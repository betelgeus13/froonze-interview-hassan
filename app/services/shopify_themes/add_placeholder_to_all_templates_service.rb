# frozen_string_literal: true

# not used anymore as preparation for built for shopify badge and 04/2023 api
module ShopifyThemes
  class AddPlaceholderToAllTemplatesService
    ASSETS_URL = [
      'templates/customers/account.liquid',
      'templates/customers/addresses.liquid',
      'templates/customers/order.liquid'
    ].freeze

    PLACEHOLDER = "<div id='frcp_app_wrapper' class='frcp-app-wrapper'></div>\n"

    def call(theme:)
      ASSETS_URL.each do |asset_url|
        theme_file = ShopifyAPI::Asset.find(asset_url, params: { theme_id: theme&.external_id }.compact)
        next if theme_file.value.include?(PLACEHOLDER)

        theme_file.value = PLACEHOLDER + theme_file.value
        theme_file.save!
      rescue ActiveResource::ResourceNotFound => e
        # The templates are added after a theme is created. So sometimes this job may run before the
        #   the files are created in Shopify. So we should retry adding the placeholder later.
        # These errors should retried by sidekiq.

        # in case the template uses json templates instead of liquid we should just return
        theme_uses_json_template = begin
          ShopifyAPI::Asset.find('templates/customers/account.json', params: { theme_id: theme&.external_id }.compact)
          return { error: 'Theme uses json templates. Cannot add placeholder' }
        rescue ActiveResource::ResourceNotFound => exception
          false
        end

        raise e unless theme_uses_json_template
      rescue ActiveResource::ClientError => e
        raise e if e.message.squish.include?('Response code = 429. Response message = Too Many Requests.')

        # These errors should retried by sidekiq.

        Utils::RollbarService.error(e, shop_id: theme.shop_id, theme_id: theme.id)

      rescue StandardError => e
        Utils::RollbarService.error(e, shop_id: theme.shop_id, theme_id: theme.id)
      end
    end
  end
end
