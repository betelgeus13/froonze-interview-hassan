module Rack
  module Auth
    class AuthenticatedAdmin

      def initialize(app)
        @app = app
      end

      def call(env)
        rack_req = Rack::Request.new(env)
        team_member_id = rack_req.session['team_member_id']
        return unauthorized unless team_member_id
        return unauthorized unless TeamMember.admin.where(id: team_member_id).exists?
        @app.call(env)
      end

      private

      def unauthorized
        return [ 401,
          { CONTENT_TYPE => 'text/plain',
            CONTENT_LENGTH => '0',
          },
          []
        ]
      end

    end
  end
end
