require 'nokogiri'

@feature_tests = []
@behaviour_hashes = {}
@behaviours = []
$features = 0
$features_nodoc = 0

$passed, $failed, $unknown = [ 0, 0, 0 ]

$modules_and_methods_tested = {}

def process_result_file( content )

  result = { "__file" => @current_file }
  
  # convert linefeeds to whitespace
  content.gsub!( "\n", ' ' )

  # convert double whitespaces to one whitespace
  content.gsub!( '  ', ' ' )

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
        child.attributes.each{ | attribute | 

          behaviour[ attribute.first ] = attribute.last.value.split(";") 

        }          

        # retrieve module & method definitions
        child.children.select{ | node | node.kind_of?( Nokogiri::XML::Element ) }.each{ | child |

          case child.name.to_s

            when /^methods$/i

              methods = []

              # get method definitions                  
              child.children.select{ | node | node.kind_of?( Nokogiri::XML::Element ) }.each{ | child |

                method = {}

                # get behaviour element attributes, e.g. behaviour name, input_type, sut_type etc
                child.attributes.each{ | attribute | 
                  method[ attribute.first ] = attribute.last.value.split(";") 
                }          

                # retrieve method details
                child.children.select{ | node | node.kind_of?( Nokogiri::XML::Element ) }.each{ | child |

                  case child.name.to_s

                    when /^deprecated$/i

                      method[ "deprecated" ] = child.attribute("version").value.to_s

                    when /^description$/i, /^info$/i

                      # store description, info
                      method[ child.name.to_s ] = child.inner_text

                    when /^arguments$/i

                      method[ "arguments_data" ] = {}

                      arguments = []

                      child.attributes.each{ | attribute |

                        method[ "arguments_data" ][ attribute.first ] = attribute.last.value 

                      }

                      child.children.select{ | node | node.kind_of?( Nokogiri::XML::Element ) }.each{ | child |

                        argument = { "types" => [] }

                        # get behaviour element attributes, e.g. behaviour name, input_type, sut_type etc
                        child.attributes.each{ | attribute |

                          argument[ attribute.first ] = attribute.last.value.split(";") 

                        }
                        
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
  
                    when /^tables$/i

                      tables = []
                    
                      child.children.select{ | node | node.kind_of?( Nokogiri::XML::Element ) }.each{ | child |
                      
                        case child.name.to_s
                        
                          when /^table$/i
                                                    
                            table = { "name" => child.attribute("name").value, "title" => "", "header" => [], "row" => [] }
                          
                            child.children.select{ | node | node.kind_of?( Nokogiri::XML::Element ) }.each{ | child |
                              
                              case child.name.to_s
                              
                                when /^title$/i
                                
                                  table[ "title" ] = child.inner_text

                                when /^description$/i
                                
                                  table[ "description" ] = child.inner_text
                              
                                when /^header$/i, /^row$/i #, /^title$/, /^description$/
                                  
                                  table[ child.name.to_s ] << child.children.select{ | node |                                  
                                    node.kind_of?( Nokogiri::XML::Element ) }.collect{ | child |                                  
                                      child.inner_text
                                  }
                                
                              else
                                
                                puts "Unknown element name: '#{ child.name.to_s }' in #{ @current_file }"
                              
                              end
                                                                                    
                            }
                            
                            tables << table                            
                          
                          else

                          puts "Unknown element name: '#{ child.name.to_s }' in #{ @current_file }"
                          
                        end
                      
                      }
                      
                      method[ "tables" ] = tables
  
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

def read_test_result_files( folder )

  Dir.glob( File.join( folder, '*.xml' ) ).each{ | file |

    @current_file = file

    @feature_tests << process_result_file( open( file, 'r' ).read )

  }

  puts "\nTest result files: #{ @feature_tests.count }"

end

def read_behaviour_xml_files( folder )

  if File.directory?( folder )
  
    files = Dir.glob( File.join( folder, '*.xml' ) )
    
  else
  
    files = [ folder ]
  end

  files.each{ | file |

    @current_file = file

    @behaviours << { :filename => file, :behaviours => process_behaviour_file( open( file, 'r' ).read ) }

  }
  
  puts "Behaviour XML files: #{ @behaviours.count }"

end

def read_behaviour_hash_files( folder )

  Dir.glob( File.join( folder, '*.hash' ) ).each{ | file |

    @current_file = file

    content = open( file, 'r' ).read

    # merge to results table
    process_behaviour_hash_file( open( file, 'r' ).read ).each_pair{ | key, value | 

      @behaviour_hashes[ key.to_s ] = ( @behaviour_hashes[ key.to_s ] || [] ) | value 

    }

  }

  abort "No behaviour XML files found from folder '#{ folder }'" if @behaviour_hashes.empty?

end

=begin
def collect_all_features

  @behaviour_hashes.collect{ | module_name, methods |

    methods.collect{ | method |

     "%s#%s" % [ module_name, method ]

    }

  }.flatten

end
=end

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

    result[ ( feature["description"] || ["no feature test description"] ).first ] = 

      ( feature["scenarios"] || [] ).collect{ | scenario |

        # collect step status
        step_results = ( scenario[ "step" ] || [] ).collect{ | step |
        
          #p scenario
        
          if /^.*\s{1}(\w+)$/.match( step )
          
            $1
          
          else
 
            "unknown"
          
          end 
        
          #( /^.*\s{1}(\w+)$/.match( step ).captures || [] ).first
        
        }
        
        ( scenario["example_step"] || [] ).collect{ | example |

          code = /\"(.*)\"/.match( example ).captures.first

          status = ( /^.*\s{1}(\w+)$/.match( example ).captures || [] )      
          
          if status.first.to_s.downcase == 'passed'

            if ( step_results - status ).count > 0 
              status_literal = "failed"
              $failed += 1
            else
              status_literal = "passed"
              $passed += 1
            end
          
          else
                    
            if status.first.to_s.empty?
              status_literal = "unknown"
              $unknown += 1
            else
              status_literal = "failed"            
              $failed += 1
            end
            
          end

          [ 
            "example" => code, 
            "status" => status_literal, 
            "description" => ( scenario["description"] || "" ) 
          ]

        }.flatten

      }.flatten
    
  }.flatten
  
  result

end

def generate_document_xml

  doc = Nokogiri::XML::Builder.new{ | xml |
    
    xml.documentation{

      # TODO: behaviour.hash should have feature type (method/attribute) mentioned  
      # TODO: behaviour.hash should have number of arguments incl. optional + blocks


   #   p @documented_features
    
      @documented_features.sort.each{ | feature_name, feature_documentation | 

        feature_documentation.default = ""

        module_name, method_name = feature_name.split("#")

        feature_type = feature_documentation[ "type" ].first

        arguments_count = feature_documentation[ "arguments_data" ][ "implemented" ]
        optional_arguments_count = feature_documentation[ "arguments_data" ][ "optional" ]

      }

#exit  

      @documented_features.sort.each{ | feature, feature_documentation |
            
        #module_name, method_name, feature_type, feature_parameters = feature.split("#")

        #arguments_count, optional_arguments_count = feature_parameters.split(";")



        module_name, method_name = feature.split("#")

        feature_type = feature_documentation[ "type" ].first

        arguments_count = feature_documentation[ "arguments_data" ][ "implemented" ]
        optional_arguments_count = feature_documentation[ "arguments_data" ][ "optional" ]

                
        feature = "%s#%s" % [ module_name, method_name ]
      
        # make name for feature
        feature_name = case feature_type
      
          when "accessor"
            [ method_name, method_name + "=" ]

          when "writer"
            [ method_name + "=" ]
          
          when "reader", "method"
            [ method_name ]
          
        else
        
          warn("Unknown feature type %s for %s" % [ feature_type, feature ] )
        
          [ method_name ]
        
        end
      
        # get document

        #documented = @documented_features.keys.include?( feature )

        #feature_documentation = {}
        #feature_documentation.default = ""

#        if documented 
          
        # feature_documentation.merge!( @documented_features[ feature.to_s ] )

#        end
       
        # next if feature_documentation.empty?
             
        $features += 1
                          
        if feature_documentation["nodoc"][0].to_s.downcase == "true"
          $features_nodoc += 1
          next 
        end
       
        # <feature type="accessor" name="z;z=" types="qt" versions="*" input_types="touch" object_types="*;sut" requires_plugin="x">
        xml.feature( 
          :type => feature_type, 
          :name => feature_name.join(";"),           
          :required_plugin => feature_documentation[ "__behaviour" ][ "plugin" ],
          :sut_type => feature_documentation["__behaviour"][ "sut_type" ].join(";"), 
          :sut_version => feature_documentation["__behaviour"][ "version" ].join(";"), 
          :input_type => feature_documentation["__behaviour"][ "input_type" ].join(";"),
          :object_type => feature_documentation["__behaviour"][ "object_type" ].join(";")
        ){ 

          # <behaviour name="QtGestureBehaviour" module="MobyBehaviour::QT::GestureBehaviour" />
          xml.behaviour( 
            :name => feature_documentation[ "__behaviour" ][ "name" ], 
            :module => module_name
          )

          if feature_documentation.has_key?( "deprecated" )

            xml.deprecated( :version => feature_documentation[ "deprecated" ] )

          end

          # <description>example</description>
          xml.description( feature_documentation[ "description" ] )

          # <info>example</info>
          xml.info( feature_documentation[ "info" ] )
          
          feature_documentation[ "arguments" ] = [] if feature_documentation[ "arguments" ].kind_of?( String )
                    
          # <arguments count="1" optional="0" described="1" block="true">
          xml.arguments( 
            :count => arguments_count, 
            :optional => optional_arguments_count, 
            :described => feature_documentation[ "arguments" ].count,
            :block => feature_documentation[ "arguments" ].select{ | arg | ( arg[ "type" ] || [] ).first == "block" }.count > 0 
              
          ){

            ( feature_documentation[ "arguments" ] || [] ).each do | argument |
                                    
              # <argument name="value" optional="false" default="11">
              xml.argument( 
                :name => argument[ "name" ].first, 
                :optional => argument[ "optional" ].first, 
                :default => ( argument[ "default" ] || [] ).first, 
                :type => argument[ "type" ].first
                  
              ){

                # iterate each argument                            
                ( argument[ "types" ] || [{}] ).each{ | type |
                
                  type.each_pair do | argument_type, value |  
        
                    # <type name="Integer">
                    xml.type!( :name => argument_type ){

                      # <description>Example argument</description>
                      xml.description( value[ "description" ] )

                      # <example>12</example>
                      xml.example( value[ "example" ] )

                    } # </type>

                  end # type.each_pair
                  
                } # arguments_types.each
              
              } # </argument>
            
            end

          } # </arguments>

          # <returns>
          xml.returns( :described => feature_documentation[ "returns" ].size ){
            
            ( feature_documentation[ "returns" ] || [{}] ).each do | return_value |

              # each return value type
              return_value.each_pair do | variable_type, value |  
                                    
                # <type name="Integer">
                xml.type_( :name => variable_type ){

                  # <description>Example return value</description>
                  xml.description( value[ "description" ] || "" )

                  # <example>12</example>
                  xml.example( value[ "example" ] || "" )

                } # </type>

              end # types.each

            end # returns.each
            
          } # </returns>

          # <exceptions>
          xml.exceptions( :described => feature_documentation[ "exceptions" ].size ){

            ( feature_documentation[ "exceptions" ] || [{}] ).each do | exception |

              # each exception type
              exception.each_pair do | exception_type, value |  
                                    
                # <type name="Integer">
                xml.type_( :name => exception_type ){

                  # <description>Example exception</description>
                  xml.description( value[ "description" ] )

                } # </type>

              end

            end
            
          } # </exceptions>

          # <tables>
          xml.tables{

            ( feature_documentation[ "tables" ] || [{}] ).each do | table |

              xml.table( :name => table[ "name" ] ){
              
                xml.title( table[ "title" ].to_s )
                xml.description( table[ "description" ].to_s )

                xml.header{                                
                  ( table[ "header" ] || [[]] ).first.each{ | item |
                    xml.item( item )
                  }
                }

                ( table[ "row" ] || [] ).each{ | row |
                  
                  xml.row{                              
                    row.each{ | item |
                      xml.item( item )
                    }
                  }
                }              

              }

            end
            
          } # </tables>

          # collect feature tests for method (1), attr_reader (1), attr_writer (1) and attr_accessor (2)          
          names = feature_name.collect{ | name | 
          
            
            feature.split("#").first + "#" + name 
            
          }
          
          tests = names.collect{ | feature_test |
          
            { feature_test => @executed_tests[ feature_test ] || {} }  
            
          }.flatten

          #p tests

          # <tests count="1" passed="0" skipped="0" failed="0">
          xml.tests( 
            :count => tests.count, 
            :passed => tests.select{ | scenario | scenario[ "status" ] == "passed" }.count, 
            :skipped => tests.select{ | scenario | scenario[ "status" ] == "skipped" }.count, 
            :failed => tests.select{ | scenario | scenario[ "status" ] == "failed" }.count 
          ){
            
            tests.each do | scenario |
          
              scenario.each_pair do | scenario_name, scenarios |
              
                scenarios.each do | scenario_value | 

                  # <scenario type="reader" status="passed">
                  xml.scenario( 
                  
                    :type => ( feature_type == "accessor" ? ( ( scenario_name[-1] == ?= ) ? "writer" : "reader" ) : feature_type ), 
                    :status => scenario_value[ "status" ]

                  ){
                  
                    # <description>Example scenario</description>
                    xml.description( scenario_value[ "description" ] )

                    # <example>code</example>
                    xml.example( scenario_value[ "example" ] )
                  
                  } # </scenario>
                  
                end
              
              end

            end

          } # </tests>
          
        }

      }

    }
  }

  doc.to_xml.to_s.gsub("<?xml version=\"1.0\"?>") do | head |
    result = head
    result << "\n"
    result << "<?xml-stylesheet type=\"text/xsl\" href=\"template.xsl\"?>"
  end

end

if ARGV.count < 2
  
  abort "\nUsage: #{ File.basename( $0 ) } test_results_folder behaviour_xml_folder [ output_filename ]\n\n"

end

feature_tests_folder = File.expand_path( $tests || ARGV[ 0 ] || '.' )
behaviour_xml_folder = File.expand_path( $source || ARGV[ 1 ] || 'behaviour_xml/' )
output_filename = File.expand_path( $destination || ARGV[2] || 'document.xml' )

read_test_result_files( feature_tests_folder) # ok
read_behaviour_xml_files( behaviour_xml_folder ) # ok

#read_behaviour_hash_files( behaviour_xml_folder ) # ok

#puts "all executed feature tests:"
@executed_tests = collect_feature_tests

#puts ""
#puts "all available features:"
#@all_features = collect_all_features

#puts ""
#puts "all documented features:"
@documented_features = collect_documented_features

accessors = []

puts "\nTotal number of tests: #{ $passed + $failed + $unknown }\n"
puts "Tests with passed status: #{ $passed }"
puts "Tests with failed status: #{ $failed }"
puts "Tests with unknown result: #{ $unknown }"


begin

  open( output_filename, 'w'){ | file | file << generate_document_xml }

  puts "\nTotal number of features: #{ $features } (#{ $features_nodoc } with nodoc tag)"

  puts "\nDocumentation XML saved succesfully to #{ output_filename }"

rescue Exception => e 

  puts "\nDocumentation XML saved unsuccesfully due to '#{ e.message }' (#{ e.class })"

end

puts ""

