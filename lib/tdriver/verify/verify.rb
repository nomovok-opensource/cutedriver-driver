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

module TDriverVerify

  TIMEOUT_CYCLE_SECONDS = 0.1 if !defined?( TIMEOUT_CYCLE_SECONDS )

  @@on_error_verify_block = nil

  def on_error_verify_block( &block )

    raise ArgumentError.new( "No verify block given" ) unless block_given?

    @@on_error_verify_block = block

  end

  def reset_on_error_verify_block

    @@on_error_verify_block = nil

  end

  def execute_on_error_verify_block

    unless @@on_error_verify_block.nil?

      begin

        @@on_error_verify_block.call

      rescue Exception

        raise $!.class, "Exception was raised while executing on_error_verify_block. Reason: #{ $!.message.to_s }"

      end

    else

      raise ArgumentError, 'No verify block defined with on_error_verify_block method'

    end

  end

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
  
    begin

      # determine name of caller method
      verify_caller = caller( 1 ).first.to_s

      # store orignal logging state
      logging_enabled = $logger.enabled

      # disable behaviour logging
      $logger.enabled = false

      # ensure that timeout is either nil or type of integer
      timeout.check_type [ Integer, NilClass ], 'wrong argument type $1 for timeout (expected $2)'

      # ensure that message is either nil or type of string
      message.check_type [ String, NilClass ], 'wrong argument type $1 for exception message (expected $2)'

      # verify that block was given
      raise LocalJumpError, 'unable to verify due to no code block was given' unless block_given?

      # convert timeout to integer, nil will be zero
      timeout = get_timeout( timeout )

      # verify that timeout is valid
      timeout.not_negative 'timeout value cannot be negative'

      # calculate the time when timeout exceeds
      timeout_end_time = Time.now + timeout

      # convert message to string, nil will be empty string
      message = message.to_s

      # add double quotation and trailing whitespace if not empty string
      message = "#{ message.inspect } " if message.length > 0

      # store original timeout value
      original_timeout_value = TDriver::TestObjectFactory.timeout

      # set the testobject timeout to 0 for the duration of the verify call
      TDriver::TestObjectFactory.timeout = 0

      loop do
      
        begin
        
          counter = ref_counter

          # execute code block
          yield

          # break loop if no exceptions thrown
          break

        rescue 

          raise if $!.kind_of?( MobyBase::ContinuousVerificationError )

          # refresh and retry unless timeout exceeded
          raise $! if Time.now > timeout_end_time
          
          # retry interval
          sleep TIMEOUT_CYCLE_SECONDS

          # refresh suts
          refresh_suts if counter == ref_counter
        
        end # begin
      
      end # do loop
        
    rescue

      # restore logger state
      $logger.enabled = logging_enabled

      # execute on verification error code block
      execute_on_error_verify_block unless @@on_error_verify_block.nil?

      # process the exception
      if $!.kind_of?( MobyBase::ContinuousVerificationError )
      
        raise
            
      else
      
        error_message = "Verification #{ message }at #{ verify_caller } failed as an exception was thrown when the verification block was executed"
        error_message << "#{ MobyUtil::KernelHelper.find_source( verify_caller ) }\nDetails: \n#{ $!.inspect }"
      
      end

      $logger.behaviour "FAIL;Verification #{ message }failed: #{ $!.to_s }.\n #{ timeout.nil? ? '' : ' using timeout ' + timeout.to_s }.;#{ kind_of?( MobyBase::SUT ) ? id.to_s + ';sut' : ';' };{};verify;"

      # raise the exception
      raise MobyBase::VerificationError, error_message
       
    ensure

      # restore original test object factory timeout value 
      TDriver::TestObjectFactory.timeout = original_timeout_value

      # restore logger state
      $logger.enabled = logging_enabled
    
    end

    $logger.behaviour "PASS;Verification #{ message }at #{ verify_caller } was successful#{ timeout.nil? ? '' : ' using timeout ' + timeout.to_s }.;#{ kind_of?( MobyBase::SUT ) ? id.to_s + ';sut' : ';' };{};verify;"

    nil
  
  end

  def minitest_verify( timeout = nil, message = nil, &block )
    require 'minitest/assertions'
    begin

      # determine name of caller method
      verify_caller = caller( 1 ).first.to_s

      # store orignal logging state
      logging_enabled = $logger.enabled

      # disable behaviour logging
      $logger.enabled = false

      # ensure that timeout is either nil or type of integer
      timeout.check_type [ Integer, NilClass ], 'wrong argument type $1 for timeout (expected $2)'

      # ensure that message is either nil or type of string
      message.check_type [ String, NilClass ], 'wrong argument type $1 for exception message (expected $2)'

      # verify that block was given
      raise LocalJumpError, 'unable to verify due to no code block was given' unless block_given?

      # convert timeout to integer, nil will be zero
      timeout = get_timeout( timeout )

      # verify that timeout is valid
      timeout.not_negative 'timeout value cannot be negative'

      # calculate the time when timeout exceeds
      timeout_end_time = Time.now + timeout

      # convert message to string, nil will be empty string
      message = message.to_s

      # add double quotation and trailing whitespace if not empty string
      message = "#{ message.inspect } " if message.length > 0

      # store original timeout value
      original_timeout_value = TDriver::TestObjectFactory.timeout

      # set the testobject timeout to 0 for the duration of the verify call
      TDriver::TestObjectFactory.timeout = 0

      loop do
      
        begin
        
          counter = ref_counter

          # execute code block
          yield

          # break loop if no exceptions thrown
          break

        rescue 

          raise if $!.kind_of?( MobyBase::ContinuousVerificationError )

          # refresh and retry unless timeout exceeded
          raise $! if Time.now > timeout_end_time
          
          # retry interval
          sleep TIMEOUT_CYCLE_SECONDS

          # refresh suts
          refresh_suts if counter == ref_counter
        
        end # begin
      
      end # do loop
        
    rescue

      # restore logger state
      $logger.enabled = logging_enabled

      # execute on verification error code block
      execute_on_error_verify_block unless @@on_error_verify_block.nil?

      # process the exception
      if $!.kind_of?( MobyBase::ContinuousVerificationError )
      
        raise
            
      else
      
        error_message = "Verification #{ message }at #{ verify_caller } failed as an exception was thrown when the verification block was executed"
        error_message << "#{ MobyUtil::KernelHelper.find_source( verify_caller ) }\nDetails: \n#{ $!.inspect }"
      
      end

      $logger.behaviour "FAIL;Verification #{ message }failed: #{ $!.to_s }.\n #{ timeout.nil? ? '' : ' using timeout ' + timeout.to_s }.;#{ kind_of?( MobyBase::SUT ) ? id.to_s + ';sut' : ';' };{};verify;"

      # raise the exception
      raise Minitest::Assertion, error_message
       
    ensure

      # restore original test object factory timeout value 
      TDriver::TestObjectFactory.timeout = original_timeout_value

      # restore logger state
      $logger.enabled = logging_enabled
    
    end

    $logger.behaviour "PASS;Verification #{ message }at #{ verify_caller } was successful#{ timeout.nil? ? '' : ' using timeout ' + timeout.to_s }.;#{ kind_of?( MobyBase::SUT ) ? id.to_s + ';sut' : ';' };{};verify;"

    nil
  
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
  
    begin

      # determine name of caller method
      verify_caller = caller( 1 ).first.to_s

      # store orignal logging state
      logging_enabled = $logger.enabled

      # disable behaviour logging
      $logger.enabled = false

      # ensure that timeout is either nil or type of integer
      timeout.check_type [ Integer, NilClass ], 'wrong argument type $1 for timeout (expected $2)'

      # ensure that message is either nil or type of string
      message.check_type [ String, NilClass ], 'wrong argument type $1 for exception message (expected $2)'

      # verify that block was given
      raise LocalJumpError, 'unable to verify due to no code block was given' unless block_given?

      # convert timeout to integer, nil will be zero
      timeout = get_timeout( timeout )

      # verify that timeout is valid
      timeout.not_negative 'timeout value cannot be negative'

      # calculate the time when timeout exceeds
      timeout_end_time = Time.now + timeout

      # convert message to string, nil will be empty string
      message = message.to_s

      # add double quotation and trailing whitespace if not empty string
      message = "#{ message.inspect } " if message.length > 0

      # store original timeout value
      original_timeout_value = TDriver::TestObjectFactory.timeout

      # set the testobject timeout to 0 for the duration of the verify call
      TDriver::TestObjectFactory.timeout = 0

      # result container
      result = nil

      loop do
      
        counter = ref_counter

        begin
        
          # execute code block
          result = yield

        rescue

          raise if $!.kind_of?( MobyBase::ContinuousVerificationError )
        
          # break loop if exceptions thrown
          break

        end

        # refresh and retry unless timeout exceeded
        raise $! if Time.now > timeout_end_time
        
        # retry interval
        sleep TIMEOUT_CYCLE_SECONDS

        # refresh suts
        refresh_suts if counter == ref_counter
      
      end # do loop
        
    rescue

      # restore logger state
      $logger.enabled = logging_enabled

      # execute on verification error code block
      execute_on_error_verify_block unless @@on_error_verify_block.nil?

      # process the exception
      if $!.kind_of?( MobyBase::ContinuousVerificationError )
      
        raise
    
      elsif $!.kind_of?( MobyBase::VerificationError )
      
        error_message = "Verification #{ message }at #{ verify_caller } failed: #{ MobyUtil::KernelHelper.find_source( verify_caller ) }"
        error_message << "The block did not raise exception. It returned: #{ result.inspect }"
        
      else
      
        error_message = "Verification #{ message }at #{ verify_caller } failed as an exception was thrown when the verification block was executed"
        error_message << "#{ MobyUtil::KernelHelper.find_source( verify_caller ) }\nDetails: \n#{ $!.inspect }"
      
      end

      $logger.behaviour "FAIL;Verification #{ message }failed: #{ $!.to_s }.\n #{ timeout.nil? ? '' : ' using timeout ' + timeout.to_s }.;#{ kind_of?( MobyBase::SUT ) ? id.to_s + ';sut' : ';' };{};verify_not;"

      # raise the exception
      raise MobyBase::VerificationError, error_message
       
    ensure

      # restore original test object factory timeout value 
      TDriver::TestObjectFactory.timeout = original_timeout_value

      # restore logger state
      $logger.enabled = logging_enabled
    
    end

    $logger.behaviour "PASS;Verification #{ message }at #{ verify_caller } was successful#{ timeout.nil? ? '' : ' using timeout ' + timeout.to_s }.;#{ kind_of?( MobyBase::SUT ) ? id.to_s + ';sut' : ';' };{};verify_not;"

    nil
  
  end

  def minitest_verify_not( timeout = nil, message = nil, &block )
    require 'minitest/assertions'
    begin

      # determine name of caller method
      verify_caller = caller( 1 ).first.to_s

      # store orignal logging state
      logging_enabled = $logger.enabled

      # disable behaviour logging
      $logger.enabled = false

      # ensure that timeout is either nil or type of integer
      timeout.check_type [ Integer, NilClass ], 'wrong argument type $1 for timeout (expected $2)'

      # ensure that message is either nil or type of string
      message.check_type [ String, NilClass ], 'wrong argument type $1 for exception message (expected $2)'

      # verify that block was given
      raise LocalJumpError, 'unable to verify due to no code block was given' unless block_given?

      # convert timeout to integer, nil will be zero
      timeout = get_timeout( timeout )

      # verify that timeout is valid
      timeout.not_negative 'timeout value cannot be negative'

      # calculate the time when timeout exceeds
      timeout_end_time = Time.now + timeout

      # convert message to string, nil will be empty string
      message = message.to_s

      # add double quotation and trailing whitespace if not empty string
      message = "#{ message.inspect } " if message.length > 0

      # store original timeout value
      original_timeout_value = TDriver::TestObjectFactory.timeout

      # set the testobject timeout to 0 for the duration of the verify call
      TDriver::TestObjectFactory.timeout = 0

      # result container
      result = nil

      loop do
      
        counter = ref_counter

        begin
        
          # execute code block
          result = yield

        rescue

          raise if $!.kind_of?( MobyBase::ContinuousVerificationError )
        
          # break loop if exceptions thrown
          break

        end

        # refresh and retry unless timeout exceeded
        raise $! if Time.now > timeout_end_time
        
        # retry interval
        sleep TIMEOUT_CYCLE_SECONDS

        # refresh suts
        refresh_suts if counter == ref_counter
      
      end # do loop
        
    rescue

      # restore logger state
      $logger.enabled = logging_enabled

      # execute on verification error code block
      execute_on_error_verify_block unless @@on_error_verify_block.nil?

      # process the exception
      if $!.kind_of?( MobyBase::ContinuousVerificationError )
      
        raise
    
      elsif $!.kind_of?( MobyBase::VerificationError )
      
        error_message = "Verification #{ message }at #{ verify_caller } failed: #{ MobyUtil::KernelHelper.find_source( verify_caller ) }"
        error_message << "The block did not raise exception. It returned: #{ result.inspect }"
        
      else
      
        error_message = "Verification #{ message }at #{ verify_caller } failed as an exception was thrown when the verification block was executed"
        error_message << "#{ MobyUtil::KernelHelper.find_source( verify_caller ) }\nDetails: \n#{ $!.inspect }"
      
      end

      $logger.behaviour "FAIL;Verification #{ message }failed: #{ $!.to_s }.\n #{ timeout.nil? ? '' : ' using timeout ' + timeout.to_s }.;#{ kind_of?( MobyBase::SUT ) ? id.to_s + ';sut' : ';' };{};verify_not;"

      # raise the exception
      raise Minitest::Assertion, error_message
       
    ensure

      # restore original test object factory timeout value 
      TDriver::TestObjectFactory.timeout = original_timeout_value

      # restore logger state
      $logger.enabled = logging_enabled
    
    end

    $logger.behaviour "PASS;Verification #{ message }at #{ verify_caller } was successful#{ timeout.nil? ? '' : ' using timeout ' + timeout.to_s }.;#{ kind_of?( MobyBase::SUT ) ? id.to_s + ';sut' : ';' };{};verify_not;"

    nil
  
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
  
    begin

      # expected result
      expected_value = true

      # determine name of caller method
      verify_caller = caller( 1 ).first.to_s

      # store orignal logging state
      logging_enabled = $logger.enabled

      # disable behaviour logging
      $logger.enabled = false

      # ensure that timeout is either nil or type of integer
      timeout.check_type [ Integer, NilClass ], 'wrong argument type $1 for timeout (expected $2)'

      # ensure that message is either nil or type of string
      message.check_type [ String, NilClass ], 'wrong argument type $1 for exception message (expected $2)'

      # verify that block was given
      raise LocalJumpError, 'unable to verify due to no code block was given' unless block_given?

      # convert timeout to integer, nil will be zero
      timeout = get_timeout( timeout )

      # verify that timeout is valid
      timeout.not_negative 'timeout value cannot be negative'

      # calculate the time when timeout exceeds
      timeout_end_time = Time.now + timeout

      # convert message to string, nil will be empty string
      message = message.to_s

      # add double quotation and trailing whitespace if not empty string
      message = "#{ message.inspect } " if message.length > 0

      # store original timeout value
      original_timeout_value = TDriver::TestObjectFactory.timeout

      # set the testobject timeout to 0 for the duration of the verify call
      TDriver::TestObjectFactory.timeout = 0

      # result container
      result = nil

      loop do
      
        begin
        
          counter = ref_counter

          # execute code block
          result = yield

          # raise exception if result of yield does not equal with expected value 
          raise MobyBase::VerificationError unless result == expected_value

          # break loop if no exceptions thrown
          break

        rescue 

          raise if $!.kind_of?( MobyBase::ContinuousVerificationError )

          # refresh and retry unless timeout exceeded
          raise $! if Time.now > timeout_end_time
          
          # retry interval
          sleep TIMEOUT_CYCLE_SECONDS

          # refresh suts
          refresh_suts if counter == ref_counter
        
        end # begin
      
      end # do loop
        
    rescue

      # restore logger state
      $logger.enabled = logging_enabled

      # execute on verification error code block
      execute_on_error_verify_block unless @@on_error_verify_block.nil?

      # process the exception
      if $!.kind_of?( MobyBase::ContinuousVerificationError )
      
        raise
    
      elsif $!.kind_of?( MobyBase::VerificationError )
      
        error_message = "Verification #{ message }at #{ verify_caller } failed: #{ MobyUtil::KernelHelper.find_source( verify_caller ) }"
        error_message << "The block did not return #{ expected_value }. It returned: #{ result.inspect }"
        
      else
      
        error_message = "Verification #{ message }at #{ verify_caller } failed as an exception was thrown when the verification block was executed"
        error_message << "#{ MobyUtil::KernelHelper.find_source( verify_caller ) }\nDetails: \n#{ $!.inspect }"
      
      end

      $logger.behaviour "FAIL;Verification #{ message }failed: #{ $!.to_s }.\n #{ timeout.nil? ? '' : ' using timeout ' + timeout.to_s }.;#{ kind_of?( MobyBase::SUT ) ? id.to_s + ';sut' : ';' };{};verify_true;"

      # raise the exception
      raise MobyBase::VerificationError, error_message
       
    ensure

      # restore original test object factory timeout value 
      TDriver::TestObjectFactory.timeout = original_timeout_value

      # restore logger state
      $logger.enabled = logging_enabled
    
    end

    $logger.behaviour "PASS;Verification #{ message }at #{ verify_caller } was successful#{ timeout.nil? ? '' : ' using timeout ' + timeout.to_s }.;#{ kind_of?( MobyBase::SUT ) ? id.to_s + ';sut' : ';' };{};verify_true;"

    nil
  
  end


  def minitest_verify_true( timeout = nil, message = nil, &block )
    require 'minitest/assertions'

    begin

      # expected result
      expected_value = true

      # determine name of caller method
      verify_caller = caller( 1 ).first.to_s

      # store orignal logging state
      logging_enabled = $logger.enabled

      # disable behaviour logging
      $logger.enabled = false

      # ensure that timeout is either nil or type of integer
      timeout.check_type [ Integer, NilClass ], 'wrong argument type $1 for timeout (expected $2)'

      # ensure that message is either nil or type of string
      message.check_type [ String, NilClass ], 'wrong argument type $1 for exception message (expected $2)'

      # verify that block was given
      raise LocalJumpError, 'unable to verify due to no code block was given' unless block_given?

      # convert timeout to integer, nil will be zero
      timeout = get_timeout( timeout )

      # verify that timeout is valid
      timeout.not_negative 'timeout value cannot be negative'

      # calculate the time when timeout exceeds
      timeout_end_time = Time.now + timeout

      # convert message to string, nil will be empty string
      message = message.to_s

      # add double quotation and trailing whitespace if not empty string
      message = "#{ message.inspect } " if message.length > 0

      # store original timeout value
      original_timeout_value = TDriver::TestObjectFactory.timeout

      # set the testobject timeout to 0 for the duration of the verify call
      TDriver::TestObjectFactory.timeout = 0

      # result container
      result = nil

      loop do
      
        begin
        
          counter = ref_counter

          # execute code block
          result = yield

          # raise exception if result of yield does not equal with expected value 
          raise MobyBase::VerificationError unless result == expected_value

          # break loop if no exceptions thrown
          break

        rescue 

          raise if $!.kind_of?( MobyBase::ContinuousVerificationError )

          # refresh and retry unless timeout exceeded
          raise $! if Time.now > timeout_end_time
          
          # retry interval
          sleep TIMEOUT_CYCLE_SECONDS

          # refresh suts
          refresh_suts if counter == ref_counter
        
        end # begin
      
      end # do loop
        
    rescue

      # restore logger state
      $logger.enabled = logging_enabled

      # execute on verification error code block
      execute_on_error_verify_block unless @@on_error_verify_block.nil?

      # process the exception
      if $!.kind_of?( MobyBase::ContinuousVerificationError )
      
        raise
    
      elsif $!.kind_of?( MobyBase::VerificationError )
      
        error_message = "Verification #{ message }at #{ verify_caller } failed: #{ MobyUtil::KernelHelper.find_source( verify_caller ) }"
        error_message << "The block did not return #{ expected_value }. It returned: #{ result.inspect }"
        
      else
      
        error_message = "Verification #{ message }at #{ verify_caller } failed as an exception was thrown when the verification block was executed"
        error_message << "#{ MobyUtil::KernelHelper.find_source( verify_caller ) }\nDetails: \n#{ $!.inspect }"
      
      end

      $logger.behaviour "FAIL;Verification #{ message }failed: #{ $!.to_s }.\n #{ timeout.nil? ? '' : ' using timeout ' + timeout.to_s }.;#{ kind_of?( MobyBase::SUT ) ? id.to_s + ';sut' : ';' };{};verify_true;"

      # raise the exception
      raise Minitest::Assertion, error_message
       
    ensure

      # restore original test object factory timeout value 
      TDriver::TestObjectFactory.timeout = original_timeout_value

      # restore logger state
      $logger.enabled = logging_enabled
    
    end

    $logger.behaviour "PASS;Verification #{ message }at #{ verify_caller } was successful#{ timeout.nil? ? '' : ' using timeout ' + timeout.to_s }.;#{ kind_of?( MobyBase::SUT ) ? id.to_s + ';sut' : ';' };{};verify_true;"

    nil
  
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
  
    begin

      # expected result
      expected_value = false

      # determine name of caller method
      verify_caller = caller( 1 ).first.to_s

      # store orignal logging state
      logging_enabled = $logger.enabled

      # disable behaviour logging
      $logger.enabled = false

      # ensure that timeout is either nil or type of integer
      timeout.check_type [ Integer, NilClass ], 'wrong argument type $1 for timeout (expected $2)'

      # ensure that message is either nil or type of string
      message.check_type [ String, NilClass ], 'wrong argument type $1 for exception message (expected $2)'

      # verify that block was given
      raise LocalJumpError, 'unable to verify due to no code block was given' unless block_given?

      # convert timeout to integer, nil will be zero
      timeout = get_timeout( timeout )

      # verify that timeout is valid
      timeout.not_negative 'timeout value cannot be negative'

      # calculate the time when timeout exceeds
      timeout_end_time = Time.now + timeout

      # convert message to string, nil will be empty string
      message = message.to_s

      # add double quotation and trailing whitespace if not empty string
      message = "#{ message.inspect } " if message.length > 0

      # store original timeout value
      original_timeout_value = TDriver::TestObjectFactory.timeout

      # set the testobject timeout to 0 for the duration of the verify call
      TDriver::TestObjectFactory.timeout = 0

      # result container
      result = nil

      loop do
      
        begin
        
          counter = ref_counter

          # execute code block
          result = yield

          # raise exception if result of yield does not equal with expected value 
          raise MobyBase::VerificationError unless result == expected_value

          # break loop if no exceptions thrown
          break

        rescue 

          raise if $!.kind_of?( MobyBase::ContinuousVerificationError )

          # refresh and retry unless timeout exceeded
          raise $! if Time.now > timeout_end_time
          
          # retry interval
          sleep TIMEOUT_CYCLE_SECONDS

          # refresh suts
          refresh_suts if counter == ref_counter
        
        end # begin
      
      end # do loop
        
    rescue

      # restore logger state
      $logger.enabled = logging_enabled

      # execute on verification error code block
      execute_on_error_verify_block unless @@on_error_verify_block.nil?

      # process the exception
      if $!.kind_of?( MobyBase::ContinuousVerificationError )
      
        raise
    
      elsif $!.kind_of?( MobyBase::VerificationError )
      
        error_message = "Verification #{ message }at #{ verify_caller } failed: #{ MobyUtil::KernelHelper.find_source( verify_caller ) }"
        error_message << "The block did not return #{ expected_value }. It returned: #{ result.inspect }"
        
      else
      
        error_message = "Verification #{ message }at #{ verify_caller } failed as an exception was thrown when the verification block was executed"
        error_message << "#{ MobyUtil::KernelHelper.find_source( verify_caller ) }\nDetails: \n#{ $!.inspect }"
      
      end

      $logger.behaviour "FAIL;Verification #{ message }failed: #{ $!.to_s }.\n #{ timeout.nil? ? '' : ' using timeout ' + timeout.to_s }.;#{ kind_of?( MobyBase::SUT ) ? id.to_s + ';sut' : ';' };{};verify_false;"

      # raise the exception
      raise MobyBase::VerificationError, error_message
       
    ensure

      # restore original test object factory timeout value 
      TDriver::TestObjectFactory.timeout = original_timeout_value

      # restore logger state
      $logger.enabled = logging_enabled
    
    end

    $logger.behaviour "PASS;Verification #{ message }at #{ verify_caller } was successful#{ timeout.nil? ? '' : ' using timeout ' + timeout.to_s }.;#{ kind_of?( MobyBase::SUT ) ? id.to_s + ';sut' : ';' };{};verify_false;"

    nil
  
  end

  def minitest_verify_false( timeout = nil, message = nil, &block )
    require 'minitest/assertions'
    
    begin

      # expected result
      expected_value = false

      # determine name of caller method
      verify_caller = caller( 1 ).first.to_s

      # store orignal logging state
      logging_enabled = $logger.enabled

      # disable behaviour logging
      $logger.enabled = false

      # ensure that timeout is either nil or type of integer
      timeout.check_type [ Integer, NilClass ], 'wrong argument type $1 for timeout (expected $2)'

      # ensure that message is either nil or type of string
      message.check_type [ String, NilClass ], 'wrong argument type $1 for exception message (expected $2)'

      # verify that block was given
      raise LocalJumpError, 'unable to verify due to no code block was given' unless block_given?

      # convert timeout to integer, nil will be zero
      timeout = get_timeout( timeout )

      # verify that timeout is valid
      timeout.not_negative 'timeout value cannot be negative'

      # calculate the time when timeout exceeds
      timeout_end_time = Time.now + timeout

      # convert message to string, nil will be empty string
      message = message.to_s

      # add double quotation and trailing whitespace if not empty string
      message = "#{ message.inspect } " if message.length > 0

      # store original timeout value
      original_timeout_value = TDriver::TestObjectFactory.timeout

      # set the testobject timeout to 0 for the duration of the verify call
      TDriver::TestObjectFactory.timeout = 0

      # result container
      result = nil

      loop do
      
        begin
        
          counter = ref_counter

          # execute code block
          result = yield

          # raise exception if result of yield does not equal with expected value 
          raise MobyBase::VerificationError unless result == expected_value

          # break loop if no exceptions thrown
          break

        rescue 

          raise if $!.kind_of?( MobyBase::ContinuousVerificationError )

          # refresh and retry unless timeout exceeded
          raise $! if Time.now > timeout_end_time
          
          # retry interval
          sleep TIMEOUT_CYCLE_SECONDS

          # refresh suts
          refresh_suts if counter == ref_counter
        
        end # begin
      
      end # do loop
        
    rescue

      # restore logger state
      $logger.enabled = logging_enabled

      # execute on verification error code block
      execute_on_error_verify_block unless @@on_error_verify_block.nil?

      # process the exception
      if $!.kind_of?( MobyBase::ContinuousVerificationError )
      
        raise
    
      elsif $!.kind_of?( MobyBase::VerificationError )
      
        error_message = "Verification #{ message }at #{ verify_caller } failed: #{ MobyUtil::KernelHelper.find_source( verify_caller ) }"
        error_message << "The block did not return #{ expected_value }. It returned: #{ result.inspect }"
        
      else
      
        error_message = "Verification #{ message }at #{ verify_caller } failed as an exception was thrown when the verification block was executed"
        error_message << "#{ MobyUtil::KernelHelper.find_source( verify_caller ) }\nDetails: \n#{ $!.inspect }"
      
      end

      $logger.behaviour "FAIL;Verification #{ message }failed: #{ $!.to_s }.\n #{ timeout.nil? ? '' : ' using timeout ' + timeout.to_s }.;#{ kind_of?( MobyBase::SUT ) ? id.to_s + ';sut' : ';' };{};verify_false;"

      # raise the exception
      raise Minitest::Assertion, error_message
       
    ensure

      # restore original test object factory timeout value 
      TDriver::TestObjectFactory.timeout = original_timeout_value

      # restore logger state
      $logger.enabled = logging_enabled
    
    end

    $logger.behaviour "PASS;Verification #{ message }at #{ verify_caller } was successful#{ timeout.nil? ? '' : ' using timeout ' + timeout.to_s }.;#{ kind_of?( MobyBase::SUT ) ? id.to_s + ';sut' : ';' };{};verify_false;"

    nil
  
  end





  # Verifies that result of given block equals to expected value. Verification is synchronized with all connected suts.
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
  def verify_equal( expected_value, timeout = nil, message = nil, &block )
  
    begin

      # determine name of caller method
      verify_caller = caller( 1 ).first.to_s

      # store orignal logging state
      logging_enabled = $logger.enabled

      # disable behaviour logging
      $logger.enabled = false

      # ensure that timeout is either nil or type of integer
      timeout.check_type [ Integer, NilClass ], 'wrong argument type $1 for timeout (expected $2)'

      # ensure that message is either nil or type of string
      message.check_type [ String, NilClass ], 'wrong argument type $1 for exception message (expected $2)'

      # verify that block was given
      raise LocalJumpError, 'unable to verify due to no code block was given' unless block_given?

      # convert timeout to integer, nil will be zero
      timeout = get_timeout( timeout )

      # verify that timeout is valid
      timeout.not_negative 'timeout value cannot be negative'

      # calculate the time when timeout exceeds
      timeout_end_time = Time.now + timeout

      # convert message to string, nil will be empty string
      message = message.to_s

      # add double quotation and trailing whitespace if not empty string
      message = "#{ message.inspect } " if message.length > 0

      # store original timeout value
      original_timeout_value = TDriver::TestObjectFactory.timeout

      # set the testobject timeout to 0 for the duration of the verify call
      TDriver::TestObjectFactory.timeout = 0

      # result container
      result = nil

      loop do
      
        begin
        
          counter = ref_counter

          # execute code block
          result = yield

          # raise exception if result of yield does not equal with expected value 
          raise MobyBase::VerificationError unless result == expected_value

          # break loop if no exceptions thrown
          break

        rescue 

          raise if $!.kind_of?( MobyBase::ContinuousVerificationError )

          # refresh and retry unless timeout exceeded
          raise $! if Time.now > timeout_end_time
          
          # retry interval
          sleep TIMEOUT_CYCLE_SECONDS

          # refresh suts
          refresh_suts if counter == ref_counter
        
        end # begin
      
      end # do loop
        
    rescue

      # restore logger state
      $logger.enabled = logging_enabled

      # execute on verification error code block
      execute_on_error_verify_block unless @@on_error_verify_block.nil?

      # process the exception
      if $!.kind_of?( MobyBase::ContinuousVerificationError )
      
        raise
    
      elsif $!.kind_of?( MobyBase::VerificationError )
      
        error_message = "Verification #{ message }at #{ verify_caller } failed: #{ MobyUtil::KernelHelper.find_source( verify_caller ) }"
        error_message << "The value was not equal to #{ expected_value }. It returned: #{ result.inspect }"
        
      else
      
        error_message = "Verification #{ message }at #{ verify_caller } failed as an exception was thrown when the verification block was executed"
        error_message << "#{ MobyUtil::KernelHelper.find_source( verify_caller ) }\nDetails: \n#{ $!.inspect }"
      
      end

      $logger.behaviour "FAIL;Verification #{ message }failed: #{ $!.to_s }.\n #{ timeout.nil? ? '' : ' using timeout ' + timeout.to_s }.;#{ kind_of?( MobyBase::SUT ) ? id.to_s + ';sut' : ';' };{};verify_equal;"

      # raise the exception
      raise MobyBase::VerificationError, error_message
       
    ensure

      # restore original test object factory timeout value 
      TDriver::TestObjectFactory.timeout = original_timeout_value

      # restore logger state
      $logger.enabled = logging_enabled
    
    end

    $logger.behaviour "PASS;Verification #{ message }at #{ verify_caller } was successful#{ timeout.nil? ? '' : ' using timeout ' + timeout.to_s }.;#{ kind_of?( MobyBase::SUT ) ? id.to_s + ';sut' : ';' };{};verify_equal;"

    nil
  
  end


  def minitest_verify_equal( expected_value, timeout = nil, message = nil, &block )
    require 'minitest/assertions'
    begin

      # determine name of caller method
      verify_caller = caller( 1 ).first.to_s

      # store orignal logging state
      logging_enabled = $logger.enabled

      # disable behaviour logging
      $logger.enabled = false

      # ensure that timeout is either nil or type of integer
      timeout.check_type [ Integer, NilClass ], 'wrong argument type $1 for timeout (expected $2)'

      # ensure that message is either nil or type of string
      message.check_type [ String, NilClass ], 'wrong argument type $1 for exception message (expected $2)'

      # verify that block was given
      raise LocalJumpError, 'unable to verify due to no code block was given' unless block_given?

      # convert timeout to integer, nil will be zero
      timeout = get_timeout( timeout )

      # verify that timeout is valid
      timeout.not_negative 'timeout value cannot be negative'

      # calculate the time when timeout exceeds
      timeout_end_time = Time.now + timeout

      # convert message to string, nil will be empty string
      message = message.to_s

      # add double quotation and trailing whitespace if not empty string
      message = "#{ message.inspect } " if message.length > 0

      # store original timeout value
      original_timeout_value = TDriver::TestObjectFactory.timeout

      # set the testobject timeout to 0 for the duration of the verify call
      TDriver::TestObjectFactory.timeout = 0

      # result container
      result = nil

      loop do
      
        begin
        
          counter = ref_counter

          # execute code block
          result = yield

          # raise exception if result of yield does not equal with expected value 
          raise MobyBase::VerificationError unless result == expected_value

          # break loop if no exceptions thrown
          break

        rescue 

          raise if $!.kind_of?( MobyBase::ContinuousVerificationError )

          # refresh and retry unless timeout exceeded
          raise $! if Time.now > timeout_end_time
          
          # retry interval
          sleep TIMEOUT_CYCLE_SECONDS

          # refresh suts
          refresh_suts if counter == ref_counter
        
        end # begin
      
      end # do loop
        
    rescue

      # restore logger state
      $logger.enabled = logging_enabled

      # execute on verification error code block
      execute_on_error_verify_block unless @@on_error_verify_block.nil?

      # process the exception
      if $!.kind_of?( MobyBase::ContinuousVerificationError )
      
        raise
    
      elsif $!.kind_of?( MobyBase::VerificationError )
      
        error_message = "Verification #{ message }at #{ verify_caller } failed: #{ MobyUtil::KernelHelper.find_source( verify_caller ) }"
        error_message << "The value was not equal to #{ expected_value }. It returned: #{ result.inspect }"
        
      else
      
        error_message = "Verification #{ message }at #{ verify_caller } failed as an exception was thrown when the verification block was executed"
        error_message << "#{ MobyUtil::KernelHelper.find_source( verify_caller ) }\nDetails: \n#{ $!.inspect }"
      
      end

      $logger.behaviour "FAIL;Verification #{ message }failed: #{ $!.to_s }.\n #{ timeout.nil? ? '' : ' using timeout ' + timeout.to_s }.;#{ kind_of?( MobyBase::SUT ) ? id.to_s + ';sut' : ';' };{};verify_equal;"

      # raise the exception
      raise Minitest::Assertion, error_message
       
    ensure

      # restore original test object factory timeout value 
      TDriver::TestObjectFactory.timeout = original_timeout_value

      # restore logger state
      $logger.enabled = logging_enabled
    
    end

    $logger.behaviour "PASS;Verification #{ message }at #{ verify_caller } was successful#{ timeout.nil? ? '' : ' using timeout ' + timeout.to_s }.;#{ kind_of?( MobyBase::SUT ) ? id.to_s + ';sut' : ';' };{};verify_equal;"

    nil
  
  end


  # Verifies that result of the given block is less than expected value. Verification is synchronized with all connected suts.
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
  def verify_less( expected_value, timeout = nil, message = nil, &block )
  
    begin

      # determine name of caller method
      verify_caller = caller( 1 ).first.to_s

      # store orignal logging state
      logging_enabled = $logger.enabled

      # disable behaviour logging
      $logger.enabled = false

      # ensure that timeout is either nil or type of integer
      timeout.check_type [ Integer, NilClass ], 'wrong argument type $1 for timeout (expected $2)'

      # ensure that message is either nil or type of string
      message.check_type [ String, NilClass ], 'wrong argument type $1 for exception message (expected $2)'

      # verify that block was given
      raise LocalJumpError, 'unable to verify due to no code block was given' unless block_given?

      # convert timeout to integer, nil will be zero
      timeout = get_timeout( timeout )

      # verify that timeout is valid
      timeout.not_negative 'timeout value cannot be negative'

      # calculate the time when timeout exceeds
      timeout_end_time = Time.now + timeout

      # convert message to string, nil will be empty string
      message = message.to_s

      # add double quotation and trailing whitespace if not empty string
      message = "#{ message.inspect } " if message.length > 0

      # store original timeout value
      original_timeout_value = TDriver::TestObjectFactory.timeout

      # set the testobject timeout to 0 for the duration of the verify call
      TDriver::TestObjectFactory.timeout = 0

      # result container
      result = nil

      loop do
      
        begin
        
          counter = ref_counter

          # execute code block
          result = yield

          # raise exception if result of yield is less than expected value 
          raise MobyBase::VerificationError unless result < expected_value

          # break loop if no exceptions thrown
          break

        rescue 

          raise if $!.kind_of?( MobyBase::ContinuousVerificationError )

          # refresh and retry unless timeout exceeded
          raise $! if Time.now > timeout_end_time
          
          # retry interval
          sleep TIMEOUT_CYCLE_SECONDS

          # refresh suts
          refresh_suts if counter == ref_counter
        
        end # begin
      
      end # do loop
        
    rescue

      # restore logger state
      $logger.enabled = logging_enabled

      # execute on verification error code block
      execute_on_error_verify_block unless @@on_error_verify_block.nil?

      # process the exception
      if $!.kind_of?( MobyBase::ContinuousVerificationError )
      
        raise
    
      elsif $!.kind_of?( MobyBase::VerificationError )
      
        error_message = "Verification #{ message }at #{ verify_caller } failed: #{ MobyUtil::KernelHelper.find_source( verify_caller ) }"
        error_message << "The value was not less than #{ expected_value }. It returned: #{ result.inspect }"
        
      else
      
        error_message = "Verification #{ message }at #{ verify_caller } failed as an exception was thrown when the verification block was executed"
        error_message << "#{ MobyUtil::KernelHelper.find_source( verify_caller ) }\nDetails: \n#{ $!.inspect }"
      
      end

      $logger.behaviour "FAIL;Verification #{ message }failed: #{ $!.to_s }.\n #{ timeout.nil? ? '' : ' using timeout ' + timeout.to_s }.;#{ kind_of?( MobyBase::SUT ) ? id.to_s + ';sut' : ';' };{};verify_less;"

      # raise the exception
      raise MobyBase::VerificationError, error_message
       
    ensure

      # restore original test object factory timeout value 
      TDriver::TestObjectFactory.timeout = original_timeout_value

      # restore logger state
      $logger.enabled = logging_enabled
    
    end

    $logger.behaviour "PASS;Verification #{ message }at #{ verify_caller } was successful#{ timeout.nil? ? '' : ' using timeout ' + timeout.to_s }.;#{ kind_of?( MobyBase::SUT ) ? id.to_s + ';sut' : ';' };{};verify_less;"

    nil
  
  end

  def minitest_verify_less( expected_value, timeout = nil, message = nil, &block )
    require 'minitest/assertions'
    begin

      # determine name of caller method
      verify_caller = caller( 1 ).first.to_s

      # store orignal logging state
      logging_enabled = $logger.enabled

      # disable behaviour logging
      $logger.enabled = false

      # ensure that timeout is either nil or type of integer
      timeout.check_type [ Integer, NilClass ], 'wrong argument type $1 for timeout (expected $2)'

      # ensure that message is either nil or type of string
      message.check_type [ String, NilClass ], 'wrong argument type $1 for exception message (expected $2)'

      # verify that block was given
      raise LocalJumpError, 'unable to verify due to no code block was given' unless block_given?

      # convert timeout to integer, nil will be zero
      timeout = get_timeout( timeout )

      # verify that timeout is valid
      timeout.not_negative 'timeout value cannot be negative'

      # calculate the time when timeout exceeds
      timeout_end_time = Time.now + timeout

      # convert message to string, nil will be empty string
      message = message.to_s

      # add double quotation and trailing whitespace if not empty string
      message = "#{ message.inspect } " if message.length > 0

      # store original timeout value
      original_timeout_value = TDriver::TestObjectFactory.timeout

      # set the testobject timeout to 0 for the duration of the verify call
      TDriver::TestObjectFactory.timeout = 0

      # result container
      result = nil

      loop do
      
        begin
        
          counter = ref_counter

          # execute code block
          result = yield

          # raise exception if result of yield is less than expected value 
          raise MobyBase::VerificationError unless result < expected_value

          # break loop if no exceptions thrown
          break

        rescue 

          raise if $!.kind_of?( MobyBase::ContinuousVerificationError )

          # refresh and retry unless timeout exceeded
          raise $! if Time.now > timeout_end_time
          
          # retry interval
          sleep TIMEOUT_CYCLE_SECONDS

          # refresh suts
          refresh_suts if counter == ref_counter
        
        end # begin
      
      end # do loop
        
    rescue

      # restore logger state
      $logger.enabled = logging_enabled

      # execute on verification error code block
      execute_on_error_verify_block unless @@on_error_verify_block.nil?

      # process the exception
      if $!.kind_of?( MobyBase::ContinuousVerificationError )
      
        raise
    
      elsif $!.kind_of?( MobyBase::VerificationError )
      
        error_message = "Verification #{ message }at #{ verify_caller } failed: #{ MobyUtil::KernelHelper.find_source( verify_caller ) }"
        error_message << "The value was not less than #{ expected_value }. It returned: #{ result.inspect }"
        
      else
      
        error_message = "Verification #{ message }at #{ verify_caller } failed as an exception was thrown when the verification block was executed"
        error_message << "#{ MobyUtil::KernelHelper.find_source( verify_caller ) }\nDetails: \n#{ $!.inspect }"
      
      end

      $logger.behaviour "FAIL;Verification #{ message }failed: #{ $!.to_s }.\n #{ timeout.nil? ? '' : ' using timeout ' + timeout.to_s }.;#{ kind_of?( MobyBase::SUT ) ? id.to_s + ';sut' : ';' };{};verify_less;"

      # raise the exception
      raise Minitest::Assertion, error_message
       
    ensure

      # restore original test object factory timeout value 
      TDriver::TestObjectFactory.timeout = original_timeout_value

      # restore logger state
      $logger.enabled = logging_enabled
    
    end

    $logger.behaviour "PASS;Verification #{ message }at #{ verify_caller } was successful#{ timeout.nil? ? '' : ' using timeout ' + timeout.to_s }.;#{ kind_of?( MobyBase::SUT ) ? id.to_s + ';sut' : ';' };{};verify_less;"

    nil
  
  end



  # Verifies that result of the given block is greater than expected value. Verification is synchronized with all connected suts.
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
  def verify_greater( expected_value, timeout = nil, message = nil, &block )
  
    begin

      # determine name of caller method
      verify_caller = caller( 1 ).first.to_s

      # store orignal logging state
      logging_enabled = $logger.enabled

      # disable behaviour logging
      $logger.enabled = false

      # ensure that timeout is either nil or type of integer
      timeout.check_type [ Integer, NilClass ], 'wrong argument type $1 for timeout (expected $2)'

      # ensure that message is either nil or type of string
      message.check_type [ String, NilClass ], 'wrong argument type $1 for exception message (expected $2)'

      # verify that block was given
      raise LocalJumpError, 'unable to verify due to no code block was given' unless block_given?

      # convert timeout to integer, nil will be zero
      timeout = get_timeout( timeout )

      # verify that timeout is valid
      timeout.not_negative 'timeout value cannot be negative'

      # calculate the time when timeout exceeds
      timeout_end_time = Time.now + timeout

      # convert message to string, nil will be empty string
      message = message.to_s

      # add double quotation and trailing whitespace if not empty string
      message = "#{ message.inspect } " if message.length > 0

      # store original timeout value
      original_timeout_value = TDriver::TestObjectFactory.timeout

      # set the testobject timeout to 0 for the duration of the verify call
      TDriver::TestObjectFactory.timeout = 0

      # result container
      result = nil

      loop do
      
        begin
        
          counter = ref_counter

          # execute code block
          result = yield

          # raise exception if result of yield is greater than expected value 
          raise MobyBase::VerificationError unless result > expected_value

          # break loop if no exceptions thrown
          break

        rescue 

          raise if $!.kind_of?( MobyBase::ContinuousVerificationError )

          # refresh and retry unless timeout exceeded
          raise $! if Time.now > timeout_end_time
          
          # retry interval
          sleep TIMEOUT_CYCLE_SECONDS

          # refresh suts
          refresh_suts if counter == ref_counter
        
        end # begin
      
      end # do loop
        
    rescue

      # restore logger state
      $logger.enabled = logging_enabled

      # execute on verification error code block
      execute_on_error_verify_block unless @@on_error_verify_block.nil?

      # process the exception
      if $!.kind_of?( MobyBase::ContinuousVerificationError )
      
        raise
    
      elsif $!.kind_of?( MobyBase::VerificationError )
      
        error_message = "Verification #{ message }at #{ verify_caller } failed: #{ MobyUtil::KernelHelper.find_source( verify_caller ) }"
        error_message << "The value vas not greater than #{ expected_value }. It returned: #{ result.inspect }"
        
      else
      
        error_message = "Verification #{ message }at #{ verify_caller } failed as an exception was thrown when the verification block was executed"
        error_message << "#{ MobyUtil::KernelHelper.find_source( verify_caller ) }\nDetails: \n#{ $!.inspect }"
      
      end

      $logger.behaviour "FAIL;Verification #{ message }failed: #{ $!.to_s }.\n #{ timeout.nil? ? '' : ' using timeout ' + timeout.to_s }.;#{ kind_of?( MobyBase::SUT ) ? id.to_s + ';sut' : ';' };{};verify_greater;"

      # raise the exception
      raise MobyBase::VerificationError, error_message
       
    ensure

      # restore original test object factory timeout value 
      TDriver::TestObjectFactory.timeout = original_timeout_value

      # restore logger state
      $logger.enabled = logging_enabled
    
    end

    $logger.behaviour "PASS;Verification #{ message }at #{ verify_caller } was successful#{ timeout.nil? ? '' : ' using timeout ' + timeout.to_s }.;#{ kind_of?( MobyBase::SUT ) ? id.to_s + ';sut' : ';' };{};verify_greater;"

    nil
  
  end

  def minitest_verify_greater( expected_value, timeout = nil, message = nil, &block )
    require 'minitest/assertions'
    begin

      # determine name of caller method
      verify_caller = caller( 1 ).first.to_s

      # store orignal logging state
      logging_enabled = $logger.enabled

      # disable behaviour logging
      $logger.enabled = false

      # ensure that timeout is either nil or type of integer
      timeout.check_type [ Integer, NilClass ], 'wrong argument type $1 for timeout (expected $2)'

      # ensure that message is either nil or type of string
      message.check_type [ String, NilClass ], 'wrong argument type $1 for exception message (expected $2)'

      # verify that block was given
      raise LocalJumpError, 'unable to verify due to no code block was given' unless block_given?

      # convert timeout to integer, nil will be zero
      timeout = get_timeout( timeout )

      # verify that timeout is valid
      timeout.not_negative 'timeout value cannot be negative'

      # calculate the time when timeout exceeds
      timeout_end_time = Time.now + timeout

      # convert message to string, nil will be empty string
      message = message.to_s

      # add double quotation and trailing whitespace if not empty string
      message = "#{ message.inspect } " if message.length > 0

      # store original timeout value
      original_timeout_value = TDriver::TestObjectFactory.timeout

      # set the testobject timeout to 0 for the duration of the verify call
      TDriver::TestObjectFactory.timeout = 0

      # result container
      result = nil

      loop do
      
        begin
        
          counter = ref_counter

          # execute code block
          result = yield

          # raise exception if result of yield is greater than expected value 
          raise MobyBase::VerificationError unless result > expected_value

          # break loop if no exceptions thrown
          break

        rescue 

          raise if $!.kind_of?( MobyBase::ContinuousVerificationError )

          # refresh and retry unless timeout exceeded
          raise $! if Time.now > timeout_end_time
          
          # retry interval
          sleep TIMEOUT_CYCLE_SECONDS

          # refresh suts
          refresh_suts if counter == ref_counter
        
        end # begin
      
      end # do loop
        
    rescue

      # restore logger state
      $logger.enabled = logging_enabled

      # execute on verification error code block
      execute_on_error_verify_block unless @@on_error_verify_block.nil?

      # process the exception
      if $!.kind_of?( MobyBase::ContinuousVerificationError )
      
        raise
    
      elsif $!.kind_of?( MobyBase::VerificationError )
      
        error_message = "Verification #{ message }at #{ verify_caller } failed: #{ MobyUtil::KernelHelper.find_source( verify_caller ) }"
        error_message << "The value vas not greater than #{ expected_value }. It returned: #{ result.inspect }"
        
      else
      
        error_message = "Verification #{ message }at #{ verify_caller } failed as an exception was thrown when the verification block was executed"
        error_message << "#{ MobyUtil::KernelHelper.find_source( verify_caller ) }\nDetails: \n#{ $!.inspect }"
      
      end

      $logger.behaviour "FAIL;Verification #{ message }failed: #{ $!.to_s }.\n #{ timeout.nil? ? '' : ' using timeout ' + timeout.to_s }.;#{ kind_of?( MobyBase::SUT ) ? id.to_s + ';sut' : ';' };{};verify_greater;"

      # raise the exception
      raise Minitest::Assertion, error_message
       
    ensure

      # restore original test object factory timeout value 
      TDriver::TestObjectFactory.timeout = original_timeout_value

      # restore logger state
      $logger.enabled = logging_enabled
    
    end

    $logger.behaviour "PASS;Verification #{ message }at #{ verify_caller } was successful#{ timeout.nil? ? '' : ' using timeout ' + timeout.to_s }.;#{ kind_of?( MobyBase::SUT ) ? id.to_s + ';sut' : ';' };{};verify_greater;"

    nil
  
  end


  # Verifies that the block given to return value matches with expected regular expression pattern. Verification is synchronized with all connected suts.
  # If this method is called for a sut, synchronization is only done with that sut.
  #
  # === params
  # expected:: Regular expression
  # timeout:: (optional) Integer defining the amount of seconds during which the verification must pass.
  # message:: (optional) A String that is displayed as additional information if the verification fails.
  # === returns
  # nil
  # === raises
  # ArgumentError:: message was not a String or timeout an integer, or no block was given.
  # TypeError:: if block result not type of String.
  # VerificationError:: The verification failed.
  # RuntimeError:: An unexpected error was encountered during verification.
  def verify_regexp( expected_value, timeout = nil, message = nil, &block )

    begin

      # store original timeout value
      original_timeout_value = TDriver::TestObjectFactory.timeout
    
      # determine name of caller method
      verify_caller = caller( 1 ).first.to_s

      # store orignal logging state
      logging_enabled = $logger.enabled

      # disable behaviour logging
      $logger.enabled = false

      # verify that arguments was given in correct format
      expected_value.check_type Regexp, "wrong argument type $1 for expected result (expected $2)"

      # ensure that timeout is either nil or type of integer
      timeout.check_type [ Integer, NilClass ], 'wrong argument type $1 for timeout (expected $2)'

      # ensure that message is either nil or type of string
      message.check_type [ String, NilClass ], 'wrong argument type $1 for exception message (expected $2)'
  
      # verify that block was given
      raise LocalJumpError, 'unable to verify due to no code block was given' unless block_given?

      # convert timeout to integer, nil will be zero
      timeout = get_timeout( timeout )

      # verify that timeout is valid
      timeout.not_negative 'timeout value cannot be negative'

      # calculate the time when timeout exceeds
      timeout_end_time = Time.now + timeout

      # convert message to string, nil will be empty string
      message = message.to_s

      # add double quotation and trailing whitespace if not empty string
      message = "#{ message.inspect } " if message.length > 0

      # set the testobject timeout to 0 for the duration of the verify call
      TDriver::TestObjectFactory.timeout = 0

      # result container
      result = nil

      loop do
      
        begin
        
          counter = ref_counter

          # execute code block
          result = yield

          # raise exception if result of yield does not match with expected value regexp 
          raise MobyBase::VerificationError unless result =~ expected_value

          # break loop if no exceptions thrown
          break

        rescue 

          raise if $!.kind_of?( MobyBase::ContinuousVerificationError )

          # refresh and retry unless timeout exceeded
          raise $! if Time.now > timeout_end_time
          
          # retry interval
          sleep TIMEOUT_CYCLE_SECONDS

          # refresh suts
          refresh_suts if counter == ref_counter
        
        end # begin
      
      end # do loop
        
    rescue

      # restore logger state
      $logger.enabled = logging_enabled

      # execute on verification error code block
      execute_on_error_verify_block unless @@on_error_verify_block.nil?

      # process the exception
      if $!.kind_of?( MobyBase::ContinuousVerificationError )
      
        raise
    
      elsif $!.kind_of?( MobyBase::VerificationError )
      
        error_message = "Verification #{ message }at #{ verify_caller } failed: #{ MobyUtil::KernelHelper.find_source( verify_caller ) }"
        error_message << "The return value of block did not match with #{ expected_value.inspect } pattern. Block returned: #{ result.inspect }"
        
      else
      
        error_message = "Verification #{ message }at #{ verify_caller } failed as an exception was thrown when the verification block was executed"
        error_message << "#{ MobyUtil::KernelHelper.find_source( verify_caller ) }\nDetails: \n#{ $!.inspect }"
      
      end

      $logger.behaviour "FAIL;Verification #{ message }failed: #{ $!.to_s }.\n #{ timeout.nil? ? '' : ' using timeout ' + timeout.to_s }.;#{ kind_of?( MobyBase::SUT ) ? id.to_s + ';sut' : ';' };{};verify_regexp;"

      # raise the exception
      raise MobyBase::VerificationError, error_message
       
    ensure

      # restore original test object factory timeout value 
      TDriver::TestObjectFactory.timeout = original_timeout_value

      # restore logger state
      $logger.enabled = logging_enabled
    
    end

    $logger.behaviour "PASS;Verification #{ message }at #{ verify_caller } was successful#{ timeout.nil? ? '' : ' using timeout ' + timeout.to_s }.;#{ kind_of?( MobyBase::SUT ) ? id.to_s + ';sut' : ';' };{};verify_regexp;"

    nil
  
  end

  def minitest_verify_regexp( expected_value, timeout = nil, message = nil, &block )
    require 'minitest/assertions'
    begin

      # store original timeout value
      original_timeout_value = TDriver::TestObjectFactory.timeout
    
      # determine name of caller method
      verify_caller = caller( 1 ).first.to_s

      # store orignal logging state
      logging_enabled = $logger.enabled

      # disable behaviour logging
      $logger.enabled = false

      # verify that arguments was given in correct format
      expected_value.check_type Regexp, "wrong argument type $1 for expected result (expected $2)"

      # ensure that timeout is either nil or type of integer
      timeout.check_type [ Integer, NilClass ], 'wrong argument type $1 for timeout (expected $2)'

      # ensure that message is either nil or type of string
      message.check_type [ String, NilClass ], 'wrong argument type $1 for exception message (expected $2)'
  
      # verify that block was given
      raise LocalJumpError, 'unable to verify due to no code block was given' unless block_given?

      # convert timeout to integer, nil will be zero
      timeout = get_timeout( timeout )

      # verify that timeout is valid
      timeout.not_negative 'timeout value cannot be negative'

      # calculate the time when timeout exceeds
      timeout_end_time = Time.now + timeout

      # convert message to string, nil will be empty string
      message = message.to_s

      # add double quotation and trailing whitespace if not empty string
      message = "#{ message.inspect } " if message.length > 0

      # set the testobject timeout to 0 for the duration of the verify call
      TDriver::TestObjectFactory.timeout = 0

      # result container
      result = nil

      loop do
      
        begin
        
          counter = ref_counter

          # execute code block
          result = yield

          # raise exception if result of yield does not match with expected value regexp 
          raise MobyBase::VerificationError unless result =~ expected_value

          # break loop if no exceptions thrown
          break

        rescue 

          raise if $!.kind_of?( MobyBase::ContinuousVerificationError )

          # refresh and retry unless timeout exceeded
          raise $! if Time.now > timeout_end_time
          
          # retry interval
          sleep TIMEOUT_CYCLE_SECONDS

          # refresh suts
          refresh_suts if counter == ref_counter
        
        end # begin
      
      end # do loop
        
    rescue

      # restore logger state
      $logger.enabled = logging_enabled

      # execute on verification error code block
      execute_on_error_verify_block unless @@on_error_verify_block.nil?

      # process the exception
      if $!.kind_of?( MobyBase::ContinuousVerificationError )
      
        raise
    
      elsif $!.kind_of?( MobyBase::VerificationError )
      
        error_message = "Verification #{ message }at #{ verify_caller } failed: #{ MobyUtil::KernelHelper.find_source( verify_caller ) }"
        error_message << "The return value of block did not match with #{ expected_value.inspect } pattern. Block returned: #{ result.inspect }"
        
      else
      
        error_message = "Verification #{ message }at #{ verify_caller } failed as an exception was thrown when the verification block was executed"
        error_message << "#{ MobyUtil::KernelHelper.find_source( verify_caller ) }\nDetails: \n#{ $!.inspect }"
      
      end

      $logger.behaviour "FAIL;Verification #{ message }failed: #{ $!.to_s }.\n #{ timeout.nil? ? '' : ' using timeout ' + timeout.to_s }.;#{ kind_of?( MobyBase::SUT ) ? id.to_s + ';sut' : ';' };{};verify_regexp;"

      # raise the exception
      raise Minitest::Assertion, error_message
       
    ensure

      # restore original test object factory timeout value 
      TDriver::TestObjectFactory.timeout = original_timeout_value

      # restore logger state
      $logger.enabled = logging_enabled
    
    end

    $logger.behaviour "PASS;Verification #{ message }at #{ verify_caller } was successful#{ timeout.nil? ? '' : ' using timeout ' + timeout.to_s }.;#{ kind_of?( MobyBase::SUT ) ? id.to_s + ';sut' : ';' };{};verify_regexp;"

    nil
  
  end


  # Verifies that the given signal is emitted.
  #
  # === params
  # timeout:: Integer, defining the amount of seconds during which the verification must pass.
  # signal_name:: String, name of the signal
  # message:: (optional) A String that is displayed as additional information if the verification fails.
  # block:: code to execute while listening signals
  # === returns
  # nil
  # === raises
  # ArgumentError:: message or signal_name was not a String or timeout a non negative Integer
  # VerificationError:: The verification failed.
  def verify_signal( timeout, signal_name, message = nil, &block )

    begin

      logging_enabled = $logger.enabled

      $logger.enabled = false

      # ensure that timeout is either nil or type of integer
      timeout.check_type Integer, 'wrong argument type $1 for timeout (expected $2)'

      # ensure that message is either nil or type of string
      message.check_type [ String, NilClass ], 'wrong argument type $1 for exception message (expected $2)'

      # verify that block was given
      raise LocalJumpError, 'unable to verify due to no code block was given' unless block_given?

      # verify that timeout is valid
      timeout.not_negative 'timeout value cannot be negative'

      # convert message to string, nil will be empty string
      message = message.to_s

      # add double quotation and trailing whitespace if not empty string
      message = "#{ message.inspect } " if message.length > 0

      verify_caller = caller(1).first.to_s

      # wait for the signal
      begin

        wait_for_signal( timeout, signal_name, &block )

      rescue

        error_msg = "Verification #{ message }at #{ verify_caller } failed: #{ MobyUtil::KernelHelper.find_source(verify_caller) }"
        error_msg << "The signal #{ signal_name } was not emitted in #{ timeout } seconds.\nNested exception:\n#{ $!.inspect }"

        raise MobyBase::VerificationError, error_msg

      end

    rescue

      execute_on_error_verify_block unless @@on_error_verify_block.nil?

      $logger.enabled = logging_enabled

      $logger.behaviour "FAIL;Verification #{ message }failed: #{ $!.to_s } using timeout '#{ timeout }.;#{ kind_of?(MobyBase::SUT) ? id.to_s + ';sut' : ';' };{};verify_signal;#{ signal_name }"

      raise

    ensure
    
      $logger.enabled = logging_enabled
      
    end

    $logger.behaviour "PASS;Verification #{ message }at #{ verify_caller } was successful#{ timeout.nil? ? '' : ' using timeout ' + timeout.to_s }.;#{ kind_of?( MobyBase::SUT ) ? id.to_s + ';sut' : ';' };{};verify_signal;#{ signal_name }"
    
    nil

  end

  def minitest_verify_signal( timeout, signal_name, message = nil, &block )
    require 'minitest/assertions'
    begin

      logging_enabled = $logger.enabled

      $logger.enabled = false

      # ensure that timeout is either nil or type of integer
      timeout.check_type Integer, 'wrong argument type $1 for timeout (expected $2)'

      # ensure that message is either nil or type of string
      message.check_type [ String, NilClass ], 'wrong argument type $1 for exception message (expected $2)'

      # verify that block was given
      raise LocalJumpError, 'unable to verify due to no code block was given' unless block_given?

      # verify that timeout is valid
      timeout.not_negative 'timeout value cannot be negative'

      # convert message to string, nil will be empty string
      message = message.to_s

      # add double quotation and trailing whitespace if not empty string
      message = "#{ message.inspect } " if message.length > 0

      verify_caller = caller(1).first.to_s

      # wait for the signal
      begin

        wait_for_signal( timeout, signal_name, &block )

      rescue

        error_msg = "Verification #{ message }at #{ verify_caller } failed: #{ MobyUtil::KernelHelper.find_source(verify_caller) }"
        error_msg << "The signal #{ signal_name } was not emitted in #{ timeout } seconds.\nNested exception:\n#{ $!.inspect }"

        raise Minitest::Assertion, error_msg

      end

    rescue

      execute_on_error_verify_block unless @@on_error_verify_block.nil?

      $logger.enabled = logging_enabled

      $logger.behaviour "FAIL;Verification #{ message }failed: #{ $!.to_s } using timeout '#{ timeout }.;#{ kind_of?(MobyBase::SUT) ? id.to_s + ';sut' : ';' };{};verify_signal;#{ signal_name }"

      raise

    ensure
    
      $logger.enabled = logging_enabled
      
    end

    $logger.behaviour "PASS;Verification #{ message }at #{ verify_caller } was successful#{ timeout.nil? ? '' : ' using timeout ' + timeout.to_s }.;#{ kind_of?( MobyBase::SUT ) ? id.to_s + ';sut' : ';' };{};verify_signal;#{ signal_name }"
    
    nil

  end



  private

  # TODO: remove me?
  def get_end_time( timeout )

    if kind_of?( MobyBase::SUT )

      Time.now + ( timeout.nil? ? $parameters[ sut ][ :synchronization_timeout, '10' ].to_i : timeout.to_i )

    else

      Time.now + ( timeout.nil? ? $parameters[ :synchronization_timeout, '10' ].to_i : timeout.to_i )

    end

  end

  def get_timeout( timeout )

    if kind_of?( MobyBase::SUT )

      timeout = $parameters[ sut ][ :synchronization_timeout, '10' ] if timeout.nil?

    else

      timeout = $parameters[ :synchronization_timeout, '10' ] if timeout.nil?

    end
    
    timeout.to_i
      
  end

  # Current count of combined sut refresh calls to all suts
  def ref_counter
    counter = 0
    if kind_of?( MobyBase::SUT )
      counter = dump_count
    else
      TDriver::SUTFactory.connected_suts.each do |sut_id, sut_attributes|
        counter += sut_attributes[:sut].dump_count
      end
    end
    counter
  end

  def verify_refresh(b_use_id=true)
    if kind_of?( MobyBase::SUT )
        begin
          appid = get_application_id
        rescue
          appid='-1'
        end
        if appid != "-1" && b_use_id
          refresh({:id => appid})
        else
          refresh
        end
      else
        #refresh all connected suts
        TDriver::SUTFactory.connected_suts.each do |sut_id, sut_attributes|
          begin
            appid = sut_attributes[:sut].get_application_id
          rescue
            appid='-1'
          end
          if appid != "-1" && b_use_id
            sut_attributes[:sut].refresh({:id => appid}) if sut_attributes[:is_connected]
          else
            sut_attributes[:sut].refresh if sut_attributes[:is_connected]
          end
        end
      end
  end

  # Refresh ui state inside verify
  def refresh_suts
    begin
      verify_refresh
      # Ignore all availability errors
    rescue RuntimeError, MobyBase::ApplicationNotAvailableError => e
      begin
        verify_refresh(false)
      rescue RuntimeError, MobyBase::ApplicationNotAvailableError => e
        # This occurs when no applications are registered to sut
        if !(e.message =~ /no longer available/)
          puts 'Raising exception'
          # all other errors are passed up
          raise e
        end
      end
    end
  end

end

module MattiVerify
  include TDriverVerify

end
