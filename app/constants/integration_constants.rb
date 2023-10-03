# frozen_string_literal: true

module IntegrationConstants
  ALL_KEYS = [
    KLAVIYO = 'klaviyo',
    FACEBOOK_PIXEL = 'facebook_pixel',
    GOOGLE_ANALYTICS = 'google_analytics',
    RIVO_REWARDS = 'rivo_rewards',
    SMILE_IO = 'smile_io',
    YOTPO_REWARDS = 'yotpo_rewards',
    BON_RWARDS = 'bon_rewards',
    RISE_AI = 'rise_ai',
    YOTPO_SUBSCRIPTIONS = 'yotpo_subscriptions',
    APPSTLE_SUBSCRIPTIONS = 'appstle_subscriptions',
    RECHARGE_SUBSCRIPTIONS = 'recharge_subscriptions',
    PAY_WHIRL_SUBSCRIPTIONS = 'pay_whirl_subscriptions',
    SEAL_SUBSCRIPTIONS = 'seal_subscriptions',
    LOOP_SUBSCRIPTIONS = 'loop_subscriptions',
    APPSTLE_MEMBERSHIPS = 'appstle_memberships',
    VIFY_ORDER_PRINTER = 'vify_order_printer',
    ORDER_PRINTER_PRO = 'order_printer_pro',
    WIZARD_INVOICE = 'wizard_invoice',
    SUFIO_INVOICE = 'sufio_invoice',
    ORDERIFY = 'orderify',
    AFTERSHIP_RETURNS = 'aftership_returns',
    RETURN_PRIME = 'return_prime',
    PARCEL_PANEL = 'parcel_panel',
    SEVENTEEN_TRACK = 'seventeen_track',
    SKY_PILOT_DOWNLOAD = 'sky_pilot_download',
    SENDOWL_DOWNLOAD = 'sendowl_download',
    DOWNLOADABLE_DIGITAL_ASSETS = 'downloadable_digital_assets',
    WISHLIST_WISHIFY = 'wishlist_wishify',
    WISHLIST_HERO = 'wishlist_hero',
    WISHLIST_KING = 'wishlist_king',
    WISHLIST_PLUS = 'wishlist_plus',
    LOYALTY_JUDGEME = 'loyalty_judgeme'
  ]

  ALL = {
    Integration::CUSTOMER_PAGE_TYPE => CUSTOMER_PAGE_INTEGRATIONS = {
      SMILE_IO => {
        name: 'Smile: Rewards & Loyalty',
        listing_slug: 'smile-io',
        is_nav_item: true,
        settings: {
          'push_date_of_birth' => true,
          'disable_smile_reload' => true
        }
      },
      YOTPO_REWARDS => {
        name: 'Yotpo Loyalty & Rewards',
        listing_slug: 'swell',
        is_nav_item: true,
        settings: {
          'push_date_of_birth' => true,
          'widget_code' => nil,
          'path' => YOTPO_REWARDS
        }
      },
      RIVO_REWARDS => {
        name: 'Rivo Loyalty & Referrals',
        listing_slug: 'loyalty-hero',
        is_nav_item: true,
        settings: {
          'embedded' => false,
          'push_date_of_birth' => true,
          'path' => RIVO_REWARDS
        }
      },
      BON_RWARDS => {
        name: 'BON Loyalty Rewards & Referral',
        listing_slug: 'bon-loyalty-rewards',
        is_nav_item: true,
        settings: {
          'push_date_of_birth' => true
        }
      },
      RISE_AI => {
        name: 'Gift Cards & Loyalty Program by Rise.ai',
        listing_slug: 'gift-card-loyalty-program',
        is_nav_item: true,
        settings: {
          'open_account_module' => true
        }
      },
      APPSTLE_MEMBERSHIPS => {
        name: 'Appstle℠ Memberships',
        listing_slug: 'appstle-memberships',
        is_nav_item: true
      },
      APPSTLE_SUBSCRIPTIONS => {
        name: 'Appstle℠ Subscriptions',
        listing_slug: 'subscriptions-by-appstle',
        is_nav_item: true
      },
      RECHARGE_SUBSCRIPTIONS => {
        name: 'Recharge Subscriptions',
        listing_slug: 'subscription-payments',
        is_nav_item: true
      },
      PAY_WHIRL_SUBSCRIPTIONS => {
        name: 'PayWhirl Subscription Payments',
        listing_slug: 'paywhirl',
        is_nav_item: true,
        settings: {
          'path' => PAY_WHIRL_SUBSCRIPTIONS
        }
      },
      YOTPO_SUBSCRIPTIONS => {
        name: 'Subscriptions by Yotpo',
        listing_slug: 'yotpo-subscription',
        is_nav_item: true,
        settings: {
          'widget_code' => nil,
          'path' => YOTPO_SUBSCRIPTIONS
        }
      },
      SEAL_SUBSCRIPTIONS => {
        name: 'Seal Subscriptions℠ & Loyalty',
        listing_slug: 'seal-subscriptions',
        is_nav_item: true
      },
      LOOP_SUBSCRIPTIONS => {
        name: 'Loop Subscriptions',
        listing_slug: 'loop-subscriptions',
        is_nav_item: true
      },
      VIFY_ORDER_PRINTER => {
        name: 'Order Printer: PDF Invoice Pro by Vify',
        listing_slug: 'pdf-invoice-customizer-1',
        is_nav_item: false
      },
      ORDER_PRINTER_PRO => {
        name: 'Order Printer Pro: Invoice App',
        listing_slug: 'order-printer-pro',
        settings: {
          'invoice' => {
            'link' => nil,
            'slug' => nil,
            'multiplier' => nil
          },
          'refund' => {
            'link' => nil,
            'slug' => nil,
            'multiplier' => nil
          }
        }
      },
      WIZARD_INVOICE => {
        name: 'Wizard Labs: Invoice Wizard',
        listing_slug: 'invoice-wizard',
        settings: {
          'invoice' => {
            'link' => nil,
            'public_key' => nil
          },
          'return_form' => {
            'link' => nil,
            'public_key' => nil
          }
        }
      },
      SUFIO_INVOICE => {
        name: 'Sufio: Professional Invoices',
        listing_slug: 'sufio',
        settings: {},
        is_nav_item: false
      },
      ORDERIFY => {
        name: 'Orderify',
        listing_slug: 'orderify',
        is_nav_item: false,
        settings: {
          'add_edit_button' => true,
          'add_reorder_button' => false
        }
      },
      AFTERSHIP_RETURNS => {
        name: 'AfterShip Returns Center',
        listing_slug: 'returns-center-by-aftership',
        is_nav_item: true,
        settings: {
          'external_url' => nil,
          'embedded' => false,
          'embedded_url' => '/apps/aftership-returns-center'
        }
      },
      RETURN_PRIME => {
        name: 'Return Prime: Order Return',
        listing_slug: 'return-prime',
        settings: {}
      },
      PARCEL_PANEL => {
        name: 'Parcel Panel Order Tracking',
        listing_slug: 'parcelpanel',
        is_nav_item: true,
        settings: {
          'path' => PARCEL_PANEL
        }
      },
      SEVENTEEN_TRACK => {
        name: '17TRACK Order Tracking & Email',
        listing_slug: '17track',
        settings: {
          'open_same_tab' => false,
          'path' => '/apps/17track'
        }
      },
      SKY_PILOT_DOWNLOAD => {
        name: 'Sky Pilot ‑ Digital Downloads',
        listing_slug: 'sky-pilot',
        is_nav_item: false
      },
      SENDOWL_DOWNLOAD => {
        name: 'SendOwl',
        listing_slug: 'sendowl',
        is_nav_item: false,
        settings: {
          'sendowl_store_id' => nil,
          'all_products_are_digital' => false
        }
      },
      DOWNLOADABLE_DIGITAL_ASSETS => {
        name: 'DDA ‑ Digital Downloads',
        listing_slug: 'digital-assets',
        is_nav_item: false,
        settings: {}
      },
      WISHLIST_WISHIFY => {
        name: 'Wishlist ‑ Wishify',
        listing_slug: 'wishlist-wishify',
        is_nav_item: true,
        settings: {
          'path' => WISHLIST_WISHIFY
        }
      },
      WISHLIST_HERO => {
        name: 'Wishlist Hero',
        listing_slug: 'wishlist-hero',
        is_nav_item: true,
        settings: {}
      },
      WISHLIST_KING => {
        name: 'Wishlist King',
        listing_slug: 'wishlist-king',
        is_nav_item: true,
        settings: {
          'url' => '/pages/wishlist'
        }
      },
      WISHLIST_PLUS => {
        name: 'Wishlist Plus',
        listing_slug: 'swym-relay',
        is_nav_item: true,
        settings: {}
      }
    },
    Integration::WISHLIST_TYPE => WISHLSIT_INTEGRATIONS = {
      KLAVIYO => {
        name: 'Klaviyo',
        listing_slug: 'klaviyo',
        enabled: false,
        backend_only: true,
        settings: {
          'public_api_key' => nil,
          'events' => {
            BroadcastEventConstants::WISHLIST_ADDED => true,
            BroadcastEventConstants::WISHLIST_REMOVED => true,
            BroadcastEventConstants::WISHLIST_ADDED_TO_CART => true,
            BroadcastEventConstants::WISHLIST_BOUGHT => true
          }
        }
      },
      FACEBOOK_PIXEL => {
        name: 'Facebook Pixel',
        listing_slug: '',
        logo: 'facebook.svg',
        enabled: false,
        settings: {}
      },
      GOOGLE_ANALYTICS => {
        name: 'Google Analytics',
        listing_slug: '',
        logo: 'google.svg',
        enabled: false,
        settings: {}
      }
    },

    Integration::LOYALTY_TYPE => LOYALTY_INTEGRATIONS = {
      LOYALTY_JUDGEME => {
        name: 'Judge.me Product Reviews',
        listing_slug: 'judgeme',
        logo: 'judgeme.png',
        enabled: false,
        backend_only: true,
        settings: {},
        dont_save_settings: true
      }
    }
  }.freeze
end
