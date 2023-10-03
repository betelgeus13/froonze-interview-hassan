<template>
  <div v-if="isAnyTags" class="shop-tags has-text-centered">
    <b-tag v-if="shop.activeShopifySubscription" type="is-success">Has Subscription</b-tag>
    <b-tag v-if="!shop.installed" type="is-dark">Unistalled</b-tag>
    <b-tag v-if="shop.betaTester" type="is-info">Beta Tester</b-tag>
    <b-tag v-if="accountsNotActivated" type="is-danger">Accounts Not Activated</b-tag>
    <b-tag v-if="shop.isDevelopmentShop" type="is-warning">Dev Plan</b-tag>
  </div>
</template>

<script>
  export default {
    props: {
      shop: Object,
    },

    computed: {
      isAnyTags() {
        return this.shop.activeShopifySubscription ||
          !this.shop.installed ||
          this.shop.betaTester ||
          this.accountsNotActivated ||
          this.shop.isDevelopmentShop
      },

      accountsNotActivated() {
        return !['required', 'optional'].includes(this.shop.shopifyCustomerAccountSetting)
      },
    }
  }
</script>

<style lang="scss" scoped>
  .shop-tags {
    margin-bottom: 12px;
    border-bottom: 1px solid lightgrey;
    padding-bottom: 12px;
  }
</style>
