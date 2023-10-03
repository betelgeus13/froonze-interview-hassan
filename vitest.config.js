import { defineConfig } from "vitest/config";
import { createVuePlugin } from "vite-plugin-vue2"
const path = require('path')

export default defineConfig({
  plugins: [createVuePlugin()],
  resolve: {
    // below are convenient shortcuts that we can use in javascript and css files in order to avoid relative paths
    // in js files we can use them like this: import something from 'Javascript/some/path/to/file.js'
    // in css files we need also to add "~" to the shortcut name: @import '~ShopifyEmbeddedStyles/_mixins';
    alias: {
      MerchantDashboard: path.resolve(__dirname, './app/javascript/apps/merchant_dashboard'),
      MerchantDashboardCssVariables: path.resolve(__dirname, './app/javascript/apps/merchant_dashboard/styles/variables.scss'),
      CustomerPage: path.resolve(__dirname, './app/javascript/apps/customer_page'),
      ProductWishlist: path.resolve(__dirname, './app/javascript/apps/product_wishlist'),
      SharedWishlist: path.resolve(__dirname, './app/javascript/apps/shared_wishlist'),
      SocialLogins: path.resolve(__dirname, './app/javascript/apps/social_logins'),
      Admin: path.resolve(__dirname, './app/javascript/apps/admin'),
      RailsStyleMixins: path.resolve(__dirname, './app/assets/stylesheets/_mixins.scss'),
      JS: path.resolve(__dirname, './app/javascript'),
      Translations: path.resolve(__dirname, './lib/translations'),
      CustomForms: path.resolve(__dirname, './app/javascript/apps/custom_forms'),
    }
  },
  test: {
    globals: true,
    environment: "jsdom",
    setupFiles: [
      "./mock_fetch.js"
    ]
  },
  root: "spec/javascript", //Define the root
});
