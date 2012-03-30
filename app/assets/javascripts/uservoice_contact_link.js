$('.js_uservoice_link').click(function(event){
  UserVoice.showPopupWidget();
  event.preventDefault(); // Prevent link from following its href
});
