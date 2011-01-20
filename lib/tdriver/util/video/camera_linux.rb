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

module MobyUtil
  
  # Linux streamer webcam implementation
  # Requires that the streamer application is installed
  class TDriverLinuxCam

    STARTUP_TIMEOUT = 60

    DEFAULT_OPTIONS = { :device => '/dev/video0', :width => 320, :height => 240, :fps => 5 }

    # TODO: document me
    def self.new_cam( *args )

      MobyUtil::TDriverLinuxCam.new( *args )

    end

    # Creates a new recroding object witdh the given recording options    
    # === params
    # video_file: String, path and name of file where the recorded video is stored
    # user_options: (optional) Hash, keys :fps, :width, :height can be used to overwrite defaults
    def initialize( video_file, user_options = {} )      

      @_device = nil
      @_video_file = nil
      @_recording = false
      @_rec_options = nil
      @_owcc_startex = nil
      @_owcc_stop = nil
      
      @_control_id = nil
      @_video_file = video_file
      @_rec_options = DEFAULT_OPTIONS.merge user_options
          
    end
    
    # Starts recording based on options given during initialization
    # === raises
    # RuntimeError: No filename has been defined or recording initialization failed due to timeout.
    def start_recording

      raise RuntimeError.new( "No video file defined, unable to start recording." ) if @_video_file.nil?

      if File.exists?( @_video_file )        
        begin
          File.delete( @_video_file )
            rescue
          # no reaction to failed file ops, unless recording fails
        end
      end  

      rec_command = 'streamer -q -c ' + @_rec_options[ :device ].to_s + ' -f rgb24 -r ' + @_rec_options[ :fps ].to_s + ' -t 99:00:00 -o ' +  @_video_file.to_s + ' -s ' + @_rec_options[ :width ].to_s + 'x' + @_rec_options[ :height ].to_s

      @_streamer_pid = fork do
        begin
          Kernel::exec( rec_command )
        rescue Exception => e
          raise RuntimeError.new( "An error was encountered while launching streamer:\n" << e.inspect )
        end
      end

      file_timed_out = false

      file_timeout = Time.now + STARTUP_TIMEOUT

      while File.size?( @_video_file ).nil? && !file_timed_out do

        #wait for recording to start, ie. filesize > 0
        sleep 0.1

        file_timed_out = true if Time.now > file_timeout

      end
      
      if file_timed_out

        # make sure recording is not initializing, clean up any failed file        
        begin
          Process.kill( 9, @_streamer_pid.to_i )
        rescue
        end
        
        if File.exists?( @_video_file )
          begin
            File.delete( @_video_file )
          rescue
          end
        end

        raise RuntimeError.new( "Failed to start recording. Timeout: #{STARTUP_TIMEOUT} second(s). File: \"#{@_video_file}\" " )

      end
    
      @_recording = true
      
      nil
      
    end
        
    # Stops ongoing recording    
    def stop_recording 

      if @_recording      

        @_recording = false            

        Process.kill( 9, @_streamer_pid.to_i )

      end

      nil

    end    
    
    # enable hooking for performance measurement & debug logging
    TDriver::Hooking.hook_methods( self ) if defined?( TDriver::Hooking )

  end #TDriverLinuxCam
    
end # MobyUtil
