class Group < ApplicationRecord
  has_many :group_members , dependent: :destroy
  has_many :members, through: :group_members

  has_attached_file :avatar,
  styles: { medium: "512x512>" }


  validates_attachment_content_type :avatar, content_type: /\Aimage\/.*\z/

  validates_uniqueness_of :threema_id, :allow_blank => true, :allow_nil => true
  validates_length_of :name, minimum: 1, maximum: 255, allow_blank: false
  validates_uniqueness_of :name


  default_scope {where(state: "active")}.sort
  scope :include_deleted, -> { self.all.unscoped }
  scope :local_groups, -> { where(threema_id: ['', nil]) }

  after_save :upload_image
  after_update :group_approved

  private

  def upload_image
    if self.avatar.present?
      UploadImageJob.perform_later(self)
    end
  end

  def group_approved
    UserMailer.group_approved(self, User.find(self.created_by)).deliver_later if self.saved_change_to_threema_id && self.threema_id.present?
  end

end
