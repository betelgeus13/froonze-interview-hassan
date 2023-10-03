import Vue from 'vue'
import App from 'Admin/app.vue'
import router from 'Admin/plugins/router.js'
import store from 'Admin/store/main.js'
import apolloProvider from 'Admin/plugins/vue_apollo.js'
import 'Admin/plugins/buefy.js'
import 'Admin/plugins/global_methods.js'
import _ from 'lodash'

// Global variables
Vue.prototype.$constants = window.globalConstants
Vue.prototype._ = _

document.addEventListener('DOMContentLoaded', () => {
  const app = new Vue({
    router,
    store,
    apolloProvider,
    render: h => h(App)
  }).$mount()
  document.body.appendChild(app.$el)
})
