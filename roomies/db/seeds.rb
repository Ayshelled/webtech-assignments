# Roomies sample data
#
# Run with `bin/rails db:seed` (or `bin/rails db:reset` to start from an empty database).
# It wipes every Roomies table first, so it can be run as many times as needed.
#
# Dates are relative to the day you run it, so the data always tells a coherent story:
# listings available in the coming weeks, visits in the past are completed and the
# ones ahead are proposed or confirmed, and reviews come after their visit.
#
# Every user's password is "password123".

puts "Cleaning the database..."
ActiveRecord::Base.transaction do
  [ Report, SavedListing, Review, Visit, Application, ListingPhoto, Listing,
    PropertyAmenity, Property, Amenity, Neighborhood, User ].each(&:delete_all)
end

today = Date.current

# A time on a given day relative to today, e.g. at(-5, 19) is five days ago at 19:00
at = ->(days, hour, minute = 0) { (today + days).in_time_zone.change(hour: hour, min: minute) }

photo_url = ->(id) { "https://images.unsplash.com/photo-#{id}?auto=format&fit=crop&w=1200&q=80" }
photos_by_key = {
  bright_bedroom:  "1560185008-b033106af5c3",
  minimal_bedroom: "1598928506311-c55ded91a20c",
  cozy_bedroom:    "1616486338812-3dadae4b4ace",
  white_bedroom:   "1505693416388-ac5ce068fe85",
  wood_bedroom:    "1540518614846-7eded433c457",
  calm_bedroom:    "1522771739844-6a9f6d5f14af",
  modern_bedroom:  "1631049307264-da0ec9d70304",
  plant_bedroom:   "1595526114035-0d45ed16cfbf",
  open_living:     "1522708323590-d24dbb6b0267",
  apartment:       "1502672260266-1c1ef2d93688",
  living_room:     "1493809842364-78817add7ffb",
  kitchen:         "1484154218962-a197022b5858",
  lounge:          "1513694203232-719a280e022f",
  interior:        "1586023492125-27b2c045efd7"
}.freeze

