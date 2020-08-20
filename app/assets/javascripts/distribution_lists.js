$(document).on('turbolinks:load', function () {
  $('#distribution_list_member_ids').select2({
    theme: "bootstrap",
    language: "de"

    });


    $("#search").on("keyup", function() {
      var value = $(this).val().toLowerCase();
      $("#usersTable tr").filter(function() {
        $(this).toggle($(this).text().toLowerCase().indexOf(value) > -1);
      });
    });

    $('#distribution_list_member_ids').on("select2:unselect", function (e) { remove_add_btn_from_table(e.params.data.id) });

    var selected = $('#distribution_list_member_ids').val();
    for (var i in selected) {
      btn = document.getElementById(selected[i]);
      btn.innerHTML ='<i class="fas fa-user-minus"></i>'
      btn.classList.add('btn-secondary')
      btn.classList.remove('btn-primary')
    }

    $( "#list_container" ).hide();

    $( "#toggle_lists" ).click(function() {
      $( "#list_container" ).toggle( "fast", function() {
        // Animation complete.
      });
    });

})
