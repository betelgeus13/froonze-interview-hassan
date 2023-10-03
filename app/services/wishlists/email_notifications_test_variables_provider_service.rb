module Wishlists
  class EmailNotificationsTestVariablesProviderService
    def call(shop:)
      settings = ::Setting.select(:email_logo, :wishlist_reminder_notification_products_count).find_by(shop_id: shop.id)
      logo_url = settings.email_logo
      products = shop.products.in_store.limit(settings.wishlist_reminder_notification_products_count)

      products_data = products.map do |product|
        {
          href: "#{shop.https_custom_domain}/products/#{product.handle}",
          image_src: product.picture_url,
          title: product.title,
          price: "#{product.variants.values.first['price']}#{shop.currency}"
        }
      end

      variables = {
        first_name: 'John',
        last_name: 'Doe',
        full_name: 'John Doe',
        shop_name: shop.name,
        shop_https_domain: shop.https_custom_domain,
        reply_to: shop.reply_to,
        logo_url:,
        product: products_data.first,
        products: products_data,
        unsubscribe_url: 'https://example.com'
      }.deep_stringify_keys
    end
  end
end
