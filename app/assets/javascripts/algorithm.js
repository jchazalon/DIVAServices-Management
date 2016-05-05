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
           $('#status_' + id).text(data['status']);
           $('#status_message_' + id).text(data['status_message']);
           if(data['status'] == 'creating' || data['status'] == 'validating' || data['status'] == 'testing') {
             update = true;
           }
           if(data['status'] == 'published' && $('#status_' + id).text() != 'published') {
             location.reload();
           }
         },
         complete: function() {
           if(update) {
             setTimeout(worker, 10000);
           }
         }
       });
     }
   });
}

$('.algorithms.index').ready(status_updater);
$('.algorithms.index').on('page:load', status_updater);
