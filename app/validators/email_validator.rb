class EmailValidator < ActiveModel::Validator
  def validate(record)
    if should_validate(record) && User.find_by_email_or_alias(record.email)
      unless record.errors[:email].include? 'has already been taken'
          record.errors.add(:email, "is not unique")
      end
    end
  end

  private

  def should_validate(record)
    record.new_record? || record.email_changed?
  end
end
