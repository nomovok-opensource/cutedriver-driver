
=begin

    # == arguments
    # direction:
    #  Integer
    #   description: Example argument1
    #   example: 10
    #  Hash
    #   description:
    #    Example argument 1 type 2
    #   example: { :optional_1 => "value_1", :optional_2 => "value_2" }
    #
    # button:
    #  String
    #   description: which button to use
    #   example: "Hello"
=end

source =
'direction
 Integer
  description: jotanjotain
    Example argument1
  example: 10
 Hash
  description:
   Example argument 1 type 2
  example: { :optional_1 => "value_1", :optional_2 => "value_2" }

button
 String
  description: desc
  example: "Hello"

'

source = 
'String
 description: Return value type
 example: "World"'

def parse_returns( source )

  result = []

  current_argument_type = nil

  current_section = nil

  argument_index = -1

  source.lines.to_a.each_with_index{ | line, index | 
    
    # remove cr/lf
    line.chomp!

    # remove trailing whitespaces
    line.rstrip!

    # count nesting depth
    line.match( /^(\s*)/ )

    nesting = $1.size

    # remove leading whitespaces
    line.lstrip!

    if nesting == 0

      line =~ /^(\w+)/i

      if !$1.nil? && (65..90).include?( $1[0] )

        Kernel.const_get( $1 ) rescue abort( "Line %s: \"%s\" is not valid argument variable type. (e.g. OK: \"String\", \"Array\", \"Fixnum\" etc) " % [ index + 1, $1 ] )

        # argument type
        current_argument_type = $1

        current_section = nil

        result << { current_argument_type => {} }

        argument_index += 1

      end

     else

        abort("Unable add return value details (line %s: \"%s\") for %s due to return value variable type must be defined first.\nPlease note that return value type must start with capital letter (e.g. OK: \"String\" NOK: \"string\")" % [ index + 1, line, current_argument  ] ) if current_argument_type.nil?

        line =~ /^(.*?)\:{1}($|[\r\n\t\s]{1})(.*)$/i

        if $1.nil?

          abort("Unable add return value details (line %s: \"%s\") for %s due to section name not defined. Sections names are written in lowercase with trailing colon and whitespace (e.g. OK: \"example: 10\", NOK: \"example:10\")" % [ index +1, line, current_argument]) if $1.nil? && current_section.nil?

          # remove leading & trailing whitespaces
          section_content = line.strip

        else

          current_section = $1
          
          unless result[ argument_index ][ current_argument_type ].has_key?( current_section )

            result[ argument_index ][ current_argument_type ][ current_section ] = ""

          end
      
          section_content = $3.strip

        end

        abort("Unable add return value details due to variable type not defined. Argument type must be defined at pos 1 of comment. (e.g. \"# Integer\" NOK: \"#  Integer\", \"#Integer\")") if current_argument_type.nil?  

        # add one leading whitespace if current_section value is not empty 
        section_content = " " + section_content unless result[ argument_index ][ current_argument_type ][ current_section ].empty?

        # store section_content to current_section
        result[ argument_index ][ current_argument_type ][ current_section ] << section_content

        puts "%s#%s: %s" % [ current_argument_type, current_section, section_content ]

    end


  }

  result

end

p parse_returns( source )

exit

