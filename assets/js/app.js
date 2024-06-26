// If you want to use Phoenix channels, run `mix help phx.gen.channel`
// to get started and then uncomment the line below.
// import "./user_socket.js"

// You can include dependencies in two ways.
//
// The simplest option is to put them in assets/vendor and
// import them using relative paths:
//
//     import "../vendor/some-package.js"
//
// Alternatively, you can `npm install some-package --prefix assets` and import
// them using a path starting with the package name:
//
//     import "some-package"
//

// Include phoenix_html to handle method=PUT/DELETE in forms and buttons.
import "phoenix_html"
// Establish Phoenix Socket and LiveView configuration.
import {Socket} from "phoenix"
import {LiveSocket} from "phoenix_live_view"
import topbar from "../vendor/topbar"
import Sortable from "../vendor/sortable"
import SelectHook from "./SelectHook"

let Hooks = {}

Hooks.BoardTicketDragDrop = {
  mounted() {
    new Sortable(this.el, {
      dragClass: "drag-item",
      ghostClass: "drag-ghost",
      group: "board-ticket-group",
      onEnd: e => {
        const params = {
          ...e.item.dataset,
          oldIndex: e.oldIndex,
          newIndex: e.newIndex,
          oldStatus: e.from.id,
          newStatus: e.to.id
        }
        this.pushEventTo(this.el, "move_ticket", params)
      }
    })
  }
}

Hooks.BacklogTicketDragDrop = {
  mounted() {
    new Sortable(this.el, {
      dragClass: "drag-item",
      ghostClass: "drag-ghost",
      group: "backlog-ticket-group",
      onEnd: e => {
        const params = {
          ...e.item.dataset,
          oldIndex: e.oldIndex,
          newIndex: e.newIndex,
          oldIteration: e.from.id,
          newIteration: e.to.id
        }
        this.pushEventTo(this.el, "change_ticket_iteration", params)
      }
    })
  }
}

Hooks.LocalTime = {
  mounted() {
    this.updated()
  },
  updated() {
    const dt = new Date(this.el.textContent.trim())
    this.el.textContent = dt.toLocaleString()
    this.el.classList.remove("invisible")
  }
}

Hooks.Select = SelectHook

let csrfToken = document.querySelector("meta[name='csrf-token']").getAttribute("content")
let liveSocket = new LiveSocket("/live", Socket, {params: {_csrf_token: csrfToken}, hooks: Hooks})

// Show progress bar on live navigation and form submits
topbar.config({barColors: {0: "#29d"}, shadowColor: "rgba(0, 0, 0, .3)"})
window.addEventListener("phx:page-loading-start", _info => topbar.show(300))
window.addEventListener("phx:page-loading-stop", _info => topbar.hide())

// connect if there are any LiveViews on the page
liveSocket.connect()

// expose liveSocket on window for web console debug logs and latency simulation:
// >> liveSocket.enableDebug()
// >> liveSocket.enableLatencySim(1000)  // enabled for duration of browser session
// >> liveSocket.disableLatencySim()
window.liveSocket = liveSocket

