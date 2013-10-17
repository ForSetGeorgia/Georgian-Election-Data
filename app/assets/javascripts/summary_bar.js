$(document).ready(function() {
  if (gon.is_voters_list && gon.openlayers){
    // make sure the groups in the summary bar all have the same width
    var widths = [];
    $('#summary_data_container #summary_bar_voter_list .group_box').each(function(){
      $(this).width('auto');
      widths.push($(this).width());
    });
    // update widths to max width
    $('#summary_data_container #summary_bar_voter_list .group_box').each(function() { $(this).width(Math.max.apply(Math, widths)); });
  }
});
