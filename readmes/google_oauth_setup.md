1. Go to https://console.cloud.google.com/apis/credentials

2. Click on the "Select a project" dropdown. In the popup click "New project" and create a new project.

3. Configure consent screen
  - In "Scopes" step add `.../auth/userinfo.email` scope

4. In "Credentials" tab click "Create Credentials" -> OAuth client ID
  - Setup redirect_uri url to: https://your-ngrok.io/admin/auth/google/callback

5. Add OAuth id and secret as `admin_google_oauth` in Rails credentials
