<template>
  <b-select v-model="selectedTheme"
      size="is-small"
      @input="(theme) => $emit('themeSelect', theme)">
    <option v-for="theme in shopifyThemes" :value="theme" :key="theme.id">
      {{ theme.name }}
      <span v-if="theme.live">
        (Live)
      </span>
    </option>
  </b-select>
</template>

<script>
  export default {
    props: {
      shopifyThemes: Array,
    },

    data() {
      return {
        selectedTheme: null,
      }
    },

    mounted() {
      const globalCustomization = _.find(this.shopifyThemes, theme => {
        return theme.global
      })
      this.selectedTheme = globalCustomization
      this.$emit('themeSelect', globalCustomization)
    }
  }
</script>
