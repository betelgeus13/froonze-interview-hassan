# frozen_string_literal: true
class ShopifyThemeCustomization < ApplicationRecord
  TYPES = Set[
    CUSTOMER_PAGE_TYPE = 'customer_page',
    SOCIAL_LOGINS = 'social_logins',
    WISHLIST = 'wishlist',
    CUSTOM_FORMS = 'custom_forms',
  ]

  attr_readonly :customization_type

  belongs_to :shopify_theme

  validates :shopify_theme_id, presence: true, uniqueness: { scope: :customization_type }
  validates :customization_type, presence: true, inclusion: { in: TYPES }

  scope :customer_page, -> { where(customization_type: CUSTOMER_PAGE_TYPE) }
end
