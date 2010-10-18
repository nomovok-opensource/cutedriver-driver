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

		def behaviours( return_indexes = false )

			return_indexes ? @object_behaviours : @object_behaviours.collect{ | index | MobyBase::BehaviourFactory.instance.get_behaviour_at_index( index )[ :name ] }.uniq.compact.sort

		end

		def object_methods


			[].tap{ | methods | 
				@object_behaviours.each{ | index | 
					MobyBase::BehaviourFactory.instance.get_behaviour_at_index( index )[ :methods ].keys.each{ | key | methods << key.to_s }
				} 
			}.uniq.compact.sort

		end

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
