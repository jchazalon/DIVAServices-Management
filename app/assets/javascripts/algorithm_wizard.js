function wizard_sortable() {
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

function edit_sortable() {
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
          url: 'input_parameters/sort',
          data: { sorted_input_parameters: sortable.toArray() }
      });
    },
  });
}

$('.algorithm_wizard.show').ready(wizard_sortable);
$('.algorithm_wizard.show').on('page:load', wizard_sortable);

$('.algorithms.edit').ready(edit_sortable);
$('.algorithms.edit').on('page:load', edit_sortable);
