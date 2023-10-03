# frozen_string_literal: true
module Forms
  class TogglerService

    class ToggleError < StandardError; end

    def initialize(shop:, slug:, active:)
      @shop = shop
      @slug = slug
      @active = active
    end

    def call
      return { error: 'Custom forms plugin is not activated' } unless @shop.custom_forms_active?
      form = @shop.forms.find_by(slug: @slug)
      return { error: 'Form not found' } if form.blank?

      if @active
        plan = @shop.plugins['custom_forms']
        allowed_active_forms_count = FormConstants::ALLOWED_ACTIVE_FORMS_COUNT[plan]
        if @shop.forms.active.count >= allowed_active_forms_count
          return { error: "Only up to #{allowed_active_forms_count} active forms are allowed on the #{plan.capitalize} plan" }
        end
      end

      if @active && (form.registration_location? || form.profile_location?)
        if @shop.forms.active.where(location: form.location).exists?
          return { error: "Only one #{form.location} form can be active at a time" }
        end
      end

      form.update!(active: @active)
      {}
    rescue => e
      Utils::RollbarService.error(ToggleError.new(e), shop_id: @shop_id, form_slug: @slug)
    end

  end
end
