import { Controller } from "@hotwired/stimulus"

// The search page (/listings) asks the public JSON API for the rooms with fetch:
// changing a filter, or submitting the form, reloads only the results, without a
// full page request. The page still works without JavaScript: the form is a plain
// GET to /listings that the server renders, and that is also the first render.
//
// <div data-controller="listing-search" data-listing-search-url-value="/api/v1/listings">
//   ...the search form...
//   <p data-listing-search-target="count"></p>
//   <div data-listing-search-target="results"></div>
//   <div data-listing-search-target="more"></div>
// </div>
export default class extends Controller {
  static targets = ["count", "results", "more", "status"]
  static values = { url: String, perPage: { type: Number, default: 12 } }

  connect() {
    this.form = this.element.querySelector("form")
    this.currency = new Intl.NumberFormat("es-CL", { style: "currency", currency: "CLP", maximumFractionDigits: 0 })
    this.dates = new Intl.DateTimeFormat("en-GB", { day: "numeric", month: "short", year: "numeric", timeZone: "UTC" })
  }

  disconnect() {
    this.abortController?.abort()
  }

  // submit->listing-search#search and change->listing-search#search
  search(event) {
    if (event.type === "submit") event.preventDefault()
    this.load(1, { append: false })
  }

  // click->listing-search#loadMore on the "Show more rooms" button
  loadMore(event) {
    event.preventDefault()
    this.load(this.page + 1, { append: true })
  }

  async load(page, { append }) {
    const filters = this.filters()
    const query = new URLSearchParams({ ...filters, page, per_page: this.perPageValue })

    // Only the latest request matters: a slower, older answer must not overwrite it
    this.abortController?.abort()
    this.abortController = new AbortController()
    this.setStatus("Searching…")
    this.element.setAttribute("aria-busy", "true")

    try {
      const response = await fetch(`${this.urlValue}?${query}`, {
        headers: { Accept: "application/json" },
        signal: this.abortController.signal
      })
      const body = await response.json()

      if (!response.ok) {
        // 400 Bad Request: the API says which parameter was wrong
        const details = Object.entries(body.error?.details || {}).map(([name, problem]) => `${name.replace("_", " ")} ${problem}`)
        this.showError([body.error?.message || "The search failed", ...details].join(". "))
        return
      }

      this.page = body.meta.page
      this.render(body, { append })
      // Keep the address in sync, so reloading or sharing the page shows the same search
      const pageQuery = new URLSearchParams(filters).toString()
      window.history.replaceState(window.history.state, "", pageQuery ? `${location.pathname}?${pageQuery}` : location.pathname)
      this.setStatus("")
    } catch (error) {
      if (error.name === "AbortError") return
      this.showError("Couldn't reach the server. Check your connection and try again.")
    } finally {
      this.element.removeAttribute("aria-busy")
    }
  }

  // The non-blank values of the form, as query parameters
  filters() {
    const filters = {}
    for (const [name, value] of new FormData(this.form)) {
      if (value !== "" && name !== "authenticity_token") filters[name] = value
    }
    return filters
  }

  render(body, { append }) {
    const total = body.meta.total_count
    this.countTarget.textContent = `${total} ${total === 1 ? "room" : "rooms"} found`

    if (!append) this.resultsTarget.replaceChildren()

    if (total === 0) {
      this.resultsTarget.replaceChildren(this.emptyState())
    } else {
      let row = this.resultsTarget.querySelector(".row")
      if (!row) {
        row = this.build("div", "row g-4")
        this.resultsTarget.append(row)
      }
      body.data.forEach((listing) => row.append(this.card(listing)))
    }

    this.moreTarget.replaceChildren()
    if (body.links.next) {
      const button = this.build("button", "btn btn-outline-secondary", "Show more rooms")
      button.type = "button"
      button.dataset.action = "listing-search#loadMore"
      this.moreTarget.append(button)
    }
  }

  // The same card as app/views/listings/_listing.html.erb, built from the API data.
  // textContent everywhere: nothing from the API is ever parsed as HTML.
  card(listing) {
    const column = this.build("article", "col-md-6 col-lg-4")
    const card = this.build("div", "listing-card h-100 position-relative")

    if (listing.cover_photo) {
      const image = this.build("img", "card-img-top")
      image.src = listing.cover_photo.url
      image.alt = listing.cover_photo.alt
      image.loading = "lazy"
      card.append(image)
    } else {
      const placeholder = this.build("div", "card-img-top photo-placeholder d-flex align-items-center justify-content-center")
      placeholder.setAttribute("aria-hidden", "true")
      placeholder.append(this.build("i", "bi bi-house-door"))
      card.append(placeholder)
    }

    const bodyElement = this.build("div", "card-body")
    const header = this.build("div", "d-flex justify-content-between align-items-start gap-2")
    const title = this.build("h3", "mb-2")
    const link = this.build("a", "stretched-link text-reset text-decoration-none", listing.title)
    link.href = listing.links.html
    title.append(link)
    header.append(title, this.build("span", "price text-nowrap", this.currency.format(listing.monthly_rent)))

    const type = listing.property.type.replaceAll("_", " ")
    const meta = this.build("p", "listing-meta mb-2",
      `${listing.neighborhood.name} · ${type.charAt(0).toUpperCase()}${type.slice(1)} · Available ${this.formatDate(listing.available_from)}`)
    const place = this.build("p", "listing-meta small mb-0", ` ${listing.neighborhood.city}`)
    const pin = this.build("i", "bi bi-geo-alt")
    pin.setAttribute("aria-hidden", "true")
    place.prepend(pin)

    const badges = this.build("div", "d-flex flex-wrap gap-1 mt-3")
    if (listing.furnished) badges.append(this.badge("Furnished"))
    if (listing.private_bathroom) badges.append(this.badge("Private bathroom"))
    const months = listing.minimum_stay_months
    badges.append(this.badge(`Min. ${months} ${months === 1 ? "month" : "months"}`))

    bodyElement.append(header, meta, place, badges)
    card.append(bodyElement)
    column.append(card)
    return column
  }

  emptyState() {
    const empty = this.build("div", "empty-state text-center text-secondary py-5")
    const icon = this.build("i", "bi bi-search fs-1 d-block mb-2")
    icon.setAttribute("aria-hidden", "true")
    empty.append(icon, this.build("p", "mb-0", "No published rooms match these filters. Try widening your search."))
    return empty
  }

  showError(message) {
    this.setStatus("")
    const alert = this.build("div", "alert alert-warning", message)
    alert.setAttribute("role", "alert")
    this.resultsTarget.replaceChildren(alert)
    this.moreTarget.replaceChildren()
  }

  setStatus(text) {
    if (this.hasStatusTarget) this.statusTarget.textContent = text
  }

  badge(text) {
    return this.build("span", "badge text-bg-light border", text)
  }

  formatDate(isoDate) {
    return isoDate ? this.dates.format(new Date(`${isoDate}T00:00:00Z`)) : ""
  }

  build(tagName, className, text) {
    const element = document.createElement(tagName)
    if (className) element.className = className
    if (text !== undefined) element.textContent = text
    return element
  }
}
