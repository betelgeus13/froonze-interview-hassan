<template>
  <div class="editor-container">
    <b-loading v-if="!value && value != ''" active :is-full-page="false" />
    <div class="editor" ref="editor" />
  </div>
</template>

<script>
  import { mapState } from 'vuex'
  import ace from 'brace'
  import 'brace/mode/liquid'
  import 'brace/mode/css'
  import 'brace/mode/javascript'
  import 'brace/mode/json'
  import 'brace/theme/monokai'
  require('brace/ext/searchbox')

  const MODES_MAPPING = {
    'text/css': 'css',
    'application/javascript': 'javascript',
    'application/x-liquid': 'liquid',
    'application/json': 'json',
  }

  export default {
    computed: {
      ...mapState({
        selectedAsset: state => state.themeEditor.selectedAsset,
      }),
      value() {
        return this.selectedAsset.value
      },
      contentType() {
        return this.selectedAsset.contentType
      }
    },

    data() {
      return {
        editor: null,
      }
    },

    methods: {
      setup() {
        this.editor = ace.edit(this.$refs.editor)
        this.editor.setTheme('ace/theme/monokai')
        this.setEditorMode()
        this.setCurrentValue()
        this.editor.$blockScrolling = Infinity
        this.editor.session.setTabSize(2)
        this.editor.session.on('change', () => {
          this.selectedAsset.value = this.editor.session.getValue()
        })
      },

      setCurrentValue() {
        if (this.value != null) this.editor.session.setValue(this.value)
      },

      setEditorMode() {
        const mode = MODES_MAPPING[this.contentType]
        this.editor.session.setMode(`ace/mode/${mode}`)
      },
    },

    watch: {
      value() {
        const localValue = this.editor.session.getValue()
        if (localValue != this.value) this.setCurrentValue()
      },

      contentType() {
        this.setEditorMode()
      }
    },

    mounted() {
      this.setup()
    },

  }
</script>

<style lang="scss" scoped>
  .editor-container {
    position: relative;
  }

  .editor {
    border-radius: 4px;
    font-family: 'Source Code Pro', monospace;
    font-size: 14px;
    height: calc(100vh - 146px);
    letter-spacing: normal;
    line-height: 20px;
    margin-bottom: 20px;
  }
</style>
