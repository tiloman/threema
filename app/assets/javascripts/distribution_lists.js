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
      $( "#list_container" ).toggle( "slow", function() {
        // Animation complete.
      });
    });

})

// function remove_add_btn_from_table(id) {
//   button = document.getElementById(id)
//   button.innerHTML ='<i class="fas fa-user-plus"></i>'
//   button.classList.add('btn-primary')
//   button.classList.remove('btn-secondary')
// }
//
//
// function addMemberToSelect(new_member, button) {
//   var selected_now = $('#distribution_list_member_ids').val();
//   if (selected_now != null ){
//     var members = selected_now.map(x => x);
//   } else {
//     var members = [];
//   }
//
//   if (button.classList.contains("btn-primary")) {
//     members.push(new_member);
//     $('#distribution_list_member_ids').val(members); // Select the option with a value of '1'
//     $('#distribution_list_member_ids').trigger('change'); // Notify any JS components that the value changed
//     //button.style.display = "none"
//     button.innerHTML ='<i class="fas fa-user-minus"></i>'
//     button.classList.add('btn-secondary')
//     button.classList.remove('btn-primary')
//   } else {
//     var index = members.indexOf(new_member);
//     members.splice(index, 1);
//     $('#distribution_list_member_ids').val(members); // Select the option with a value of '1'
//     $('#distribution_list_member_ids').trigger('change'); // Notify any JS components that the value changed
//     //button.style.display = "none"
//     button.innerHTML ='<i class="fas fa-user-plus"></i>'
//     button.classList.add('btn-primary')
//     button.classList.remove('btn-secondary')
//   }
// }



// function add_me(user) {
//   let button = document.getElementById(user);
//   addMemberToSelect(user, button)
// }

//Auswahl löschen
// function unSelectAll(){
//   let usersTable = document.getElementById('usersTable');
//   let checkboxes = usersTable.querySelectorAll('input[type=checkbox]');
//   let num = checkboxes.length;
//
//   for (let i=0; i<num; i++) {
//     checkboxes[i].checked = false;
//
//      }
// }
