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
    if threema_id
      if member = Member.find_by(threema_id: threema_id)
        username = member.get_username_from_threema_work.downcase
        username_array = username.strip.split /\s+/ #[lohmann, timo]
        username_first = username_array.second.gsub(/\s+/, '') #timo
        username_last = username_array.first.gsub(/\s+/, '') #lohmann

        user_first_name = I18n.transliterate(first_name.downcase).gsub(/\s+/, '')
        user_last_name = I18n.transliterate(last_name.downcase).gsub(/\s+/, '')

        first_name_valid = user_first_name == username_first || user_first_name == username_last
        last_name_valid = user_last_name == username_first || user_last_name == username_last
        first_name_and_last_name_differ = user_first_name != user_last_name

        puts first_name_valid
        puts last_name_valid
        puts first_name_and_last_name_differ

        if first_name_valid == false || last_name_valid == false || first_name_and_last_name_differ == false
          errors[:base] << "Die bei Threema hinterlegten Daten stimmen nicht mit den hier eingegebenen Daten überein."
          errors[:base] << "Bitte gleiche die eingegebenen Daten mit den in der App hinterlegten Daten ab. Zu finden Sie diese in den Einstellungen unter dem Punkt: Lizenz-Benutzername."
          errors[:base] << "Dieser setzt sich aus Nachname + Vorname zusammen. Die entsprechende Eingabe ist hier erforderlich."
          errors[:base] << "Aktuelle Eingabe: #{self.last_name} #{self.first_name}"
          throw :abort
        end
      else
        errors[:base] << "Die Threema ID kann im System nicht gefunden werden. Wenn der Account neu erstellt wurde, kann es bis zu 6h dauern bis er mit dem System synchronisiert wurde. Versuche es später noch einmal. Tritt das Problem weiterhin auf, kontaktiere bitte einen Administrator."
        throw :abort
      end
    end
  end

  def new_user_job
    NewUserJob.perform_later(self) unless self.not_signed_up
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
    end
  end

end
