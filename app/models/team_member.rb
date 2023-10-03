class TeamMember < ApplicationRecord
  ROLES = [
    ADMIN_ROLE = 'admin'
  ].freeze

  validates :email, presence: true, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates_inclusion_of :role, in: ROLES, allow_nil: true

  scope :admin, -> { where(role: ADMIN_ROLE) }
end
