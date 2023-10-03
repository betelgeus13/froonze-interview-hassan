module WidgetTranslations
  class PublisherService

    def initialize(widget_translation)
      @widget_translation = widget_translation
      @shop = widget_translation.shop
    end

    def call
      @shop.with_shopify_session do
        publish
      end
    end

    private

    def publish
      widget_type = @widget_translation.widget_type
      locale = @widget_translation.locale
      metafield_key = "#{@widget_translation.widget_type}_texts"
      metafield = Shopify::MetafieldService.find(key: metafield_key)

      if metafield.blank?
        default_translation = WidgetTranslations::DefaultsFetcherService.call(widget_type, @shop.primary_locale)
        metafield = Shopify::MetafieldService.publish(key: metafield_key, value: default_translation.to_json, type: :json)
      end

      if locale == @shop.primary_locale
        metafield.update_attribute(:value, @widget_translation.value.to_json)
      else
        content_digest = Digest::SHA256.hexdigest(metafield.value)
        translation = {
          locale: locale,
          key: 'value',
          value: @widget_translation.value.to_json,
          translatableContentDigest: content_digest
        }
        Shopify::TranslationService.push_translation(metafield.admin_graphql_api_id, [translation])
      end
    end

  end
end
