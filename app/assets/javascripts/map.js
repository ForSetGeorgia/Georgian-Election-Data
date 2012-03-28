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

  vector_child = new OpenLayers.Layer.Vector("Child Layer", {styleMap: build_indicator_scale_styles()});

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
	// now that the child vector is loaded, lets show the legend
    draw_legend();
  } else {
alert("no features");
  }
}

// Legend
function draw_legend()
{
	var colors = ['#ffffff', '#FFFFB2', '#FED976', '#FEB24C', '#FD8D3C', '#FC4E2A', '#E31A1C', '#B10026'];
    var leg = $('#legend');
	if (gon.indicator_scales && gon.indicator_scales.length > 0){
		for (var i=0; i<gon.indicator_scales.length; i++){
        	leg.append('<li><span style="background: ' + colors[i] + '"></span> ' + gon.indicator_scales[i].name + '</li>');
		}
	} else {
		// no legend
		leg.innerHTML = "";
	}
    $('#legend-container').fadeIn('slow');
}

// build the color mapping for the indicators
function build_indicator_scale_styles() {
    var theme = new OpenLayers.Style();
	var colors = ['#ffffff', '#FFFFB2', '#FED976', '#FEB24C', '#FD8D3C', '#FC4E2A', '#E31A1C', '#B10026'];
	if (gon.indicator_scales && gon.indicator_scales.length > 0){
		// look at each scale and create the builder
		for (var i=0; i<gon.indicator_scales.length; i++){
			var name = gon.indicator_scales[i].name;
			var color = colors[i];

			// look in the name for >, <, or -
			// - if find => create appropriate comparison filter
			// - else use ==
		    var rule;
			var indexG = name.indexOf(">");
			var indexL = name.indexOf("<");
			var indexB = name.indexOf("-");
			if (indexG >= 0) {
				// set to >
				if (indexG == 0){
					rule = build_rule(color, ">", name.slice(1));
				}
				else if (indexG == name.length-1) {
					rule = build_rule(color, ">", name.slice(0, indexG-1));
				}
				else {
					// > is in middle of string.  can not handle
				}
			} else if (indexL >= 0) {
				// set to <
				if (indexG == 0){
					rule = build_rule(color, "<", name.slice(1));
				}
				else if (indexG == name.length-1) {
					rule = build_rule(color, "<", name.slice(0, indexG-1));
				}
				else {
					// > is in middle of string.  can not handle
				}
			} else if (indexB >= 0) {
				// set to < and >
				rule = build_rule(color, "..", name.slice(0, indexB), name.slice(indexB+1));
			} else {
				// set to '='
				rule = build_rule(color, "==", name);
			}
			// add the rule to the theme
			if (rule){
			    theme.addRules([rule]);
			}
		}
	}
    
    var stylemap = new OpenLayers.StyleMap({'default':theme, 'select': {'strokeColor': '#0000ff', 'fillColor': '#0000ff', 'strokeWidth': 2}});
    return stylemap;
}

function build_rule(color, type, value1, value2){
	var rule;
	if (type == ".." && value1 && value2){
	    rule = new OpenLayers.Rule({
	      	filter: new OpenLayers.Filter.Comparison({
		        type: type,
		        property: "value",
		        lowerBoundary: value1,
		 		upperBoundary: value2}),
	        symbolizer: {"Polygon": {'fillColor': color}}
	    });
	} else if (type && value1){
	    rule = new OpenLayers.Rule({
	      	filter: new OpenLayers.Filter.Comparison({
		        type: type,
		        property: "value",
		        value: value1 }),
	        symbolizer: {"Polygon": {'fillColor': color}}
	    });
	}

	return rule;
}

