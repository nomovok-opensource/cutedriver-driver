require 'nokogiri'

@feature_tests = []
@behaviour_hashes = {}
@behaviours = []

$modules_and_methods_tested = {}

def process_result_file( content )

  result = { "__file" => @current_file }

  doc = Nokogiri::XML::parse( content )

  # parse each element
  doc.root.children.each{ | child |

    if child.kind_of?( Nokogiri::XML::Element )

      case child.name.to_s

        when /^description$/i

          # collect description, remove empty lines, strip leading and trailing whitespaces, split lines
          result[ child.name.to_s ] = ( result[ child.name.to_s ] || [] ) + child.inner_text.split("\n").collect{ | value | value.empty? ? nil : value.strip }.compact

        when /^scenarios$/i
        
          scenarios = []

          # iterate through each scenario
          child.children.each{ | scenario | 

            scenario_data = {}

            scenario.children.each{ | data |

              if child.kind_of?( Nokogiri::XML::Element )

                scenario_data[ data.name.to_s ] = ( scenario_data[ data.name.to_s ] || [] ) + data.inner_text.split("\n").collect{ | value | value.empty? ? nil : value.strip }.compact

              end

            }

            scenarios << scenario_data

          }

          result[ child.name.to_s ] = scenarios

        when /^text$/i

          # skip any element inner texts

      else

        puts "Unknown element name: '#{ child.name.to_s }' in #{ @current_file }"

      end
      
    end

  }

=begin
  { result["description"].first => 

    result["scenarios"].collect{ | scenario |

      scenario["example_step"].collect{ | example |

        code = /\"(.*)\"/.match( example ).captures.first

        status = /^.*\s{1}(\w+)$/.match( example ).captures.first      

        { :example => code, :status => status.to_s.downcase }

      }

    }.flatten
  }
=end

  result

end

def process_behaviour_hash_file( content )

  eval( content )

end

def process_behaviour_file( content )

  # TODO: recursive method to parse documentation?

  doc = Nokogiri::XML::parse( content )

  behaviour_config = Hash[ doc.root.attributes.collect{ | attribute | [ attribute.first, attribute.last.value ] } ] # ] = attribute.last.value.split(";") }          

  result = { "behaviours" => [], "__config" => behaviour_config }

  # parse each element
  doc.root.children.select{ | node | node.kind_of?( Nokogiri::XML::Element ) }.each{ | child |

    case child.name.to_s

      when /^behaviour$/i

        # new behaviour hash
        behaviour = {}

        # get behaviour element attributes, e.g. behaviour name, input_type, sut_type etc
        child.attributes.each{ | attribute | behaviour[ attribute.first ] = attribute.last.value.split(";") }          

        # retrieve module & method definitions
        child.children.select{ | node | node.kind_of?( Nokogiri::XML::Element ) }.each{ | child |

          p# child.name

          case child.name.to_s

            when /^methods$/i

              methods = []

              # get method definitions                  
              child.children.select{ | node | node.kind_of?( Nokogiri::XML::Element ) }.each{ | child |

                method = {}

                # get behaviour element attributes, e.g. behaviour name, input_type, sut_type etc
                child.attributes.each{ | attribute | method[ attribute.first ] = attribute.last.value.split(";") }          

                # retrieve method details
                child.children.select{ | node | node.kind_of?( Nokogiri::XML::Element ) }.each{ | child |

                  case child.name.to_s

                    when /^description$/i, /^info$/i

                      # store description, info
                      method[ child.name.to_s ] = child.inner_text

                    when /^arguments$/i

                      arguments = []

                      child.children.select{ | node | node.kind_of?( Nokogiri::XML::Element ) }.each{ | child |

                        argument = { "types" => [] }

                        # get behaviour element attributes, e.g. behaviour name, input_type, sut_type etc
                        child.attributes.each{ | attribute | argument[ attribute.first ] = attribute.last.value.split(";") }

                        # get each argument details, e.g. type(s), default value etc
                        child.children.select{ | node | node.kind_of?( Nokogiri::XML::Element ) }.each{ | child |

                          case child.name.to_s

                            when /^default$/

                              argument[ child.name.to_s ] = child.inner_text.to_s

                            when /^type$/

                              argument[ "types" ] << Hash[ child.attribute("name").value, Hash[ child.children.select{ | node | node.kind_of?( Nokogiri::XML::Element ) }.collect{ | child | [ child.name, child.inner_text ] }  ] ]
                        
                          else

                            puts "Unknown element name: '#{ child.name.to_s }' in #{ @current_file }"

                          end

                        }

                        arguments << argument

                      }

                      method[ "arguments" ] = arguments

                    when /^returns$/i

                      returns = []

                      # get each argument details, e.g. type(s), default value etc
                      child.children.select{ | node | node.kind_of?( Nokogiri::XML::Element ) }.each{ | child |

                        case child.name.to_s

                          when /^type$/

                            returns << Hash[ child.attribute("name").value, Hash[ child.children.select{ | node | node.kind_of?( Nokogiri::XML::Element ) }.collect{ | child | [ child.name, child.inner_text ] }  ] ]
                      
                        else

                          puts "Unknown element name: '#{ child.name.to_s }' in #{ @current_file }"

                        end

                      }

                      method[ "returns" ] = returns

                    when /^exceptions$/i

                      exceptions = []

                      child.children.select{ | node | node.kind_of?( Nokogiri::XML::Element ) }.each{ | child |

                        case child.name.to_s

                          when /^exception$/

                            exceptions << Hash[ child.attribute("name").value, Hash[ child.children.select{ | node | node.kind_of?( Nokogiri::XML::Element ) }.collect{ | child | [ child.name, child.inner_text ] }  ] ]
                      
                        else

                          puts "Unknown element name: '#{ child.name.to_s }' in #{ @current_file }"

                        end

                      }

                      method[ "exceptions" ] = exceptions
  
                  # if element under methods node is unknown...
                  else

                    puts "Unknown element name: '#{ child.name.to_s }' in #{ @current_file }"

                  end

                }

                methods << method
                
              }

              behaviour[ "methods" ] = methods


            when /^module$/i

              behaviour[ child.name.to_s ] = child.attribute("name").value.split(";")

          else

            puts "Unknown element name: '#{ child.name.to_s }' in #{ @current_file }"

          end

        }

        result[ "behaviours" ] << behaviour

      when /^text$/i

        # skip any element inner texts

    else

      puts "Unknown element name: '#{ child.name.to_s }' in #{ @current_file }"

    end


  }

  result

