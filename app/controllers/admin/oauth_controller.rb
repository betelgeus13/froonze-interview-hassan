module Admin
  class OauthController < ActionController::Base
    def google_oauth_callback
      email = request.env['omniauth.auth'].dig('info', 'email')
      if email.blank?
        flash[:error] = 'Could not get OAuth information'
        return redirect_to admin_login_url
      end

      team_member = TeamMember.admin.find_by(email: email)
      if team_member.blank?
        flash[:error] = 'Could not find admin'
        return redirect_to admin_login_url
      end

      session[:team_member_id] = team_member.id
      return redirect_to admin_url
    end
  end
end
