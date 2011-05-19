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


class ReportJUnitXml
  def initialize(report_path)
    
    @test_case_run_arr=Array.new
    @junit_xml_report_path=report_path
    @test_case_arr=Array.new
    @test_run_properties_arr=Array.new
    
    @test_set_name=$parameters[ :quality_center_testset_name, "TestSetName" ]
    @test_set_path =$parameters[ :quality_center_testset_path, "TestSetPath" ]
    @test_class_name=nil
    @junit_xml_filename = convert_to_file_name('tdriver_junit_xml')
    @failures = 0
    @errors = 0
    @tests = 0
    
    @tests_start_time = Time.now
    @tc_start_time = nil
    @tc_end_time = nil
    @pass_statuses=$parameters[ :report_passed_statuses, "passed" ].split('|')
    @fail_statuses=$parameters[ :report_failed_statuses, "failed" ].split('|')
    @not_run_statuses=$parameters[ :report_not_run_statuses, "not run" ].split('|')
  end
  def convert_to_file_name(value)
    "TEST-"+value.gsub(/[^\w_\.]/, '_') + ".xml"
  end
  def add_test_name(name,group)
    @test_class_name=group.gsub(/[<\/?*>!)(}{\{@%"'.,:;~-]/,'')
    @test_name = name.gsub(/[<\/?*>!)(}{\{@%"'.,:;~-]/,'')
  end
  def test_suite_properties(os,sw,variant,product,language,localization,total_memory,used_memory_start,used_memory_end)
    @test_run_properties_arr=nil
    @test_run_properties_arr=Array.new  
    @test_run_properties_arr << [os]
    @test_run_properties_arr << [sw]
    @test_run_properties_arr << [variant]
    @test_run_properties_arr << [product]
    @test_run_properties_arr << [language]
    @test_run_properties_arr << [localization]
    @test_run_properties_arr << [total_memory]
    @test_run_properties_arr << [used_memory_start]
    @test_run_properties_arr << [used_memory_end]    
  end

  def add_test_result(status,start_time,end_time)
    if @fail_statuses.include?(status)
      @failures = @failures + 1
    end
    if @not_run_statuses.include?(status)
      @errors = @errors + 1
    end
    @tests = @tests+1
    @tc_start_time = start_time
    @tc_end_time = end_time
  end
  


  def create_junit_xml()    
    test_run_properties_arr=@test_run_properties_arr
    test_case_arr=$tdriver_reporter.read_result_storage('all')
    failures=@failures
    errors=@errors
    tests=@tests
    tests_end_time = Time.now
    execution_time=tests_end_time - @tests_start_time
    builder = Nokogiri::XML::Builder.new do |xml|
      xml.testsuite(:failures => failures,
        :errors => errors,
        :tests => tests,
        :name => "Test_Results" ) {
        xml.properties {
          xml.property(:os => test_run_properties_arr[0].to_s){
          }
          xml.property(:sw => test_run_properties_arr[1].to_s){
          }
          xml.property(:variant => test_run_properties_arr[2].to_s){
          }
          xml.property(:product => test_run_properties_arr[3].to_s){
          }
          xml.property(:language => test_run_properties_arr[4].to_s){
          }
          xml.property(:localization => test_run_properties_arr[5].to_s){
          }
          xml.property(:total_memory => test_run_properties_arr[6].to_s){
          }
          xml.property(:used_memory_start => test_run_properties_arr[7].to_s){
          }
          xml.property(:used_memory_end => test_run_properties_arr[8].to_s){
          }
          xml.property(:timestamp => @tests_start_time.to_s){
          }
          xml.property(:timestamp_end => tests_end_time.to_s){
          }
          xml.property(:time => execution_time.to_s){
          }
		    }
        test_case_arr.each do |test_case|
          if test_case[7].to_s == 'passed' || @pass_statuses.include?(test_case[7].to_s)
            xml.testcase(:classname => test_case[1].to_s, :name => test_case[0].to_s, :start_time => @tc_start_time , :end_time => @tc_end_time){
            }
          end
          if test_case[7].to_s == 'failed' || @fail_statuses.include?(test_case[7].to_s)
            xml.testcase(:classname => test_case[1].to_s, :name => test_case[0].to_s, :start_time => @tc_start_time , :end_time => @tc_end_time ){
              xml.failure(:message => test_case[0].to_s){
                xml.text(test_case[9].to_s.gsub('<br />'," \n ")){
                }
              }
            }
          end
          if test_case[7].to_s == 'not run' || @not_run_statuses.include?(test_case[7].to_s)
            xml.testcase(:classname => test_case[1].to_s, :name => test_case[0].to_s, :start_time => @tc_start_time , :end_time => @tc_end_time ){
              xml.error(:message => test_case[0].to_s){
                xml.text(test_case[9].to_s.gsub('<br />'," \n ")){
                }
              }
            }
          end
        end
      }
    end
    File.open(@junit_xml_report_path+'/junit_xml/'+@junit_xml_filename, 'w') { |file| file.write(builder.to_xml) }
    builder=nil
    test_case_arr=nil
  end
end

