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

  # TODO: document BehaviourFactory class
  class BehaviourFactory

  include Singleton
  
  def initialize

    @@behaviours = []
    @@behaviours_cache = {}
    @@modules_cache = {}

    @@plugin_cache = []
    
    # behaviour xml files path
    @@path = File.join( MobyUtil::FileHelper.tdriver_home, '/behaviours/*.xml' )

    parse_behaviour_files( 

      load_behaviours( @@path ) 

    )

  end

  public

  def to_xml( rules = {} ) 

    @_method_index = nil

    rules.default = [ '*' ]

    rules.each_pair{ | key, value |

    rules[ key ] = [ value ] if value.kind_of?( String )

    }

    MobyUtil::XML.build{

    behaviours{

      @@behaviours.each_index{ | index |

      @_method_index = index

      behaviour = @@behaviours[ @_method_index ]

      if ( ( rules[ :name ] == behaviour[ :name ] ) ||  

        ( rules[ :name ] == [ '*' ] ) &&

#        ( !( rules[ :sut_type ] & behaviour[ :sut_type ] ).empty? ) && 
        ( !( rules[ :input_type ] & behaviour[ :input_type ] ).empty? ) && 
        ( !( rules[ :object_type ] & behaviour[ :object_type ] ).empty? ) && 
        ( !( rules[ :version ] & behaviour[ :version ] ).empty? )

        ) 

        behaviour( :name => @@behaviours[ @_method_index ][ :name ], :object_type => @@behaviours[ @_method_index ][ :object_type ].join(";") ){ 
        object_methods{
          @@behaviours[ @_method_index ][ :methods ].each { | key, value |
          object_method( :name => key.to_s ) {  
            description( value[:description] )
            example( value[:example] )
          }
          }
        }
        }

      end

      }

    }

    }.to_xml

  end

  def get_behaviour_at_index( index )

    result = @@behaviours[ index ]

    if result.nil? 

    Kernel::raise RuntimeError.new( "No behaviour at index #{ index }" )

    else

    result

    end

  end
  
  # TODO: document me
  def reset_modules_cache
  
    # reset modules cache hash; needed if new behaviour plugins loaded later than when initializing TDriver/SUT
    @@modules_cache.clear
  
  end

  def apply_behaviour!( rules = {} )

    # merge user-defined rules on top of default rules set
    #rules = { :sut_type => ['*'], :object_type => ['*'], :input_type => ['*'], :version => ['*'] }.merge!( rules )

    raise ArgumentError, 'Target object not defined in rules hash' if rules[ :object ].nil?      

    rules.default = ['*']

    # retrieve enabled plugins from PluginService
    enabled_plugins = TDriver::PluginService.enabled_plugins 

    # apply behaviours to target object
    get_object_behaviours( rules ).each{ | behaviour_index |

      behaviour_data = @@behaviours[ behaviour_index ]

      # skip if required plugin is not registered or enabled; compare requires array and enabled_plugins array
      next unless ( behaviour_data[ :requires ] - enabled_plugins ).empty?

      begin

        # retrieve behaviour module from cache and extend target object
        rules[ :object ].extend( 

          @@modules_cache.fetch( behaviour_data[ :module ][ :name ] ){ | name |                  

            # ... or store to cache for the next time if not found 
            @@modules_cache[ name ] = MobyUtil::KernelHelper.get_constant( name )

          } 

        )

      rescue NameError

        raise NameError, "Implementation for behaviour #{ behaviour_data[ :name ] } does not exist. (#{ behaviour_data[ :module ][ :name ] })"


      rescue

        raise RuntimeError, "Error while applying #{ behaviour_data[ :name ] } (#{ behaviour_data[ :module ][ :name ] }) behaviour to target object. Reason: #{ $!.message } (#{ $!.class })"

      end

      # add behaviour information to test object
      rules[ :object ].instance_exec{ 

        @object_behaviours.push( behaviour_index ) unless @object_behaviours.include?( behaviour_index )

      }

    }

  end

  private

  def load_behaviours( behaviour_files )

    behaviours_data = []

    @file_name = ""

    begin

    Dir.glob( behaviour_files ).each{ | behaviour | 

      @file_name = behaviour

      behaviours_data << { :filename => @file_name, :xml => MobyUtil::FileHelper.get_file( @file_name ) }

    }

    rescue MobyUtil::EmptyFilenameError

    Kernel::raise EmptyFilenameError.new( "Unable to load behaviours xml file due to filename is empty or nil" )

    rescue MobyUtil::FileNotFoundError => ex

    Kernel::raise ex

    rescue IOError => ex

    Kernel::raise IOError.new("Error occured while loading behaviours xml file %s. Reason: %s" % [ @file_name, ex.message ] )

    rescue => ex

    Kernel::raise RuntimeError.new( "Error occured while parsing behaviours xml file %s. Reason: %s (%s)" % [ @file_name, ex.message, ex.class ] )

    end

    behaviours_data

  end

  def parse_behaviour_files( behaviour_files )

    behaviour_files.each{ | behaviours | 

    begin

      # skip parsing the xml if string is empty
      next if behaviours[ :xml ].empty?

      # parse behaviour xml
      document = MobyUtil::XML.parse_string( behaviours[ :xml ] )

    rescue => exception

      Kernel::raise MobyUtil::XML::ParseError.new( 
                            "Error occured while parsing behaviour XML file %s. Error: %s " % [ behaviours[ :filename ], exception.message ] 
                            ) 

    end

    # retrieve root attributes
    root_attributes = document.root.xpath( "/behaviours" ).first.attributes

    # parse retrieve behaviour definitions
    document.root.xpath( "/behaviours/behaviour" ).each{ | node |

      # retrieve behaviour attributes & module node
      attributes = node.attributes

      name = attributes[ "name" ].to_s
      object_type = attributes[ "object_type" ].to_s
      input_type = attributes[ "input_type" ].to_s
      sut_type = attributes[ "sut_type" ].to_s
      version = attributes[ "version" ].to_s

      env = ( attributes[ "env" ] || '*' ).to_s 

      module_node = node.xpath( 'module' ).first
      
      name = attributes[ "name" ].to_s
      object_type = attributes[ "object_type" ].to_s
      input_type = attributes[ "input_type" ].to_s
      sut_type = attributes[ "sut_type" ].to_s
      version = attributes[ "version" ].to_s
      
      # verify that all required attributes and nodes are found in behaviour xml node
      #Kernel::raise RuntimeError.new("Behaviour does not have a name, please see behaviour XML files") if name.empty?
      name.not_empty("Behaviour element does not have name (name) attribute defined, please see behaviour XML files", RuntimeError)
      
      #Kernel::raise RuntimeError.new("Behaviour target object type not defined for #{ name } in XML") if object_type.empty?
      object_type.not_empty("Behaviour element does not have target object type (object_type) attribute defined, please see #{ name } in behaviour XML files", RuntimeError)

      #Kernel::raise RuntimeError.new("Behaviour target object input type not defined for #{ name } in XML") if input_type.empty?
      input_type.not_empty("Behaviour element does not have target object input type (input_type) attribute defined, please see #{ name } in behaviour XML files", RuntimeError)

      #Kernel::raise RuntimeError.new("Behaviour target object sut type not defined for #{ name } in XML") if sut_type.empty?
      sut_type.not_empty("Behaviour element does not have target object sut type (sut_type) attribute defined, please see #{ name } in behaviour XML files", RuntimeError)

      #Kernel::raise RuntimeError.new("Behaviour target object sut version not defined for #{ name } in XML") if version.empty?
      version.not_empty("Behaviour element does not have target object SUT version (version) attribute defined, please see #{ name } in behaviour XML files", RuntimeError)

      #Kernel::raise RuntimeError.new("Behaviour implementation module not defined for #{ name } in XML") if module_node.nil?
      module_node.not_nil("Behaviour does not have implementation module element defined, please see #{ name } in behaviour XML files", RuntimeError)
      
      # retrieve module name & implementation filename
      module_attributes = module_node.attributes
      module_file = module_attributes[ "file" ].to_s # optional
      module_name = module_attributes[ "name" ].to_s 
      
      #Kernel::raise RuntimeError.new( "Behaviour implementation module name not defined for #{ name } in XML") if module_name.empty?
      module_name.not_empty("Behaviour does not have implementation module name defined, please see #{ name } in behaviour XML files", RuntimeError)

      methods_hash = {}

      # create hash of methods
      node.xpath( 'methods/method' ).each{ | method |

        # retrieve method description & example and store to methods hash
        methods_hash[ method.attribute( "name" ).to_s.to_sym ] = {

          :description => method.at_xpath( 'description/text()' ).to_s, 

          :example     => method.at_xpath( 'example/text()' ).to_s

        }

      }

      # create and store beahaviour hash
      @@behaviours << {

      :name => name,
      :requires => root_attributes[ "plugin" ].to_s.split(";"),
      :object_type => object_type.split(";"),
      :input_type => input_type.split(";"),
#      :sut_type => sut_type.split(";"),
      :version => version.split(";"),
      :env => env.split(";"),

      :module => { 
        :file => module_file, 
        :name => module_name 
      },

      :methods => methods_hash

      }

    }

    }

  end

