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

include TDriverReportJavascript
module TDriverReportWriter

  def write_style_sheet(page)
    css='body
{
	background-color:#74C2E1;
  font-family: sans-serif;
	font-size: small;
}
.navigation_section
{
	background-color:#0191C8;
	width:1024px;
	height:40px;
    margin-left : auto;
    margin-right: auto;
  font-family: sans-serif;
	font-size: medium;
-webkit-box-shadow: 5px 5px 8px #818181;
-moz-box-shadow: 5px 5px 8px #818181;
-moz-border-radius: 9px 9px 9px 9px;
-webkit-border-radius: 9px;
-webkit-border-top-left-radius: 9px;
-webkit-border-bottom-right-radius: 9px;

}
.page_navigation_section
{
	background-color:#0191C8;
	width:1024px;
	height:40px;
    margin-left : auto;
    margin-right: auto;
  font-family: sans-serif;
	font-size: medium;
-webkit-box-shadow: 5px 5px 8px #818181;
-moz-box-shadow: 5px 5px 8px #818181;
-moz-border-radius: 9px 9px 9px 9px;
-webkit-border-radius: 9px;
-webkit-border-top-left-radius: 9px;
-webkit-border-bottom-right-radius: 9px;

}


.summary
{
	background-color:White;
	width:1024px;
	height:100%;
	margin-left : auto;
    margin-right: auto;
-webkit-box-shadow: 5px 5px 8px #818181;
-moz-box-shadow: 5px 5px 8px #818181;
-moz-border-radius: 9px 9px 9px 9px;
-webkit-border-radius: 9px;
-webkit-border-top-left-radius: 9px;
-webkit-border-bottom-right-radius: 9px;

}
.summary_total_run
{
	background-color:White;
	width:1024px;
	height:100%;
	margin-left : auto;
    margin-right: auto;
-webkit-box-shadow: 5px 5px 8px #818181;
-moz-box-shadow: 5px 5px 8px #818181;
-moz-border-radius: 9px 9px 9px 9px;
-webkit-border-radius: 9px;
-webkit-border-top-left-radius: 9px;
-webkit-border-bottom-right-radius: 9px;

}
.summary_passed
{
	background-color:White;
	width:1024px;
	height:100%;
	margin-left : auto;
    margin-right: auto;
-webkit-box-shadow: 5px 5px 8px #818181;
-moz-box-shadow: 5px 5px 8px #818181;
-moz-border-radius: 9px 9px 9px 9px;
-webkit-border-radius: 9px;
-webkit-border-top-left-radius: 9px;
-webkit-border-bottom-right-radius: 9px;

}
.summary_crash
{
	background-color:White;
	width:1024px;
	height:100%;
	margin-left : auto;
    margin-right: auto;
-webkit-box-shadow: 5px 5px 8px #818181;
-moz-box-shadow: 5px 5px 8px #818181;
-moz-border-radius: 9px 9px 9px 9px;
-webkit-border-radius: 9px;
-webkit-border-top-left-radius: 9px;
-webkit-border-bottom-right-radius: 9px;

}
.summary_reboot
{
	background-color:White;
	width:1024px;
	height:100%;
	margin-left : auto;
    margin-right: auto;
-webkit-box-shadow: 5px 5px 8px #818181;
-moz-box-shadow: 5px 5px 8px #818181;
-moz-border-radius: 9px 9px 9px 9px;
-webkit-border-radius: 9px;
-webkit-border-top-left-radius: 9px;
-webkit-border-bottom-right-radius: 9px;

}
.statistics
{
	background-color:White;
	width:1024px;
	height:100%;
	margin-left : auto;
    margin-right: auto;
-webkit-box-shadow: 5px 5px 8px #818181;
-moz-box-shadow: 5px 5px 8px #818181;
-moz-border-radius: 9px 9px 9px 9px;
-webkit-border-radius: 9px;
-webkit-border-top-left-radius: 9px;
-webkit-border-bottom-right-radius: 9px;

}
.summary_failed
{
	background-color:White;
	width:1024px;
	height:100%;
	margin-left : auto;
    margin-right: auto;
-webkit-box-shadow: 5px 5px 8px #818181;
-moz-box-shadow: 5px 5px 8px #818181;
-moz-border-radius: 9px 9px 9px 9px;
-webkit-border-radius: 9px;
-webkit-border-top-left-radius: 9px;
-webkit-border-bottom-right-radius: 9px;

}
.summary_not_run
{
	background-color:White;
	width:1024px;
	height:100%;
	margin-left : auto;
    margin-right: auto;
-webkit-box-shadow: 5px 5px 8px #818181;
-moz-box-shadow: 5px 5px 8px #818181;
-moz-border-radius: 9px 9px 9px 9px;
-webkit-border-radius: 9px;
-webkit-border-top-left-radius: 9px;
-webkit-border-bottom-right-radius: 9px;

}
.test_passed
{
	background-color:White;
	width:1024px;
	height:100%;
	margin-left : auto;
    margin-right: auto;
-webkit-box-shadow: 5px 5px 8px #818181;
-moz-box-shadow: 5px 5px 8px #818181;
-moz-border-radius: 9px 9px 9px 9px;
-webkit-border-radius: 9px;
-webkit-border-top-left-radius: 9px;
-webkit-border-bottom-right-radius: 9px;

}
.test_failed
{
	background-color:White;
	width:1024px;
	height:100%;
	margin-left : auto;
    margin-right: auto;
-webkit-box-shadow: 5px 5px 8px #818181;
-moz-box-shadow: 5px 5px 8px #818181;
-moz-border-radius: 9px 9px 9px 9px;
-webkit-border-radius: 9px;
-webkit-border-top-left-radius: 9px;
-webkit-border-bottom-right-radius: 9px;

}
.test_not_run
{
	background-color:White;
	width:1024px;
	height:100%;
	margin-left : auto;
    margin-right: auto;
-webkit-box-shadow: 5px 5px 8px #818181;
-moz-box-shadow: 5px 5px 8px #818181;
-moz-border-radius: 9px 9px 9px 9px;
-webkit-border-radius: 9px;
-webkit-border-top-left-radius: 9px;
-webkit-border-bottom-right-radius: 9px;

}
.environment
{
	background-color:White;
	width:1024px;
	height:100%;
	margin-left : auto;
    margin-right: auto;
-webkit-box-shadow: 5px 5px 8px #818181;
-moz-box-shadow: 5px 5px 8px #818181;
-moz-border-radius: 9px 9px 9px 9px;
-webkit-border-radius: 9px;
-webkit-border-top-left-radius: 9px;
-webkit-border-bottom-right-radius: 9px;

}
.page_title
{
	background-color:#0191C8;
	width:1024px;
	min-height:100%;
	margin-left : auto;
    margin-right: auto;
    color : white;
-webkit-box-shadow: 5px 5px 8px #818181;
-moz-box-shadow: 5px 5px 8px #818181;
-moz-border-radius: 9px 9px 9px 9px;
-webkit-border-radius: 9px;
-webkit-border-top-left-radius: 9px;
-webkit-border-bottom-right-radius: 9px;

}
.table
{
	width: 100%;
-webkit-box-shadow: 5px 5px 8px #818181;
-moz-box-shadow: 5px 5px 8px #818181;
-moz-border-radius: 9px 9px 9px 9px;
-webkit-border-radius: 9px;
-webkit-border-top-left-radius: 9px;
-webkit-border-bottom-right-radius: 9px;

}
a:link { color:Black;}
a:visited { color:Black;}
a:hover { color:White; background-color:#005B9A;}

#navigation
{
	list-style-type:none;
	padding:10px 10px 20px 10px;
  width: 47em;
	margin: auto;
}

#navigation li {
	float:left;
	margin:0 2px;
}
#navigation li a {
	display:block;
	padding:2px 10px;
	background-color:#E0E0E0;
	color:#2E3C1F;
	text-decoration:none;
}
#navigation li a.current {
	background-color:#74C2E1;
	color:#FFFFFF;
}
#navigation_tabs_ul li a.current {
	background-color:#74C2E1;
	color:Black;
}
#navigation li a:hover {
	background-color:#3C72B0;
	color:#FFFFFF;
}
#failed_case
{
	background-color:Red;
}
#passed_case
{
	background-color:Lime;
}
#not_run_case
{
	background-color:#E0E0E0;
}

