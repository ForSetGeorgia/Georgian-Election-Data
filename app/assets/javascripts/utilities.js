// get the query paramter with the provided name
// - name is the long name of the parameter (e.g., event_id)
// - name2 is the abbreviated name that shows in the pretty url (e.g., event)
function get_query_parameter(url, name, name2){
	var value;
	var index = url.indexOf(name + "=");
	var index2 = url.indexOf("/" + name2 + "/");
	if (index > 0){
		// found 'name=', now need to replace the value
		var name_length = name.length+1; // use +1 to account for the '='
		var indexAfter = url.indexOf("&", index+name_length);
		if (indexAfter > 0){
			// there is another paramter after this one
			value = url.slice(index+name_length, indexAfter);
		}else {
			// no more parameters after this one
			value = url.slice(index+name_length, url.length);
		}
	}else if (index2 > 0) {
		// found '/name/', now need to replace the value
		var name_length = name2.length+2; // use +2 to account for the '/' at the beginning and end
		var indexAfter = url.indexOf("/", index2+name_length);
		var indexAfter2 = url.indexOf("?", index2+name_length);
		if (indexAfter > 0){
			// there is another paramter after this one
			value = url.slice(index2+name_length, indexAfter);
		} else if (indexAfter2 > 0){
			// there is another paramter after this one
			value = url.slice(index2+name_length, indexAfter2);
		}else {
			// no more parameters after this one
			value = url.slice(index2+name_length, url.length);
		}
	}
	return value;
}

// add/update the query paramter with the provided name and value
function update_query_parameter(url, name, name2, value){
  var new_url;
	// get the current url
	var index = url.indexOf(name + "=");
	var index2 = url.indexOf("/" + name2 + "/");
	if (index > 0){
		// found 'name=', now need to replace the value
		var name_length = name.length+1; // use +1 to account for the '='
		var indexAfter = url.indexOf("&", index+name_length);
		if (indexAfter > 0){
			// there is another paramter after this one
			new_url = url.slice(0, index+name_length) + value + url.slice(indexAfter);
		}else {
			// no more parameters after this one
			new_url = url.slice(0, index+name_length) + value;
		}
	}else if (index2 > 0) {
		// found '/name/', now need to replace the value
		var name_length = name2.length+2; // use +2 to account for the '/' at the beginning and end
		var indexAfter = url.indexOf("/", index2+name_length);
		var indexAfter2 = url.indexOf("?", index2+name_length);
		if (indexAfter > 0){
			// there is another paramter after this one
			new_url = url.slice(0, index2+name_length) + value + url.slice(indexAfter);
		} else if (indexAfter2 > 0){
			// there is another paramter after this one
			new_url = url.slice(0, index2+name_length) + value + url.slice(indexAfter2);
		}else {
			// no more parameters after this one
			new_url = url.slice(0, index2+name_length) + value;
		}
	}else {
		// not in query string yet, add it
		// if this is the first query string, add the ?, otherwise add &
    new_url = url;
		new_url += new_url.indexOf("?") > 0 ? "&" : "?"
		new_url += name + "=" + value;
	}
	return new_url;
}


// replace the query paramter with the new one that is provided
// - name is the long name of the parameter (e.g., event_id)
// - name2 is the abbreviated name that shows in the pretty url (e.g., event)
function replace_query_parameter(url, old_name, old_name2, new_name, new_name2, value, value2){
  var new_url;
	// get the current url
	var index = url.indexOf(old_name + "=");
	var index2 = url.indexOf("/" + old_name2 + "/");
	if (index > 0){
		// found 'name=', now need to replace the value
		var name_length = old_name.length+1; // use +1 to account for the '='
		var indexAfter = url.indexOf("&", index+name_length);
		if (indexAfter > 0){
			// there is another paramter after this one
			new_url = url.slice(0, index) + new_name + "=" + value + url.slice(indexAfter);
		}else {
			// no more parameters after this one
			new_url = url.slice(0, index) + new_name + "=" + value;
		}
	}else if (index2 > 0) {
		// found '/name/', now need to replace the value
		var name_length = old_name2.length+2; // use +2 to account for the '/' at the beginning and end
		var indexAfter = url.indexOf("/", index2+name_length);
		var indexAfter2 = url.indexOf("?", index2+name_length);
		if (indexAfter > 0){
			// there is another paramter after this one
			new_url = url.slice(0, index2+1) + new_name2 + "/" + value2 + url.slice(indexAfter);
		} else if (indexAfter2 > 0){
			// there is another paramter after this one
			new_url = url.slice(0, index2+1) + new_name2 + "/" + value2 + url.slice(indexAfter2);
		}else {
			// no more parameters after this one
			new_url = url.slice(0, index2+1) + new_name2 + "/" + value2;
		}
	}else {
		// not in query string yet, add it
		// if this is the first query string, add the ?, otherwise add &
    new_url = url;
		new_url += new_url.indexOf("?") > 0 ? "&" : "?"
		new_url += new_name + "=" + value;
	}
	return new_url;
}

