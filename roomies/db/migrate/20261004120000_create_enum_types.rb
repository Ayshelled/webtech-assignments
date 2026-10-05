class CreateEnumTypes < ActiveRecord::Migration[8.0]
  def change
    create_enum :user_role,          %w[member moderator]
    create_enum :property_type,      %w[apartment house studio townhouse]
    create_enum :amenity_category,   %w[amenity shared_space]
    create_enum :listing_status,     %w[draft published reserved rented withdrawn]
    create_enum :application_status, %w[pending shortlisted accepted rejected withdrawn]
    create_enum :visit_status,       %w[proposed confirmed cancelled completed]
    create_enum :report_reason,      %w[fraudulent misleading offensive other]
    create_enum :report_status,      %w[pending dismissed actioned]
  end
end
