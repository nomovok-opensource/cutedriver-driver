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

module TDriver
  
  class TestObjectFactory

    attr_accessor :timeout, :retry_interval, :test_object_adapter

    def initialize( test_object_adapter )
    
      #@timeout = 5
      
      #@retry_interval = 1
    
      @test_object_adapter = test_object_adapter
    
      @timeout = MobyUtil::Parameter[ :synchronization_timeout, "20" ].to_f

      @retry_interval = MobyUtil::Parameter[ :synchronization_retry_interval, "1" ].to_f
                
    end # initialize
        
    def get_objects( source_data, rules, &block )
  
      # __multiple_objects
      # __all_children
      #

      #TDriver::TestObjectIdentificator.new( creation_hash )
      # {:type=>"application", :name=>"calculator"}

      test_object_attributes = rules[ :attributes ]

      dynamic_attributes = strip_dynamic_attributes!( test_object_attributes )

      # add keys from rules to dynamic attribute filter list -- to avoid IRB bug
      MobyUtil::DynamicAttributeFilter.instance.add_attributes( rules.keys )

      #p dynamic_attributes
      #p rules

      refresh = false

      MobyUtil::Retryable.until( 
      
        :timeout   => @timeout, 
        :interval  => @retry_interval,
        :exception => [ MobyBase::TestObjectNotFoundError, MobyBase::MultipleTestObjectsIdentifiedError ] 

      ){

        # refresh source data if refresh flag is set to true
        source_data = yield( source_data ) if refresh

        # set refresh flag to true 
        refresh = true    

        matches, rule = @test_object_adapter.get_objects( source_data, test_object_attributes )
   
        # create string representation of hash merged with and dynamic attributes 
        rules_string = test_object_attributes.merge( dynamic_attributes ).inspect
                
        # raise exception if multiple matches found
        Kernel::raise MobyBase::MultipleTestObjectsIdentifiedError.new(
        
          "Multiple test objects found with rule: #{ rules_string }"
          
        ) if !dynamic_attributes.has_key?( :__index ) and (!( rules[ :multiple_objects ] || false ) and matches.size > 1)
        
        # raise exception if no matches found
			  Kernel::raise MobyBase::TestObjectNotFoundError.new(
			   
			    "Cannot find object with rule: #{ rules_string }"
			    
		    ) if matches.size.zero?

        # ... or proceed if no exceptions raised  

        # sort elements if required by caller
        # @test_object_adapter.sort_elements....

        # return only one element if index given
        matches = [ matches[ dynamic_attributes[ :__index ] ] ] if dynamic_attributes.has_key?( :__index )
        
        # return array of matching test object(s)
        make_test_objects( matches, rules )

      }
      
    end # get_objects

  private

    def make_test_objects( matches, rules )

      #p rules
    
      sut = rules[ :sut ]
    
      # return array of matching test object(s)
      matches.collect{ | source_data |
                
        # get test object type from xml
        object_type = @test_object_adapter.test_object_attribute( 'type', source_data )

        # create new test object instance
        test_object = MobyBase::TestObject.new( 

          # test object factory
          self,             

          # associated sut
          sut,    

          # associated parent object; either test object, application or sut
          rules[ :parent_object ], 

          # test object xml data
          source_data
          
        )

        # apply object composition behaviour to test object
        test_object.extend( MobyBehaviour::ObjectBehaviourComposition )
        
        # TODO: behaviours should be applied by using BehaviourFactory directly 
        # apply behaviours to test object
        test_object.apply_behaviour!(
          :object_type  => [ '*', object_type ],
          :sut_type     => [ '*', sut.ui_type ],
          :input_type   => [ '*', sut.input.to_s ],
          :version      => [ '*', sut.ui_version ]
        )
        
        # create child accessors
        @test_object_adapter.create_child_accessors!( test_object, source_data )

        # TODO: call verification block if defined (verify_ui_dump)
        
#      # do not make test object verifications if we are operating on the 
#      # base sut itself (allow run to pass)
#      unless parent.kind_of?( MobyBase::SUT )
#       verify_ui_dump( sut ) unless sut.verify_blocks.empty?
#      end

        # pass test object with behaviours as result
        test_object
        
      }
    
    end # make_test_objects

    def strip_dynamic_attributes!( hash )

      # remove dynamic attributes from hash and return as result     
      Hash[ 

        # iterate through each hash key
        hash.select{ | key, value | 

          # dynamic attribute name has "__" prefix
          if key.to_s =~ /^__/ 

            # remove dynamic attribute key from hash
            hash.delete( key )

            # add to hash
            true

          else

            # do not add to hash
            false

          end

        } 

      ]

    end # strip_dynamic_attributes!
   
  end # TestObjectFactory

end # TDriver
