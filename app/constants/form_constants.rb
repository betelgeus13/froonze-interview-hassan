module FormConstants
  ALLOWED_ACTIVE_FORMS_COUNT = {
    ShopifySubscription::CUSTOM_FORMS_BASIC_PLAN => 2,
    ShopifySubscription::CUSTOM_FORMS_ADVANCED_PLAN => 2,
    ShopifySubscription::CUSTOM_FORMS_PREMIUM_PLAN => 999 # unlimited
  }

  # TODO: we should add these to the MD constants and automatically append them to forms
  DEFAULT_SETTINGS = {
    show_required: true,
    primary_color: '#5873f9',
    primary_text_color: '#ffffff',
    form_background_color: '#ffffff',
    form_text_color: '#202202',
    max_width: 500,
    show_form_border: true,
    show_form_box_shadow: true,
    form_border_radius: 2,
    input_border_radius: 2
  }
end
