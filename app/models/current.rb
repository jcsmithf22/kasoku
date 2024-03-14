class Current < ActiveSupport::CurrentAttributes
  attribute :user, :app_session, :organization

  # Could also delegate the user to app_session as such:
  # delegate :user, to: :app_session, allow_nil: true
end
