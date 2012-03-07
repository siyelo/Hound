module ScopesReminders
  extend ActiveSupport::Concern

  LOOK_AHEAD_SECONDS = 59

  module ClassMethods
    ### Named Scopes
    def upcoming
      where("send_at >= ? AND delivered = ?", Time.now, false)
    end

    def completed
      where("delivered = ?", true)
    end

    def sorted
      order("send_at ASC")
    end

    def ready_to_send
      cutoff = Time.now.change(sec: LOOK_AHEAD_SECONDS)
      where("send_at < ? AND delivered = ?", cutoff, false)
    end

    #TODO - refactor: we're diving too far into the user model here
    def with_active_user
      joins(fetched_mail: :user).
        where("users.invitation_token IS NULL OR users.invitation_accepted_at IS NOT NULL")
    end
  end
end

