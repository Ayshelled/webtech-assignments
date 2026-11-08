class User < ApplicationRecord
  has_secure_password
  has_many :sessions, dependent: :destroy

  enum :role, { member: "member", moderator: "moderator" }, validate: true

  # As host
  has_many :properties, dependent: :destroy
  has_many :listings, through: :properties
  # As seeker
  has_many :applications, dependent: :destroy
  has_many :visits, through: :applications
  has_many :reviews, through: :visits
  has_many :saved_listings, dependent: :destroy
  has_many :saved_rooms, through: :saved_listings, source: :listing
  has_many :reports, dependent: :destroy

  normalizes :email_address, with: ->(email) { email.strip.downcase }

  validates :email_address, presence: true, uniqueness: true, length: { maximum: 255 },
                            format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :full_name, presence: true, length: { maximum: 120 }
  validates :phone, length: { maximum: 30 }, allow_blank: true
  validates :bio, length: { maximum: 500 }
  # has_secure_password already requires a password on sign up and checks the
  # confirmation; allow_nil skips it when a profile is saved without one
  validates :password, length: { minimum: 8 }, allow_nil: true
end
