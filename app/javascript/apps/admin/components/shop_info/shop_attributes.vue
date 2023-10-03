<template>
  <div class="card">
    <header class="card-header">
      <p class="card-header-title">
        Shop attributes
      </p>
    </header>
    <div class="card-content">
      <b-table :data="shopAttributes" height="260" sticky-header>
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
  </div>
</template>

<script>
  const SHOP_ATTRIBUTES = [
    'shopifyDomain',
    'customDomain',
    'storefrontPassword',
    'email',
    'phone',
    'owner',
    'shopifyPlan',
    'customersCount',
    'primaryLocale',
    'countryCode',
    'currency',
    'passwordEnabled',
    'installed',
    'betaTester',
    'shopifyCustomerAccountSetting',
    'createdAt',
    'lastVisitedAt',
  ]

  export default {
    props: {
      shop: Object
    },

    computed: {
      shopAttributes() {
        const attributes = _.pick(this.shop, SHOP_ATTRIBUTES)
        return _.map(attributes, (value, key) => {
          return { name: _.startCase(key), value: value }
        })
      },
    },
  }
</script>