#statistics_table
{
	font-size: 12px;
	text-align: left;
	border-collapse: collapse;
}
#statistics_table th
{
	padding: 8px;
	border-bottom: 1px solid Black;
	color: #669;
	border-top: 1px solid transparent;
}
#statistics_table td
{
	padding: 8px;
	border-bottom: 1px solid Black;
	color: #669;
	border-top: 1px solid transparent;
}


.navigation_tabs{
width: 100%;
overflow: hidden;

}

.navigation_tabs ul{
margin: 0;
padding: 0;
padding-left: 100px; /*offset of tabs relative to browser left edge*/
font: bold 12px sans-serif;
list-style-type: none;
}

.navigation_tabs li{
display: inline;
margin: 0;
}

.navigation_tabs li a{
float: left;
display: block;
text-decoration: none;
margin: 0;
padding: 13px 8px; /*padding inside each tab*/
border-right: 1px solid white; /*right divider between tabs*/
color: white;
background: #0191C8; /*background of tabs (default state)*/
}

.navigation_tabs li a:visited{
color: white;
}

.navigation_tabs li a:hover, .navigation_tabs li.selected a{
background: black; /*background of tabs for hover state, plus tab with "selected" class assigned to its LI */
}


img
{
	width:50%;
	height:50%;
}
    .togList
{

}

.togList dt
{

}

.togList dt span
{

}

.togList dd
{
width: 90%;
padding-bottom: 15px;
}

FORM { DISPLAY:inline; }

html.isJS .togList dd
{
display: block;
}
    input.btn {
	  color:#050;
	  font: bold 84% \'trebuchet ms\',helvetica,sans-serif;
	  border: 1px solid;
	  border-color: #696 #363 #363 #696;
	}
  input.btn:hover{
    background-color:#dff4ff;
    border:1px solid #c2e1ef;
    color:#336699;
    }

