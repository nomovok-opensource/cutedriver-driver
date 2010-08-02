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

  def tdriver_log_data(data)
    Kernel::raise ArgumentError.new("Argument to method cannot be nil.") if data.nil?
    if $tdriver_reporter!=nil
      $tdriver_reporter.set_user_data(data)
    end
  end
  
  def tdriver_log_data_in_total_run_table(column_name,value)
    Kernel::raise ArgumentError.new("Argument to method cannot be nil.") if column_name.nil? || value.nil?
    if $tdriver_reporter!=nil
      $tdriver_reporter.set_user_table_data(column_name,value)
    end
  end
  
  def tdriver_report_log(message)
  	Kernel::raise ArgumentError.new("Argument message was not a String.") unless message.nil? or message.kind_of?(String)
    if $tdriver_reporter!=nil
      $tdriver_reporter.set_log(message)
    end
  end
  def tdriver_report_set_test_case_status(status)
  	Kernel::raise ArgumentError.new("Argument status was not a String.") unless status.nil? or status.kind_of?(String)
    if $tdriver_reporter!=nil
      $tdriver_reporter.set_test_case_user_defined_status(status)
    end
  end
  def tdriver_report_total_tests_run()
    total=0
    if $tdriver_reporter!=nil
      total=$tdriver_reporter.get_total_run
    end
    return total.to_i
  end
  def tdriver_report_total_passed_tests()
    total=0
    if $tdriver_reporter!=nil
      total=$tdriver_reporter.get_total_passed
    end
    return total.to_i
  end
  def tdriver_report_total_failed_tests()
    total=0
    if $tdriver_reporter!=nil
      total=$tdriver_reporter.get_total_failed
    end
    return total.to_i
  end
  def tdriver_report_total_not_run_tests()
    total=0
    if $tdriver_reporter!=nil
      total=$tdriver_reporter.get_total_not_run
    end
    return total.to_i
  end
  def tdriver_report_folder()
    folder=nil
    if $tdriver_reporter!=nil
      folder=$tdriver_reporter.get_report_folder
    end
    return folder.to_s
  end
  def tdriver_report_start_time()
    start_time=nil
    if $tdriver_reporter!=nil
      start_time=$tdriver_reporter.get_start_time
    end
    return start_time.to_s
  end
  def tdriver_report_run_time()
    run_time=nil
    if $tdriver_reporter!=nil
      run_time=$tdriver_reporter.get_run_time
    end
    return run_time.to_s
  end
  def tdriver_report_total_crash_files()
    crash_files=0
    if $tdriver_reporter!=nil
      crash_files=$tdriver_reporter.get_total_crash_files
    end
    return crash_files.to_i
  end
  def tdriver_report_total_device_resets()
    device_resets=0
    if $tdriver_reporter!=nil
      device_resets=$tdriver_reporter.get_total_device_resets
    end
    return device_resets.to_i
  end
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

  #old api methods

  def matti_log_data(data)
    file, line = caller.first.split(":")
    $stdout.puts "%s:%s warning: method deprecated" % [ file, line]
    tdriver_log_data(data)
  end
  def matti_report_log(message)
    file, line = caller.first.split(":")
    $stdout.puts "%s:%s warning: method deprecated" % [ file, line]
  	tdriver_report_log(message)
  end
  def matti_report_set_test_case_status(status)
    file, line = caller.first.split(":")
    $stdout.puts "%s:%s warning: method deprecated" % [ file, line]
  	tdriver_report_set_test_case_status(status)
  end
  def matti_report_total_tests_run()
    file, line = caller.first.split(":")
    $stdout.puts "%s:%s warning: method deprecated" % [ file, line]
    tdriver_report_total_tests_run()
  end
  def matti_report_total_passed_tests()
    file, line = caller.first.split(":")
    $stdout.puts "%s:%s warning: method deprecated" % [ file, line]
    tdriver_report_total_passed_tests()
  end
  def matti_report_total_failed_tests()
    file, line = caller.first.split(":")
    $stdout.puts "%s:%s warning: method deprecated" % [ file, line]
    tdriver_report_total_failed_tests()
  end
  def matti_report_total_not_run_tests()
    file, line = caller.first.split(":")
    $stdout.puts "%s:%s warning: method deprecated" % [ file, line]
    tdriver_report_total_not_run_tests()
  end
  def matti_report_folder()
    file, line = caller.first.split(":")
    $stdout.puts "%s:%s warning: method deprecated" % [ file, line]
    tdriver_report_folder()
  end
  def matti_report_start_time()
    file, line = caller.first.split(":")
    $stdout.puts "%s:%s warning: method deprecated" % [ file, line]
    tdriver_report_start_time()
  end
  def matti_report_run_time()
    file, line = caller.first.split(":")
    $stdout.puts "%s:%s warning: method deprecated" % [ file, line]
    tdriver_report_run_time()
  end
  def matti_report_total_crash_files()
    file, line = caller.first.split(":")
    $stdout.puts "%s:%s warning: method deprecated" % [ file, line]
    tdriver_report_total_crash_files()
  end
  def matti_report_total_device_resets()
    file, line = caller.first.split(":")
    $stdout.puts "%s:%s warning: method deprecated" % [ file, line]
    tdriver_report_total_device_resets()
  end
  def matti_report_combine_reports(reports)
    file, line = caller.first.split(":")
    $stdout.puts "%s:%s warning: method deprecated" % [ file, line]
    tdriver_report_combine_reports(reports)
  end
  
  
end #TDriverReportAPI

module MattiReportAPI

  include TDriverReportAPI

end

 