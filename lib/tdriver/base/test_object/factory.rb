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


module MobyBase

	# class to represent TestObjectFactory.
	#
	# when a SUT asks for factory to create test objects, it shall give reference to the SUT so that 
	# factory can make a call back for SUT object dump (in xml)
	class TestObjectFactory

		include Singleton

		attr_reader :timeout

		#attr_writer :behaviour_generator

		# TODO: Document me (TestObjectFactory::initialize)
		def initialize

			#TODO maybe set elsewhere used for defaults
			# TODO: Remove from here, to be initialized by the environment.

      reset_timeout

      @test_object_cache = {}
      @inside_verify = false
		end

		#TODO: Team TE review @ Wheels
		# Function to set timeout for TestObjectFactory
		# This should be used only in unit testing, otherwise should not be used
		# sets timeout used in identifying TestObjects to new timeout
		#
		# == params
		# new_timeout:: Fixnum which defines the new timeout
		# == raises
		# ArgumentError:: if parameter is not kind of Fixnum
		def timeout=( value )

			Kernel::raise ArgumentError.new( "Value for timeout should be of numeric. It was %s" % [ value.class ] ) unless value.kind_of?( Numeric )

			@timeout = value

		end

		def set_timeout( new_timeout )

			warn( "Deprecated method: use timeout=(value) instead of TestObjectFactory#set_timeout( value )" )

			self.timeout = new_timeout

		end

		# Function gets the timeout used in TestObjectFactory
		#
		# === returns
		# Numeric:: Timeout
		def get_timeout

			warn( "Deprecated method: use timeout instead of TestObjectFactory#get_timeout" )

			@timeout

		end

		#TODO: Team TE review @ Engine
		# Function to reset timeout to default
		# This is needed, as TOFactory is singleton.
		# == params
		# --
		# == returns
		# --
		# == raises
		# --
		def reset_timeout()

			@timeout = MobyUtil::Parameter[ :application_synchronization_timeout, "20" ].to_i
			@_retry_interval = MobyUtil::Parameter[ :application_synchronization_retry_interval, "1" ].to_i

		end

		#TODO: update documetation
		# Function to make a test object.
		# Queries from the sut an xml dump which is used to generate TestObjects.
		# Once XML dump is retrieved, a TestObject is identified by the TestObjectIdentificator.
		# TestObject is populated with data and activated.
		# The behaviour is added, as described in BehaviourGenerator#apply_behaviour
		# Lastly the created TestObject instance is associated to the SUT and vice versa.
		#
		# TODO: proper synchronization
		# 
		# == params
		# sut:: SUT object with which the new test object is to be associated 
		# test_object_identificator:: TestObjectIdentificator which is used to identify the required test object from the xml data
		# == returns
		# TestObject new, initialized and ready to use test object with associated data and behaviours
		# == raises, as defined in TestObjectIdentificator
		# ArgumentError:: if test_object_identificator is not of type LibXML::XML::Node,
		# MultipleTestObjectsIdentifiedError:: if multiple TestObjects can be identified using the test_object_identificator
		# TestObjectNotFoundError:: if no TestObjects are identified using the test_object_identificator
		def make( sut, test_object_identificator )

			test_object = make_test_object( 
				self, 
				sut, 
				sut, 
				_make_xml( sut, test_object_identificator ) 
			)

			sut.add_child( test_object )

			test_object

		end

		# Function for dynamically creating methods for accessing child objects of a test object 
		# == params
		# test_object:: test_object where access methods should be added
		# == returns
		# test_object:: test_object with added access methods
		def create_child_accessors!( test_object )

			created_accessors = []

			test_object.xml_data.xpath( 'objects/object' ).each{ | objectElement |

				objectElement.attribute( "type" ).tap{ | objType |

					unless created_accessors.include? objType then

						test_object.instance_eval(

							"def %s( rules={} ); raise TypeError, 'parameter <rules> should be hash' unless rules.kind_of?( Hash ); rules[:type] = :%s; child( rules ); end;" % [ objType, objType ]


						)

						created_accessors << objType

					end

				}

			}

		end

		# Function for making a child test object (a test object that is not directly a accessible from the sut) 
		# Creates accessors for children of the new object, applies any behaviours applicable for its type. 
		# Does not associate child object to parent / vice versa - leaves that to the client. 
		#
		# == params
		# parent_test_object:: TestObject thas is the parent of the child object being created 
		# test_object_identificator:: TestObjectIdentificator which is used to identify the child object from the xml data
		# == returns
		# TestObject:: new child test object, could be eql? to an existing TO
		# == raises
		# == raises, as defined in TestObjectIdentificator
		# ArgumentError:: if test_object_identificator is not of type LibXML::XML::Node,
		# MultipleTestObjectsIdentifiedError:: if multiple TestObjects can be identified using the test_object_identificator
		# TestObjectNotFoundError:: The TestObject cannot be found or the parent object is no longer visible on the SUT
		def make_child( parent_test_object, test_object_identificator )

			identified_object_xml = nil
			
			layout_direction = nil

			MobyUtil::Retryable.until( 
				:timeout => @timeout, 
				:interval => @_retry_interval,
				:exception => [ MobyBase::TestObjectNotFoundError, MobyBase::MultipleTestObjectsIdentifiedError ] ) {
				
				parent_test_object.refresh( :id => parent_test_object.get_application_id )

				if test_object_identificator.dynamic_attributes.include?( :__xy_sorting )

					begin

						layout_direction = parent_test_object.sut.application( :id => parent_test_object.get_application_id ).attribute("layoutDirection")

					rescue MobyBase::AttributeNotFoundError

						layout_direction = nil

					end
	
				end

				identified_object_xml = test_object_identificator.find_object_data( parent_test_object.xml_data, layout_direction )

			}


			make_test_object( 
				self, 
				parent_test_object.sut, 
				parent_test_object, 
				identified_object_xml 
			)

		end


		# Same as def make_child, but creates an array of test objects 
		# == params
		# parent_test_object:: TestObject thas is the parent of the child object being created 
		# test_object_identificator:: TestObjectIdentificator which is used to identify the child object from the xml data
		#find_all_children:: Boolean specifying whether all children under the test node or just immediate children should be retreived.
		# == returns
		# An array of Test Objects.
		# == raises
		# == raises, as defined in TestObjectIdentificator
		# ArgumentError:: if test_object_identificator is not of type LibXML::XML::Node,
		# TestObjectNotFoundError:: The TestObject cannot be found or the parent object is no longer visible on the SUT
		def make_multiple_children( parent_test_object, test_object_identificator, find_all_children)

			identified_object_xml = Array.new

			ret_array = Array.new

			layout_direction = nil

			begin

				MobyUtil::Retryable.until( 
					:timeout => @timeout, 
					:interval => @_retry_interval,
					:exception => [ MobyBase::TestObjectNotFoundError ] ) {

					parent_test_object.refresh( :id => parent_test_object.get_application_id )

					if test_object_identificator.dynamic_attributes.include?( :__xy_sorting )

						begin

							layout_direction = parent_test_object.sut.application( :id => parent_test_object.get_application_id ).attribute("layoutDirection")

						rescue MobyBase::AttributeNotFoundError

							layout_direction = nil

						end

					end

					identified_object_xml = test_object_identificator.find_multiple_object_data( parent_test_object.xml_data, find_all_children, layout_direction )

				}

				rescue MobyBase::TestObjectNotFoundError

					Kernel::raise MobyBase::TestObjectNotFoundError.new(
						"The parent test object was no available on the SUT.\n" <<
						"Expected object type: '#{ parent_test_object.type }' id: '#{ parent_test_object.id }'" 
					)

				end

				identified_object_xml.each do |child_xml|

				ret_array << make_test_object( self, parent_test_object.sut, parent_test_object, child_xml )

			end

			ret_array

		end

	private

		def make_test_object( test_object_factory, sut, parent, xml_object )
 
			# retrieve test object type from xml
			object_type = xml_object.kind_of?( MobyUtil::XML::Element ) ? xml_object.attribute( 'type' ) : nil
      
