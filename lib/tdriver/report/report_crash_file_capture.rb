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




class TDriverReportCrashFileCapture
  include TDriverReportFileCapture
  def initialize
    @crash_file_locations=Array.new
    @crash_file_suts=Array.new
    @crash_file_names=Array.new
    @crash_file_count=0
    @monitor_crash_files='false'
    read_crash_monitor_settings()
    read_file_monitor_settings()
  end

  def return_settings_value_array(setting)
    setting_value=setting
    setting_arr=Array.new
    setting_arr=setting_value.split(',')
    setting_arr
  end

  def read_crash_monitor_settings()
    @crash_file_locations=return_settings_value_array(MobyUtil::Parameter[ :report_crash_file_locations, nil ])
    @crash_file_suts=return_settings_value_array(MobyUtil::Parameter[ :report_crash_file_monitored_sut_ids, nil ])
    @crash_file_names=return_settings_value_array(MobyUtil::Parameter[ :report_crash_file_names, nil ])
    @monitor_crash_files = MobyUtil::Parameter[ :report_crash_file_monitor, 'false' ]
  end

  def clean_crash_files_from_sut()
    if @monitor_crash_files == 'true'
      MobyBase::SUTFactory.instance.connected_suts.each do |sut_id, sut_attributes|
        if sut_attributes[:is_connected]
          @crash_file_suts.each do |monitored_sut|
            if monitored_sut == sut_id.to_s
              sut_crash_files=Array.new
              sut_crash_files=list_sut_crash_files(sut_attributes[:sut])
              sut_crash_files.each do |crash_file|
                delete_crash_file(sut_attributes[:sut],crash_file[0])
              end
            end
          end
        end
      end
    end
  end

  def list_sut_crash_files(current_sut)
    crash_file_arr=Array.new
    @crash_file_count=0
    #for every location:
    @crash_file_locations.each do |location|
          begin
          #get file names
          current_location_files = current_sut.ftp( :Command => :List_files, :Remote_dir => location )
          #collect crash names and add paths
          current_location_files.each do |sut_file|
            if file_is_crash_file(sut_file)
              crash_file_arr << [location.gsub("/",'\\')+'\\'+sut_file.to_s,sut_file.to_s]
              @crash_file_count+=1
            end
          end
          rescue => ex
             #puts ex.message
          end
    end
    crash_file_arr
  end

  def download_crash_file(current_sut,file_name,download_folder,download_file)
    begin
      current_sut.ftp( :Command => :Download, :Local_filename => download_folder+download_file, :Remote_filename => file_name )
    rescue => ex
       #puts ex.message
    end
  end

  def delete_crash_file(current_sut,file_name)
    begin
      current_sut.ftp( :Command => :Delete, :Remote_filename => file_name )
    rescue => ex
       #puts ex.message
    end
  end

  def file_is_crash_file(file_name)
     is_crash_file=false
     @crash_file_names.each do |crash_file_identity|
       if file_name.to_s.include? crash_file_identity.to_s
         is_crash_file=true
       end
     end
     is_crash_file
  end

  def check_if_crash_files_exist()
    sut_crash_files=Array.new
    if @monitor_crash_files == 'true'
      MobyBase::SUTFactory.instance.connected_suts.each do |sut_id, sut_attributes|
        if sut_attributes[:is_connected]
          @crash_file_suts.each do |monitored_sut|
            if monitored_sut == sut_id.to_s
              sut_crash_files << list_sut_crash_files(sut_attributes[:sut])
            end
          end
        end
      end
      @crash_file_count
    else
      @crash_file_count
    end
  end

  def download_crash_files(download_folder)
   if @monitor_crash_files == 'true'
      MobyBase::SUTFactory.instance.connected_suts.each do |sut_id, sut_attributes|
        if sut_attributes[:is_connected]
          @crash_file_suts.each do |monitored_sut|
            if monitored_sut == sut_id.to_s
              sut_crash_files=Array.new
              sut_crash_files=list_sut_crash_files(sut_attributes[:sut])
              sut_crash_files.each do |crash_file|
                download_crash_file(sut_attributes[:sut],crash_file[0],download_folder.gsub("/",'\\')+'\\',crash_file[1])
                delete_crash_file(sut_attributes[:sut],crash_file[0])
              end
              sut_attributes[:sut].clear_crash_notes(5)
            end
          end
        end
      end
    end
  end

  def capture_crash_files()
    if @monitor_crash_files == 'true'
      begin
        dump_folder=@test_case_folder+'/crash_files'
        if File::directory?(dump_folder)==false
          FileUtils.mkdir_p dump_folder
        end
        download_crash_files(dump_folder)
      rescue Exception => e
         @test_case_execution_log=@test_case_execution_log.to_s + '<br />' + "Unable to capture crash files: " + e.message
      end
    end
  end
end



