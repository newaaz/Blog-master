class Region < ApplicationRecord
  belongs_to :federal_district
  has_many :users, dependent: :nullify
  has_many :posts, dependent: :nullify

  validates :name, presence: true, uniqueness: true
end
