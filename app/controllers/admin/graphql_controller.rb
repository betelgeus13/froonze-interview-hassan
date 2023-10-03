module Admin
  class GraphqlController < Admin::BaseController
    include GraphqlConcern

    before_action :check_admin_access

    def execute
      variables = prepare_variables(params[:variables])
      context = {
        admin: admin,
        request: request
      }
      result = AdminSchema.execute(params[:query],
          variables: variables,
          context: context,
          operation_name: params[:operationName])
      render json: result
    rescue StandardError => e
      raise e unless Rails.env.development?
      handle_error_in_development(e)
    end

  end
end
