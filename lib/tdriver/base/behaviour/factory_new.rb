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

  class BehaviourFactory
  
    class << self

    public

      # initialize behaviours factory
      def init( options )

        # verify that argument is type of hash
        options.check_type Hash, 'wrong argument type $1 for TDriver::BehaviourFactory#init options argument (expected $2)'

        # load behaviour configuration files
        load_behaviours( 

          options.require_key( :path, 'required key $1 not found from TDriver::BehaviourFactory#init options argument' )
          
        )

      end
      
      # reset class configuration
      def reset

        # reset default values
        initialize_class      
      
      end

      # TODO: document me
      def apply_behaviour( rule )
        
        # verify that rule is given as hash
        rule.check_type Hash, 'wrong argument type $1 for TDriver::BehaviourFactory#apply_behaviour rule argument (expected $2)'

        # empty collected indexes variable
        collected_indexes = [] 
        
        # retrieve object from hash
        _object = rule[ :object ]

        # generate cache key, drop :object value from hash
        cache_key = rule.reject{ | key, value | key == :object }.to_s.hash

        # retrieve behaviour from cache if found
        if @behaviours_cache.has_key?( cache_key )
        
          behaviours = @behaviours_cache[ cache_key ]
        
        else

          # add each collected behaviour to object
          behaviours = collect_behaviours( rule )

          # store to cache
          @behaviours_cache[ cache_key ] = behaviours

        end

        # iterate through each collected behaviour 
        behaviours.each do | behaviour |

          begin
        
            # retrieve module from hash
            _module = behaviour[ :module ]

            unless _module.kind_of?( Module )

              # retrieve behaviour module
              _module = MobyUtil::KernelHelper.get_constant( _module.to_s ) 

              # store pointer to module (implementation) back to hash
              behaviour[ :module ] = _module

            end

            # extend target object with behaviour module
            _object.extend( _module )

            # store behaviour indexes
            collected_indexes << behaviour[ :index ]

          rescue NameError

            raise NameError, "Implementation for #{ behaviour[ :name ] } behaviour does not exist. (#{ _module })"
          
          rescue
          
            raise RuntimeError, "Error while applying #{ behaviour[ :name ] } (#{ _module }) behaviour to target object due to #{ $!.message } (#{ $!.class })"
          
          end
        
        end # behaviours.each

        # retrieve objects behaviour index array if already set
        collected_indexes = _object.instance_variable_get( :@object_behaviours ) | collected_indexes if _object.instance_variable_defined?( :@object_behaviours )

        # add behaviour information to test object
        _object.instance_variable_set( :@object_behaviours, collected_indexes )
      
      end

    private
      
      # private methods and variables
      def initialize_class

        # behaviours container
        @behaviours = []
        
        # behaviour cache; re-collecting behaviours is not required for similar target objects
        @behaviours_cache = {}
            
      end

      # TODO: document me
      def collect_behaviours( rule )

        # default value for rule if not defined
        rule.default = [ '*' ]

        # retrieve enabled plugins from PluginService
        enabled_plugins = TDriver::PluginService.enabled_plugins 

        # store as local variable for less AST lookups
        _object_type  = rule[ :object_type  ]
        _input_type   = rule[ :input_type   ]
        _env          = rule[ :env          ]
        _version      = rule[ :version      ]

        @behaviours.select do | behaviour |

          # skip if required plugin is not registered or enabled; compare requires array and enabled_plugins array
          next unless ( behaviour[ :requires ] - enabled_plugins ).empty?
          
          case rule[ :name ]
          
            when behaviour[ :name ]
            
              # exact match with name
              true
            
            when ['*']

              # compare rules and behaviour attributes             
              !( _object_type & behaviour[ :object_type ] ).empty? && 
              !( _input_type  & behaviour[ :input_type  ] ).empty? &&
              !( _env         & behaviour[ :env         ] ).empty? && 
              !( _version     & behaviour[ :version     ] ).empty? 

          else
            
            false

          end

        end # behaviours.select
      
      end

      # load and parse behaviours files
      def load_behaviours( path )

        # behaviour xml files path
        Dir.glob( File.join( path, '*.xml' ) ){ | filename |
 
          begin
      
            # read file contents
            content = MobyUtil::FileHelper.get_file( filename )  
          
            # skip when empty file
            next if content.empty?
  
            # parse behaviour xml and process each behaviours element
            MobyUtil::XML.parse_string( content ).root.xpath( '/behaviours' ).each do | behaviours |

              # retrieve root attributes
              root_attributes = behaviours.attributes

              # process each behaviour element
              behaviours.xpath( './behaviour' ).each do | behaviour |

                # retrieve behaviour attributes - set default values if not found from element
                attributes = behaviour.attributes.default_values(
                  'name'        => '', 
                  'object_type' => '', 
                  'input_type'  => '', 
                  'sut_type'    => '', 
                  'version'     => '',
                  'env'         => '*'
                )

                # verify that behaviour attributes are not empty
                attributes.each_pair do | key, value |                  

                  value.not_empty "behaviour element attribute #{ key.inspect } is not defined or empty", RuntimeError

                end 

                # retrieve implementation/module name
                module_name = behaviour.at_xpath( 'module/@name' ).to_s

                # verify that module name is defined
                module_name.not_empty "behaviour #{ attributes[ "name" ].inspect } does not have module name defined or is empty", RuntimeError

                # store behaviour 
                @behaviours << {  

                  :index       => @behaviours.count,
    
                  :name        => attributes[ 'name'        ],
                  :object_type => attributes[ 'object_type' ].split(';'),
                  :input_type  => attributes[ 'input_type'  ].split(';'),
                  :version     => attributes[ 'version'     ].split(';'),
                  :env         => attributes[ 'env'         ].split(';'),

                  :requires    => root_attributes[ 'plugin' ].to_s.split(';'),

                  :module      => module_name,
                  :file        => behaviour.at_xpath( 'module/text()' ).to_s, # optional 
                  
                  :methods     => Hash[ 
                    # collect method details from behaviour 
                    behaviour.xpath( 'methods/method' ).collect{ | method |                
                      [ 
                        method.attribute( 'name' ),
                        {
                          :description => method.at_xpath( 'description/text()' ).to_s,
                          :example     => method.at_xpath( 'example/text()'     ).to_s
                        }
                      ]                  
                    }
                  ]
                
                }

              end # behaviour.each

            end # behaviours.each

          rescue MobyUtil::FileNotFoundError

            raise

          rescue MobyUtil::XML::ParseError
          
            raise MobyUtil::XML::ParseError, "Error while parsing behaviours file #{ behaviours[ :filename ] } due to #{ $!.message }"

          rescue

            raise RuntimeError, "Error while processing behaviours file #{ filename } due to #{ $!.message }"

          end
        
        } # Dir.glob
      
      end # behaviours
   
    end # self
   
    # initialize behaviour factory
    initialize_class

    # enable hooking for performance measurement & debug logging
    TDriver::Hooking.hook_methods( self ) if defined?( TDriver::Hooking )

  end # BehaviourFactory
  
end # TDriver
