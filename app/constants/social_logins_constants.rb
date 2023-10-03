# frozen_string_literal: true

module SocialLoginsConstants
  DEFAULT_PROVIDERS = Set[
    'facebook',
    'google',
    'twitter',
    'amazon',
    'linkedin',
  ].freeze

  OTHER_PROVIDERS = Set[
    APPLE = 'apple',
    MICROSOFT = 'microsoft',
  ].freeze

  ADVANCED_PLAN_PROVIDERS = Set[
    APPLE,
  ].freeze

  ALL_PROVIDERS = (DEFAULT_PROVIDERS + OTHER_PROVIDERS).freeze

  DEFAULT_CUSTOMER_TAGS = [
    'froonze',
    '{ provider }',
    '{ provider }_{ user_id }'
  ].freeze

  CUSTOMER_TAGS_LIMIT = 5

  GOOGLE_ONE_TAP_MARGIN_TOP_DEFAULT = 40

  GOOGLE_ONE_TAP_MARGIN_RIGHT_DEFAULT = 20
end
