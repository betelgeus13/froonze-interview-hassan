const { environment } = require('@rails/webpacker')
const { VueLoaderPlugin } = require('vue-loader')
const vue = require('./loaders/vue')
const rawLoaderSvg = require('./loaders/raw-loader-svg')
const yamlLoader = require('./loaders/yaml-loader')
const path = require('path')

const aliasConfig = {
  resolve: {
    // below are convenient shortcuts that we can use in javascript and css files in order to avoid relative paths
    // in js files we can use them like this: import something from 'Javascript/some/path/to/file.js'
    // in css files we need also to add "~" to the shortcut name: @import '~ShopifyEmbeddedStyles/_mixins';
    alias: {
      MerchantDashboard: path.resolve(__dirname, '../../app/javascript/apps/merchant_dashboard'),
      MerchantDashboardCssVariables: path.resolve(__dirname, '../../app/javascript/apps/merchant_dashboard/styles/variables.scss'),
      CustomerPage: path.resolve(__dirname, '../../app/javascript/apps/customer_page'),
      ProductWishlist: path.resolve(__dirname, '../../app/javascript/apps/product_wishlist'),
      SharedWishlist: path.resolve(__dirname, '../../app/javascript/apps/shared_wishlist'),
      SocialLogins: path.resolve(__dirname, '../../app/javascript/apps/social_logins'),
      Admin: path.resolve(__dirname, '../../app/javascript/apps/admin'),
      RailsStyleMixins: path.resolve(__dirname, '../../app/assets/stylesheets/_mixins.scss'),
      JS: path.resolve(__dirname, '../../app/javascript'),
      Translations: path.resolve(__dirname, '../../lib/translations'),
      CustomForms: path.resolve(__dirname, '../../app/javascript/apps/custom_forms'),
    }
  },
  output: {
    jsonpFunction: 'frcpJsonPArray',
  },
}

environment.config.merge(aliasConfig)
environment.plugins.prepend('VueLoaderPlugin', new VueLoaderPlugin())
environment.loaders.prepend('vue', vue)
environment.loaders.prepend('raw-loader-svg', rawLoaderSvg)
environment.loaders.prepend('yaml-loader', yamlLoader)

module.exports = environment
