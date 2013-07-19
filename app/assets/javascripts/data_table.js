var was_selected_map = [];

$(document).ready(function() {

  if (gon.data_table_path){
    // apply chosen jquery to filters
    $('select#data_table_filter').chosen({width: "100%"});
    // record which columns are visible by default
    $('select#data_table_filter').find(":selected").each(function() { was_selected_map.push($(this).data('id')) });

    // when indicator filter changes, update what indicators to show
    // - compare list of what was selected vs what is selected and only update the items that don't match
    $('select#data_table_filter').live('change', function(){
      var lookup = {};
      var selected = [];
      
      // get all options that are selected
      $(this).find(":selected").each(function() { selected.push($(this).data('id')) });

      // find was was de-selected and turn col off
      for (var j in selected) {
        lookup[selected[j]] = selected[j];
      }
      for (var i in was_selected_map) {
        if (typeof lookup[was_selected_map[i]] == 'undefined') {
          // item removed
          $('table#map_data_table th[data-id="' + was_selected_map[i] + '"]').addClass('hidden');
          $('table#map_data_table td[data-id="' + was_selected_map[i] + '"]').addClass('hidden');
        } 
      }      
       
      lookup = {};
      // find what was selected and turn col on
      for (var j in was_selected_map) {
        lookup[was_selected_map[j]] = was_selected_map[j];
      }
      for (var i in selected) {
        if (typeof lookup[selected[i]] == 'undefined') {
          // item added
          $('table#map_data_table th[data-id="' + selected[i] + '"]').removeClass('hidden');
          $('table#map_data_table td[data-id="' + selected[i] + '"]').removeClass('hidden');
        } 
      }      

      // update the chosen list so that the items selected are in the correct order
      $(this).trigger("liszt:updated");
            
      // update what items are selected
      was_selected_map = selected;
    });
  }
});

