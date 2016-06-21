// Script to ensure the timeliness of the displayed algorithm statues.
function status_updater() {
  // Iterate over each status
  $('span').each(function(){
    if($(this) && $(this).attr('id') && $(this).attr('id').match(/status_\d+/) ) {
      var id = $(this).attr('id').match(/\d+/)
      var update = false; // Don't rerun script per default.
      // Request newest status.
      $.ajax({
        type: "GET",
         contentType: "application/json; charset=utf-8",
         dataType: 'json',
         url: '/algorithms/' + id + '/status',
         success: function(data) {
           // If the status code on the page is not the same as the new one we received, update the page.
           if($('#status_' + id).data('statuscode') != data['status_code']) {
             location.reload();
           }
           // If the status code will switch soon, run the update loop later again.
           if(data['status_code'] == '50' || // Validating
              data['status_code'] == '100' || // Creating
              data['status_code'] == '110') { // Testing
             update = true;
           }
         },
         complete: function() {
           // If necessary, run script later again.
           if(update) {
             setTimeout(status_updater, 5000);
           }
         }
       });
     }
   });
}

// Only run the script on the algorithm list (index page).
$('.algorithms.index').ready(status_updater);
$('.algorithms.index').on('page:load', status_updater);
