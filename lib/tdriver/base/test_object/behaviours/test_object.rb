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

	module TestObject

		# Hash containing the identification attributes that were used when the test object was created.
		attr_accessor :creation_attributes

		# Tries to use the missing method id as a child object type and find an object based on it
		def method_missing( method_id, *method_arguments )

			# method mapping/aliases - this should be configured in xml file
			#case method_id
			#	when :Button;	method_id = [ :Button, :QToolButton, :DuiButton, :HbPushButton, :softkey ]
			#	when :List;	method_id = [ :QList, :HbListWidgetView, :DuiList ]
			#end

			hash_rule = ( method_arguments.first.kind_of?( Hash ) ? method_arguments.first : {} ).merge( :type => method_id )

			begin
				child( hash_rule )

			rescue MobyBase::TestObjectNotFoundError, MobyBase::TestObjectNotVisibleError

				#hash_rule.delete( :type )

				Kernel::raise MobyBase::TestObjectNotFoundError.new(
					'The test object (id: "%s", type: "%s", name: "%s") has no child object with type or behaviour method with name "%s" (%s) on sut "%s".' % 
					[ @id, @type, @name, method_id.inspect, ( hash_rule.empty? ? "" : "attributes: #{ hash_rule.inspect }" ), @sut.id ]
				)

			end

		end

		# Determine is current test object a application
		# === returns
		# TrueClass:: 
		# FalseClass:: 
		def application?

			@type == 'application'

		end

		# Return all test object attributes
		# === returns
		# Hash:: Test object attributes
		def attributes

			# return hash of test object attributes
			Hash[ xml_data.xpath( 'attributes/attribute' ).collect{ | test_object | [ test_object.attribute( 'name' ), test_object.content ] } ]

		end

		# Changes the status of the test object to active
		# == returns 
		# TrueClass::
		def activate

			@_active = true

		end

		# Changes the status of the test object to inactive, also deactivating all children
		# Removes reference from @parent TestObject or SUT to this TestObject so that 
		# @parent.refresh does not refresh currrent TestObject
		#
		# Does nothing if TestObject is already deactivated
		# == returns 
		# ?
		def deactivate

			return if !@_active

			@_active = false

			@_child_object_cache.each_value{ | test_object | 

				# deactivate test object					
				test_object.deactivate	

			}

			@_child_object_cache.clear

			@parent.remove_child( self )


		end


		# Function returns a attribute of test object 
		# === params
		# name:: String definig the name of the attribute to get
		# === returns
		# String:: Value of the attribute as a string
		# === raises
		# TestObjectNotInitializedError:: if the test object xml data has not been initialized
		# AttributeNotFoundError:: if the requested attribute can not be found in the xml data of the object
		def attribute( name )

			# note: count of tries represents total number of tries
			MobyUtil::Retryable.while( :tries => 2, :interval => 0 ) { | attempt |

				begin
	
					# find attribute from xml
					find_attribute( name )

				rescue MobyBase::AttributeNotFoundError

					# do following actions only once
					if ( attempt == 1 )

						# add to dynamic attribute filter once
						MobyUtil::DynamicAttributeFilter.instance.add_attribute( name )

						# refresh ui state
						refresh( :id => get_application_id )

					end

					# raise exception and retry if attempts left
					raise

				end

			}

		end
		
		# Returns the actual test object that was used as the parent when this object instance was created. For getting the parent object in the UI object hierarchy, 
        	# see get_parent.
		#
		# === returns
		# TestObject:: test object that was used as parent when this object was created. Can also be of type SUT if sut was the parent (ie. application objects)
		def parent_object()

			$stderr.puts "warning: TestObject#parent_object is deprecated, please use TestObject#parent instead."			

			@parent

		end
		
		# Returns theparent test object for the current object in question, according to the UI object hierarchy. For getting the test object that was actually used 
		# as the parent when the test object instance was created, see parent_object.
		#
		# === returns
		# TestObject:: test object that is parent of this test object, self if no parent (ie. application objects)
		def get_parent()

			return self if application?

			#find parent id
			element_set = @sut.xml_data.xpath( "//object/objects/object[@id='%s']/../.." % @id )

			return self if( element_set == nil or element_set.size == 0 )

			element = element_set.first

			#if app set look for the item under the app to make sure app id is available
			if self.get_application_id && element.attribute( "type" ) != 'application'

				@sut.child( 

					:id => get_application_id, 
					:type => 'application' 

				).child( 

					:id => element.attribute( "id" ), 
					:name => element.attribute( "name" ), 
					:type => element.attribute( "type" ) 

				)

			else

				@sut.child( 
   				    :id => element.attribute( "id" ), 
					:name => element.attribute( "name" ), 
					:type => element.attribute( "type" ) 
				)

			end

		end


		# TODO: Team TE: review me @ 'Brakes'
		# Creates a test object for a child object of this test object
		# Associates child object as current object's child.
		# and associates self as child object's parent.
		#
		# NOTE:
		# Subsequent calls to TestObject#child(rule) always returns reference to same Testobject:
		# a = to.child(rule) ; b = to.child(rule) ; a.equal?( b ); # => true
		# note the usage of equal? above instead of normally used eql?. Please refer to Ruby manual for more information.
		#
		# NOTE: The accessor methods for child objects created automatically by the DataGenerator are dependent on this method.
		# === params
		# attributes:: Hash object holding information for identifying which child to create, eg. :type => :slider
		# === returns
		# TestObject:: new child test object or reference to existing child
		def child( attributes )

			creation_data = attributes.clone
			logging_enabled = MobyUtil::Logger.instance.enabled

			MobyUtil::Logger.instance.enabled = false if ( creation_data.delete( :__logging ) == 'false' )
			creation_data.delete( :__timeout )

			# check if the hash contains symbols as values and translate those into strings
			translate!( creation_data )

			refresh_args = ( creation_data[ :type ] == 'application' ? { :name => creation_data[ :name ], :id => creation_data[ :id ] } : { :id => get_application_id } )

			if !( @_active )

				@sut.refresh refresh_args

				begin 
					@parent.child( :type => @type, :id => @id )

				rescue MobyBase::TestObjectNotFoundError

					MobyUtil::Logger.instance.log("behaviour", "FAIL;Parent test object no longer visible.;#{ identity };child;#{ creation_data.inspect }")
					MobyUtil::Logger.instance.enabled = logging_enabled
					Kernel::raise MobyBase::TestObjectNotVisibleError

				end
			end

			initial_timeout = @test_object_factory.timeout unless ( custom_timeout = nil || attributes[ :__timeout ] ).nil?

			# add symbols to dynamic attributes list -- to avoid IRB bug
			MobyUtil::DynamicAttributeFilter.instance.add_attributes( creation_data.keys )

			begin

				@test_object_factory.timeout = custom_timeout unless custom_timeout.nil?
				child_object = @test_object_factory.make_child( self, MobyBase::TestObjectIdentificator.new( creation_data ) )

			rescue MobyBase::MultipleTestObjectsIdentifiedError => exception

				MobyUtil::Logger.instance.log("behaviour" , "FAIL;Multiple child objects matched criteria.;#{ identity };child;#{ creation_data.inspect }")
				Kernel::raise exception

			rescue MobyBase::TestObjectNotFoundError => exception

				MobyUtil::Logger.instance.log("behaviour" , "FAIL;The child object could not be found.;#{ identity };child;#{ creation_data.inspect }")
				Kernel::raise exception

			rescue Exception => exception

				MobyUtil::Logger.instance.log("behaviour" , "FAIL;Failed when trying to find child object.;#{ identity };child;#{ creation_data.inspect }")
				Kernel::raise exception

			ensure
				@test_object_factory.timeout = initial_timeout unless custom_timeout.nil?
				MobyUtil::Logger.instance.enabled = logging_enabled
			end

			#MobyUtil::Logger.instance.log "behaviour", "PASS;Object found with matching criteria.;#{ identity };child;#{ creation_data.inspect }"

			# Type information is stored in a separate member, not in the Hash
			creation_data.delete( :type )

			# use cached test object if once already retrieved
			get_cached_test_object!( child_object ).tap{ | found_in_cache |

				# Store/update the attributes that were used to create the child object.
				child_object.creation_attributes = creation_data

				# add child to objects cache 
				add_child( child_object ) unless found_in_cache

			}

			child_object

		end

		# Function similar to child, but returns an array of children test objects that meet the given criteria
		# === params
		# attributes:: Hash object holding information for identifying which child to create, eg. :type => :slider
	        #find_all:: Boolean specifying whether all children under the test node or just immediate children should be retreived.
		# === returns
		# An array of TestObjects
		def children( attributes={}, find_all=true)
		  
			raise TypeError.new( 'Input parameter not of Type: Hash.\nIt is: ' + attributes.class.to_s ) unless attributes.kind_of?( Hash ) #and !attributes.empty?
			
			# If empty or only special attributes then add :type => "any" to search all
			temp_attributes = attributes.clone
			temp_attributes.delete_if {|k,v| (k.to_s =~ /^__/) != nil }
			attributes.merge!({:type => "any"}) if temp_attributes.empty?
			
			child_objects = Array.new
		  
			creation_data = attributes.clone
			logging_enabled = MobyUtil::Logger.instance.enabled

			MobyUtil::Logger.instance.enabled = false if ( creation_data.delete( :__logging ) == 'false' )
			creation_data.delete( :__timeout )

			# check if the hash contains symbols as values and translate those into strings
			translate!( creation_data )

			refresh_args = ( creation_data[ :type ] == 'application' ? { :name => creation_data[ :name ], :id => creation_data[ :id ] } : { :id => get_application_id } )

			# add symbols to dynamic attributes list -- to avoid IRB bug
			MobyUtil::DynamicAttributeFilter.instance.add_attributes( creation_data.keys )

			if !( @_active )

				@sut.refresh refresh_args

				begin 
					@parent.child( :type => @type, :id => @id )

				rescue MobyBase::TestObjectNotFoundError

					MobyUtil::Logger.instance.log("behaviour", "FAIL;Parent test object no longer visible.;#{ identity };child;#{ creation_data.inspect }")
					MobyUtil::Logger.instance.enabled = logging_enabled
					Kernel::raise MobyBase::TestObjectNotVisibleError

				end
			end

			initial_timeout = @test_object_factory.timeout unless ( custom_timeout = nil || attributes[ :__timeout ] ).nil?

			begin

				@test_object_factory.timeout = custom_timeout unless custom_timeout.nil?
				child_objects = @test_object_factory.make_multiple_children( self, MobyBase::TestObjectIdentificator.new( creation_data ), find_all )

			rescue MobyBase::TestObjectNotFoundError => exception

				MobyUtil::Logger.instance.log("behaviour" , "FAIL;The child object could not be found.;#{ identity };child;#{ creation_data.inspect }")
				Kernel::raise exception

			rescue Exception => exception

				MobyUtil::Logger.instance.log("behaviour" , "FAIL;Failed when trying to find child object.;#{ identity };child;#{ creation_data.inspect }")
				Kernel::raise exception

			ensure
				@test_object_factory.timeout = initial_timeout unless custom_timeout.nil?
				MobyUtil::Logger.instance.enabled = logging_enabled
			end

			#MobyUtil::Logger.instance.log "behaviour", "PASS;Object found with matching criteria.;#{ identity };child;#{ creation_data.inspect }"

			# Type information is stored in a separate member, not in the Hash
			creation_data.delete( :type )

			child_objects.each do | child_object |

				# use cached test object if once already retrieved
				get_cached_test_object!( child_object ).tap{ | found_in_cache |

					# Store/update the attributes that were used to create the child object.
					child_object.creation_attributes = creation_data

					# add child to objects cache 
					add_child( child_object ) unless found_in_cache

				}

			end

			# return test objects
			child_objects
		end
    
		# Updates this test object to match the data in the provided xml document
		# Propagates updating to all child TestObjects
		# If TestObject is not identified, then current TO is deactivated, as is all the Child objects, as defined in TestObject#deactivate.
		# === params
		# xml_document:: LibXML::XML::Node describing the new state of this test object
		# === returns 
		# ?
		# === raises
		# nothing
		def update( xml_document )

			begin

				if !( _xml_data = MobyBase::TestObjectIdentificator.new( :type => @type, :id => @id, :name => @name ).find_object_data( xml_document ) ).eql?( xml_data )

					@_child_objects.each { | test_object | test_object.update( ( xml_data = _xml_data ) ) }

				end

			rescue MobyBase::TestObjectNotFoundError, MobyBase::MultipleTestObjectsIdentifiedError

				deactivate

			end


		end 

		# Function refreshes test objects to correspond with the current state of the device.
		# 
		# NOTE:
		#
		# @sut#refresh will call update method for this TestObject, if state has changed. Thus, calling
		# @sut.refresh might have a side effect that changes the @_active instance variable.
		# === raises
		# TestObjectNotFoundError:: if TestObject is not identified within synch timeout.
		def refresh( refresh_args = {} )

			@sut.refresh( refresh_args )

		end

		# Function refreshes test objects to correspond with the current state of the device, forcing
		# the sut to request a new XML dump from the device.
		# 
		# NOTE:
		#
		# @sut#force_refresh will call update method for this TestObject, if state has changed. Thus, calling
		# @sut.force_refresh might have a side effect that changes the @_active instance variable.
		# === raises
		# TestObjectNotFoundError:: if TestObject is not identified within synch timeout.
		def force_refresh( refresh_args = {} )

			@sut.refresh( refresh_args )

		end

		# Function for finding out the application id for this test ojbect
		# All test objects should be under application object now so this should be ok?
		# === returns
		# String:: representing the id of the application test object
		def get_application_id

			return @_application_id if @_application_id

			return @id if application?

			parent_object = @parent

			while parent_object

				return ( @_application_id = parent_object.id ) if parent_object.type == 'application'

				parent_object = parent_object.parent

			end

			# last resort
			begin

				return @sut.child( :type => 'application' ).id

			rescue e

			end

			# no parent found
			nil

		end

		def set_application_id( application_id )

			@_application_id = application_id

 		end

		# Returns a StateObject containing the current state of this test object as XML.
		# The state object is static and thus is not refreshed or synchronized etc.
		#
		# === returns
		# StateObject:: State of this test object
		def state

			MobyBase::StateObject.new( xml_data, self )

		end

		# Function for translating all symbol values into strings using sut's translate method
		# Goes through all items in a hash and if a value is symbol then uses that symbol as a logical
		# name and tries to find a translation for that.
		# === params
		# hash:: Hash containing key, value pairs. The parameter will get modified if symbols are found from values
		# === raises
		# LanguageNotFoundError:: In case of language is not found
		# LogicalNameNotFoundError:: In case of logical name is not found for current language
		# MySqlConnectError:: In case problems with the db connectivity
		def translate!( hash )

			hash.each_pair do | _key, _value |

				next if [ :name, :type, :id ].include?( _key )

				hash[ _key ] = sut.translate( _value ) if _value.kind_of?( Symbol ) 

			end if !hash.nil?

		end

	private

		# TODO: refactor logging_enabled 
		# try to reactivate test object if currently not active
		def reactivate_test_object( attributes )

			refresh_args = ( attributes[ :type ] == 'application' ? { :name => attributes[ :name ], :id => attributes[ :id ] } : { :id => get_application_id } )

			@sut.refresh( refresh_args )

			begin 
				@parent.child( :type => @type, :id => @id )

			rescue MobyBase::TestObjectNotFoundError

				Kernel::raise MobyBase::TestObjectNotVisibleError

			end

		end

		# Strip dynamic attributes (such as :__timeout, :__logging) from hash and return those as hash
		# == returns
		# Hash:: Hash of dynamic attributes
		def strip_dynamic_attributes!( attributes, exceptions = [] )

			Hash[ attributes.select{ | key, value | 

				if /^__/.match( key.to_s ) and !exceptions.include?( key )

					attributes.delete( key )

					true

				else

					false

				end

			}]

		end

		def get_cached_test_object!( object )

			object_hash = object.hash

			if @_child_object_cache.has_key?( object_hash ) 

				object = @_child_object_cache[ object_hash ]

				true

			else

				false

			end

		end

		def get_child_objects( attributes )

			# create copy of attributes hash
			creation_data = attributes.clone

			# strip all dynamic attributes such as :__timeout, :__logging etc.
			dynamic_attributes = strip_dynamic_attributes!( creation_data )

			# store and set logger state if given, use default value if none given
			#MATTI.logger.push_enabled( /^(true|false)$/i.match( dynamic_attributes[ :__logging ].to_s ) ? $1.downcase == 'true' : nil )

			# store and set logger state if given, use default value if none given
			MATTI.logger.push_enabled( MobyUtil::KernelHelper.to_boolean( dynamic_attributes[ :__logging ], MATTI.logger.enabled ) )

			# determine if multiple matches is allowed, default: false
			#multiple_objects = dynamic_attributes[ :__multiple_objects ].to_s =~ /^true$/i ? true : false

			# determine if multiple matches is allowed, default value is false
			multiple_objects = MobyUtil::KernelHelper.to_boolean( dynamic_attributes[ :__multiple_objects ], false )

			find_all_children = MobyUtil::KernelHelper.to_boolean( dynamic_attributes[ :__find_all_children ], true )

			# check if the hash contains symbols as values and translate those into strings
			translate!( creation_data )

			# use custom timeout if defined
			timeout = ( dynamic_attributes[ :__timeout ] || @test_object_factory.timeout ).to_i

			# add symbols to dynamic attributes list -- to avoid IRB bug
			MobyUtil::DynamicAttributeFilter.instance.add_attributes( creation_data.keys )

			begin

				# try to reactivate test object if currently not active
				reactivate_test_object( creation_data ) unless @_active

				# retrieve test objects from xml
				child_objects = @test_object_factory.make_child_objects( 

					:attributes => creation_data,
					:dynamic_attributes => dynamic_attributes, 

					:parent => self,
					:sut => @sut,
					:application => self.get_application_id,

					:timeout => timeout,
					:multiple_objects => multiple_objects,
					:find_all_children => find_all_children

				)

				# Type information is stored in a separate member, not in the Hash
				#creation_data.delete( :type )

				child_objects.each do | child_object |

					# use cached test object if once already retrieved
					get_cached_test_object!( child_object ).tap{ | found_in_cache |

						# Store/update the attributes that were used to create the child object.
						child_object.creation_attributes = creation_data

						# add child to objects cache 
						add_child( child_object ) unless found_in_cache

					}

				end

				# return test object(s)
				multiple_objects ? child_objects : child_objects.first

			rescue Exception => exception

				if exception.kind_of?( MobyBase::MultipleTestObjectsIdentifiedError )

					description = "Multiple child objects matched criteria."

				elsif exception.kind_of?( MobyBase::TestObjectNotFoundError )

					description = "The child object(s) could not be found."

				elsif exception.kind_of?( MobyBase::TestObjectNotVisibleError )

					description = "Parent test object no longer visible."

				else

					description = "Failed when trying to find child object(s)."

				end

				MATTI.logger.behaviour(

					"%s;%s;%s;%s;%s" % [ "FAIL", description, identity, multiple_objects ? "children" : "child", creation_data.inspect ]

				)

				Kernel::raise

			ensure

				# restore logger state
				MobyUtil::Logger.instance.pop_enabled

			end

		end

		# Creates a string identifying this test object: sut, type, attributes used when created
		#
		# === returns
		# String:: String identifying this test object
		def identity

			"#{ @sut.id };#{ @type };#{ @creation_attributes.inspect }"

		end


		def find_attribute( name )

			# store xml data to variable, due to xml_data is a function that returns result of xpath to sut.xml_data
			_xml_data = xml_data

			# convert name to string if variable type is symbol
			name = name.to_s if name.kind_of?( Symbol )

			# raise exception if attribute name variable type is other than string
			Kernel::raise ArgumentError.new( "Wrong argument type %s for attribute argument (expected String)" % name.class ) unless name.kind_of?( String )

			# raise eception if xml data is empty or nil
			Kernel::raise MobyBase::TestObjectNotInitializedError.new if _xml_data.nil? || _xml_data.to_s.empty?

			# retrieve attribute(s) from xml
			nodeset = _xml_data.xpath( "attributes/attribute[translate(@name,'ABCDEFGHIJKLMNOPQRSTUVWXYZ','abcdefghijklmnopqrstuvwxyz')='%s']" % name.downcase )

			# raise exception if no such attribute found
			Kernel::raise MobyBase::AttributeNotFoundError.new( "Could not find attribute '%s' for test object of type '%s'." % [ name, type ] ) if nodeset.empty? 

			# Need to disable this for now #Kernel::raise MobyBase::MultipleAttributesFoundError.new( "Multiple attributes found with name '%s'" % name ) if nodeset.count > 1

			# return found attribute
			nodeset.first.content.strip

		end

		# this method will be automatically invoked after module is extended to sut object	
		def self.extended( target_object )

			target_object.instance_exec{

				initialize_settings

			}

		end

		def initialize_settings

			# defaults
			@_application_id = nil
			@creation_attributes = nil

			@_child_object_cache = {}

			activate

		end

		# enable hooking for performance measurement & debug logging
		MobyUtil::Hooking.instance.hook_methods( self ) if defined?( MobyUtil::Hooking )

	end # TestObject 

end # MobyBehaviour
