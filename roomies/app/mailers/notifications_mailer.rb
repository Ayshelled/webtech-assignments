# The emails that tell each side of an application what happened. They are sent
# from the controllers with deliver_later, so Active Job delivers them in the
# background and the page doesn't wait for the email to go out.
class NotificationsMailer < ApplicationMailer
  # To the host: someone applied to one of their rooms
  def new_application
    @application = params[:application]
    @listing = @application.listing
    @host = @listing.property.user

    mail to: @host.email_address,
         subject: "New application for #{@listing.title}"
  end

  # To the seeker: the host shortlisted, accepted or rejected their application
  # (accepting one also rejects the others, and each of them gets this email)
  def application_answered
    @application = params[:application]
    @listing = @application.listing

    subjects = {
      "shortlisted" => "You are on the shortlist for #{@listing.title}",
      "accepted"    => "Your application for #{@listing.title} was accepted",
      "rejected"    => "News about your application for #{@listing.title}"
    }
    mail to: @application.user.email_address,
         subject: subjects.fetch(@application.status, "Your application for #{@listing.title} changed")
  end
end
