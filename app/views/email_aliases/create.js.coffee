$('#email_aliases').html("<%=j render current_user.email_aliases %>")
$('#email_alias_email').val ''
<% if @email_alias.errors.any? %>
$('.status').show()
$('.status').text('Email already in use')
$('.status').fadeOut(4000)
<% end %>
