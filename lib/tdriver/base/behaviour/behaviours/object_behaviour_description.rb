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

module MobyBehaviour

  # == description
  # Generic methods for inspecting test object and it's methods
  #
  # == behaviour
  # GenericObjectDescription
  #
  # == requires
  # *
  #
  # == input_type
  # *
  #
  # == sut_type
  # *
  #
  # == sut_version
  # *
  #
  # == objects
  # *;sut
  #
	module ObjectBehaviourDescription

    # == description
    # Return list of behaviour name(s) which caller object contains. This method may be useful when implementing/testing custom behaviour modules.
    #
    # == arguments
    # return_indexes
    #  TrueClass
    #   description: Returns result as array of behaviour indexes  
    #   example: true
    #  FalseClass
    #   description: Returns result as array of behaviour names
    #   example: false
    #
    # == returns
    # Array
    #  description: If 'return_indexes' is true, result is a array of indexes (Fixnum) 
    #  example: [1,2,3,4,5]
    #
    # Array
    #  description: If 'return_indexes' is false, result is a array of behaviour names (String)
    #  example: ["GenericApplication", "GenericFind", "GenericObjectComposition"]
    #
    # == footer
    #
		def behaviours( return_indexes = false )

			return_indexes ? @object_behaviours : @object_behaviours.collect{ | index | MobyBase::BehaviourFactory.instance.get_behaviour_at_index( index )[ :name ] }.uniq.compact.sort

		end

    # == description
    # Returns a list of the names of (behaviour) methods publicly accessible in object. This method may be useful when implementing/testing custom behaviour modules.
    # == returns
    # Array
    #  description: List of method names 
    #  example: ["application?", "close", "closable?", "describe"]
		def object_methods

			[].tap{ | methods | 
				@object_behaviours.each{ | index | 
					MobyBase::BehaviourFactory.instance.get_behaviour_at_index( index )[ :methods ].keys.each{ | key | methods << key.to_s }
				} 
			}.uniq.compact.sort

		end

    # == description
    # Return brief method description either as return value or printed to STDOUT. This method may be useful when implementing/testing custom behaviour modules. 
    #
    # == arguments
    # method_name
    #  String
    #   description: Name of the method  
    #   example: "type"
    #
    # print
    #  TrueClass
    #   description: Print result to STDOUT and return as String
    #   example: true
    #  FalseClass
    #   description: Return result as Hash instead of printing to STDOUT 
    #   example: false
    #
    # return_result
    #  TrueClass
    #   description: Pass result as return value
    #   example: true
    #  FalseClass
    #   description: Do not pass result as return value
    #   example: false
    #
    # == returns
    # String
    #  description: String representation of object description/details 
    #  example: "Description:\nReturns type of the test object\n\nExample:\ntype"
    #
    # Hash
    #  description: Hash representation of object description/details 
    #  example: { :description=>"Returns type of the test object", :example=>"type" }
    #
    # NilClass
    #  description: When 'return_result' is false
    #  example: nil
    #
    # == footer
    #
		def describe_method( method_name, print = true, return_result = false )
			
			# convert to symbol if method_name is a string
			method_name = method_name.to_sym if method_name.kind_of?( String )

			Kernel::raise ArgumentError.new("Wrong argument type for method name. (Actual: #{ method_name.class }, Expected: Symbol)") unless method_name.kind_of?( Symbol )

			# print result to stdout if argument not boolean
			print = true unless [ TrueClass, FalseClass ].include? print.class

			# return result not printed out to stdout 
			return_result = true unless print

			result_hash = nil

			@object_behaviours.each{ | index | 

				behaviour = MobyBase::BehaviourFactory.instance.get_behaviour_at_index( index )

				if behaviour[ :methods ].keys.include? method_name
					method_details = behaviour[:methods][ method_name ]
					result_hash = { :description => method_details[ :description ], :example => method_details[ :example ] }
					break;
				end
				
			}

			Kernel::raise RuntimeError.new("No such method for object type of #{ self.type }") if result_hash.nil?

			if print

				result = ""

				[ :description, :example ].each{ | key | 
					tmp_hash = result_hash[ key ]
					result << "\n#{ key.to_s.capitalize }:\n#{ tmp_hash }\n"
				}

				puts result

			else

				result = result_hash

			end

			( return_result ? result : nil )

		end

    # == description
    # Return list of methods and behaviour name(s) which caller object contains. This method may be useful when implementing/testing custom behaviour modules.    
    #
    # == arguments
    # print
    #  TrueClass
    #   description: Print result to STDOUT and return as String
    #   example: true
    #  FalseClass
    #   description: Return result as Hash instead of printing to STDOUT 
    #   example: false
    #
    # return_result
    #  TrueClass
    #   description: Pass result as return value
    #   example: true
    #  FalseClass
    #   description: Do not pass result as return value
    #   example: false
    #
    # == returns
    # String
    #  description: String representation of object details 
    #  example: "Object:\n	sut => sut_qt\n	type => application\n\nBehaviours:\n	GenericApplication\n\nMethods:\n	application?\n"
    #
    # Hash
    #  description: Hash representation of object details 
    #  example: { :methods=>["application?"], :behaviours=>["GenericApplication"], :object=>{:sut=>:sut_qt, :type=>"application"} }
    #
    # NilClass
    #  description: When 'return_result' is false
    #  example: nil
    #
    # == footer
    #
		def describe( print = true, return_result = false )

			# print result to stdout if argument not boolean
			print = true unless [ TrueClass, FalseClass ].include? print.class

			# return result not printed out to stdout 
			return_result = true unless print

			result_hash = {

				:object => { :type => self.type, :sut => self.kind_of?( MobyBase::SUT ) ? self.id : self.sut.id },
				:methods => object_methods,						
				:behaviours => behaviours 
			}

			if print

				result = ""

				[:object, :behaviours, :methods].each{ | key, value | 
					value = result_hash[ key ]
					result << "\n#{ key.to_s.capitalize }:\n"
					case value.class.to_s
						when "Array": result << "\t" << value.join("\n\t") << "\n"
						when "Hash": result << value.collect{ | key, value | "\t#{ key } => #{ value }" }.join("\n") << "\n"
					#else
						#result << "\t#{ value }\n"
					end
				}

				puts result

			else

				result = result_hash

			end

			( return_result ? result : nil )

		end

		# enable hooking for performance measurement & debug logging
		MobyUtil::Hooking.instance.hook_methods( self ) if defined?( MobyUtil::Hooking )
	
	end # ObjectBehaviourDescription

end # MobyBehaviour
