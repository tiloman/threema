$(document).on('turbolinks:load', function () {


  $( "#feed_container" ).hide();

  $( "#toggle_feeds" ).click(function() {
    $( "#feed_container" ).toggle( "slow", function() {
      // Animation complete.
    });
  });
})
