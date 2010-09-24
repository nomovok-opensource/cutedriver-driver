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

def generate_document_xml

=begin

 <feature>
    <name>z</name>
    <module>MobyBehaviour::QT::Gesture</module>
    <full_name>MobyBehaviour::QT::Gesture#z</full_name>
    <type>accessor</type>
    <arguments>
      <count>0</count>
      <optional>0</optional>
    </arguments>
    <feature_documentation>
      <describes>
        <name>z</name>
        <name>z=</name>
      </describes>
      <description>example desc</description>
      <info></info>
      <behaviour_name>QtExampleGestureBehaviour</behaviour_name>
      <required_plugin>*</required_plugin>
      <sut_types>
        <type>qt</type>
      </sut_types>
      <sut_versions>
        <version>*</version>
      </sut_versions>
      <object_types>
        <version>*</version>
        <version>sut</version>
      </object_types>
      <input_types>
        <type>touch</type>
      </input_types>
      <arguments>
        <argument>
          <name>value</name>
          <optional>false</optional>
          <types>
            <type>
              <name>Integer</name>
              <example>10</example>
              <description>Example argument1</description>
            </type>
          </types>
        </argument>
      </arguments>
      <returns>
        <type>
          <name>String</name>
          <example>"World"</example>
          <description>Return value type</description>
        </type>
      </returns>
      <exceptions/>
    </feature_documentation>
    <feature_tests/>
  </feature>

 <feature>

    <type>accessor</type>

    <implements>
      <name>z</name>
      <name>z=</name>
    </implements>

    <behaviour_name>QtExampleGestureBehaviour</behaviour_name>
    <module>MobyBehaviour::QT::Gesture</module>
    <required_plugin>*</required_plugin>

    <sut_types>
      <type>qt</type>
    </sut_types>

    <sut_versions>
      <version>*</version>
    </sut_versions>

    <object_types>
      <version>*</version>
      <version>sut</version>
    </object_types>

    <input_types>
      <type>touch</type>
    </input_types>

    <description>example desc</description>
    <info></info>

    <arguments>

      <count>1</count>
      <optional>0</optional>

        <argument>
          <name>value</name>
          <optional>false</optional>
          <types>
            <type>
              <name>Integer</name>
              <example>10</example>
              <description>Example argument1</description>
            </type>
          </types>
        </argument>

    </arguments>

    <returns>

      <type>
        <name>String</name>
        <example>"World"</example>
        <description>Return value type</description>
      </type>

    </returns>
      
    <exceptions/>

    <feature_tests/>

  </feature>




 <feature>

    <type>accessor</type>

    <implements>
      <name>z</name>
      <name>z=</name>
    </implements>

    <behaviour_name>QtExampleGestureBehaviour</behaviour_name>
    <module>MobyBehaviour::QT::Gesture</module>
    <required_plugin>*</required_plugin>

    <sut_types>
      <type>qt</type>
    </sut_types>

    <sut_versions>
      <version>*</version>
    </sut_versions>

    <object_types>
      <version>*</version>
      <version>sut</version>
    </object_types>

    <input_types>
      <type>touch</type>
    </input_types>

    <description>example desc</description>
    <info></info>

    <arguments count="1" optional="0">

      <argument name="value" optional="false">
        <type name="Integer">
          <example>10</example>
          <description>Example argument1</description>
        </type>
      </argument>

    </arguments>

    <returns>

      <type name="String">
        <example>"World"</example>
        <description>Return value type</description>
      </type>

    </returns>
      
    <exceptions/>

    <feature_tests/>

  </feature>




=end


  doc = Nokogiri::XML::Builder.new{ | xml |

    #p doc.to_xml
    #p doc.to_xml
    #exit

    xml.documentation{

      # TODO: behaviour.hash should have feature type (method/attribute) mentioned  
      # TODO: behaviour.hash should have number of arguments incl. optional + blocks

      collect_all_features.sort.each{ | feature |
      
        module_name, method_name, feature_type, feature_parameters = feature.split("#")

        feature_parameters = feature_parameters.split(";")
        
        feature = "%s#%s" % [ module_name, method_name ]
      
        # get document

        documented = @documented_features.keys.include?( feature )

        if documented 

          feature_documentation = @documented_features[ feature.to_s ]
                      
          xml.describes{

            feature_documentation["name"].each{ | feature_name |
            
            xml.name( feature_name )

            }

          }

        else

          

        end
        
        xml.feature(){ 

          xml.name!( method_name.to_s )
          xml.module( module_name.to_s )
          xml.full_name( feature.to_s ) 

          xml.type!( feature_type )
                          
          xml.arguments{
          
            xml.count( feature_parameters[ 0 ] )
            xml.optional( feature_parameters[ 1 ] )
          
          }
                          
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
                  
          
          xml.feature_tests!{
      
            case feature_type
            
              when /accessor/i
                tests = [ feature, "%s=" % feature ]

              when /writer/i
                tests = [ "%s=" % feature ]
              
              when /method/i, /reader/i            
                tests = [ feature ]
            
            end

            #tests = ["MobyBehaviour::QT::Widget#tap"]
            
            tests.each{ | test_feature |
                  
              ( @executed_tests[ test_feature ] || [] ).each{ | test |
              
                xml.scenario{ 

                  xml.type!( feature_type == "accessor" ? ( ( test_feature[-1] == ?= ) ? "writer" : "reader" ) : feature_type )
                      
                  xml.status( test[ "status" ] )
                  xml.description( test[ "description" ] )
                  xml.example( test[ "example" ] )
                
                } # xml.scenario
                            
              } # executed_tests.each
                    
            }        
                      
          } # xml.feature_tests
          
        }

      }

    }
  }

  doc.to_xml

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

puts generate_document_xml

