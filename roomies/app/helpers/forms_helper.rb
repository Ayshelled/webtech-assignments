module FormsHelper
  # Classes for a form control, adding Bootstrap's .is-invalid when the attribute has an error.
  # Pass several attributes when the error can land on either one (neighborhood_id / neighborhood).
  def field_class(form, *attributes, base: "form-control")
    invalid = attributes.any? { |attribute| form.object.errors.include?(attribute) }
    class_names(base, "is-invalid": invalid)
  end

  # The error messages of a field, shown right below it
  def field_errors(form, *attributes)
    messages = attributes.flat_map { |attribute| form.object.errors.full_messages_for(attribute) }
    tag.div(messages.to_sentence, class: "invalid-feedback d-block") if messages.any?
  end

  # Bootstrap alert class for each flash type
  def flash_class(type)
    { "notice" => "success", "alert" => "danger" }.fetch(type.to_s, "info")
  end

  def acting_user_options
    options_from_collection_for_select(User.order(:full_name), :id, :full_name, current_user&.id)
  end
end
