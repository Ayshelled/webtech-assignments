# Small builders for the authorization and API tests: a host with a property, a
# listing and members, without depending on the seeds
module RoomiesFactory
  def create_member(name, role: :member)
    User.create!(full_name: name.capitalize, email_address: "#{name}@example.com", password: "password123", role: role)
  end

  def create_listing(host, status: :published, title: "Room of #{host.full_name}", rent: 350_000)
    @neighborhood ||= Neighborhood.create!(name: "Ñuñoa", city: "Santiago")
    property = Property.create!(user: host, neighborhood: @neighborhood, street_address: "Irarrázaval #{rand(1000..9999)}",
                                property_type: :apartment)
    property.listings.create!(title: title, monthly_rent: rent, deposit: 0, available_from: Date.current + 10,
                              description: "<p>A room</p>", status: status)
  end

  def create_application(listing, seeker)
    listing.applications.create!(user: seeker, message: "Hi, I'm #{seeker.full_name}", intended_stay_months: 6,
                                 desired_move_in_date: Date.current + 15)
  end
end
