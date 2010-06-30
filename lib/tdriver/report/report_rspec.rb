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


require File.expand_path( File.join( File.dirname( __FILE__ ), 'report' ) )
begin
require 'spec/runner/formatter/base_text_formatter'
module Spec
    module Runner
      module Formatter
        #Report module which contains the Cucumber, Test::Unit and RSpec report formatters
        module TDriverReport
          #Class for formatting RSpec report
          class RSpecFormatter < BaseTextFormatter
            include TDriverReportCreator
            def initialize(options, output)
              super
              @current_example_group=nil
            end
            #This method is for the undefiened BaseTextFormatter methods
            #
            # === params
            # === returns
            # === raises
            def method_missing(sym, *args)
              # no-op
            end
            #This method initializes new test run
            #
            # === params
            # === returns
            # === raises
            def start(example_count)
              start_run()
            end            
            #This method sets the group
            #
            # === params
            # === returns
            # === raises
            def example_group_started(example)
              @current_example_group=example.description
              add_report_group('Specs:'+@current_example_group+'|')
            end
            #This method starts a new test case
            #
            # === params
            # === returns
            # === raises
            def example_started(example)              
              start_test_case(example.description)
              add_test_case_group(@current_example_group)
            end
            #This method records the passed test case result
            #
            # === params
            # === returns
            # === raises
            def example_passed(example)
             update_test_case('-')
             end_test_case(example.description,'passed')
            end
            #This method records the failed test case result
            #
            # === params
            # === returns
            # === raises
            def example_failed(example, counter, failure)
              capture_screen_test_case()
              update_test_case(failure)
              update_test_case(failure.exception.message) unless failure.exception.message.nil?
              update_test_case("#{format_backtrace(failure.exception.backtrace)}") unless failure.exception.nil?
              end_test_case(example.description,'failed')
            end
            #This method records the not run test case result
            #
            # === params
            # === returns
            # === raises
            def example_pending(example, message, pending_caller)
              update_test_case(message)
              end_test_case(example.description,'not run')
            end
          end
      end
    end
  end
end
rescue LoadError

end

