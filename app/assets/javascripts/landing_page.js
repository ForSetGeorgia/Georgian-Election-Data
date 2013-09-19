$(document).ready(function() {
  if (gon.langing_page){

    // get the max height for row 3 divs and set all other divs to match
    function adjust_landing_page_heights(){
      var heights = [];
      $('#row2 > div').each(function(){
        heights.push($(this).height());
      });
console.log(heights);
      
      $('#row2 > div').each(function() { $(this).height(Math.max.apply(Math, heights)); });
    }

    $(window).resize(function(){
      adjust_landing_page_heights();
    });

    adjust_landing_page_heights();

  }
  
});
