# encoding: utf-8
# Locales **************************************************************************

ActiveRecord::Base.connection.execute("TRUNCATE locales") 

Locale.create(:language => 'ka' , :name => 'ქართული')
Locale.create(:language => 'en' , :name => 'English')

