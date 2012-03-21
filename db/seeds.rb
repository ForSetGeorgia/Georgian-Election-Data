# encoding: utf-8
# Locales **************************************************************************

ActiveRecord::Base.connection.execute("TRUNCATE locales") 

Locale.create(:language => 'ka' , :name => 'ქართული')
Locale.create(:language => 'en' , :name => 'English')

ActiveRecord::Base.connection.execute("TRUNCATE event_types") 
ActiveRecord::Base.connection.execute("TRUNCATE event_type_translations") 

EventType.create(:event_type_translations_attributes => {"0"=>{:name=>"არჩევნები", :locale=>"ka"}, "1"=>{:name=>"Elections", :locale=>"en"}})
EventType.create(:event_type_translations_attributes => {"0"=>{:name=>"ამომრჩეველთა სია", :locale=>"ka"}, "1"=>{:name=>"Voters List", :locale=>"en"}})

ActiveRecord::Base.connection.execute("TRUNCATE shape_types") 
ActiveRecord::Base.connection.execute("TRUNCATE shape_type_translations") 

ShapeType.create(:shape_type_translations_attributes => {"0"=>{:name=>"ქვეყანა", :locale=>"ka"}, "1"=>{:name=>"Country", :locale=>"en"}})
ShapeType.create(:shape_type_translations_attributes => {"0"=>{:name=>"რეგიონში", :locale=>"ka"}, "1"=>{:name=>"Region", :locale=>"en"}})
ShapeType.create(:shape_type_translations_attributes => {"0"=>{:name=>"რაიონის", :locale=>"ka"}, "1"=>{:name=>"District", :locale=>"en"}})
ShapeType.create(:shape_type_translations_attributes => {"0"=>{:name=>"საუბნო", :locale=>"ka"}, "1"=>{:name=>"Precinct", :locale=>"en"}})

