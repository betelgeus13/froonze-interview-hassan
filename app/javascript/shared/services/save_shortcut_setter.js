const REGISTERED_EVENTS = {}

export default {
  call(name, callback) {
    if (REGISTERED_EVENTS[name]) return
    document.addEventListener('keydown', (e) => {
      if (e.key === "s" && (e.ctrlKey || e.metaKey)) {
        e.preventDefault() // prevent "Save Page" from getting triggered.
        callback()
      }
    })
    REGISTERED_EVENTS[name] = true
  }
}
