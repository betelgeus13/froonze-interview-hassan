<template>
  <div v-if="selectedAsset" class="editing-window">
    <div class="top-pannel-container">
      <b-field class="asset-tabs has-addons">
        <asset-tab v-for="asset in assetTabs" :asset="asset" :key="asset.key" />
      </b-field>
      <div class="top-pannel-separator" />
      <b-button v-if="selectedAsset"
          @click="save"
          :loading="isSaving"
          type="is-primary"
          size="is-small"
          class="save-btn"
      >
        Save
      </b-button>
    </div>
    <ace-editor />
  </div>
</template>

<script>
  import Vue from 'vue'
  import { mapState } from 'vuex'
  import gql from 'graphql-tag'
  import AssetTab from './asset_tab.vue'
  import AceEditor from './ace_editor.vue'

  export default {
    components: {
      AssetTab,
      AceEditor,
    },

    computed: {
      ...mapState({
        assetTabs: state => state.themeEditor.assetTabs,
        selectedAsset: state => state.themeEditor.selectedAsset,
      }),
    },

    data() {
      return {
        isSaving: false,
      }
    },

    methods: {
      save() {
        const savingAsset = this.selectedAsset // in case selected asset changes while saving is still going on
        this.isSaving = true
        this.$apollo.mutate({
          mutation: gql`
            mutation updateShopifyThemeAsset($input: UpdateShopifyThemeAssetInput!) {
              updateShopifyThemeAsset(input: $input) {
                error
              }
            }
          `,
          variables: {
            input: {
              shopId: parseInt(this.$route.params.shopId),
              themeId: this.$route.params.themeId,
              assetKey: savingAsset.key,
              value: savingAsset.value,
            }
          }
        })
        .then(response => {
          const error = response.data.updateShopifyThemeAsset.error
          if (error) {
            this.showError(error)
          } else {
            this.showSuccess('Successfully updated')
            Vue.set(savingAsset, 'originalValue', savingAsset.value)
          }
        })
        .catch(this.showDefaultError)
        .finally(() => this.isSaving = false)
      }
    }
  }
</script>

<style lang="scss" scoped>
  .top-pannel-container {
    display: flex;
    justify-content: space-between;
    border: 1px solid lightgrey;
    border-radius: 2px;
    margin-bottom: 12px;
    padding: 8px;
  }

  .top-pannel-separator {
    height: 30px;
    width: 1px;
    background-color: lightgrey;
    margin: 0 20px;
  }

  .asset-tabs.asset-tabs {
    display: inline-flex;
    overflow-x: auto;
    width: calc(100% - 70px);
    margin-bottom: 0;
  }
</style>
