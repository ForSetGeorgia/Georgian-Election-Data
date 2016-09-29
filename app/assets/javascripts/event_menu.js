$(document).ready(function () {
	$('div.events_menu_tabs').tabs(); // jquery-ui tabs

	if (!gon.landing_page){
  	$('div.events_menu_tabs').hide();
	}

	$('#navmenu').click(function (e) {
	  var t = $(".events_menu_tabs[data-id='main']"), state = t.hasClass("open");

	  if (state)
	  {
	    $(document).off('click.navmenu_document');
	  }
	  else
	  {
	    $(document).on("click.navmenu_document", function () {
	      t.toggleClass("open");
	      t.slideToggle(200);
	      $(document).off('click.navmenu_document');
	    });
	  }
	  t.toggleClass("open");
	  t.slideToggle(200);

	  e.stopPropagation();
	});

	// tipsy tooltips
	$('.events_menu_tabs .ui-tabs-panel .menu_list ul.menu_item li a').tipsy({
		gravity: 'w'
	});

	$('.events_menu_tabs .ui-tabs-panel .menu_list ul.menu_item li.event_name span').tipsy({
		gravity: 'w'
	});

});
