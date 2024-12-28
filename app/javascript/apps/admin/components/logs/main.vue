<template>
  <div>
    <logs />
  </div>
</template>

<script>
  import ShopFinder from 'Admin/components/shop_finder'
  import Logs from './logs'

  export default {
    components: { ShopFinder, Logs },

    methods: {
      handleShopSelect(shop) {
        this.$router.push(`/logs`)
      }
    }
  }
</script>
