module Forms
  class AfterPlanChangeCallbackService

    def initialize(shop)
      @shop = shop
    end

    def call
      if @shop.custom_forms_active?
        check_active_forms_count
      else
        @shop.forms.active.each(&:deactivate!)
      end
      Forms::MetafieldUpdaterJob.perform_async(@shop.id)
    end

    private

    def check_active_forms_count
      plan = @shop.plugins['custom_forms']
      return if plan.blank? # shouldn't happen, but just in case
      active_forms = @shop.forms.active
      allowed_active_forms = FormConstants::ALLOWED_ACTIVE_FORMS_COUNT[plan]
      if active_forms.length > allowed_active_forms
        to_deactivate_count = active_forms.length - allowed_active_forms
        active_forms.last(to_deactivate_count).each(&:deactivate!)
      end
    end

  end
end
