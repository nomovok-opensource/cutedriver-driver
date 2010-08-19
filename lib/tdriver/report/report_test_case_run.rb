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
  #Test case class for new test case run
  class TestCaseRun < TDriverReportCrashFileCapture
    include TDriverReportWriter
    def initialize()
      @test_case_folder=nil
      @test_cases_folder=nil
      @test_case_name=nil
      @test_case_ended=false
      @test_case_name_full=nil
      @test_case_index=nil
      @test_case_start_time=nil
      @test_case_end_time=nil
      @test_case_run_time=nil
      @test_case_status=nil
      @test_case_execution_log=nil
      @test_case_user_data=nil
      @test_case_user_data_columns=nil
      @test_case_chronological_view_data=nil
      @capture_screen_error=nil
      @failed_dump_error=nil
      @test_case_reboots=0
      @test_case_crash_files=0
      @test_case_behaviour_log = Array.new
      @failed_screenshot=nil
      @test_case_group=nil
      @tc_video_recording=false
      @tc_video_filename=nil
      @tc_previous_video_filename=nil
      @tc_video_recorder=nil
      @tc_memory_amount_start=nil
      @tc_memory_amount_end=nil
      @tc_memory_amount_start='-'
      @tc_memory_amount_end='-'
      @tc_memory_amount_total='-'      
      @pass_statuses=MobyUtil::Parameter[ :report_passed_statuses, "passed" ].split('|')
      @fail_statuses=MobyUtil::Parameter[ :report_failed_statuses, "failed" ].split('|')
      @not_run_statuses=MobyUtil::Parameter[ :report_not_run_statuses, "not run" ].split('|')
      @test_case_logging_level = MobyUtil::Parameter[ :logging_level, nil ]
      @trace_directory=MobyUtil::Parameter[ :report_trace_folder, nil]
      $tdriver_report_log_output = StringIO.new ""
      begin
        if MobyUtil::Parameter[:behaviour_logging] == 'true'
          if @test_case_logging_level.to_i > 0
            logger_instance = MobyUtil::Logger.instance.get_logger( 'TDriver' )
            begin
              MobyUtil::Logger.instance.remove_outputter(logger_instance, 'io' )
            rescue
            end
            o = Log4r::IOOutputter.new("io",$tdriver_report_log_output)
            MobyUtil::Logger.instance.add_outputter(logger_instance, o)
          end
        end
      rescue
      end
    end
    #This method sets the test case group
    #
    # === params
    # value: test case report folder
    # === returns
    # nil
    # === raises
    def set_test_case_group(value)
      @test_case_group=value
    end
    #This method sets the test case reboots
    #
    # === params
    # value: amount
    # === returns
    # nil
    # === raises
    def set_test_case_reboots(value)
      @test_case_reboots=@test_case_reboots.to_i+value.to_i
    end
    #This method sets the test case crash files
    #
    # === params
    # value: amount
    # === returns
    # nil
    # === raises
    def set_test_case_crash_files(value)
      @test_case_crash_files=@test_case_crash_files.to_i+value.to_i
    end
    #This method sets the tdriver test cases report folder
    #
    # === params
    # value: test cases report folder
    # === returns
    # nil
    # === raises
    def set_test_cases_folder(value)
      @test_cases_folder=value
    end
    #This method sets the tdriver test case has ended
    #
    # === params
    # value: test cases report folder
    # === returns
    # nil
    # === raises
    def set_test_case_ended(value)
      @test_case_ended=value
    end
    #This method sets the tdriver test case report folder
    #
    # === params
    # value: test case report folder
    # === returns
    # nil
    # === raises
    def set_test_case_folder(value)
      @test_case_folder=value
    end
    #This method sets the tdriver test case name
    #
    # === params
    # value: test case name
    # === returns
    # nil
    # === raises
    def set_test_case_name_full(value)
      @test_case_name_full=value
    end
    #This method sets the tdriver test case name
    #
    # === params
    # value: test case name
    # === returns
    # nil
    # === raises
    def set_test_case_name(value)
      @test_case_name_full=value
      #Clean the test case name for unwanted chars
      stripped=value.gsub(/[<\/?*>!)(}{\{@%"'.,:;~-]/,'').squeeze(" ")
      if stripped==nil then
        stripped=value.squeeze(" ")
      end
      stripped1 = stripped.to_s.gsub(' ','_')      
      if stripped1==nil
        stripped1=stripped
      end
      str = stripped1.slice(0, 100)
      if str == nil
        str=stripped1
      end
      stripped1=str
      @test_case_name=stripped1.to_s
    end
    #This method sets the test case index
    #
    # === params
    # value: test case index
    # === returns
    # nil
    # === raises
    def set_test_case_index(value)
      @test_case_index=value
    end
    #This method sets the test case start time
    #
    # === params
    # value: test case start time
    # === returns
    # nil
    # === raises
    def set_test_case_start_time(value)
      @test_case_start_time=value
    end
    #This method sets the test case end time
    #
    # === params
    # value: test case end time
    # === returns
    # nil
    # === raises
    def set_test_case_end_time(value)
      @test_case_end_time=value
    end
    #This method sets the test case run time
    #
    # === params
    # value: test case run time
    # === returns
    # nil
    # === raises
    def set_test_case_run_time(value)
      @test_case_run_time=value
    end
    #This method sets the test case status
    #
    # === params
    # value: test case status
    # === returns
    # nil
    # === raises
    def set_test_case_status(value)
      @test_case_status=value
    end
    #This method sets the test case execution log
    #
    # === params
    # value: test case execution log entry
    # === returns
    # nil
    # === raises
    def set_test_case_execution_log(value)     
      @test_case_execution_log=@test_case_execution_log.to_s + '<br />' + value.to_s.gsub(/\n/,'<br />')
    end
    #This method sets the test case user data
    #
    # === params
    # value: test case user data
    # === returns
    # nil
    # === raises
    def set_test_case_user_data(data,columns)
      @test_case_user_data=data
      @test_case_user_data_columns=columns    
    end
    #This method sets the users data to display in chronological table
    #
    # === params
    # value: test case user data
    # === returns
    # nil
    # === raises
    def set_test_case_chronological_view_data(data)
      @test_case_chronological_view_data=data
    end    
    #This method sets the test case behaviour log
    #
    # === params
    # value: test case execution log entry
    # === returns
    # nil
    # === raises
    def set_test_case_behaviour_log(value,test_case)
      @test_case_behaviour_log << [value.to_s,test_case]
    end
    #Thid methods sets video recording of the test case
    #
    # === params
    # rec_name: String, name of video file to create
    # previous_name: String, name of video file of previous test case	
    # === returns
    # nil
    def start_video_recording( rec_name, previous_name )
				
      require File.expand_path( File.join( File.dirname( __FILE__ ), '..', 'util', 'video_rec' ) )
      @tc_video_filename = rec_name
      @tc_previous_video_filename = previous_name
      tc_video_width = 640
      tc_video_height = 480
      tc_video_fps = 30
		
      begin
        tc_video_width = MobyUtil::Parameter[ :report_video_width ].to_i
      rescue
        # parameter not loaded, do nothing
      end
      begin
        tc_video_height = MobyUtil::Parameter[ :report_video_height ].to_i
      rescue
        # parameter not loaded, do nothing
      end
      begin
        tc_video_fps = MobyUtil::Parameter[ :report_video_fps ].to_i
      rescue
        # parameter not loaded, do nothing
      end
		
      #begin
      @tc_video_recorder=MobyUtil::TDriverWinCam.new( @tc_video_filename, { :width => tc_video_width, :height => tc_video_height, :fps => tc_video_fps } )
      @tc_video_recorder.start_recording
      @tc_video_recording = true
      #rescue
		  
      #end
	  
      nil
		
    end
	  
    def stop_video_recording()
      @tc_video_recorder.stop_recording
      @tc_video_recording = false
    end
    #This method sets the tdriver test case memory at start
    #
    # === params
    # value: memory
    # === returns
    # nil
    # === raises
    def set_tc_memory_amount_start(value)
      @tc_memory_amount_start=value
    end
    #This method sets the tdriver test case memory at end
    #
    # === params
    # value: memory
    # === returns
    # nil
    # === raises
    def set_tc_memory_amount_end(value)
      @tc_memory_amount_end=value
    end
    #This method sets the tdriver test case total memory
    #
    # === params
    # value: memory
    # === returns
    # nil
    # === raises
    def set_tc_memory_amount_total(value)
      @tc_memory_amount_total=value
    end
    #This method gets the test case reboots
    #
    # === params
    # value: amount
    # === returns
    # nil
    # === raises
    def get_test_case_reboots()
      @test_case_reboots
    end
    #This method gets the test case crash files
    #
    # === params
    #
    # === returns
    # nil
    # === raises
    def get_test_case_crash_files()
      @test_case_crash_files
    end
    #This method gets the test case folder
    #
    # === params
    # nil
    # === returns
    # test case folder object
    # === raises
    def get_test_case_folder()
      @test_case_folder
    end
    #This method gets the test case name
    #
    # === params
    # nil
    # === returns
    # test case name object
    # === raises
    def get_test_case_name()
      @test_case_name
    end
    #This method gets the full test case name
    #
    # === params
    # nil
    # === returns
    # full test case name object
    # === raises
    def get_test_case_name_full()
      @test_case_name_full
    end
    #This method gets the test case index
    #
    # === params
    # nil
    # === returns
    # test case index object
    # === raises
    def get_test_case_index()
      @test_case_index
    end
    #This method gets the tdriver test case ended status
    #
    # === params
    # value: test cases report folder
    # === returns
    # nil
    # === raises
    def get_test_case_ended()
      @test_case_ended
    end
    #This method gets the test case logging level
    #
    # === params
    # nil
    # === returns
    # test case index object
    # === raises
    def get_test_case_logging_level()
      @test_case_logging_level
    end
    #This method gets the test case start time
    #
    # === params
    # nil
    # === returns
    # test case start time object
    # === raises
    def get_test_case_start_time()
      @test_case_start_time
    end
    #This method gets the test case end time
    #
    # === params
    # nil
    # === returns
    # test case end time object
    # === raises
    def get_test_case_end_time()
      @test_case_end_time
    end
    #This method gets the test case run time
    #
    # === params
    # nil
    # === returns
    # test case run time object
    # === raises
    def get_test_case_run_time()
      @test_case_run_time
    end
    #This method gets the test case status
    #
    # === params
    # nil
    # === returns
    # test case status object
    # === raises
    def get_test_case_status()
      @test_case_status
    end
    #This method gets the test case execution log
    #
    # === params
    # nil
    # === returns
    # test case execution log object
    # === raises
    def get_test_case_execution_log()
      @test_case_execution_log
    end
    #This method gets the test case behaviour log
    #
    # === params
    # nil
    # === returns
    # test case execution log object
    # === raises
    def get_test_case_behaviour_log()
      @test_case_behaviour_log
    end
    #This method gets the tdrivertest case memory at start
    #
    # === params
    # value: memory
    # === returns
    # nil
    # === raises
    def get_tc_memory_amount_start()
      @tc_memory_amount_start
    end
    #This method gets the tdrivertest case memory at end
    #
    # === params
    # value: memory
    # === returns
    # nil
    # === raises
    def get_tc_memory_amount_end()
      @tc_memory_amount_end
    end
    #This method gets the tdrivertest case total memory
    #
    # === params
    # value: memory
    # === returns
    # nil
    # === raises
    def get_tc_memory_amount_total()
      @tc_memory_amount_total
    end
    #This method gets the test case group
    #
    # === params
    # value: test case report folder
    # === returns
    # nil
    # === raises
    def get_test_case_group()
      @test_case_group
    end
    #This method gets the test case displays data
    #
    # === params
    # value: test case report folder
    # === returns
    # nil
    # === raises
    def get_test_case_chronological_view_data()
      @test_case_chronological_view_data
    end
    #This method updates the tdrivertest case details page
    #
    # === params
    # nil
    # === returns
    # nil
    # === raises
    def update_test_case_page()
      begin
        #Calculate run time
        @test_case_run_time=Time.now-@test_case_start_time
        write_page_start(@test_case_folder+'/index.html',@test_case_name)
        write_test_case_body(@test_case_folder+'/index.html',@test_case_name_full,@test_case_start_time,@test_case_end_time,@test_case_run_time,@test_case_status,@test_case_index,@test_case_folder,@capture_screen_error,@failed_dump_error,@test_case_reboots)
        write_page_end(@test_case_folder+'/index.html')
      rescue Exception => e
        Kernel::raise e
      end
      return nil
    end    
    #This method makes a copy of the video recording of this test case
    def copy_video_capture()
	
      stop_video_recording
	  
      logging_enabled = MobyUtil::Logger.instance.enabled
      MobyUtil::Logger.instance.enabled=false
      begin
	  
        video_folder=@test_case_folder+'/video'
        if File::directory?(video_folder)==false
          FileUtils.mkdir_p video_folder
        end        
		
        File.copy(@tc_video_filename, video_folder)		
        File.copy(@tc_previous_video_filename, video_folder)
		
      rescue Exception => e
        @test_case_execution_log=@test_case_execution_log.to_s + '<br />' + "Unable to store video file(#{@tc_video_filename}): " + e.message
      end
	  
      MobyUtil::Logger.instance.enabled=logging_enabled
      return nil
    end
    #This method captures the failed xml dump and image
    #
    # === params
    # nil
    # === returns
    # nil
    # === raises
    def capture_dump(take_screenshot=true)      
      MobyUtil::Logger.instance.enabled=false
      image_html=Array.new
      state_html=Array.new
      self.set_test_case_execution_log('<hr />')
      begin
        dump_folder=@test_case_folder+'/state_xml'
        if File::directory?(dump_folder)==false
          FileUtils.mkdir_p dump_folder
        end
        MobyBase::SUTFactory.instance.connected_suts.each do |sut_id, sut_attributes|
          
          t = Time.now
          time_stamp=t.strftime( "%Y%m%d%H%M%S" )
          if take_screenshot==true
            begin
              sut_attributes[:sut].capture_screen( :Filename => dump_folder+'/'+time_stamp+'_state.png', :Redraw => true ) if sut_attributes[:is_connected]
              image_html='<a href="state_xml/'<<
                time_stamp+'_state.png'<<
                '"><img alt="" src="state_xml/'<<
                time_stamp+'_state.png'<<
                '" width=20% height=20% /></a>'
              self.set_test_case_execution_log(image_html.to_s)
            rescue Exception=>e             
              @capture_screen_error="Unable to capture sceen image: " + e.message    
              self.set_test_case_execution_log(@capture_screen_error.to_s)
            end
          end
        
          begin
            failed_xml_state=sut_attributes[:sut].xml_data() if sut_attributes[:is_connected]
            File.open(dump_folder+'/'+time_stamp+'_state.xml', 'w') { |file| file.write(failed_xml_state) }
            state_html='<a href="state_xml/'<<
              time_stamp+'_state.xml'<<
              '">'+time_stamp+'_state.xml'+'</a>'
              self.set_test_case_execution_log(state_html.to_s)
          rescue Exception=>e           
            @failed_dump_error="Unable to capture state xml: " + e.message
            self.set_test_case_execution_log(@failed_dump_error.to_s)
          end
  			end
      rescue Exception => e
        @capture_screen_error="Unable to capture state: " + e.message
        self.set_test_case_execution_log(@capture_screen_error.to_s)
      ensure
        if MobyUtil::Parameter[ :logging_level, 0 ].to_i > 0
          MobyUtil::Logger.instance.enabled=true
        else
          MobyUtil::Logger.instance.enabled=false
        end
        self.set_test_case_execution_log('<hr />')
      end
    end
    #This method captures the trace files
    #
    # === params
    # nil
    # === returns
    # nil
    # === raises
    def capture_trace_files()
      if MobyUtil::Parameter[ :report_trace_capture, false]=="true"
        trace_folder=MobyUtil::Parameter[ :report_trace_folder, nil]
        if trace_folder!=nil
          if File::directory?(trace_folder)==true
            dump_folder=@test_case_folder+'/trace_files'
            if File::directory?(dump_folder)==false
              FileUtils.mkdir_p dump_folder
            end
            FileUtils.cp_r trace_folder, @test_case_folder+'/trace_files'
          end
        end
      end
    end
    #This method creates a new TDriver test case folder when testing is ended
    #
    # === params
    # nil
    # === returns
    # nil
    # === raises
    def  create_test_case_folder(status)
      begin
        #check if report directory exists
        @test_case_folder=@test_cases_folder+'/'+status+'_'+@test_case_index.to_s+'_'+@test_case_name
        if File::directory?(@test_case_folder)==false
          FileUtils.mkdir_p @test_case_folder
        end
      rescue Exception => e
        Kernel::raise e
      end
      return nil
    end

    #This method renames a new TDriver test case folder when testing is ended
    #
    # === params
    # nil
    # === returns
    # nil
    # === raises
    def  rename_test_case_folder(status)
      begin
        #check if report directory exists
        old_test_case_folder=@test_case_folder
        new_test_case_folder=@test_case_folder.gsub('result',status)        
        if File::directory?(new_test_case_folder)==false
          FileUtils.mv old_test_case_folder, new_test_case_folder , :force => true  # no error
          @test_case_folder=new_test_case_folder
        end
      rescue Exception => e
        Kernel::raise e
      end
      return nil
    end

    def video_recording?
      @tc_video_recording
    end
  end
end