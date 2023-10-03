<template>
  <div v-if="!$apollo.loading">
    <div class="level header">
      <div class="level-left">
        <div class="level-item">
          <theme-selector :shopify-themes="shop.shopifyThemes" @themeSelect="handleThemeSelect"  />
        </div>
      </div>
      <div class="level-right">
        <actions :shop="shop" v-if='shop' skip='theme_customizations' />
        <div class="level-item">
          <a :href="`https://${shop.shopifyDomain}`" target="_blank" class="shop-link">
            {{ shop.shopifyDomain }}
          </a>
        </div>
      </div>
    </div>

    <div class="body container">
      <editor v-if="selectedTheme" :theme="selectedTheme" />
    </div>
  </div>
</template>

<script>
  import gql from 'graphql-tag'
  import ThemeSelector from './theme_selector'
  import Editor from './editor'
  import Actions from 'Admin/components/shared/actions.vue'

  export default {
    components: { ThemeSelector, Editor, Actions },

    data() {
      return {
        selectedTheme: null
      }
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
                global
                shopifyThemeCustomizations {
                  customizationType
                  html
                  css
                  js
                }
              }
            }
          },
        `,
        variables() {
          return {
            id: parseInt(this.$route.query.shop_id)
          }
        },
        result(result) {
          // push empty customization objects for each customizationType if they don't exist yet
          result.data.shop.shopifyThemes.forEach((theme) => {
            this.$constants.theme_customization_types.forEach((customizationType) => {
              const existingCustomization = theme.shopifyThemeCustomizations.find((customization) => {
                return customization.customizationType == customizationType
              })
              if (!existingCustomization) {
                theme.shopifyThemeCustomizations.push({ customizationType: customizationType })
              }
            })
          })
        }
      }
    },

    methods: {
      handleThemeSelect(theme) {
        this.selectedTheme = theme
      }
    },
  }
</script>

<style lang="scss" scoped>
  .shop-link { color: black; }

  .level-right .shop-links {
    display: flex;
    gap: 20px;
    margin: 0 20px 0 0 ;
    border-bottom: none;
    padding-bottom: 0;
  }
</style>
