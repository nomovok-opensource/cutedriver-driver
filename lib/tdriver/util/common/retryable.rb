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

  class Retryable

    # Function to retry code block for x times if exception raises
    # == params
    # options:: Hash of options 
    #   :tries  Number of tries to perform. Default is 1
    #   :interval  Timeout between retry. Default is 0
    #   :exception  Retry if given type of exception occures. Default is Exception (any error)
    # == returns
    def self.while( options = {}, &block )

      # default options
      options.default_values( :tries => 1, :interval => 0, :exception => Exception )

      attempt = 1

      begin

        # yield given block and pass attempt number as parameter
        yield( attempt )

      rescue *options[ :exception ]

        if ( attempt < options[ :tries ] ) && ![ *options[ :unless ] ].include?( $!.class )

          sleep( options[ :interval ] ) if options[ :interval ] > 0

          attempt += 1

          retry

        end

        # raise exception with correct exception backtrace
        Kernel::raise $!

      end

      #nil
      
    end

    # Function to retry code block until timeout expires if exception raises 
    # == params
    # options:: Hash of options 
    #   :timeout  Timeout until fail. Default is 0
    #   :interval  Timeout between retry. Default is 0
    #   :exception  Retry if given type of exception occures. Default is Exception (any error)
    # == returns
    def self.until( options = {}, &block )

      # default options
      options.default_values( :timeout => 0, :interval => 0, :exception => Exception )
      
      # store start time
      start_time = Time.now

      # attempt number
      attempt = 0

      begin

        # execute block
        yield( attempt )

      rescue *options[ :exception ]

        if (Time.now - start_time) <= options[ :timeout ] && ![ *options[ :unless ] ].include?( $!.class )

          sleep( options[ :interval ] ) if options[ :interval ] > 0

          attempt += 1

          retry

        end

        # raise exception with correct exception backtrace
        Kernel::raise $!

      end
      
      #nil

    end

    # enable hooking for performance measurement & debug logging
    MobyUtil::Hooking.instance.hook_methods( self ) if defined?( MobyUtil::Hooking )

  end # Retryable

end # MobyUtil
