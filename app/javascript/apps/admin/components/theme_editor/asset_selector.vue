<template>
  <div class="asset-selector">
    <b-loading v-if="$apollo.loading" active :is-full-page="false" />
    <div v-else>
      <b-input v-model="searchQuery" size="is-small" placeholder="Search..." class="search-bar" />
      <div class="assets-container">
        <b-collapse v-for="section in filteredSections"
            v-model="section.isOpen"
            :key="section.name"
            animation="slide"
            class="asset-section"
        >
            <template #trigger>
              <div role="button" :aria-expanded="section.isOpen" class="section-name">
                <b-icon v-if="section.isOpen" icon="chevron-down" />
                <b-icon v-else icon="chevron-right" />
                <strong>{{ _.capitalize(section.name) }}</strong>
              </div>
            </template>
            <div v-if="assets" v-for="asset in section.assets"
                @click="selectAsset(asset)"
                class="asset"
                :class="{ 'asset--selected': asset == selectedAsset }"
            >
              {{ assetName(asset.key) }}
            </div>
        </b-collapse>
      </div>
    </div>
  </div>
</template>

<script>
  import gql from 'graphql-tag'
  import { mapState } from 'vuex'
  import constants from './constants.js'

  export default {
    data() {
      return {
        sections: constants.sectionNames.map(sectionName => {
          return { name: sectionName, isOpen: true }
        }),
        searchQuery: '',
      }
    },

    apollo: {
      assets: {
        query: gql`
          query ($shopId: ID!, $themeId: ID!) {
            shop(id: $shopId) {
              id
              shopifyTheme(themeId: $themeId) {
                id
                assets {
                  key
                  contentType
                  value
                }
              }
            }
          }
        `,
        variables() {
          return {
            shopId: parseInt(this.$route.params.shopId),
            themeId: this.$route.params.themeId,
          }
        },
        update(data) {
          return data.shop.shopifyTheme.assets
        },
      }
    },

    computed: {
      ...mapState({
        selectedAsset: state => state.themeEditor.selectedAsset,
      }),
      filteredAssets() {
        if (!this.searchQuery) return this.assets
        return this.assets.filter(asset => asset.key.toLowerCase().includes(this.searchQuery.toLowerCase()))
      },
      filteredSections() {
        const filteredSections = []
        this.sections.forEach(section => {
          const sectionAssets = this.filteredAssets.filter(asset => _.startsWith(asset.key, section.name + '/'))
          section.assets = sectionAssets
          if (sectionAssets.length > 0) filteredSections.push(section)
        })
        return filteredSections
      }
    },

    methods: {
      assetName(key) {
        const sectionName = constants.sectionNames.find(sectionName => _.startsWith(key, sectionName))
        if (sectionName) {
          return key.split(`${sectionName}/`)[1]
        } else {
          return key
        }
      },
      selectAsset(asset) {
        this.$store.dispatch('themeEditor/addAssetTab', asset)
      },
    }
  }
</script>

<style lang="scss" scoped>
  @import '~JS/shared/styles/mixins';

  .asset-selector {
    position: relative;
    padding: 8px;
  }

  .assets-container {
    height: calc(100% - 60px);
    overflow-x: auto;
  }

  .search-bar {
    margin-bottom: 20px;
  }

  .asset-section {
    margin-bottom: 12px;
    &:last-child { margin-bottom: 0; }
  }

  .section-name {
    display: flex;
    align-items: center;
  }

  .asset {
    @include text-elipsis;
    margin-top: 8px;
    padding: 0 4px;
    border-radius: 2px;
    cursor: pointer;

    &--selected { background-color: gainsboro; }
  }
</style>
