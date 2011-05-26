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

#require 'lib/tdriver'

module TDriver

  class Behaviour

    def initialize( values )

      # add each hash pair as class instance attribute    
      values.each_pair do | key, value |

        # cast to string; might need additional verification for invalid characters
        key = key.to_s

        # add attribute reader for hash key 
        eval <<-CODE 
        
          # add attribute reader     
          class << self; attr_reader :#{ key }; end

          # set value
          @#{ key } = #{ value.inspect };
          
        CODE
      
      end
    
    end

    def method_missing( name, *args )
    
      nil
    
    end
    
    def applies_to?( rule )

      rule.default = [ '*' ]
      
      case rule[ :name ]
      
        when @name
        
          true
        
        when ['*'] 
          
          !( rule[ :object_type ] & @object_type ).empty? && 
          !( rule[ :input_type ] & @input_type ).empty? &&
          !( rule[ :env ] & @env ).empty? && 
          !( rule[ :version ] & @version ).empty? 

        else
        
          false

      end      

=begin
      # calculate hash for behaviour rule / hash value will be used to identify similar objects
      @@behaviours_cache.fetch( rule.delete_keys( :object ).hash ){ | behaviour_hash |

        rule.default = [ '*' ]

        @@behaviours_cache[ behaviour_hash ] = @@behaviours.each_with_index.collect{ | behaviour, index |

          case rule[ :name ]

            when behaviour[ :name ]

              index

            when [ '*' ]

              index if ( 
                !( rule[ :object_type ] & behaviour[ :object_type ] ).empty? && 
                !( rule[ :input_type ] & behaviour[ :input_type ] ).empty? &&
                !( rule[ :env ] & behaviour[ :env ] ).empty? && 
                !( rule[ :version ] & behaviour[ :version ] ).empty? 
              )

          else

            nil

          end

        }.compact

      }
=end

    end
  
  end

  class BehaviourFactory
  
    class << self

    public

      # initialize behaviours factory
      def init( options )

        load_behaviours( 
        
          options[ :path ] 
          
        )

      end
      
      # reset class configuration
      def reset

        # reset default values
        initialize_class      
      
      end

      def collect_behaviours( rule )

        cache_key = rule.reject{ | key, value | key == :object }

        if @behaviours_cache.has_key?( cache_key )
        
          @behaviours_cache[ cache_key ]
        
        else
        
          # retrieve enabled plugins from PluginService
          enabled_plugins = TDriver::PluginService.enabled_plugins 

          @behaviours_cache[ cache_key ] = @behaviours.select do | behaviour |

            # skip if required plugin is not registered or enabled; compare requires array and enabled_plugins array
            next unless ( behaviour[ 'requires' ] - enabled_plugins ).empty?

            rule.default = [ '*' ]
            
            case rule[ :name ]
            
              when @name
              
                # exact match with name
                true
              
              when ['*'] 
   
                # compare rules and behaviour attributes             
                !( rule[ :object_type ] & behaviour[ 'object_type' ] ).empty? && 
                !( rule[ :input_type ] & behaviour[ 'input_type' ] ).empty? &&
                !( rule[ :env ] & behaviour[ 'env' ] ).empty? && 
                !( rule[ :version ] & behaviour[ 'version' ] ).empty? 

              else
              
                false

            end

          end

        end
      
      end

      def apply_behaviour( rule )
        
        collected_indexes = [] 
        
        #?? rule[ :object ].instance_variable_get( :@object_behaviours )
        
        collect_behaviours( rule ).each do | behaviour |

          begin
        
            # retrieve behaviour module
            behaviour[ 'module' ] = MobyUtil::KernelHelper.get_constant( behaviour[ 'module' ].to_s ) unless behaviour[ 'module' ].kind_of?( Module )

            # extend target object with behaviour module
            rule[ :object ].extend( behaviour[ 'module' ] )

            # store behaviour indexes
            collected_indexes << behaviour[ 'index' ]

          rescue NameError

            raise NameError, "Implementation for #{ behaviour[ 'name' ] } behaviour does not exist. (#{ behaviour[ 'module' ] })"
          
          rescue
          
            raise RuntimeError, "Error while applying #{ behaviour[ 'name' ] } (#{ behaviour[ 'module' ] }) behaviour to target object due to #{ $!.message } (#{ $!.class })"
          
          end

        
        end

        unless rule[ :object ].instance_variable_defined?( :@object_behaviours )

          # set behaviour indexes to test object
          rule[ :object ].instance_variable_set( :@object_behaviours, collected_indexes )
        
        else
        
          # add behaviour indexes to test object
          rule[ :object ].instance_variable_get( :@object_behaviours ).tap{ | indexes | indexes = indexes | collected_indexes }

        end

        
                  