// remove the query paramter with the provided name and value
// - name is the long name of the parameter (e.g., event_id)
// - name2 is the abbreviated name that shows in the pretty url (e.g., event)
function remove_query_parameter(url, name, name2){
  var new_url;
	// get the current url
	var index = url.indexOf(name + "=");
	var index2 = url.indexOf("/" + name2 + "/");
	if (index > 0){
		// found 'name=', now need to remove the parameter and its value
		var name_length = name.length+1; // use +1 to account for the '='
		var indexAfter = url.indexOf("&", index+name_length);
		if (indexAfter > 0){
			// there is another paramter after this one
			new_url = url.slice(0, index) + url.slice(indexAfter);
		}else {
			// no more parameters after this one
			new_url = url.slice(0, index);
		}
	}else if (index2 > 0) {
		// found '/name/', now need to remove the parameter and its value
		var name_length = name2.length+2; // use +2 to account for the '/' at the beginning and end
		var indexAfter = url.indexOf("/", index2+name_length);
		var indexAfter2 = url.indexOf("?", index2+name_length);
		if (indexAfter > 0){
			// there is another paramter after this one
			new_url = url.slice(0, index2) + url.slice(indexAfter);
		} else if (indexAfter2 > 0){
			// there is another paramter after this one
			new_url = url.slice(0, index2) + url.slice(indexAfter2);
		}else {
			// no more parameters after this one
			new_url = url.slice(0, index2);
		}
	}
	return new_url;
}


// Convert dataURL to Blob object
function dataURLtoBlob(dataURL) {
  // Decode the dataURL    
  var binary = atob(dataURL.split(',')[1]);
  // Create 8-bit unsigned array
  var array = [];
  for(var i = 0; i < binary.length; i++) {
      array.push(binary.charCodeAt(i));
  }
  // Return our Blob object
  return new Blob([new Uint8Array(array)], {type: 'image/png'});
}

// send the png images that were generated of the map
// to the server so they can be saved and used next time
// taken from: http://rohitrox.github.io/2013/07/19/canvas-images-and-rails/
function save_generated_map_images(){
  
  var img = document.getElementById("svg_to_png1");
      
  // Get image
  var file = dataURLtoBlob(img.toDataURL('image/png'));
  // Create new form data
  var fd = new FormData();
  // Append our Canvas image file to the form data
  fd.append("event_id", gon.event_id);
  fd.append("data_set_id", gon.data_set_id);
  fd.append("parent_shape_id", gon.parent_shape_id);
  fd.append("img", file);
  fd.append("img_width", $('#summary_data_above_map > div:first-of-type .map_image img').data('width'));
  fd.append("img_height", $('#summary_data_above_map > div:first-of-type .map_image img').data('height'));
  // And send it
  $.ajax({
     url: "/" + I18n.locale + "/save_map_images",
     type: "POST",
     data: fd,
     processData: false,
     contentType: false,
  }); 
}

/*

function full_height (element)
{
  if (element.length == 0)
  {
    return 0;
  }
  var values =
  [
    element.height(),
    element.css('margin-top'),
    element.css('margin-bottom'),
    element.css('padding-top'),
    element.css('padding-bottom'),
    element.css('border-top-width'),
    element.css('border-bottom-width')
  ],
  h = 0;
  for (i in values)
  {
    h += parseInt(values[i]);
  }
  return h;
}

function window_width ()
{
  var winW;
  if (document.body && document.body.offsetWidth)
  {
    winW = document.body.offsetWidth;
  }
  else if (document.compatMode == 'CSS1Compat' && document.documentElement && document.documentElement.offsetWidth)
  {
    winW = document.documentElement.offsetWidth;
  }
  else if (window.innerWidth)
  {
    winW = window.innerWidth;
  }
  return winW;
}
*/