def parse_arguments( source )

  result = []

  current_argument = nil

  current_argument_type = nil

  current_section = nil

  argument_index = -1

  source.lines.to_a.each_with_index{ | line, index | 
    
    # remove cr/lf
    line.chomp!

    # remove trailing whitespaces
    line.rstrip!

    # count nesting depth
    line.match( /^(\s*)/ )

    nesting = $1.size

    # remove leading whitespaces
    line.lstrip!

    if nesting == 0

      line =~ /^(\w+)/i

      unless $1.nil?

        # argument name
        current_argument = $1 

        current_section = nil

        current_argument_type = nil

        result << { current_argument => {} }

        argument_index += 1

      end

    else

      # is line content class name? (argument variable type)
      line =~ /^(\w+)$/i

      if !$1.nil? && (65..90).include?( $1[0] ) # "Array", "String", "Integer"

        Kernel.const_get( $1 ) rescue abort( "Line %s: \"%s\" is not valid argument variable type. (e.g. OK: \"String\", \"Array\", \"Fixnum\" etc) " % [ index +1, $1 ] )

        current_argument_type = $1

        result[ argument_index ][ current_argument ][ current_argument_type ] = {}

        current_section = nil

      else

        abort("Unable add argument details (line %s: \"%s\") for %s due to argument variable type must be defined first.\nPlease note that argument type must start with capital letter (e.g. OK: \"String\" NOK: \"string\")" % [ index + 1, line, current_argument  ] ) if current_argument_type.nil?

        line =~ /^(.*?)\:{1}($|[\r\n\t\s]{1})(.*)$/i

        if $1.nil?

          abort("Unable add argument details (line %s: \"%s\") for %s due to section name not defined. Sections names are written in lowercase with trailing colon and whitespace (e.g. OK: \"example: 10\", NOK: \"example:10\")" % [ index +1, line, current_argument]) if $1.nil? && current_section.nil?

          # remove leading & trailing whitespaces
          section_content = line.strip

        else

          current_section = $1

          unless result[ argument_index ][ current_argument ][ current_argument_type ].has_key?( current_section )

            result[ argument_index ][ current_argument ][ current_argument_type ][ current_section ] = ""

          end
      
          section_content = $3.strip

        end

        abort("argument not defined, argument name must be in 'level 0'") if current_argument.nil?  

        # add one leading whitespace if current_section value is not empty 
        section_content = " " + section_content unless result[ argument_index ][ current_argument ][ current_argument_type ][ current_section ].empty?

        # store section_content to current_section
        result[ argument_index ][ current_argument ][ current_argument_type ][ current_section ] << section_content

        puts "%s#%s#%s: %s" % [ current_argument, current_argument_type, current_section, section_content ]

      end

    end


  }

  result

end

puts "\n\n\n\n\n---------------------------------\n"

p parse_arguments( source )


exit



#p source

def fix_nesting( source )
  
  nesting = 0

  last_nesting = 0

  result = []

  source.each_line{ | line |

    # count nesting depth
    line.match( /^(\s*)/ )

    nesting = $1.size

    if nesting > last_nesting

      puts ">"

    elsif nesting == last_nesting
    
      puts "=="

    else

      puts "<" 

    end 

    last_nesting = nesting

    puts "%s: %s" % [ nesting, line ]

  }

end

p fix_nesting( source )

exit


def t( source, start_pos = 0 )

  results = []

  level = []

  last_nesting = -1

  source.lines.to_a[ start_pos .. -1 ].each_with_index{ | line, line_pos | 

    # remove cr/lf
    line.chomp!

    # remove trailing whitespaces
    line.rstrip!

    # count nesting depth
    line.match( /^(\s*)/ )

    nesting = $1.size

    # remove leading whitespaces
    line.lstrip!

    #puts line

    # check if line is a section name
    if ( line =~ /^(\w+)\:/i )


      #if ($1.size) + 1 > line.size
      #  #results[:XXX] = line.slice( $1.size +1 .. -1 )
      #  puts "more characters to capture, store to hash" 
      #end
      if nesting == last_nesting

        puts "same level"

        level.pop
        level << $1

      elsif nesting > last_nesting

        puts "next level"

        level << $1

      else

        p $1

        puts "prev level"

        p nesting, last_nesting

        level.pop( last_nesting - nesting )

        level << $1

      end

      puts "\n%s%s" % [ "".rjust( level.count, "\t" ), level.join(":") ]
      
      last_nesting = nesting

    else

      puts "%s%s: %s" % [ "".rjust( level.count, "\t" ), level.join(":"), line ]

    end

  }

=begin

#=begin
    # check if line is a section name
    if ( line =~ /^(\w+)\:/i )

      if ($1.size) + 1 > line.size

        #results[:XXX] = line.slice( $1.size +1 .. -1 )
        puts "more characters to capture, store to hash" 

      end
    

      if nesting > current_nesting

        p line

        puts ">>go deeper"

        #p line_pos


        r = t( source, ( start_pos + line_pos + 1 ), nesting, results )
   
        skip_to_line = ( start_pos + line_pos + 1 + r.last )

        p "skip to line %s" % skip_to_line

      else

        puts "same level: %s" % line

      end

      #exit if nesting == 0

      #exit

    else

      puts "save to hash: %s" % line

    end
#=end

  }

=end

  results

end

p t( source )
