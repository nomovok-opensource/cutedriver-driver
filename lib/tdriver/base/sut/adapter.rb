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


module MobyController

	# Abstract class SutAdapter. Not supposed to be instantiated as is
	class SutAdapter
	  
      def add_hook( id, &block )

        raise ArgumentError, 'Unable to add hook due to no block was given' unless block_given?
		@hooks = {} unless @hooks
        @hooks[ id ] = block

      end

	  private

      # TODO: document me
      def execute_hook( id, *arguments )

        @hooks[ id ].call( *arguments )

      end

      # TODO: document me
      def hooked? ( id )
		@hooks = {} unless @hooks
        @hooks.has_key?( id )

      end



	end # SutAdapter

end # MobyController
