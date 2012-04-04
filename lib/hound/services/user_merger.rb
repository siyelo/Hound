module Hound
  class UserMerger

    def perform(primary_user, secondary_user)
      @primary_user = primary_user
      @secondary_user = secondary_user

      begin
        ActiveRecord::Base.transaction do
          merge_users!
          delete_secondary_user!
          @primary_user.email_aliases.new(email: @secondary_user.email).save!
        end
      rescue ActiveRecord::ActiveRecordError => e
        false
      end
    end

    private

    def merge_users!
      merge_fetched_mails!
      merge_email_aliases!
    end

    def merge_fetched_mails!
      @secondary_user.fetched_mails.each do |fm|
        fm.user = @primary_user
        fm.save!
      end
    end

    def merge_email_aliases!
      @secondary_user.email_aliases.each do |ea|
        ea.user = @primary_user
        ea.save!
      end
    end

    def delete_secondary_user!
      @secondary_user.reload
      @secondary_user.destroy
    end

  end
end
