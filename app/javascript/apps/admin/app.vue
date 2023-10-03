<template>
  <div>
    <sidebar class="sidebar" />
    <div class="router-view-container">
      <router-view class="router-view" />
    </div>
  </div>
</template>

<script>
import Sidebar from './components/sidebar'

export default {
  components: { Sidebar }
}
</script>

<style lang='scss'>
  @import '~Admin/styles/variables';

  .sidebar {
    display: inline-block;
    vertical-align: top;
    width: 226px;
    height: 100vh;
    background-color: $backgroundColor;
    border-right: 1px solid lightgrey;
  }

  .router-view-container {
    float: right;
    vertical-align: top;
    width: calc(100% - 226px);
    height: 100vh;
    overflow-y: auto;
    background-color: white;
  }

  .router-view {
    margin: 0 auto;
    font-size: 14px;
  }

  table {
    font-size: 14px;
  }

  .level.header.header {
    background-color: lighten($primaryColor, 20%);
    color: white;
    padding: 12px;
    margin-bottom: 0;
  }

  .body {
    padding: 20px;
  }
</style>
