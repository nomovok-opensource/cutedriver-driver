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




#require File.expand_path( File.join( File.dirname( __FILE__ ), 'common' ) )
#require File.expand_path( File.join( File.dirname( __FILE__ ), 'logger' ) )
#require File.expand_path( File.join( File.dirname( __FILE__ ), '../../base/lib/base_errors' ) )
#require File.expand_path( File.join( File.dirname( __FILE__ ), '../../base/lib/sut' ) )
#require File.expand_path( File.join( File.dirname( __FILE__ ), '../../base/lib/sut_factory' ) )

module TDriverVerify


  TIMEOUT_CYCLE_SECONDS = 0.1 if !defined?( TIMEOUT_CYCLE_SECONDS )

  # Verifies that the block given to this method evaluates without throwing any exceptions. Verification is synchronized with all connected suts.
  # If this method is called for a sut, synchronization is only done with that sut.
  #
  # === params
  # timeout:: (optional) Integer defining the amount of seconds during which the verification must pass.
  # message:: (optional) A String that is displayed as additional information if the verification fails.
  # === returns
  # nil
  # === raises
  # ArgumentError:: message was not a String or timeout an integer, or no block was given.
  # VerificationError:: The verification failed.

  def verify( timeout = nil, message = nil, &block )
    logging_enabled = MobyUtil::Logger.instance.enabled

    verify_caller = caller(1).first.to_s

    begin

      MobyUtil::Logger.instance.enabled = false
      Kernel::raise ArgumentError.new("No block was given.") unless block_given?
      Kernel::raise ArgumentError.new("Argument timeout was not an Integer.") unless timeout.nil? or timeout.kind_of?(Integer)
      Kernel::raise ArgumentError.new("Argument message was not a String.") unless message.nil? or message.kind_of?(String)

      #Set the testobject timeout to 0 for the duration of the verify call
      original_sync_timeout = MobyBase::TestObjectFactory.instance.timeout
      MobyBase::TestObjectFactory.instance.timeout = 0

      timeout_time = get_end_time(timeout)
      #TIMEOUT_CYCLE_SECONDS

      loop do
        counter = ref_counter
        begin # catch errors thrown in the provided block

          yield
          # no error => verification ok
          break

        rescue Exception => e 
          raise if e.kind_of? MobyBase::ContinuousVerificationError

          source_contents = ""
          error_msg = ""
          if Time.new > timeout_time

            error_msg = "Verification #{message.nil? ? '' : '"' << message.to_s << '" '}at #{verify_caller} failed\n"

            begin
              source_contents = MobyUtil::KernelHelper.find_source(verify_caller)
            rescue Exception
              # failed to load line from file, do nothing
              MobyUtil::Logger.instance.enabled = logging_enabled
              MobyUtil::Logger.instance.log "behaviour" , "WARNING;Failed to load source line: #{e.backtrace.inspect}.;#{self.kind_of?(MobyBase::SUT) ? self.id.to_s + ';sut' : ';'};{};verify;"
            end

            if !source_contents.empty?
              error_msg << source_contents
            end
            error_msg << "\nNested exception:" << e.message << "\n"
            Kernel::raise MobyBase::VerificationError.new(error_msg)

          end

        end

        sleep TIMEOUT_CYCLE_SECONDS

        refresh_suts if counter == ref_counter
      end # do

    rescue Exception => e
      raise if e.kind_of? MobyBase::ContinuousVerificationError
      MobyUtil::Logger.instance.enabled = logging_enabled
      MobyUtil::Logger.instance.log "behaviour" , "FAIL;Verification #{message.nil? ? '' : '\"' << message << '\" '}failed: #{e.to_s}#{timeout.nil? ? '' : ' using timeout ' + timeout.to_s}.;#{self.kind_of?(MobyBase::SUT) ? self.id.to_s + ';sut' : ';'};{};verify;"
      Kernel::raise e
    ensure
      MobyBase::TestObjectFactory.instance.timeout = original_sync_timeout unless original_sync_timeout.nil?
    end

    MobyUtil::Logger.instance.enabled = logging_enabled
    MobyUtil::Logger.instance.log "behaviour" , "PASS;Verification #{message.nil? ? '' : '\"' << message << '\" '}at #{verify_caller} was successful#{timeout.nil? ? '' : ' using timeout ' + timeout.to_s}.;#{self.kind_of?(MobyBase::SUT) ? self.id.to_s + ';sut' : ';'};{};verify;"
    return nil

  end


  # Verifies that the block given to this method throws an exception while being evaluated. Verification is synchronized with all connected suts.
  # If this method is called for a sut, synchronization is only done with that sut.
  #
  # === params
  # timeout:: (optional) Integer defining the amount of seconds during which the verification must pass.
  # message:: (optional) A String that is displayed as additional information if the verification fails.
  # === returns
  # nil
  # === raises
  # ArgumentError:: message was not a String or timeout an integer, or no block was given.
  # VerificationError:: The verification failed.
  def verify_not( timeout = nil, message = nil, &block )

    logging_enabled = MobyUtil::Logger.instance.enabled
    verify_caller = caller(1).first.to_s
    begin

      MobyUtil::Logger.instance.enabled = false
      Kernel::raise ArgumentError.new("No block was given.") unless block_given?
      Kernel::raise ArgumentError.new("Argument timeout was not an Integer.") unless timeout.nil? or timeout.kind_of?(Integer)
      Kernel::raise ArgumentError.new("Argument message was not a String.") unless message.nil? or message.kind_of?(String)

      #Set the testobject timeout to 0 for the duration of the verify call
      original_sync_timeout = MobyBase::TestObjectFactory.instance.timeout
      MobyBase::TestObjectFactory.instance.timeout = 0

      timeout_time = get_end_time(timeout)
      #TIMEOUT_CYCLE_SECONDS

      loop do
        counter = ref_counter
        artificial_exception_raised = false
        begin # catch errors thrown in the provided block

          yield
          artificial_exception_raised = true
          Kernel::raise "test"
        rescue Exception => e
          raise if e.kind_of? MobyBase::ContinuousVerificationError

          source_contents = ""
          error_msg = ""

          if (!artificial_exception_raised)
            # an error was encountered => verification ok
            break
          end

          if Time.new > timeout_time

            error_msg = "Verification #{message.nil? ? '' : '"' << message.to_s << '" '}at #{verify_caller} failed\n"
            source_contents = MobyUtil::KernelHelper.find_source(verify_caller)

            if !source_contents.empty?
              error_msg << source_contents
            end
            Kernel::raise MobyBase::VerificationError.new(error_msg)

          end

          sleep TIMEOUT_CYCLE_SECONDS

          refresh_suts if counter == ref_counter

        end

      end # do


    rescue Exception => e
      raise if e.kind_of? MobyBase::ContinuousVerificationError

      MobyUtil::Logger.instance.enabled = logging_enabled
      MobyUtil::Logger.instance.log "behaviour" , "FAIL;Verification #{message.nil? ? '' : '\"' << message << '\" '}failed: #{e.to_s}#{timeout.nil? ? '' : ' using timeout ' + timeout.to_s}.;#{self.kind_of?(MobyBase::SUT) ? self.id.to_s + ';sut' : ';'};{};verify_not;"
      Kernel::raise e
    ensure
      MobyBase::TestObjectFactory.instance.timeout = original_sync_timeout unless original_sync_timeout.nil?
    end

    MobyUtil::Logger.instance.enabled = logging_enabled
    MobyUtil::Logger.instance.log "behaviour" , "PASS;Verification #{message.nil? ? '' : '\"' << message << '\" '}at #{verify_caller} was successful#{timeout.nil? ? '' : ' using timeout ' + timeout.to_s}.;#{self.kind_of?(MobyBase::SUT) ? self.id.to_s + ';sut' : ';'};{};verify_not;"
    return nil

  end

  # Verifies that the block given to this method evaluates to true. Verification is synchronized with all connected suts.
  # If this method is called for a sut, synchronization is only done with that sut.
  #
  # === params
  # timeout:: (optional) Integer defining the amount of seconds during which the verification must pass.
  # message:: (optional) A String that is displayed as additional information if the verification fails.
  # === returns
  # nil
  # === raises
  # ArgumentError:: message was not a String or timeout an integer, or no block was given.
  # VerificationError:: The verification failed.
  # RuntimeError:: An unexpected error was encountered during verification.
  def verify_true( timeout = nil, message = nil, &block )

    logging_enabled = MobyUtil::Logger.instance.enabled
    verify_caller = caller(1).first.to_s
    begin
      MobyUtil::Logger.instance.enabled = false
      Kernel::raise ArgumentError.new("No block was given.") unless block_given?
      Kernel::raise ArgumentError.new("Argument timeout was not an Integer.") unless timeout.nil? or timeout.kind_of?(Integer)
      Kernel::raise ArgumentError.new("Argument message was not a String.") unless message.nil? or message.kind_of?(String)

      #Set the testobject timeout to 0 for the duration of the verify call
      original_sync_timeout = MobyBase::TestObjectFactory.instance.timeout
      MobyBase::TestObjectFactory.instance.timeout = 0

      timeout_time = get_end_time(timeout)
      #TIMEOUT_CYCLE_SECONDS

      loop do
        counter = ref_counter
        begin # catch errors thrown due to verification results


          begin # catch errors thrown in the provided block
            result = yield
          rescue Exception => e 
            raise if e.kind_of? MobyBase::ContinuousVerificationError
            error_msg = "Verification #{message.nil? ? '' : '"' << message.to_s << '" '}at #{verify_caller} failed as an exception was thrown when the verification block was executed."
            error_msg << MobyUtil::KernelHelper.find_source(verify_caller)
            error_msg << "\nDetails: "
            error_msg << "\n" << e.inspect
            raise MobyBase::VerificationError.new(error_msg)
          end

          error_msg = "Verification #{message.nil? ? '' : '"' << message.to_s << '" '}at #{verify_caller} failed."
          error_msg << MobyUtil::KernelHelper.find_source(verify_caller)
          error_msg << "\nThe block did not return true. It returned: " << result.inspect          
          raise MobyBase::VerificationError.new(error_msg) unless result == true

          # break loop if no exceptions thrown
          break

        rescue MobyBase::VerificationError => ve

          # refresh and retry unless timeout reached

          if Time.new > timeout_time
            Kernel::raise ve
          end

          sleep TIMEOUT_CYCLE_SECONDS

          refresh_suts if counter == ref_counter
        rescue Exception => e
          raise if e.kind_of? MobyBase::ContinuousVerificationError
          MobyUtil::Logger.instance.enabled = logging_enabled
          # an unexpected error has occurred
          Kernel::raise RuntimeError.new("An unexpected error was encountered during verification:\n" << e.inspect )

        end # begin, catch any VerificationErrors

      end # do

    rescue Exception => e
      raise if e.kind_of? MobyBase::ContinuousVerificationError
      MobyUtil::Logger.instance.enabled = logging_enabled
      MobyUtil::Logger.instance.log "behaviour" , "FAIL;Verification #{message.nil? ? '' : '\"' << message << '\" '}failed:#{e.to_s}.\n#{timeout.nil? ? '' : ' using timeout ' + timeout.to_s}.;#{self.kind_of?(MobyBase::SUT) ? self.id.to_s + ';sut' : ';'};{};verify_true;"
      Kernel::raise e
    ensure
      MobyBase::TestObjectFactory.instance.timeout = original_sync_timeout unless original_sync_timeout.nil?
    end

    MobyUtil::Logger.instance.enabled = logging_enabled
    MobyUtil::Logger.instance.log "behaviour" , "PASS;Verification #{message.nil? ? '' : '\"' << message << '\" '}at #{verify_caller} was successful#{timeout.nil? ? '' : ' using timeout ' + timeout.to_s}.;#{self.kind_of?(MobyBase::SUT) ? self.id.to_s + ';sut' : ';'};{};verify_true;"
    return nil

  end

  # Verifies that the block given to this method evaluates to false. Verification is synchronized with all connected suts.
  # If this method is called for a sut, synchronization is only done with that sut.
  #
  # === params
  # timeout:: (optional) Integer defining the amount of seconds during which the verification must pass.
  # message:: (optional) A String that is displayed as additional information if the verification fails.
  # === returns
  # nil
  # === raises
  # ArgumentError:: message was not a String or timeout an integer, or no block was given.
  # VerificationError:: The verification failed.
  # RuntimeError:: An unexpected error was encountered during verification.
  def verify_false( timeout = nil, message = nil, &block )

    logging_enabled = MobyUtil::Logger.instance.enabled
    verify_caller = caller(1).first.to_s
    begin
      MobyUtil::Logger.instance.enabled = false
      Kernel::raise ArgumentError.new("No block was given.") unless block_given?
      Kernel::raise ArgumentError.new("Argument timeout was not an Integer.") unless timeout.nil? or timeout.kind_of?(Integer)
      Kernel::raise ArgumentError.new("Argument message was not a String.") unless message.nil? or message.kind_of?(String)

      #Set the testobject timeout to 0 for the duration of the verify call
      original_sync_timeout = MobyBase::TestObjectFactory.instance.timeout
      MobyBase::TestObjectFactory.instance.timeout = 0

      timeout_time = get_end_time(timeout)
      #TIMEOUT_CYCLE_SECONDS

      loop do
        counter = ref_counter
        begin # catch errors thrown due to verification results

          begin # catch errors thrown in the provided block
            result = yield
          rescue Exception => e
            raise if e.kind_of? MobyBase::ContinuousVerificationError
            error_msg = "Verification #{message.nil? ? '' : '"' << message.to_s << '" '}at #{verify_caller} failed as an exception was thrown when the verification block was executed."
            error_msg << MobyUtil::KernelHelper.find_source(verify_caller)
            error_msg << "\nDetails: "
            error_msg << "\n" << e.inspect
            raise MobyBase::VerificationError.new(error_msg)
          end

          error_msg = "Verification #{message.nil? ? '' : '"' << message.to_s << '" '}at #{verify_caller} failed:"
          error_msg << MobyUtil::KernelHelper.find_source(verify_caller)
          error_msg << "The block did not return false. It returned: " << result.inspect          
          raise MobyBase::VerificationError.new(error_msg) unless result == false

          # break loop if no exceptions thrown
          break

        rescue MobyBase::VerificationError => ve

          # refresh and retry unless timeout reached

          if Time.new > timeout_time
            Kernel::raise ve
          end

          sleep TIMEOUT_CYCLE_SECONDS

          refresh_suts if counter == ref_counter


        rescue Exception => e
          raise if e.kind_of? MobyBase::ContinuousVerificationError
          # an unexpected error has occurred
          MobyUtil::Logger.instance.enabled = logging_enabled
          Kernel::raise RuntimeError.new("An unexpected error was encountered during verification:\n" << e.inspect )

        end # begin, catch any VerificationErrors

      end # do

    rescue Exception => e
      raise if e.kind_of? MobyBase::ContinuousVerificationError
      MobyUtil::Logger.instance.enabled = logging_enabled
      MobyUtil::Logger.instance.log "behaviour" , "FAIL;Verification #{message.nil? ? '' : '\"' << message << '\" '}failed:#{e.to_s}.\n #{timeout.nil? ? '' : ' using timeout ' + timeout.to_s}.;#{self.kind_of?(MobyBase::SUT) ? self.id.to_s + ';sut' : ';'};{};verify_false;"
      Kernel::raise e
    ensure
      MobyBase::TestObjectFactory.instance.timeout = original_sync_timeout unless original_sync_timeout.nil?
    end

    MobyUtil::Logger.instance.enabled = logging_enabled
    MobyUtil::Logger.instance.log "behaviour" , "PASS;Verification #{message.nil? ? '' : '\"' << message << '\" '}at #{verify_caller} was successful#{timeout.nil? ? '' : ' using timeout ' + timeout.to_s}.;#{self.kind_of?(MobyBase::SUT) ? self.id.to_s + ';sut' : ';'};{};verify_false;"
    return nil

  end

  # Verifies that the block given to this method evaluates to the expected value. Verification is synchronized with all connected suts.
  # If this method is called for a sut, synchronization is only done with that sut.
  #
  # === params
  # expected:: Expected result value of the block
  # timeout:: (optional) Integer defining the amount of seconds during which the verification must pass.
  # message:: (optional) A String that is displayed as additional information if the verification fails.
  # === returns
  # nil
  # === raises
  # ArgumentError:: message was not a String or timeout an integer, or no block was given.
  # VerificationError:: The verification failed.
  # RuntimeError:: An unexpected error was encountered during verification.
  def verify_equal( expected, timeout = nil, message = nil, &block )
    logging_enabled = MobyUtil::Logger.instance.enabled
    verify_caller = caller(1).first.to_s
    begin
      MobyUtil::Logger.instance.enabled = false
      Kernel::raise ArgumentError.new("No block was given.") unless block_given?
      Kernel::raise ArgumentError.new("Argument timeout was not an Integer.") unless timeout.nil? or timeout.kind_of?(Integer)
      Kernel::raise ArgumentError.new("Argument message was not a String.") unless message.nil? or message.kind_of?(String)

      #Set the testobject timeout to 0 for the duration of the verify call
      original_sync_timeout = MobyBase::TestObjectFactory.instance.timeout
      MobyBase::TestObjectFactory.instance.timeout = 0

      timeout_time = get_end_time(timeout)

      #TIMEOUT_CYCLE_SECONDS

      loop do
        counter = ref_counter
        begin # catch errors thrown due to verification results

          begin # catch errors thrown in the provided block
            result = yield

          rescue Exception => e
            raise if e.kind_of? MobyBase::ContinuousVerificationError
            error_msg = "Verification #{message.nil? ? '' : '"' << message.to_s << '" '}at #{verify_caller} failed as an exception was thrown when the verification block was executed."
            error_msg << MobyUtil::KernelHelper.find_source(verify_caller)
            error_msg << "\nDetails: "
            error_msg << "\n" << e.inspect
            raise MobyBase::VerificationError.new(error_msg)
          end
          if result != expected
            error_msg = "Verification #{message.nil? ? '' : '"' << message.to_s << '" '}at #{verify_caller} failed:"
            error_msg << MobyUtil::KernelHelper.find_source(verify_caller)
            error_msg << "\nThe block did not return #{expected.inspect}. It returned: " << result.inspect            
            raise MobyBase::VerificationError.new(error_msg)
          end
          # break loop if no exceptions thrown
          break

        rescue MobyBase::VerificationError => ve

          # refresh and retry unless timeout reached

          if Time.new > timeout_time
            Kernel::raise ve
          end

          sleep TIMEOUT_CYCLE_SECONDS

          refresh_suts if counter == ref_counter
        rescue MobyBase::ContinuousVerificationError
          raise
        rescue Exception => e
          raise if e.kind_of? MobyBase::ContinuousVerificationError
          # an unexpected error has occurred
          Kernel::raise RuntimeError.new("An unexpected error was encountered during verification:\n" << e.inspect )

        end # begin, catch any VerificationErrors

      end # do

    rescue Exception => e
      raise if e.kind_of? MobyBase::ContinuousVerificationError

      MobyUtil::Logger.instance.enabled = logging_enabled
      MobyUtil::Logger.instance.log "behaviour" , "FAIL;Verification #{message.nil? ? '' : '\"' << message << '\" '}failed:#{e.to_s}.\n#{timeout.nil? ? '' : ' using timeout ' + timeout.to_s}.;#{self.kind_of?(MobyBase::SUT) ? self.id.to_s + ';sut' : ';'};{};verify_equal;" << expected.to_s
      Kernel::raise e
    ensure
      MobyBase::TestObjectFactory.instance.timeout = original_sync_timeout unless original_sync_timeout.nil?
    end

    MobyUtil::Logger.instance.enabled = logging_enabled
    MobyUtil::Logger.instance.log "behaviour" , "PASS;Verification #{message.nil? ? '' : '\"' << message << '\" '}at #{verify_caller} was successful#{timeout.nil? ? '' : ' using timeout ' + timeout.to_s}.;#{self.kind_of?(MobyBase::SUT) ? self.id.to_s + ';sut' : ';'};{};verify_equal;" << expected.to_s
    return nil

  end

  # Verifies that the given signal is emitted.
  #
  # === params
  # timeout:: Integer, defining the amount of seconds during which the verification must pass.
  # signal_name:: String, name of the signal
  # message:: (optional) A String that is displayed as additional information if the verification fails.
  # === returns
  # nil
  # === raises
  # ArgumentError:: message or signal_name was not a String or timeout a non negative Integer
  # VerificationError:: The verification failed.
  def verify_signal( timeout, signal_name, message = nil )

    logging_enabled = MobyUtil::Logger.instance.enabled
    verify_caller = caller(1).first.to_s

    begin

      MobyUtil::Logger.instance.enabled = false

      Kernel::raise ArgumentError.new("Argument timeout was not a non negative Integer.") unless (timeout.kind_of?(Integer) && timeout >= 0)
      Kernel::raise ArgumentError.new("Argument message was not a non empty String.") unless (message.nil? || (message.kind_of?(String) && !message.empty?))

      # wait for the signal
      begin
        self.wait_for_signal(timeout, signal_name)
      rescue Exception => e
        error_msg = "Verification #{message.nil? ? '' : '"' << message.to_s << '" '}at #{verify_caller} failed:"
        error_msg << MobyUtil::KernelHelper.find_source(verify_caller)
        error_msg << "The signal #{signal_name} was not emitted in #{timeout} seconds."        
        error_msg << "\nNested exception:\n" << e.inspect
        Kernel::raise MobyBase::VerificationError.new(error_msg)
      end

    rescue Exception => e
      MobyUtil::Logger.instance.enabled = logging_enabled
      MobyUtil::Logger.instance.log "behaviour" , "FAIL;Verification #{message.nil? ? '' : '\"' << message << '\" '}failed: #{e.to_s} using timeout '#{timeout}.;#{self.kind_of?(MobyBase::SUT) ? self.id.to_s + ';sut' : ';'};{};verify_signal;#{signal_name}"
      Kernel::raise e
    end

    MobyUtil::Logger.instance.enabled = logging_enabled
    MobyUtil::Logger.instance.log "behaviour" , "PASS;Verification #{message.nil? ? '' : '\"' << message << '\" '}at #{verify_caller} was successful#{timeout.nil? ? '' : ' using timeout ' + timeout.to_s}.;#{self.kind_of?(MobyBase::SUT) ? self.id.to_s + ';sut' : ';'};{};verify_signal;#{signal_name}"
    return nil

  end

  private


  def get_end_time(timeout)

    if self.kind_of?(MobyBase::SUT)
      Time.new + (timeout.nil? ? MobyUtil::Parameter[self.sut][ :synchronization_timeout].to_i : timeout.to_i)
    else
      Time.new + (timeout.nil? ? MobyUtil::Parameter[ :synchronization_timeout].to_i : timeout.to_i)
    end
  end

  # Current count of combined sut refresh calls to all suts
  def ref_counter
    counter = 0
    if self.kind_of? MobyBase::SUT
      counter = self.dump_count
    else
      MobyBase::SUTFactory.instance.connected_suts.each do |sut_id, sut_attributes|
        counter += sut_attributes[:sut].dump_count
      end
    end
    counter
  end

  # Refresh ui state inside verify
  def refresh_suts
    begin
      if self.kind_of? MobyBase::SUT
        appid = self.get_application_id
        if appid != "-1"
          self.refresh({:id => appid})
        else
          self.refresh
        end
      else
        #refresh all connected suts
        MobyBase::SUTFactory.instance.connected_suts.each do |sut_id, sut_attributes|
          appid = sut_attributes[:sut].get_application_id
          if appid != "-1"
            sut_attributes[:sut].refresh({:id => appid}) if sut_attributes[:is_connected]
          else
            sut_attributes[:sut].refresh if sut_attributes[:is_connected]
          end
        end
      end

      # Ignore all availability errors
    rescue RuntimeError => e
      # This occurs when no applications are registered to sut
      if !(e.message =~ /no longer available/)
        # all other errors are passed up
        raise e
      end
    end
  end

end

module MattiVerify
  include TDriverVerify

end
