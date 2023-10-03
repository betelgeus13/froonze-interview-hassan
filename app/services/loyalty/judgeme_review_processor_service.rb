# frozen_string_literal: true

module Loyalty
  class JudgemeReviewProcessorService
    VERIFIED_BUYER_SOURCES = %w[
      fulfillment
      pushowl
      multi-review
      picture-first
      email-other-products
      user-profile
      email
    ]

    VERIFIED_BUYER = 'buyer'

    def initialize(shop:, customer:, review_id:, has_pictures:, has_videos:, verified:, rating:, source:)
      @shop = shop
      @customer = customer

      @review_id = review_id
      @has_pictures = has_pictures
      @has_videos = has_videos
      @verified = verified
      @rating = rating
      @source = source
    end

    def call
      return { warning: 'Customer excluded from loyalty' } if @customer.excluded_from_loyalty?

      loyalty_event = @customer.loyalty_events.judgeme.find_by(object_external_id: @review_id)
      return { loyalty_event: } if loyalty_event.present?

      earning_rule = @shop.loyalty_earning_rules.judgeme_type.active.take
      return { error: 'No earning rule' } if earning_rule.blank?

      refetch_review_data(earning_rule:)
      return { error: 'Review not qualified' } unless qualified?(earning_rule:)

      { loyalty_event: create_earning_event(earning_rule:) }
    end

    private

    def create_earning_event(earning_rule:)
      new_points = calculate_earning_points(earning_rule:)
      earning_event = nil
      Loyalty::EventCreatorHelperService.call(@customer) do
        earning_event = @customer.loyalty_events.judgeme.create!(
          object_external_id: @review_id,
          loyalty_earning_rule: earning_rule,
          points: new_points
        )
      end
      earning_event
    end

    def calculate_earning_points(earning_rule:)
      value = earning_rule.value.to_i
      value += earning_rule.advanced_options['with_pictures_value'].to_i if @has_pictures
      value += earning_rule.advanced_options['with_videos_value'].to_i if @has_videos
      value
    end

    def qualified?(earning_rule:)
      return false if earning_rule.advanced_options['only_pictures'] && !@has_pictures
      return false if earning_rule.advanced_options['only_videos'] && !@has_videos

      return false if earning_rule.advanced_options['verified_buyer'] && !verified_review?
      return false if earning_rule.advanced_options['minimum_rating'] && @rating < earning_rule.advanced_options['minimum_rating']

      return false if earning_rule.advanced_options['max_rewards'] && max_rewards_reached?(earning_rule:)

      true
    end

    def max_rewards_reached?(earning_rule:)
      @customer.loyalty_events.judgeme.where('created_at > ?', 24.hours.ago).count >= earning_rule.advanced_options['max_rewards']
    end

    def verified_review?
      VERIFIED_BUYER_SOURCES.include?(@source) || @verified.include?(VERIFIED_BUYER)
    end

    def refetch_review_data(earning_rule:)
      return unless !@has_videos && (earning_rule.advanced_options['only_videos'] || earning_rule.advanced_options['with_videos_value'])

      ret = Integrations::Judgeme::FetchReviewDataService.new(shop: @shop, review_id: @review_id).call
      return if ret[:data].blank?

      @source = ret.dig(:data, :source)
      @verified = ret.dig(:data, :verified)
      @has_pictures ||= ret.dig(:data, :has_pictures)
      @has_videos ||= ret.dig(:data, :has_videos)
    end
  end
end
