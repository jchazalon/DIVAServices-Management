function ready2() {
  var container = document.querySelector('.input_parameters');
  var sortable = Sortable.create(container, {
    draggable: ".list-group-item",
    ghostClass: 'ghost',
    handle: '.handle',
    scroll: true,
    animation: 400,
    onUpdate: function (evt) {
        $(evt.target).find('h3').each(function(index) {
          $(this).text("Parameter " + (index + 1));
        })
        $.ajax({
          type: "PUT",
          url: '../input_parameters/sort',
          data: { sorted_input_parameters: sortable.toArray() }
      });
    },
  });
}

$(document).ready(ready2);
$(document).on('page:load', ready2);
