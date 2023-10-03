# frozen_string_literal: true

module Forms
  class MetafieldUpdaterService
    FIELD_COMMON_PARAMS = %w[
      id
      required
      label
      default
      placeholder
      description
      width
      settings
    ].freeze

    GLOBAL_SETTINGS = [
      :customer_page_phone_default_country
    ]

    VALIDATION_PARAMS = %w[id operator value meta error_message].freeze

    def initialize(shop)
      @shop = shop
      @forms = shop.forms.active.preload(form_fields: %i[custom_field form_field_validations])
      @setting = Setting.select(GLOBAL_SETTINGS).find_by(shop_id: shop.id)
    end

    def call
      Shopify::SetShopAppInstallationIdService.new.call(shop: @shop) if @shop.app_installation_id.blank?
      Shopify::Metafields::FormsUpdaterService.call(shop: @shop, forms_settings:)
    end

    private

    def forms_settings
      forms = {
        profile: (serialize_form(profile_form) if profile_form.present?),
        registration: (serialize_form(registration_form) if registration_form.present?),
        page: page_forms.map { |form| serialize_form(form) }
      }.compact

      { forms:, global_settings: }
    end

    def profile_form
      @profile_form ||= @forms.find { |form| form.profile_location? }
    end

    def registration_form
      @registration_form ||= @forms.find { |form| form.registration_location? }
    end

    def page_forms
      page_forms ||= @forms.select { |form| form.page_location? }
    end

    def serialize_form(form)
      {
        slug: form.slug,
        location: form.location,
        type: form.form_type,
        label_style: form.label_style,
        registration_action: form.registration_action,
        steps: form.form_steps.sort_by(&:order).map { |step| serialize_step(step) },
        settings: serialize_settings(form)
      }
    end

    def serialize_settings(form)
      FormConstants::DEFAULT_SETTINGS.keys.each_with_object({}) do |field, obj|
        obj[field] = form.send field
      end
    end

    def global_settings
      GLOBAL_SETTINGS.each_with_object({}) do |field, obj|
        obj[field] = @setting.send field
      end
    end

    def serialize_step(step)
      {
        id: step.id,
        name: step.name,
        fields: step.form_fields.sort_by(&:order).map { |field| serialize_field(field) }
      }
    end

    def serialize_field(field)
      params = field.attributes.slice(*FIELD_COMMON_PARAMS)
      params['key'] = field.key
      params['type'] = field.field_type
      if field.custom_field?
        params['data_type'] = field.custom_field.data_type
        params['settings'] = Hash(field.settings)
      end
      params['validations'] = serialize_validations(field.form_field_validations)
      params
    end

    def serialize_validations(validations)
      validations.map do |validation|
        attrs = validation.attributes.slice(*VALIDATION_PARAMS)
        attrs['operator_type'] = validation.operator_type
        attrs
      end
    end
  end
end
