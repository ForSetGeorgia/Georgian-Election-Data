$(document).ready(function(){

	if(gon.edit_news){
		// load the date pickers
		$('#news_date_posted').datepicker({
				dateFormat: 'dd.mm.yy',
		});

		if (gon.date_posted !== undefined &&
				gon.date_posted.length > 0)
		{
			$("#news_date_posted").datepicker("setDate", new Date(gon.date_posted));
		}


	}
});

