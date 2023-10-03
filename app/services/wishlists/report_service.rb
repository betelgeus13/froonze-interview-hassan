# frozen_string_literal: true

module Wishlists
  class ReportService
    attr_reader :shop

    SUM_SELECT = 'SUM(ordered_value) AS ordered_value,
      SUM(added_to_cart_value) as added_to_cart_value,
      SUM(add_counter) as add_count,
      SUM(remove_counter) as remove_count
    '

    SENT_EMAIL_FIELDS = %i[
      reminder_open
      reminder_click
      reminder_spam_complaint
      reminder_bounce
      reminder_sent
      back_in_stock_open
      back_in_stock_click
      back_in_stock_spam_complaint
      back_in_stock_bounce
      back_in_stock_sent
      low_on_stock_open
      low_on_stock_click
      low_on_stock_spam_complaint
      low_on_stock_bounce
      low_on_stock_sent
      price_drop_open
      price_drop_click
      price_drop_spam_complaint
      price_drop_bounce
      price_drop_sent
      date
    ]

    def initialize(shop:)
      @shop = shop
    end

    def call(start_date:, end_date:)
      start_date = Date.parse(start_date.to_s).beginning_of_day
      end_date = Date.parse(end_date.to_s).end_of_day
      wishlisted_items_query = shop.wishlist_items.where('updated_at >= ? AND updated_at <= ?', start_date, end_date)

      top_product_data = wishlisted_items_query.limit(10).group(:product_id).order('count_id desc').count('id')
      top_product_ids = top_product_data.keys

      added_to_cart_data = WishlistItem.where('updated_at >= ? AND updated_at <= ?', start_date, end_date)
                                       .where(product_id: top_product_ids).where.not(added_to_cart_at: nil).group(:product_id).count
      ordered_data = WishlistItem.where('updated_at >= ? AND updated_at <= ?', start_date, end_date)
                                 .where(product_id: top_product_ids).where.not(order_completed_at: nil).group(:product_id).count

      top_products = shop.products.where(id: top_product_data.keys).index_by(&:id).map do |product_id, product|
        hash = product.attributes
        hash['wishlist_count'] = top_product_data[product_id] || 0
        hash['added_to_cart_count'] = added_to_cart_data[product_id] || 0
        hash['ordered_count'] = ordered_data[product_id] || 0

        OpenStruct.new(hash)
      end

      top_products.sort_by! { |p| -p['wishlist_count'] }

      wishlist_daily_activities_query = shop.wishlist_daily_activities.where('date >= ? AND date <= ?', start_date, end_date)
      wishlist_daily_activities_data = wishlist_daily_activities_query.select(SUM_SELECT).to_a.first

      email_data = get_email_data(shop:, start_date:, end_date:)
      {
        wishlist_count: wishlisted_items_query.active.count,
        total_wishlist_count: wishlisted_items_query.count,
        ordered_value: wishlist_daily_activities_data.ordered_value.to_i,
        added_to_cart_value: wishlist_daily_activities_data.added_to_cart_value.to_i,
        added_count: wishlist_daily_activities_data.add_count.to_i,
        remove_count: wishlist_daily_activities_data.remove_count.to_i,
        top_products:,
        email_data:
      }
    rescue StandardError => e
      Utils::RollbarService.error(e)
      { error: 'Something went wrong. Please reload the page and try again' }
    end

    private

    def get_email_data(shop:, start_date:, end_date:)
      sent_emails = shop.sent_email_daily_activities.between(start_date:, end_date:).select(SENT_EMAIL_FIELDS).index_by(&:date)
      data = {
        all: {
          sent_series: [],
          sent_total: 0,
          open_series: [],
          open_total: 0,
          click_series: [],
          click_total: 0,
          bounce_series: [],
          bounce_total: 0,
          spam_complaint_series: [],
          spam_complaint_total: 0
        },
        reminder: {
          sent_series: [],
          sent_total: 0,
          open_series: [],
          open_total: 0,
          click_series: [],
          click_total: 0,
          bounce_series: [],
          bounce_total: 0,
          spam_complaint_series: [],
          spam_complaint_total: 0
        },
        price_drop: {
          sent_series: [],
          sent_total: 0,
          open_series: [],
          open_total: 0,
          click_series: [],
          click_total: 0,
          bounce_series: [],
          bounce_total: 0,
          spam_complaint_series: [],
          spam_complaint_total: 0
        },
        back_in_stock: {
          sent_series: [],
          sent_total: 0,
          open_series: [],
          open_total: 0,
          click_series: [],
          click_total: 0,
          bounce_series: [],
          bounce_total: 0,
          spam_complaint_series: [],
          spam_complaint_total: 0
        },
        low_on_stock: {
          sent_series: [],
          sent_total: 0,
          open_series: [],
          open_total: 0,
          click_series: [],
          click_total: 0,
          bounce_series: [],
          bounce_total: 0,
          spam_complaint_series: [],
          spam_complaint_total: 0
        }
      }

      from_date = Date.new(start_date.year, start_date.month, start_date.day)
      to_date = Date.new(end_date.year, end_date.month, end_date.day)
      labels = []

      (from_date..to_date).each do |day|
        labels << day.strftime('%b %d')
        day_data = sent_emails[day] || OpenStruct.new
        day_sent_total = 0
        day_open_total = 0
        day_click_total = 0
        day_bounce_total = 0
        day_spam_complaint_total = 0
        %i[reminder price_drop back_in_stock low_on_stock].each do |email_type|
          data[email_type][:sent_series] << day_data.send("#{email_type}_sent".to_sym).to_i
          data[email_type][:sent_total] += day_data.send("#{email_type}_sent".to_sym).to_i
          day_sent_total += day_data.send("#{email_type}_sent".to_sym).to_i
          data[email_type][:open_series] << day_data.send("#{email_type}_open".to_sym).to_i
          data[email_type][:open_total] += day_data.send("#{email_type}_open".to_sym).to_i
          day_open_total += day_data.send("#{email_type}_open".to_sym).to_i
          data[email_type][:click_series] << day_data.send("#{email_type}_click".to_sym).to_i
          data[email_type][:click_total] += day_data.send("#{email_type}_click".to_sym).to_i
          day_click_total += day_data.send("#{email_type}_click".to_sym).to_i
          data[email_type][:bounce_series] << day_data.send("#{email_type}_bounce".to_sym).to_i
          data[email_type][:bounce_total] += day_data.send("#{email_type}_bounce".to_sym).to_i
          day_bounce_total += day_data.send("#{email_type}_bounce".to_sym).to_i
          data[email_type][:spam_complaint_series] << day_data.send("#{email_type}_spam_complaint".to_sym).to_i
          data[email_type][:spam_complaint_total] += day_data.send("#{email_type}_spam_complaint".to_sym).to_i
          day_spam_complaint_total += day_data.send("#{email_type}_spam_complaint".to_sym).to_i
        end

        data[:all][:sent_series] << day_sent_total
        data[:all][:sent_total] += day_sent_total
        data[:all][:open_series] << day_open_total
        data[:all][:open_total] += day_open_total
        data[:all][:click_series] << day_click_total
        data[:all][:click_total] += day_click_total
        data[:all][:bounce_series] << day_bounce_total
        data[:all][:bounce_total] += day_bounce_total
        data[:all][:spam_complaint_series] << day_spam_complaint_total
        data[:all][:spam_complaint_total] += day_spam_complaint_total
      end

      data[:labels] = labels

      data
    end
  end
end
