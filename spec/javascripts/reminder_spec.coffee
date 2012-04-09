describe "Reminder", ->
  it "updates a reminder", ->
    params = { reminder : { 'delivered' : 'false' }}
    expect(Reminder.get_params_for_update_delivered('false')).toEqual(params)

  it "updates a reminder to true", ->
    params = { reminder : { 'delivered' : 'true' }}
    expect(Reminder.get_params_for_update_delivered('true')).toEqual(params)

  describe "validate_cc_emails", ->
    it "returns true if all emails in a comma seperated string are valid", ->
      email_string = '1@1.com, 2@2.com'
      expect(Reminder.validate_cc_emails(email_string)).toEqual(true)

    it "returns false if >1 emails in comma seperated string is not valid", ->
      email_string = '1, 2@2.com'
      expect(Reminder.validate_cc_emails(email_string)).toEqual(false)
      email_string = '1@1.com, 2.com'
      expect(Reminder.validate_cc_emails(email_string)).toEqual(false)
      email_string = '1@com, 2.com'
      expect(Reminder.validate_cc_emails(email_string)).toEqual(false)

    it "strings leading an trailing spaces from string", ->
      email_string = ' 1@1.com, 2@2.com '
      expect(Reminder.validate_cc_emails(email_string)).toEqual(true)

    it "parses both comma and semi-colon seperated strings", ->
      email_string = '1@1.com, 2@2.com; 3@3.com'
      expect(Reminder.validate_cc_emails(email_string)).toEqual(true)