=begin
  def get_object_behaviours( rules )

    # calculate hash for behaviour rules / hash value will be used to identify similar objects
    behaviour_hash = Hash[ rules.select{ | key, value | key != :object  } ].hash

    if @@behaviours_cache.has_key?( behaviour_hash )

      # retrieve behaviour module indexes from cache
      @@behaviours_cache[ behaviour_hash ]

    else

      rules.default = [ '*' ]

      extended_modules = []

      @@behaviours.each_with_index{ | behaviour, index |

        if ( ( rules[ :name ] == behaviour[ :name ] ) || 

          ( rules[ :name ] == [ '*' ] && 

          #         ( !( rules[ :sut_type ] & behaviour[ :sut_type ] ).empty? ) && 
          ( !( rules[ :object_type ] & behaviour[ :object_type ] ).empty? ) &&
          ( !( rules[ :input_type ] & behaviour[ :input_type ] ).empty? ) &&
          ( !( rules[ :env ] & behaviour[ :env ] ).empty? ) &&
          ( !( rules[ :version ] & behaviour[ :version ] ).empty? ) ) )

          # retrieve list of extended modules
          extended_modules << index

        end

      }

      # store behaviour module indexes to cache
      @@behaviours_cache[ behaviour_hash ] = extended_modules

    end

  end
=end

  def get_object_behaviours( rule )

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

  end


  def get_behaviour_from_cache( target, sut_type, object_type, sut_version, input_type )

    if @_behaviour_cache.has_key?( object_type )

    # apply modules to target object
    @_behaviour_cache[ object_type ].each{ | module_name | target.instance_eval( "self.extend(#{ module_name })" ) }

    # return true
    true

    else
    # return false
    false
    end

  end

  # enable hooking for performance measurement & debug logging
  TDriver::Hooking.hook_methods( self ) if defined?( TDriver::Hooking )

  end # BehaviourGenerator

end # MobyBase
