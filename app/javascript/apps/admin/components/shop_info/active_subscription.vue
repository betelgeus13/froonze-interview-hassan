<template>
  <div class="card subscription-card">
    <header class="card-header">
      <p class="card-header-title">
        Active subscription
      </p>
    </header>
    <div class="card-content">
      <div v-if="activeSubscription">
        <b-table :data="activeSubscriptionAttributes">
          <b-table-column field="name" label="Attribute" v-slot="props">
            <div class="attribute-name">
              {{ props.row.name }}
            </div>
          </b-table-column>
          <b-table-column field="value" label="Value" v-slot="props">
            <div class="attribute-value">
              {{ props.row.value }}
            </div>
          </b-table-column>
        </b-table>
      </div>
      <div v-else class="has-text-centered">
        No active subscription
      </div>
    </div>
  </div>
</template>

<script>
  export default {
    props: {
      activeSubscription: Object,
    },

    computed: {
      activeSubscriptionAttributes() {
        let attributes = _.omit(this.activeSubscription, '__typename')
        attributes.plugins = _.omit(attributes.plugins, '__typename')
        return _.map(attributes, (value, key) => {
          return { name: _.startCase(key), value: value }
        })
      }
    },
  }
</script>
