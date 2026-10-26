// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails
import "@hotwired/turbo-rails"
import "controllers"
import * as bootstrap from "bootstrap"
import "trix"
import "@rails/actiontext"

// Photos are uploaded in the listing's own photo field (validated there), so the
// rich text editors only take text: formatting, lists and links, no file attachments
document.addEventListener("trix-file-accept", (event) => event.preventDefault())
