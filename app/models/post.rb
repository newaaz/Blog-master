class Post < ApplicationRecord
  include Statable

  belongs_to :user
  belongs_to :region

  has_many_attached :files

  validates :title, :body, presence: true
  validate :user_can_post_to_region

  private

  def user_can_post_to_region
    return if user.admin?
    return if user.region_id == region_id

    errors.add(:region, "You can only post to your region")
  end
end
