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

  # Windows DirectShow webcam implementation
  class TDriverWinCam

    STARTUP_TIMEOUT = 60

    DEFAULT_OPTIONS = { :device => nil, :width => 640, :height => 480, :fps => 30 }
    
    # TODO: document me
    def self.new_cam( *args )

      MobyUtil::TDriverWinCam.new( *args )

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
        
      require 'Win32API'      

      begin     
      
        @_owcc_startex = Win32API.new( 'TDriverWebCamControl', 'OscarWebCamControlStartEx', [ 'P', 'N', 'N', 'N', 'L', 'L', 'L', 'I', 'I'  ], 'L' )
        @_owcc_stop = Win32API.new( 'TDriverWebCamControl', 'OscarWebCamControlStop', [ 'L' ], 'V' )
   
      rescue Exception => e
      
        begin 
            
          #OSCARWEBCAMCONTROL_API long OscarWebCamControlStartEx(char* captureFile, double compQuality, DWORD dwBitsPerSec, long lFramesPerSec, long lCapWidth, long lCapHeight, bool bFlipV, bool bFlipH)
          @_owcc_startex = Win32API.new( 'OscarWebCamControl', 'OscarWebCamControlStartEx', [ 'P', 'N', 'N', 'N', 'L', 'L', 'L', 'I', 'I'  ], 'L' )
          #OSCARWEBCAMCONTROL_API void OscarWebCamControlStop(long pTargetMediaControl)
          @_owcc_stop = Win32API.new( 'OscarWebCamControl', 'OscarWebCamControlStop', [ 'L' ], 'V' )
          
        rescue Exception => ee
          raise RuntimeError.new( "Failed to connect to video recording DLL file (TDriverWebCamControl.dll or OscarWebCamControl.dll). Details:\n" + ee.message )
        end
        
      end

      if user_options.has_key? :device

        puts "WARNING: TDriverWinCam does not support the :device option. This setting is ignored."

      end
  
      @_control_id = nil
      @_video_file = video_file
      @_rec_options = DEFAULT_OPTIONS.merge user_options
          
    end
    
    # Starts recording based on options given during initialization
    # === raises
    # RuntimeError: No filename has been defined or recording initialization failed due to timeout.
    def start_recording

      raise RuntimeError.new("No video file defined, unable to start recording.") if @_video_file.nil?

      if File.exists?( @_video_file )        
        begin
          File.delete( @_video_file )
        rescue
          # no reaction to failed file ops, unless recording fails
        end
      end
    
      @_control_id = @_owcc_startex.call( @_video_file, 0, 0, 0, @_rec_options[ :fps ].to_i, @_rec_options[ :width ].to_i, @_rec_options[ :height ].to_i, 0, 0 )
      
      if @_control_id == 0

        raise RuntimeError.new( "Failed to start video recording.\nFile: " + @_video_file + "\nFPS: " + @_rec_options[ :fps ].to_s + "\nWidth: " + @_rec_options[ :width ].to_s + "\nHeight: " + @_rec_options[ :height ].to_s )

      end

      file_timed_out = false

      file_timeout = Time.now + STARTUP_TIMEOUT

      while File.size?( @_video_file ).nil? && !file_timed_out do

        #wait for recording to start, ie. filesize > 0
        sleep 1

        # force refresh file size
        begin

          if File.exists?( @_video_file ) 
            File.open( @_video_file, 'r' ) do 
            end      
          end

        rescue

        end      
        
        if Time.now > file_timeout
          file_timed_out = true
        end

      end
      
      if file_timed_out

        # make sure recording is not initializing, clean up any failed file        
        begin
          @_owcc_stop.call( @_control_id )
        rescue
        end
        
        if File.exists?( @_video_file )
          begin
            File.delete( @_video_file )
          rescue
          end
        end      

        raise RuntimeError.new( "Failed to start recording. Timeout: #{STARTUP_TIMEOUT} File: \"#{@_video_file}\" " )
      end
      
      @_recording = true
      
      nil
      
    end
        
    # Stops ongoing recording    
    def stop_recording 

      if @_recording      
        @_recording = false            
        @_owcc_stop.call( @_control_id )
      end

      nil

    end

    # enable hooking for performance measurement & debug logging
    TDriver::Hooking.hook_methods( self ) if defined?( TDriver::Hooking )
    
  end #TDriverWinCam
    
end # MobyUtil
