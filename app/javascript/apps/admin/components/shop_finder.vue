<template>
  <b-field class="shop-finder">
    <b-autocomplete
        v-model="searchQuery"
        :data="autocompleteShops"
        field="shopifyDomain"
        :loading="$apollo.loading"
        @select="handleShopSelect"
        icon="magnify"
        placeholder="Find a shop"
        size="is-small"
    >
      <template #empty>No results found</template>
    </b-autocomplete>
  </b-field>
</template>

<script>
  import gql from 'graphql-tag'

  export default {
    data() {
      return {
        searchQuery: '',
      }
    },

    apollo: {
      shopSearch: {
        query: gql`
          query shopSearch($query: String!) {
            shopSearch(query: $query) {
              id
              shopifyDomain
              shopifyThemes {
                id
                live
              }
            }
          }
        `,
        variables() {
          return {
            query: this.searchQuery,
          }
        }
      }
    },

    methods: {
      handleShopSelect(shop) {
        if (!shop) return
        this.$emit('select', shop)
      }
    },

    computed: {
      autocompleteShops() {
        return this.$apollo.loading ? [] : this.shopSearch
      }
    }
  }
</script>

<style lang="scss">
  .shop-finder {
    .autocomplete .dropdown-menu {
      width: auto;
    }
  }
</style>
