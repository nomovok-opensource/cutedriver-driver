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

require File.join( File.dirname(__FILE__), '../lib/tdriver/util/loader.rb' )

MobyUtil::GemHelper.install( MobyUtil::FileHelper.tdriver_home ){ | tdriver_home_folder |

  [ 
    # default parameters & sut configuration
    [ "../xml/defaults/*.xml",  "defaults/", true ],

    # parameters
    [ "../xml/parameters/tdriver_parameters.xml", "tdriver_parameters.xml", false ],
    [ "../xml/parameters/tdriver_parameters.xml", "default/tdriver_parameters.xml", true ],
    [ "../config/sut_parameters.rb", "sut_parameters.rb", true ],
    [ "../config/sut_setup.rb", "sut_setup.rb", true ],
    [ "../config/sut_teardown.rb", "sut_teardown.rb", true ],

    # templates
    [ "../xml/templates/*.xml",  "templates/", true ],
    [ "../xml/templates/*.xml",  "default/templates/", true ],

    # behaviours
    [ "../xml/behaviours/*.xml",  "behaviours/", true ],
    [ "../xml/behaviours/*.xml",  "default/behaviours/", true ],

    # create logfiles fodler
    [ nil, "logfiles/", false ]

    # documentation
    #[ "../doc/", "doc/", true ]

    ].each { | task |

      source, destination, overwrite = task

      if source.nil?

        MobyUtil::FileHelper.mkdir_path( File.join( tdriver_home_folder, destination ) ) unless MobyUtil::FileHelper.folder_exist?( File.join( tdriver_home_folder, destination ) )

      else

        MobyUtil::FileHelper.copy_file( source, "#{ tdriver_home_folder }/#{ destination }", false, overwrite, true )

      end

  }

}

MobyUtil::Stats.report( 'install', 'Installed gem' )

sleep ( 5 ) # do not remove!!
