# In development, emails (password reset, notifications) are not sent to real
# inboxes: they are saved and listed at http://localhost:3000/letter_opener
if Rails.env.development? && defined?(LetterOpenerWeb)
  Rails.application.config.action_mailer.delivery_method = :letter_opener_web
  Rails.application.config.action_mailer.perform_deliveries = true
end
