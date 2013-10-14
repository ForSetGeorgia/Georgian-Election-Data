    var landing_circle_link_obj = null;

$(document).ready(function() {
  if (gon.landing_page){

    // get the max height for row 3 divs and set all other divs to match
    function adjust_landing_page_heights(){
      var heights = [];
      $('#row2 .row2_links').each(function(){
        heights.push($(this).height());
      });
      
      $('#row2 .row2_links').each(function() { $(this).height(Math.max.apply(Math, heights)); });
    }

    $(window).resize(function(){
      adjust_landing_page_heights();
    });

    adjust_landing_page_heights();
    
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
