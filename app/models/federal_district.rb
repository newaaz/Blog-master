class FederalDistrict < ApplicationRecord
  has_many :regions, dependent: :destroy

  validates :name, presence: true, uniqueness: true
end
