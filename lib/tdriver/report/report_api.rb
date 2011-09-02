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


module TDriverReportAPI

  # This method returns all the current executed test by status
  #
  # === params
  # status_type: tests status
  # === returns
  # Array
  # === raises
  def tdriver_get_current_by_status( status_type )
    raise TypeError.new("Argument to method cannot be nil.") if status_type.nil?
    ret = []
    if $tdriver_reporter!=nil
      ret = $tdriver_reporter.parse_results_for_current_test(status_type)
    end
    return ret
  end

  # This method returns all the tests
  #
  # === params
  # status_type: tests status
  # === returns
  # Array
  # === raises
  def tdriver_get_status(status_type)
    raise TypeError.new("Argument to method cannot be nil.") if status_type.nil?
    ret = []
    if $tdriver_reporter!=nil
      ret = $tdriver_reporter.read_result_storage(status_type)
    end
    return ret
  end

  # This method returns all the sequential fails
  #
  # === params
  # nil
  # === returns
  # String
  # === raises
  def tdriver_get_sequential_fails    
    return $tdriver_reporter.get_sequential_fails if $tdriver_reporter
  end
  
  # This method updates the sequential fail status
  #
  # === params
  # status: fail status
  # === returns
  # nil
  # === raises
  def tdriver_update_sequential_fails( status )
     $tdriver_reporter.update_sequential_fails( status ) if $tdriver_reporter
  end

  # This method logs data to the test case
  #
  # === params
  # data: the data to be logged
  # === returns
  # nil
  # === raises
  def tdriver_log_data(data)
    raise TypeError.new("Argument to method cannot be nil.") if data.nil?
    if $tdriver_reporter!=nil
      $tdriver_reporter.set_user_data(data)
    end
  end

  # This method captures sut state to test case
  #
  # === params
  # capture_screen_shot: include screenshot to the capture
  # === returns
  # nil
  # === raises
  def tdriver_capture_state(capture_screen_shot=true)
    if $tdriver_reporter
      $new_test_case.capture_dump(capture_screen_shot) if $new_test_case
    end
  end

  # This method captures sut state to test case with comments
  #
  # === params
  # arguments: optional aguments
  # === returns
  # nil
  # === raises
  def tdriver_capture_screen(arguments=Hash.new)
    if $tdriver_reporter
      $new_test_case.capture_dump(true,arguments) if $new_test_case
    end
  end

  # This method logs data to the total run table
  #
  # === params
  # column_name: name of the column
  # value: value for the entry
  # === returns
  # nil
  # === raises
  def tdriver_log_data_in_total_run_table(column_name,value)
    raise TypeError.new("Argument to method cannot be nil.") if column_name.nil? || value.nil?
    if $tdriver_reporter!=nil
      $tdriver_reporter.set_user_table_data(column_name,value)
    end
  end

  # This method logs data test case details
  #
  # === params
  # message: message to be logged in to details(Supports html for formatting the entry)
  # === returns
  # nil
  # === raises
  def tdriver_report_log(message)
  	raise TypeError.new("Argument message was not a String.") unless message.nil? or message.kind_of?(String)
    if $tdriver_reporter
      $new_test_case.set_test_case_execution_log(message) if $new_test_case
    end
  end

  # This method changes the test case result
  #
  # === params
  # status: new test case status
  # === returns
  # nil
  # === raises
  def tdriver_report_set_test_case_status(status)
  	raise TypeError.new("Argument status was not a String.") unless status.nil? or status.kind_of?(String)
    if $tdriver_reporter!=nil
      $tdriver_reporter.set_test_case_user_defined_status(status)
    end
  end

  # This method returns how many tests has been executed
  #
  # === params
  # nil
  # === returns
  # Integer
  # === raises
  def tdriver_report_total_tests_run()
    total=0
    if $tdriver_reporter!=nil
      total=$tdriver_reporter.total_run
    end
    return total.to_i
  end

  # This method returns how many tests has passed
  #
  # === params
  # nil
  # === returns
  # Integer
  # === raises
  def tdriver_report_total_passed_tests()
    total=0
    if $tdriver_reporter!=nil
      total=$tdriver_reporter.total_passed
    end
    return total.to_i
  end

  # This method returns how many tests has failed
  #
  # === params
  # nil
  # === returns
  # Integer
  # === raises
  def tdriver_report_total_failed_tests()
    total=0
    if $tdriver_reporter!=nil
      total=$tdriver_reporter.total_failed
    end
    return total.to_i
  end

  # This method returns how many tests were not run
  #
  # === params
  # nil
  # === returns
  # Integer
  # === raises
  def tdriver_report_total_not_run_tests()
    total=0
    if $tdriver_reporter!=nil
      total=$tdriver_reporter.total_not_run
    end
    return total.to_i
  end

  # This method returns current report folder
  #
  # === params
  # nil
  # === returns
  # String
  # === raises
  def tdriver_report_folder()
    folder=nil
    if $tdriver_reporter!=nil
      folder=$tdriver_reporter.report_folder
    end
    return folder.to_s
  end

  # This method returns test case start time
  #
  # === params
  # nil
  # === returns
  # String
  # === raises
  def tdriver_report_start_time()
    start_time=nil
    if $tdriver_reporter!=nil
      start_time=$tdriver_reporter.start_time
    end
    return start_time.to_s
  end

  # This method current execution time
  #
  # === params
  # nil
  # === returns
  # String
  # === raises
  def tdriver_report_run_time()
    run_time=nil
    if $tdriver_reporter!=nil
      run_time=$tdriver_reporter.run_time
    end
    return run_time.to_s
  end

  # This method returns the amount of crash files
  #
  # === params
  # nil
  # === returns
  # Integer
  # === raises
  def tdriver_report_total_crash_files()
    crash_files=0
    if $tdriver_reporter!=nil
      crash_files=$tdriver_reporter.total_crash_files
    end
    return crash_files.to_i
  end

  # This method returns the amount of device resets
  #
  # === params
  # nil
  # === returns
  # Integer
  # === raises
  def tdriver_report_total_device_resets()
    device_resets=0
    if $tdriver_reporter!=nil
      device_resets=$tdriver_reporter.total_device_resets
    end
    return device_resets.to_i
  end

  # This method can combine previous results to the current execution
  #
  # === params
  # nil
  # === returns
  # Integer
  # === raises
  def tdriver_report_combine_reports(reports)
    if $tdriver_reporter!=nil
      $tdriver_reporter.combine_results(reports)
    else
      require 'tdriver'
      include TDriverReportCreator
      start_run
      $tdriver_reporter.combine_results(reports)
    end
  end

  # This method returns the amount of device resets
  #
  # === params
  # nil
  # === returns
  # Integer
  # === raises
  def tdriver_report_current_test_case_dir()
    test_case_path=''
    if $new_test_case!=nil
      test_case_path=$new_test_case.test_case_folder
    end
    return test_case_path.to_s
  end
  

end #TDriverReportAPI