=begin     
        # retrieve enabled plugins from PluginService
        enabled_plugins = TDriver::PluginService.enabled_plugins 

        @behaviours.each_with_index{ | behaviour, index |
        
          # skip if required plugin is not registered or enabled; compare requires array and enabled_plugins array
          next unless ( behaviour.requires - enabled_plugins ).empty?
        
          if behaviour.applies_to?( rule )
            
            begin
                                     
             behaviour_module = behaviour.module
                                     
              # retrieve behaviour module
              if behaviour_module.kind_of?( String )
                behaviour_module = behaviour.instance_variable_set(:@module, MobyUtil::KernelHelper.get_constant( behaviour.module )) 
              end

              # extend target object with behaviour module
              rule[ :object ].extend( behaviour_module )
          
            rescue NameError

              raise NameError, "Implementation for #{ behaviour.name } behaviour does not exist. (#{ behaviour.module })"
            
            rescue
            
              raise RuntimeError, "Error while applying #{ behaviour.name } (#{ behaviour.module }) behaviour to target object due to #{ $!.message } (#{ $!.class })"
            
            end

# new
#MobyBase::BehaviourFactory::apply_behaviour!                                          631      2.25980600      2.21837500    3.178%      0.00358131

# old
#MobyBase::BehaviourFactory::apply_behaviour!                                          631      2.27668800      2.23749700    3.178%      0.00360806
#MobyBase::BehaviourFactory::apply_behaviour!                                          631      0.87363100      0.77245300    1.131%      0.00138452
#MobyBase::BehaviourFactory::apply_behaviour!                                          631      0.51659900      0.48817000    0.720%      0.00081870
#MobyBase::BehaviourFactory::apply_behaviour!                                          631      0.73310700      0.70426600    1.030%      0.00116182
#MobyBase::BehaviourFactory::apply_behaviour!                                          631      0.58667000      0.55826300    0.824%      0.00092975

#=begin           
            # add behaviour information to test object
            rule[ :object ].instance_variable_get( :@object_behaviours ).tap{ | indexes |
            
              indexes.push( index ) unless indexes.include?( index )
            
            }
#=end
      
            # add behaviour information to test object
            indexes = rule[ :object ].instance_variable_get( :@object_behaviours )

            indexes.push( index ) unless indexes.include?( index )
              
          end # if applies.to?
          
        }
=end
      
      end

    private
      
      # private methods and variables
      def initialize_class

        # behaviours container
        @behaviours = []
        
        @behaviours_cache = {}
            
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
              behaviours.xpath( 'behaviour' ).each do | behaviour |

                # retrieve behaviour attributes - set default values if not found from element
                attributes = behaviour.attributes.default_values(
                  "name"        => '', 
                  "object_type" => '', 
                  "input_type"  => '', 
                  "sut_type"    => '', 
                  "version"     => '',
                  "env"         => '*'
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
                #@behaviours << Behaviour.new( 

                # store behaviour 
                @behaviours << { #Behaviour.new( 

                  "index"       => @behaviours.count,
    
                  "name"        => attributes[ 'name'        ],
                  "object_type" => attributes[ 'object_type' ].split(';'),
                  "input_type"  => attributes[ 'input_type'  ].split(';'),
                  "version"     => attributes[ 'version'     ].split(';'),
                  "env"         => attributes[ 'env'         ].split(';'),

                  "requires"    => root_attributes[ 'plugin' ].to_s.split(';'),

                  "module"      => module_name,
                  "file"        => behaviour.at_xpath( 'module/text()' ).to_s, # optional 
                  
                  "methods"     => Hash[ 
                    # collect method details from behaviour 
                    behaviour.xpath( 'methods/method' ).collect{ | method |                
                      [ 
                        method.attribute('name'),
                        {
                          "description" => method.at_xpath( 'description/text()' ).to_s,
                          "example" => method.at_xpath( 'example/text()' ).to_s
                        }
                      ]                  
                    }
                  ]
                
                }
                
                # )

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

  end
  
end
