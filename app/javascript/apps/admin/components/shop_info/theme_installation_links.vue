<template>
  <div class="card themes-card">
    <header class="card-header">
      <p class="card-header-title">
        Installation links
      </p>
    </header>
    <div class="card-content">
      <div v-for="theme in shop.shopifyThemes" :key="theme.id" class="theme-wrapper">
        <div class="name-and-tags-container">
          <div class="theme-name-wrapper" :title="theme.name">
            {{ theme.name }}
          </div>
          <b-tag v-if="theme.live" type="is-success">Live Theme</b-tag>
        </div>
        <b-button type="is-primary is-light" size="is-small" @click="copyLink(theme)">
          Copy
        </b-button>
      </div>
    </div>
  </div>
</template>

<script>
  export default {
    props: {
      shop: Object,
    },

    methods: {
      copyLink(theme) {
        const appUuid = this.$constants.shopify_theme_app_extension_uuid
        const installationLink = `https://${this.shop.shopifyDomain}/admin/themes/${theme.externalId}/editor/` +
          `?previewPath=/account&context=apps&activateAppId=${appUuid}/customer_account_page`
        navigator.clipboard.writeText(installationLink)
          .then(() => {
            this.$buefy.toast.open({
              message: `Copied installation link for ${theme.name} theme`,
              type: 'is-success'
            })
          })
      },
    },
  }
</script>

<style lang="scss" scoped>
  @import 'JS/shared/styles/mixins';

  .enable-accounts-btn { float: right; }

  .theme-wrapper {
    display: flex;
    align-items: center;
    justify-content: space-between;
    height: 44px;
    border-bottom: 1px solid lightgrey;
  }

  .name-and-tags-container {
    width: calc(100% - 60px);
  }

  .theme-name-wrapper {
    width: calc(100% - 100px);
    @include text-elipsis;
    display: inline-block;
    vertical-align: middle;
  }

  .card-content {
    min-height: 110px;
    max-height: 300px;
    overflow: auto;
  }
</style>
