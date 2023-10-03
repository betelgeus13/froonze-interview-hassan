import 'JS/shared/styles/toast.scss'

export default {
  open
}


function open({ text, type, timer = 3000, timerProgressBar = true } = {}) {
  const closeAt = new Date().valueOf() + timer
  const id = `frcp_toat_wrapper_${closeAt}`
  const existingToast = document.querySelector('.frcp-toast-wrapper')
  let delay = 0
  if (existingToast) delay = parseInt(existingToast.id.replace('frcp_toat_wrapper_', '')) - new Date() + 500

  setTimeout(() => {
    document.body.append(html(text, type, timerProgressBar, id))
    if (timerProgressBar) setProgressBar(timer, id)
    if (timer) clearToast(timer, id)
  }, delay)
}

function html(text, type, timerProgressBar, id) {
  const wrapper = document.createElement('div')
  const className = type == 'error' ? 'frcp-toast--error' : 'frcp-toast--success'
  wrapper.className = 'frcp-toast-wrapper'
  wrapper.id = id

  let progressBar = ''

  if (timerProgressBar) {
    progressBar = `
      <div class="frcp-toast__progress-bar-container">
        <div class="frcp-toast__progress-bar"></div>
      </div>
    `
  }

  const icontHtml = type == 'error' ? errorIcon() : successIcon()
  const popup = `
    <div class='frcp-toast frcp-toast--show ${className}'>
      ${icontHtml}
      <div class='frcp-toast__title'>${text}</div>
      ${progressBar}
    </div>
  `

  wrapper.innerHTML = popup

  return wrapper
}

function clearToast(timer, id) {
  setTimeout(() => {
    const elem = document.querySelector('.frcp-toast--show')
    elem.classList.remove('frcp-toast--show')
    elem.classList.add('frcp-toast--hide')
    setTimeout(() => {
      document.querySelector(`#${id}`).remove()
    }, 100)
  }, timer)
}

function setProgressBar(timer, id) {
  const seconds = parseInt(timer / 1000)
  const progressBar = document.querySelector(`#${id} .frcp-toast__progress-bar`)
  progressBar.style.transition = `width ${seconds}s linear 0s`
  progressBar.style.display = 'flex'
  setTimeout(() => {
    progressBar.style.width = '0%'
  }, 10)
}

function errorIcon() {
  return `
    <div class="frcp-toast__icon">
      <span class="frcp-toast__x-mark">
        <span class="frcp-toast__x-mark-line-left"></span>
        <span class="frcp-toast__x-mark-line-right"></span>
      </span>
    </div>
  `
}


function successIcon() {
  return `
    <div class="frcp-toast__icon frcp-toast__success">
      <div class="frcp-toast__success-circular-line-left"></div>
      <span class="frcp-toast__success-line-tip"></span> 
      <span class="frcp-toast__success-line-long"></span>
      <div class="frcp-toast__success-ring"></div> 
      <div class="frcp-toast__success-fix"></div>
      <div class="frcp-toast__success-circular-line-right" ></div>
    </div>
  `
}
