import Vue from 'vue'

const GlobalMethodsPlugin = {
  install(Vue, options) {
    Vue.mixin({
      methods: {
        showDefaultError(error) {
          this.$buefy.toast.open({
            message: 'Something went wrong. Please reload the page and try again or contact support.',
            type: 'is-danger'
          })
          console.log(error)
        },

        showError(error) {
          this.$buefy.toast.open({
            message: error,
            type: 'is-danger'
          })
          console.log(error)
        },

        showSuccess(message) {
          this.$buefy.toast.open({ message: message, type: 'is-success' })
        },
      },

    })
  }
}

Vue.use(GlobalMethodsPlugin)
