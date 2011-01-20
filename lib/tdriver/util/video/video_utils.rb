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

  # class VideoUtil ???
   
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
        system('ffmpeg -v 0 -i '+in_target_video.to_s+' -y -f image2 -r '+in_fps.to_s+' '+alive_temp_folder+'/frame-%05d.png')
      else
        system('ffmpeg 2>video_split.log -v 0 -i '+in_target_video.to_s+' -y -f image2 -r '+in_fps.to_s+' '+alive_temp_folder+'/frame-%05d.png')
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

        time_now = Time.now

        puts "Max difference: " << d_max.to_s << "\nMin difference: " << d_min.to_s << "\n"
        puts "Mean difference: " << (d_sum/im_files.size).to_s unless im_files.size == 0
        puts "Count of images exceeding difference tolerance: " << dif_count.to_s

        puts "Fraction of images exceeding difference tolerance: " << (dif_count.to_f/im_files.size).to_s unless im_files.size == 0
        puts "Analysis duration: " << (time_now - t_start).to_s
        puts "Total duration: " << (time_now - ts).to_s
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

    # enable hooking for performance measurement & debug logging
    TDriver::Hooking.hook_methods( self ) if defined?( TDriver::Hooking )

  # end # VideoUtil ???

end
