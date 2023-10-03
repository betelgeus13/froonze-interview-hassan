<template>
  <div v-if="isAnyActions" class="shop-links">
    <router-link v-if="shop.installed && showLink('shop_info')" :to="`/shop_info?shop_id=${shop.id}`">
      <b-button type="is-link" size="is-small">Shop Info</b-button>
    </router-link>
    <router-link v-if="shop.installed && showLink('theme_customizations')" :to="`/theme_customizations?shop_id=${shop.id}`">
      <b-button type="is-link" size="is-small">Theme customizations</b-button>
    </router-link>
    <router-link v-if="shop.installed && showLink('theme_editor')" :to="`/shop/${shop.id}/theme_editor/theme/${liveTheme.id}`">
      <b-button type="is-link" size="is-small">Theme editor</b-button>
    </router-link>
    <div class="right-side-buttons">
      <b-button tag="a" target="_blank" :href="`/admin/login_to_shop?shop_id=${shop.id}`" size="is-small" type="is-link">
        Login
      </b-button>
    </div>
  </div>
</template>

<script>
  export default {
    props: {
      shop: Object,
      skip: String
    },

    computed: {
      isAnyActions() {
        return this.shop.installed
      },
      liveTheme() {
        return this.shop.shopifyThemes.find(theme => theme.live)
      }
    },
    methods: {
      showLink(link) {
        return this.skip != link
      }
    }
  }
</script>

<style lang="scss" scoped>
  .shop-links {
    margin-bottom: 12px;
    border-bottom: 1px solid lightgrey;
    padding-bottom: 12px;
  }

  .right-side-buttons {
    float: right;
  }
</style>
