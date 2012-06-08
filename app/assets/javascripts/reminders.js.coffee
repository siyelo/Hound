# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/

class Reminder
  @hide_reminder_body: (reminderBody) ->
    reminderBody.addClass('hidden')
    reminderBody.prev('tr.js_reminder_title').removeClass('active')

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

  $(".js_reminder_title").live "click", (event) ->
    event.preventDefault()
    reminderTitle = $(this)
    link     = reminderTitle.find('td a:first')
    reminderBody = reminderTitle.next("tr.js_reminder_body")

    $('tr.js_reminder_title').removeClass('active')
    reminderTitle.addClass('active')

    if (reminderBody.hasClass('hidden'))
      $.getScript(link.attr('href') + ".js")
    else
      Reminder.hide_reminder_body(reminderBody)

  $('#js_cancel').live "click", (event) ->
    event.preventDefault()
    reminderBody = $(this).parents('tr.js_reminder_body')
    Reminder.hide_reminder_body(reminderBody)

  $('#show_emails').live "click", (event) ->
    event.preventDefault()
    $("#preview_emails").slideToggle()
    $("#all_emails").slideToggle()
