class Post < ApplicationRecord
  include Statable

  belongs_to :user
  belongs_to :region

  has_many_attached :files

  scope :under_review, -> { where(state: 'under_review') }
  scope :published,    -> { where(state: 'accepted') }

  # Дополнительные полезные скоупы
  scope :by_region, ->(region_id) { where(region_id: region_id) }
  scope :by_user,   ->(user_id) { where(user_id: user_id) }

  # Скоуп для отображения черновиков пользователя
  scope :user_drafts, ->(user_id) { where(user_id: user_id, status: :draft) }

  # Комбинированный скоуп для отображения всех постов доступных пользователю
  # (опубликованные в его регионе + его черновики)
  scope :available_for_user, ->(user) {
    left_outer_joins(:region)
      .where(
        'posts.status = ? AND posts.region_id = ? OR (posts.user_id = ? AND posts.status = ?)',
        statuses[:accepted],
        user.region_id,
        user.id,
        statuses[:draft]
      )
  }

  validates :title, :body, presence: true
  validate :user_can_post_to_region

  private

  def user_can_post_to_region
    return if user.region_id == region_id || user.admin?

    errors.add(:region, "У поста должен быть Ваш регион")
  end
end
