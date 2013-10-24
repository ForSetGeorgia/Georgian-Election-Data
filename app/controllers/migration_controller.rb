class MigrationController < ApplicationController
  require 'net/http'
  require "open-uri"

  def from_protocols_app
Rails.logger.debug "***********************************"    
Rails.logger.debug "***********  from protocols app start"    
Rails.logger.debug "***********************************"    
    success = false
    return_msg = nil
    msg = nil
    
    if params[:respond_to_url].present?
Rails.logger.debug "************* respond_to_url = #{params[:respond_to_url]}"    
    
      if params[:event_id].present? && params[:file_url].present? && 
          params[:precincts_completed].present? && params[:precincts_total].present?
          
Rails.logger.debug "************* required params provided"    
        
        # get file
Rails.logger.debug "************* getting file at #{params[:file_url]}"    
        file_name = params[:file_url].split('/').last
        file = open(params[:file_url])
        
        timestamp = Time.now
        
Rails.logger.debug "************* processing file"    
        Datum.transaction do
          # process the data
		      msg = Datum.build_from_csv(params[:event_id],
							    Datum::DATA_TYPE[:live],
                  params[:precincts_completed],
                  params[:precincts_total],
                  timestamp,
				          file)

          if msg.present?
Rails.logger.debug "************* errors!"    
            # errors occurred
            return_msg = I18n.t('app.msgs.upload.error', :file_name => file_name, :msg => msg)
          else
Rails.logger.debug "************* no errors"    
            # no errors
            success = true

            # find the dataset and turn it on
            ds = DataSet.where(:event_id => params[:event_id], :timestamp => timestamp, :data_type => Datum::DATA_TYPE[:live],
              :precincts_completed => params[:precincts_completed], :precincts_total => params[:precincts_total])
              
            if ds.present?
Rails.logger.debug "************* making dataset visible"    
              ds.first.show_to_public = true
              ds.first.save
            else
Rails.logger.debug "************* could not find dataset to make visible"    
              return_msg = "The data was loaded but the dataset could not be found to turn on to the public"
            end
          end
        end      
      else
Rails.logger.debug "************* missing params"    
        #require params not provided
        return_msg = I18n.t('app.msgs.missing_parameters')
      end
  
Rails.logger.debug "************* sending response to #{params[:respond_to_url]}"    
      # send notification back of result
      uri = URI(params[:respond_to_url])
      res = Net::HTTP.post_form(uri, {'success' => success, 'msg' => return_msg, 'file_url' => params[:file_url]})
    end
    render text: "OK"
  end

end
