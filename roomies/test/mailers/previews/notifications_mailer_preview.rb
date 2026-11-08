# Preview the notification emails at http://localhost:3000/rails/mailers/notifications_mailer
class NotificationsMailerPreview < ActionMailer::Preview
  def new_application
    NotificationsMailer.with(application: Application.first).new_application
  end

  def application_answered
    application = Application.find_by(status: %w[shortlisted accepted rejected]) || Application.first
    NotificationsMailer.with(application: application).application_answered
  end
end
