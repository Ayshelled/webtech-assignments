# Roomies — Design Decisions

## Entities introduced beyond the project description

- **users**: one table for every account, with a `role` enum (`member` / `moderator`) only. Host and Seeker are not roles — as settled in the user stories, they're the same Member seen from two sides of a listing — so the enum doesn't need them.
- **neighborhoods**: its own entity (`name`, `city`) instead of free text on `properties`, because the brief has moderators "managing the neighborhood... catalogs" — implying a fixed, curated list hosts pick from, not something they type.
- **amenities**: same reasoning as neighborhoods (a moderated catalog), and we merged "amenities" and "shared spaces" — two separate attributes the brief lists for a property — into this one table, distinguished by a `category` enum (`amenity` / `shared_space`). Both are just togglable features of a property that moderators curate.
- **property_amenities** and **saved_listings**: join tables required by the many-to-many relationships (property↔amenities, member↔saved listings) that the brief describes but doesn't name.
- **listing_photos**: the brief only says a listing "carries photographs"; we gave photos their own table with `position` and `alt_text` so a listing can hold several ordered photos and each one carries the alt text the accessibility requirements ask for.
- **visits**: described narratively in the brief, we made it its own entity with a `visit_status` (`proposed → confirmed/cancelled → completed`) tied to one application, so the visit's state machine is independent of the application's own status.
- **reports**: named in the brief, but we added `report_reason` (`fraudulent` / `misleading` / `offensive` / `other`) and `report_status` (`pending` / `dismissed` / `actioned`) so moderators have an actual triage workflow, not just a flag.

## Listing lifecycle

A single `listing_status` enum on `listings`: `draft → published → reserved → rented`, with `withdrawn` reachable from `draft` or `published`. This is a direct 1:1 mapping of the five states in the brief's "Listing Lifecycle" section — a query on one column tells us whether a listing is open for applications.

## Application lifecycle

An `application_status` enum on `applications`: `pending → shortlisted → accepted` / `rejected`, with `withdrawn` reachable from `pending` or `shortlisted`. The unique index on `(listing_id, user_id)` enforces "a seeker may not apply twice to the same listing" at the database level.

Two other rules from the brief — a seeker can't apply to their own listing, and can't apply to a listing that isn't published — depend on comparing rows across tables (`listings.user_id` via `properties`, and `listings.status`), so a schema constraint can't express them. We're treating both as application-level validations for Assignment 2, not as anything visible in the diagram.

The "accept exactly one applicant" rule (accepting one application rejects every other pending/shortlisted one on the same listing and moves the listing to `reserved`, all atomically) is the same kind of case: no relational constraint can say "at most one accepted row per `listing_id`" while still keeping the historical rejected/withdrawn rows around. We're treating this as a transaction in the Rails service layer later, not a DB-level invariant now.

## Assumptions

- A **review belongs to a visit**, not directly to a user+property pair (`reviews.visit_id` is unique). This is what enforces "one review per completed visit" for free, and reflects that a review is about a specific stay, not a standing relationship with the property.
- A **visit reschedule creates a new row** rather than editing the existing one in place, so the application keeps a full history of proposed and cancelled slots. The brief doesn't settle this either way.
- **Removing a review** (a moderator power) is assumed to be a hard delete for now — there's no `deleted_at` or status column on `reviews` to keep a moderated-away review as a record. We may revisit this if a later assignment expects auditability.
- **Deposit defaults to 0**, assuming it's optional rather than a mandatory charge.
- **Location of the App**, in this proyect we've made the assumption that, even though it's in english, the app operates for user in Santiago de Chile. Hence, we've also assumed the app's currency is Chilean Pesos.
- **For accessing the website**, it's assumed that the assignment does not need the use of GitHub Pages to host the website. It is assumed that to run the website, the user launches it on their own accord (for example, through live server).

## Changes since Assignment 1

Writing the migrations for Assignment 2 led to a few changes in the model. The updated source is [`Domain-Model.dbml`](Domain-Model.dbml).

- **`listing_photos.image_url` added** (`varchar(500)`, not null). In Assignment 1 a photo only had `caption`, `alt_text` and `position`, which left nothing to display. Each photo now points to an image URL, and the model also requires `alt_text`, as the accessibility requirements ask. Uploading files (Active Storage) is left for the assignment that introduces forms.
- **No Action Text for `description` and `house_rules`.** The Assignment 1 diagram said both would be managed as rich text. Nothing is editable in this assignment, so they stay plain `text` columns. We can move them to Action Text once hosts can write them through a form.
- **Database `CHECK` constraints added** beyond what the diagram showed: positive bedroom and bathroom counts, a positive rent, a non-negative deposit and photo position, a minimum stay and intended stay of at least one month, and a rating between 1 and 5. The same rules are also model validations, so the user gets a readable error message instead of a database exception.
- **Rules that span tables are validations, not constraints**, as anticipated in Assignment 1: a seeker can't apply to their own listing or to a listing that isn't published, a review requires a completed visit, a visit must be scheduled after its application was created, and a listing's availability date can't be in the past.
- **Running the site:** the landing page is no longer opened with Live Server. It is now the root route of the Rails application (see the README).
