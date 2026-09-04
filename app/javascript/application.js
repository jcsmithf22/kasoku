// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails
import "@hotwired/turbo-rails"
import "controllers"

Turbo.StreamActions.add_error = function() {
  this.targetElements.forEach((target) => {
    target.classList.add("border-red-500")
  })
}

Turbo.StreamActions.remove_error = function() {
  this.targetElements.forEach((target) => {
    target.classList.remove("border-red-500")
  })
}
