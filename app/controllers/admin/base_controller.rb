module Admin
  class BaseController < ActionController::Base

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

  end
end
