# frozen_string_literal: true

class Shop < ActiveRecord::Base
  include ShopifyApp::ShopSessionStorageWithScopes

  SHOPIFY_DEVELOPMENT_PLANS = Set['partner_test', 'affiliate', 'staff_business'].freeze

  OUT_OF_BUSINESS_PLANS = Set['cancelled', 'frozen', 'fraudulent', 'paused'].freeze

  ACCOUNTS_ENABLED = Set['optional', 'required'].freeze

  has_many :shopify_themes, dependent: :destroy
  has_many :shopify_theme_customizations, through: :shopify_themes
  has_many :shopify_subscriptions, dependent: :destroy

  has_one :active_shopify_subscription, -> { active }, class_name: 'ShopifySubscription'

  scope :installed, -> { where(installed: true) }
  scope :with_active_plan, -> { where.not(shopify_plan: OUT_OF_BUSINESS_PLANS) }
  scope :uninstalled_or_not_active, -> { where(installed: false).or(Shop.where(shopify_plan: OUT_OF_BUSINESS_PLANS)) }

  def api_version
    # ShopifyApp.configuration.api_version
    '2023-01'
  end

  def https_domain
    "https://#{shopify_domain}"
  end

  def https_custom_domain
    "https://#{custom_domain}"
  end

  def development_shop?
    shopify_plan.in?(SHOPIFY_DEVELOPMENT_PLANS)
  end

  def installed?
    installed && !OUT_OF_BUSINESS_PLANS.include?(shopify_plan)
  end

  def owner_first_name
    owner.split(' ').first
  end
end
