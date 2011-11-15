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

      if return_indexes

        @object_behaviours

      else

        TDriver::BehaviourFactory.collect_behaviours( :index => @object_behaviours ).collect{ | behaviour | behaviour[ :name ] }.uniq.compact

      end

		end

    # == description
    # Returns a list of the names of (behaviour) methods publicly accessible in object. This method may be useful when implementing/testing custom behaviour modules.
    # == returns
    # Array
    #  description: List of method names 
    #  example: ["application?", "close", "closable?", "describe"]
		def object_methods

      TDriver::BehaviourFactory.collect_behaviours( :index => @object_behaviours ).inject( [] ){ | result, behaviour |

        # append method names to result array
        result.concat( 

          behaviour[ :methods ].keys.collect{ | key | 

            # make sure that method name is returned in type of string
            key.to_s 

          } 

        ) 

      }.uniq.compact

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
    # == exceptions
    # TypeError
    #  description: Wrong argument type <class> for method name (expected Symbol or String)
    #
    # ArgumentError
    #  description: Test object type of <type> does not have method <name>
    #
		def describe_method( method_name, print = true, return_result = false )
			
      # verify that method_name is type of Symbol or String and convert it to Symbol
      method_name = method_name.check_type( [ Symbol, String ], "wrong argument type $1 for method name (expected $2)" ).to_s

      # verify that print argument is boolean
      print = print.check_type( [ TrueClass, FalseClass ], "wrong argument type $1 for verbose output (expected $2)" ).true?

			# return result not printed out to stdout 
			return_result = true if print.false?

      behaviours = TDriver::BehaviourFactory.collect_behaviours( :index => @object_behaviours ).select{ | behaviour |

        behaviour[ :methods ].keys.include?( method_name )

      }.compact.last

      # verify that method was found
      behaviours.not_blank "Test object type of #{ @type } does not have method #{ method_name.inspect }"

      result = { 
        :name => method_name, 
        :description => behaviours[ :methods ][ method_name ][ :description ], 
        :example => behaviours[ :methods ][ method_name ][ :example ] 
      }

      if print

        result = [ :name, :description, :example ].inject( "" ){ | tmp_result, key |

					tmp_result << "\n#{ key.to_s.capitalize }:\n#{ result[ key ] }\n"

        }

        puts result

      end

      # result
      return_result ? result : nil    

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
		def describe( print = true, return_result = false )

			# print result to stdout if argument not boolean
			print = true unless [ TrueClass, FalseClass ].include? print.class

			# return result not printed out to stdout 
			return_result = true unless print

			result_hash = {

				:object => { :type => @type, :sut => kind_of?( MobyBase::SUT ) ? id : sut.id },
				:methods => object_methods,						
				:behaviours => behaviours 
			}

			if print

				result = ""

				[:object, :behaviours, :methods].each{ | key, value | 
					value = result_hash[ key ]
					result << "\n#{ key.to_s.capitalize }:\n"
					case value.class.to_s
						when "Array"
              result << "\t" << value.join("\n\t") << "\n"
						when "Hash"
              result << value.collect{ | key, value | "\t#{ key } => #{ value }" }.join("\n") << "\n"
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
		TDriver::Hooking.hook_methods( self ) if defined?( TDriver::Hooking )
	
	end # ObjectBehaviourDescription

end # MobyBehaviour
