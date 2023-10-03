<template>
  <div class="editor-container">
    <b-select v-model="selectedCustomizationType"
        size="is-small"
        class="customization-type-select">
      <option v-for="customizationTypeOtion in $constants.theme_customization_types"
          :value="customizationTypeOtion"
          :key="customizationTypeOtion"
      >
        {{ customizationTypeOtion }}
      </option>
    </b-select>
    <b-field position="is-centered">
      <b-radio-button v-for="fieldName in ['css', 'js', 'html']"
          v-model="activeTab"
          :native-value="fieldName"
          :key="fieldName">
        <span>{{ fieldName }}</span>
      </b-radio-button>
    </b-field>
    <ace-editor v-model="currentValue" :mode="activeTab" />
    <b-button type="is-info" @click="save" :loading="isSaving">
      Save
    </b-button>
  </div>
</template>

<script>
  import Vue from 'vue'
  import gql from 'graphql-tag'
  import saveShortcutSetter from 'JS/shared/services/save_shortcut_setter.js'

  import AceEditor from './ace_editor.vue'

  export default {
    components: { AceEditor },

    props: {
      theme: Object,
    },

    data() {
      return {
        selectedCustomizationType: 'customer_page',
        activeTab: 'css',
        isSaving: false,
      }
    },

    computed: {
      themeCustomization() {
        const themeCustomization = this.theme.shopifyThemeCustomizations.find(themeCustomization => {
          return themeCustomization.customizationType == this.selectedCustomizationType
        })
        return themeCustomization
      },

      currentValue: {
        get() { return this.themeCustomization[this.activeTab] },
        set(value) {
          Vue.set(this.themeCustomization, this.activeTab, value)
        }
      },
    },

    methods: {
      trimFields() {
        _.each(['css', 'js', 'html'], (fieldName) => {
          let value = this.themeCustomization[fieldName]
          if (!value) return
          value = value.trim()
          Vue.set(this.themeCustomization, fieldName, value)
        })
      },

      save() {
        this.trimFields()
        this.isSaving = true
        this.$apollo.mutate({
          mutation: gql`
            mutation updateShopifyThemeCustomization($input: UpdateShopifyThemeCustomizationInput!) {
              updateShopifyThemeCustomization(input: $input) {
                error
              }
            }
          `,
          variables: {
            input: {
              shopId: parseInt(this.$route.query.shop_id),
              shopifyThemeId: this.theme.id,
              shopifyThemeCustomization: {
                customizationType: this.themeCustomization.customizationType,
                css: this.themeCustomization.css,
                js: this.themeCustomization.js,
                html: this.themeCustomization.html,
              }
            },
          },
        })
        .then(response => {
          const error = response.data.updateShopifyThemeCustomization.error
          if (error) {
            this.showError(error)
          } else {
            this.showSuccess('Successfully updated')
          }
        })
        .catch(this.showDefaultError)
        .finally(() => this.isSaving = false)
      }
    },

    mounted() {
      saveShortcutSetter.call('themeEditor', this.save)
    }
  }
</script>

<style lang="scss" scoped>
  .editor-container {
    text-align: center;
  }

  .editor {
    border-radius: 4px;
    font-family: 'Source Code Pro', monospace;
    font-size: 14px;
    height: calc(100vh - 280px);
    letter-spacing: normal;
    line-height: 20px;
    margin-bottom: 20px;
  }

  .lang-tabs.lang-tabs {
    margin-bottom: 0;
  }

  .customization-type-select {
    margin-bottom: 20px;
  }
</style>
