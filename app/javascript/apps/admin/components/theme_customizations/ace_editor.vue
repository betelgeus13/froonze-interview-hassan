<template>
  <div class="editor" ref="editor" />
</template>

<script>
  import ace from 'brace'
  import 'brace/mode/html'
  import 'brace/mode/css'
  import 'brace/mode/javascript'
  import 'brace/theme/monokai'
  require('brace/ext/searchbox')

  const MODES_MAPPING = {
    css: 'css',
    js: 'javascript',
    html: 'html',
  }

  export default {
    props: {
      value: String,
      mode: String,
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
          this.$emit('input', this.editor.session.getValue())
        })
      },

      setCurrentValue() {
        this.editor.session.setValue(this.value || '')
      },

      setEditorMode() {
        const mode = MODES_MAPPING[this.mode]
        this.editor.session.setMode(`ace/mode/${mode}`)
      },
    },

    watch: {
      value() {
        const localValue = this.editor.session.getValue()
        if (localValue != this.value) this.setCurrentValue()
      },

      mode() {
        this.setEditorMode()
      }
    },

    mounted() {
      this.setup()
    },

  }
</script>
