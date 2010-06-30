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




require 'tdriver'

module MobyBehaviour

	module QT

		module Testing

			def a
			end
	
			def b
			end

			def self.y
			end


		end

	end

end

def collect_methods( klass )

	methods_list = []

	[ klass.public_instance_methods( false ), klass.singleton_methods( false ) ].each{ | list |

		list.each{ | method | methods_list << method }

	}

	methods_list

end

target = MobyBehaviour::QT::Testing

target_name_array = target.name.split("::")

behaviour_name = target_name_array.last

sut_type = target_name_array.count > 1  ? target_name_array[ 1 ] : '*'

methods = collect_methods( target )

xml = MobyUtil::XML::Builder.new{

	behaviours{

		behaviour( :name => behaviour_name, :object_type => '*', :sut_type => sut_type, :input_type => '*', :version => '*' ){

			_module_( :name => target.name )

			_methods_{

				methods.each{ | method |

					_method_( :name => method.to_s ){

						description "Describe your method behaviour here"
						example "Example of method usage"

					}

				}

			}


		}

	}

}.to_xml.gsub("_module_", "module").gsub("_methods_", "methods").gsub("_method_", "method")

puts xml
