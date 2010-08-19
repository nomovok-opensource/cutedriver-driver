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


class ReportingGroups
  def initialize(tdriver_groups,test_cases_array,grouping=true)
    #@reporting_groups='Common:Application:Close:Open|Common:Connect to|Common:Disconnect|Qt:Tap|Qt:Drag:Drag to|Qt:Type Text'
    if tdriver_groups != nil
      @reporting_groups=clean_reporting_groups(tdriver_groups)
    else
      @reporting_groups=nil
    end
    @main_groups=Array.new
    @main_groups_sub_level_one=Array.new
    @main_groups_sub_level_two=Array.new
    @main_groups_sub_level_three=Array.new
    @main_groups_sub_level_four=Array.new
    @main_groups_sub_level_five=Array.new
    #Group statistics
    @main_total=0
    @main_passed=0
    @main_failed=0
    @main_not_run=0
    @group_test_case_arr=Array.new(test_cases_array)
    @grouping=grouping
    @pass_statuses=MobyUtil::Parameter[ :report_passed_statuses, "passed" ].split('|')
    @fail_statuses=MobyUtil::Parameter[ :report_failed_statuses, "failed" ].split('|')
    @not_run_statuses=MobyUtil::Parameter[ :report_not_run_statuses, "not run" ].split('|')
  end
  def clean_reporting_groups(report_group_string)
    cleaned_group_string=''
    reporting_groups_arr=report_group_string.split('|')
    reporting_groups_arr.each do |main|
      groups_arr=main.split(':')
      first=true
      groups_arr.each do |sub|
        if first==true
          cleaned_group_string+=sub.strip
          first=false
        else
          cleaned_group_string+=':'+sub.strip
        end
      end
      cleaned_group_string+='|'
    end
    cleaned_group_string
  end
  def tog_list_statistics(tc_arr,group,status)
    status_row=''
    if status=='all'
      cases_in_group=0
      passed=0
      failed=0
      not_run=0
      tc_arr.each do |x|
        if x[1]==group
          cases_in_group+=1
          tc_status=x[7]
          passed+=1 if tc_status=='passed' || @pass_statuses.include?(tc_status)
          failed+=1 if tc_status=='failed' || @fail_statuses.include?(tc_status)
          not_run+=1 if tc_status=='not run' || @not_run_statuses.include?(tc_status)
        end
      end
      if cases_in_group > 0
        status_row = '<b style="color: #00FF00">Passed:</b>'+passed.to_s+' <b style="color: #FF0000">Failed:</b>'+failed.to_s+' <b style="color: #808080">Not run:</b>'+not_run.to_s+' <b>Total:</b>'+cases_in_group.to_s
      else
        status_row=0
      end
    else
      cases_in_group=0
      tc_arr.each do |x|
        if x[1]==group
          cases_in_group+=1
        end
      end
      if cases_in_group > 0
        status_row = '<b>Total:</b>'+cases_in_group.to_s
      else
        status_row=0
      end
    end
    status_row
  end
  def tog_list_begin(name,tc_arr,status,main=nil)
    if main==nil
      test_statistics=tog_list_statistics(tc_arr,name,status)
      if test_statistics != 0
        html_body='<dl class="togList">'<<
          '<dt onclick="tog(this)" style="background-color: #CCCCCC;"><b><span><input id="Button1" type="button" value="Open" class="btn" /></span> '<<
          name.to_s<<
          '</b> '<<
          '</dt>'<<
          '<dt>'<<
          test_statistics<<
          '</dt>'<<
          '<dd>'
      else
        html_body=0
      end
    else
      html_body='<dl class="togList">'<<
        '<dt onclick="tog(this)" style="background-color: #CCCCCC;"><b><span><input id="Button1" type="button" value="Open" class="btn" /></span> '<<
        name.to_s<<
        '</b> '<<
        '</dt>'<<
        '<dd>'
    end
    html_body
  end
  def tog_list_end(summary=nil)
    if summary == 'main'
      html_body='</dd>'<<
        '<dt>'<<
        '<b style="color: #00FF00"> Passed:</b>'<<
        @main_passed.to_s<<
        '<b style="color: #FF0000"> Failed:</b>'<<
        @main_failed.to_s<<
        '<b style="color: #808080"> Not run:</b>'<<
        @main_not_run.to_s<<
        '<b> Total:</b> '<<
        @main_total.to_s<<
        '</dt>'<<
        '</dl>'<<
        '<hr />'
    else
      html_body='</dd>'<<
        '</dl>'<<
        '<hr />'
    end

    html_body
  end
  def check_duplicate_groups(group_arr,group)
    b_group_exists=false
    group_arr.each do |existing_group|
      if existing_group[0] == group
        b_group_exists=true
        break
      end
    end
    b_group_exists
  end
  def check_duplicate_sub_groups(group_arr,main_group,sub_group)
    b_group_exists=false
    group_arr.each do |existing_group|
      if existing_group[0].to_s == main_group.to_s && existing_group[1].to_s == sub_group.to_s
        b_group_exists=true
        break
      end
    end
    b_group_exists
  end
  def parse_groups()
    if @reporting_groups != nil
      reporting_groups_arr=@reporting_groups.split('|')
      reporting_groups_arr.each do |groups|
        groups_arr=groups.split(':')
        if check_duplicate_groups(@main_groups,groups_arr[0])==false
          @main_groups << [groups_arr[0]]
        end
        current_level=0
        groups_arr.each do |group|
          if current_level==1
            if check_duplicate_sub_groups(@main_groups_sub_level_one,groups_arr[0],group)==false
              @main_groups_sub_level_one << [[groups_arr[0]],[group]]
            end
          end
          if current_level==2
            if check_duplicate_sub_groups(@main_groups_sub_level_two,groups_arr[0],group)==false
              @main_groups_sub_level_two << [[groups_arr[0]],[group]]
            end
          end
          if current_level==3
            if check_duplicate_sub_groups(@main_groups_sub_level_three,groups_arr[0],group)==false
              @main_groups_sub_level_three << [[groups_arr[0]],[group]]
            end
          end
          if current_level==4
            if check_duplicate_sub_groups(@main_groups_sub_level_four,groups_arr[0],group)==false
              @main_groups_sub_level_four << [[groups_arr[0]],[group]]
            end
          end
          if current_level==5
            if check_duplicate_sub_groups(@main_groups_sub_level_five,groups_arr[0],group)==false
              @main_groups_sub_level_five << [[groups_arr[0]],[group]]
            end
          end
          current_level+=1
        end
      end
    end
  end
  def status_select(selection_index, selected_status)
    
    status_selection = "<select name=\"#{selection_index}_status_select\">"
    selection_data=''
    @pass_statuses.each do |status|
      if status==selected_status
        selection_data << "<option selected>#{status}</option>"
      else
        selection_data << "<option>#{status}</option>"
      end
    end
    @fail_statuses.each do |status|
      if status==selected_status
        selection_data << "<option selected>#{status}</option>"
      else
        selection_data << "<option>#{status}</option>"
      end
    end
    @not_run_statuses.each do |status|
      if status==selected_status
        selection_data << "<option selected>#{status}</option>"
      else
        selection_data << "<option>#{status}</option>"
      end
    end
                                
    status_selection << selection_data << "</select>"
    status_selection
  end
  
  def get_user_cols(status,tc_arr)
    cols=nil
    if status=='all' && tc_arr!= nil 
      cols = Array.new
      tc_arr.each do |x|
        data_hash=x[12]
        cols << data_hash.keys
      end
      cols=cols.flatten.uniq
    end
    cols
  end
  
  def pad_user_data(status,data_hash,all_cols)
    if (status=='all' && all_cols!=nil && !all_cols.empty?)
      keys_need_adding = all_cols - data_hash.keys
      keys_need_adding.each do |new_key|
        data_hash[new_key] = "-"
      end
    end
  end
  
  def generate_test_results_table(status,tc_arr,item)
    table_body=Array.new
    if item==nil
      cases_in_group=0
      element=0
      table_body='<table align="center" style="width:100%;">'<<
        '<tr>'<<
        '<td>'<<
        '<b>Execution</b></td>'<<
        '<td>'<<
        '<b>Start Time</b></td>'<<
        '<td>'<<
        '<b>Name</b></td>'<<
        '<td>'<<
        '<b>Duration</b></td>'<<
        '<td>'<<
        '<b>Memory</b></td>'<<
        '<td>'<<
        '<b>Result</b></td>'<<
        '<td>'<<
        '<b>Comment</b></td>'
        
      user_cols=get_user_cols(status,tc_arr)
      if (user_cols!=nil && !user_cols.empty?)
        user_cols.sort.each do |col|
          table_body<<'<td>'<<'<b>'<<col.to_s<<'</b></td>'
        end
      end
  
      table_body<<'</tr>'
      
      tc_arr.each do |x|        
        cases_in_group+=1
        @main_total+=1
        tc_status=x[7].to_s
        tc_style_tag=' id=""'
        tc_style_tag=' id="passed_case"' if tc_status=='passed' || @pass_statuses.include?(tc_status)
        tc_style_tag=' id="failed_case"' if tc_status=='failed' || @fail_statuses.include?(tc_status)
        tc_style_tag=' id="not_run_case"' if tc_status=='not run' || @not_run_statuses.include?(tc_status)
        @main_passed+=1 if tc_status=='passed' || @pass_statuses.include?(tc_status)
        @main_failed+=1 if tc_status=='failed' || @fail_statuses.include?(tc_status)
        @main_not_run+=1 if tc_status=='not run' || @not_run_statuses.include?(tc_status)
        tc_name=x[0].to_s.gsub('_',' ')
        
        table_body << '<tr' <<
          tc_style_tag <<
          '>'<<
        '<td>'<<
          x[8]<< #testcase execution number
        '</td>'<<
          '<td>'<<
          x[4]<< #testcase start time
        '</td>'<<
          '<td><a name="'+tc_name.gsub(' ','_')+'_'+tc_status.to_s.gsub(' ','_')+'"></a>'<<
          '<a href="'<<
          x[11]<<
          '">'<<
          tc_name<<
          '</a></td>'<<
          '<td>'<<
          x[5]<< #testcase duration
        '</td>'<<
          '<td>'<<
          x[6]<< #testcase memory usage
        '</td>'<<
          '<td>'<<
          status_select(x[8],tc_status) <<
          '</td>'<<
          '<td>'<<
          "<textarea name=\"#{x[8]}_text_area\"  cols=\"23\" rows=\"2\">#{x[10]}</textarea>" <<
          '</td>'

          data_hash=x[12] 
          if (data_hash!=nil && !data_hash.empty?)
            #display user data
            pad_user_data(status,data_hash,user_cols)
            user_cols.sort.each do |col|
              row = '<td>'+data_hash[col].to_s+'</td>'
              table_body<<row
            end
          end
          table_body<<'</tr>'
      end
      if cases_in_group>0
        table_body << '</table>'
      else
        table_body='<br/>'
      end
    else
      if status=='all'
        cases_in_group=0
        element=0
        table_body='<table align="center" style="width:100%;">'<<
          '<tr>'<<
          '<td>'<<
          '<b>Name</b></td>'<<
          '<td>'<<
          '<b>Result</b></td>'<<
          '<td>'<<
          '<b>Comment</b></td>'<<
          '</tr>'
        tc_arr.each do |x|
          if x[1]==item.at(1).to_s
            cases_in_group+=1
            @main_total+=1
            tc_status=x[7].to_s
            tc_style_tag=' id=""'
            tc_style_tag=' id="passed_case"' if tc_status=='passed' || @pass_statuses.include?(tc_status)
            tc_style_tag=' id="failed_case"' if tc_status=='failed' || @fail_statuses.include?(tc_status)
            tc_style_tag=' id="not_run_case"' if tc_status=='not run' || @not_run_statuses.include?(tc_status)
            @main_passed+=1 if tc_status=='passed' || @pass_statuses.include?(tc_status)
            @main_failed+=1 if tc_status=='failed' || @fail_statuses.include?(tc_status)
            @main_not_run+=1 if tc_status=='not run' || @not_run_statuses.include?(tc_status)
            tc_name=x[0].to_s.gsub('_',' ')
            table_body << '<tr' <<
              tc_style_tag<<
              '>'<<
              '<td>'<<
              '<a href="'<<
              x[11]<<
              '">'<<
              tc_name<<
              '</a></td>'<<
              '<td>'<<
              status_select(x[8],tc_status) <<
              '</td>'<<
              '<td>'<<
              "<textarea name=\"#{x[8]}_text_area\"  cols=\"23\" rows=\"2\">#{x[10]}</textarea>" <<
              '</td>'<<
              '</tr>'
            @group_test_case_arr[element]=['--','--']
          end
          element+=1
        end
        if cases_in_group>0
          table_body << '</table>'
        else
          table_body='<br/>'
          
        end
      else
        tc_style_tag=' id=""'
        tc_style_tag=' id="passed_case"' if status=='passed' || @pass_statuses.include?(status)
        tc_style_tag=' id="failed_case"' if status=='failed' || @fail_statuses.include?(status)
        tc_style_tag=' id="not_run_case"' if status=='not run' || @not_run_statuses.include?(status)
        cases_in_group=0
        element=0
        table_body='<table align="center" style="width:100%;">'<<
          '<tr>'<<
          '<td>'<<
          '<b>Name</b></td>'<<
          '<td>'<<
          '<b>Result</b></td>'<<
          '<td>'<<
          '<b>Comment</b></td>'<<
          '</tr>'
        tc_arr.each do |x|
          if x[1]==item.at(1).to_s
            @main_total+=1
            @main_passed+=1 if status=='passed' || @pass_statuses.include?(status)
            @main_failed+=1 if status=='failed' || @fail_statuses.include?(status)
            @main_not_run+=1 if status=='not run' || @not_run_statuses.include?(status)
            cases_in_group+=1
            tc_status=x[7]
            tc_name=x[0].to_s.gsub('_',' ')
            table_body << '<tr' <<
              tc_style_tag<<
              '>'<<
              '<td>'<<
              '<a href="'<<
              x[11]<<
              '">'<<
              tc_name<<
              '</a></td>'<<
              '<td>'<<
              status_select(x[8],tc_status) <<
              '</td>'<<
              '<td>'<<
              "<textarea name=\"#{x[8]}_text_area\"  cols=\"23\" rows=\"2\">#{x[10]}</textarea>" <<
              '</td>'<<
              '</tr>'
            @group_test_case_arr[element]=['--','--']
          end
          element+=1
        end
        if cases_in_group > 0
          table_body << '</table>'
        else
          table_body='<br/>'
        end
      end
    end
    table_body
  end
  def generate_report(status)
    html_body=Array.new
    if @grouping==true
      @main_groups.each do |group|
        @main_total=0
        @main_passed=0
        @main_failed=0
        @main_not_run=0
        html_body << tog_list_begin(group,@group_test_case_arr,status,'main')
        html_body << generate_test_results_table(status,@group_test_case_arr,[group,group])
        tog_list1=0
        tog_list2=0
        tog_list3=0
        tog_list4=0
        tog_list5=0
        @main_groups_sub_level_one.each do |item1|

          if group.to_s == item1.at(0).to_s && @reporting_groups.include?(group.to_s+':'+item1.at(1).to_s)
            tog_list1=tog_list_begin(item1.at(1).to_s,@group_test_case_arr,status)
            if tog_list1 != 0
              html_body << tog_list1
              html_body << generate_test_results_table(status,@group_test_case_arr,item1)
            end
            @main_groups_sub_level_two.each do |item2|
              if group.to_s == item2.at(0).to_s && @reporting_groups.include?(item1.at(1).to_s+':'+item2.at(1).to_s)
                tog_list2=tog_list_begin(item2.at(1).to_s,@group_test_case_arr,status)
                if tog_list2 != 0
                  html_body << tog_list2
                  html_body << generate_test_results_table(status,@group_test_case_arr,item2)
                end
                @main_groups_sub_level_three.each do |item3|
                  if group.to_s == item3.at(0).to_s && @reporting_groups.include?(item2.at(1).to_s+':'+item3.at(1).to_s)
                    tog_list3=tog_list_begin(item3.at(1).to_s,@group_test_case_arr,status)
                    if tog_list3 != 0
                      html_body << tog_list3
                      html_body << generate_test_results_table(status,@group_test_case_arr,item3)
                    end
                    @main_groups_sub_level_four.each do |item4|
                      if group.to_s == item4.at(0).to_s && @reporting_groups.include?(item3.at(1).to_s+':'+item4.at(1).to_s)
                        tog_list4=tog_list_begin(item4.at(1).to_s,@group_test_case_arr,status)
                        if tog_list4 != 0
                          html_body << tog_list4
                          html_body << generate_test_results_table(status,@group_test_case_arr,item4)
                        end
                        @main_groups_sub_level_five.each do |item5|
                          if group.to_s == item5.at(0).to_s && @reporting_groups.include?(item4.at(1).to_s+':'+item5.at(1).to_s)
                            tog_list5=tog_list_begin(item5.at(1).to_s,@group_test_case_arr,status)
                            if tog_list5 != 0
                              html_body << tog_list5
                              html_body << generate_test_results_table(status,@group_test_case_arr,item5)
                              html_body << tog_list_end()
                            end
                          end
                        end
                        if tog_list4 != 0
                          html_body << tog_list_end()
                        end
                      end
                    end
                    if tog_list3 != 0
                      html_body << tog_list_end()
                    end
                  end
                end
                if tog_list2 != 0
                  html_body << tog_list_end()
                end
              end
            end
            if tog_list1 != 0
              html_body << tog_list_end()
            end
          end
        end
        html_body << tog_list_end('main')
      end
      html_body << generate_test_results_table(status,@group_test_case_arr,['not_in_any_user_defined_group','not_in_any_user_defined_group'])
    else
      #html_body << tog_list_begin('Total run',@group_test_case_arr,status,'main')
      html_body << generate_test_results_table(status,@group_test_case_arr,nil)
      html_body << tog_list_end('main')
    end
    html_body
  end
end
