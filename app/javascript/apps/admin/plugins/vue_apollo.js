import Vue from 'vue'
import VueApollo from 'vue-apollo'
import ApolloClient from 'apollo-boost'

Vue.use(VueApollo)

const apolloClient = new ApolloClient({
  uri: window.globalConstants.https_url + '/admin/graphql',
  fetchOptions: {
    credentials: 'same-origin',
  },
  request: (operation) => {
    const csrfToken = document.querySelector('meta[name=csrf-token]').getAttribute('content')
    operation.setContext({
      headers: { "X-CSRF-Token": csrfToken }
    })
  },
})

export default new VueApollo({
  defaultClient: apolloClient,
})
