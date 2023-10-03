function getDefaultState() {
  return {
    selectedTheme: null,
    selectedAsset: null,
    assetTabs: [],
    selectedAssetTab: null
  }
}

const actions = {
  changeTheme: (context, theme) => {
    context.commit('resetAssetsTabs')
    context.commit('setSelectedAsset', null)
    context.commit('setSelectedTheme', theme)
  },

  addAssetTab: (context, asset) => {
    context.commit('setSelectedAsset', asset)
    const assetTabs = context.state.assetTabs
    if (assetTabs.includes(asset)) return
    context.commit('addAssetTab', asset)
  },

  closeAssetTab: (context, asset) => {
    const state = context.state
    if (asset == state.selectedAsset) {
      if (state.assetTabs.length == 1) {
        context.commit('setSelectedAsset', null)
      } else {
        const index = state.assetTabs.indexOf(asset)
        context.commit('setSelectedAsset', state.assetTabs[index - 1])
      }
    }
    context.commit('closeAssetTab', asset)
  }
}

const mutations = {
  resetState: state => Object.assign(state, getDefaultState()),

  setSelectedTheme: (state, theme) => state.selectedTheme = theme,

  setSelectedAsset: (state, asset) => state.selectedAsset = asset,

  resetAssetsTabs: state => state.assetTabs = [],

  addAssetTab: (state, asset) => state.assetTabs.push(asset),

  closeAssetTab: (state, asset) => state.assetTabs = _.without(state.assetTabs, asset)
}

export default {
  namespaced: true,
  state: getDefaultState(),
  actions,
  mutations
}
