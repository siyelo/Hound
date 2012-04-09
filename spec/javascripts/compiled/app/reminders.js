(function() {
  var Reminder;

  Reminder = (function() {

    function Reminder() {}

    Reminder.get_params_for_update_delivered = function(is_checked) {
      return {
        reminder: {
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

    Reminder.hide_reminder_row = function(reminder_row) {
      reminder_row.addClass('hidden');
      return reminder_row.prev('tr.reminder').removeClass('active');
    };

    return Reminder;

  })();

  (typeof exports !== "undefined" && exports !== null ? exports : this).Reminder = Reminder;

  $(document).ready(function() {
    if ($('#reminder_body').length > 0) {
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
    $(".reminder").live("click", function(event) {
      var link, reminder, reminder_row;
      event.preventDefault();
      reminder = $(this);
      link = reminder.find('td a:first');
      reminder_row = reminder.next("tr.reminder_row");
      $('tr.reminder').removeClass('active');
      reminder.addClass('active');
      if (reminder_row.hasClass('hidden')) {
        return $.getScript(link.attr('href') + ".js");
      } else {
        return Reminder.hide_reminder_row(reminder_row);
      }
    });
    $('.js_submit').live("click", function(event) {
      var element, error, errors_box;
      element = $(this);
      errors_box = element.parents('.reminder_row').find('.errors');
      if (!Reminder.validate_cc_emails($('#reminder_other_recipients').val())) {
        error = $('<li/>').text('Not all Cc addresses are well formatted');
        errors_box.html('').append(error);
        return event.preventDefault();
      }
    });
    return $('#js_cancel').live("click", function(event) {
      var reminder_row;
      event.preventDefault();
      reminder_row = $(this).parents('tr.reminder_row');
      return Reminder.hide_reminder_row(reminder_row);
    });
  });

}).call(this);
