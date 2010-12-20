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

	# Base class and interface for camera recorders in TDriver
	class TDriverCam
	
	    # Automatically select the right kind of camera implementation for the detected platform.
	    def self.new_cam( *args )
		
		  if EnvironmentHelper.windows?
		  
		    return TDriverWinCam.new( *args )
		  
		  elsif EnvironmentHelper.linux?
		  
		    return TDriverLinuxCam.new( *args )
			
		  else
		    raise RuntimeError.new("Unidentified platform type, unable to select platform specific camera. Supported platform types: Linux, Windows.")
		  end
		
		end

		def initialize
		  raise RuntimeError.new("TDriverCam abstract class")
		end
		
		def start_recording
		  raise RuntimeError.new("TDriverCam abstract class")
		end
		
		def stop_recording
		  raise RuntimeError.new("TDriverCam abstract class")
		end

	end # TDriverCam

	# Windows DirectShow webcam implementation
	class TDriverWinCam < TDriverCam

		@_device = nil
		@_video_file = nil
		@_recording = false
		@_rec_options = nil
		@_owcc_startex = nil
		@_owcc_stop = nil
		STARTUP_TIMEOUT = 60
		DEFAULT_OPTIONS = { :device => nil, :width => 640, :height => 480, :fps => 30 }
		
		# Creates a new recroding object witdh the given recording options		
		# === params
		# video_file: String, path and name of file where the recorded video is stored
    # user_options: (optional) Hash, keys :fps, :width, :height can be used to overwrite defaults
		def initialize( video_file, user_options = {} )
		    
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

          raise RuntimeError.new("No video file defined, unable to start recording.") unless !@_video_file.nil?

		  if File.exists?( @_video_file )		    
		    begin
		      File.delete( @_video_file )
			rescue
			  # no reaction to failed file ops, unless recording fails
			end
		  end
		
          @_control_id = @_owcc_startex.call( @_video_file, 0, 0, 0, @_rec_options[ :fps ].to_i, @_rec_options[ :width ].to_i, @_rec_options[ :height ].to_i, 0, 0 )
		  
		  if @_control_id == 0
		    Kernel::raise RuntimeError.new( "Failed to start video recording.\nFile: " + @_video_file + "\nFPS: " + @_rec_options[ :fps ].to_s + "\nWidth: " + @_rec_options[ :width ].to_s + "\nHeight: " + @_rec_options[ :height ].to_s )
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
		  
		  return nil
		  
		end
				
		# Stops ongoing recording		
		def stop_recording 
          if @_recording		  
            @_recording = false						
			@_owcc_stop.call( @_control_id )
		  end
		  return nil
		end		
		
	end #TDriverWinCam
	
	
	# Linux streamer webcam implementation
	# Requires that the streamer application is installed
	class TDriverLinuxCam < TDriverCam

		@_device = nil
		@_video_file = nil
		@_recording = false
		@_rec_options = nil
		@_owcc_startex = nil
		@_owcc_stop = nil
		STARTUP_TIMEOUT = 60
		DEFAULT_OPTIONS = { :device => '/dev/video0', :width => 320, :height => 240, :fps => 5 }
		
		# Creates a new recroding object witdh the given recording options		
		# === params
		# video_file: String, path and name of file where the recorded video is stored
    # user_options: (optional) Hash, keys :fps, :width, :height can be used to overwrite defaults
		def initialize( video_file, user_options = {} )	    
			
		    @_control_id = nil
  		    @_video_file = video_file
		    @_rec_options = DEFAULT_OPTIONS.merge user_options
					
		end
		
		# Starts recording based on options given during initialization
		# === raises
		# RuntimeError: No filename has been defined or recording initialization failed due to timeout.
		def start_recording

          raise RuntimeError.new( "No video file defined, unable to start recording." ) unless !@_video_file.nil?

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
		
            if Time.now > file_timeout
              file_timed_out = true
            end			
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
		  
		  return nil
		  
		end
				
		# Stops ongoing recording		
		def stop_recording 
          if @_recording		  
            @_recording = false						
            Process.kill( 9, @_streamer_pid.to_i )
		  end
		  return nil
		end		
		
	end #TDriverLinuxCam
  
  
  # Checks if the target video contains enough activity to be considered active or static.
  #
	# === params
	# in_target_video: String, Name and path of video file to analyze
  # in_fps: (optional) Numeric, frames to be analyzed per second
  # in_image_treshold: (optional) Numeric, minimum change between two frames for them to be considered different
  # in_video_treshold: (optional) Numeric, Minimum percentage of frames with changes for the video to be considered alive.
  # in_verbose: (optional) Boolean, True for verbose output including target video statistics
  def self.video_alive?( in_target_video, in_fps = 1, in_image_treshold = 4, in_video_treshold = 35, in_verbose = false )
  
    puts "Arguments fps: " << in_fps.inspect << " frame: " << in_image_treshold.inspect << " video: "  << in_video_treshold.inspect if in_verbose
    in_change = in_image_treshold / 100.0
    
    alive_temp_folder = "temp_target_alive"
    
    require 'RMagick'
    
    raise ArgumentError.new( "The FPS argument must be an Interger or a Float, it was a #{ in_fps.class }." ) unless in_fps.kind_of? Numeric
    raise ArgumentError.new( "The frame treshold argument must be an Interger or a Float, it was a #{ in_image_treshold.class }." ) unless in_image_treshold.kind_of? Numeric
    raise ArgumentError.new( "The video treshold argument must be an Interger or a Float, it was a #{ in_video_treshold.class }." ) unless in_video_treshold.kind_of? Numeric
     
    ts = Time.now if in_verbose

    begin
      FileUtils.remove_dir alive_temp_folder
    rescue 
      # failed to remove dir, do nothing
    end
    
    begin
      FileUtils.mkdir_p alive_temp_folder  
    rescue
    
    end
    
    begin
      File.delete 'video_split.log' if File.exist? 'video_split.log'
    rescue
    end
        
    if in_verbose
      system('ffmpeg.exe -v 0 -i '+in_target_video.to_s+' -y -f image2 -r '+in_fps.to_s+' '+alive_temp_folder+'/frame-%05d.png')
    else
      system('ffmpeg.exe 2>video_split.log -v 0 -i '+in_target_video.to_s+' -y -f image2 -r '+in_fps.to_s+' '+alive_temp_folder+'/frame-%05d.png')
    end

    puts "Video processing duration: " << (Time.now - ts).to_s if in_verbose

    t_start = Time.now
    
    im_files = Dir.glob( alive_temp_folder + '/frame-*.png' )

    raise RuntimeError.new( "No video frames found for analysis." ) if im_files.size == 0
    
    d_max = 0.0
    d_min = 1.0

    d_sum = 0.0
    
    dif_count = 0

    pre_obj = Magick::ImageList.new(im_files[0])

    (im_files.size-1).times do | im_index |

      im_file = Magick::ImageList.new(im_files[ im_index ])
      pre_file = pre_obj
       
      dif = pre_file.compare_channel(im_file, Magick::RootMeanSquaredErrorMetric)[1]
       if in_verbose
        d_min = dif unless dif >= d_min
        d_max = dif unless dif <= d_max
        d_sum += dif
      end
      dif_count += 1 if dif > in_change
      puts "Processing image: " << im_file.to_s << " I: " << (im_index+1).to_s  << " C: " << dif.to_s if in_verbose
      
      pre_obj = im_file
           
    end
        
    if in_verbose
      puts "Max difference: " << d_max.to_s << "\nMin difference: " << d_min.to_s << "\n"
      puts "Mean difference: " << (d_sum/im_files.size).to_s unless im_files.size == 0
      puts "Count of images exceeding difference tolerance: " << dif_count.to_s

      puts "Fraction of images exceeding difference tolerance: " << (dif_count.to_f/im_files.size).to_s unless im_files.size == 0
      puts "Analysis duration: " << (Time.now - t_start).to_s
      puts "Total duration: " << (Time.now - ts).to_s
    end

    begin
      FileUtils.remove_dir alive_temp_folder
    rescue 
    end
    
    begin
      File.delete 'video_split.log' if File.exist? 'video_split.log'
    rescue
    end
    
    # Check if enough frames had changes
    return (dif_count.to_f/im_files.size)*100 >= in_video_treshold
      
  end  
  
end
