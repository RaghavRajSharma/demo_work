window.ST = window.ST || {};

(function(module) {
  $(".settings.show").ready(function(){
    initializeState();
    attachProfileListeners();
  });

  function initializeState() {
    module.lastSelectedFavoriteDiscipline = $('#person_favorite_discipline_id').val();
    module.selectedFavoriteDiscipline = $('#person_favorite_discipline_id').val();
    module.licenseType = $('input[name="person[license_type]"]:checked').val() + "-";
    module.licenseNumber = $("#person_license_number").val();
    updateForm();
  }

  function attachProfileListeners() {
    $('#person_favorite_discipline_id').on('change', function(e){
      module.selectedFavoriteDiscipline = e.target.value;
      var toRenable = module.lastSelectedFavoriteDiscipline;
      $('#person_discipline_ids_'+toRenable).removeAttr('disabled');
      $('#person_discipline_ids_'+e.target.value).removeAttr('checked');
      $('#person_discipline_ids_'+e.target.value).attr('disabled', 'true');
      module.lastSelectedFavoriteDiscipline = e.target.value;
      console.log('last:'+module.lastSelectedFavoriteDiscipline);
      console.log('current:'+module.selectedFavoriteDiscipline);
    });
    $('input[name="person[license_type]"]').on('change', function(e){
      if(e.target.value === "Student") {
        module.licenseType = "";
        module.licenseNumber = "";
      } else {
        module.licenseType = e.target.value + "-";
      }
      updateForm();
    });
  }

  function updateForm() {
    loadLicenseTypePrefix();
    disableDisciplineField();
    updateLicenseNumber();
  }

  function disableDisciplineField() {
    $('#person_discipline_ids_'+module.selectedFavoriteDiscipline).attr('disabled', 'true');
  }

  function loadLicenseTypePrefix() {
    $('#current_license_type').removeAttr('disabled');
    $('#current_license_type').val(module.licenseType);
    $('#current_license_type').attr('disabled', 'true');
  }

  function updateLicenseNumber() {
    if(module.licenseNumber === "") {
      $('#person_license_number').val("");
    }
  }

  
  
})(window.ST);
