# Bootstrap marks invalid fields with .is-invalid (see FormsHelper), so Rails
# doesn't need to wrap them in its own <div class="field_with_errors">.
ActionView::Base.field_error_proc = proc { |html_tag, _instance| html_tag }
