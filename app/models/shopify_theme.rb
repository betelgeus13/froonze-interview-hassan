# frozen_string_literal: true

class ShopifyTheme < ApplicationRecord

  ROLES = Set[
    'main',
    'unpublished',
    GLOBAL_CUSTOMIZATION_ROLE = 'global_customization'
  ].freeze

  GLOBAL_CUSTOMIZATION_NAME = 'Global Customization'

  GLOBAL_CUSTOMIZATION_PARAMS = {
    name: GLOBAL_CUSTOMIZATION_NAME,
    role: GLOBAL_CUSTOMIZATION_ROLE,
    external_id: 0
  }.freeze

  belongs_to :shop
  has_many :shopify_theme_customizations, dependent: :destroy

  validates_uniqueness_of :external_id, { scope: :shop }
  validates_presence_of :name
  validates :role, presence: true, inclusion: { :in => ROLES }

  scope :excluding_global, -> { where.not(role: GLOBAL_CUSTOMIZATION_ROLE) }
  scope :live, -> { where(role: 'main') }

  def live?
    self.role == 'main'
  end

  def global_customization?
    self.role == GLOBAL_CUSTOMIZATION_ROLE
  end


end
