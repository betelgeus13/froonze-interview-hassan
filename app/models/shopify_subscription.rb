# frozen_string_literal: true

class ShopifySubscription < ActiveRecord::Base
  scope :pending, -> { where(activated_at: nil, cancelled_at: nil) }
  scope :not_pending, -> { where('activated_at IS NOT NULL OR cancelled_at IS NOT NULL') }
  scope :active, -> { where.not(activated_at: nil).where(cancelled_at: nil) }
end
