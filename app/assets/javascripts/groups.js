$(document).on('turbolinks:load', function () {
  $('#group_member_ids').select2({
    theme: "bootstrap",
    language: "de"

    });


    $("#search").on("keyup", function() {
      var value = $(this).val().toLowerCase();
      $("#usersTable tr").filter(function() {
        $(this).toggle($(this).text().toLowerCase().indexOf(value) > -1);
      });
    });

    $('#group_member_ids').on("select2:unselect", function (e) { remove_add_btn_from_table(e.params.data.id) });

    var selected = $('#group_member_ids').val();
    for (var i in selected) {
      btn = document.getElementById(selected[i]);
      btn.innerHTML ='<i class="fas fa-user-minus"></i>'
      btn.classList.add('btn-secondary')
      btn.classList.remove('btn-primary')
    }

    $( "#group_container" ).hide()
    $( "#toggle_groups" ).click(function() {
      $( "#group_container" ).toggle( "fast", function() {
        // Animation complete.
      });
    });
})


function remove_add_btn_from_table(id) {
  button = document.getElementById(id)
  button.innerHTML ='<i class="fas fa-user-plus"></i>'
  button.classList.add('btn-primary')
  button.classList.remove('btn-secondary')
}


function addMemberToSelect(new_member, button) {
  if ($('#group_member_ids').length) {
    var select2_form = $('#group_member_ids');
  }
  else if ($('#distribution_list_member_ids').length) {
    var select2_form = $('#distribution_list_member_ids');
  }

  var selected_now = select2_form.val();
  if (selected_now != null ){
    var members = selected_now.map(x => x);
  } else {
    var members = [];
  }

  if (button.classList.contains("btn-primary")) {
    members.push(new_member);
    select2_form.val(members); // Select the option with a value of '1'
    select2_form.trigger('change'); // Notify any JS components that the value changed
    button.innerHTML ='<i class="fas fa-user-minus"></i>'
    button.classList.add('btn-secondary')
    button.classList.remove('btn-primary')
  } else {
    var index = members.indexOf(new_member);
    members.splice(index, 1);
    select2_form.val(members); // Select the option with a value of '1'
    select2_form.trigger('change'); // Notify any JS components that the value changed
    button.innerHTML ='<i class="fas fa-user-plus"></i>'
    button.classList.add('btn-primary')
    button.classList.remove('btn-secondary')
  }



}


//alle Checkboxen selektieren

function selectAll(checkbox){
let selectAllBox = document.getElementById("allUsersBox");
let usersTable = document.getElementById("usersTable");
let checkboxes = usersTable.getElementsByClassName('user_checkbox');
let searchInput = document.getElementById('search').value;
let num = checkboxes.length;


  if (selectAllBox.checked == true) {
    //wenn etwas eingegeben wurde in das Suchfeld
    if (searchInput != '') {
        let value = searchInput.toLowerCase();

        $("#usersTable tr").filter(function() {

           if(this.style.display != 'none') {
             //this.childNodes[0].childNodes[0].checked = true;
             addMemberToSelect(this.children[0].children[0].id, this.children[0].children[0])
           }
        });

    } else {
    //alle Felder werden selektiert
    if (num > 300) {
      alert("Mehr als 300 Personen ausgewählt. Das kann ein bisschen dauern...")
    }
    for (var i=0; i<num; i++) {
        //checkboxes[i].checked = true;
        addMemberToSelect(checkboxes[i].id, checkboxes[i])
      }
    }

  } else {
  //keins wird selektiert
  if ($('#group_member_ids').length) {
    var select2_form = $('#group_member_ids');
  }
  else if ($('#distribution_list_member_ids').length) {
    var select2_form = $('#distribution_list_member_ids');
  }
  var selected_now = select2_form.val();
  var members = [];
  select2_form.val(members); // Select the option with a value of '1'
  select2_form.trigger('change'); // Notify any JS components that the value changed
    for (var i=0; i<num; i++) {
      //checkboxes[i].checked = false;
      remove_add_btn_from_table(checkboxes[i].id)
       }
  }

}


function add_me(user) {
  let button = document.getElementById(user);
  addMemberToSelect(user, button)
}



$(document).on('turbolinks:load', function () {
  if (document.querySelector('.custom-file')){
    document.querySelector('.custom-file').addEventListener('change',function(e){
      var fileName = document.getElementById("inputGroupFile01").files[0].name;
      var nextSibling = e.target.nextElementSibling
      nextSibling.innerText = fileName
    })
  }


})


// function sortUsersTable(n) {
//   var table, rows, switching, i, x, y, shouldSwitch, dir, switchcount = 0;
//   table = document.getElementById("usersTable");
//   switching = true;
//   // Set the sorting direction to ascending:
//   dir = "asc";
//   /* Make a loop that will continue until
//   no switching has been done: */
//   while (switching) {
//     // Start by saying: no switching is done:
//     switching = false;
//     rows = table.rows;
//     /* Loop through all table rows (except the
//     first, which contains table headers): */
//     for (i = 1; i < (rows.length - 1); i++) {
//       // Start by saying there should be no switching:
//       shouldSwitch = false;
//       /* Get the two elements you want to compare,
//       one from current row and one from the next: */
//       x = rows[i].getElementsByTagName("TD")[n];
//       y = rows[i + 1].getElementsByTagName("TD")[n];
//       /* Check if the two rows should switch place,
//       based on the direction, asc or desc: */
//       if (dir == "asc") {
//         if (x.innerHTML.toLowerCase() > y.innerHTML.toLowerCase()) {
//           // If so, mark as a switch and break the loop:
//           shouldSwitch = true;
//           break;
//         }
//       } else if (dir == "desc") {
//         if (x.innerHTML.toLowerCase() < y.innerHTML.toLowerCase()) {
//           // If so, mark as a switch and break the loop:
//           shouldSwitch = true;
//           break;
//         }
//       }
//     }
//     if (shouldSwitch) {
//       /* If a switch has been marked, make the switch
//       and mark that a switch has been done: */
//       rows[i].parentNode.insertBefore(rows[i + 1], rows[i]);
//       switching = true;
//       // Each time a switch is done, increase this count by 1:
//       switchcount ++;
//     } else {
//       /* If no switching has been done AND the direction is "asc",
//       set the direction to "desc" and run the while loop again. */
//       if (switchcount == 0 && dir == "asc") {
//         dir = "desc";
//         switching = true;
//       }
//     }
//   }
// }
