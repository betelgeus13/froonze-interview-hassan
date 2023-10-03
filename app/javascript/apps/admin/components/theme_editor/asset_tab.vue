<template>
  <b-radio-button
      v-model="selectedAsset"
      :key="asset.key"
      :native-value="asset"
      size="is-small"
      type="is-primary is-light is-outlined"
  >
    {{ assetNameWithoutSection() }}
    <div class="close-button-container">
      <template v-if="isHasChanges">
        <div class="change-circle"></div>
        <div class="close-button close-button--hidden" @click.stop="close">x</div>
      </template>
      <div v-else class="close-button" @click.stop="close">x</div>
    </div>
  </b-radio-button>
</template>

<script>
  import gql from 'graphql-tag'
  import Vue from 'vue'
  import constants from './constants.js'

  export default {
    props: {
      asset: Object,
    },

    computed: {
      selectedAsset: {
        get() { return this.$store.state.themeEditor.selectedAsset },
        set(asset) { this.$store.commit('themeEditor/setSelectedAsset', asset) }
      },

      isHasChanges() {
        return this.asset.value && this.asset.value != this.asset.originalValue
      }
    },

    apollo: {
      remoteAsset: {
        query: gql`
          query ($shopId: ID!, $themeId: ID!, $assetKey: String!) {
            shop(id: $shopId) {
              id
              shopifyTheme(themeId: $themeId) {
                id
                asset(assetKey: $assetKey) {
                  key
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
            assetKey: this.asset.key,
          }
        },
        update(data) {
          return data.shop.shopifyTheme.asset
        },
      }
    },

    methods: {
      assetNameWithoutSection() {
        const key = this.asset.key
        const sectionName = constants.sectionNames.find(sectionName => _.startsWith(key, sectionName))
        if (sectionName) {
          return key.split(`${sectionName}/`)[1]
        } else {
          return key
        }
      },

      close() {
        this.$store.dispatch('themeEditor/closeAssetTab', this.asset)
      }
    },

    watch: {
      'remoteAsset.value'() {
        if (!this.asset.value) {
          Vue.set(this.asset, 'value', this.remoteAsset.value)
          Vue.set(this.asset, 'originalValue', this.remoteAsset.value)
        }
      }
    },
  }
</script>

<style lang="scss" scoped>
  .close-button-container {
    display: flex;
    align-items: center;
    margin-left: 4px;
    width: 20px;
    height: 100%;
     &:hover {
      .close-button { display: flex; }
      .change-circle  { display: none; }
    }
  }

  .change-circle {
    width: 8px;
    height: 8px;
    border-radius: 50%;
    margin-left: 6px;
    background-color: lightseagreen;
    &:hover { display: none; }
  }

  .close-button {
    display: flex;
    align-items: center;
    justify-content: space-around;
    font-weight: bold;
    width: 20px;
    height: 20px;
    border-radius: 4px;
    &:hover { background-color: lightgrey; }
    &--hidden { display: none; }
  }
</style>
