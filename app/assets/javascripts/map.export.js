$(function(){
   var map_export = $("#export"),
       export_map_svg = $("#export-png, #export-map, #export-data-xls, #export-data-csv, #export .fancybox"),
       display_export = function()
       {
         export_map_svg.css('display', 'block');
       },
       export_click = function()
       {
         var min_width = 94, max_width = 269;
         if (parseInt(map_export.css('width')) < max_width-1)
         {
            map_export.animate({
               width: max_width
            }, 250, display_export);
         }
         else
         {
            export_map_svg.css('display', 'none');
            map_export.animate({
               width: min_width
            }, 250);
         }
       };

   $("#export p:first").bind({
      click: export_click
   });


  // download data links cannot submit as normal links due to geo language and event name/titles being long (too many characters for url)
  // so use hidden form
  $('.download-link').on('click', function(event) {
    event.preventDefault();

		$("#hidden_form_data #type").val($(this).data('type'));
		$("#hidden_form_data").attr('action', $("#hidden_form_data").data('action') + '.' + $(this).data('type'));
		// submit the hidden form
		$('#hidden_form_data').submit();
  });

});

