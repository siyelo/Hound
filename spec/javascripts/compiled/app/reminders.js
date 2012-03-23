(function() {
  var Reminder;

  Reminder = (function() {

    function Reminder() {}

    Reminder.get_params_for_update_delivered = function(is_checked) {
      return {
        reminder_mail: {
          'delivered': is_checked
        }
      };
    };

    Reminder.validate_cc_emails = function(value) {
      var email, emails, i, regex, valid;
      regex = /^([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})$/i;
      emails = value.trim().split(/[,;]\s*/);
      valid = true;
      for (i in emails) {
        email = emails[i];
        if (email.trim() !== '') valid = valid && regex.test(email);
      }
      return valid;
    };

    Reminder.mark_as_complete = function(form, element) {
      return $.ajax({
        type: 'PUT',
        url: form.action,
        data: Reminder.get_params_for_update_delivered(element.is(':checked')),
        dataType: 'json',
        complete: function() {
          return Reminder.mark_as_complete_callback(element);
        }
      });
    };

    Reminder.mark_as_complete_callback = function(element) {
      element.attr("disabled", false);
      $('.status').show();
      $('.status').text('Saving changes');
      $('.status').fadeOut(2000);
      if (element.closest("tr").hasClass("completed_row")) {
        return element.closest("tr").removeClass("completed_row");
      } else {
        return element.closest("tr").addClass("completed_row");
      }
    };

    return Reminder;

  })();

  (typeof exports !== "undefined" && exports !== null ? exports : this).Reminder = Reminder;

  $(document).ready(function() {
    if (($('#reminder_body').length)) {
      $('#reminder_body').tinymce({
        theme: "advanced",
        theme_advanced_buttons1: "bold,italic,underline, strikethrough",
        theme_advanced_buttons2: "",
        theme_advanced_buttons3: "",
        theme_advanced_buttons4: "",
        theme_advanced_toolbar_location: "top",
        theme_advanced_toolbar_align: "left"
      });
    }
    $(".subject_link").live("click", function() {
      return $('.inline_reminder').hide();
    });
    $(".mark_as_complete").live("click", function() {
      var element, form;
      element = $(this);
      element.attr("disabled", true);
      form = element.parent("td").siblings("form")[0];
      return Reminder.mark_as_complete(form, element);
    });
    $('.js_submit').live("click", function() {
      $('.errors').html('');
      if (!Reminder.validate_cc_emails($('#reminder_mail_cc').val())) {
        $('.errors').html('<h3>Reminder could not be saved!</h3><p>Not all cc addresses are properly formed.</p><hr/>');
        return event.preventDefault();
      }
    });
    return $('#js_cancel').live("click", function() {
      $('.inline_reminder').hide();
      return false;
    });
  });

}).call(this);
