# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/

class Reminder
  @get_params_for_update_delivered: (is_checked) ->
    { reminder_mail: { 'delivered': is_checked } }

  @validate_cc_emails: (value)   ->
    regex = /^([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})$/i
    emails = value.trim().split(/[,;]\s*/)
    valid = true
    for i of emails
      email = emails[i]
      unless email.trim() == ''
        valid = valid and regex.test(email)
    return valid

  @mark_as_complete: (form, element) ->
    $.ajax
      type: 'PUT'
      url: form.action
      data: Reminder.get_params_for_update_delivered element.is(':checked')
      dataType: 'json'
      complete: ->
        Reminder.mark_as_complete_callback(element)

  @mark_as_complete_callback: (element) ->
      element.attr("disabled", false)
      $('.status').show()
      $('.status').text('Saving changes')
      $('.status').fadeOut(2000)
      if element.closest("tr").hasClass("completed_row")
        element.closest("tr").removeClass "completed_row"
      else
        element.closest("tr").addClass "completed_row"

(exports ? this).Reminder = Reminder

$(document).ready ->
  if ($('#reminder_body').length)
    $('#reminder_body').tinymce
      theme: "advanced",
      theme_advanced_buttons1: "bold,italic,underline, strikethrough",
      theme_advanced_buttons2: "",
      theme_advanced_buttons3: "",
      theme_advanced_buttons4: "",
      theme_advanced_toolbar_location: "top",
      theme_advanced_toolbar_align: "left"

  $(".subject_link").live "click", ->
    $('.inline_reminder').hide()

  $(".mark_as_complete").live "click", ->
    element = $(this)
    element.attr("disabled", true)
    form = element.parent("td").siblings("form")[0]
    Reminder.mark_as_complete(form, element)

  #Validate the form of the cc email addresses before submitting
  $('.js_submit').live "click", ->
    $('.errors').html('')
    unless Reminder.validate_cc_emails($('#reminder_mail_cc').val())
      $('.errors').html('<h3>Reminder could not be saved!</h3><p>Not all cc addresses are properly formed.</p><hr/>')
      event.preventDefault()

  $('#js_cancel').live "click", ->
    $('.inline_reminder').hide()
    return false
