module Wishlists
  class EmailNotificationDataProviderService
    TOKEN_SECRET = Rails.application.credentials.loyalty[:email_token_secret]

    def call(wishlist_items:, email_type:)
      shop = wishlist_items.first.shop
      product = wishlist_items.first.product
      logo_url = ::Setting.select(:email_logo).find_by(shop_id: shop.id).email_logo
      customer = wishlist_items.first.customer

      ret = ::Wishlists::EmailTemplateFetcherService.new(shop:).get_with_locale(email_type:, locale: customer.locale)
      return { error: ret[:error] } if ret[:error]

      email_template = ret[:result]
      token = JWT.encode({ customer_id: customer.id }, TOKEN_SECRET)
      unsubscribe_url = Rails.application.routes.url_helpers.wishlist_unsubscribe_url(token:)

      variables = {
        first_name: customer.first_name,
        last_name: customer.last_name,
        full_name: customer.full_name,
        shop_name: shop.name,
        shop_https_domain: shop.https_custom_domain,
        reply_to: shop.reply_to,
        logo_url:,
        product: product_data(wishlist_item: wishlist_items.first),
        products: wishlist_items.map { |wi| product_data(wishlist_item: wi) },
        unsubscribe_url:
      }.deep_stringify_keys

      body = Liquid::Template.parse(email_template.html_inlined_css).render(variables)
      subject = Liquid::Template.parse(email_template.subject).render(variables)

      {
        to: customer.email,
        from: shop.from_email,
        reply_to: shop.reply_to,
        subject:,
        body:,
        tag: "#{email_type}__#{shop.shopify_domain}",
        unsubscribe_url:
      }
    end

    private

    def product_data(wishlist_item:)
      product = wishlist_item.product

      {
        href: "#{product.shop.https_custom_domain}/products/#{product.handle}?variant=#{wishlist_item.variant_external_id}",
        image_src: product.picture_url,
        title: product.title,
        price: "#{product.variants.values.first['price']}#{product.shop.currency}"
      }
    end
  end
end
