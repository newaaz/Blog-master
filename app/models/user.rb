class User < ApplicationRecord
  devise :database_authenticatable, :registerable, :rememberable

  has_many :posts, dependent: :destroy
  belongs_to :region, optional: true

  validates :region, presence: true, unless: :admin?
  validates :login, presence: true, uniqueness: true
  validates :fio, presence: true

  def email_required?
    false
  end

  def email_changed?
    false
  end
end
