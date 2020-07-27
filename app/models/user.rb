class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable, :confirmable

  before_create :validate_threema_account_data
  before_update :validate_threema_account_data

  after_create :new_user_job
  after_save :role_changed_mail#, if role_changed?

  validates :first_name, :last_name, :threema_id,  presence: true

  scope :admins, -> { where(role: "Administrator") }


  def is_admin
    self.role == "Administrator"
  end

  def name
    self.first_name + " " + self.last_name if self.first_name && self.last_name
  end

  def is_unconfirmed
    self.role == "unconfirmed"
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
    NewUserJob.perform_later(self)
  end

  def role_changed_mail
    UserMailer.role_changed(self, self.saved_change_to_role).deliver_later if self.saved_change_to_role
  end

end
