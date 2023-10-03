<template>
  <div>
    <editing-window v-if="$route.query.shop_id" />
    <div v-else class="shop-finder-container container">
      <shop-finder @select="handleShopSelect" />
    </div>
  </div>
</template>

<script>
  import ShopFinder from 'Admin/components/shop_finder'
  import EditingWindow from './editing_window'

  export default {
    components: { ShopFinder, EditingWindow },

    data() {
      return {
        isShopSelected: false,
      }
    },

    methods: {
      handleShopSelect(shop) {
        this.$router.push(`/theme_customizations?shop_id=${shop.id}`)
      },
      showShopFinder() {
        this.$router.push('/theme_customizations')
      }
    },
  }
</script>

<style lang="scss" scoped>
  .shop-finder-container {
    padding: 20px;
  }
</style>
