

$(document).on('turbolinks:load', function () {
  $('#category').select2({
    theme: "bootstrap",
    language: "de"
    });

    $('#category').on('change', function(){
      if (this[0].selected) {
        $('#category').clear
      }
    });
})
