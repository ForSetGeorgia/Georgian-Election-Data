/*  Useful functions  */
this.log=function(a){console.log(a)};Array.prototype.__=function(a){this.push(a)};this.foreach=function(a,b){if(typeof a.length==="number")for(var c=0;c<a.length;c++)b(c,a[c]);else if(typeof a.length==="undefined")for(var c in a)b(c,a[c])};this.extract=function(a){if(typeof a.length==="number")for(var b=0;b<a.length;b++)this[b]=a[b];else if(typeof a.length==="undefined")for(var b in a)this[b]=a[b]};this.ob=function(){this.code};this.ob.prototype.start=function(a){this.code=a.toString().substring(a.toString().search("{")+1,a.toString().search("}"))};this.ob.prototype.flush=function(){eval(this.code)}

/*  Declaring class  */
function MapPopup() {
  var self = this;
  this.svg = null;
  this.svgElements = new Array();
  this.title = null;
  this.y_s = 20; // padding on the y axis
  this.max_value_width = 0;
  this.max_ind_width = 0;
  this.max = 100;
  this.dist = 25;
  this.i = 0;
	this.item_spacing = 10;

  this.svgElementsIndex = function(){
    index = 0;
    if (self.svgElements.length > 0) {
      index = self.svgElements.length-1;
    }
    console.log("svgElements index = " + index);
    if (self.svgElements[index] === undefined)
      self.svgElements[index] = {};
    console.log("svgElements[index] = " + self.svgElements[index]);
    return index;
  }

  this.computeWindowWidth = function(id_el, json, options)
  {
    var max_width = 0;
  /*
    old computations for widths
    title
    window.maxSVGWidth = 30+(ths.title.location.length>th_title.length ? ths.title.location.length : th_title.length)*5+50;
    summary data
    window.maxSVGWidth = 30+ths.max_ind_width*7+80+ths.max/100*json.data[0].value+10;
    data item
    window.maxSVGWidth = (30+ths.max_ind_width*7+10)+(ths.max_value_width.toString().length*7+50);
    no data
    window.maxSVGWidth = 30+ths.max_ind_width*7+10+gon.no_data_text.length*7+50;

  */
    for(i=0;i<json.length;i++){
      if (json[i].hasOwnProperty("title"))
      {
        var title = typeof json[i].title.title_abbrv !== "undefined" &&
          json[i].title.title_abbrv instanceof String &&
          json[i].title.title_abbrv.length > 0 ? json[i].title.title_abbrv : json[i].title.title;
				var title_title_width = get_text_width(title, "15px");
				var title_loc_width = get_text_width(json[i].title.location, "15px");
console.log("title title width = " + title_title_width);
console.log("title location width = " + title_loc_width);
				var title_width = self.item_spacing*6+(title_title_width>title_loc_width ? title_title_width : title_loc_width);
console.log("title width = " + title_width);
        if (title_width > max_width)
          max_width = title_width;
      }
      else if (json[i].hasOwnProperty("summary_data"))
      {
        var max_text_width = 0;
        var max_value_width = 0;
				for(var j=0;j<json[i].summary_data.length;j++) {
					var value = json[i].summary_data[j];
					var text_width = get_text_width(value.indicator_name);
          if( text_width > max_text_width)
            max_text_width = text_width;
					var value_width = get_text_width(value.number_format === null ?
							value.formatted_value : value.formatted_value + value.number_format)
          if( value_width > max_value_width)
            max_value_width = value_width;
        }
console.log("summary max text width = " + max_text_width +
	"; max value width = " + max_value_width + "; first data value = " + json[i].summary_data[0].value);
				if (isNaN(json[i].summary_data[0].value))
					var summary_width = self.item_spacing*3+max_text_width+self.item_spacing+max_value_width+self.item_spacing*3;
				else
					var summary_width = self.item_spacing*3+max_text_width+self.item_spacing+max_value_width+self.item_spacing+self.max/100*json[i].summary_data[0].value+self.item_spacing*2;

        console.log("summary width = " + summary_width);
        if (summary_width > max_width)
          max_width = summary_width;
        if (max_text_width > self.max_ind_width)
          self.max_ind_width = max_text_width;
        if (max_value_width > self.max_value_width)
          self.max_value_width = max_value_width;
      }
      else if (json[i].hasOwnProperty("data_item"))
      {
        var max_text_width = get_text_width(json[i].data_item.indicator_name);
        var max_value_width = get_text_width(json[i].data_item.number_format === null ?
					json[i].data_item.formatted_value : json[i].data_item.formatted_value + " " + json[i].data_item.number_format);
        var item_width = self.item_spacing*3+max_text_width+self.item_spacing+max_value_width+self.item_spacing*3;
        console.log("item width = " + item_width);
        if (item_width > max_width)
          max_width = item_width;
        if (max_text_width > self.max_ind_width)
          self.max_ind_width = max_text_width;
        if (max_value_width > self.max_value_width)
          self.max_value_width = max_value_width;
      }
    };
    window.maxSVGWidth = max_width;
    console.log("self.max_ind_width = " + self.max_ind_width + "; self.max_value_width = " + self.max_value_width);
  }

  this.processTitle = function(id_el, json, options)
  {
    // determine which title to use
    var title = typeof json.title_abbrv !== "undefined" &&
      json.title_abbrv instanceof String &&
      json.title_abbrv.length > 0 ? json.title_abbrv : json.title;

    // add the titles to the svg
    if (typeof window.maxSVGWidth !== "undefined")
    {
      this.SVGElement("text", {
        "x": (window.maxSVGWidth/2),
        "y": 20,
        "style": "font-size:15px;text-anchor:middle;"
      }).text(json.location);

      this.SVGElement("text", {
        "x": (window.maxSVGWidth/2),
        "y": 40,
        "style": "font-size:15px;text-anchor:middle;"
      }).text(title);
    }

    // make height at least 50 so title will show
    window.maxSVGHeight = 50;
    // make y padding equal to min height
    self.y_s = 50;
  }

  this.processSummaryData = function(id_el, json, options)
  {
		// if a limit was passed in, use it
    json = json.slice(0, options.limit !== undefined ? options.limit : json.length);
		// create the svg for each summary data item
    for(var i=0;i<json.length;i++){
      // create horizontal bars
      // - first is for item color
      this.SVGElement("rect", {
        "x": self.item_spacing,
        "y": self.y_s+i*self.dist,
        "width": 10,
        "height": 10,
        "style": "fill:"+json[i].color
      });

			if (!isNaN(json[i].value)){
		    // - second is for bar chart
		    this.SVGElement("rect", {
		      "x": self.item_spacing*3+self.max_ind_width+self.item_spacing+self.max_value_width+self.item_spacing,
		      "y": self.y_s+i*self.dist,
		      "width": self.max/100*json[i].value,
		      "height": 10,
		      "style": "fill:#5c81a3"
		    });
			}

      // make separator line
      this.SVGElement("line", {
        "x1": self.item_spacing,
        "y1": self.y_s+self.i*self.dist+15,
        "x2": window.maxSVGWidth-10,
        "y2": self.y_s+self.i*self.dist+15,
        "style": "stroke-width:1px;stroke:#CCC"
      });

      // write out name
      this.SVGElement("text", {
        "x": self.item_spacing*3,
        "y": self.y_s+10+self.i*self.dist,
        "style": "font-size:12px;",
        "class": "title"
      }).text(json[i].indicator_name);
      // write out value
      this.SVGElement("text", {
        "x": self.item_spacing*3+self.max_ind_width+self.item_spacing,
        "y": self.y_s+10+self.i*self.dist,
        "style": "font-size:12px;"
      }).text(json[i].formatted_value+(json[i].number_format === null ? "" : json[i].number_format));

      self.i++;

      window.maxSVGHeight = self.y_s+10+self.i*self.dist+10;
    }
  }

  this.processDataItem = function(id_el, json, options)
  {
    // make separator line
    this.SVGElement("line", {
      "x1": self.item_spacing,
      "y1": self.y_s+self.i*self.dist+15,
      "x2": window.maxSVGWidth-10,
      "y2": self.y_s+self.i*self.dist+15,
      "style": "stroke-width:1px;stroke:#CCC"
    });

    // write out name
    this.SVGElement("text", {
      "x": self.item_spacing*3,
      "y": self.y_s+10+self.i*self.dist,
      "style": "font-size:12px;",
      "class": "title"
    }).text(json.indicator_name);
    // write out value
    this.SVGElement("text", {
      "x": self.item_spacing*3+self.max_ind_width+self.item_spacing,
      "y": self.y_s+10+self.i*self.dist,
      "style": "font-size:12px;"
    }).text(json.formatted_value+(json.number_format === null ? "" : json.number_format));

    self.i++;

    window.maxSVGHeight = self.y_s+10+self.i*self.dist+10;
  }
}


