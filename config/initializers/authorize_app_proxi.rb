# configuration taken from https://github.com/Shopify/shopify_app/issues/846
ALLOWED_PATHS = %w(
  /api/graphql
  /social_logins/
  /custom_forms/
  /wishlist/
).freeze

Rails.application.config.host_authorization = {
  # if it came via the shopify app proxy, it's fine
  exclude: lambda { |request|
    # we only care about things that arrive via the app proxy, so bail
    # early unless that's what clearly we're looking at
    next false if ALLOWED_PATHS.none? { |path| request.path.starts_with?(path) }

    query_hash = Rack::Utils.parse_query(request.env['QUERY_STRING'])
    signature = query_hash.delete('signature')

    # unsigned requests don't count; bail early if we're missing a signature
    next false unless signature

    sorted_params = query_hash.collect { |k, v| "#{k}=#{Array(v).join(',')}" }.sort.join

    calculated_signature = OpenSSL::HMAC.hexdigest(
      OpenSSL::Digest.new('sha256'),
      ShopifyApp.configuration.secret,
      sorted_params
    )

    ActiveSupport::SecurityUtils.secure_compare(
      calculated_signature,
      signature
    )
  },

  # this is our 403 response, when host verification fails. we do this to standardize the
  # response, which has the side-effect of making this much nicer for dev and test environments :)
  response_app: lambda { |env|
                  request = ActionDispatch::Request.new(env)

                  body = '403 Forbidden'

                  [403, {
                    'Content-Type' => "text/plain; charset=#{ActionDispatch::Response.default_charset}",
                    'Content-Length' => body.bytesize.to_s
                  }, [body]]
                }
}
