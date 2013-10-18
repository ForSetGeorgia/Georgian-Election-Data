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
  }
  
});
