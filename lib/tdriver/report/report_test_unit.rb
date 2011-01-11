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
#Report module which contains the Test::Unit report formatter
def create_global_reporter_hook_for_test_unit()
   eval("
    module Test #:nodoc:all
      module Unit
        module UI
          module Console
            class TestRunner
              def create_mediator(suite)
                # swap in TDriver custom mediator
                return TDriverReportTestUnit::TestUnit.new(suite)
              end
            end #TestRunner
          end #Console
        end #UI
      end #Unit
    end #Test
      ")
end
module TDriverReportTestUnit
  def create_test_unit_formatter()
    eval "
      require 'test/unit'
      require 'test/unit/ui/console/testrunner'
#class for listening test unit execution process
    class TestUnit < Test::Unit::UI::TestRunnerMediator
      include TDriverReportCreator
        def initialize(suite, report_mgr = nil)
          super(suite)
          @tc_result=nil
          @current_suite_name=suite.name
          @current_test_name=nil
          add_listener(Test::Unit::UI::TestRunnerMediator::STARTED, &method(:started))
          add_listener(Test::Unit::TestCase::STARTED, &method(:test_started))
          add_listener(Test::Unit::TestCase::FINISHED, &method(:test_finished))
          add_listener(Test::Unit::TestResult::FAULT, &method(:fault))
        end
        def get_class_name(full_test_name) #:nodoc:
          begin
            name=full_test_name
            name=name.gsub(/[)]/,'')
            name_arr=name.split('(')
            return [name_arr[1].gsub(/[:]/,'_'),name_arr[0].gsub(/[:]/,'_')]
          rescue
            return ['Ruby test',full_test_name]
          end
        end
        #This method initializes new test run
        #
        # === params
        # === returns
        # === raises
        def started(result)
          start_run()
          add_report_group(@current_suite_name+'|')
        end
        #This method starts a new test case
        #
        # === params
        # === returns
        # === raises
        def test_started(name)
          full_name=get_class_name(name)
          @current_test_name=full_name[1]
          add_report_group(@current_suite_name+':'+full_name[0]+'|')
          start_test_case(@current_test_name)
          add_test_case_group(full_name[0])
          @tc_result='passed'
        end
        #This method records the test case result
        #
        # === params
        # === returns
        # === raises
        def test_finished(name)
          if @tc_result=='passed'
            update_test_case('-')
          end
          end_test_case(@current_test_name,@tc_result)
        end
        #This method records the test case fault result
        #
        # === params
        # === returns
        # === raises
        def fault(fault)
          capture_screen_test_case()
          update_test_case(fault)
          @tc_result='failed'
        end
    end
    "
  end

  def TDriverReportTestUnit.included(mod)

    create_test_unit_formatter()
    create_global_reporter_hook_for_test_unit()

  end

end

module TDriverReport
  def create_test_unit_formatter()
    $stderr.puts "Warning: TDriverReport#create_test_unit_formatter() is deprecated please use only \"include TDriverReportTestUnit\" instead of
    begin
  include TDriverReport
  create_test_unit_formatter()
  end
  module Test #:nodoc:all
    module Unit
      module UI
        module Console
          class TestRunner
            def create_mediator(suite)
              # swap in TDriver custom mediator
              return TDriverReport::TestUnit.new(suite)
            end
          end
        end
      end
    end
  end
    "
    eval "
      require 'test/unit'
      require 'test/unit/ui/console/testrunner'
#class for listening test unit execution process
    class TestUnit < Test::Unit::UI::TestRunnerMediator
      include TDriverReportCreator
        def initialize(suite, report_mgr = nil)
          super(suite)
          @tc_result=nil
          @current_suite_name=suite.name
          @current_test_name=nil
          add_listener(Test::Unit::UI::TestRunnerMediator::STARTED, &method(:started))
          add_listener(Test::Unit::TestCase::STARTED, &method(:test_started))
          add_listener(Test::Unit::TestCase::FINISHED, &method(:test_finished))
          add_listener(Test::Unit::TestResult::FAULT, &method(:fault))
        end
        def get_class_name(full_test_name) #:nodoc:
          begin
            name=full_test_name
            name=name.gsub(/[)]/,'')
            name_arr=name.split('(')
            return [name_arr[1].gsub(/[:]/,'_'),name_arr[0].gsub(/[:]/,'_')]
          rescue
            return ['Ruby test',full_test_name]
          end
        end
        #This method initializes new test run
        #
        # === params
        # === returns
        # === raises
        def started(result)
          start_run()
          add_report_group(@current_suite_name+'|')
        end
        #This method starts a new test case
        #
        # === params
        # === returns
        # === raises
        def test_started(name)
          full_name=get_class_name(name)
          @current_test_name=full_name[1]
          add_report_group(@current_suite_name+':'+full_name[0]+'|')
          start_test_case(@current_test_name)
          add_test_case_group(full_name[0])
          @tc_result='passed'
        end
        #This method records the test case result
        #
        # === params
        # === returns
        # === raises
        def test_finished(name)
          if @tc_result=='passed'
            update_test_case('-')
          end
          end_test_case(@current_test_name,@tc_result)
        end
        #This method records the test case fault result
        #
        # === params
        # === returns
        # === raises
        def fault(fault)
          capture_screen_test_case()
          update_test_case(fault)
          @tc_result='failed'
        end
    end
    "
  end
end




