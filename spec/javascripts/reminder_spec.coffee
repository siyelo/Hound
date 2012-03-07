describe "Reminder", ->
  it "updates a reminder", ->
    params = { reminder_mail : { 'delivered' : 'false' }}
    expect(Reminder.get_params_for_update_delivered('false')).toEqual(params)

  it "updates a reminder to true", ->
    params = { reminder_mail : { 'delivered' : 'true' }}
    expect(Reminder.get_params_for_update_delivered('true')).toEqual(params)

