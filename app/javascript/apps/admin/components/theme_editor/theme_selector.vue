<template>
  <div class="theme-selector">
    <b-loading v-if="$apollo.loading" active :is-full-page="false" />
    <b-select v-else v-model="selectedTheme" size="is-small" expanded>
      <option v-for="theme in themes"
          :value="theme"
      >
      {{ theme.name }}
      <span v-if="theme.live">
        {{ '(Live)' }}
      </span>
    </option>
    </b-select>
  </div>
</template>

<script>
  import gql from 'graphql-tag'

  export default {
    apollo: {
      shopifyThemes: {
        query: gql`
          query ($shopId: ID!) {
            shop(id: $shopId) {
              id
              shopifyThemes {
                id
                name
                live
                global
              }
            }
          }
        `,
        variables() {
          return {
            shopId: parseInt(this.$route.params.shopId),
          }
        },
        update(data) {
          return data.shop.shopifyThemes
        },
        result({ data }) {
          const themes = data.shop.shopifyThemes
          const routeThemeId = this.$route.params.themeId
          let selectedTheme
          if (routeThemeId == 'live') {
            selectedTheme = themes.find(theme => theme.live)
          } else {
            selectedTheme = themes.find(theme => theme.id == routeThemeId)
          }
          this.$store.commit('themeEditor/setSelectedTheme', selectedTheme)
        },
      }
    },

    computed: {
      selectedTheme: {
        get() { return this.$store.state.themeEditor.selectedTheme },
        set(theme) {
          this.$store.dispatch('themeEditor/changeTheme', theme)
          this.changeRoute()
        }
      },

      themes() {
        return this.shopifyThemes ? this.shopifyThemes.filter(theme => !theme.global) : []
      }
    },

    methods: {
      changeRoute() {
        this.$router.push(`/shop/${this.$route.params.shopId}/theme_editor/theme/${this.selectedTheme.id}`)
      }
    }
  }
</script>

<style lang="scss" scoped>
  .theme-selector {
    position: relative;
    border-bottom: 1px solid lightgrey;
    padding: 20px 8px;
    background-color: white;
    min-height: 70px;
  }
</style>
