# frozen_string_literal: true

module Loyalty
  class EmailTemplateVariablesReplacerService
    def initialize(loyalty_event:, locale:, is_test: false)
      @is_test = is_test
      @locale = locale
      @shop = loyalty_event.shop
      @translator ||= WidgetTranslations::TranslatorService.new(@shop, WidgetTranslation::LOYALTY, locale)
      return if is_test

      @customer = loyalty_event.customer
      @loyalty_event = loyalty_event
    end

    def call(content)
      return '' if content.blank?

      if @is_test
        replace_test_variables(content)
      else
        replace_real_variables(content)
      end
    end

    private

    def replace_test_variables(content)
      variables = {
        shop_name: 'Shop name',
        first_name: 'John',
        last_name: 'Doe',
        full_name: 'John Doe',
        balance_points: '1000',
        discount_code: 'TEST_CODE',
        earning_points_amount: '100',
        reward_name: '"Test reward"'
      }
      variables[:earning_action] = @translator.call(section: 'email', key: 'earning_action__earning_order')
      variables = variables.stringify_keys
      Liquid::Template.parse(content).render(variables)
    end

    def replace_real_variables(content)
      variables = {
        shop_name: @shop.name,
        first_name: @customer.first_name,
        last_name: @customer.last_name,
        full_name: @customer.full_name,
        balance_points: @customer.loyalty_points.to_i.to_s
      }
      if @loyalty_event.earning?
        variables[:earning_points_amount] = @loyalty_event.points.to_s
        variables[:earning_action] = @translator.call(section: 'email', key: "earning_action__#{@loyalty_event.event_type}")
      elsif @loyalty_event.spend_points?
        variables[:reward_name] = "\"#{@loyalty_event.loyalty_spending_rule.title}\""
        variables[:discount_code] = @loyalty_event.loyalty_discount.code
      end
      variables = variables.stringify_keys
      Liquid::Template.parse(content).render(variables)
    end
  end
end