/*  Class function  */
MapPopup.prototype.processJSON = function(id_el, json, options)
{
  if (json instanceof Array && json.length>0)
  {
    // determine overall window width
console.log("compute width");
    this.computeWindowWidth(id_el, json, options);
console.log("computed window width = " + window.maxSVGWidth);

    // create svg element
    var d3elmapsvg = d3.select(id_el)
                     .append("svg")
                     .attr("xmlns", "http://www.w3.org/2000/svg")
                     .attr("class", "elmapsvg");
    this.svg = d3elmapsvg;

    // process each data type in json
    //foreach(json, function(index, hash){
console.log("json length = " + json.length);
    for(var index=0;index<json.length;index++){
console.log("starting json index " + index);
      if (json[index].hasOwnProperty("title"))
      {
console.log("loading title");
        this.processTitle(id_el, json[index].title, options);
      }
      else if (json[index].hasOwnProperty("summary_data"))
      {
console.log("loading summary data");
        this.processSummaryData(id_el, json[index].summary_data, options);
      }
      else if (json[index].hasOwnProperty("data_item"))
      {
console.log("loading data item");
        this.processDataItem(id_el, json[index].data_item, options);
      }
console.log("finishing json index " + index);
    }
  }
};

MapPopup.prototype.Rect = function(x, y, width, height)
{
  return this.svg.append("rect")
                 .attr("width", width)
                 .attr("height", height)
                 .attr("x", x)
                 .attr("y", y);
};

