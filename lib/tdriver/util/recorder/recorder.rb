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
 
# Class for recording scripts from qt applications.
# Complete test script recording not supported. 
# Application must be running when recording is started and 
# must not be closed as a during the recording.

module MobyUtil

  class Recorder

    #TODO detect app start for later versions...
    def self.start_rec( app )

      #raise ArgumentError.new("Application must be defined.") unless app
      app.check_type( MobyBase::TestObject, "Wrong argument type $1 for application object (expected $2)" )

      app.start_recording

    end

    # Prints the recorded events as an tdriver script fragment.
    def self.print_script( sut, app, object_identificators = ['text','icontext','label'] )

      # verify that sut type is type of MobyBase::SUT
      #raise ArgumentError.new("Sut must be defined.") unless sut
      sut.check_type( MobyBase::SUT, "Wrong argument type $1 for SUT (expected $2)" )

      #raise ArgumentError.new("Application must be defined.") unless app
      app.check_type( MobyBase::TestObject, "Wrong argument type $1 for application object (expected $2)" )

      #raise ArgumentError.new("Object identificators must be set, use defaults if not sure what the use.") unless object_identificators
      object_identificators.check_type( Array, "Wrong argument type $1 for object identificators (expected $2)" )
      
      xml_source = app.print_recordings

      app.stop_recording
      
      MobyUtil::Scripter.new( sut.id, object_identificators ).write_fragment( 

        #MobyBase::StateObject.new( :source_data => xml_source ), 
        sut.state_object( xml_source ), 
        app.name 

      )

    end

    # enable hooking for performance measurement & debug logging
    TDriver::Hooking.hook_methods( self ) if defined?( TDriver::Hooking )

  end # Recorder

end # MobyUtil

