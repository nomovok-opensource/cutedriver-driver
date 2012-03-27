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

module TDriverReportCreator
  include TDriverErrorRecovery
  include TDriverCustomErrorRecovery

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
    @_stored_details=[]
    clean_video_files

    if $tdriver_reporter == nil
      initialize_error_recovery
      $run_status_thread_active=false
      $test_case_run_index=0
      $tdriver_reporter=TestRun.new
      $tdriver_reporter.initialize_tdriver_report_folder()
      $tdriver_report_created=false
      $current_tdriver_report_folder=$tdriver_reporter.report_folder

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
        if $new_test_case!=nil
          if $new_test_case.test_case_ended==false
            end_test_case($new_test_case.test_case_name,@tc_status)
          end
        end
        puts 'Generating report summary...'
        exit_status=''
  
        exit_status << "Stderr:#{$stderr}<hr/>"
        exit_status << "Stdout:#{$stdout}<hr/>"
        exit_status << "Exit command:#{$!}<br/>"
        exit_status << "Backtrace:#{$@}"
        
        $tdriver_reporter.update_summary_page('finished',exit_status)
        puts 'Summary generated...'
        puts 'Generating total run table...'
        $tdriver_reporter.update_test_case_summary_pages('all')
        puts 'Total run table generated...'
        if $tdriver_reporter.report_exclude_passed_cases=='false'
          puts 'Generating passed cases table...'
          $tdriver_reporter.update_test_case_summary_pages('passed')
          puts 'Passed table generated...'
        end
        puts 'Generating failed cases table...'
        $tdriver_reporter.update_test_case_summary_pages('failed')
        puts 'Failed table generated...'
        puts 'Generating not run cases table...'
        $tdriver_reporter.update_test_case_summary_pages('not run')
        puts 'Not run table generated...'
        puts 'Generating statistics table...'
        $tdriver_reporter.update_test_case_summary_pages('statistics')
        puts 'Statistics generated...'
        puts 'Grouping results by result and name...'
        $tdriver_reporter.group_results_by_test_case()
        puts 'Tests grouped by result and name...'
        if $parameters[ :create_run_table_csv, false ]=='true'
          puts 'Generating CSV...'
          $tdriver_reporter.create_csv
          puts 'CSV generated...'
        end
        puts 'Generating Junit xml...'
        $new_junit_xml_results.create_junit_xml()
        puts 'Junit generated...'
        #$tdriver_reporter.delete_result_storage()
        $tdriver_reporter.disconnect_connected_devices()
        $tdriver_reporter.update_tdriver_log_page()
        puts 'Report generated to:'
        puts $tdriver_reporter.report_folder()
        clean_video_files
        ending_test_set_run if $parameters[ :custom_error_recovery_module, nil ]!=nil
        if $tdriver_reporter.total_failed.to_i > 0
          Kernel.exit(1)
        elsif $tdriver_reporter.total_run.to_i == 0
          Kernel.exit(1)
        elsif $tdriver_reporter.total_not_run.to_i > 0
          Kernel.exit(1)
        end
      }
    else
      initialize_error_recovery
    end
    starting_test_set_run if $parameters[ :custom_error_recovery_module, nil ]!=nil
  end
  #This method registers a connection error
  #
  # === params
  # status: last test case result
  # === returns
  # nil
  # === raises
  def error_in_connection_detected
    error_in_connection if $parameters[ :custom_error_recovery_module, nil ]!=nil
    $tdriver_reporter.connection_errors+=1 if $tdriver_reporter
    $new_test_case.connection_errors+=1 if $new_test_case
    $new_test_case.set_test_case_execution_log('<b style="color: #FF0000">WARNING: Connection error detected!</b>') if $new_test_case
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
    groups=$parameters[ :report_groups, nil ]
    unless groups == nil
      groups_ar=groups.split('|')
      groups_ar.each do |group|
        group_ar=group.split(':')
        group_ar.each do |group_name|
          found_in_group=group_name if test_case_name.include? group_name
        end
      end
    else
      found_in_group=$new_test_case.test_case_group
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
    group=extract_group_from_test_case_name($new_test_case.test_case_name_full)
    current_status=''
    if(status=='failed')
      current_status=$tdriver_reporter.fail_statuses.first
      $tdriver_reporter.set_total_failed(1)
    end
    if(status=='passed')
      current_status=$tdriver_reporter.pass_statuses.first
      $tdriver_reporter.set_total_passed(1)
    end
    if(status!='passed' && status!='failed')

      current_status=$tdriver_reporter.not_run_statuses.first
      $tdriver_reporter.set_total_not_run(1)
    end

    $tdriver_reporter.write_to_result_storage(
      current_status,
      test_case_name,
      group,
      reboots,
      crashes,
      $new_test_case.test_case_start_time,
      $new_test_case.test_case_chronological_view_data,
      $new_test_case.test_case_run_time,
      $new_test_case.tc_memory_amount_end,
      $new_test_case.test_case_index,
      execution_log,
      '',
      '',
      $new_test_case.test_case_total_dump_count,
      $new_test_case.test_case_total_data_sent,
      $new_test_case.test_case_total_data_received,
      $new_test_case.test_case_user_data,      
      $new_test_case.test_case_user_data_columns,
      $new_test_case.connection_errors
    )

    $tdriver_reporter.test_case_user_xml_data=Hash.new
    $tdriver_reporter.set_end_time(Time.now)
    $tdriver_reporter.set_total_run(1)
    $tdriver_reporter.update_summary_page('inprogress')
    $tdriver_reporter.update_environment_page()
    if $parameters[ :realtime_status_page_update, false ]=='true'
      if $run_status_thread_active == false
        $run_status_thread_active=true
        Thread.new do
          begin
            #Update test case summary pages
            $tdriver_reporter.update_test_case_summary_pages('all')
            $tdriver_reporter.update_test_case_summary_pages('passed') if $tdriver_reporter.report_exclude_passed_cases=='false'
            $tdriver_reporter.update_test_case_summary_pages('failed')
            $tdriver_reporter.update_test_case_summary_pages('not run')
            $tdriver_reporter.update_test_case_summary_pages('statistics')
            $tdriver_reporter.group_results_by_test_case()
            $new_junit_xml_results.create_junit_xml()
            $tdriver_reporter.update_tdriver_log_page()
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


  #This method updates the current test case user data
  #
  # === params
  #
  # === returns
  # nil
  # === raises
  def update_test_case_user_data()
    if $new_test_case != nil
      user_data_rows, user_data_cols=$tdriver_reporter.get_user_data
      $new_test_case.set_test_case_user_data(user_data_rows, user_data_cols)
      chronological_data_rows=$tdriver_reporter.test_case_user_chronological_table_data
      $new_test_case.set_test_case_chronological_view_data(chronological_data_rows)
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
    if $new_test_case!=nil
      if $new_test_case.test_case_ended==false
        end_test_case($new_test_case.test_case_name,@tc_status)
      end
    end
    $test_case_run_index=$test_case_run_index.to_i+1
    $new_test_case=TestCaseRun.new
    $new_test_case.set_test_cases_folder($current_tdriver_report_folder.to_s+'/cases')
    $new_test_case.set_test_case_name(test_case.to_s)
    $new_test_case.set_test_case_start_time(Time.now)
    $new_test_case.set_test_case_index($test_case_run_index.to_i)
    $new_test_case.test_case_dump_count_at_start=$tdriver_reporter.total_dump_count.clone
    $new_test_case.test_case_data_sent_at_start=$tdriver_reporter.total_sent_data.clone
    $new_test_case.test_case_data_received_at_start=$tdriver_reporter.total_received_data.clone

    create_test_case_folder('result')
    begin
      if start_error_recovery()==true
        $tdriver_reporter.set_total_device_resets(1)
        $new_test_case.set_test_case_reboots(1)
      end
    rescue Exception => e
      update_test_case("Error recovery failed Exception: #{e.message} Backtrace: #{e.backtrace}")
      end_test_case($new_test_case.test_case_name,'failed')
      exit(1)
    end
    $new_test_case.read_crash_monitor_settings()

    $new_test_case.read_file_monitor_settings()

    $new_test_case.clean_crash_files_from_sut() if $test_case_run_index==1 && $parameters[ :report_crash_file_monitor_crash_file_cleanup, false ]=='true'

    amount_of_crash_files=$new_test_case.check_if_crash_files_exist()

    if amount_of_crash_files.to_i > 0
      $new_test_case.capture_crash_files()
      $new_test_case.clean_crash_files_from_sut()
      $tdriver_reporter.set_total_crash_files(amount_of_crash_files.to_i)
      $new_test_case.set_test_case_crash_files(amount_of_crash_files.to_i)
    else
      if $parameters[ :report_crash_file_monitor_confirm_any_crash_note, false ]=='true'
        $new_test_case.confirm_crash_notes
      end
    end

    amount_of_files=$new_test_case.check_if_files_exist()
    if amount_of_files.to_i > 0
      $new_test_case.capture_files()
      $new_test_case.clean_files_from_sut()
      $tdriver_reporter.set_total_crash_files(amount_of_files.to_i)
      $new_test_case.set_test_case_crash_files(amount_of_files.to_i)
    end

    if $parameters[ :report_monitor_memory, 'false']=='true'
      begin
        TDriver::SUTFactory.connected_suts.each do |sut_id, sut_attributes|
          $new_test_case.set_tc_memory_amount_total($tdriver_reporter.get_sut_total_memory(sut_id,sut_attributes))
          $new_test_case.set_tc_memory_amount_start($tdriver_reporter.get_sut_used_memory(sut_id,sut_attributes))
        end
      rescue
        $new_test_case.set_tc_memory_amount_total(0)
        $new_test_case.set_tc_memory_amount_start(0)
      end
    end
    logging_enabled = MobyUtil::Logger.instance.enabled
    begin

      if $parameters[:report_video, "false"] != "false"
        # copy previous recording
        MobyUtil::Logger.instance.enabled=false

        each_video_device do | video_device, device_index |
          begin
            FileUtils.mv(tdriver_report_folder() + "/cam_" + device_index + "_" + @_video_file_name, tdriver_report_folder() + "/cam_" + device_index + "_" + @_previous_video_file_name )
          rescue
            # do nothing..
          end

        end
        $new_test_case.start_video_recording( @_video_file_name, @_previous_video_file_name )

        MobyUtil::Logger.instance.enabled=logging_enabled

      end
    rescue Exception => e

    ensure
      MobyUtil::Logger.instance.enabled=logging_enabled
    end
    update_test_case_user_data()
    starting_test_case(test_case, TDriver::SUTFactory.connected_suts) if $parameters[ :custom_error_recovery_module, nil ]!=nil
  end
  #This method updates the current test case execution log
  #
  # === params
  # details: details to be added in to the execution log
  # === returns
  # nil
  # === raises
  def update_test_case(details)
    if $new_test_case==nil
      @_stored_details << details
    else
      if @_stored_details!=[] && @_stored_details!=nil
        @_stored_details.each do |detail|
          $new_test_case.set_test_case_execution_log(detail)
        end
        $new_test_case.set_test_case_execution_log(details,true)
        @_stored_details=[]
      else
        $new_test_case.set_test_case_execution_log(details,true)
      end
      updating_test_case_details(details) if $parameters[ :custom_error_recovery_module, nil ]!=nil
      if  $parameters[ :report_monitor_memory, 'false']=='true'
        begin
          start_memory=$new_test_case.tc_memory_amount_start()
          if start_memory=='-'
            TDriver::SUTFactory.connected_suts.each do |sut_id, sut_attributes|
              memory=$tdriver_reporter.get_sut_used_memory(sut_id,sut_attributes)
              $new_test_case.set_tc_memory_amount_start(memory)
            end
          end
        rescue
          $new_test_case.set_tc_memory_amount_start(0)
        end
      end
    end
  end


  #This method creates or renames the test case folder
  #
  # === params
  # test_case: the test case name
  # status: status of the test case
  # === returns
  # nil
  # === raises
  def create_test_case_folder(status)
    if $new_test_case!=nil
      if $new_test_case.test_case_folder==nil
        $new_test_case.create_test_case_folder(status)
      else
        $new_test_case.rename_test_case_folder(status)
      end
    end
  end

  #This method takes a screenshot of current test case execution
  #
  # === params
  # === returns
  # nil
  # === raises
  def capture_screen_test_case()
    begin
      create_test_case_folder($tdriver_reporter.fail_statuses.first)
      $new_test_case.capture_dump()
      error_in_test_case(TDriver::SUTFactory.connected_suts) if $parameters[ :custom_error_recovery_module, nil ]!=nil
    rescue => ex
      puts ex.message
      puts ex.backtrace
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
      TDriver::SUTFactory.connected_suts.each do |sut_id, sut_attributes|
        if sut_attributes[:is_connected]
          memory=$tdriver_reporter.get_sut_used_memory(sut_id,sut_attributes)
          $tdriver_reporter.get_sut_total_dump_count(sut_id,sut_attributes)
          $tdriver_reporter.get_sut_total_sent_data(sut_id,sut_attributes)
          $tdriver_reporter.get_sut_total_received_data(sut_id,sut_attributes)
          $new_test_case.set_tc_memory_amount_end(memory)
          $tdriver_reporter.set_memory_amount_end(memory)
        end
      end
    rescue
      $new_test_case.set_tc_memory_amount_end(0)
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
      if $parameters[:behaviour_logging] == 'true'
        if $new_test_case.test_case_logging_level.to_i > 0
          $tdriver_report_log_output.string.each do |line|
            $new_test_case.set_test_case_behaviour_log(line,nil)
            $tdriver_reporter.set_test_run_behaviour_log(line,$new_test_case.test_case_name_full)
          end
        end
      end
    rescue
    end
  end

  def calculate_execution_footprint_data_for_test_case
    TDriver::SUTFactory.connected_suts.each do |sut_id, sut_attributes|
      if sut_attributes[:is_connected]
        $tdriver_reporter.get_sut_total_dump_count(sut_id,sut_attributes)
        $tdriver_reporter.get_sut_total_sent_data(sut_id,sut_attributes)
        $tdriver_reporter.get_sut_total_received_data(sut_id,sut_attributes)
      end
    end

    $new_test_case.test_case_dump_count_at_end=$tdriver_reporter.total_dump_count
    $new_test_case.test_case_dump_count_at_end.each do |item|
      at_start=$new_test_case.test_case_dump_count_at_start[item[0]].to_i
      at_start=0 if at_start==nil
      at_end=item[1].to_i
      total=at_end-at_start
      $new_test_case.test_case_total_dump_count[item[0]]=total
    end

    $new_test_case.test_case_data_sent_at_end=$tdriver_reporter.total_sent_data
    $new_test_case.test_case_data_sent_at_end.each do |item|
      at_start=$new_test_case.test_case_data_sent_at_start[item[0]].to_i
      at_start=0 if at_start==nil
      at_end=item[1].to_i
      total=at_end-at_start
      $new_test_case.test_case_total_data_sent[item[0]]=total
    end

    $new_test_case.test_case_data_received_at_end=$tdriver_reporter.total_received_data
    $new_test_case.test_case_data_received_at_end.each do |item|
      at_start=$new_test_case.test_case_data_received_at_start[item[0]].to_i
      at_start=0 if at_start==nil
      at_end=item[1].to_i
      total=at_end-at_start
      $new_test_case.test_case_total_data_received[item[0]]=total
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
    $new_test_case.set_test_case_ended(true) if $new_test_case
    update_test_case_user_data()
    if $new_test_case != nil
      calculate_execution_footprint_data_for_test_case
      if $parameters[:report_crash_file_monitor] == 'true'
        found_crash_files = $new_test_case.check_if_crash_files_exist()
        if found_crash_files.to_i > 0
          $tdriver_reporter.set_total_crash_files(found_crash_files.to_i)
          $new_test_case.set_test_case_crash_files(found_crash_files.to_i)
          status='failed'
        end
      end
      if $parameters[:report_file_monitor] == 'true'
        found_files = $new_test_case.check_if_files_exist()
        if found_files.to_i > 0
          $tdriver_reporter.set_total_crash_files(found_files.to_i)
          $new_test_case.set_test_case_crash_files(found_files.to_i)
          status='failed' if $parameters[:report_fail_test_if_files_found]=='true'
        end
      end

      temp_rec = $new_test_case.video_recording?

      if temp_rec
        $new_test_case.stop_video_recording
      end
      if $tdriver_reporter.test_case_user_defined_status!=nil
        status=$tdriver_reporter.test_case_user_defined_status
        $tdriver_reporter.set_test_case_user_defined_status(nil)
      end
      if(status=='failed')
        $new_test_case.set_test_case_status($tdriver_reporter.fail_statuses.first)
        create_test_case_folder($tdriver_reporter.fail_statuses.first)
        if found_crash_files.to_i > 0
          $new_test_case.capture_crash_files()
        end
        if $new_test_case.video_recording?
          $new_test_case.copy_video_capture()
        end
      end
      if(status=='passed')

        no_activity_videos = ""
        if $parameters[:report_check_device_active, 'false']=='true'
          if temp_rec

            no_activity_videos = $new_test_case.target_video_alive
          end
        end

        if no_activity_videos == ""
          $new_test_case.set_test_case_status($tdriver_reporter.pass_statuses.first)
          create_test_case_folder($tdriver_reporter.pass_statuses.first)
        else
          # switch case to failed status
          status='failed'
          $new_test_case.copy_video_capture
          $new_test_case.update_test_case "The case failed due to video analysis (#{no_activity_videos}) indicating that the target is no longer responding."

          $new_test_case.set_test_case_status($tdriver_reporter.fail_statuses.first)
          create_test_case_folder($tdriver_reporter.fail_statuses.first)
          if found_crash_files.to_i > 0
            $new_test_case.capture_crash_files()
          end

        end

      end
      if(status!='passed' && status!='failed')
        $new_test_case.set_test_case_status($tdriver_reporter.not_run_statuses.first)
        create_test_case_folder($tdriver_reporter.not_run_statuses.first)
      end
      $new_test_case.set_test_case_end_time(Time.now)
      update_test_case_behaviour_log()
      update_test_case_memory_usage() if $parameters[ :report_monitor_memory, 'false']=='true'
      execution_log=$new_test_case.test_case_execution_log
      if $parameters[:report_trace_capture_only_in_failed_case, 'true']!='true'
        $new_test_case.capture_trace_files()
      else
        if status=='failed'
          $new_test_case.capture_trace_files()
        end
      end
      if found_files.to_i > 0
        $new_test_case.capture_files()
      end
      $new_test_case.update_test_case_page()
      $new_test_case.clean_files_from_sut()

      update_run($new_test_case.test_case_name.to_s,status,$new_test_case.test_case_reboots,$new_test_case.test_case_crash_files,execution_log)

      $new_junit_xml_results.add_test_result(status, $new_test_case.test_case_start_time, $new_test_case.test_case_end_time)
      tdriver_update_sequential_fails( status ) if $parameters[ :runner_sequence_skip, "false" ] == "true"

      $new_test_case=nil
      execution_log=nil

    end
    ending_test_case(status, TDriver::SUTFactory.connected_suts) if $parameters[ :custom_error_recovery_module, nil ]!=nil
  end
  def add_report_group(value)
    $tdriver_reporter.set_generic_reporting_groups(value)
  end
  def add_test_case_group(value)
    $new_test_case.set_test_case_group(value)
  end

  # Cleans any temporary files created by recording video
  def clean_video_files
    [ @_video_file_name, @_previous_video_file_name ].each do | file_name |

      each_video_device do | video_device, device_index |
        begin
          delete_file = tdriver_report_folder() + "/cam_" + device_index + "_" + file_name
          if File.exists?( delete_file )
            File.delete( delete_file )
          end
        rescue
          # delete failed, do nothing
        end
      end
    end
  end

  def each_video_device

    if $parameters[:report_video, nil] != nil

      device_index = 0
      $parameters[:report_video].split("|").each do | video_device |
        if !video_device.strip.empty?
          yield video_device.strip, device_index.to_s
          device_index += 1
        end
      end

    end

  end

end #TDriverReportCreator




