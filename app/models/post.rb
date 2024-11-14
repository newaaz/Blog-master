class Post < ApplicationRecord
  include Statable

  belongs_to :user
  belongs_to :region

  has_many_attached :files

  validates :title, :body, presence: true
  # validate :user_can_post_to_region

  private

  def user_can_post_to_region
    return if user.region_id == region_id || user.admin?

    errors.add(:region, "У поста должен быть Ваш регион")
  end
end
