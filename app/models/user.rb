class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :invitable, :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable, :confirmable

  before_create :validate_threema_account_data
  before_update :validate_threema_account_data

  after_create :new_user_job
  after_invitation_accepted :invitation_accepted_notification

  after_save :role_changed_mail#, if role_changed?

  validates :first_name, :last_name, :threema_id,  presence: true

  default_scope {order(last_name: :asc)}

  scope :admins, -> { where(role: "Administrator") }
  scope :owners, -> { where(role: "Besitzer") }


  def is_user_or_higher
    if self.role == "Benutzer" || self.role == "Verwaltung" || self.role == "Administrator" || self.role == "Besitzer"
      return true
    end
  end

  def is_management_or_higher
    if self.role == "Verwaltung" || self.role == "Administrator" || self.role == "Besitzer"
      return true
    end
  end

  def is_admin_or_higher
    if self.role == "Administrator" || self.role == "Besitzer"
      return true
    end
  end

  def is_owner
    return true if self.role == "Besitzer"
  end

  def name
    self.first_name + " " + self.last_name if self.first_name && self.last_name
  end

  def is_unconfirmed
    self.role == "Unbestätigt"
  end

  def member
    Member.find_by(threema_id: self.threema_id)
  end

  def not_signed_up
    self.first_name.nil?
  end

  private

  def validate_threema_account_data
    if self.threema_id
      member = Member.find_by(threema_id: self.threema_id)

      if self.first_name.downcase != member.first_name.downcase || self.last_name.downcase != member.last_name.downcase
        errors[:base] << "Die bei Threema hinterlegten Daten stimmen nicht mit den hier eingegebenen Daten überein."
        throw :abort
      end
    end
  end

  def new_user_job
    NewUserJob.perform_later(self) unless self.not_signed_up
    puts "**********NEUER USER******************"
    puts self.first_name unless self.not_signed_up
  end

  def invitation_accepted_notification
    UserMailer.welcome_email(self).deliver_later
    User.owners.each do |owner|
      AdminMailer.invitation_accepted(self, owner).deliver_later
    end
  end

  def role_changed_mail
    if self.saved_change_to_role
      UserMailer.role_changed(self, self.saved_change_to_role).deliver_later unless self.not_signed_up
      puts "****************************"
      puts self.saved_change_to_role[1] unless self.not_signed_up
    end
  end

end
