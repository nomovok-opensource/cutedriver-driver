############################################################################
## 
## Copyright (C) 2010 Nokia Corporation and/or its subsidiary(-ies). 
## All rights reserved. 
## Contact: Nokia Corporation (testabilitydriver@nokia.com) 
## 
## This file is part of TDriver.
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

require File.expand_path( File.join( File.dirname( __FILE__ ), 'report_writer' ) )
require File.expand_path( File.join( File.dirname( __FILE__ ), 'report_combine' ) )
require File.expand_path( File.join( File.dirname( __FILE__ ), 'report_data_table' ) )
module TDriverReportCreator

  #Test run class for new test run
  class TestRun < ReportCombine
    include TDriverReportWriter
    include ReportDataTable
    #class variables for summary report
    def initialize()
      @report_folder=nil
      @reporting_groups=nil
      @generic_reporting_groups=''
      @start_time=nil
      @end_time=nil
      @run_time=nil
      @total_run=0
      @total_passed=0
      @total_failed=0
      @total_not_run=0
      @total_crash_files=0
      @total_device_resets=0
      @test_case_user_defined_status=nil
      @test_run_behaviour_log = Array.new
      @test_run_user_log = Array.new
      @test_case_user_data=Array.new
      @test_case_user_data_columns = Array.new
      @test_case_user_chronological_table_data = Hash.new
      @attached_test_reports = Array.new
      @report_pages_ready=Array.new
      @memory_amount_start='-'
      @memory_amount_end='-'
      @memory_amount_total='-'
      $result_storage_in_use=false
      @pages=MobyUtil::Parameter[ :report_results_per_page, 10]
      @pass_statuses=MobyUtil::Parameter[ :report_passed_statuses, "passed" ].split('|')
      @fail_statuses=MobyUtil::Parameter[ :report_failed_statuses, "failed" ].split('|')
      @not_run_statuses=MobyUtil::Parameter[ :report_not_run_statuses, "not run" ].split('|')
      @report_editable=MobyUtil::Parameter[ :report_editable, "false" ]
    end
    #This method sets the test case user defined status
    #
    # === params
    # value: test case status
    # === returns
    # nil
    # === raises
    def set_test_case_user_defined_status(value)
      @test_case_user_defined_status=value
    end
    #This method sets user created log
    #
    # === params
    # value: test run execution log entry
    # === returns
    # nil
    # === raises
    def set_log(value)
      if value==nil
        @test_run_user_log=nil
        @test_run_user_log=Array.new
      else
        @test_run_user_log << ["USER LOG: #{value.to_s}"]
      end
    end
    #This method adds user data
    #
    # === params
    # value: the data to be added an array or hash
    # === returns
    # nil
    # === raises
    # TypeError exception
    def set_user_data(value)
      if value==nil        
        @test_case_user_data = Array.new
        @test_case_user_data_columns = Array.new
      else
        raise TypeError.new( 'Input parameter not of Type: Hash or Array.\nIt is: ' + value.class.to_s ) unless value.kind_of?( Hash ) || value.kind_of?( Array )
        if value.kind_of?( Hash )
          add_data_from_hash(value,@test_case_user_data,@test_case_user_data_columns)
        end
        if value.kind_of?( Array )
          add_data_from_array(value,@test_case_user_data,@test_case_user_data_columns)
        end
      end
    end
    #This method adds user table data
    #
    # === params
    # column_name: the column name in chronological table
    # value: the data 
    # === returns
    # nil
    # === raises
    def set_user_table_data(column_name,value)
      if (!column_name.empty? && column_name!=nil)
        @test_case_user_chronological_table_data[column_name.to_s]=value.to_s 
      end
    end
    #This method sets the test run behaviour log
    #
    # === params
    # value: test run execution log entry
    # === returns
    # nil
    # === raises
    def set_test_run_behaviour_log(value,test_case)
      @test_run_behaviour_log << [value.to_s,test_case]
    end
    #This method sets generic reporting groups
    #
    # === params
    #
    # === returns
    # nil
    # === raises
    def set_generic_reporting_groups(value)
      if check_if_group_exists_groups(@generic_reporting_groups,value)==false
        @generic_reporting_groups=@generic_reporting_groups+value
      end
      get_reporting_groups()
    end
    #This method sets the report folder value
    #
    # === params
    # value: test set report folder
    # === returns
    # nil
    # === raises
    def set_report_folder(value)
      @report_folder=value
    end
    #This method sets the test run start time
    #
    # === params
    # value: test set start time
    # === returns
    # nil
    # === raises
    def set_start_time(value)
      @start_time=value
    end
    #This method sets the test run end time
    #
    # === params
    # value: test set end time
    # === returns
    # nil
    # === raises
    def set_end_time(value)
      @end_time=value
    end
    #This method sets the test run run time
    #
    # === params
    # value: test set run time
    # === returns
    # nil
    # === raises
    def set_run_time(value)
      @run_time=value
    end
    #This method sets the total tests run
    #
    # === params
    # value: total run value
    # === returns
    # nil
    # === raises
    def set_total_run(value)
      if value==1
        @total_run=@total_run.to_i+1
      else
        @total_run=value
      end
    end
    #This method sets the total passed tests run
    #
    # === params
    # value: total passed value
    # === returns
    # nil
    # === raises
    def set_total_passed(value)
      if value==1
        @total_passed=@total_passed.to_i+1
      else
        @total_passed=value
      end
    end
    #This method sets the total failed tests run
    #
    # === params
    # value: total failed value
    # === returns
    # nil
    # === raises
    def set_total_failed(value)
      if value==1
        @total_failed=@total_failed.to_i+1
      else
        @total_failed=value
      end
    end
    #This method sets the total amount of not run cases
    #
    # === params
    # value: total not run value
    # === returns
    # nil
    # === raises
    def set_total_not_run(value)
      if value==1
        @total_not_run=@total_not_run.to_i+1
      else
        @total_not_run=value
      end
    end
    #This method sets the total amount of found crash files
    #
    # === params
    # value: total not run value
    # === returns
    # nil
    # === raises
    def set_total_crash_files(value)
      @total_crash_files=@total_crash_files.to_i+value.to_i
    end
    #This method sets the total amount of device resets
    #
    # === params
    # value: total not run value
    # === returns
    # nil
    # === raises
    def set_total_device_resets(value)
      @total_device_resets=@total_device_resets.to_i+value.to_i
    end

    #This method sets the memory amount end
    #
    # === params
    #
    # === returns
    # nil
    # === raises
    def set_memory_amount_end(value)
      @memory_amount_end=value
    end
    #This method sets the memory amount start
    #
    # === params
    #
    # === returns
    # nil
    # === raises
    def set_memory_amount_start(value)
      @memory_amount_start=value
    end
    #This method sets the memory amount total
    #
    # === params
    #
    # === returns
    # nil
    # === raises
    def set_memory_amount_total(value)
      @memory_amount_total=value
    end
    #This method gets the report folder
    #
    # === params
    # nil
    # === returns
    # report folder object
    # === raises
    def get_report_folder()
      @report_folder
    end        
    #This method gets the test set start time
    #
    # === params
    # nil
    # === returns
    # start time object
    # === raises
    def get_start_time()
      @start_time
    end
    #This method gets the test set end time
    #
    # === params
    # nil
    # === returns
    # end time object
    # === raises
    def get_end_time()
      @end_time
    end
    #This method gets the test set run time
    #
    # === params
    # nil
    # === returns
    # run time object
    # === raises
    def get_run_time()
      @run_time
    end
    #This method gets the test set total tests run
    #
    # === params
    # nil
    # === returns
    # total tests run object
    # === raises
    def get_total_run()
      @total_run
    end
    #This method gets the first passed status
    #
    # === params
    # nil
    # === returns
    # total tests run object
    # === raises
    def get_passed_status()
      @pass_statuses.first
    end
    #This method gets the first failed status
    #
    # === params
    # nil
    # === returns
    # total tests run object
    # === raises
    def get_failed_status()
      @fail_statuses.first
    end
    #This method gets the first not run status
    #
    # === params
    # nil
    # === returns
    # total tests run object
    # === raises
    def get_not_run_status()
      @not_run_statuses.first
    end
    #This method gets the test set total passed tests run
    #
    # === params
    # nil
    # === returns
    # total passed tests run object
    # === raises
    def get_total_passed()
      @total_passed
    end
    #This method gets the test set total failed tests run
    #
    # === params
    # nil
    # === returns
    # total failed tests run object
    # === raises
    def get_total_failed()
      @total_failed
    end
    #This method gets the test set total failed tests run
    #
    # === params
    # nil
    # === returns
    # total failed tests run object
    # === raises
    def get_total_crash_files()
      @total_crash_files
    end
    #This method gets the test set total device reset
    #
    # === params
    # nil
    # === returns
    # total failed tests run object
    # === raises
    def get_total_device_resets()
      @total_device_resets
    end
    #This method gets the test set total not run tests run
    #
    # === params
    # nil
    # === returns
    # total not run tests object
    # === raises
    def get_total_not_run()
      @total_not_run
    end
    #This method gets the test case user defined status
    #
    # === params
    # 
    # === returns
    # nil
    # === raises
    def get_test_case_user_defined_status()
      @test_case_user_defined_status
    end
    #This method gets the not run cases name array
    #
    # === params
    #
    # === returns
    # nil
    # === raises
    def get_not_run_cases_arr()
      #@not_run_cases_arr
      read_result_storage('not run')
    end
    #This method gets the passed cases name array
    #
    # === params
    #
    # === returns
    # nil
    # === raises
    def get_passed_cases_arr()
      #@passed_cases_arr
      read_result_storage('passed')
    end
    #This method gets the failed cases name array
    #
    # === params
    #
    # === returns
    # nil
    # === raises
    def get_failed_cases_arr()
      #@failed_cases_arr
      read_result_storage('failed')
    end
    #This method gets the failed cases name array
    #
    # === params
    #
    # === returns
    # nil
    # === raises
    def get_all_cases_arr()
      #@all_cases_arr
      read_result_storage('all')
    end
    #This method gets the memory amount end
    #
    # === params
    #
    # === returns
    # nil
    # === raises
    def get_memory_amount_end()
      @memory_amount_end
    end
    #This method gets the memory amount start
    #
    # === params
    #
    # === returns
    # nil
    # === raises
    def get_memory_amount_start()
      @memory_amount_start
    end
    #This method gets reporting groups
    #
    # === params
    #
    # === returns
    # nil
    # === raises
    def get_reporting_groups()
      @reporting_groups=MobyUtil::Parameter[ :report_groups, nil ]
      if @reporting_groups==nil
        @reporting_groups=@generic_reporting_groups
      end
      @reporting_groups
    end
    #This method gets the test run behaviour log
    #
    # === params
    # nil
    # === returns
    # test run execution log object
    # === raises
    def get_test_run_behaviour_log()
      @test_run_behaviour_log
    end
    #This method gets user created log
    #
    # === params
    # value: test run execution log entry
    # === returns
    # nil
    # === raises
    def get_log()
      @test_run_user_log
    end
    #This method gets user created data
    #
    # === params
    # nil
    # === returns
    # the testcase data and column objects
    # === raises
    def get_user_data()
      return @test_case_user_data,@test_case_user_data_columns
    end
    #This method gets user data to display in chronological table
    #
    # === params
    # nil
    # === returns
    # the testcase data and column objects
    # === raises
    def get_user_chronological_table_data()
      @test_case_user_chronological_table_data
    end
    #This method sets user data to display in chronological table
    #
    # === params
    # nil
    # === returns
    # the testcase data and column objects
    # === raises
    def set_user_chronological_table_data(value)
      if (value==nil)
        @test_case_user_chronological_table_data=Hash.new
      else
        @test_case_user_chronological_table_data=value
      end
    end
    #This method will parse duplicate groups out
    #
    # === params
    #
    # === returns
    # nil
    # === raises
    def check_if_group_exists_groups(groups,new_group_item)
      if groups.include? new_group_item
        true
      else
        false
      end
    end
    #This method creates a new TDriver test report folder when testing is started
    #
    # === params
    # nil
    # === returns
    # nil
    # === raises
    def  initialize_tdriver_report_folder()
      t = Time.now
      b_fixed_report_folder=false
      @start_time=t
      @reporter_base_folder = MobyUtil::Parameter[ :report_outputter_path, 'tdriver_reports/' ]
      if MobyUtil::Parameter[ :report_outputter_folder, nil ] != nil
        @report_folder=@reporter_base_folder+MobyUtil::Parameter[ :report_outputter_folder, nil ]
        b_fixed_report_folder=true
      else
        @report_folder=@reporter_base_folder+"test_run_"+t.strftime( "%Y%m%d%H%M%S" )
      end

      begin
        #check if report directory exists
        if File::directory?(@report_folder)==false
          FileUtils.mkdir_p @report_folder+'/environment'
          FileUtils.mkdir_p @report_folder+'/cases'
          FileUtils.mkdir_p @report_folder+'/junit_xml'
          
        else
          if b_fixed_report_folder==true
            FileUtils::remove_entry_secure(@report_folder, :force => true)
            FileUtils.mkdir_p @report_folder+'/environment'
            FileUtils.mkdir_p @report_folder+'/cases'
            FileUtils.mkdir_p @report_folder+'/junit_xml'            
          end
        end
        write_style_sheet(@report_folder+'/tdriver_report_style.css')
        write_page_start(@report_folder+'/cases/1_passed_index.html','Passed')
        write_page_end(@report_folder+'/cases/1_passed_index.html')
        write_page_start(@report_folder+'/cases/1_failed_index.html','Failed')
        write_page_end(@report_folder+'/cases/1_failed_index.html')
        write_page_start(@report_folder+'/cases/1_not_run_index.html','Not run')
        write_page_end(@report_folder+'/cases/1_not_run_index.html')
        write_page_start(@report_folder+'/cases/1_total_run_index.html','Total run')
        write_page_end(@report_folder+'/cases/1_total_run_index.html')
        #write_page_start(@report_folder+'/cases/tdriver_log_index.html','TDriver log')
        #write_page_end(@report_folder+'/cases/tdriver_log_index.html')
        write_page_start(@report_folder+'/cases/statistics_index.html','Statistics')
        write_page_end(@report_folder+'/cases/statistics_index.html')
      rescue Exception => e
        Kernel::raise e, "Unable to create report folder", caller
      end
      return nil
    end

    #This method updates the tdriver test run summary page
    #
    # === params
    # nil
    # === returns
    # nil
    # === raises
    def update_summary_page(status)
      begin
        #Calculate run time
        @run_time=Time.now-@start_time
        if status=='inprogress'
          write_page_start(@report_folder+'/index.html','TDriver test results')
          write_summary_body(@report_folder+'/index.html',@start_time,'Tests Ongoing...',@run_time,@total_run,@total_passed,@total_failed,@total_not_run,@total_crash_files,@total_device_resets)
          write_page_end(@report_folder+'/index.html')
        else
          write_page_start(@report_folder+'/index.html','TDriver test results')
          write_summary_body(@report_folder+'/index.html',@start_time,@end_time,@run_time,@total_run,@total_passed,@total_failed,@total_not_run,@total_crash_files,@total_device_resets)
          write_page_end(@report_folder+'/index.html')
        end
      rescue Exception => e
        Kernel::raise e, "Unable to update summary page", caller
      end
      return nil
    end
    #This method updates the tdriver test run enviroment page
    #
    # === params
    # nil
    # === returns
    # nil
    # === raises
    def update_environment_page()
      begin
        sw_version='-'
        variant='-'
        product='-'
        language='-'
        loc='-'
        #Copy behaviour and parameter xml files in to the report folder
        if /win/ =~ MobyUtil::EnvironmentHelper.ruby_platform
          FileUtils.cp_r 'C:/tdriver/behaviours', @report_folder+'/environment' if File.directory?('C:/tdriver/behaviours')
          FileUtils.cp_r 'C:/tdriver/templates', @report_folder+'/environment' if File.directory?('C:/tdriver/templates')
          FileUtils.cp_r 'C:/tdriver/defaults', @report_folder+'/environment' if File.directory?('C:/tdriver/defaults')
          FileUtils.copy('C:/tdriver/tdriver_parameters.xml',@report_folder+'/environment/tdriver_parameters.xml') if File.file?('C:/tdriver/tdriver_parameters.xml')
        else
          FileUtils.cp_r '/etc/tdriver/behaviours', @report_folder+'/environment' if File.directory?('/etc/tdriver/behaviours')
          FileUtils.cp_r '/etc/tdriver/templates', @report_folder+'/environment' if File.directory?('/etc/tdriver/templates')
          FileUtils.cp_r '/etc/tdriver/defaults', @report_folder+'/environment' if File.directory?('/etc/tdriver/defaults')
          FileUtils.copy('/etc/tdriver/tdriver_parameters.xml',@report_folder+'/environment/tdriver_parameters.xml') if File.file?('/etc/tdriver/tdriver_parameters.xml')
        end
        MobyBase::SUTFactory.instance.connected_suts.each do |sut_id, sut_attributes|
          begin
            if sut_attributes[:is_connected]
              sw_version=get_sut_sw_version(sut_id, sut_attributes) #sut_attributes[:sut].sysinfo( :Sw_version ) if MobyUtil::Parameter[sut_id][:type]=='S60'
              variant=get_sut_lang_version(sut_id, sut_attributes) #sut_attributes[:sut].sysinfo( :Lang_version ) if MobyUtil::Parameter[sut_id][:type]=='S60'
              @memory_amount_start=get_sut_used_memory(sut_id, sut_attributes) if @memory_amount_start==nil || @memory_amount_start=='-'
              @memory_amount_end=get_sut_used_memory(sut_id, sut_attributes)
              @memory_amount_total=get_sut_total_memory(sut_id, sut_attributes)
              product=MobyUtil::Parameter[sut_id][:product]
              language=MobyUtil::Parameter[sut_id][:language]
              loc=MobyUtil::Parameter[sut_id][:localisation_server_database_tablename]
            end
            @memory_amount_start='-' if @memory_amount_start==nil
            @memory_amount_end='-' if @memory_amount_end==nil
            @memory_amount_total='-' if @memory_amount_total==nil

            sw_version='-' if sw_version==nil
            variant='-' if variant==nil
            product='-' if product==nil
            language='-' if language==nil
            loc='-' if loc==nil
          rescue
          end
        end
        write_page_start(@report_folder+'/environment/index.html','TDriver test environment')
        write_environment_body(@report_folder+'/environment/index.html',RUBY_PLATFORM,sw_version,variant,product,language,loc)
        write_page_end(@report_folder+'/environment/index.html')
        $new_junit_xml_results.test_suite_properties(RUBY_PLATFORM,sw_version,variant,product,language,loc,@memory_amount_total,@memory_amount_start,@memory_amount_end)
      rescue Exception => e
        Kernel::raise e, "Unable to update environment page", caller
      end
      return nil
    end
    #This method updates the tdriver log page
    #
    # === params
    # nil
    # === returns
    # nil
    # === raises
    def update_tdriver_log_page()
      begin
        write_page_start(@report_folder+'/cases/tdriver_log_index.html','TDriver log')
        write_tdriver_log_body(@report_folder+'/cases/tdriver_log_index.html',@test_run_behaviour_log)
        write_page_end(@report_folder+'/cases/tdriver_log_index.html')
      rescue Exception => e
        Kernel::raise e
      end
      return nil
    end
    #This method gets the sut langugage version
    #
    # === params
    # sut_id: sut id
    # === returns
    # nil
    # === raises
    def get_sut_lang_version(sut_id, sut_attributes)
      MobyUtil::Logger.instance.enabled=false
      lang_version='-'
      begin
        if MobyUtil::Parameter[sut_id][:type]=='S60' || MobyUtil::Parameter[sut_id][:type]=='S60QT'
          lang_version=sut_attributes[:sut].sysinfo( :Lang_version )
        end
        if MobyUtil::Parameter[sut_id][:type]=='QT'
          if /win/ =~ MobyUtil::EnvironmentHelper.ruby_platform
            lang_version=0
          else
            lang_version=0
          end
        end
      rescue
      ensure
        if MobyUtil::Parameter[ :logging_level, 0 ].to_i > 0
          MobyUtil::Logger.instance.enabled=true
        else
          MobyUtil::Logger.instance.enabled=false
        end
        return lang_version
      end
    end
    #This method gets the sut sw version
    #
    # === params
    # sut_id: sut id
    # === returns
    # nil
    # === raises
    def get_sut_sw_version(sut_id, sut_attributes)
      MobyUtil::Logger.instance.enabled=false
      sw_version='-'
      begin
        if MobyUtil::Parameter[sut_id][:type]=='S60' || MobyUtil::Parameter[sut_id][:type]=='S60QT'
          sw_version=sut_attributes[:sut].sysinfo( :Sw_version )
        end
        if MobyUtil::Parameter[sut_id][:type]=='QT'
          if /win/ =~ MobyUtil::EnvironmentHelper.ruby_platform
            sw_version=0
          else
            sw_version=0
          end
        end
      rescue
      ensure
        if MobyUtil::Parameter[ :logging_level, 0 ].to_i > 0
          MobyUtil::Logger.instance.enabled=true
        else
          MobyUtil::Logger.instance.enabled=false
        end
        return sw_version
      end
    end
    #This method gets the sut used memory amount
    #
    # === params
    # sut_id: sut id
    # === returns
    # nil
    # === raises
    def get_sut_used_memory(sut_id, sut_attributes)
      MobyUtil::Logger.instance.enabled=false
      memory=0
      begin
        if MobyUtil::Parameter[sut_id][:type]=='S60' || MobyUtil::Parameter[sut_id][:type]=='S60QT'
          memory=sut_attributes[:sut].sysinfo( :Get_used_ram )
        end
        if MobyUtil::Parameter[sut_id][:type]=='QT'
          if /win/ =~ MobyUtil::EnvironmentHelper.ruby_platform
            memory=0
          else
            memory=0
          end
        end
      rescue
      ensure
        if MobyUtil::Parameter[ :logging_level, 0 ].to_i > 0
          MobyUtil::Logger.instance.enabled=true
        else
          MobyUtil::Logger.instance.enabled=false
        end
        return memory
      end

    end
    #This method gets the sut total memory amount
    #
    # === params
    # sut_id: sut id
    # === returns
    # nil
    # === raises
    def get_sut_total_memory(sut_id, sut_attributes)
      MobyUtil::Logger.instance.enabled=false
      memory=0
      begin
        if MobyUtil::Parameter[sut_id][:type]=='S60' || MobyUtil::Parameter[sut_id][:type]=='S60QT'
          memory=sut_attributes[:sut].sysinfo( :Get_total_ram )
        end
        if MobyUtil::Parameter[sut_id][:type]=='QT'
          if /win/ =~ MobyUtil::EnvironmentHelper.ruby_platform
            memory=0
          else
            memory=0
          end
        end
      rescue
      ensure
        if MobyUtil::Parameter[ :logging_level, 0 ].to_i > 0
          MobyUtil::Logger.instance.enabled=true
        else
          MobyUtil::Logger.instance.enabled=false
        end
        return  memory
      end
    end
    
    def write_to_result_storage(status,testcase,group,reboots=0,crashes=0,start_time=nil,user_data=nil,duration=0,memory_usage=0,index=0,log='',comment='',link='')
      while $result_storage_in_use==true
        sleep 1
      end
      $result_storage_in_use=true
      begin
        storage_file=nil       
        html_link=status+'_'+index.to_s+'_'+testcase+'/index.html' if link==''
        storage_file='all_cases.xml'

        file=@report_folder+'/'+storage_file

        if File.exist?(file)
          io = File.open(file, 'r')
          xml_data = Nokogiri::XML(io){ |config| config.options = Nokogiri::XML::ParseOptions::STRICT }
          io.close
          test = Nokogiri::XML::Node.new("test",xml_data)
          test_name = Nokogiri::XML::Node.new("name",test)
          test_name.content = testcase
          test_group = Nokogiri::XML::Node.new("group",test)
          test_group.content = group
          test_reboots = Nokogiri::XML::Node.new("reboots",test)
          test_reboots.content = reboots
          test_crashes = Nokogiri::XML::Node.new("crashes",test)
          test_crashes.content = crashes
          test_start_time = Nokogiri::XML::Node.new("start_time",test)
          test_start_time.content = start_time
          test_duration = Nokogiri::XML::Node.new("duration",test)
          test_duration.content = duration
          test_memory_usage = Nokogiri::XML::Node.new("memory_usage",test)
          test_memory_usage.content = memory_usage
          test_status = Nokogiri::XML::Node.new("status",test)
          test_status.content = status
          test_index = Nokogiri::XML::Node.new("index",test)
          test_index.content = index
          test_log = Nokogiri::XML::Node.new("log",test)
          test_log.content = log
          test_comment = Nokogiri::XML::Node.new("comment",test)
          test_comment.content = comment
          test_link = Nokogiri::XML::Node.new("link",test)
          test_link.content = html_link
      
          test << test_name
          test << test_group
          test << test_reboots
          test << test_crashes
          test << test_start_time
          test << test_duration
          test << test_memory_usage
          test << test_status
          test << test_index
          test << test_log
          test << test_comment
          test << test_link
         
          if user_data!=nil && !user_data.empty?
            test_data = Nokogiri::XML::Node.new("user_display_data",test)
            user_data.each { |key,value| 
              data_value=Nokogiri::XML::Node.new("data",test_data)
              data_value.content = value.to_s
              data_value.set_attribute("id",key.to_s)
              test_data << data_value
            }
            test<<test_data
          end

          xml_data.root.add_child(test)
          File.open(file, 'w') {|f| f.write(xml_data.to_xml) }
          test=nil
          xml_data=nil
        else
          counter=0
          if user_data!=nil && !user_data.empty?
            #to avoid odd number list for hash error!
            user_data_keys = user_data.keys
            user_data_values = user_data.values
            counter = user_data_values.size-1
          end
          builder = Nokogiri::XML::Builder.new do |xml|
            xml.tests {
              xml.test {
                xml.name testcase
                xml.group group
                xml.reboots reboots
                xml.crashes crashes
                xml.start_time start_time
                xml.duration duration
                xml.memory_usage memory_usage
                xml.status status
                xml.index index
                xml.log log
                xml.comment comment
                xml.link html_link
                if user_data!=nil && !user_data.empty?
                  xml.user_display_data {
                    (0..counter).each { |i|
                      xml.data("id"=>user_data_keys.at(i).to_s){ 
                        xml.text user_data_values.at(i).to_s{
                        }
                      }
                    }
                  }
                end
              }
            }
          end
          File.open(file, 'w') {|f| f.write(builder.to_xml) }
        end
        $result_storage_in_use=false
        builder=nil
      rescue Nokogiri::XML::SyntaxError => e
        $result_storage_in_use=false
        $stderr.puts "caught exception when writing results: #{e}"
      end
    end
    
    def read_result_storage(results)
      while $result_storage_in_use==true
        sleep 1
      end
      $result_storage_in_use=true
      begin
        result_storage=nil
        result_storage=Array.new
        storage_file='all_cases.xml'

        file=@report_folder+'/'+storage_file
        if File.exist?(file)
          io = File.open(file, 'r')
          xml_data = Nokogiri::XML(io){ |config| config.options = Nokogiri::XML::ParseOptions::STRICT }
          io.close
          xml_data.root.xpath("//tests/test").each do |node|
            value=node.search("name").text #0
            group=node.search("group").text #1
            reboots=node.search("reboots").text #2
            crashes=node.search("crashes").text #3
            start_time=node.search("start_time").text #4
            duration=node.search("duration").text #5
            memory_usage=node.search("memory_usage").text #6
            status=node.search("status").text #7
            index=node.search("index").text #8
            log=node.search("log").text #9
            comment=node.search("comment").text #10
            link=node.search("link").text #11
            
            user_data = Hash.new
            node.xpath("user_display_data/data").each do |data_node|
              value_name =  data_node.get_attribute("id")  
              val = data_node.text
              user_data[value_name] = val
            end
        
            case results
            when 'passed'
              if @pass_statuses.include?(status)
                result_storage << [value,group,reboots,crashes,start_time,duration,memory_usage,status,index,log,comment,link,user_data]
              end
            when 'failed'
              if @fail_statuses.include?(status)
                result_storage << [value,group,reboots,crashes,start_time,duration,memory_usage,status,index,log,comment,link,user_data]
              end
            when 'not run'
              if @not_run_statuses.include?(status)
                result_storage << [value,group,reboots,crashes,start_time,duration,memory_usage,status,index,log,comment,link,user_data]
              end
            when 'all'
              result_storage << [value,group,reboots,crashes,start_time,duration,memory_usage,status,index,log,comment,link,user_data]
            end
          end
          xml_data=nil
          $result_storage_in_use=false
          result_storage
        else
          $result_storage_in_use=false
          result_storage
        end
      rescue Nokogiri::XML::SyntaxError => e
        $result_storage_in_use=false
        $stderr.puts "caught exception when reading results: #{e}"
        result_storage
      end
    end

    def delete_result_storage()
      storage_file='passed_cases.xml'
      file=@report_folder+'/'+storage_file
      if File.exist?(file)
        File.delete(file)
      end

      storage_file='failed_cases.xml'
      file=@report_folder+'/'+storage_file
      if File.exist?(file)
        File.delete(file)
      end

      storage_file='not_run_cases.xml'
      file=@report_folder+'/'+storage_file
      if File.exist?(file)
        File.delete(file)
      end

      storage_file='all_cases.xml'
      file=@report_folder+'/'+storage_file
      if File.exist?(file)
        File.delete(file)
      end
    end
    #This method disconencts the connected devices
    #
    # === params
    # status: last run test case
    # === returns
    # nil
    # === raises
    def disconnect_connected_devices()
      if MobyUtil::Parameter[ :report_disconnect_connected_devices, false ] == 'true'
        MobyBase::SUTFactory.instance.connected_suts.each do |sut_id, sut_attributes|
          sut_attributes[:sut].disconnect() if sut_attributes[:is_connected]
        end
      end
    end

    def split_array(splittable_array,chunks)
      a = []
      splittable_array.each_with_index do |x,i|
        a << [] if i % chunks == 0
        a.last << x
      end
      a
    end

    #This method updates the tdriver test run enviroment page
    #
    # === params
    # status: last run test case
    # === returns
    # nil
    # === raises
    def update_test_case_summary_pages(status,rewrite=false)
      @passed_cases_arr=Array.new
      @failed_cases_arr=Array.new
      @not_run_cases_arr=Array.new
      @all_cases_arr=Array.new
      begin        
        case status
        when 'passed'
          @passed_cases_arr=read_result_storage(status)          
          splitted_arr=Array.new
          splitted_arr=split_array(@passed_cases_arr,@pages.to_i)
          page=1
          splitted_arr.each do |case_arr|
            #if File.exist?(@report_folder+"/cases/#{page+1}_passed_index.html")==false || rewrite==true
            if @report_pages_ready.include?("#{page}_passed")==false || rewrite==true
              write_page_start(@report_folder+"/cases/#{page}_passed_index.html",'Passed',page,splitted_arr.length)
              write_test_case_summary_body(@report_folder+"/cases/#{page}_passed_index.html",status,case_arr,nil)
              #end
              page_ready=write_page_end(@report_folder+"/cases/#{page}_passed_index.html",page,splitted_arr.length)
            end
            if page_ready!=nil
              @report_pages_ready << "#{page_ready}_passed"
            end
            page_ready=nil
            page+=1
          end
        when 'failed'
          @failed_cases_arr=read_result_storage(status)
          splitted_arr=Array.new
          splitted_arr=split_array(@failed_cases_arr,@pages.to_i)
          page=1
          splitted_arr.each do |case_arr|
            if File.exist?(@report_folder+"/cases/#{page+1}_failed_index.html")==false || rewrite==true
              if @report_pages_ready.include?("#{page}_failed")==false || rewrite==true
                write_page_start(@report_folder+"/cases/#{page}_failed_index.html",'Failed',page,splitted_arr.length)
                write_test_case_summary_body(@report_folder+"/cases/#{page}_failed_index.html",status,case_arr,nil)
              end
            end
            page_ready=write_page_end(@report_folder+"/cases/#{page}_failed_index.html",page,splitted_arr.length) if @report_pages_ready.include?("#{page}_failed")==false || rewrite==true
            if page_ready!=nil
              @report_pages_ready << "#{page_ready}_failed"
            end
            page_ready=nil
            page+=1
          end
        when 'not run'
          @not_run_cases_arr=read_result_storage(status)
          splitted_arr=Array.new
          splitted_arr=split_array(@not_run_cases_arr,@pages.to_i)
          page=1
          splitted_arr.each do |case_arr|
            if File.exist?(@report_folder+"/cases/#{page+1}_not_run_index.html")==false || rewrite==true
              if @report_pages_ready.include?("#{page}_not_run")==false || rewrite==true
                write_page_start(@report_folder+"/cases/#{page}_not_run_index.html",'Not run',page,splitted_arr.length)
                write_test_case_summary_body(@report_folder+"/cases/#{page}_not_run_index.html",status,case_arr,nil)
              end
            end
            page_ready=write_page_end(@report_folder+"/cases/#{page}_not_run_index.html",page,splitted_arr.length) if @report_pages_ready.include?("#{page}_not_run")==false || rewrite==true
            if page_ready!=nil
              @report_pages_ready << "#{page_ready}_not_run"
            end
            page_ready=nil
            page+=1
          end
        when 'statistics'
          @all_cases_arr=read_result_storage('all')
          write_page_start(@report_folder+'/cases/statistics_index.html','Statistics')
          write_test_case_summary_body(@report_folder+'/cases/statistics_index.html','statistics',@all_cases_arr)
          write_duration_graph(@report_folder+'/cases/statistics_index.html', @report_folder, 'duration_graph.png', @all_cases_arr)      
          write_page_end(@report_folder+'/cases/statistics_index.html')
        when 'all'
          @all_cases_arr=read_result_storage(status)
          splitted_arr=Array.new
          splitted_arr=split_array(@all_cases_arr,@pages.to_i)
          page=1
          splitted_arr.each do |case_arr|
            if File.exist?(@report_folder+"/cases/#{page+1}_total_run_index.html")==false || rewrite==true
              if @report_pages_ready.include?("#{page}_all")==false || rewrite==true
                write_page_start(@report_folder+"/cases/#{page}_total_run_index.html",'Total run',page,splitted_arr.length)
                write_page_start(@report_folder+"/cases/#{page}_chronological_total_run_index.html",'Total run',page,splitted_arr.length)
                write_test_case_summary_body(@report_folder+"/cases/#{page}_total_run_index.html",'total run',case_arr,@report_folder+"/cases/#{page}_chronological_total_run_index.html",page)
              end
            end
            write_page_end(@report_folder+"/cases/#{page}_chronological_total_run_index.html",page,splitted_arr.length) if @report_pages_ready.include?("#{page}_all")==false || rewrite==true
            page_ready=write_page_end(@report_folder+"/cases/#{page}_total_run_index.html",page,splitted_arr.length) if @report_pages_ready.include?("#{page}_all")==false || rewrite==true

            if page_ready!=nil
              @report_pages_ready << "#{page_ready}_all"
            end
            page_ready=nil
            page+=1
          end
        end
        @passed_cases_arr=nil
        @failed_cases_arr=nil
        @not_run_cases_arr=nil
        @all_cases_arr=nil
      rescue Exception => e
        Kernel::raise e, "Unable to update test case summary pages", caller
      end
      return nil
    end
    
    def create_csv
      storage_file='all_cases.xml'
      csv_file = 'all_cases.csv'
      csv_array = Array.new
      not_added=false
    
      file=@report_folder+'/'+storage_file
      csv =  nil
      begin
        if File.exist?(file)
          io = File.open(file, 'r')
          csv = File.new(@report_folder+'/'+ csv_file, 'w')
          xml_data = Nokogiri::XML(io){ |config| config.options = Nokogiri::XML::ParseOptions::STRICT }
          io.close
          xml_data.root.xpath("//tests/test").each do |node|
        
            line=Array.new
            first_line=Array.new
        
            value=node.search("name").text
            first_line<<"name" if !not_added
            line<<value
            start_time=node.search("start_time").text
            first_line<<"start_time" if !not_added
            line<<start_time
            duration=node.search("duration").text
            first_line<<"duration" if !not_added
            line<<duration
            memory_usage=node.search("memory_usage").text
            first_line<<"memory_usage" if !not_added
            line<<memory_usage
            status=node.search("status").text
            first_line<<"status" if !not_added
            line<<status

            node.xpath("user_display_data/data").each do |data_node|
              value_name = data_node.get_attribute("id")
              value = data_node.text
              first_line<<value_name if !not_added
              line<<value
            end

            csv.puts(first_line.join(",")) if !not_added
            csv.puts(line.join(","))
            not_added=true
          end
          csv.close
        else
          puts "Unable to create csv file"
        end
      rescue Exception => e
        puts "Error creating csv file"
        puts e.to_s
      end
    end
  
  end
end