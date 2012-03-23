(function() {

  describe("Reminder", function() {
    it("updates a reminder", function() {
      var params;
      params = {
        reminder_mail: {
          'delivered': 'false'
        }
      };
      return expect(Reminder.get_params_for_update_delivered('false')).toEqual(params);
    });
    it("updates a reminder to true", function() {
      var params;
      params = {
        reminder_mail: {
          'delivered': 'true'
        }
      };
      return expect(Reminder.get_params_for_update_delivered('true')).toEqual(params);
    });
    describe("validate_cc_emails", function() {
      it("returns true if all emails in a comma seperated string are valid", function() {
        var email_string;
        email_string = '1@1.com, 2@2.com';
        return expect(Reminder.validate_cc_emails(email_string)).toEqual(true);
      });
      it("returns false if >1 emails in comma seperated string is not valid", function() {
        var email_string;
        email_string = '1, 2@2.com';
        expect(Reminder.validate_cc_emails(email_string)).toEqual(false);
        email_string = '1@1.com, 2.com';
        expect(Reminder.validate_cc_emails(email_string)).toEqual(false);
        email_string = '1@com, 2.com';
        return expect(Reminder.validate_cc_emails(email_string)).toEqual(false);
      });
      it("strings leading an trailing spaces from string", function() {
        var email_string;
        email_string = ' 1@1.com, 2@2.com ';
        return expect(Reminder.validate_cc_emails(email_string)).toEqual(true);
      });
      return it("parses both comma and semi-colon seperated strings", function() {
        var email_string;
        email_string = '1@1.com, 2@2.com; 3@3.com';
        return expect(Reminder.validate_cc_emails(email_string)).toEqual(true);
      });
    });
    return describe("mark_as_complete", function() {
      it("should make a correctly formed AJAX request to the form's URL", function() {
        var element, form;
        form = {};
        form.action = 'form_action';
        element = {};
        element.is = function(e) {
          return true;
        };
        spyOn($, 'ajax');
        Reminder.mark_as_complete(form, element);
        expect($.ajax.mostRecentCall.args[0]["url"]).toEqual('form_action');
        expect($.ajax.mostRecentCall.args[0]["type"]).toEqual('PUT');
        expect($.ajax.mostRecentCall.args[0]["dataType"]).toEqual('json');
        return expect($.ajax.mostRecentCall.args[0]["data"]).toEqual({
          reminder_mail: {
            'delivered': true
          }
        });
      });
      return it("should execute callback on successful completion of AJAX request", function() {
        var element, form;
        form = {};
        form.action = 'form_action';
        element = {};
        element.is = function(e) {
          return true;
        };
        spyOn($, "ajax").andCallFake(function(options) {
          return options.complete();
        });
        spyOn(Reminder, 'mark_as_complete_callback');
        Reminder.mark_as_complete(form, element);
        return expect(Reminder.mark_as_complete_callback).toHaveBeenCalled();
      });
    });
  });

}).call(this);
