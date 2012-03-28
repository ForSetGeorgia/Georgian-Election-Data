//= require openlayers
//= require jquery
//= require jquery_ujs

window.onload = map_init;

// Define global variables which can be used in all functions
var map, vector_base, vector_child;

// Function called from body tag
function map_init(){

	var options = {
        controls: []  // Remove all controls
  };

  map = new OpenLayers.Map('map', options);

  vector_base = new OpenLayers.Layer.Vector("Base Layer", {isBaseLayer: true});

  vector_child = new OpenLayers.Layer.Vector("Child Layer");

  map.addLayers([vector_base, vector_child]);

	// load the base layer
	var prot = new OpenLayers.Protocol.HTTP({
		url: gon.shape_path,
		format: new OpenLayers.Format.GeoJSON({
      'internalProjection': map.baseLayer.projection,
      'externalProjection': new OpenLayers.Projection('EPSG:900913')
		})
	});

	var strat = [new OpenLayers.Strategy.Fixed()];
	vector_base.protocol = prot;
	vector_base.strategies = strat;

	// create event to load the features and set the bound
	// after protocol has read in json
	prot.read({
			callback: load_vector_base
	});

	// load the child layer
	var prot2 = new OpenLayers.Protocol.HTTP({
		url: gon.children_shapes_path,
		format: new OpenLayers.Format.GeoJSON({
      'internalProjection': map.baseLayer.projection,
      'externalProjection': new OpenLayers.Projection('EPSG:900913')
		})
	});

	vector_child.protocol = prot2;
	vector_child.strategies = strat;

	// create event to load the features and set the bound
	// after protocol has read in json
	prot2.read({
			callback: load_vector_child
	});


  // Selection
  var select_child = new OpenLayers.Control.SelectFeature(vector_child, {
    hover: true,
    onSelect: hover_handler,
		clickFeature: click_handler
  });
  map.addControls([select_child]);
  select_child.activate();


}

// load the features and set the bound
// after protocol has read in json
function load_vector_base(resp){
	if (resp.success()){
		var features = resp.features;         
    var bounds;
		if(features) {
      if(features.constructor != Array) {
          features = [features];
      }
      for(var i=0; i<features.length; ++i) {
        if (!bounds) {
            bounds = features[i].geometry.getBounds();
        } else {
            bounds.extend(features[i].geometry.getBounds());
        }
      }
      vector_base.addFeatures(features);
      map.zoomToExtent(bounds);
    } else {
alert("no features");
    }
	}
}

// load the features for the children into the vector_child layer
function load_vector_child(resp){
	if (resp.success()){
    vector_child.addFeatures(resp.features);
  } else {
alert("no features");
  }
}

// show the object's name
function hover_handler (feature)
{
	var text = feature.attributes.common_name;
	if (gon.showing_indicators){
		text += ' : <span style="text-decoration:underline;">';
		if (feature.attributes.value.length === 0){
			text += "N/A";
		} else {
			text += feature.attributes.value;
		}
		text += "</span>";
	}
  document.getElementById("map-obj-title").innerHTML = text;
}



function click_handler (feature)
{
	// add/update the shape_id parameter
	var url = update_query_parameter(window.location.href, "shape_id", feature.attributes.id);

	// add/update the shape_type_id parameter
	url = update_query_parameter(url, "shape_type_id", feature.attributes.shape_type_id);

	// add/update the parameter to indicate that the shape was clicked on
	url = update_query_parameter(url, "shape_click", true);

	// load the url
	window.location.href = url;
}

// add/update the query paramter with the provided name and value
function update_query_parameter(url, name, value){
	// get the current url
	var index = url.indexOf(name + "=");
	var name_length = name.length+1; // use +1 to account for the '='
	if (index > 0){
		// found it, now need to replace the value
		var indexAfter = url.indexOf("&", index+name_length);
		if (indexAfter > 0){
			// there is another paramter after this one
			url = url.slice(0, index+name_length) + value + url.slice(indexAfter);
		}else {
			// no more parameters after this one
			url = url.slice(0, index+name_length) + value;
		}
	}else {
		// not in query string yet, add it
		// if this is the first query string, add the ?, otherwise add &
		url += url.indexOf("?") > 0 ? "&" : "?"
		url += name + "=" + value;		
	}
	return url;
}
