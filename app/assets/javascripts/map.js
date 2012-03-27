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
			callback: set_features_bounds
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
			callback: set_features_bounds
	});


  // Selection
  var select_base = new OpenLayers.Control.SelectFeature(vector_base, {
    hover: true,
    onSelect: hover_handler,
    clickFeature: click_handler
  });

  map.addControls([select_base]);
  select_base.activate();

/*
  var select_child = new OpenLayers.Control.SelectFeature(vector_child, {
    hover: true,
    onSelect: hover_handler
  });
  map.addControls([select_base, select_child]);
  select_base.activate();
  select_child.activate();
*/

}

// load the features and set the bound
// after protocol has read in json
function set_features_bounds(resp){
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

// show the object's name
function hover_handler (feature)
{
  document.getElementById("map-obj-title").innerHTML = feature.attributes.common_name
}



function click_handler (feature)
{
	// get the current url
	url = window.location.href;
	// look for the shape_id parameter
	index = url.indexOf("shape_id=");
	if (index > 0){
		// found shape_id, now need to replace the id with that of this feature
		indexAfter = url.indexOf("&", index+9);
		if (indexAfter > 0){
			// there is another paramter after this one
			url = url.slice(0, index+9) + feature.attributes.id + url.slice(indexAfter);
		}else {
			// no more parameters after this one
			url = url.slice(0, index+9) + feature.attributes.id;
		}
	}else {
		// no shape_id yet, add it
		// if this is the first query string, add the ?, otherwise add &
		url += url.indexOf("?") > 0 ? "&" : "?"
		url += "shape_id=" + feature.attributes.id;		
	}
	window.location.href = url;
}

