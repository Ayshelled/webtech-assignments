module ApplicationHelper
  # Bootstrap colour for every lifecycle state (listings, applications, visits and reports)
  STATUS_COLORS = {
    "draft" => "secondary", "published" => "success", "reserved" => "warning",
    "rented" => "primary", "withdrawn" => "dark",
    "pending" => "secondary", "shortlisted" => "info", "accepted" => "success", "rejected" => "danger",
    "proposed" => "secondary", "confirmed" => "info", "cancelled" => "danger", "completed" => "success",
    "dismissed" => "secondary", "actioned" => "danger"
  }.freeze

  # The app operates in Santiago, so amounts are Chilean pesos: $450.000
  def clp(amount)
    number_to_currency(amount, unit: "$", delimiter: ".", separator: ",", precision: 0, format: "%u%n")
  end

  def status_badge(status)
    color = STATUS_COLORS.fetch(status.to_s, "secondary")
    tag.span(status.to_s.humanize, class: "badge rounded-pill text-bg-#{color}")
  end

  def short_date(date)
    l(date, format: "%-d %b %Y") if date
  end

  def date_time(time)
    l(time, format: "%-d %b %Y, %H:%M") if time
  end

  def rating_stars(rating)
    tag.span(class: "rating", aria: { label: "#{rating} out of 5 stars" }) do
      safe_join(1.upto(5).map { |i| tag.i(class: i <= rating ? "bi bi-star-fill" : "bi bi-star", aria: { hidden: true }) })
    end
  end

  def average_rating(reviews)
    return if reviews.empty?

    (reviews.sum(&:rating).to_f / reviews.size).round(1)
  end

  # Navbar link that is highlighted while browsing that section
  def nav_link(name, path, section)
    active = controller_name == section
    link_to name, path, class: class_names("nav-link", active: active), aria: { current: ("page" if active) }
  end
end
