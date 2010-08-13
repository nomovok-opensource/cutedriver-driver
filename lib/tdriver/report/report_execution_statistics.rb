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


require File.expand_path( File.join( File.dirname( __FILE__ ), 'report_writer' ) )
require 'gruff'

class ReportingStatistics
  def initialize(test_cases_array)
    @all_statuses=Array.new
    @group_test_case_arr=Array.new(test_cases_array)
    @pass_statuses=MobyUtil::Parameter[ :report_passed_statuses, "passed" ].split('|')
    @fail_statuses=MobyUtil::Parameter[ :report_failed_statuses, "failed" ].split('|')
    @not_run_statuses=MobyUtil::Parameter[ :report_not_run_statuses, "not run" ].split('|')
    @test_results_per_page=MobyUtil::Parameter[ :report_results_per_page, 10]
    @statistics_arr=Array.new
    @total_statistics_arr=Array.new
  end

  def reset_total_statistics()
    @all_statuses << "total"
    @total_statistics_arr << ["total",0]
    @pass_statuses.each do |status|
      @total_statistics_arr << [status,0]
      @all_statuses << status
    end
    @fail_statuses.each do |status|
      @total_statistics_arr << [status,0]
      @all_statuses << status
    end
    @not_run_statuses.each do |status|
      @total_statistics_arr << [status,0]
      @all_statuses << status
    end
    @total_statistics_arr << ["reboots",0]
    @total_statistics_arr << ["crashes",0]
    @total_statistics_arr << ["duration",0]
    @all_statuses << "reboots" << "crashes" << "duration"
  end

  def generate_statistics_headers()
    status_heads=Array.new
    @pass_statuses.each do |status|
      status_heads << "<td><b>#{status}</b></td>"
    end
    @fail_statuses.each do |status|
      status_heads << "<td><b>#{status}</b></td>"
    end
    @not_run_statuses.each do |status|
      status_heads << "<td><b>#{status}</b></td>"
    end
    status_heads << "<td><b>Reboots</b></td>"
    status_heads << "<td><b>Crashes</b></td>"
    status_heads << "<td><b>Duration</b></td>"
    status_heads
  end

  def collect_test_case_statistics()
    total_duration = 0.0
    @group_test_case_arr.each do |test_case|
      tc_status=test_case[7]
      tc_name=test_case[0].to_s.gsub('_',' ')
      tc_execution=test_case[8].to_i
      reboots=test_case[2]
      crashes=test_case[3]
      duration=test_case[5].to_f
      total_duration = total_duration + duration

      b_test_in_statistics=false
      
      current_index=0
      @total_statistics_arr.each do |total_status|
        if tc_status==total_status[0]
          @total_statistics_arr[current_index]=[tc_status,total_status[1].to_i+1]
        end
        if total_status[0]=="reboots"
          @total_statistics_arr[current_index]=["reboots",total_status[1].to_i+reboots.to_i]
        end
        if total_status[0]=="crashes"
          @total_statistics_arr[current_index]=["crashes",total_status[1].to_i+crashes.to_i]
        end
        if total_status[0]=="total"
          @total_statistics_arr[current_index]=["total",total_status[1].to_i+1]
        end
        if total_status[0]=="duration"
          @total_statistics_arr[current_index]=["duration",total_status[1].to_f+duration]
        end
        current_index+=1
      end
      current_index=0
      @statistics_arr.each do |total_status|
        if total_status[1]==tc_status && total_status[0]==tc_name
          b_test_in_statistics=true
          @statistics_arr[current_index]=[tc_name,tc_status,total_status[2].to_i+1,tc_execution]
        end
        if total_status[1]=="reboots" && total_status[0]==tc_name
          b_test_in_statistics=true
          @statistics_arr[current_index]=[tc_name,"reboots",total_status[2].to_i+reboots.to_i,tc_execution]
        end
        if total_status[1]=="crashes" && total_status[0]==tc_name
          b_test_in_statistics=true
          @statistics_arr[current_index]=[tc_name,"crashes",total_status[2].to_i+crashes.to_i,tc_execution]
        end
        if total_status[1]=="total" && total_status[0]==tc_name
          b_test_in_statistics=true
          @statistics_arr[current_index]=[tc_name,"total",total_status[2].to_i+1,tc_execution]
        end
        if total_status[1]=="duration" && total_status[0]==tc_name
          b_test_in_statistics=true
          @statistics_arr[current_index]=[tc_name,"duration",total_status[2].to_f+duration]
        end
        current_index+=1
      end

      if b_test_in_statistics==false
        @all_statuses.each do |status|
          if status==tc_status
            @statistics_arr << [tc_name,tc_status,1,tc_execution]
          elsif status=="reboots"
            @statistics_arr << [tc_name,"reboots",reboots.to_i,tc_execution]
          elsif status=="crashes"
            @statistics_arr << [tc_name,"crashes",crashes.to_i,tc_execution]
          elsif status=="total"
            @statistics_arr << [tc_name,"total",1,tc_execution]
          elsif status=="duration"
            @statistics_arr << [tc_name,"duration",duration,tc_execution]
          else
            @statistics_arr << [tc_name,status,0,tc_execution]
          end
        end
      end

    end

  end

  def add_result_style_tag(status,total)
    tc_style_tag=' id=""'
    tc_style_tag=' id="passed_case"' if @pass_statuses.include?(status) && total>0
    tc_style_tag=' id="failed_case"' if @fail_statuses.include?(status) && total>0
    tc_style_tag=' id="not_run_case"' if @not_run_statuses.include?(status) && total>0
    tc_style_tag
  end
  def add_result_link(test_case,status,total,test_index)

    result_page=test_index/@test_results_per_page.to_i
    result_page_mod=test_index % @test_results_per_page.to_i

    if result_page_mod>0
      result_page=result_page.to_i+1
    end
    result_page=1 if result_page==0

    tc_link='<a href="'+result_page.to_i.to_s+'_chronological_total_run_index.html">'
    tc_link='<a href="'+result_page.to_i.to_s+'_chronological_total_run_index.html#'+test_case.gsub(' ','_')+'_' + @pass_statuses.first + '">' if @pass_statuses.include?(status) && total>0
    tc_link='<a href="'+result_page.to_i.to_s+'_chronological_total_run_index.html#'+test_case.gsub(' ','_')+'_' + @fail_statuses.first + '">' if @fail_statuses.include?(status) && total>0
    tc_link='<a href="'+result_page.to_i.to_s+'_chronological_total_run_index.html#'+test_case.gsub(' ','_')+'_' + @not_run_statuses.first + '">' if @not_run_statuses.include?(status) && total>0
    tc_link
  end
  
  def generate_duration_graph(file_name)
  	
	reset_total_statistics()
	collect_test_case_statistics()
    
	labels = Hash.new   
	durations = Array.new
	test_case_added=Array.new
	current_index = 0
	@statistics_arr.each do |test_case|
	  tc_name=test_case[0].to_s.gsub('_',' ')
	  if test_case_added.include?(tc_name)==false && test_case[1].to_s=="duration"
	      	durations << test_case[2]
	      	labels[current_index] = tc_name
	  		current_index += 1
	  		test_case_added << tc_name
	  end
	end 
        
	g = Gruff::Bar.new
	g.title = "Duration Distribution" 
	g.data("Duration", durations)
	g.labels = labels
	g.write(file_name)
	  
  end

  def generate_statistics_table()
    table_body=Array.new
    reset_total_statistics()
    collect_test_case_statistics()
    table_body='<table align="center" border="1" cellspacing="0" style="width:100%;">'<<
      '<tr>'<<
      '<td>'<<
      '<b>Name</b></td>'<<
      '<td>'<<
      '<b>Total</b></td>'<<
      generate_statistics_headers.to_s <<
      '</tr>'

    test_case_added=Array.new

    @statistics_arr.each do |test_case|
      tc_name=test_case[0].to_s.gsub('_',' ')
      if test_case_added.include?(tc_name)==false
        table_body << "<tr>"
        table_body << "<td>#{tc_name}</td>"
        @statistics_arr.each do |test_case_statistics|
          if test_case_statistics[0]==tc_name
            table_body << "<td#{add_result_style_tag(test_case_statistics[1],test_case_statistics[2])}>#{add_result_link(test_case_statistics[0],test_case_statistics[1],test_case_statistics[2],test_case_statistics[3])}#{test_case_statistics[2]}</a></td>"
          end
        end
        table_body << "</tr>"
        test_case_added << tc_name
      end
    end


    table_body << '<tr></tr>'
    table_body << '<tr>' <<
      '<td>'<<
      '<b>Total</b></td>'
    @total_statistics_arr.each do |statistic|
      table_body << "<td><b>#{statistic[1]}</b></td>"
    end
    table_body << '</tr>' <<
      '</table>'


    table_body
  end

end
