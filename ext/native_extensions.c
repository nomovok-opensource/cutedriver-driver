/*
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
*/

#include "ruby.h"

static const CRC_16[ 16 ] = {
 
      0x0000, 0x1081, 0x2102, 0x3183,	
			0x4204, 0x5285, 0x6306, 0x7387,
			0x8408, 0x9489, 0xa50a, 0xb58b,	
			0xc60c, 0xd68d, 0xe70e, 0xf78f

};

/*
static VALUE crc16_ibm( VALUE self, VALUE string ) {

  // verify argument type
  Check_Type( string, T_STRING );
  
  const char* data = RSTRING_PTR( string );
  
  int len = RSTRING_LEN( string );
    
  int crc = 0xffff;

  int c = 0;

  while( len-- != 0 ){

    c = *data++;

		crc = ( ( crc >> 4 ) & 0x0fff ) ^ CRC_16[ ( ( crc ^ c ) & 15 ) ];

		crc = ( ( crc >> 4 ) & 0x0fff ) ^ CRC_16[ ( ( crc ^ ( c >> 4 )) & 15 ) ];
  }


	return INT2FIX( ~crc & 0xffff );

}
*/

//static VALUE crc16_ibm( VALUE self, VALUE string, VALUE unused_crc ) {
static VALUE crc16_ibm( int argc, VALUE* argv, VALUE self ) { 
  //klass VALUE self, VALUE string, VALUE unused_crc ) {

  // variables for arguments
  VALUE string, initial_crc;

  // retrieve arguments
  rb_scan_args(argc, argv, "11", &string, &initial_crc);

  int crc; // = 0xffff;
  
  if (NIL_P(initial_crc)){
  
    crc = 0xffff; 
  
  } else {

    // verify initial crc value
    Check_Type( initial_crc, T_FIXNUM );
  
    crc = NUM2INT( initial_crc );
  
  }
  
  // verify argument type
  Check_Type( string, T_STRING );

  const char* data = RSTRING_PTR( string );
  
  int len = RSTRING_LEN( string );
  
  int c = 0;

  while( len-- ){

    c = *data++;

    crc = ( crc >> 4 ) ^ CRC_16[ ( crc ^ c ) & 15 ];
              
    crc = ( crc >> 4 ) ^ CRC_16[ ( crc ^ ( c >> 4 ) ) & 15 ];

  }

	return INT2FIX( ~crc & 0xffff );


}

void Init_native_extensions() {

  // main tdriver module
	VALUE mTDriver = rb_define_module( "TDriver" );

  // checksum module
	VALUE cChecksum = rb_define_class_under( mTDriver, "Checksum", rb_cObject );
	
	// checksum methods
	rb_define_singleton_method( cChecksum, "crc16_ibm", crc16_ibm, -1 );

  // deprecated - for backwards compatibility
	VALUE mNativeExtensions = rb_define_module_under( mTDriver, "NativeExtensions" );
	VALUE mCRC = rb_define_module_under( mNativeExtensions, "CRC" );
	rb_define_singleton_method( mCRC, "crc16_ibm", crc16_ibm, -1 );


}
