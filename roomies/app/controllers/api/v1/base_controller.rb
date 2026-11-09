# Base of the public JSON API (version 1, under /api/v1). It needs no session:
# it only exposes what a visitor can already see, and never personal data.
#
# Every error answers with the same structure and the matching HTTP status:
#   { "error": { "status": 404, "message": "...", "details": { ... } } }
module Api
  module V1
    class BaseController < ActionController::API
      # Pundit decides what is public: the same ListingPolicy::Scope the web pages
      # use, resolved for a visitor (no current user)
      include Pundit::Authorization

      # API controllers don't load every helper: the JSON views need these
      helper ApiHelper

      rescue_from ActiveRecord::RecordNotFound do
        render_error :not_found, "#{controller_name.singularize.humanize} not found"
      end

      private

      # The API is anonymous: policies always answer as for a visitor
      def pundit_user = nil

      def render_error(status, message, details = nil)
        code = Rack::Utils.status_code(status)
        render json: { error: { status: code, message: message, details: details }.compact }, status: status
      end
    end
  end
end
