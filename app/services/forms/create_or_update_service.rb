# frozen_string_literal: true

module Forms
  class CreateOrUpdateService
    class UpdateError < StandardError; end

    PARAMS_TO_UPDATE = (%i[form_type name label_style registration_action redirect_path] + FormConstants::DEFAULT_SETTINGS.keys).freeze

    def initialize(shop, params)
      @params = params
      @shop = shop
      @steps = params[:steps]
      @form = @shop.forms.preload(form_fields: %i[custom_field form_field_validations]).find_or_initialize_by(slug: params[:slug])
    end

    def call
      return { error: 'Profile form can only have one step' } unless profile_form_steps_count_is_valid?

      ret = check_plan
      return ret if ret[:error]

      ActiveRecord::Base.transaction do
        create_or_update_form
      end
      { slug: @form.slug }
    rescue StandardError => e
      Utils::RollbarService.error(UpdateError.new(e), shop_id: @shop.id)
      { error: 'Something went wrong. Please reload the page and try again.' }
    end

    private

    def profile_form_steps_count_is_valid?
      return false if @form.profile_location? && @steps.count > 1

      true
    end

    def create_or_update_form
      @form.location = @params[:location] if @form.new_record?
      @form.assign_attributes(@params.slice(*PARAMS_TO_UPDATE))
      @form.save!
      delete_old_steps
      create_or_update_all_steps
    end

    def delete_old_steps
      old_step_ids = @form.form_steps.map(&:id)
      remaining_step_ids = @steps.map { |step| step[:id].to_i }.compact
      step_ids_to_leave = old_step_ids & remaining_step_ids
      @form.form_steps.where.not(id: step_ids_to_leave).destroy_all
    end

    def create_or_update_all_steps
      @form.form_steps.each_with_index do |step, index|
        step.update!(order: index + 10_000) # temporarily set order to a very high number so that there is no db conflict(order needs to be unique)
      end
      @steps.each_with_index do |step_params, index|
        create_or_update_step(step_params, index)
      end
    end

    def create_or_update_step(step_params, index)
      step_params = step_params.to_h
      step = if step_params[:id].present?
               @form.form_steps.find { |s| s.id == step_params[:id].to_i } || raise('Step not found')
             else
               @form.form_steps.new
             end
      step_params.delete(:id)
      step.update!(name: step_params[:name], order: index)
      delete_old_fields(step, step_params[:fields])
      create_or_update_all_fields(step, step_params[:fields])
    end

    def delete_old_fields(step, fields_list_params)
      old_field_ids = step.form_fields.map(&:id)
      remaining_field_ids = fields_list_params.map { |field_params| field_params[:id].to_i }.compact
      field_ids_to_leave = old_field_ids & remaining_field_ids
      step.form_fields.where.not(id: field_ids_to_leave).destroy_all
    end

    def create_or_update_all_fields(step, fields_list_params)
      step.form_fields.each_with_index do |field, index|
        field.update!(order: index + 10_000) # temporarily set order to a very high number so that there is no db conflict(order needs to be unique)
      end
      fields_list_params.each_with_index do |field_params, index|
        create_or_update_field(step, field_params, index)
      end
    end

    def create_or_update_field(step, field_params, index)
      field_params = field_params.to_h
      field_params[:order] = index
      field_params[:field_type] = field_params.delete(:type)
      field = if field_params[:id]
                step.form_fields.find { |f| f.id == field_params[:id].to_i } || raise('Field not found')
              else
                step.form_fields.new
              end
      field_params.delete(:id)
      if field_params[:key]
        custom_field = @shop.custom_fields.find { |cf| cf.key == field_params[:key] }
        raise "Custom field with key #{field_params[:key]} does not exist" if custom_field.blank?

        field_params[:custom_field_id] = custom_field.id
      end
      field_params.delete(:key)
      validations_list_params = field_params.delete(:validations)
      field.update!(field_params)
      delete_validations(field, validations_list_params)
      create_or_update_validations(field, validations_list_params)
    end

    def delete_validations(field, validations_list_params)
      old_validation_ids = field.form_field_validations.map(&:id)
      remaining_validation_ids = validations_list_params.map { |validation| validation[:id].to_i }.compact
      validation_ids_to_leave = old_validation_ids & remaining_validation_ids
      field.form_field_validations.where.not(id: validation_ids_to_leave).destroy_all
    end

    def create_or_update_validations(field, validations_list_params)
      validations_list_params.each do |validation_params|
        validation = if validation_params[:id]
                       field.form_field_validations.find { |v| v.id == validation_params[:id].to_i } || raise('Validation not found')
                     else
                       field.form_field_validations.new
                     end
        validation_params.delete(:id)
        validation.update!(validation_params)
      end
    end

    def check_plan
      if @params[:registration_action] == 'account_approval' && @shop.plugins['custom_forms'] == 'basic'
        return { error: 'Please upgrade to Custom forms to Advanced plan to use Account approval' }
      end

      {}
    end
  end
end