function build_style() {
    var theme = new OpenLayers.Style();
    var rule1 = new OpenLayers.Rule({
      	filter: new OpenLayers.Filter.Comparison({
	        type: OpenLayers.Filter.Comparison.GREATER_THAN,
	        property: "value",
	        value: 500 }),
        symbolizer: {"Polygon": {'fillColor': '#B10026'}}
    });
    var rule2 = new OpenLayers.Rule({
		filter: new OpenLayers.Filter.Logical({
	        type: OpenLayers.Filter.Logical.AND,
	        filters: [ 
	            new OpenLayers.Filter.Comparison({
	                type: OpenLayers.Filter.Comparison.LESS_THAN,
	                property: "value",
	                value: 501
	            }),
	            new OpenLayers.Filter.Comparison({
	                type: OpenLayers.Filter.Comparison.GREATER_THAN,
	                property: "value",
	                value: 400
	            })
	        ]
	        }),
        symbolizer: {"Polygon": {'fillColor': '#E31A1C'}}
    });
    var rule3 = new OpenLayers.Rule({
		filter: new OpenLayers.Filter.Logical({
	        type: OpenLayers.Filter.Logical.AND,
	        filters: [ 
	            new OpenLayers.Filter.Comparison({
	                type: OpenLayers.Filter.Comparison.LESS_THAN,
	                property: "value",
	                value: 401
	            }),
	            new OpenLayers.Filter.Comparison({
	                type: OpenLayers.Filter.Comparison.GREATER_THAN,
	                property: "value",
	                value: 300
	            })
	        ]
	        }),
        symbolizer: {"Polygon": {'fillColor': '#FC4E2A'}}
    });
    var rule4 = new OpenLayers.Rule({
		filter: new OpenLayers.Filter.Logical({
	        type: OpenLayers.Filter.Logical.AND,
	        filters: [ 
	            new OpenLayers.Filter.Comparison({
	                type: OpenLayers.Filter.Comparison.LESS_THAN,
	                property: "value",
	                value: 301
	            }),
	            new OpenLayers.Filter.Comparison({
	                type: OpenLayers.Filter.Comparison.GREATER_THAN,
	                property: "value",
	                value: 200
	            })
	        ]
	        }),
        symbolizer: {"Polygon": {'fillColor': '#FD8D3C'}}
    });
    var rule5 = new OpenLayers.Rule({
		filter: new OpenLayers.Filter.Logical({
	        type: OpenLayers.Filter.Logical.AND,
	        filters: [ 
	            new OpenLayers.Filter.Comparison({
	                type: OpenLayers.Filter.Comparison.LESS_THAN,
	                property: "value",
	                value: 201
	            }),
	            new OpenLayers.Filter.Comparison({
	                type: OpenLayers.Filter.Comparison.GREATER_THAN,
	                property: "value",
	                value: 100
	            })
	        ]
	        }),
        symbolizer: {"Polygon": {'fillColor': '#FEB24C'}}
    });
    var rule6 = new OpenLayers.Rule({
		filter: new OpenLayers.Filter.Logical({
	        type: OpenLayers.Filter.Logical.AND,
	        filters: [ 
	            new OpenLayers.Filter.Comparison({
	                type: OpenLayers.Filter.Comparison.LESS_THAN,
	                property: "value",
	                value: 101
	            }),
	            new OpenLayers.Filter.Comparison({
	                type: OpenLayers.Filter.Comparison.GREATER_THAN,
	                property: "value",
	                value: 0
	            })
	        ]
	        }),
        symbolizer: {"Polygon": {'fillColor': '#FED976'}}
    });

    var rule7 = new OpenLayers.Rule({
		filter: new OpenLayers.Filter.Comparison({
	        type: OpenLayers.Filter.Comparison.EQUAL_TO,
	        property: "value",
	        value: 0
        }),
        symbolizer: {"Polygon": {'fillColor': '#FFFFB2'}}
    });

    var rule8 = new OpenLayers.Rule({
		filter: new OpenLayers.Filter.Comparison({
	        type: OpenLayers.Filter.Comparison.EQUAL_TO,
	        property: "value",
	        value: "N/A"
        }),
        symbolizer: {"Polygon": {'fillColor': '#ffffff'}}
    });
    theme.addRules([rule1, rule2, rule3, rule4, rule5, rule6, rule7, rule8]);
    
    var stylemap = new OpenLayers.StyleMap({'default':theme, 'select': {'strokeColor': '#0000ff', 'fillColor': '#0000ff', 'strokeWidth': 2}});
    return stylemap;
}

// show the object's name
function hover_handler (feature)
{
	var text = feature.attributes.common_name;
	if (gon.showing_indicators){
		text += ' : <span style="text-decoration:underline;">';
		text += feature.attributes.value;
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
