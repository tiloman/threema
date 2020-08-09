$(document).on('turbolinks:load', function () {
  $('#group_member_ids').select2({
    theme: "bootstrap",
    language: "de"

    });


    $("#search").on("keyup", function() {
      var value = $(this).val().toLowerCase();
      if (value != "") {
        document.getElementById("allUsersBox").style.display = "block";
      } else {
        document.getElementById("allUsersBox").style.display = "none";
      }
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

//check if user is in list before submit
    $('#new_group').submit(function() {
      if ($('#group_member_ids').length) {
        var select2_form = $('#group_member_ids');
      }

      var selected_now = select2_form.val();
      if (selected_now != null ){
        var members = selected_now.map(x => x);
      } else {
        var members = [];
      }

      var current_user = document.getElementById('current_user_member').innerHTML
      var is_in_group = members.includes(current_user);

      if (is_in_group == false) {
        return confirm("Du bist aktuell nicht Teil der zu erstellenden Gruppe. Falls das so gewollt ist, bestätige mit 'OK'. \nAndernfalls klicke auf 'Abbrechen' und füge dich hinzu, bevor du die Gruppe erstellst.");
      }

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