.behaviour_table_title
{
	background-color:#CCCCCC;
}
.user_data_table_title
{
	background-color:#CCCCCC;
}

    '
    File.open(page, 'w') {|f| f.write(css) }
    css=nil
  end

  def format_duration(seconds)
    if Gem.available?('chronic_duration')
      duration_str=ChronicDuration.output(seconds)
    else
      m, s = seconds.divmod(60)
      duration_str="#{m}m#{'%.3f' % s}s"
    end
    duration_str
  end

  def write_stack_file_to_html(file,page,linen)
    code=File.read(file)
    html_code=[]
    code_line=1
    code.each do |line|
      if linen.to_s==code_line.to_s
        html_code << "<b><a style=\"color: #FF0000\" name=\"#{code_line}\">#{code_line}: #{line.gsub(' ','&nbsp;' )} </a></b><br />"
      else
        html_code << "<a name=\"#{code_line}\">#{code_line}: #{line.gsub(' ','&nbsp;' )} </a><br />"
      end
      code_line+=1
    end
    File.open(page, 'w') do |f2|
      f2.puts html_code
    end
  end

  def copy_code_file_to_test_case_report(file,folder,linen)
    begin
      FileUtils.mkdir_p(folder.to_s+'/stack_files') if File::directory?(folder.to_s+'/stack_files')==false
      if File.directory?("#{Dir.pwd}/#{@report_folder}/#{folder}")
        write_stack_file_to_html(file,"#{Dir.pwd}/#{@report_folder}/#{folder}/stack_files/#{File.basename(file)}.html",linen)
        FileUtils.copy(file,"#{Dir.pwd}/#{@report_folder}/#{folder}/stack_files/#{File.basename(file)}")
      else
        write_stack_file_to_html(file,"#{folder}/stack_files/#{File.basename(file)}.html",linen)
        FileUtils.copy(file,"#{folder}/stack_files/#{File.basename(file)}")
      end

    rescue Exception => e
      puts e.message
      puts e.backtrace
    end
  end

  def reporter_link_to_code(log_line,folder=nil)
    begin
      log_line.gsub(/([\w \*\/\w\/\.-]+)\:(\d+)/) do |match|
        line=match[/\:(\d+)/]
        f=match[/([\w \*\/\w\/\.-]+)/]
        file="#{File.dirname(f.strip)}/#{File.basename(f.strip)}"
        file = file if File.exist?(file)
        file = "#{Dir.pwd}/#{file}" if File.exist?("#{Dir.pwd}/#{file}")
        if File.exist?(file) && match.include?('testability-driver')==false
          copy_code_file_to_test_case_report(file,folder,line.gsub(':','').strip)
          link_to_stack='<a style="color: #FF0000" href="stack_files/'<<
            File.basename(file.to_s)+'.html#'+line.to_s<<
            '">'+match+'</a>'
          log_line=log_line.gsub(match,link_to_stack)
        end
      end
    rescue Exception => e
      puts e.message
      puts e.backtrace
    end
    log_line
  end

  def behaviour_log_summary(log,log_format='string')
    begin
      log_table = Array.new
      pass=0
      fail=0
      #behaviour=0
      warning=0
      debug=0
      info=0
      error=0
      fatal=0
      log_table << '<table width=60% border="1">'
      log_table << '<tr class="behaviour_table_title"><td><b>BEHAVIOUR</b></td><td><b>Total</b></td></tr>'
      log.each do |log_row|
        if log_row[0].include? 'PASS'
          pass+=1
        end
        if log_row[0].include? 'FAIL'
          fail+=1
        end
        #if log_row.include? 'BEHAVIOUR'
        # behaviour+=1
        #end
        if log_row[0].include? 'WARNING'
          warning+=1
        end
        if log_row[0].include? 'DEBUG'
          debug+=1
        end
        if log_row[0].include? 'INFO'
          info+=1
        end
        if log_row[0].include? 'ERROR'
          error+=1
        end
        if log_row[0].include? 'FATAL'
          fatal+=1
        end
      end
      log_table << '<tr><td>PASS:</td><td>'+pass.to_s+'</td></tr>'
      log_table << '<tr><td>FAIL:</td><td>'+fail.to_s+'</td></tr>'
      #log_table << '<tr><td>BEHAVIOUR:</td><td>'+behaviour.to_s+'</td></tr>'
      log_table << '<tr><td>WARNING:</td><td>'+warning.to_s+'</td></tr>'
      log_table << '<tr><td>DEBUG:</td><td>'+debug.to_s+'</td></tr>'
      log_table << '<tr><td>INFO:</td><td>'+info.to_s+'</td></tr>'
      log_table << '<tr><td>ERROR:</td><td>'+error.to_s+'</td></tr>'
      log_table << '<tr><td>FATAL:</td><td>'+fatal.to_s+'</td></tr>'
      log_table << '</table>'
      if log_format=='string'
        log_table.join
      else
        log_table
      end
    rescue
      '-'
    end
  end
  def format_behaviour_log(log,log_format='string')
    begin
      log_table = Array.new
      log_table << '<table border="1">'
      log_table << '<tr class="behaviour_table_title"><td><b>TDriver</b></td><td><b>Log</b></td><td><b>Status</b></td></tr>'
      log.each do |log_row|
        status='-'
        type='-'
        log_entry='-'
        if log_row[0].include? 'PASS'
          status='<b style="color: #00FF00">PASS</b>'
        end
        if log_row[0].include? 'FAIL'
          status='<b style="color: #FF0000">FAIL</b>'
        end
        if log_row[0].include? 'BEHAVIOUR'
          type='<b>BEHAVIOUR</b>'
        end
        if log_row[0].include? 'WARNING'
          type='<b style="color: #FF00FF">WARNING<b>'
        end
        if log_row[0].include? 'DEBUG'
          type='DEBUG'
        end
        if log_row[0].include? 'INFO'
          type='<b style="color: #00FF00">INFO</b>'
        end
        if log_row[0].include? 'ERROR'
          type='<b style="color: #FF0000">ERROR</b>'
        end
        if log_row[0].include? 'FATAL'
          type='<b style="color: #FF0000">FATAL</b>'
        end

        formatted_log=log_row[0].gsub('PASS;','')
        formatted_log=formatted_log.gsub('FAIL;','')
        formatted_log=formatted_log.gsub('BEHAVIOUR TDriver:','')
        formatted_log=formatted_log.gsub('WARNING;','')
        formatted_log=formatted_log.gsub('DEBUG TDriver:','')
        formatted_log=formatted_log.gsub('INFO TDriver:','')
        formatted_log=formatted_log.gsub('ERROR TDriver:','')
        formatted_log=formatted_log.gsub('FATAL TDriver:','')
        log_entry=formatted_log
        formatted_log=nil
        if log_row[1] != nil
          log_table << '<tr><td>'+type+'</td><td><a href="'+log_row[1].to_s+'/index.html">'+log_entry+'</a></td><td>'+status+'</td></tr>'
        else
          log_table << '<tr><td>'+type+'</td><td>'+log_entry+'</td><td>'+status+'</td></tr>'
        end

      end
      log_table << '</table>'
      if log_format=='string'
        log_table.join
      else
        log_table
      end
    rescue
      '-'
    end
  end
  def format_execution_log(log,folder=nil)
    begin
      formatted_log=Array.new
      log.each do |line|
        line=reporter_link_to_code(line,folder)
        if line.include?('testability-driver')==false
          formatted_log << line.gsub('PASSED','<b style="color: #00FF00">PASSED</b>').gsub('FAILED','<b style="color: #FF0000">FAILED</b>').gsub('SKIPPED','<b>SKIPPED</b>')
        else
          formatted_log << "<b style=\"color: #2554C7\">#{line}</b>".gsub('PASSED','<b style="color: #00FF00">PASSED</b>').gsub('FAILED','<b style="color: #FF0000">FAILED</b>').gsub('SKIPPED','<b>SKIPPED</b>')
        end
      end
      formatted_log.to_s
    rescue
      '-'
    end
  end
  def write_page_start(page, title,report_page=nil,report_pages=nil)
    case title
    when "TDriver test results"
      stylesheet='<link rel="stylesheet" title="TDriverReportStyle" href="tdriver_report_style.css"/>'
    when "TDriver test environment","Total run","Statistics","Passed","Failed","Not run","Crash","Reboot","TDriver log"
      stylesheet='<link rel="stylesheet" title="TDriverReportStyle" href="../tdriver_report_style.css"/>'
    else
      stylesheet='<link rel="stylesheet" title="TDriverReportStyle" href="../../tdriver_report_style.css"/>'
    end
    html_start='<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">' <<
      '<html xmlns="http://www.w3.org/1999/xhtml">'<<
      '<head><meta http-equiv="Content-Type" content="text/html; charset=utf-8"><META HTTP-EQUIV="CACHE-CONTROL" CONTENT="NO-CACHE"><META HTTP-EQUIV="PRAGMA" CONTENT="NO-CACHE">'<<
      stylesheet<<
      get_expand_collapse_java_script()<<
      '<title>'+title+'</title>'<<
      '</head><body>'
    File.open(page, 'w') do |f2|
      f2.puts html_start
    end
    html_start=nil
    stylesheet=nil
    write_navigation_menu(page,title,report_page,report_pages)
    page=nil
    title=nil
  end
  def write_test_case_body(page,test_case_name,start_time,end_time,run_time,status,index,folder,capture_screen_error,failed_dump_error,reboots=0,total_dump_count=nil,total_data_sent=nil,total_data_received=nil)
    status_style='test_passed' if status=='passed' || @pass_statuses.include?(status)
    status_style='test_failed' if status=='failed' || @fail_statuses.include?(status)
    status_style='test_not_run' if status=='not run' || @not_run_statuses.include?(status)
    begin
      used_memory_difference=@tc_memory_amount_start.to_i-@tc_memory_amount_end.to_i
    rescue
      used_memory_difference='-'
    end
    formatted_test_case_name=test_case_name.gsub('_',' ')
    if formatted_test_case_name==nil
      formatted_test_case_name=test_case_name
    end
    html_body='<div class="page_title"><center><h1>',formatted_test_case_name,'</h1></center></div>'<<
      '<div class="'<<
      status_style<<
      '"><table align="center" style="width:100%;">'<<
      '<tr>'<<
      '<td style="font-weight: 700">'<<
      'Case</td>'<<
      '<td>'<<
      index.to_s,'</td>'<<
      '</tr>'<<
      '<tr>'<<
      '<td style="font-weight: 700">'<<
      'Status</td>'<<
      '<td>'<<
      status,'</td>'<<
      '</tr>'<<
      '<tr>'<<
      '<td style="font-weight: 700">'<<
      'Started</td>'<<
      '<td>'<<
      start_time.strftime("%d.%m.%Y %H:%M:%S"),'</td>'<<
      '</tr>'<<
      '<tr>'<<
      '<td style="font-weight: 700">'<<
      'Ended</td>'<<
      '<td>'<<
      end_time.strftime("%d.%m.%Y %H:%M:%S"),'</td>'<<
      '</tr>'<<
      '<tr>'<<
      '<td style="font-weight: 700">'<<
      'Runtime</td>'<<
      '<td>'<<
      format_duration(run_time)+'</td>'<<
      '</tr>'

    total_dump_count.each do |item|
      html_body << '<tr>'<<
        '<td style="font-weight: 700">'<<
        "Dump count from sut #{item[0]}</td>"<<
        '<td>'<<
        item[1].to_s+'</td>'<<
        '</tr>'
    end

    total_data_sent.each do |item|
      html_body << '<tr>' <<
        '<td style="font-weight: 700">'<<
        "Sent bytes from sut #{item[0]}</td>"<<
        '<td>'<<
        item[1].to_s+'</td>'<<
        '</tr>'
    end

    total_data_received.each do |item|
      html_body << '<tr>' <<
        '<td style="font-weight: 700">'<<
        "Received bytes from sut #{item[0]}</td>"<<
        '<td>'<<
        item[1].to_s+'</td>'<<
        '</tr>'
    end

    html_body << '<tr><td><b>Total memory</b></td><td>'<<
      @tc_memory_amount_total.to_s<<
      '</td></tr>'<<
      '<tr><td><b>Used memory at beginning</b></td><td>'<<
      @tc_memory_amount_start.to_s<<
      '</td></tr>'<<
      '<tr><td><b>Used memory at end</b></td><td>'<<
      @tc_memory_amount_end.to_s<<
      '</td></tr>'<<
      '<tr><td><b>Used memory difference</b></td><td>'<<
      used_memory_difference.to_s<<
      '</td></tr>' <<
      '<tr><td><b>Device reboots</b></td><td>'<<
      reboots.to_s<<
      '</td></tr>' <<
      '<tr>' <<
      '<td style="font-weight: 700">'<<
      'Details</td>'<<
      '<td style="font-size: small; font-weight: bold">'<<
      format_execution_log(@test_case_execution_log,folder.to_s)<<
      '</td></tr>'

    if File::directory?(folder.to_s+'/crash_files')==true
      d=Dir.entries(folder.to_s+'/crash_files')
      d.each do |x|
        if (x !='.' && x != '..')
          html_body=html_body<<
            '<tr>'<<
            '<td style="font-weight: 700">'<<
            '&nbsp;</td>'<<
            '<td>'<<
            '<a href="crash_files/'<<
            x<<
            '">'+x+'</a></td>'<<
            '</tr>'
        end
      end
    end
    if File::directory?(folder.to_s+'/trace_files')==true
      d=Dir.entries(folder.to_s+'/trace_files')
      d.each do |x|
        if (x !='.' && x != '..')
          html_body=html_body<<
            '<tr>'<<
            '<td style="font-weight: 700">'<<
            'Trace files</td>'<<
            '<td>'<<
            '<a href="trace_files/'<<
            x<<
            '">Captured trace files</a></td>'<<
            '</tr>'
        end
      end
    end
    if File::directory?(folder.to_s+'/video')==true
      d=Dir.entries(folder.to_s+'/video')
      html_body=html_body<<
        '<tr>'<<
        '<td style="font-weight: 700">'<<
        'Video files</td>'<<
        '</tr>'
      d.each do |x|
        if (x !='.' && x != '..')
          html_body=html_body<<
            '<tr>'<<
            '<td style="font-weight: 700">'<<
            '&nbsp;</td>'<<
            '<td>'<<
            '<a href="video/'<<
            x<<
            '">'+x+'</a></td>'<<
            '</tr>'
        end
      end
    end
    if File::directory?(folder.to_s+'/files')==true
      d=Dir.entries(folder.to_s+'/files')
      html_body=html_body<<
        '<tr>'<<
        '<td style="font-weight: 700">'<<
        'Monitored files</td>'<<
        '</tr>'
      d.each do |x|
        if (x !='.' && x != '..')
          html_body=html_body<<
            '<tr>'<<
            '<td style="font-weight: 700">'<<
            '&nbsp;</td>'<<
            '<td>'<<
            '<a href="files/'<<
            x<<
            '">'+x+'</a></td>'<<
            '</tr>'
        end
      end
    end
    html_body=html_body<<
      '<tr><td style="font-weight: 700">'<<
      '&nbsp;</td>'
    html_body=html_body<<
      '</tr>'<<
      '</table>'
    if @test_case_behaviour_log.length > 0
      html_body=html_body<<
        '<dl class="togList">'<<
        '<dt onclick="tog(this)" style="background-color: #CCCCCC;"><b style="font-size: large"><span><input id="Button1" type="button" value="Close" class="btn" /></span> Behaviours</b></dt>'<<
        '<dd style="font-size: small">'<<
        format_behaviour_log(@test_case_behaviour_log)<<
        '</dd>'<<
        '</dl>'
    end
    if @test_case_user_data!=nil && !@test_case_user_data.empty?
      html_body=html_body<<
        '<dl class="togList">'<<
        '<dt onclick="tog(this)" style="background-color: #CCCCCC;"><b style="font-size: large"><span><input id="Button1" type="button" value="Close" class="btn" /></span> User Data</b></dt>'<<
        '<dd style="font-size: small">'<<
        format_user_log_table( @test_case_user_data,@test_case_user_data_columns)<<
        '</dd>'<<
        '</dl>'
    end
    html_body=html_body<<
      '</div>'
    File.open(page, 'a') do |f2|
      f2.puts html_body
    end
    html_body=nil
    @test_case_execution_log=nil
    @test_case_behaviour_log=nil
    @test_case_user_data=nil
    @test_case_user_data_columns=nil
  end
  def tog_list_begin(name)
    html_body='<dl class="togList">'<<
      '<dt onclick="tog(this)"><b><span>+</span>'<<
      name<<
      '</b></dt>'<<
      '<dd>'
    html_body
  end
  def tog_list_end()
    html_body='</dd>'<<
      '</dl>'
    html_body
  end
  def write_duration_graph(page, folder, graph_file_name, tc_arr)

    tdriver_group=ReportingStatistics.new(tc_arr)
    tdriver_group.generate_duration_graph(folder + '/cases/' + graph_file_name)

    html_body=Array.new
    html_body << '<div>'
    html_body << '<H1 ALIGN=center><img border="0" src="./'+graph_file_name+'"/></H1>'
    html_body << '</div>'
    File.open(page, 'a') do |f2|
      f2.puts html_body
    end
    tdriver_group = nil
    html_body=nil
    GC.start
  end
  def write_test_case_summary_body(page,status,tc_arr,chronological_page=nil,report_page=nil)
    html_body=Array.new
    case status
    when 'passed'
      title='<div class="page_title"><center><h1>Passed</h1></center></div>'<<
        '<div class="summary_passed">' <<
        '<form action="save_total_run_results" >'
      tdriver_group=ReportingGroups.new(@reporting_groups,tc_arr)
      tdriver_group.parse_groups()
      html_result=tdriver_group.generate_report(@pass_statuses.first)
      html_body << title
      html_body << html_result
      html_body << "<input type=\"submit\" name=\"save_changes\" value=\"Save changes\" />" if @report_editable=='true'
      html_body << "</form>"
      html_body << '<form action="save_results_to" ><input type="submit" name="save_results_to" value="Download report" /></form>' if @report_editable=='true'
      tdriver_group=nil
      html_result=nil
    when 'failed'
      title='<div class="page_title"><center><h1>Failed</h1></center></div>'<<
        '<div class="summary_failed">' <<
        '<form action="save_total_run_results" >'
      tdriver_group=ReportingGroups.new(@reporting_groups,tc_arr)
      tdriver_group.parse_groups()
      html_result=tdriver_group.generate_report(@fail_statuses.first)
      html_body << title
      html_body << html_result
      html_body << "<input type=\"submit\" name=\"save_changes\" value=\"Save changes\" />" if @report_editable=='true'
      html_body << "</form>"
      html_body << '<form action="save_results_to" ><input type="submit" name="save_results_to" value="Download report" /></form>' if @report_editable=='true'
      tdriver_group=nil
      html_result=nil
    when 'not_run'
      title='<div class="page_title"><center><h1>Not run</h1></center></div>'<<
        '<div class="summary_not_run">' <<
        '<form action="save_total_run_results" >'
      tdriver_group=ReportingGroups.new(@reporting_groups,tc_arr)
      tdriver_group.parse_groups()
      html_result=tdriver_group.generate_report(@not_run_statuses.first)
      html_body << title
      html_body << html_result
      html_body << "<input type=\"submit\" name=\"save_changes\" value=\"Save changes\" />" if @report_editable=='true'
      html_body << "</form>"
      html_body << '<form action="save_results_to" ><input type="submit" name="save_results_to" value="Download report" /></form>' if @report_editable=='true'
      tdriver_group=nil
      html_result=nil
    when 'crash'
      title='<div class="page_title"><center><h1>Crash</h1></center></div>'<<
        '<div class="summary_crash">' <<
        '<form action="save_total_run_results" >'
      tdriver_group=ReportingGroups.new(@reporting_groups,tc_arr,false)
      tdriver_group.parse_groups()
      html_result=tdriver_group.generate_report('all')
      html_body << title
      html_body << html_result
      html_body << "<input type=\"submit\" name=\"save_changes\" value=\"Save changes\" />" if @report_editable=='true'
      html_body << "</form>"
      html_body << '<form action="save_results_to" ><input type="submit" name="save_results_to" value="Download report" /></form>' if @report_editable=='true'
      tdriver_group=nil
      html_result=nil
    when 'reboot'
      title='<div class="page_title"><center><h1>Reboot</h1></center></div>'<<
        '<div class="summary_reboot">' <<
        '<form action="save_total_run_results" >'
      tdriver_group=ReportingGroups.new(@reporting_groups,tc_arr,false)
      tdriver_group.parse_groups()
      html_result=tdriver_group.generate_report('all')
      html_body << title
      html_body << html_result
      html_body << "<input type=\"submit\" name=\"save_changes\" value=\"Save changes\" />" if @report_editable=='true'
      html_body << "</form>"
      html_body << '<form action="save_results_to" ><input type="submit" name="save_results_to" value="Download report" /></form>' if @report_editable=='true'
      tdriver_group=nil
      html_result=nil
    when 'statistics'
      title='<div class="page_title"><center><h1>Statistics</h1></center></div>'<<
        '<div class="statistics">'
      tdriver_group=ReportingStatistics.new(tc_arr)
      html_result=tdriver_group.generate_statistics_table()
      html_body << title
      html_body << html_result
      tdriver_group=nil
      html_result=nil
    else
      chronological_html_body=Array.new
      title='<div class="page_title"><center><h1>Total run</h1></center></div>'
      view_selection='<div class="summary_view_select"><center><input type="button" value="Grouped view" ONCLICK="location.assign(\''+report_page.to_s+'_total_run_index.html\');"/>'<<
        '<input type="button" value="Chronological view" ONCLICK="location.assign(\''+report_page.to_s+'_chronological_total_run_index.html\');"/></center></div>'<<
        '<div class="summary_total_run">' <<
        '<form action="save_total_run_results" >'
      title << view_selection
      tdriver_group=ReportingGroups.new(@reporting_groups,tc_arr)
      tdriver_group.parse_groups()
      html_result=tdriver_group.generate_report('all')
      html_body << title
      html_body << html_result
      html_body << "<input type=\"submit\" name=\"save_changes\" value=\"Save changes\" />" if @report_editable=='true'
      html_body << "</form>"
      html_body << '<form action="save_results_to" ><input type="submit" name="save_results_to" value="Download report" /></form>' if @report_editable=='true'
      html_body << '<form action="export_results_to_excel" ><input type="submit" name="export_results_to_excel" value="Export to Excel" /></form>' if @report_editable=='true'

      tdriver_group=nil
      html_result=nil
      tdriver_group=ReportingGroups.new(@reporting_groups,tc_arr,false)
      tdriver_group.parse_groups()
      chronological_html_result=tdriver_group.generate_report('all')
      chronological_html_body << title
      chronological_html_body << chronological_html_result
      chronological_html_body << "<input type=\"submit\" name=\"save_changes\" value=\"Save changes\" />" if @report_editable=='true'
      chronological_html_body << "</form>"
      chronological_html_body << '<form action="save_results_to" ><input type="submit" name="save_results_to" value="Download report" /></form>' if @report_editable=='true'
      chronological_html_body << '<form action="export_results_to_excel" ><input type="submit" name="export_results_to_excel" value="Export to Excel" /></form>' if @report_editable=='true'
      chronological_html_body << "</div>"

      File.open(chronological_page, 'a') do |f2|
        f2.puts chronological_html_body
      end
      tdriver_group=nil
      chronological_html_result=nil
      chronological_html_body=nil
    end
    html_body << '</div>'
    File.open(page, 'a') do |f2|
      f2.puts html_body
    end
    html_body=nil
    GC.start
  end

  def write_summary_body(page,start_time,end_time,run_time,total_run,total_passed,total_failed,total_not_run,total_crash_files,total_device_resets,summary_arr=nil)
    fail_rate=0
    pass_rate=0
    if total_run.to_i > 0
      begin
        fail_rate=(total_failed.to_f/(total_run.to_f-total_not_run.to_f))*100
        pass_rate=(total_passed.to_f/(total_run.to_f-total_not_run.to_f))*100
        fail_rate="%0.2f" % fail_rate
        pass_rate="%0.2f" % pass_rate
      rescue
        fail_rate="0"
        pass_rate="0"
      end
    end

    html_body='<div class="page_title"><center><h1>TDriver test results</h1></center></div>'<<
      '<div class="summary"><table align="center" style="width:80%;" border="0">'<<
      '<tr>'<<
      '<td><b>Started</b></td>'<<
      '<td>'+start_time.strftime("%d.%m.%Y %H:%M:%S")+'</td>'<<
      '</tr>'<<
      '<tr>'<<
      '<td><b>Ended</b></td>'
    begin
      html_body+='<td>'+end_time.strftime("%d.%m.%Y %H:%M:%S")+'</td>'
    rescue
      html_body+='<td>'+end_time.to_s+'</td>'
    end
    html_body+='</tr>'<<
      '<tr>'<<
      '<td><b>Runtime</b></td>'<<
      '<td>'+format_duration(run_time)+'</td>'<<
      '</tr>'<<
      '<tr>'<<
      '<td><a href="cases/1_total_run_index.html"><b>Total run</b></a></td>'<<
      '<td>'+total_run.to_s+'</td>'<<
      '</tr>'<<
      '<tr>'<<
      '<td><a href="cases/1_passed_index.html"><b>Passed</b></a></td>'<<
      '<td>'+total_passed.to_s+'</td>'<<
      '</tr>'<<
      '<tr>'<<
      '<td><a href="cases/1_failed_index.html"><b>Failed</b></a></td>'<<
      '<td>'+total_failed.to_s+'</td>'<<
      '</tr>'<<
      '<tr>'<<
      '<td><a href="cases/1_not_run_index.html"><b>Not run</b></a></td>'<<
      '<td>'+total_not_run.to_s+'</td>'<<
      '</tr>'<<
      '<tr>'<<
      '<td><b>Total crash files captured</b></td>'<<
      '<td>'+total_crash_files.to_s+'</td>'<<
      '</tr>'<<
      '<tr>'<<
      '<td><b>Total device resets</b></td>'<<
      '<td>'+total_device_resets.to_s+'</td>'<<
      '</tr>'
    $tdriver_reporter.total_dump_count.each do |item|
      html_body << '<tr>'<<
        "<td><b>Total dump count from sut #{item[0].to_s}</b></td>"<<
        '<td>'+item[1].to_s+'</td>'<<
        '</tr>'
    end
    $tdriver_reporter.total_sent_data.each do |item|
      html_body << '<tr>'<<
        "<td><b>Total bytes sent from sut #{item[0].to_s}</b></td>"<<
        '<td>'+item[1].to_s+'</td>'<<
        '</tr>'
    end
    $tdriver_reporter.total_received_data.each do |item|
      html_body << '<tr>'<<
        "<td><b>Total bytes received from sut #{item[0].to_s}</b></td>"<<
        '<td>'+item[1].to_s+'</td>'<<
        '</tr>'
    end
    html_body << '<tr>'<<
      '<td><b>Pass %</b></td>'<<
      '<td>'+pass_rate.to_s+'%</td>'<<
      '</tr>'<<
      '<tr>'<<
      '<td><b>Fail %</b></td>'<<
      '<td>'+fail_rate.to_s+'%</td>'<<
      '</tr>'<<
      '</table></div><p />'
    if summary_arr
      html_body << '<div class="statistics">'
      tdriver_group=ReportingStatistics.new(summary_arr,true)
      html_result=tdriver_group.generate_statistics_table()
      html_body << html_result << '</div>'
    end

    File.open(page, 'a') do |f2|
      f2.puts html_body
    end
    html_body=nil
  end
  def create_behaviour_links()
    folder=@report_folder+'/environment/behaviours'
    links=' '
    if File::directory?(folder.to_s)==true
      d=Dir.entries(folder.to_s)
      d.each do |x|
        if (x !='.' && x != '..')
          if x.include? '.xml'
            links << '<a href="behaviours/'+x+'">'+x+'</a> <br />'
          end
        end
      end
    end
    links
  end

  def create_templates_links()
    folder=@report_folder+'/environment/templates'
    links=' '
    if File::directory?(folder.to_s)==true
      d=Dir.entries(folder.to_s)
      d.each do |x|
        if (x !='.' && x != '..')
          if x.include? '.xml'
            links << '<a href="templates/'+x+'">'+x+'</a> <br />'
          end
        end
      end
    end
    links
  end

  def write_environment_body(page,os,sw,variant,product,language,loc)
    begin
      used_memory_difference=@memory_amount_start.to_i-@memory_amount_end.to_i
    rescue
      used_memory_difference='-'
    end

    tdriver_version=ENV['TDRIVER_VERSION']
    tdriver_version='TDRIVER_VERSION environment variable not found' if tdriver_version==nil
    html_body='<div class="page_title"><center><h1>TDriver test environment</h1></center></div>'<<
      '<div class="environment"><table align="center" style="width:80%;" border="0">'<<
      '<tr><td><b>OS</b></td><td>'<<
      os<<
      '</td></tr>'<<
      '<tr><td><b>TDriver version</b></td><td>'<<
      tdriver_version<<
      '</td></tr>'<<
      '<tr><td><b>SW Version</b></td><td>'<<
      sw<<
      '</td></tr>'<<
      '<tr><td><b>Variant</b></td><td>'<<
      variant<<
      '</td></tr>'<<
      '<tr><td><b>Product</b></td><td>'<<
      product<<
      '</td></tr>'<<
      '<tr><td><b>Language</b></td><td>'<<
      language<<
      '</td></tr>'<<
      '<tr><td><b>Localization</b></td><td>'<<
      loc<<
      '</td></tr>'<<
      '<tr><td><b>Total memory</b></td><td>'<<
      @memory_amount_total.to_s<<
      '</td></tr>'<<
      '<tr><td><b>Used memory at beginning</b></td><td>'<<
      @memory_amount_start.to_s<<
      '</td></tr>'<<
      '<tr><td><b>Used memory at end</b></td><td>'<<
      @memory_amount_end.to_s<<
      '</td></tr>'<<
      '<tr><td><b>Used memory difference</b></td><td>'<<
      used_memory_difference.to_s<<
      '</td></tr>'<<
      "<tr><td><b>Behaviours</b></td><td>#{create_behaviour_links()}</td></tr>"<<
      '<tr><td><b>Parameters</b></td><td><a href="tdriver_parameters.xml">tdriver_parameters.xml</a></td></tr>'<<
      "<tr><td><b>Templates</b></td><td>#{create_templates_links()}</td></tr>"<<
      '</table></div>'
    create_behaviour_links()
    File.open(page, 'a') do |f2|
      f2.puts html_body
    end
    html_body=nil
  end
  def write_tdriver_log_body(page,log)
    if log.length > 0
      log_summary=behaviour_log_summary(log,'array')
      formatted_log=format_behaviour_log(log,'array')
      File.open(page, 'a') do |f|
        f.write('<div class="page_title"><center><h1>TDriver Log</h1></center></div>')
        f.write('<div class="environment">')
        f.write('<center><H2>Summary</H2>')
        log_summary.each do |entry|
          f.write(entry)
        end
        f.write('</center><br /><br /></div><br />')
        f.write('<div class="environment">')
        formatted_log.each do |entry|
          f.write(entry)
        end
        f.write('</div>')
      end
    else
      File.open(page, 'a') do |f|
        f.write('<div class="page_title"><center><h1>TDriver Log</h1></center></div>')
        f.write('<div class="environment">')
        f.write('<center><H2>Log is empty</H2>')
        f.write('</center><br /><br /></div><br />')
      end
    end
  end
  def write_navigation_menu(page,title,report_page=nil,report_pages=nil)
    case title
    when "TDriver test results"
      tdriver_test_results_link='index.html" class="current"'
      tdriver_test_environment_link='environment/index.html"'
      tdriver_log_link='cases/tdriver_log_index.html"'
      total_run_link="cases/1_total_run_index.html\""
      statistics_link="cases/statistics_index.html\""
      passed_link="cases/1_passed_index.html\""
      failed_link="cases/1_failed_index.html\""
      not_run_link="cases/1_not_run_index.html\""
    when "TDriver test environment"
      tdriver_test_results_link='../index.html"'
      tdriver_test_environment_link='index.html" class="current"'
      tdriver_log_link='../cases/tdriver_log_index.html"'
      total_run_link="../cases/1_total_run_index.html\""
      statistics_link='../cases/statistics_index.html"'
      passed_link="../cases/1_passed_index.html\""
      failed_link="../cases/1_failed_index.html\""
      not_run_link="../cases/1_not_run_index.html\""
    when "Total run"
      tdriver_test_results_link='../index.html"'
      tdriver_test_environment_link='../environment/index.html"'
      tdriver_log_link='tdriver_log_index.html"'
      total_run_link="#{report_page}_total_run_index.html\" class=\"current\""
      statistics_link="statistics_index.html\""
      passed_link="1_passed_index.html\""
      failed_link="1_failed_index.html\""
      not_run_link="1_not_run_index.html\""
    when "Statistics"
      tdriver_test_results_link='../index.html"'
      tdriver_test_environment_link='../environment/index.html"'
      tdriver_log_link='tdriver_log_index.html"'
      total_run_link="1_total_run_index.html\""
      statistics_link='statistics_index.html" class="current"'
      passed_link="1_passed_index.html\""
      failed_link="1_failed_index.html\""
      not_run_link="1_not_run_index.html\""
    when "Passed"
      tdriver_test_results_link='../index.html"'
      tdriver_test_environment_link='../environment/index.html"'
      tdriver_log_link='tdriver_log_index.html"'
      total_run_link="1_total_run_index.html\""
      statistics_link='statistics_index.html"'
      passed_link="#{report_page}_passed_index.html\" class=\"current\""
      failed_link="1_failed_index.html\""
      not_run_link="1_not_run_index.html\""
    when "Failed","Crash","Reboot"
      tdriver_test_results_link='../index.html"'
      tdriver_test_environment_link='../environment/index.html"'
      tdriver_log_link='tdriver_log_index.html"'
      total_run_link="1_total_run_index.html\""
      statistics_link='statistics_index.html"'
      passed_link="1_passed_index.html\""
      failed_link="#{report_page}_failed_index.html\" class=\"current\""
      not_run_link="1_not_run_index.html\""
    when "Not run"
      tdriver_test_results_link='../index.html"'
      tdriver_test_environment_link='../environment/index.html"'
      tdriver_log_link='tdriver_log_index.html"'
      total_run_link="1_total_run_index.html\""
      statistics_link='statistics_index.html"'
      passed_link="1_passed_index.html\""
      failed_link="1_failed_index.html\""
      not_run_link="#{report_page}_not_run_index.html\" class=\"current\""
    when "TDriver log"
      tdriver_test_results_link='../index.html"'
      tdriver_test_environment_link='../environment/index.html"'
      tdriver_log_link='tdriver_log_index.html" class="current"'
      total_run_link="#{report_page}_total_run_index.html\""
      statistics_link='statistics_index.html"'
      passed_link="#{report_page}_passed_index.html\""
      failed_link="#{report_page}_failed_index.html\""
      not_run_link="#{report_page}_not_run_index.html\""
    else
      tdriver_test_results_link='../../index.html"'
      tdriver_test_environment_link='../../environment/index.html"'
      tdriver_log_link='../tdriver_log_index.html"'
      total_run_link="../1_total_run_index.html\""
      statistics_link='../statistics_index.html"'
      passed_link="../1_passed_index.html\""
      failed_link="../1_failed_index.html\""
      not_run_link="../1_not_run_index.html\""
    end
    html_body='<div class="navigation_section"><div class="navigation_tabs">'<<
      '<ul id="navigation_tabs_ul">'<<
      '<li><a href="'<<
      tdriver_test_results_link<<
      '>TDriver test results</a></li>'<<
      '<li><a href="'<<
      tdriver_test_environment_link<<
      '>TDriver test environment</a></li>'<<
      '<li><a href="'<<
      statistics_link<<
      '>Statistics</a></li>'<<
      '<li><a href="'<<
      total_run_link<<
      '>Total run</a></li>'<<
      '<li><a href="'<<
      passed_link<<
      '>Passed</a></li>'<<
      '<li><a href="'<<
      failed_link<<
      '>Failed</a></li>'<<
      '<li><a href="'<<
      not_run_link<<
      '>Not run</a></li>'<<
      '</ul>'<<
      '</div></div>'
    File.open(page, 'a') do |f2|
      f2.puts html_body
    end
    html_body=nil
  end

  def write_page_navigation_div(page,report_page,report_pages)
    page_with_no_number=page.gsub("#{report_page}_","")
    page_base_name=File.basename(page_with_no_number)
    div_body=Array.new
    div_body<<"<div class=\"page_navigation_section\"><center>"<<
      "<ul id=\"navigation\">"
    max=10
    start_page=report_page/max
    if start_page==0
      start_page=1
    else
      if (report_page%max)!=0
        start_page=(start_page*max)+1
      else
        start_page=(start_page*max)+1-max
      end
    end
    if (start_page+max)<report_pages
      end_page=(start_page+max)-1
    else
      end_page=report_pages
    end

    div_body<<"<li><a href=\"#{start_page-max}_#{page_base_name}\">Previous</a></li>" if start_page!=1

    for i in (start_page..end_page)
      div_body<<"<li><a href=\""
      if i==report_page
        div_body<<"#{i}_#{page_base_name}\" class=\"current\""
      else
        div_body<<"#{i}_#{page_base_name}\""
      end
      div_body<<">#{i}</a></li>"
    end
    div_body<<"<li><a href=\"#{end_page+1}_#{page_base_name}\">Next</a></li>" if end_page < report_pages
    div_body<<"</ul></center></div>"
    div_body
  end

  def write_page_end(page,report_page=nil,report_pages=nil)
    page_ready=nil
    if report_page!=nil
      navigation_div="#{write_page_navigation_div(page,report_page,report_pages)}"
      html_end="#{navigation_div}</body></html>"
      doc = Nokogiri::HTML(open(page))
      b_div_found=false
      doc.xpath('//div[@class="page_navigation_section"]').each do |div|
        if div.text.include?('Next')
          page_ready=report_page
        end
        b_div_found=true
        div.replace(Nokogiri.make(navigation_div))
      end
      if b_div_found==false
        File.open(page, 'a') do |f|
          f.puts html_end
        end
      else
        File.open(page, 'w') do |f|
          f.puts doc
        end
      end
    else
      html_end="</body></html>"
      File.open(page, 'a') do |f|
        f.puts html_end
      end
    end
    html_end=nil
    page_ready
  end
  def get_java_script()
    get_expand_collapse_java_script()
  end
  def format_user_log_table(user_data_rows,user_data_columns)
    begin
      formatted_user_data=Array.new
      formatted_user_data << '<div><table align="center" style="width:100%;" border="1">'
      header='<tr class="user_data_table_title">'
      user_data_columns.sort.each do |column|
        header=header+'<td><b>'+column.to_s+'</b></td>'
      end
      formatted_user_data << header +'</tr>'

      #first need to add empty values for those columns that donot exist

      user_data_rows.each do |row_hash|
        keys_need_adding = user_data_columns - row_hash.keys
        keys_need_adding.each do |new_key|
          row_hash[new_key] = " - "
        end
      end

      #create the table rows
      user_data_rows.each do |row_hash|
        row = '<tr>'
        row_hash.sort{|a,b| a[0]<=>b[0]}.each do |value|
          row=row+'<td>'+value[1].to_s+'</td>'
        end
        formatted_user_data << row+'</tr>'
      end
      formatted_user_data << '</table></div>'
      formatted_user_data.to_s
    rescue Exception => e
      '-'
    end
  end

end #end TDriverReportWriter


