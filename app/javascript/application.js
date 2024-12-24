import "@hotwired/turbo-rails"
import "./controllers"
import "./channels"
import * as bootstrap from "bootstrap"

document.addEventListener("turbo:load", () => {
    const tooltipTriggerList = [].slice.call(document.querySelectorAll('[data-bs-toggle="tooltip"]'))
    tooltipTriggerList.map((tooltipTriggerEl) => {
        return new bootstrap.Tooltip(tooltipTriggerEl)
    })
})
