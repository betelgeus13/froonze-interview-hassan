module Shopify
  module Subscriptions
    class ManagerService
      BASE_CHARGE_GRANDFATHER_DATE = Date.new(2022, 6, 2)

      BASE_CHARGE_TIERS = [
        {
          threshold: 20_000,
          price: 25
        },
        {
          threshold: 5_000,
          price: 15
        },
        {
          threshold: 1_000,
          price: 5
        }
      ].freeze

      MIN_THRESHOLD = BASE_CHARGE_TIERS.last[:threshold]
      MAX_CUSTOMERS_COUNT_LIMIT = 100_000

      PLUGIN_INFO = {
        ShopifySubscription::REORDER_BUTTON => {
          price: 0.5,
          name: 'Reorder Button'
        },
        ShopifySubscription::CUSTOM_PAGES => {
          price: 2,
          name: 'Custom Pages'
        },
        ShopifySubscription::RECENTLY_VIEWED => {
          price: 1,
          name: 'Recently Viewed Products'
        },
        ShopifySubscription::SOCIAL_LOGINS => {
          name: 'Social Logins',
          plans: {
            ShopifySubscription::SOCIAL_LOGINS_BASIC_PLAN => {
              price: 2,
              name: 'Basic'
            },
            ShopifySubscription::SOCIAL_LOGINS_ADVANCED_PLAN => {
              price: 4.5,
              name: 'Advanced'
            }
          }
        },
        ShopifySubscription::WISHLIST => {
          name: 'Wishlist',
          plans: {
            ShopifySubscription::WISHLIST_BASIC_PLAN => {
              price: 4,
              name: 'Basic'
            },
            ShopifySubscription::WISHLIST_ADVANCED_PLAN => {
              price: 10,
              name: 'Advanced'
            },
            ShopifySubscription::WISHLIST_PREMIUM_PLAN => {
              price: 15,
              name: 'Premium'
            }
          }
        },
        ShopifySubscription::ORDER_ACTIONS => {
          name: 'Cancel Order Button',
          plans: {
            ShopifySubscription::ORDER_ACTIONS_BASIC_PLAN => {
              price: 4,
              name: 'Basic'
            }
          }
        },
        ShopifySubscription::CUSTOMER_PAGE_INTEGRATIONS => {
          name: 'Account Integrations',
          plans: {
            ShopifySubscription::CUSTOMER_PAGE_INTEGRATIONS_BASIC_PLAN => {
              price: 2,
              name: 'Basic'
            }
          }
        },
        ShopifySubscription::CUSTOM_FORMS => {
          name: 'Custom Forms',
          plans: {
            ShopifySubscription::CUSTOM_FORMS_BASIC_PLAN => {
              price: 6,
              name: 'Basic',
            },
            ShopifySubscription::CUSTOM_FORMS_ADVANCED_PLAN => {
              price: 12,
              name: 'Advanced',
            },
            ShopifySubscription::CUSTOM_FORMS_PREMIUM_PLAN => {
              price: 30,
              name: 'Premium',
            }
          }
        },
        ShopifySubscription::LOYALTY => {
          name: 'Loyalty',
          plans: {
            ShopifySubscription::LOYALTY_FIRST_PLAN => {
              price: 1,
              name: '100 orders',
              max_orders_count: 100,
            },
            ShopifySubscription::LOYALTY_SECOND_PLAN => {
              price: 10,
              name: '500 orders',
              max_orders_count: 500,
            },
            ShopifySubscription::LOYALTY_THIRD_PLAN => {
              price: 30,
              name: '1000 orders',
              max_orders_count: 1000,
            },
            ShopifySubscription::LOYALTY_FOURTH_PLAN => {
              price: 60,
              name: 'Unlimited',
            },
          }
        }
      }.freeze

      def initialize(shop, plugins = {})
        @shop = shop
        @plugins = plugins
        shop.update_customers_count if shop.customers_count.blank?
      end

      def generate_subscription
        # TODO: Implement limits checks for wishlist plugins
        base_charge_in_cents = base_charge * 100
        local_subscription = @shop.shopify_subscriptions.new(plugins: @plugins, base_charge_in_cents: base_charge_in_cents)
        return { error: 'Plugins are not valid' } unless local_subscription.plugins_valid?
        error = validate_order_counts
        return { error: } if error.present?

        name = generate_name
        amount = generate_amount
        if amount.zero?
          cancel_active_subscription
        else
          local_subscription.amount_in_cents = amount * 100
          create_new_subscription(local_subscription, name, amount)
        end
      end

      def base_charge
        @base_charge ||= calculate_base_charge
      end

      def custom_base_charge?
        @shop.customers_count > MAX_CUSTOMERS_COUNT_LIMIT
      end

      def generate_name(ignore_base: false)
        names_list = []
        @plugins.each do |plugin, value|
          next if value.blank?

          info = PLUGIN_INFO[plugin]
          if info[:plans]
            plan_info = info[:plans][value]
            name = info[:name]
            name += "(#{plan_info[:name]})" if info[:plans].count > 1
            names_list << name
          else
            names_list << info[:name]
          end
        end
        full_name = names_list.join(' + ')
        full_name = ['Base', full_name.presence].compact.join(' + ') if !ignore_base && base_charge > 0
        full_name
      end

      private

      def validate_order_counts
        activated_plugins = @plugins.select { |_, plan| plan.present? }
        activated_plugins.each do |plugin, plan|
          all_plans = plan_info = PLUGIN_INFO.dig(plugin, :plans)
          next if all_plans.blank?
          plan_info = all_plans[plan]
          max_orders_count = plan_info[:max_orders_count]
          next if max_orders_count.blank?
          if @shop.monthly_orders_count > max_orders_count
            return "Your shop exceeded maximum monthly orders limit for #{plugin} plugin"
          end
        end
        nil
      end

      def base_charge_grandfathered?
        @shop.created_at < BASE_CHARGE_GRANDFATHER_DATE
      end

      def calculate_base_charge
        return 0 if base_charge_grandfathered?
        return 0 if @shop.customers_count <= MIN_THRESHOLD
        if custom_base_charge?
          return @shop.custom_base_charge_in_cents.present? ? @shop.custom_base_charge_in_cents.to_f / 100 : nil
        end

        tier = BASE_CHARGE_TIERS.find { |tier| @shop.customers_count > tier[:threshold] }
        tier[:price]
      end

      def generate_amount
        amount = 0
        @plugins.each do |plugin, value|
          next if value.blank?

          info = PLUGIN_INFO[plugin]
          if info[:plans]
            plan_info = info[:plans][value]
            amount += plan_info[:price]
          else
            amount += info[:price]
          end
        end
        amount += base_charge
        amount
      end

      def cancel_active_subscription
        if @shop.active_shopify_subscription
          result = Shopify::Subscriptions::CancellerService.new(@shop).call
          result[:error].present? ? result : {}
        else
          { error: 'Could not find active subscription. Please contact support' } # this should not happen
        end
      end

      def create_new_subscription(local_subscription, name, amount)
        result = Shopify::Subscriptions::CreatorService.new(@shop, name, amount).call
        return result if result[:error]

        remote_subscription = result[:subscription]
        confirmation_url = result[:confirmation_url]
        local_subscription.external_id = remote_subscription.id.split('gid://shopify/AppSubscription/').last
        local_subscription.is_test = remote_subscription.test
        local_subscription.save!

        { confirmation_url: confirmation_url }
      end
    end
  end
end
