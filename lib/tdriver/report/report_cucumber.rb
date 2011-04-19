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




require File.expand_path( File.join( File.dirname( __FILE__ ), 'report' ) )
#Report module which contains the Cucumber, Test::Unit and RSpec report formatters
begin
require 'cucumber/ast/visitor'
module TDriverReport
  #Class for formatting cucumber report
  class CucumberFormatter < Cucumber::Ast::Visitor
    include TDriverReportCreator
    #This method initializes new test run
    #
    # === params
    # === returns
    # === raises
    def initialize(step_mother, io, options)
     file, line = caller.first.split(":")
      $stderr.puts "Please note that CucumberListener may soon be deprecated. Use TDriverReport::CucumberReporter instead." % [ file, line]
      super(step_mother)
      start_run()
      @options = options
      @current_feature_element = nil
      @current_feature = nil
      @tc_status=nil
      @current_feature_group=nil
      at_exit do
        end_test_case(@current_feature_element,@tc_status)       
      end
    end
    #This method visits the executed cucumber step and updates the results in to TDriver report
    #
    # === params
    # === returns
    # === raises
    def visit_step_name(keyword, step_match, status, source_indent, background)      
      if status == :passed
        step_name = step_match.format_args(lambda{|param| "*#{param}*"})
        update_test_case("#{step_name} PASSED")
        @tc_status='passed'
      end
      if status == :failed
        step_name = step_match.format_args(lambda{|param| "*#{param}*"})
        update_test_case("#{step_name} FAILED")
        @tc_status='failed'
      end
      if status == :skipped
        step_name = step_match.format_args(lambda{|param| "*#{param}*"})
        update_test_case("#{step_name} SKIPPED")
      end
      if status == :undefined
        step_name = step_match.format_args(lambda{|param| "*#{param}*"})
        update_test_case("#{step_name} NOT RUN")
        @tc_status='not run'
      end      
    end
    #This method visits the exception caused by a failed step
    #and updates the result in to TDriver report
    #
    # === params
    # === returns
    # === raises
    def visit_exception(exception, status)
      if status == :failed
        capture_screen_test_case()
        update_test_case(exception.message)
      end
      update_test_case('-') if status == :passed
    end    
    #This method visits cucumber scenario name and starts a new test case when
    #new scenario is executed
    #and updates the result in to TDriver report
    #
    # === params
    # === returns
    # === raises
    def visit_scenario_name(keyword, name, file_colon_line, source_indent)      
      visit_feature_element_name(keyword, name, file_colon_line, source_indent)
    end
    def visit_feature_name(name)
      @current_feature_group=name.gsub(/[:]/,'')
      add_report_group('Features:'+@current_feature_group+'|')
    end
    #This method determines when new test case needs to be started
    #based on the scenario name info if scenario name is different then a new test case
    #is started
    #
    # === params
    # === returns
    # === raises
    def visit_feature_element_name(keyword, name, file_colon_line, source_indent)    
      line = %Q("#{name}")      
      @current_feature_element=line if @current_feature_element.nil?
      unless line == @current_feature_element       
        end_test_case(@current_feature_element,@tc_status)
        @current_feature_element=line
      end
      start_test_case(@current_feature_element)
      add_test_case_group(@current_feature_group)
      @tc_status=nil
    end
    #This method records the cucumber outline table results in to one test case
    #
    # === params
    # === returns
    # === raises
    def visit_outline_table(outline_table)
     update_test_case("running outline: ")
      super
    end
    #This method records the cucumber outline table results in to one test case
    #
    # === params
    # === returns
    # === raises
    def visit_table_row(table_row)
      super
      if table_row.exception
        @tc_status='failed'
        capture_screen_test_case()
        update_test_case("#{format_table_row(table_row)} FAILED")
        update_test_case(table_row.exception)
      else
        @tc_status='passed' if @tc_status==nil
        update_test_case("#{format_table_row(table_row)} PASSED")
      end      
    end
    def format_table_row(row)
      begin
        [row.name, row.line]
      rescue Exception => e
        row
      end
    end
  end
end
rescue LoadError

end
