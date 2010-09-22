require 'nokogiri'

@feature_tests = {}
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

  p "--"

  # collect only important data to result
  #{ result["description"].first => result }

  { result["description"].first => 

    result["scenarios"].collect{ | scenario |

      scenario["example_step"].collect{ | example |

        code = /\"(.*)\"/.match( example ).captures.first

        status = /^.*\s{1}(\w+)$/.match( example ).captures.first      

        { :example => code, :status => status.to_s.downcase }

      }

    }.flatten
  }

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

  Dir.glob( 'feature_xml/*.xml' ).each{ | file |

    @current_file = file

    @feature_tests.merge!( process_result_file( open( file, 'r' ).read ) ) #{ :filename => file, :results => process_result_file( open( file, 'r' ).read ) }

  }

end

def read_behaviour_xml_files

  Dir.glob( 'behaviour_xml/*.xml' ).each{ | file |

    @current_file = file

    @behaviours << { :filename => file, :behaviours => process_behaviour_file( open( file, 'r' ).read ) }

  }

end

def read_behaviour_hash_files

  Dir.glob( 'behaviour_xml/*.hash' ).each{ | file |

    @current_file = file

    content = open( file, 'r' ).read

    # merge to results table
    process_behaviour_hash_file( open( file, 'r' ).read ).each_pair{ | key, value | 

      @behaviour_hashes[ key.to_s ] = ( @behaviour_hashes[ key.to_s ] || [] ) | value 

    }

  }

end

read_test_result_files # ok
read_behaviour_xml_files # ok
read_behaviour_hash_files # ok

# ran tests 
p @feature_tests.keys

p @feature_tests

=begin
  result["scenarios"].each{ | scenario |

    p scenario["example_step"]

  }
=end

  #p result["description"].first#.first #.keys


@behaviour_hashes.each_pair{ | module_name, methods |

  methods.each{ | method |

   puts "%s#%s" % [ module_name, method ]

  }

}

#p $feature_tests
