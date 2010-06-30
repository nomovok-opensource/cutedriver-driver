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





class ReportCombine
    #This method combines previous test results with the current test execution
    #
    # === params
    # status: last run test case
    # === returns
    # nil
    # === raises
    def copy_results_from_directory(report_dir)
      current_working_dir=Dir.getwd
      if File::directory?(report_dir)==true
         #FileUtils.cp_r report_dir, @report_folder
         FileUtils.cp_r report_dir+'/cases', @report_folder
         FileUtils.copy(report_dir+'/failed_cases.xml',@report_folder+'/failed_cases.xml') if File.exist?(report_dir+'/failed_cases.xml')
         FileUtils.copy(report_dir+'/passed_cases.xml',@report_folder+'/passed_cases.xml') if File.exist?(report_dir+'/passed_cases.xml')
         FileUtils.copy(report_dir+'/all_cases.xml',@report_folder+'/all_cases.xml') if File.exist?(report_dir+'/all_cases.xml')
         FileUtils.copy(report_dir+'/not_run_cases.xml',@report_folder+'/not_run_all_cases.xml') if File.exist?(report_dir+'/not_run_cases.xml')
      end
      Dir.chdir(report_dir+'/cases')
      executed_tests=Dir['*/']

      @total_passed=read_result_storage('passed').count
      @total_failed=read_result_storage('failed').count
      @total_not_run=read_result_storage('not run').count
      @total_run=read_result_storage('all').count
      
      $test_case_run_index+=executed_tests.count.to_i
      
      report_arr=report_dir.split( /[\/|\\]+/)      
      #include folder in to the current run
      @attached_test_reports << report_arr.last

      Dir.chdir(current_working_dir)
    end

    #This copies and reads the previous results data
    #
    # === params
    # status: last run test case
    # === returns
    # nil
    # === raises
    def extract_results_from_directory(report_dir)      
      if File::directory?(report_dir)==true
        copy_results_from_directory(report_dir)
      end
    end

    #This method combines previous test results with the current test execution
    #
    # === params
    # status: last run test case
    # === returns
    # nil
    # === raises
    def combine_results(reports)
      report_locations_arr=reports.split(',')
      report_locations_arr.each do |report_location|
        extract_results_from_directory(report_location)
      end
    end

end
