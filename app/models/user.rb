class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable


  before_create :validate_threema_account_data
  before_update :validate_threema_account_data

  validates :first_name, :last_name, presence: true


  private

  def validate_threema_account_data

    member = Member.find_by(threema_id: self.threema_id)

    if self.first_name.downcase != member.first_name.downcase || self.last_name.downcase != member.last_name.downcase
      errors[:base] << "Die bei Threema hinterlegten Daten stimmen nicht mit den hier eingegebenen Daten überein."
      throw :abort
    end
  end

end
