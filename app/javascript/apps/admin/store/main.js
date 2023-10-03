import Vue from 'vue'
import Vuex from 'vuex'

import themeEditorModule from './theme_editor.js'

Vue.use(Vuex)

const defaultState = {}

const actions = {}

const mutations = {}

export default new Vuex.Store({
  state: defaultState,
  actions,
  mutations,
  modules: {
    themeEditor: themeEditorModule,
  }
});
