# frozen_string_literal: true
# Be sure to restart your server when you modify this file.

Rails.application.config.session_store(:cookie_store, key: '_froonze_cp_session', expire_after: 30.days, secure: true)
