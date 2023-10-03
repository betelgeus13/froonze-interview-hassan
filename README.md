# Interview task

## Create a requests/actions log dashboard for the admin.
* For each request(action) made in the app admin log it and then create a dashboard to show it inside the admin. 
* The dashboard should have filters by team members. 
* There is no need to log the oAuth callback. 

# Project setup 

* Ruby version
We use ruby 3.1.2. The version can be upgraded to something else you use by changing the value in gemfile and .ruby-version files.

To install ruby via rvm use `rvm install ruby-3.1.2`
* System dependencies
Install required gems `bundle install`
Install node packages `yarn install`

* Database creation
Run 
`rails db:setup`
`rake db:seed`

* Credentials
EDITOR=vim rails credentials:edit --environment development
Add credentials for admin_google_oauth. 
Read https://froonze.tawk.help/article/google-api-key-pair on how to create an app in Google. 
the redirect path is `/admin/auth/google/callback`

* Create team member 
run `rails c` and create a team member with the email used to login in admin 
