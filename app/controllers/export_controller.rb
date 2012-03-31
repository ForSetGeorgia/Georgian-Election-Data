class ExportController < ActionController::Base
	protect_from_forgery
	
	# ExportController Helper Methods
		def CreateExportFile filename
			svg_file = File.new(File.dirname(__FILE__)+"/../../public/assets/"+filename,"w")					
				svg_file.puts(params[:data])
			svg_file.close
		end	
	# ---------------------------------
		def NokogiriParseExportFile filename
			svg_file = File.open(File.dirname(__FILE__)+"/../../public/assets/"+filename,"r")
			 nokogiri_svg = Nokogiri::XML(svg_file)
			 
			  # Change svg background
			  	bg_rect = Nokogiri::XML::Node.new("rect",nokogiri_svg)
			  	bg_rect['x'] = "0"
					bg_rect['y'] = "0"
					bg_rect['fill'] = "#ede6dc"
					bg_rect['width'] = "100%"
					bg_rect['height'] = "100%"
					nokogiri_svg.at_css("svg").children.first.add_previous_sibling(bg_rect)
			 	# Make linear gradient
				 	linear_gradient = Nokogiri::XML::Node.new("linearGradient",nokogiri_svg)
				 	linear_gradient['id'] = "SVGID_1_"
				 	linear_gradient['gradientUnits'] = "userSpaceOnUse"
				 	linear_gradient['x1'] = "125"
				 	linear_gradient['y1'] = "0"
				 	linear_gradient['x2'] = "125"
				 	linear_gradient['y2'] = "68.0005"
				 	nokogiri_svg.at_css("svg") << linear_gradient
			 	# Fill linear gradient
			 		stop = []
			 		stop[0] = Nokogiri::XML::Node.new("stop",nokogiri_svg)
			 		stop[0]['offset'] = "0"
			 		stop[0]['style'] = "stop-color:#FFFFFF"
			 		
			 		stop[1] = Nokogiri::XML::Node.new("stop",nokogiri_svg)
			 		stop[1]['offset'] = "0.2436"
			 		stop[1]['style'] = "stop-color:#B5B5B5"
			 		
			 		stop[2] = Nokogiri::XML::Node.new("stop",nokogiri_svg)
			 		stop[2]['offset'] = "0.5167"
			 		stop[2]['style'] = "stop-color:#686868"
			 		
			 		stop[3] = Nokogiri::XML::Node.new("stop",nokogiri_svg)
			 		stop[3]['offset'] = "0.7428"
			 		stop[3]['style'] = "stop-color:#303030"
			 		
			 		stop[4] = Nokogiri::XML::Node.new("stop",nokogiri_svg)
			 		stop[4]['offset'] = "0.91"
			 		stop[4]['style'] = "stop-color:#0D0D0D"
			 		
			 		stop[5] = Nokogiri::XML::Node.new("stop",nokogiri_svg)
			 		stop[5]['offset'] = "1"
			 		stop[5]['style'] = "stop-color:#000000"
			 		
			 		stop.each do |the_stop|
			 			nokogiri_svg.at_css("linearGradient#SVGID_1_") << the_stop
			 		end
			 	# Make paths
			 		path = Nokogiri::XML::Node.new("path",nokogiri_svg)
			 		path['opacity'] = "0.5"
			 		path['fill'] = "url(#SVGID_1_)"
			 		path['d'] = "M250,66c0,1.104-0.896,2-2,2H2c-1.104,0-2-0.896-2-2V2c0-1.104,0.896-2,2-2h246
	c1.104,0,2,0.896,2,2V66z"
					nokogiri_svg.at_css("svg") << path
				# Make rects
					rect = []
					
					rect[0] = Nokogiri::XML::Node.new("rect",nokogiri_svg) 
					rect[0]['x'] = "18.499"
					rect[0]['y'] = "7.5"
					rect[0]['fill'] = "#F9BA14"
					rect[0]['width'] = "14.166"
					rect[0]['height'] = "14.167"
					
					rect[1] = Nokogiri::XML::Node.new("rect",nokogiri_svg) 
					rect[1]['x'] = "18.499"
					rect[1]['y'] = "25.667"
					rect[1]['fill'] = "#ED6F19"
					rect[1]['width'] = "14.166"
					rect[1]['height'] = "14.167"
					
					rect[2] = Nokogiri::XML::Node.new("rect",nokogiri_svg) 
					rect[2]['x'] = "18.499"
					rect[2]['y'] = "43.833"
					rect[2]['fill'] = "#E63019"
					rect[2]['width'] = "14.166"
					rect[2]['height'] = "14.166"
					
					rect[3] = Nokogiri::XML::Node.new("rect",nokogiri_svg) 
					rect[3]['x'] = "127.166"
					rect[3]['y'] = "7.5"
					rect[3]['fill'] = "#F39416"
					rect[3]['width'] = "14.166"
					rect[3]['height'] = "14.167"
					
					rect[4] = Nokogiri::XML::Node.new("rect",nokogiri_svg) 
					rect[4]['x'] = "127.166"
					rect[4]['y'] = "25.667"
					rect[4]['fill'] = "#E84C19"
					rect[4]['width'] = "14.166"
					rect[4]['height'] = "14.167"
					
					rect[5] = Nokogiri::XML::Node.new("rect",nokogiri_svg) 
					rect[5]['x'] = "127.166"
					rect[5]['y'] = "43.833"
					rect[5]['fill'] = "#E41D19"
					rect[5]['width'] = "14.166"
					rect[5]['height'] = "14.166"
				
					rect.each do |the_rect|
						nokogiri_svg.at_css("svg") << the_rect
					end
				# Make texts
					text = []
					
					text[0] = Nokogiri::XML::Node.new("text",nokogiri_svg)
					text[0]['x'] = "40"
					text[0]['y'] = "20"
					text[0]['tranform'] = "matrix(1 0 0 1 38.999 20)"
					text[0]['fill'] = "#FFFFFF"
					text[0]['font-family'] = "'Verdana'"
					text[0]['font-size'] = "12"
					text[0].content = "No Data"
					
					text[1] = Nokogiri::XML::Node.new("text",nokogiri_svg)
					text[1]['x'] = "40"
					text[1]['y'] = "38"
					text[1]['tranform'] = "matrix(1 0 0 1 38.999 38.25)"
					text[1]['fill'] = "#FFFFFF"
					text[1]['font-family'] = "'Verdana'"
					text[1]['font-size'] = "12"
					text[1].content = "10%-20%"
					
					text[2] = Nokogiri::XML::Node.new("text",nokogiri_svg)
					text[2]['x'] = "40"
					text[2]['y'] = "56"
					text[2]['tranform'] = "matrix(1 0 0 1 38.999 56.499)"
					text[2]['fill'] = "#FFFFFF"
					text[2]['font-family'] = "'Verdana'"
					text[2]['font-size'] = "12"
					text[2].content = "30%-40%"
					
					text[3] = Nokogiri::XML::Node.new("text",nokogiri_svg)
					text[3]['x'] = "148"
					text[3]['y'] = "20"
					text[3]['tranform'] = "matrix(1 0 0 1 146.165 20)"
					text[3]['fill'] = "#FFFFFF"
					text[3]['font-family'] = "'Verdana'"
					text[3]['font-size'] = "12"
					text[3].content = "0%-10%"
					
					text[4] = Nokogiri::XML::Node.new("text",nokogiri_svg)
					text[4]['x'] = "148"
					text[4]['y'] = "38"
					text[4]['tranform'] = "matrix(1 0 0 1 146.165 38.25)"
					text[4]['fill'] = "#FFFFFF"
					text[4]['font-family'] = "'Verdana'"
					text[4]['font-size'] = "12"
					text[4].content = "20%-30%"
					
					text[5] = Nokogiri::XML::Node.new("text",nokogiri_svg)
					text[5]['x'] = "148"
					text[5]['y'] = "56"
					text[5]['tranform'] = "matrix(1 0 0 1 146.165 56.499)"
					text[5]['fill'] = "#FFFFFF"
					text[5]['font-family'] = "'Verdana'"
					text[5]['font-size'] = "12"
					text[5].content = "40%-50%"
					
					text.each do |the_text|					
						nokogiri_svg.at_css("svg") << the_text
					end			
			svg_new = nokogiri_svg.to_s
			svg_file_n = File.open(File.dirname(__FILE__)+"/../../public/assets/"+filename,"w+")
				svg_file_n.puts svg_new
			svg_file_n.close
			svg_file.close			
		end
	# End ExportController Helper Methods
		
	def index
		# Ruby switch case to determine the request type
		case params[:type]
			when "svg" then							
				CreateExportFile "map.svg"
				NokogiriParseExportFile "map.svg"			
				render :nothing => true						  
			else
				render :nothing => true				
		end
		
	end
	
end
