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


require File.expand_path( File.join( File.dirname( __FILE__ ), 'report_junit_xml' ) )
require File.expand_path( File.join( File.dirname( __FILE__ ), 'report_api' ) )
require File.expand_path( File.join( File.dirname( __FILE__ ), 'report_test_run' ) )
require File.expand_path( File.join( File.dirname( __FILE__ ), 'report_test_case_run' ) )
require File.expand_path( File.join( File.dirname( __FILE__ ), 'error_recovery/tdriver_error_recovery' ) )
require File.expand_path( File.join( File.dirname( __FILE__ ), 'report_data_presentation' ) )

module TDriverReportCreator
  include TDriverErrorRecovery
  #This method initializes new test run
  #
  # === params
  # nil
  # === returns
  # nil
  # === raises
  def start_run()

    @_video_file_name = "failed_test.avi"
    @_previous_video_file_name = "previous_test.avi"
    clean_video_files

    if $tdriver_reporter == nil
      initialize_error_recovery
      $run_status_thread_active=false
      $test_case_run_index=0
      $tdriver_reporter=TestRun.new
      $tdriver_reporter.initialize_tdriver_report_folder()
      $tdriver_report_created=false
      $current_tdriver_report_folder=$tdriver_reporter.get_report_folder
      
      $new_junit_xml_results=ReportJUnitXml.new($current_tdriver_report_folder)
      $tdriver_reporter.set_end_time(Time.now)
      $tdriver_reporter.set_total_failed(0)
      $tdriver_reporter.set_total_passed(0)
      $tdriver_reporter.set_total_not_run(0)
      $tdriver_reporter.set_total_run(0)
      $tdriver_reporter.update_summary_page('inprogress')
      $tdriver_reporter.update_environment_page()
      at_exit {
        while $run_status_thread_active == true
          sleep 1
        end
        puts 'Generating report summary...'
        $tdriver_reporter.update_summary_page('finished')
        $tdriver_reporter.update_test_case_summary_pages('all')
        $tdriver_reporter.update_test_case_summary_pages('passed')
        $tdriver_reporter.update_test_case_summary_pages('failed')
        $tdriver_reporter.update_test_case_summary_pages('not run')
        $tdriver_reporter.update_test_case_summary_pages('statistics')
        $tdriver_reporter.create_csv if MobyUtil::Parameter[ :create_run_table_csv, false ]=='true'
        $new_junit_xml_results.create_junit_xml()
        #$tdriver_reporter.delete_result_storage()
        $tdriver_reporter.disconnect_connected_devices()
        #tdriver_log_page $tdriver_reporter.update_tdriver_log_page()
        puts 'Report generated to:'
        puts $tdriver_reporter.get_report_folder()
        clean_video_files
        if $tdriver_reporter.get_total_failed.to_i > 0
          Kernel.exit(1)
        elsif $tdriver_reporter.get_total_run.to_i == 0
          Kernel.exit(1)
        elsif $tdriver_reporter.get_total_not_run.to_i > 0
          Kernel.exit(1)
        end
      }
    else
      initialize_error_recovery
    end
  end
  #This method returns the group where the test case belongs
  #
  # === params
  # status: last test case result
  # === returns
  # nil
  # === raises
  def extract_group_from_test_case_name(test_case_name)
    found_in_group='not_in_any_user_defined_group'
    groups=MobyUtil::Parameter[ :report_groups, nil ]
    unless groups == nil
      groups_ar=groups.split('|')
      groups_ar.each do |group|
        group_ar=group.split(':')
        group_ar.each do |group_name|
          found_in_group=group_name if test_case_name.include? group_name
        end
      end
    else
      found_in_group=@new_test_case.get_test_case_group()
    end
    found_in_group
  end
  #This method updates the current test run status
  #
  # === params
  # status: last test case result
  # === returns
  # nil
  # === raises
  def update_run(test_case_name,status,reboots,crashes,execution_log)
    group=extract_group_from_test_case_name(@new_test_case.get_test_case_name_full)
    current_status=''
    if(status=='failed')
      current_status=$tdriver_reporter.get_failed_status
      $tdriver_reporter.set_total_failed(1)
    end
    if(status=='passed')
      current_status=$tdriver_reporter.get_passed_status
      $tdriver_reporter.set_total_passed(1)
    end
    if(status!='passed' && status!='failed')
      
      current_status=$tdriver_reporter.get_not_run_status
      $tdriver_reporter.set_total_not_run(1)
    end
    
     $tdriver_reporter.write_to_result_storage(current_status,test_case_name,group,reboots,crashes,
      @new_test_case.get_test_case_start_time,
      @new_test_case.get_test_case_chronological_view_data,
      @new_test_case.get_test_case_run_time,
      @new_test_case.get_tc_memory_amount_end,
      @new_test_case.get_test_case_index,
      execution_log)
    $tdriver_reporter.set_end_time(Time.now)
    $tdriver_reporter.set_total_run(1)
    $tdriver_reporter.update_summary_page('inprogress')
    $tdriver_reporter.update_environment_page()
    if MobyUtil::Parameter[ :realtime_status_page_update, false ]=='true'
      if $run_status_thread_active == false
        $run_status_thread_active=true
        Thread.new do
          begin
            $tdriver_reporter.update_test_case_summary_pages('all')
            $tdriver_reporter.update_test_case_summary_pages('passed')
            $tdriver_reporter.update_test_case_summary_pages('failed')
            $tdriver_reporter.update_test_case_summary_pages('not run')
            $tdriver_reporter.update_test_case_summary_pages('statistics')
            $new_junit_xml_results.create_junit_xml()
            #tdriver_log_page $tdriver_reporter.update_tdriver_log_page()
            #ML: Update summary every 10 seconds improves performance during execution
            sleep 10
            $run_status_thread_active=false
            GC.start
          rescue Exception => e
            $run_status_thread_active=false
          end
        end
      end
    end
  end
  #This method updates the current test case user log
  #
  # === params
  # details: details to be added in to the execution log
  # === returns
  # nil
  # === raises
  def update_test_case_user_log()
    user_log=$tdriver_reporter.get_log
    if user_log != []
      user_log.each do |log_entry|
        @new_test_case.set_test_case_execution_log(log_entry)
      end
      $tdriver_reporter.set_log(nil)
    end
  end
  
  
  #This method updates the current test case user data
  #
  # === params
  # 
  # === returns
  # nil
  # === raises
  def update_test_case_user_data()
    if @new_test_case != nil
      user_data_rows, user_data_cols=$tdriver_reporter.get_user_data
      @new_test_case.set_test_case_user_data(user_data_rows, user_data_cols)
      chronological_data_rows=$tdriver_reporter.get_user_chronological_table_data
      @new_test_case.set_test_case_chronological_view_data(chronological_data_rows)
      $tdriver_reporter.set_user_data(nil)
      $tdriver_reporter.set_user_chronological_table_data(nil)
    end
  end
  
  #This method starts a new test case run
  #
  # === params
  # test_case: the new test case name
  # === returns
  # nil
  # === raises
  def start_test_case(test_case)
    $test_case_run_index=$test_case_run_index.to_i+1
    @new_test_case=TestCaseRun.new
    @new_test_case.set_test_cases_folder($current_tdriver_report_folder.to_s+'/cases')
    @new_test_case.set_test_case_name(test_case.to_s)
    @new_test_case.set_test_case_start_time(Time.now)
    @new_test_case.set_test_case_index($test_case_run_index.to_i)
    if start_error_recovery()==true
      $tdriver_reporter.set_total_device_resets(1)
      @new_test_case.set_test_case_reboots(1)
    end
    @new_test_case.read_crash_monitor_settings()
    @new_test_case.read_file_monitor_settings()

    @new_test_case.clean_crash_files_from_sut()
    @new_test_case.clean_files_from_sut()
    begin
      MobyBase::SUTFactory.instance.connected_suts.each do |sut_id, sut_attributes|
        @new_test_case.set_tc_memory_amount_total($tdriver_reporter.get_sut_total_memory(sut_id,sut_attributes))
        @new_test_case.set_tc_memory_amount_start($tdriver_reporter.get_sut_used_memory(sut_id,sut_attributes))
      end
    rescue
      @new_test_case.set_tc_memory_amount_total(0)
      @new_test_case.set_tc_memory_amount_start(0)
    end
    logging_enabled = MobyUtil::Logger.instance.enabled
    begin
      if MobyUtil::Parameter[:report_video] == "true"
        # copy previous recording        
        MobyUtil::Logger.instance.enabled=false

        begin
          File.copy( @_video_file_name, @_previous_video_file_name )
        rescue
          # do nothing..
        end

        @new_test_case.start_video_recording( @_video_file_name, @_previous_video_file_name )

        MobyUtil::Logger.instance.enabled=logging_enabled

      end
    rescue Exception => e

    ensure
      MobyUtil::Logger.instance.enabled=logging_enabled
    end
    update_test_case_user_log()
    update_test_case_user_data()
  end
  #This method updates the current test case execution log
  #
  # === params
  # details: details to be added in to the execution log
  # === returns
  # nil
  # === raises
  def update_test_case(details)
    update_test_case_user_log()
    @new_test_case.set_test_case_execution_log(details)
    begin
      start_memory=@new_test_case.get_tc_memory_amount_start()
      if start_memory==0
        MobyBase::SUTFactory.instance.connected_suts.each do |sut_id, sut_attributes|
          memory=$tdriver_reporter.get_sut_used_memory(sut_id,sut_attributes)
          @new_test_case.set_tc_memory_amount_start(memory)
        end
      end
    rescue
      @new_test_case.set_tc_memory_amount_start(0)
    end
  end


  #This method takes a screenshot of current test case execution
  #
  # === params
  # test_case: the test case name
  # status: status of the test case
  # === returns
  # nil
  # === raises
  def capture_screen_test_case()
    @new_test_case.create_test_case_folder($tdriver_reporter.get_failed_status)
    if start_error_recovery()==true
      $tdriver_reporter.set_total_device_resets(1)
      @new_test_case.set_test_case_reboots(1)
    end
    @new_test_case.capture_failed_dump()
    if @new_test_case.video_recording?
      @new_test_case.copy_video_capture()
    end
  end
  #This updates the test case behaviour log
  #
  # === params
  # === returns
  # nil
  # === raises
  def update_test_case_memory_usage()
    begin
      MobyBase::SUTFactory.instance.connected_suts.each do |sut_id, sut_attributes|
        memory=$tdriver_reporter.get_sut_used_memory(sut_id,sut_attributes)
        @new_test_case.set_tc_memory_amount_end(memory)
        $tdriver_reporter.set_memory_amount_end(memory)
      end
    rescue
      @new_test_case.set_tc_memory_amount_end(0)
    end
  end
  #This updates the test case behaviour log
  #
  # === params
  # === returns
  # nil
  # === raises
  def update_test_case_behaviour_log()
    begin
      if MobyUtil::Parameter[:behaviour_logging] == 'true'
        if @new_test_case.get_test_case_logging_level.to_i > 0
          $tdriver_report_log_output.string.each do |line|
            @new_test_case.set_test_case_behaviour_log(line,nil)
            #tdriver_log_page $tdriver_reporter.set_test_run_behaviour_log(line,full_tc_name)
          end
        end
      end
    rescue
    end
  end
  #This method ends the current test case execution
  #
  # === params
  # test_case: the test case name
  # status: status of the test case
  # === returns
  # nil
  # === raises
  def end_test_case(test_case,status)
    update_test_case_user_log()
    update_test_case_user_data()
    if @new_test_case != nil
      if MobyUtil::Parameter[:report_crash_file_monitor] == 'true'
        found_crash_files = @new_test_case.check_if_crash_files_exist()
        if found_crash_files.to_i > 0
          $tdriver_reporter.set_total_crash_files(found_crash_files.to_i)
          @new_test_case.set_test_case_crash_files(found_crash_files.to_i)
          status='failed'
        end
      end
      if MobyUtil::Parameter[:report_file_monitor] == 'true'
        found_files = @new_test_case.check_if_files_exist()
        if found_files.to_i > 0
          $tdriver_reporter.set_total_crash_files(found_files.to_i)
          @new_test_case.set_test_case_crash_files(found_files.to_i)
          status='failed' if MobyUtil::Parameter[:report_fail_test_if_files_found]=='true'
        end
      end
      if @new_test_case.video_recording?
        @new_test_case.stop_video_recording
      end
      if $tdriver_reporter.get_test_case_user_defined_status!=nil
        status=$tdriver_reporter.get_test_case_user_defined_status
        $tdriver_reporter.set_test_case_user_defined_status(nil)
      end
      if(status=='failed')
        @new_test_case.set_test_case_status($tdriver_reporter.get_failed_status)
        @new_test_case.create_test_case_folder($tdriver_reporter.get_failed_status)
        if found_crash_files.to_i > 0
          @new_test_case.capture_crash_files()
        end
      end
      if(status=='passed')
        @new_test_case.set_test_case_status($tdriver_reporter.get_passed_status)
        @new_test_case.create_test_case_folder($tdriver_reporter.get_passed_status)
      end
      if(status!='passed' && status!='failed')
        @new_test_case.set_test_case_status($tdriver_reporter.get_not_run_status)
        @new_test_case.create_test_case_folder($tdriver_reporter.get_not_run_status)
      end
      @new_test_case.set_test_case_end_time(Time.now)
      update_test_case_behaviour_log()
      update_test_case_memory_usage()
      execution_log=@new_test_case.get_test_case_execution_log      
      if MobyUtil::Parameter[:report_trace_capture_only_in_failed_case, 'true']!='true'
        @new_test_case.capture_trace_files() 
      else
        if status=='failed'
          @new_test_case.capture_trace_files() 
        end
      end
      if found_files.to_i > 0
        @new_test_case.capture_files()
      end
      @new_test_case.update_test_case_page()
      @new_test_case.clean_crash_files_from_sut()
      @new_test_case.clean_files_from_sut()

      update_run(@new_test_case.get_test_case_name.to_s,status,@new_test_case.get_test_case_reboots,@new_test_case.get_test_case_crash_files,execution_log)
      $new_junit_xml_results.add_test_result(status, @new_test_case.get_test_case_start_time, @new_test_case.get_test_case_end_time)
      
      @new_test_case=nil
      execution_log=nil

    end
  end
  def add_report_group(value)
    $tdriver_reporter.set_generic_reporting_groups(value)
  end
  def add_test_case_group(value)
    @new_test_case.set_test_case_group(value)
  end

  # Cleans any temporary files created by recording video
  def clean_video_files
    [ @_video_file_name, @_previous_video_file_name ].each do | file_name |
      begin
        if File.exists?( file_name )
          File.delete( file_name )
        end
      rescue
        # delete failed, do nothing
      end
    end
  end


end #TDriverReportCreator
require File.expand_path( File.join( File.dirname( __FILE__ ), 'report_cucumber' ) )
require File.expand_path( File.join( File.dirname( __FILE__ ), 'report_cucumber_listener' ) )
require File.expand_path( File.join( File.dirname( __FILE__ ), 'report_rspec' ) )
require File.expand_path( File.join( File.dirname( __FILE__ ), 'report_test_unit' ) )


 