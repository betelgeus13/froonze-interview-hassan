module Admin
  class BaseController < ActionController::Base
    after_action :track_action

    private

    def check_admin_access
      return head :unauthorized if admin.blank?
    end

    def admin
      @admin ||= begin
        return if session[:team_member_id].blank?
        TeamMember.admin.find_by(id: session[:team_member_id])
      end
    end

    def track_action
      ahoy.track "Ran action", {
        controller: params[:controller],
        action: params[:action],
      }
    end
  end
end
