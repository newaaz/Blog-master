class Post < ApplicationRecord
  include Statable

  belongs_to :user
  belongs_to :region

  before_validation :set_default_region, if: -> { user.admin? && region_id.nil? }
  before_create :set_published, if: -> { user.admin? }

  has_many_attached :files

  scope :under_review, -> { where(state: 'under_review') }
  scope :published,    -> { where(state: 'approved') }

  validates :title, :body, presence: true
  validate :user_can_post_to_region

  def self.find_by_filters(filters)
    conditions = ['state = ?']
    values = [Post.states[:approved]]

    if filters[:region_id].present?
      conditions << 'region_id = ?'
      values << filters[:region_id]
    end

    if filters[:user_id].present?
      conditions << 'user_id = ?'
      values << filters[:user_id]
    end

    if filters[:start_date].present? && filters[:end_date].present?
      start_of_day = Date.parse(filters[:start_date]).beginning_of_day
      end_of_day = Date.parse(filters[:end_date]).end_of_day
      conditions << 'created_at BETWEEN ? AND ?'
      values << start_of_day << end_of_day
    end

    Post.with_attached_files
        .includes(:region, :user)
        .where(conditions.join(' AND '), *values)
        .order(created_at: :desc)
  end

  private

  def user_can_post_to_region
    return if user.region_id == region_id || user.admin?

    errors.add(:region, "У поста должен быть Ваш регион")
  end

  def set_default_region
    self.region = Region.first
  end

  def set_published
    self.state = :approved
    self.published_at = Time.current
  end
end
