<template>
  <div>
    <div class="level header">
      <div class="level-left">
        <shop-finder @select="handleShopSelect" />
      </div>
      <div class="level-right" v-if="shop">
        <div class="level-item">
          <a :href="`https://${shop.shopifyDomain}`" target="_blank" class="shop-link">
            {{ shop.shopifyDomain }}
          </a>
        </div>
      </div>
    </div>
    <div v-if="shop" class="main-view container">
      <tags :shop="shop" />
      <actions :shop="shop" skip='shop_info'/>
      <shop-attributes :shop="shop" />
      <div class="box-row">
        <active-subscription :active-subscription="shop.activeShopifySubscription" class="active-subscription" />
        <theme-installation-links :shop="shop" class="installation-links" />
      </div>
    </div>
    <b-loading v-model="$apollo.loading" :is-full-page="false" />
  </div>
</template>

<script>
  import gql from 'graphql-tag'
  import ShopFinder from 'Admin/components/shop_finder.vue'
  import Tags from './tags.vue'
  import Actions from 'Admin/components/shared/actions.vue'
  import ShopAttributes from './shop_attributes.vue'
  import ActiveSubscription from './active_subscription.vue'
  import ThemeInstallationLinks from './theme_installation_links.vue'

  export default {
    components: {
      ShopFinder,
      Tags,
      Actions,
      ShopAttributes,
      ActiveSubscription,
      ThemeInstallationLinks,
    },

    methods: {
      handleShopSelect(shop) {
        this.$router.push(`/shop_info?shop_id=${shop.id}`)
      },
    },

    apollo: {
      shop: {
        query: gql`
          query shop($id: ID!) {
            shop(id: $id) {
              id
              shopifyDomain
              customDomain
              email
              phone
              owner
              shopifyPlan
              customersCount
              primaryLocale
              countryCode
              currency
              passwordEnabled
              installed
              createdAt
              betaTester
              shopifyCustomerAccountSetting
              lastVisitedAt
              isDevelopmentShop
              storefrontPassword
              activeShopifySubscription {
                activatedAt
                createdAt
                amount
                isTest
                plugins {
                  reorderBtn
                  customPages
                  recentlyViewed
                  socialLogins
                  wishlist
                  cpIntegrations
                  customForms
                  loyalty
                  orderActions
                }
              }
              shopifyThemes {
                id
                externalId
                name
                live
              }
            }
          }
        `,
        variables() {
          return {
            id: parseInt(this.$route.query.shop_id),
          }
        },
      },
    },
  }
</script>

<style lang="scss" scoped>
  .main-view { padding: 15px 40px; }

  .shop-link { color: black; }

  .box-row {
    margin-top: 15px;
    display: flex;
    justify-content: space-between;
  }

  .active-subscription, .installation-links {
    width: calc(50% - 10px);
  }
</style>
