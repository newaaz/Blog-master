class User < ApplicationRecord
  devise :database_authenticatable, :registerable, :rememberable, :validatable

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

  def will_save_change_to_email?
    false
  end
end