ActiveRecord::Base.transaction do
  # ------------------------------------------------------------------
  # Users: one moderator, hosts and seekers (all members can do both)
  # ------------------------------------------------------------------
  puts "Creating users..."
  new_user = ->(full_name, email, phone, role = :member) {
    User.create!(full_name: full_name, email_address: email, phone: phone, role: role, password: "password123")
  }

  new_user.call("Ignacio Fuentes", "ignacio.fuentes@example.com", "+56 9 6123 4501", :moderator)

  camila    = new_user.call("Camila Rojas",      "camila.rojas@example.com",      "+56 9 8123 4567")
  matias    = new_user.call("Matías González",   "matias.gonzalez@example.com",   "+56 9 7234 5678")
  valentina = new_user.call("Valentina Muñoz",   "valentina.munoz@example.com",   "+56 9 9345 6789")
  felipe    = new_user.call("Felipe Soto",       "felipe.soto@example.com",       "+56 9 6456 7890")
  daniela   = new_user.call("Daniela Contreras", "daniela.contreras@example.com", "+56 9 5567 8901")

  tomas     = new_user.call("Tomás Herrera",     "tomas.herrera@example.com",     "+56 9 8678 9012")
  catalina  = new_user.call("Catalina Silva",    "catalina.silva@example.com",    "+56 9 7789 0123")
  benjamin  = new_user.call("Benjamín Morales",  "benjamin.morales@example.com",  "+56 9 9890 1234")
  fernanda  = new_user.call("Fernanda Torres",   "fernanda.torres@example.com",   "+56 9 6901 2345")
  joaquin   = new_user.call("Joaquín Araya",     "joaquin.araya@example.com",     nil)
  antonia   = new_user.call("Antonia Reyes",     "antonia.reyes@example.com",     "+56 9 5012 3456")
  diego     = new_user.call("Diego Espinoza",    "diego.espinoza@example.com",    "+56 9 8123 7788")
  martina   = new_user.call("Martina Castro",    "martina.castro@example.com",    "+56 9 7234 8899")
  lucas     = new_user.call("Lucas Pizarro",     "lucas.pizarro@example.com",     "+56 9 9345 9900")
  emma      = new_user.call("Emma Schneider",    "emma.schneider@example.com",    "+49 151 2345 6789")
  paula     = new_user.call("Paula Vergara",     "paula.vergara@example.com",     "+56 9 6456 1122")
  sebastian = new_user.call("Sebastián Rivas",   "sebastian.rivas@example.com",   "+56 9 5567 2233")

  # ------------------------------------------------------------------
  # Catalogs managed by moderators: neighborhoods and amenities
  # ------------------------------------------------------------------
  puts "Creating neighborhoods and amenities..."
  hoods = %w[Providencia Ñuñoa Las\ Condes Santiago\ Centro La\ Reina Macul San\ Miguel Vitacura].index_with do |name|
    Neighborhood.create!(name: name, city: "Santiago")
  end

  amenity_names  = [ "Wi-Fi", "Washing machine", "Heating", "Air conditioning", "Parking", "Elevator", "Concierge", "Gym", "Pool" ]
  shared_names   = [ "Shared kitchen", "Living room", "Balcony", "Terrace", "Garden", "Laundry room", "Rooftop" ]
  amenities = amenity_names.index_with { |name| Amenity.create!(name: name, category: :amenity) }
                           .merge(shared_names.index_with { |name| Amenity.create!(name: name, category: :shared_space) })

  # ------------------------------------------------------------------
  # Properties (with their amenities, through property_amenities)
  # ------------------------------------------------------------------
  puts "Creating properties..."
  new_property = ->(host, hood, address, type, bedrooms, bathrooms, amenity_list) {
    Property.create!(user: host, neighborhood: hoods.fetch(hood), street_address: address, property_type: type,
                     bedrooms_count: bedrooms, bathrooms_count: bathrooms,
                     amenities: amenity_list.map { |name| amenities.fetch(name) })
  }

  providencia_apt = new_property.call(camila, "Providencia", "Av. Providencia 1650, Depto. 1203", :apartment, 3, 2,
    [ "Wi-Fi", "Washing machine", "Heating", "Elevator", "Concierge", "Shared kitchen", "Living room", "Balcony" ])
  nunoa_house = new_property.call(matias, "Ñuñoa", "Av. Irarrázaval 3150", :house, 5, 3,
    [ "Wi-Fi", "Washing machine", "Heating", "Parking", "Shared kitchen", "Living room", "Garden", "Laundry room" ])
  las_condes_apt = new_property.call(camila, "Las Condes", "Av. Apoquindo 4800, Depto. 702", :apartment, 2, 2,
    [ "Wi-Fi", "Air conditioning", "Elevator", "Concierge", "Gym", "Pool", "Shared kitchen", "Terrace" ])
  lastarria_apt = new_property.call(felipe, "Santiago Centro", "José Victorino Lastarria 90, Depto. 54", :apartment, 3, 1,
    [ "Wi-Fi", "Washing machine", "Elevator", "Shared kitchen", "Living room", "Rooftop" ])
  la_reina_house = new_property.call(valentina, "La Reina", "Av. Príncipe de Gales 6420", :house, 4, 2,
    [ "Wi-Fi", "Washing machine", "Heating", "Parking", "Shared kitchen", "Living room", "Garden", "Terrace" ])
  macul_townhouse = new_property.call(daniela, "Macul", "Av. Macul 2950, Casa 12", :townhouse, 3, 2,
    [ "Wi-Fi", "Washing machine", "Parking", "Shared kitchen", "Living room", "Garden" ])
  san_miguel_apt = new_property.call(daniela, "San Miguel", "Gran Avenida José Miguel Carrera 4400, Depto. 1508", :apartment, 2, 1,
    [ "Wi-Fi", "Elevator", "Gym", "Shared kitchen", "Balcony" ])

  # ------------------------------------------------------------------
  # Listings and their photos
  # ------------------------------------------------------------------
  puts "Creating listings..."
  # Listings that receive applications are created as published (applications require it)
  # and moved to their final state afterwards, as would happen in the real lifecycle.
  new_listing = ->(property, attrs, photos: [], created: 0) {
    listing = property.listings.create!(attrs.merge(created_at: at.call(-created, 10), updated_at: at.call(-created, 10)))
    photos.each_with_index do |(key, alt, caption), position|
      listing.listing_photos.create!(image_url: photo_url.call(photos_by_key.fetch(key)), alt_text: alt, caption: caption, position: position)
    end
    listing
  }

  sunny_room = new_listing.call(providencia_apt, {
    title: "Sunny room near Metro Pedro de Valdivia", status: :published,
    monthly_rent: 420_000, deposit: 420_000, available_from: today + 12, minimum_stay_months: 6,
    furnished: true, private_bathroom: false,
    description: "Bright double room on the 12th floor with a large window facing the Andes. It comes with a queen bed, a desk and a built-in wardrobe.\n\nYou'll share the apartment with two young professionals. Metro Pedro de Valdivia is a five-minute walk away, with supermarkets and cafés on the same block.",
    house_rules: "No smoking inside the apartment.\nQuiet hours from 23:00 to 08:00.\nCleaning of shared spaces rotates weekly."
  }, photos: [ [ :bright_bedroom, "Bright bedroom with a large window and a potted plant", "The room in the afternoon" ],
               [ :open_living, "Shared living room and kitchen with a sofa and a dining table", "Shared living room and kitchen" ] ],
     created: 20)

  master_room = new_listing.call(providencia_apt, {
    title: "Master bedroom with private bathroom", status: :published,
    monthly_rent: 520_000, deposit: 520_000, available_from: today + 20, minimum_stay_months: 12,
    furnished: true, private_bathroom: true,
    description: "The largest room of the apartment, with its own bathroom and a small balcony. Ideal for someone who works from home: it has a desk by the window and fiber internet.",
    house_rules: "No smoking. Overnight guests are fine with notice to the flatmates."
  }, photos: [ [ :cozy_bedroom, "Cozy bedroom with colorful artwork and soft bedding", nil ],
               [ :lounge, "Living room with a grey sofa and a coffee table", "Living room" ] ],
     created: 40)

  courtyard_room = new_listing.call(providencia_apt, {
    title: "Cozy room facing the inner courtyard", status: :draft,
    monthly_rent: 360_000, deposit: 0, available_from: today + 40, minimum_stay_months: 3,
    furnished: false, private_bathroom: false,
    description: "Small and quiet single room facing the building's inner courtyard. Still preparing photos and details."
  }, created: 3)

  family_house_room = new_listing.call(nunoa_house, {
    title: "Big room in a family house in Ñuñoa", status: :published,
    monthly_rent: 380_000, deposit: 380_000, available_from: today + 5, minimum_stay_months: 6,
    furnished: true, private_bathroom: false,
    description: "Spacious room in a two-storey house with a garden, ten minutes from Plaza Ñuñoa. The house has five rooms rented to students and young professionals.\n\nBills (water, electricity, gas and internet) are included in the rent.",
    house_rules: "Pets are welcome after talking with the house.\nEach housemate takes care of the garden one week a month."
  }, photos: [ [ :white_bedroom, "Bedroom with white walls, a double bed and a wooden night table", nil ],
               [ :kitchen, "Bright shared kitchen with white cabinets", "Shared kitchen" ] ],
     created: 18)

  garden_room = new_listing.call(nunoa_house, {
    title: "Garden-view room near Plaza Ñuñoa", status: :published,
    monthly_rent: 400_000, deposit: 400_000, available_from: today + 1, minimum_stay_months: 12,
    furnished: true, private_bathroom: false,
    description: "Ground-floor room with a window onto the garden. Bills included."
  }, photos: [ [ :white_bedroom, "Bedroom with a window onto the garden", nil ] ], created: 80)

  attic_room = new_listing.call(nunoa_house, {
    title: "Attic room with skylight", status: :withdrawn,
    monthly_rent: 330_000, deposit: 330_000, available_from: today + 10, minimum_stay_months: 6,
    furnished: false, private_bathroom: false,
    description: "Attic room with a skylight and sloped ceiling. Withdrawn after a moderator review."
  }, photos: [ [ :interior, "Living area with a sofa, plants and wooden floors", nil ] ], created: 50)

  pool_room = new_listing.call(las_condes_apt, {
    title: "Modern room with pool and gym access", status: :published,
    monthly_rent: 550_000, deposit: 550_000, available_from: today + 15, minimum_stay_months: 12,
    furnished: true, private_bathroom: true,
    description: "Fully furnished room with its own bathroom in a building with a pool, a gym and 24-hour concierge. Two blocks from Metro Escuela Militar.\n\nYou'll share the apartment with one flatmate who works in the area.",
    house_rules: "No parties. Building rules apply to the pool and gym."
  }, photos: [ [ :modern_bedroom, "Modern bedroom with a double bed and bedside lamps", nil ],
               [ :apartment, "Open living room with a sofa and large windows", "Living room" ] ],
     created: 7)

  lastarria_room = new_listing.call(lastarria_apt, {
    title: "Bohemian room in Barrio Lastarria", status: :published,
    monthly_rent: 350_000, deposit: 350_000, available_from: today + 3, minimum_stay_months: 3,
    furnished: true, private_bathroom: false,
    description: "Room in an old building in Barrio Lastarria, surrounded by theatres, bookshops and cafés. Metro Universidad Católica and Cerro Santa Lucía are around the corner.\n\nThe building has a rooftop with views of the city.",
    house_rules: "Quiet hours from midnight. Shared groceries are split monthly."
  }, photos: [ [ :plant_bedroom, "Bedroom with plants and a wooden headboard", nil ],
               [ :living_room, "Living room with a sofa, shelves and a rug", "Living room" ] ],
     created: 25)

  compact_room = new_listing.call(lastarria_apt, {
    title: "Compact room steps from Metro Universidad Católica", status: :published,
    monthly_rent: 290_000, deposit: 290_000, available_from: today + 30, minimum_stay_months: 6,
    furnished: false, private_bathroom: false,
    description: "Single room, good for a student on a budget. Unfurnished, so you can bring your own things."
  }, photos: [ [ :calm_bedroom, "Simple bedroom with a single bed and neutral colors", nil ] ], created: 6)

  la_reina_room = new_listing.call(la_reina_house, {
    title: "Quiet room in La Reina with garden", status: :published,
    monthly_rent: 340_000, deposit: 340_000, available_from: today + 21, minimum_stay_months: 6,
    furnished: true, private_bathroom: false,
    description: "Calm room in a house near Parque Mahuida, perfect for someone who enjoys nature without leaving the city. Buses to Metro Príncipe de Gales stop in front of the house.",
    house_rules: "No smoking. We cook together on Sundays, if you want to join."
  }, photos: [ [ :cozy_bedroom, "Cozy bedroom with soft bedding and artwork", nil ],
               [ :lounge, "Living room with a grey sofa", "Living room" ] ],
     created: 16)

  terrace_room = new_listing.call(la_reina_house, {
    title: "Room with private terrace", status: :published,
    monthly_rent: 390_000, deposit: 390_000, available_from: today + 1, minimum_stay_months: 12,
    furnished: true, private_bathroom: false,
    description: "Upstairs room with direct access to a small terrace."
  }, photos: [ [ :bright_bedroom, "Bright room with a window and plants", nil ] ], created: 120)

  macul_room = new_listing.call(macul_townhouse, {
    title: "Bright room near Metro Macul", status: :published,
    monthly_rent: 310_000, deposit: 310_000, available_from: today + 8, minimum_stay_months: 6,
    furnished: true, private_bathroom: false,
    description: "Room in a townhouse inside a gated community, close to Universidad de Chile's Macul campus and Metro Macul (Line 4).",
    house_rules: "Parking space available for an extra fee."
  }, photos: [ [ :minimal_bedroom, "Minimal bedroom with a made bed and warm natural light", nil ] ], created: 10)

  san_miguel_room = new_listing.call(san_miguel_apt, {
    title: "Room with city views in San Miguel", status: :published,
    monthly_rent: 300_000, deposit: 300_000, available_from: today + 18, minimum_stay_months: 6,
    furnished: true, private_bathroom: false,
    description: "Room on the 15th floor with views of the city, a block from Metro El Llano (Line 2). The building has a gym."
  }, photos: [ [ :wood_bedroom, "Bedroom with wooden furniture and a large bed", nil ] ], created: 4)

  # ------------------------------------------------------------------
  # Applications, visits and reviews
  # ------------------------------------------------------------------
  puts "Creating applications, visits and reviews..."
  apply = ->(listing, seeker, status, sent:, move_in:, stay:, message:) {
    Application.create!(listing: listing, user: seeker, status: status, message: message,
                        desired_move_in_date: move_in, intended_stay_months: stay,
                        created_at: at.call(-sent, 9), updated_at: at.call(-sent, 9))
  }
  visit = ->(application, status, when_at) { application.visits.create!(status: status, scheduled_at: when_at) }
  review = ->(visit_record, rating, comment) {
    Review.create!(visit: visit_record, rating: rating, comment: comment,
                   created_at: visit_record.scheduled_at + 1.day, updated_at: visit_record.scheduled_at + 1.day)
  }

  # Several applications competing for the same room, in every state
  apply.call(sunny_room, tomas, :pending, sent: 2, move_in: today + 15, stay: 12,
             message: "Hi Camila! I'm Tomás, 26, I work as a data analyst in Providencia. I'm tidy, quiet during the week and I love cooking.")
  catalina_sunny = apply.call(sunny_room, catalina, :shortlisted, sent: 9, move_in: today + 15, stay: 6,
             message: "Hello! I'm doing a master's at Universidad de Chile and I'm looking for a calm place close to the metro.")
  visit.call(catalina_sunny, :confirmed, at.call(2, 18))
  benjamin_sunny = apply.call(sunny_room, benjamin, :shortlisted, sent: 12, move_in: today + 20, stay: 12,
             message: "Hi, I'm Benjamín. I'm moving from Concepción for a new job and would love a furnished room near the metro.")
  review.call(visit.call(benjamin_sunny, :completed, at.call(-5, 19)), 4,
              "Bright room and a very well kept building. The kitchen is small for three people, but Camila was very clear about how the house works.")
  apply.call(sunny_room, fernanda, :rejected, sent: 15, move_in: today + 30, stay: 3,
             message: "Hi! I only need the room for three months while I finish an internship.")
  apply.call(sunny_room, joaquin, :withdrawn, sent: 14, move_in: today + 15, stay: 6,
             message: "Hello, I'm Joaquín, a design student. Is the desk included with the room?")

  # Accepting one applicant rejects the others and reserves the listing
  antonia_master = apply.call(master_room, antonia, :accepted, sent: 30, move_in: today + 20, stay: 12,
             message: "Hi Camila, I'm Antonia, an architect working remotely. The private bathroom and the desk are exactly what I need.")
  review.call(visit.call(antonia_master, :completed, at.call(-22, 18, 30)), 5,
              "Even nicer than in the photos. Lots of light, great storage, and Camila answered every question. Can't wait to move in!")
  diego_master = apply.call(master_room, diego, :rejected, sent: 28, move_in: today + 25, stay: 12,
             message: "Hello! I'm Diego, I work at a bank nearby. I'm looking for a long-term place.")
  review.call(visit.call(diego_master, :completed, at.call(-21, 19)), 3,
              "Great room, but the elevator was out of service on the day of the visit and the building's common areas felt a bit neglected.")
  apply.call(master_room, martina, :rejected, sent: 26, move_in: today + 20, stay: 6,
             message: "Hi! Would you consider a six-month stay?")
  master_room.update!(status: :reserved)

  # A rescheduled visit: the host cancelled, and a new visit was proposed and confirmed
  apply.call(family_house_room, martina, :pending, sent: 1, move_in: today + 10, stay: 6,
             message: "Hi Matías, I'm Martina, a nursing student. I'd love to live in a house with a garden.")
  lucas_house = apply.call(family_house_room, lucas, :shortlisted, sent: 10, move_in: today + 5, stay: 6,
             message: "Hi! I'm Lucas, 24, I play in a band but I promise I practice at the studio, not at home.")
  visit.call(lucas_house, :proposed, at.call(3, 17))
  emma_house = apply.call(family_house_room, emma, :shortlisted, sent: 11, move_in: today + 7, stay: 10,
             message: "Hello! I'm Emma, an exchange student from Germany at Universidad de los Andes for two semesters. My Spanish is getting better every day!")
  visit.call(emma_house, :cancelled, at.call(-4, 12))
  visit.call(emma_house, :confirmed, at.call(1, 12))

  # A listing that has already been rented: the tenant moved in weeks ago
  paula_garden = apply.call(garden_room, paula, :accepted, sent: 70, move_in: today - 45, stay: 12,
             message: "Hi, I'm Paula, a teacher at a school in Ñuñoa. A garden view would be a dream.")
  review.call(visit.call(paula_garden, :completed, at.call(-65, 18)), 5,
              "Lovely house and a very friendly group of housemates. Bills included makes life so much easier.")
  apply.call(garden_room, tomas, :rejected, sent: 68, move_in: today - 40, stay: 6,
             message: "Hello! Is the room still available? I could move in next month.")
  garden_room.update!(status: :rented)
  garden_room.update_columns(available_from: today - 45) # moved in before today

  apply.call(pool_room, diego, :pending, sent: 3, move_in: today + 15, stay: 12,
             message: "Hi again Camila! I saw your other listing and this one fits me even better.")
  apply.call(pool_room, emma, :pending, sent: 2, move_in: today + 20, stay: 12,
             message: "Hi! Is the gym open to residents at any time?")

  apply.call(lastarria_room, fernanda, :pending, sent: 4, move_in: today + 5, stay: 4,
             message: "Hi Felipe! Three or four months would be perfect for my internship downtown.")
  joaquin_lastarria = apply.call(lastarria_room, joaquin, :shortlisted, sent: 13, move_in: today + 5, stay: 6,
             message: "Hello! I study design at the GAM area, this room would be ideal.")
  review.call(visit.call(joaquin_lastarria, :completed, at.call(-8, 20)), 4,
              "Charming old building in the best area for going out. The bathroom is shared by three, which is the only downside.")

  martina_reina = apply.call(la_reina_room, martina, :shortlisted, sent: 12, move_in: today + 21, stay: 6,
             message: "Hi Valentina! I love the idea of Sunday lunches.")
  visit.call(martina_reina, :proposed, at.call(4, 11))
  apply.call(la_reina_room, felipe, :pending, sent: 5, move_in: today + 25, stay: 6,
             message: "Hi Valentina, I'm Felipe. I rent out rooms in Lastarria but I'm looking for something quieter for myself.")

  sebastian_terrace = apply.call(terrace_room, sebastian, :accepted, sent: 110, move_in: today - 90, stay: 12,
             message: "Hello! I work from home and a terrace would be perfect for my coffee breaks.")
  review.call(visit.call(sebastian_terrace, :completed, at.call(-100, 17)), 4,
              "Very quiet neighborhood and a beautiful garden. It's a bit far from the metro, so plan your commute.")
  terrace_room.update!(status: :rented)
  terrace_room.update_columns(available_from: today - 90)

  apply.call(macul_room, benjamin, :pending, sent: 1, move_in: today + 10, stay: 6,
             message: "Hi Daniela! I'm also looking at a room in Providencia, but Macul is closer to my new office.")

  # ------------------------------------------------------------------
  # Saved listings and reports
  # ------------------------------------------------------------------
  puts "Creating saved listings and reports..."
  {
    tomas => [ sunny_room, pool_room, lastarria_room ],
    catalina => [ family_house_room ],
    emma => [ sunny_room, la_reina_room ],
    paula => [ macul_room ],
    fernanda => [ compact_room ]
  }.each do |seeker, listings|
    listings.each { |listing| SavedListing.create!(user: seeker, listing: listing) }
  end

  Report.create!(listing: attic_room, user: tomas, reason: :misleading, status: :actioned,
                 details: "The photo shows a living room, not the attic room. The host confirmed the room isn't ready to rent.")
  Report.create!(listing: compact_room, user: diego, reason: :misleading, status: :pending,
                 details: "The room in the photo has a bed, but the listing says it's unfurnished.")
  Report.create!(listing: san_miguel_room, user: fernanda, reason: :fraudulent, status: :pending,
                 details: "Someone claiming to be the host asked me to pay the deposit by bank transfer before any visit.")
  Report.create!(listing: macul_room, user: martina, reason: :other, status: :dismissed,
                 details: "I think the address is wrong, the map shows a different street.")
  Report.create!(listing: family_house_room, user: lucas, reason: :offensive, status: :dismissed,
                 details: "The house rules sounded rude to me.")
end

puts "Done! The database now has:"
[ User, Neighborhood, Amenity, Property, PropertyAmenity, Listing, ListingPhoto,
  Application, Visit, Review, SavedListing, Report ].each do |model|
  puts "  #{model.name.pluralize.ljust(16)} #{model.count}"
end
puts "  Listings by status:     #{Listing.group(:status).count}"
puts "  Applications by status: #{Application.group(:status).count}"
