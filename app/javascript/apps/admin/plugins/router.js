import Vue from 'vue'
import VueRouter from 'vue-router'

import Shop from 'Admin/components/shop.vue'
import ShopInfo from 'Admin/components/shop_info/main.vue'
import ThemeCustomizations from 'Admin/components/theme_customizations/main.vue'
import ThemeEditor from 'Admin/components/theme_editor/main.vue'

Vue.use(VueRouter)

export default new VueRouter({
  routes: [
    { path: '/', redirect: '/shop_info' },
    { path: '/shop_info', component: ShopInfo },
    { path: '/theme_customizations', component: ThemeCustomizations },
    {
      path: '/shop/:shopId',
      component: Shop,
      children: [
        {
          path: 'theme_editor/theme/:themeId',
          component: ThemeEditor,
        },
      ]
    },
  ],
})
