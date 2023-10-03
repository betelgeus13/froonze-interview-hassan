<template>
  <b-menu :activable="false" class="menu">
    <b-menu-list class="menu-list">
      <router-link to='/shop_info'>
        <b-menu-item icon="store" label="Shop info" :active="$route.path == '/shop_info'" />
      </router-link>
      <router-link to='/theme_customizations'>
        <b-menu-item icon="monitor-dashboard" label="Theme customizations" :active="$route.path == '/theme_customizations'" />
      </router-link>
    </b-menu-list>
  </b-menu>
</template>


<style lang="scss" scoped>
  .menu {
    padding-top: 20px;
  }

  ::v-deep .menu-list a, .menu-item {
    padding: 2px 8px;
  }
</style>
