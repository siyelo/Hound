(function() {

  $(document).ready(function() {
    $("#user_timezone").chosen();
    $("#add_alias").live("click", function() {
      return $(this).disabled;
    });
    return $(".delete_link").live("click", function() {
      var element;
      event.preventDefault();
      element = $(this).parent('li');
      if (confirm('Are you sure?')) {
        return $.ajax({
          type: 'DELETE',
          url: $(this).attr('data-link'),
          success: function(data, textStatus, data) {
            return element.remove();
          }
        });
      }
    });
  });

}).call(this);
