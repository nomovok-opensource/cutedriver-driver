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
    attr_accessor(
      :test_case_folder,
      :test_cases_folder,
      :test_case_name,
      :test_case_ended,
      :test_case_name_full,
      :test_case_index,
      :test_case_start_time,
      :test_case_end_time,
      :test_case_run_time,
      :test_case_status,
      :test_case_execution_log,
      :test_case_user_data,
      :test_case_user_data_columns,
      :test_case_chronological_view_data,
      :test_case_total_dump_count,
      :test_case_total_data_sent,
      :test_case_total_data_received,
      :test_case_dump_count_at_start,
      :test_case_dump_count_at_end,
      :test_case_data_sent_at_start,
      :test_case_data_sent_at_end,
      :test_case_data_received_at_start,
      :test_case_data_received_at_end,
      :capture_screen_error,
      :failed_dump_error,
      :test_case_reboots,
      :test_case_crash_files,
      :test_case_behaviour_log,
      :failed_screenshot,
      :test_case_group,
      :tc_video_recording,
      :tc_video_filename,
      :tc_previous_video_filename,
      :tc_video_recorders,
      :tc_memory_amount_start,
      :tc_memory_amount_end,
      :tc_memory_amount_start,
      :tc_memory_amount_total,
      :pass_statuses,
      :fail_statuses,
      :not_run_statuses,
      :test_case_logging_level,
      :trace_directory
    )
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
      @tc_video_recorders=[]
      @tc_memory_amount_start='-'
      @tc_memory_amount_end='-'
      @tc_memory_amount_total='-'
      @test_case_total_dump_count=Hash.new
      @test_case_total_data_sent=Hash.new
      @test_case_total_data_received=Hash.new
      @test_case_dump_count_at_start=Hash.new
      @test_case_dump_count_at_end=Hash.new
      @test_case_data_sent_at_start=Hash.new
      @test_case_data_sent_at_end=Hash.new
      @test_case_data_received_at_start=Hash.new
      @test_case_data_received_at_end=Hash.new
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
      stripped=value.gsub(/[<\/?*>!)(}{\\{@%"'.,:;~-]/,'').squeeze(" ")
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


      @tc_video_recorders = []

      begin
        each_video_device do | video_device, device_index |

          rec_options = { :width => tc_video_width, :height => tc_video_height, :fps => tc_video_fps }
          rec_options[ :device ] = video_device unless video_device == "true" # use default device if "true"
          video_recorder = MobyUtil::TDriverCam.new_cam( "cam_" + device_index + "_" + @tc_video_filename, rec_options )
          video_recorder.start_recording
          @tc_video_recorders << video_recorder
          @tc_video_recording = true

        end
      rescue Exception => e
        # make sure to stop any started cams if startup fails
        stop_video_recording
        raise e

      end

      nil

    end

    def target_video_alive

      ret = ""
      each_video_device do | video_device, device_index |

        check_fps = MobyUtil::Parameter[:report_activity_fps, '3']
        check_frame_min = MobyUtil::Parameter[:report_activity_frame_treshold, '8']
        check_video_min = MobyUtil::Parameter[:report_activity_video_treshold, '29']

        ret_n = MobyUtil.video_alive? "cam_" + device_index + "_" + @tc_video_filename, check_fps.to_f, check_frame_min.to_f, check_video_min.to_f, false

        if !ret_n
          ret += ", " if !ret.empty?
          ret += "cam_" + device_index + "_" + @tc_video_filename
        end

      end

      return ret

    end

    def stop_video_recording()


      @tc_video_recorders.each do | video_recorder |
        video_recorder.stop_recording
      end

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

    #This method updates the tdrivertest case details page
    #
    # === params
    # nil
    # === returns
    # nil
    # === raises
    def update_test_case_page(rewrite=false)
      begin
        #Calculate run time
        @test_case_run_time=Time.now-@test_case_start_time

        #make sure that test case folder exists:
        if File::directory?(@test_case_folder)==false
          FileUtils.mkdir_p @test_case_folder
        end

        write_page_start(@test_case_folder+'/index.html',@test_case_name)
        write_test_case_body(@test_case_folder+'/index.html',
          @test_case_name_full,
          @test_case_start_time,
          @test_case_end_time,
          @test_case_run_time,
          @test_case_status,
          @test_case_index,
          @test_case_folder,
          @capture_screen_error,
          @failed_dump_error,
          @test_case_reboots,
          @test_case_total_dump_count,
          @test_case_total_data_sent,
          @test_case_total_data_received
        )
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


        each_video_device do | video_device, device_index |

          begin
            FileUtils.copy("cam_" + device_index + "_" + @tc_video_filename, video_folder)
          rescue
            # Copy failed, do nothing
          end

          begin
            FileUtils.copy("cam_" + device_index + "_" + @tc_previous_video_filename, video_folder)
          rescue
            # Copy failed, do nothing
          end

        end



      rescue Exception => e
        @test_case_execution_log=@test_case_execution_log.to_s + '<br />' + "Unable to store video file: " + e.message
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
    def capture_dump(take_screenshot=true,arguments=Hash.new)
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
              sut_attributes[:sut].capture_screen( :Filename => dump_folder+'/'+time_stamp+'_'+sut_id.to_s+'_state.png', :Redraw => true ) if sut_attributes[:is_connected]
              if arguments[:file]
                sut_attributes[:sut].capture_screen( :Filename => arguments[:file], :Redraw => true ) if sut_attributes[:is_connected]
              end
              image_html='<div class="img"><a href="state_xml/'<<
                time_stamp+'_'+sut_id.to_s+'_state.png'<<
                '" target="_blank"><img alt="" src="state_xml/'<<
                time_stamp+'_'+sut_id.to_s+'_state.png'<<
                '" width="10%" height="10%" /></a>'
                if arguments[:text]
                  image_html << "<div class=\"desc\">#{arguments[:text]}</div>"
                end
                image_html << '</div>'
              self.set_test_case_execution_log(image_html.to_s)
            rescue Exception=>e
              @capture_screen_error="Unable to capture sceen image #{sut_id}: " + e.message
              self.set_test_case_execution_log(@capture_screen_error.to_s)
            end
          end

          begin
            failed_xml_state=sut_attributes[:sut].xml_data() if sut_attributes[:is_connected]
            File.open(dump_folder+'/'+time_stamp+'_'+sut_id.to_s+'_state.xml', 'w') { |file| file.write(failed_xml_state) }
            state_html='<a href="state_xml/'<<
              time_stamp+'_'+sut_id.to_s+'_state.xml'<<
              '">'+time_stamp+'_'+sut_id.to_s+'_state.xml'+'</a>'
            self.set_test_case_execution_log(state_html.to_s)
          rescue Exception=>e
            @failed_dump_error="Unable to capture state xml #{sut_id}: " + e.message
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
        new_test_case_folder=@test_case_folder.sub('result'+'_'+@test_case_index.to_s+'_'+@test_case_name,status+'_'+@test_case_index.to_s+'_'+@test_case_name)
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