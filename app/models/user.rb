class User < ApplicationRecord
  devise :database_authenticatable, :registerable, :rememberable

  validates :login, presence: true, uniqueness: true
  validates :fio, presence: true

  def email_required?
    false
  end

  def email_changed?
    false
  end
end
