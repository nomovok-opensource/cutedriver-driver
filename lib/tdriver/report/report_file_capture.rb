############################################################################
##
## Copyright (C) 2010 Nokia Corporation and/or its subsidiary(-ies).
## All rights reserved.
## Contact: Nokia Corporation (testabilitydriver@nokia.com)
##
## This file is part of Testability Driver.
##
## If you have questions regarding the use of this file, please contact
## Nokia at testabilitydriver@nokia.com .
##
## This library is free software; you can redistribute it and/or
## modify it under the terms of the GNU Lesser General Public
## License version 2.1 as published by the Free Software Foundation
## and appearing in the file LICENSE.LGPL included in the packaging
## of this file.
##
############################################################################



module TDriverReportFileCapture
  def initialize
    @file_locations=Array.new
    @file_suts=Array.new
    @file_names=Array.new
    @file_count=0
    @monitor_files='false'
    read_file_monitor_settings()
  end

  def return_settings_value_array(setting)
    setting_value=setting
    setting_arr=Array.new
    setting_arr=setting_value.split(',')
    setting_arr
  end

  def read_file_monitor_settings()
    @file_locations=return_settings_value_array($parameters[ :report_file_locations, nil ])
    @file_suts=return_settings_value_array($parameters[ :report_file_monitored_sut_ids, nil ])
    @file_names=return_settings_value_array($parameters[ :report_file_names, nil ])
    @clean_files=$parameters[ :report_clean_files_from_sut_after_capture, 'true' ]
    @monitor_files = $parameters[ :report_file_monitor, 'false' ]
  end

  def clean_files_from_sut()

    if @monitor_files == 'true' && @clean_files == 'true'
      MobyBase::SUTFactory.instance.connected_suts.each do |sut_id, sut_attributes|
        if sut_attributes[:is_connected]
          @file_suts.each do |monitored_sut|
            if monitored_sut == sut_id.to_s
              sut_files=Array.new
              sut_files=list_sut_files(sut_attributes[:sut])
              sut_files.each do |file|
                delete_file(sut_attributes[:sut],file)
              end
            end
          end
        end
      end
    end
  end

  def list_sut_files(current_sut)
    file_arr=Array.new
    @file_count=0
    #for every location:
    @file_locations.each do |location|
      begin
        #get file names
        current_location_files=Array.new
        @file_names.each do |file_name|
          current_location_files = current_sut.list_files_from_sut( :from => location, :file=> file_name.to_s )
          #collect crash names and add paths
          current_location_files.each do |sut_file|
            #if file_is_file(sut_file)
            file_arr << sut_file.to_s
            @file_count+=1
            #end
          end
        end
      rescue => ex
        #puts ex.message
      end
    end
    file_arr
  end

  def download_file(current_sut,file_name,download_folder)
    begin
      current_sut.copy_from_sut(:file => file_name, :to => download_folder )
    rescue => ex
      #puts ex.message
    end
  end

  def delete_file(current_sut,file_name)
    begin
      current_sut.delete_from_sut(:file => file_name )
    rescue => ex
      #puts ex.message
    end
  end

  def check_if_files_exist()
    sut_files=Array.new
    if @monitor_files == 'true'
      MobyBase::SUTFactory.instance.connected_suts.each do |sut_id, sut_attributes|
        if sut_attributes[:is_connected]
          @file_suts.each do |monitored_sut|
            if monitored_sut == sut_id.to_s
              sut_files << list_sut_files(sut_attributes[:sut])
            end
          end
        end
      end
      @file_count
    else
      @file_count
    end
  end

  def download_files(download_folder)
    if @monitor_files == 'true'
      MobyBase::SUTFactory.instance.connected_suts.each do |sut_id, sut_attributes|
        if sut_attributes[:is_connected]
          @file_suts.each do |monitored_sut|
            if monitored_sut == sut_id.to_s
              sut_files=Array.new
              sut_files=list_sut_files(sut_attributes[:sut])
              sut_files.each do |file|
                download_file(sut_attributes[:sut],file,download_folder.gsub("\\",'/')+'/')
              end
            end
          end
        end
      end
    end
  end

  def capture_files()
    if @monitor_files == 'true'
      begin
        dump_folder=@test_case_folder+'/files'
        if File::directory?(dump_folder)==false
          FileUtils.mkdir_p dump_folder
        end
        download_files(dump_folder)
      rescue Exception => e
        @test_case_execution_log=@test_case_execution_log.to_s + '<br />' + "Unable to capture files: " + e.message + e.backtrace.to_s
      end
    end
  end
end



