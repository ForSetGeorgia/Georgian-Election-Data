# ForSet's Election Data Application

This application was originally built by JumpStart for NDI. ForSet took over management of the application in 2017.

## Summary
The Election Data Application was built to show all of Georgia's elections and voters lists going back to 2006. This data is shown through maps, tables and charts. Everything is downloadable:
* data can be downloaded in spreadsheet format
* maps can be downloaded as images or vector files
* charts can be downloaded as images or vector files

### Data Types
The Election Data Application handles two types of data: elections and voters lists.

For elections, the data contains the percent of the votes that each political party received. In addition to seeing how each party did, the application also summarizes the election results to show the overall results. In addition to the voting results, the data also includes many other indicators that are directly from the protocols or are calculations based off of the data on the protocols. Here are some examples:
* total turnout (% and #)
* invalid ballots (% and #)
* votes per minute
* more ballots than votes
* more votes than ballots

For voters lists, the data in the application is a summary of all voters at a precinct and district level. Voters lists only have a few indicators:
* total voters
* average age
* potential duplicates
* 85-99 years old
* > 99 years old


### Maps
The maps have two levels: districts and precincts. All of the districts are shown by default. When you click on a district the map reloads showing the precincts in that district. To the right of the map is a list of all indicators that exist for the election or voters lists. When you click on an indicator the map will reload to show the results of that indicator.

The maps shows the indicator data in a choropleth format. There is a default choropleth color scheme, but this can be overriden for each indicator. The scales that determine which color to show has to be defined for each indicator at each map level.

The maps have a pop-up that appears when the user hovers over a district or precinct. The pop-up is customizable for each indicator at each map level.

The maps can also be downloaded into an SVG or PNG format.

The maps are rendered using [OpenLayers](http://openlayers.org/).



### Customizing
The application is full of rich features, but this also means that there are many options when it comes to setting up a new election or voter's list.




## Dependencies


# Software Requirements for Server


## Current Versions
Look at the Gemfile for a complete list.
* Ruby 2.3.4
* Rails 3.2.22
* Bootstrap 3
* Capistrano 2.12
* Devise 2.0.4
* Paperclip 3.4.0
* Unicorn 5.3
* MySql2 0.3.18


## Requirements
* git
* rbenv - to install and manage Ruby versions
* Ruby 2.3.4 - tested on 2.1.2 and 2.3.4
* nginx - for staging/production server
* mysql - for database
* dalli - for memory cache

Environment variables
You will need the following environment variables set in the `.env` file in the root folder. See the `.env.example` file for the complete list of variables that need to be set.
* DB_NAME - database name
* DB_USER - database user name
* DB_PASSWORD - database user password
* APPLICATION_FEEDBACK_TO_EMAIL - email address to send feedback (errors) to
* APPLICATION_FEEDBACK_FROM_EMAIL - email address to send all emails from
* APPLICATION_FEEDBACK_FROM_PWD - password of above email address
* APPLICATION_EMAIL_SMTP_ADDRESS - smtp address like smtp.gmail.com
* APPLICATION_EMAIL_DOMAIN - smtp email domain
* APPLICATION_EMAIL_URL_HOST - url that will be used to create links in emails
