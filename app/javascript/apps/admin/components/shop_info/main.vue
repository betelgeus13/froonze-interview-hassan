<template>
  <div>
    <shop-info v-if="$route.query.shop_id" />
    <div v-else class="shop-finder-container container">
      <shop-finder @select="handleShopSelect" />
    </div>
  </div>
</template>

<script>
  import ShopFinder from 'Admin/components/shop_finder'
  import ShopInfo from './shop_info'

  export default {
    components: { ShopFinder, ShopInfo },

    methods: {
      handleShopSelect(shop) {
        this.$router.push(`/shop_info?shop_id=${shop.id}`)
      }
    }
  }
</script>

<style lang="scss" scoped>
  .shop-finder-container {
    padding: 20px;
  }
</style>