MapPopup.prototype.Text = function(x, y, text)
{
  return this.svg.append("text")
                 .attr("x", x)
                 .attr("y", y)
                 .text(text);
};

MapPopup.prototype.Line = function(x1, y1, x2, y2)
{
  return this.svg.append("line")
                 .attr("x1", x1)
                 .attr("y1", y1)
                 .attr("x2", x2)
                 .attr("y2", y2);
};

MapPopup.prototype.SVGElement = function(elname, attributes)
{
  var ret_svg = this.svg.append(elname);
  for(var key in attributes){
     ret_svg.attr(key, attributes[key]);
  };
  return ret_svg;
};

/*
MapPopup.prototype.processTheType = function(id_el, json, options)
{
    // create the svg object if not defined yet
    if (typeof this.svg === "undefined")
    {
      var d3elmapsvg = d3.select(id_el)
                       .append("svg")
                       .attr("xmlns", "http://www.w3.org/2000/svg")
                       .attr("class", "elmapsvg");

      this.svg = d3elmapsvg;
    }


    var ths = this;

    if (ths.title instanceof Array)
      ths.title = ths.title[0].title;

    // process the title
    if (typeof ths.title === "object" && this.title_written !== true)
    {
      // determine which title to use
      if (typeof th_title === "undefined")
      {
        th_title = typeof ths.title.title_abbrv !== "undefined" && ths.title.title_abbrv instanceof String && ths.title.title_abbrv.length > 0 ? ths.title.title_abbrv : ths.title.title;
      }

      // set width of window based on title length
      if (options['type'] === "title")
      {
//        window.maxSVGWidth = 30+(ths.title.location.length>th_title.length ? ths.title.location.length : th_title.length)*5+50;
        window.maxSVGHeight = 50;
      }

      // add the titles to the svg
      if (typeof window.maxSVGWidth !== "undefined")
      {
        this.SVGElement("text", {
          "x": (window.maxSVGWidth/2),
          "y": 20,
          "style": "font-size:15px;text-anchor:middle;"
        }).text(ths.title.location);

        this.SVGElement("text", {
          "x": (window.maxSVGWidth/2),
          "y": 40,
          "style": "font-size:15px;text-anchor:middle;"
        }).text( th_title );

        if (options['type'] === "title")
        {
          delete th_title;
          return ;
        }

        delete th_title;
        this.title_written = true;
      }
      ths.y_s = 50;
    }


    // get max length of indicator name so can set width of window accordingly
    foreach(json.data, function(index, value){
      if(value.indicator_name_abbrv.length>ths.max_ind_width)
        ths.max_ind_width = value.indicator_name_abbrv.length;
      if(value.value>ths.max_value_width)
        ths.max_value_width = value.value;
    });

    var svgElements = new Array;
    foreach(json.data.slice(0, options.limit !== undefined ? options.limit : json.data.length), function(i, value){
      svgElements.__({});
      if (options.type === "summary_data"){
        // create horizontal bars
        svgElements[svgElements.length-1]['Rect'] = [{
          "x": 10,
          "y": ths.y_s+i*ths.dist,
          "width": 10,
          "height": 10,
          "style": "fill:"+value.color
        },{
          "x": 30+ths.max_ind_width*7+60,
          "y": ths.y_s+i*ths.dist,
          "width": ths.max/100*value.value,
          "height": 10,
          "style": "fill:#5c81a3"
        }];



//        window.maxSVGWidth = 30+ths.max_ind_width*7+80+ths.max/100*json.data[0].value+10;
        window.summaryWidthDone = true;
      }
//      else if (value.indicator_name_abbrv !== gon.no_data_text && typeof window.summaryWidthDone === "undefined")
//        window.maxSVGWidth = (30+ths.max_ind_width*7+10)+(ths.max_value_width.toString().length*7+50);
//      else
//        window.maxSVGWidth = 30+ths.max_ind_width*7+10+gon.no_data_text.length*7+50;


      window.makeline = true;

      if (window.makeline)
      {
        svgElements[svgElements.length-1]['Line'] = {
          "x1": 10,
          "y1": ths.y_s+ths.i*ths.dist+15,
          "x2": window.maxSVGWidth-10,
          "y2": ths.y_s+ths.i*ths.dist+15,
          "style": "stroke-width:1px;stroke:#CCC"
        };

      }


      // write out name and value
      svgElements[svgElements.length-1]['Text'] = [[{
          "x": 30,
          "y": ths.y_s+10+ths.i*ths.dist,
          "style": "font-size:12px;",
          "class": "title",
          "fullText": value.indicator_name
        }, value.indicator_name_abbrv],
        [{
          "x": 30+ths.max_ind_width*7+10,
          "y": ths.y_s+10+ths.i*ths.dist,
          "style": "font-size:12px;"
        }, value.value+(value.number_format === null ? "" : value.number_format)]];


        ths.i++;

        window.maxSVGHeight = ths.y_s+10+ths.i*ths.dist+10;
    });

    // write out the svg elements
    foreach(svgElements, function(index, value){
      foreach(value, function(ind, val){
         if (val instanceof Array)
            foreach(val, function(the_ind, the_val){
              if (ind.toLowerCase().search("text") !== -1)
                ths.SVGElement(ind.toLowerCase(), the_val[0]).text(the_val[1]);
              else
                ths.SVGElement(ind.toLowerCase(), the_val);
            });
         else
          ths.SVGElement(ind.toLowerCase(), val);
      });
    });



};

MapPopup.prototype.processJSON = function(id_el, json, options)
{

  var ths = this;
  ths.title = json.slice(0, 1);
  json = json.slice(1);

  if (json instanceof Array && json.length>0)
  {
    foreach(json, function(index, value){
      if (typeof value.summary_data === "object")
      {

        foreach(value.summary_data, function(ind, val){
          val.value = val.formatted_value;
        });
        options['type'] = "summary_data";
        json.data = value.summary_data;
      }
      else if (typeof value.data_item === "object")
      {
        options['type'] = "data_item";
        json = {};
        json.data = [{
          indicator_name_abbrv: value.data_item.indicator_name,
          indicator_name: value.data_item.indicator_name,
          number_format: value.data_item.number_format,
          value: value.data_item.formatted_value
        }];

      }

      ths.processTheType(id_el, json, options);

    });
  }
  else
  {
    options['type'] = "title";
    ths.processTheType(id_el, json, options);
  }

    //var title_texts = document.getElementsByClassName("title");
    //foreach(title_texts, function(index, value){
    //  svgtipsify(value, 150, 30, "tipsy");
    //});
};
*/

// get the pixel width of text
// by placing the text in a span tag
// and getting the span tag's width
function get_text_width(string, font_size){
	// if no font_size provided, use defautl of 12px
	if (typeof font_size == 'undefined' ) font_size = '12px';
	$("span#hidden_span_width").text(string);
	$("span#hidden_span_width").css("font-size", font_size);
	return $("span#hidden_span_width").width();
}

function unhighlight_shape(feature)
{
  feature.style = f_style_backup;
  feature.layer.redraw();
}


function mapFreeze(feature)
{
  map.controls[2].deactivate();
  makeFeaturePopup(feature, true, true, function(){
    map.controls[2].activate();
    unhighlight_shape(feature);
  });

}



$(document).mouseover(function(e){
  window.mouse = {
    X: e.pageX,
    Y: e.pageY
  };
});
