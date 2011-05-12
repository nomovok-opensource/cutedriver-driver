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

module TDriverCustomErrorRecovery

  # This method is called by TDriver Reporter when error is detected in connection
  # === params
  # === returns
  # === raises
  def error_in_connection()

  end

  # This method is called by TDriver Reporter when test set execution is starting
  # === params
  # === returns
  # === raises
  def starting_test_set_run()

  end

  # This method is called by TDriver Reporter when test case execution is starting
  # === params
  # test_case: the test case name
  # connected_suts: All the connected TDriver suts
  # === returns
  # === raises
  def starting_test_case(test_case,connected_suts)

  end

  # This method is called by TDriver Reporter when a error is detected in test case execution
  # === params
  # connected_suts: All the connected TDriver suts
  # === returns
  # === raises
  def error_in_test_case(connected_suts)

  end

  # This method is called by TDriver Reporter when test case details are updated
  # === params
  # details: Execution details recived from the current test case
  # === returns
  # === raises
  def updating_test_case_details(details)

  end

  # This method is called by TDriver Reporter when test case execution is ended
  # === params
  # connected_suts: All the connected TDriver suts
  # === returns
  # === raises
  def ending_test_case(status,connected_suts)

  end

  # This method is called by TDriver Reporter when test set execution is ending
  # === params
  # === returns
  # === raises
  def ending_test_set_run()

  end
    
end