end

def read_test_result_files

  feature_xml_folder = ARGV.first.to_s

  Dir.glob( File.join( feature_xml_folder, '*.xml' ) ).each{ | file |

    @current_file = file

    @feature_tests << process_result_file( open( file, 'r' ).read )

    #@feature_tests.merge!( process_result_file( open( file, 'r' ).read ) ) #{ :filename => file, :results => process_result_file( open( file, 'r' ).read ) }

  }

end

def read_behaviour_xml_files

  Dir.glob( 'behaviour_xml/*.xml' ).each{ | file |

    @current_file = file

    @behaviours << { :filename => file, :behaviours => process_behaviour_file( open( file, 'r' ).read ) }

  }

end

def read_behaviour_hash_files

  file = ARGV[1] || 'behaviour_xml/'

  Dir.glob( File.join( file, '*.hash' ) ).each{ | file |

    @current_file = file

    content = open( file, 'r' ).read

    # merge to results table
    process_behaviour_hash_file( open( file, 'r' ).read ).each_pair{ | key, value | 

      @behaviour_hashes[ key.to_s ] = ( @behaviour_hashes[ key.to_s ] || [] ) | value 

    }

  }

  abort "No behaviour XML files found from folder '#{ file }'" if @behaviour_hashes.empty?

end

def collect_all_features

  @behaviour_hashes.collect{ | module_name, methods |

    methods.collect{ | method |

     "%s#%s" % [ module_name, method ]

    }

  }.flatten

end

def collect_documented_features

  behaviours = {}

  @behaviours.each{ | behaviour |
  
    file_name = behaviour[ :filename ]

    behaviour_config = behaviour[:behaviours]["__config"] || {}
  
    behaviour[:behaviours]["behaviours"].each{ | behaviour |

      config = Hash[ behaviour.select{ | key, value | key != "methods" } ]
            
      # get module name
      module_name = behaviour["module"].first
      
      # list methods
      behaviour["methods"].each{ | method |
        
        method["name"].each{ | method_name |
                
          behaviours[ "%s#%s" % [ module_name, method_name ] ] = method.merge( "__file" => file_name, "__behaviour" => config.merge( behaviour_config ) )
          
        }
        
      }

    }
  
  }.flatten

  behaviours

end

def collect_feature_tests

  result = {}
  
  @feature_tests.collect{ | feature |

    result[ feature["description"].first ] = 

      feature["scenarios"].collect{ | scenario |

        scenario["example_step"].collect{ | example |

          code = /\"(.*)\"/.match( example ).captures.first

          status = /^.*\s{1}(\w+)$/.match( example ).captures.first      

          [ "example" => code, "status" => status.to_s.downcase ]

        }.flatten

      }.flatten
    

  }.flatten
  
  result

end

if ARGV.count < 1
  
  abort "\nUsage: #{ File.basename( $0 ) } feature_xml_folder [behaviour_xml_folder]\n\n"

end

read_test_result_files # ok
read_behaviour_xml_files # ok
read_behaviour_hash_files # ok

puts "", "----", ""
#puts "all executed feature tests:"
@executed_tests = collect_feature_tests

#puts ""
#puts "all available features:"
@all_features = collect_all_features

#puts ""
#puts "all documented features:"
@documented_features = collect_documented_features

accessors = []

