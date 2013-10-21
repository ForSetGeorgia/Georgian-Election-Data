    var landing_circle_link_obj = null;

$(document).ready(function() {
  if (gon.landing_page){

    $('a.landing_circle_link').click(function(){
      landing_circle_link_obj = this;
      $.fancybox({
        transitionIn: 'elastic',
        transitionOut: 'elastic',
        type: 'inline',
        href: $(landing_circle_link_obj).attr('href'),
        onStart: function () {
          if ($(landing_circle_link_obj).data('type-id') != undefined){
            $('div#events_menu_tabs .ui-tabs-nav li a[data-type-id="' + $(landing_circle_link_obj).data('type-id') + '"]').click();
          }
          else {
            $('div#events_menu_tabs .ui-tabs-nav li:eq(0) a').click();
          }
        }
      });
    });

    if (gon.landing_live_election && gon.landing_live_election_ids && gon.landing_live_election_ids.length > 0){
    
      // process json request when looking if new live data exists
      function process_json_response(i){
        return function (response){
		      var text = $('.new_data_available[data-election-id="' + gon.landing_live_election_ids[i] + '"]');
		      if (text){
		        // if the response value is > current data set id,
		        // show msg that new data is available
		        if (response !== null && response > parseInt(gon.landing_live_dataset_ids[i])){
			        // update the url
			        // show the message
			        $(text).slideDown(500);
		        } else {
			        $(text).slideUp(500);
		        }
          }
        }
      }

	    setInterval(function() {
        for(var i=0; i<gon.landing_live_election_ids.length;i++){
			    $.getJSON(
				    '/' + I18n.locale + '/json/current_data_set/event/' + gon.landing_live_election_ids[i] + '/data_type/' + gon.landing_live_election_data_type + '.json', process_json_response(i));
        }
	    }, 1000 * 60 * 1);
    }


  }
  
});
