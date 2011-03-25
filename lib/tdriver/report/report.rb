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


require 'fileutils'
require 'date'
require File.expand_path( File.join( File.dirname( __FILE__ ), 'error_recovery/tdriver_error_recovery_settings' ) )
require File.expand_path( File.join( File.dirname( __FILE__ ), 'error_recovery/tdriver_error_recovery' ) )
require File.expand_path( File.join( File.dirname( __FILE__ ), 'error_recovery/tdriver_custom_error_recovery' ) )
require File.expand_path( File.join( File.dirname( __FILE__ ), 'report_file_capture' ) )
require File.expand_path( File.join( File.dirname( __FILE__ ), 'report_crash_file_capture' ) )
require File.expand_path( File.join( File.dirname( __FILE__ ), 'report_javascript' ) )

begin
  #Gem for formatting execution duration time
  require 'chronic_duration'
rescue LoadError
  #Gem not available do nothing
end

require File.expand_path( File.join( File.dirname( __FILE__ ), 'report_writer' ) )
require File.expand_path( File.join( File.dirname( __FILE__ ), 'report_combine' ) )
require File.expand_path( File.join( File.dirname( __FILE__ ), 'report_data_table' ) )
require File.expand_path( File.join( File.dirname( __FILE__ ), 'report_creator' ) )
require File.expand_path( File.join( File.dirname( __FILE__ ), 'report_junit_xml' ) )
require File.expand_path( File.join( File.dirname( __FILE__ ), 'report_api' ) )
require File.expand_path( File.join( File.dirname( __FILE__ ), 'report_test_run' ) )
require File.expand_path( File.join( File.dirname( __FILE__ ), 'report_test_case_run' ) )
require File.expand_path( File.join( File.dirname( __FILE__ ), 'report_cucumber' ) )
require File.expand_path( File.join( File.dirname( __FILE__ ), 'report_cucumber_listener' ) )
require File.expand_path( File.join( File.dirname( __FILE__ ), 'report_cucumber_reporter' ) )
require File.expand_path( File.join( File.dirname( __FILE__ ), 'report_rspec' ) )
require File.expand_path( File.join( File.dirname( __FILE__ ), 'report_test_unit' ) )
require File.expand_path( File.join( File.dirname( __FILE__ ), 'report_grouping' ) )
require File.expand_path( File.join( File.dirname( __FILE__ ), 'report_execution_statistics' ) )
require File.expand_path( File.join( File.dirname( __FILE__ ), 'report_data_presentation' ) )


if MobyUtil::Parameter[ :custom_error_recovery_module, nil ]!=nil

  require MobyUtil::Parameter[ :custom_error_recovery_module ]

end
include TDriverReportAPI



 
