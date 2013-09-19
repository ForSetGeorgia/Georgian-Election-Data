var was_selected_map = [];
var table_ind_ids;

function update_selected_cols(){
  var lookup = {};
  var selected = [];
  var data_table = $('#map_data_table').dataTable();
  var index;
  
  // get all options that are selected
  $('select#data_table_filter').find(":selected").each(function() { selected.push($(this).data('id')) });

  // find what was de-selected and turn col off
  for (var j in selected) {
    lookup[selected[j]] = selected[j];
  }
  for (var i in was_selected_map) {
    if (typeof lookup[was_selected_map[i]] == 'undefined') {
      // item removed
      index = table_ind_ids.indexOf(was_selected_map[i]);
      if (index > -1)
        data_table.fnSetColumnVis(index+1, false);
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
      index = table_ind_ids.indexOf(selected[i]);
      if (index > -1)
        data_table.fnSetColumnVis(index+1, true);
    } 
  }      

  // update what items are selected
  was_selected_map = selected;
}

$(document).ready(function() {

  if (gon.data_table_path){
    // apply chosen jquery to filters
    $('select#data_table_filter').chosen({width: "100%"});
    // record which columns are visible by default
    $('select#data_table_filter').find(":selected").each(function() { was_selected_map.push($(this).data('id')) });

    // when indicator filter changes, update what indicators to show
    // - compare list of what was selected vs what is selected and only update the items that don't match
    $('select#data_table_filter').live('change', function(){

      update_selected_cols();

      // update the chosen list so that the items selected are in the correct order
      $(this).trigger("liszt:updated");
    });
    
    // update the url for the download data link
    $("#export-data-xls2").attr('href',update_query_parameter($("#export-data-xls").attr('href'), "event_name", "event_name", gon.event_name));
    $("#export-data-xls2").attr('href',update_query_parameter($("#export-data-xls").attr('href'), "map_title", "map_title", gon.map_title));
    $("#export-data-csv2").attr('href',update_query_parameter($("#export-data-csv").attr('href'), "event_name", "event_name", gon.event_name));
    $("#export-data-csv2").attr('href',update_query_parameter($("#export-data-csv").attr('href'), "map_title", "map_title", gon.map_title));    

  }
});

