json.data @listings, partial: "api/v1/listings/listing", as: :listing

json.meta do
  json.total_count @total_count
  json.page @page
  json.per_page @per_page
  json.total_pages @total_pages
  json.filters @filters
end

json.links do
  query = request.query_parameters.except("page")
  json.self api_v1_listings_url(query.merge(page: @page))
  json.first api_v1_listings_url(query.merge(page: 1))
  json.prev(@page > 1 ? api_v1_listings_url(query.merge(page: @page - 1)) : nil)
  json.next(@page < @total_pages ? api_v1_listings_url(query.merge(page: @page + 1)) : nil)
  json.last api_v1_listings_url(query.merge(page: [ @total_pages, 1 ].max))
end
