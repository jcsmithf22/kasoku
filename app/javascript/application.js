// Entry point for the build script in your package.json
import "@hotwired/turbo-rails"
import "./controllers"

Turbo.StreamActions.add_error = function() {
    this.targetElements.forEach(target => {
        target.classList.add('input-error')
    })
}

Turbo.StreamActions.remove_error = function() {
    this.targetElements.forEach(target => {
        target.classList.remove('input-error')
    })
}