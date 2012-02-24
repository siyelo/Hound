module UserMailerHelper
  include ActionView::Helpers::SanitizeHelper

  def body_changes(reminder)
      Diffy::Diff.new(reminder.body_change[0],
                      reminder.body_change[1]).to_s(:text).html_safe
  end

end

