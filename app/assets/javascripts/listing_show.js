window.ST = window.ST || {};

(function(module) {
  module.selected = "new";
  $(".listings.show").ready(function(){
    attachListeners();
  });

  function attachListeners() {
    $(document).on('click', '.add_item', function(e){
      e.preventDefault();
      assignNewState(e, 'new');
    });
    $(document).on('click', '.add_existing_item', function(e){
      e.preventDefault();
      assignNewState(e, 'existing');
    });
    function assignNewState(event, state){
      var newState = {};
      var key = event.target.dataset.id;
      newState[key] = state;
      changeSelectedState(newState);
    }
    $(document).on('click', '.remove-child', function(e){
      e.preventDefault();
      var id = e.target.id.split('-')[1];
      console.log(id);
      $.get($(this).data('url'), function(html){
        $('#details-'+id).html(html);
        // attachListeners();
      })
    });

    $(document).on('submit', '.add_existing_form', function(e){
      if(e.target.id.match('existing-')) {
        e.preventDefault();
        e.stopPropagation();
        var id = e.target.id.split('-')[1];
        console.log(id);
        var split = $(this).serialize().split('%5D=')
        if($(this).serializeArray().find(function(obj){return obj.name === "listing[new_child]" && obj.value !== "" })) {
          $.ajax({
            method: 'POST', 
            url: e.target.action, 
            data: $(this).serialize()
          }).done(function(html){
            $('#links-'+id).html(html)
            $("[data-toggle='toggle']").bootstrapToggle('destroy')
            $("[data-toggle='toggle']").bootstrapToggle();
            // attachListeners();
          });
        } else {
          debugger;
        }
      }
    });

    $(document).on('change', '.is_willing_to_piece', function(){
      listing_id = $(this).data('id');
      var item_id = $(this).val()
      $.ajax({
        type: "POST",
        url: "/will_or_not_willing_to_piece?listing_id="+item_id,
        contentType: "application/json; charset=utf-8",
        dataType: "json"
      });
    });

    $('.more-info').on('click', function(e){
      e.preventDefault();
      $('#info-'+e.target.id).toggle();
      $(this).text() === "More Info" ? $(this).text("Less Info") : $(this).text("More Info")
    });
  }

  module.createInitialState = function() {
    $.get('/en/listings/rig_category_ids', function(data){
      var selectedOptions = {}
      data.forEach(function(id) {
        selectedOptions[id] = "new";
      })
      module.selected = selectedOptions
    });
  }

  function changeSelectedState(newState) {
    module.selected = Object.assign({}, module.selected, newState);
    renderForm();
  }

  function renderForm() {
    Object.keys(module.selected).forEach(function(id){
      var linksContainerId = "#links-" + id;
      if(module.selected[id] === "new") {
        $(linksContainerId + ' .add_existing_form').hide();
        $(linksContainerId + ' .new_child_listing_links').show();
  
        $(linksContainerId + ' .add_item').css('border-bottom-width', '2px');
        $(linksContainerId + ' .add_existing_item').css('border-bottom-width', '0px');
      } else if(module.selected[id] === "existing") {
        $(linksContainerId + ' .add_existing_form').show();
        $(linksContainerId + ' .new_child_listing_links').hide();
  
        $(linksContainerId + ' .add_item').css('border-bottom-width', '0px');
        $(linksContainerId + ' .add_existing_item').css('border-bottom-width', '2px');
      }
    })
    
  }
  
})(window.ST);
