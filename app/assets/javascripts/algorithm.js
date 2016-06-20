function status_updater() {
  $('span').each(function(){
    if($(this) && $(this).attr('id') && $(this).attr('id').match(/status_\d+/) ) {
      var id = $(this).attr('id').match(/\d+/)
      var update = false;
      $.ajax({
        type: "GET",
         contentType: "application/json; charset=utf-8",
         dataType: 'json',
         url: '/algorithms/' + id + '/status',
         success: function(data) {
           if($('#status_' + id).text() != 'published' &&
              $('#status_' + id).text() != 'error' &&
              $('#status_' + id).text() != 'connection_error' &&
              $('#status_' + id).text() != 'validation_error') {
             if(data['status'] == 'published' ||
                data['status'] == 'error' ||
                data['status'] == 'connection_error' ||
                data['status'] == 'validation_error') {
               location.reload();
             }
           }
           $('#status_' + id).text(data['status']);
           if(data['status_message']) {
             $('#status_message_' + id).text(data['status_message']);
           } else {
             $('#status_message_' + id).text('');
           }
           if(data['status'] == 'creating' || data['status'] == 'validating' || data['status'] == 'testing') {
             update = true;
           }
         },
         complete: function() {
           if(update) {
             setTimeout(status_updater, 5000);
           }
         }
       });
     }
   });
}

$('.algorithms.index').ready(status_updater);
$('.algorithms.index').on('page:load', status_updater);
