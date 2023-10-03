<template>
  <div class="theme-editor">
    <div class="level header">
      <div class="level-left">
        <shop-finder @select="handleShopSelect" />
      </div>
      <div class="level-right" v-if="shop">
        <actions :shop="shop" skip='theme_editor'  v-if='shop'/>
        <div class="level-item">
          <a :href="`https://${shop.shopifyDomain}`" target="_blank" class="shop-link">
            {{ shop.shopifyDomain }}
          </a>
        </div>
      </div>
    </div>
    <div class="sidebar-and-editor">
      <div class="sidebar">
        <theme-selector class="theme-selector" />
        <asset-selector class="asset-selector" />
      </div>
      <editing-window class="editing-window" />
    </div>
  </div>
</template>

<script>
  import ShopFinder from 'Admin/components/shop_finder.vue'
  import ThemeSelector from './theme_selector.vue'
  import AssetSelector from './asset_selector.vue'
  import EditingWindow from './editing_window.vue'
  import gql from 'graphql-tag'
  import Actions from 'Admin/components/shared/actions.vue'

  export default {
    components: {
      ShopFinder,
      ThemeSelector,
      AssetSelector,
      EditingWindow,
      Actions,
    },

    apollo: {
      shop: {
        query: gql`
          query shop($id: ID!) {
            shop(id: $id) {
              id
              shopifyDomain
              installed
              shopifyThemes {
                id
                name
                live
              }
            }
          }
        `,
        variables() {
          return { id: this.$route.params.shopId }
        }
      }
    },

    methods: {
      handleShopSelect(shop) {
        if (shop.id == this.$route.params.shopId) return
        const liveTheme = shop.shopifyThemes.find(theme => theme.live)
        this.$store.commit('themeEditor/resetState')
        this.$router.push(`/shop/${shop.id}/theme_editor/theme/${liveTheme.id}`)
      },
    },

    beforeMount() {
      this.$store.commit('themeEditor/resetState')
    }
  }
</script>

<style lang="scss" scoped>
  $sidebarWidth: 240px;

  .sidebar-and-editor {
    display: flex;
    height: calc(100vh - 54px);
  }

  .sidebar {
    height: 100%;
    width: $sidebarWidth;
  }

  .asset-selector {
    height: calc(100% - 74px);
  }

  .editing-window {
    width: calc(100% - #{$sidebarWidth});
    padding: 20px;
  }

  .level-right .shop-links {
    display: flex;
    gap: 20px;
    margin: 0 20px 0 0 ;
    border-bottom: none;
    padding-bottom: 0;
  }
</style>
