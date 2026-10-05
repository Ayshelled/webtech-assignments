class Neighborhood < ApplicationRecord
  has_many :properties, dependent: :restrict_with_error
  has_many :listings, through: :properties

  scope :alphabetical, -> { order(:city, :name) }

  validates :name, presence: true, length: { maximum: 100 },
                   uniqueness: { scope: :city, case_sensitive: false }
  validates :city, presence: true, length: { maximum: 100 }
end