doc = Nokogiri::XML::Builder.new{ | xml |

  #p doc.to_xml
  #p doc.to_xml
  #exit

  xml.documentation{

    # TODO: behaviour.hash should have feature type (method/attribute) mentioned  
    # TODO: behaviour.hash should have number of arguments incl. optional + blocks

    collect_all_features.sort.each{ | feature |
    
      module_name, method_name, feature_type, feature_parameters = feature.split("#")
      
      feature = "%s#%s" % [ module_name, method_name ]

      #feature_type = feature_data

      #p feature_data
      #sleep 0.3
      
      #exit
      #p accessors
      
      #sleep 0.2
    
      xml.feature{ 

        documented = @documented_features.keys.include?( feature )

        xml.name!( method_name.to_s )
        xml.module( module_name.to_s )
        xml.full_name( feature.to_s ) 

        xml.type!( feature_type )

        #xml.documented( documented.to_s )

        #xml.tested( tested.to_s )
            
        #feature_type = "unknown"
                        
        xml.feature_documentation!{ 
              
          if documented

            feature_documentation = @documented_features[ feature.to_s ]
                        
            xml.describes{

              feature_documentation["name"].each{ | feature_name |
              
              xml.name( feature_name )

              }

            }
            
            xml.description( feature_documentation[ "description" ] )

            xml.info( feature_documentation[ "info" ] )

            xml.behaviour_name( feature_documentation[ "__behaviour" ][ "name" ] )

            xml.required_plugin( feature_documentation[ "__behaviour" ][ "plugin" ] )

            xml.sut_types{
            
              feature_documentation["__behaviour"][ "sut_type" ].each{ | sut_type |
              
                xml.type!( sut_type )
              
              }
            }

            xml.sut_versions{
            
              feature_documentation["__behaviour"][ "version" ].each{ | sut_version |
              
                xml.version!( sut_version )
              
              }
            }

            xml.object_types{
            
              feature_documentation["__behaviour"][ "object_type" ].each{ | object_type |
              
                xml.version!( object_type )
              
              }
            }


            xml.input_types{
            
              feature_documentation["__behaviour"][ "input_type" ].each{ | input_type |
              
                xml.type!( input_type )
              
              }
            }
            
            xml.arguments{ 
            
              ( feature_documentation[ "arguments" ] || [] ).each{ | argument |
              
                xml.argument{
                
                  xml.name!( ( argument[ "name" ] || ["NoMethodName"] ).first ) 
                  
                  xml.optional( ( argument[ "optional" ] || [] ).first == "true" )
     
                  xml.types{ 
                  
                    argument[ "types" ].each{ | type |
                    
                      type.each_pair{ | key, value |

                          xml.type!{ 

                            xml.name!( key.to_s )

                            # store each key & value as is                        
                            value.each_pair{ | key, value | 
                              
                              xml.send( key.to_sym, value.to_s )

                            } # type.value.each_pair
                          
                          } # type
                          
                      } # type.each_pair
                      
                    } # types.each
                  
                  } # xml.types
                  
                } # xml.argument
                            
              } # xml.arguments.each
                          
            } # xml.arguments
            

            xml.returns{
            
              ( feature_documentation[ "returns" ] || [] ).each{ | returns |

                returns.each_pair{ | key, value |

                    xml.type!{ 

                      xml.name!( key.to_s )

                      # store each key & value as is                        
                      value.each_pair{ | key, value | 
                        
                        xml.send( key.to_sym, value.to_s )

                      } # type.value.each_pair
                    
                    } # type
                    
                } # type.each_pair

              } # returns.each
            
            } # xml.returns

            xml.exceptions{
            
              ( feature_documentation[ "exceptions" ] || [] ).each{ | returns |

                returns.each_pair{ | key, value |

                    xml.type!{ 

                      xml.name!( key.to_s )

                      # store each key & value as is                        
                      value.each_pair{ | key, value | 
                        
                        xml.send( key.to_sym, value.to_s )

                      } # type.value.each_pair
                    
                    } # type
                    
                } # type.each_pair

              } # returns.each
            
            } # xml.exceptions
                
          end
          
        }
                

        #puts ""
        #p @executed_tests
        
        xml.feature_tests!{
        
          # TODO: verify that getter and setter is tested when attr_accessor 
          
          #tested = @executed_tests.keys.include?( feature )
          
          p feature
          
          p @executed_tests.keys.select{ | key |
           
#            if 
            p feature_type
            key == feature 
            
            
            
          } #include?( feature )

          
          #if 1 == 2 #tested
          
          ["MobyBehaviour::QT::Widget#tap"].each{ | test |
        
            ( @executed_tests[test] || [] ).each{ | test |
            
              xml.scenario{ 

                xml.status( test[ "status" ] )
                xml.description( test[ "description" ] )
                xml.example( test[ "example" ] )
              
              } # xml.scenario
                          
            } # executed_tests.each
                  
          }        
                    
          #end
        } # xml.feature_tests
        
      }

    }

  }
}

puts doc.to_xml
p accessors