#			if !@test_object_cache.has_key?( object_type )

				test_object = MobyBase::TestObject.new( test_object_factory, sut, parent, xml_object )

				# apply behaviours to test object
				test_object.extend( MobyBehaviour::ObjectBehaviourComposition )

				# apply behaviours to test object
				test_object.apply_behaviour!( 
					:object_type => [ '*', object_type ], 
					:sut_type => [ '*', sut.ui_type ], 
					:input_type => [ '*', sut.input.to_s ], 
					:version => [ '*', sut.ui_version ] 
				)
=begin
Removed object cache usage
				# now test object has all required behaviours, store it to cache
				@test_object_cache[ object_type ] = test_object.clone

			else


				# retreieve test object with behaviours from cache and clone it
				( test_object = @test_object_cache[ object_type ].clone ).instance_exec{

					@test_object_factory = test_object_factory
					@sut = sut
					@parent = parent
					self.xml_data = xml_object

				}

			end
=end
			create_child_accessors!( test_object )

      # do not make test object verifications if we are operating on the 
      # base sut itself (allow run to pass)
      verify_ui_dump(sut) unless parent.kind_of? MobyBase::SUT

			test_object

		end


    def verify_ui_dump(sut)
      return if @inside_verify
      begin
        @inside_verify = true
        
        logging_enabled = MobyUtil::Logger.instance.enabled
        
        sut.verify_blocks.each do |verify|
          begin
            MobyUtil::Logger.instance.enabled = false
            begin
              result = verify.block.call(sut)
            rescue Exception => e
              error_msg = "Verification failed as an exception was thrown when the verification block was executed."
              error_msg << verify.source
              error_msg << "\nDetails: " << verify.message unless verify.message.nil?
              error_msg << "\nNested exception:\n" << e.inspect
              raise MobyBase::ContinuousVerificationError.new(error_msg)
            end
            error_msg = "Verification failed."
            error_msg << verify.source
            error_msg << "\nDetails: " << verify.message unless verify.message.nil?
            error_msg << "\nThe block did not return #{verify.expected.inspect}. It returned: " << result.inspect            
            raise MobyBase::ContinuousVerificationError.new(error_msg) unless result == verify.expected



          rescue Exception => e

            MobyUtil::Logger.instance.enabled = logging_enabled
            MobyUtil::Logger.instance.log "behaviour" , "FAIL;Verification #{verify.message.nil? ? '' : '\"' << verify.message << '\" '}failed:#{e.to_s}.\n#{verify.timeout.nil? ? '' : ' using timeout ' + verify.timeout.to_s}.;#{sut.id.to_s+';sut'};{};verify_always;" << verify.expected.to_s
            @inside_verify = false      
            Kernel::raise e
          end

          # Do NOT report PASS cases, like other verify blocks do. This would clog the log with useless info.
          
        end
      ensure
        @inside_verify = false      
      end
    end


		# Function to get the xml element for a test object
		# TODO: Remove TestObjectFactory::makeXML function & refactor the 'user' of this function!
		def _make_xml( sut, test_object_identificator )

			attributes = test_object_identificator.get_identification_rules

			refresh_args = ( attributes[ :type ] == 'application' ? { :name => attributes[ :name ], :id => attributes[ :id ] } : { :id => sut.current_application_id } )

			MobyUtil::Retryable.until(

				:timeout => @timeout, :interval => @_retry_interval, :exception => MobyBase::TestObjectNotFoundError ) { 
        
				sut.refresh( refresh_args ); test_object_identificator.find_object_data( sut.xml_data )

			}

		end





		# enable hooking for performance measurement & debug logging
		MobyUtil::Hooking.instance.hook_methods( self ) if defined?( MobyUtil::Hooking )

	end # TestObjectFactory

end # MobyBase
