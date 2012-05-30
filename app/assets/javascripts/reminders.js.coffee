# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/

class Reminder
  @hide_reminder_row: (reminder_row) ->
    reminder_row.addClass('hidden')
    reminder_row.prev('tr.reminder').removeClass('active')

(exports ? this).Reminder = Reminder

$(document).ready ->
  if ($('#reminder_body').length > 0)
    $('#reminder_body').tinymce
      theme: "advanced",
      theme_advanced_buttons1: "bold,italic,underline, strikethrough",
      theme_advanced_buttons2: "",
      theme_advanced_buttons3: "",
      theme_advanced_buttons4: "",
      theme_advanced_toolbar_location: "top",
      theme_advanced_toolbar_align: "left"

  $(".reminder").live "click", (event) ->
    event.preventDefault()
    reminder = $(this)
    link     = reminder.find('td a:first')
    reminder_row = reminder.next("tr.reminder_row")

    $('tr.reminder').removeClass('active')
    reminder.addClass('active')

    if (reminder_row.hasClass('hidden'))
      $.getScript(link.attr('href') + ".js")
    else
      Reminder.hide_reminder_row(reminder_row)

  $('#js_cancel').live "click", (event) ->
    event.preventDefault()
    reminder_row = $(this).parents('tr.reminder_row')
    Reminder.hide_reminder_row(reminder_row)

  $('#show_emails').live "click", (event) ->
    event.preventDefault()
    $("#preview_emails").slideToggle()
    $("#all_emails").slideToggle()
