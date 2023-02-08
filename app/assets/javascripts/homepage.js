$(function() {
  // Selectors
  intiFilters();
});

function intiFilters(){
  var showFiltersButtonSelector = "#home-toolbar-show-filters";
  var filtersContainerSelector = "#home-toolbar-filters";

  // Elements
  var $showFiltersButton = $(showFiltersButtonSelector);
  var $filtersContainer = $(filtersContainerSelector);

  $showFiltersButton.click(function() {
    $showFiltersButton.toggleClass("selected");
    $filtersContainer.toggleClass("home-toolbar-filters-mobile-hidden");
  });

  // Relocate filters
  if ($("#filters").length && $("#desktop-filters").length) {
    relocate(768, $("#filters"), $("#desktop-filters").get(0));
  }

  relocate(768, $("#header-menu-mobile-anchor"), $("#header-menu-desktop-anchor").get(0));
  relocate(768, $("#header-user-mobile-anchor"), $("#header-user-desktop-anchor").get(0));

  // Reset all filters on click of a category
  $('.home-categories-main').click(function(){
    $(this).attr('href', $(this).data('searchUrl'));
    $("form#homepage-filters").attr("action", "/s");
    $('input[type=search]').val('');
    $('#q').val('');
    history.pushState({}, null, document.location.origin);
  }); 
}
