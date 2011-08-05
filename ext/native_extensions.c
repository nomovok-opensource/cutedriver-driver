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

static const CCITT_16[ 256 ] = {
  0x0000, 0x1021, 0x2042, 0x3063, 0x4084, 0x50A5, 0x60C6, 0x70E7,
  0x8108, 0x9129, 0xA14A, 0xB16B, 0xC18C, 0xD1AD, 0xE1CE, 0xF1EF,
  0x1231, 0x0210, 0x3273, 0x2252, 0x52B5, 0x4294, 0x72F7, 0x62D6,
  0x9339, 0x8318, 0xB37B, 0xA35A, 0xD3BD, 0xC39C, 0xF3FF, 0xE3DE,
  0x2462, 0x3443, 0x0420, 0x1401, 0x64E6, 0x74C7, 0x44A4, 0x5485,
  0xA56A, 0xB54B, 0x8528, 0x9509, 0xE5EE, 0xF5CF, 0xC5AC, 0xD58D,
  0x3653, 0x2672, 0x1611, 0x0630, 0x76D7, 0x66F6, 0x5695, 0x46B4,
  0xB75B, 0xA77A, 0x9719, 0x8738, 0xF7DF, 0xE7FE, 0xD79D, 0xC7BC,
  0x48C4, 0x58E5, 0x6886, 0x78A7, 0x0840, 0x1861, 0x2802, 0x3823,
  0xC9CC, 0xD9ED, 0xE98E, 0xF9AF, 0x8948, 0x9969, 0xA90A, 0xB92B,
  0x5AF5, 0x4AD4, 0x7AB7, 0x6A96, 0x1A71, 0x0A50, 0x3A33, 0x2A12,
  0xDBFD, 0xCBDC, 0xFBBF, 0xEB9E, 0x9B79, 0x8B58, 0xBB3B, 0xAB1A,
  0x6CA6, 0x7C87, 0x4CE4, 0x5CC5, 0x2C22, 0x3C03, 0x0C60, 0x1C41,
  0xEDAE, 0xFD8F, 0xCDEC, 0xDDCD, 0xAD2A, 0xBD0B, 0x8D68, 0x9D49,
  0x7E97, 0x6EB6, 0x5ED5, 0x4EF4, 0x3E13, 0x2E32, 0x1E51, 0x0E70,
  0xFF9F, 0xEFBE, 0xDFDD, 0xCFFC, 0xBF1B, 0xAF3A, 0x9F59, 0x8F78,
  0x9188, 0x81A9, 0xB1CA, 0xA1EB, 0xD10C, 0xC12D, 0xF14E, 0xE16F,
  0x1080, 0x00A1, 0x30C2, 0x20E3, 0x5004, 0x4025, 0x7046, 0x6067,
  0x83B9, 0x9398, 0xA3FB, 0xB3DA, 0xC33D, 0xD31C, 0xE37F, 0xF35E,
  0x02B1, 0x1290, 0x22F3, 0x32D2, 0x4235, 0x5214, 0x6277, 0x7256,
  0xB5EA, 0xA5CB, 0x95A8, 0x8589, 0xF56E, 0xE54F, 0xD52C, 0xC50D,
  0x34E2, 0x24C3, 0x14A0, 0x0481, 0x7466, 0x6447, 0x5424, 0x4405,
  0xA7DB, 0xB7FA, 0x8799, 0x97B8, 0xE75F, 0xF77E, 0xC71D, 0xD73C,
  0x26D3, 0x36F2, 0x0691, 0x16B0, 0x6657, 0x7676, 0x4615, 0x5634,
  0xD94C, 0xC96D, 0xF90E, 0xE92F, 0x99C8, 0x89E9, 0xB98A, 0xA9AB,
  0x5844, 0x4865, 0x7806, 0x6827, 0x18C0, 0x08E1, 0x3882, 0x28A3,
  0xCB7D, 0xDB5C, 0xEB3F, 0xFB1E, 0x8BF9, 0x9BD8, 0xABBB, 0xBB9A,
  0x4A75, 0x5A54, 0x6A37, 0x7A16, 0x0AF1, 0x1AD0, 0x2AB3, 0x3A92,
  0xFD2E, 0xED0F, 0xDD6C, 0xCD4D, 0xBDAA, 0xAD8B, 0x9DE8, 0x8DC9,
  0x7C26, 0x6C07, 0x5C64, 0x4C45, 0x3CA2, 0x2C83, 0x1CE0, 0x0CC1,
  0xEF1F, 0xFF3E, 0xCF5D, 0xDF7C, 0xAF9B, 0xBFBA, 0x8FD9, 0x9FF8,
  0x6E17, 0x7E36, 0x4E55, 0x5E74, 0x2E93, 0x3EB2, 0x0ED1, 0x1EF0
};


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

static VALUE crc16( int argc, VALUE* argv, VALUE self ) { 
  //klass VALUE self, VALUE string, VALUE unused_crc ) {

  // variables for arguments
  VALUE string, initial_crc;

  // retrieve arguments
  rb_scan_args(argc, argv, "11", &string, &initial_crc);

  int crc; // = 0xffff;
  
  if (NIL_P(initial_crc)){
  
    crc = 0; 
  
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

    crc = ( ( crc << 8 ) ^ CCITT_16[ ( crc >> 8 ) ^ c ] ) & 0xffff;

  }

	return INT2FIX( crc );


}

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

// determines that native extension is in use
static VALUE native_extension( VALUE self ) { 

  return Qtrue;

}

/*
// determines that native extension is in use
static VALUE conv( VALUE self, VALUE string ) { 
  
  VALUE arr = rb_ary_new();
  
  const char* data = RSTRING_PTR( string );
  
  int len = RSTRING_LEN( string );
  
  int c = 0;

  while( len-- ){

    c = *data++;

    char result[] = { c };

    switch( c ){

      case 38:

        rb_ary_push( arr, rb_str_new2( "&amp;" ) );
        break;

      case 60:

        rb_ary_push( arr, rb_str_new2( "&lt;" ) );
        break;

      case 62:

        rb_ary_push( arr, rb_str_new2( "&gt;" ) );
        break;

      case 34:

        rb_ary_push( arr, rb_str_new2( "&quot;" ) );
        break;

      case 39:

        rb_ary_push( arr, rb_str_new2( "&apos;" ) );
        break;

    default:

      //rb_ary_push( arr, INT2FIX(c) );
      rb_ary_push( arr, rb_str_new( result, 1 ) );
      break;

    }

  }  

  return rb_funcall2( arr, rb_intern("join"), 0, NULL );

}
*/

void Init_native_extensions() {

  // main tdriver module
	VALUE mTDriver = rb_define_module( "TDriver" );

  // checksum module
	VALUE cChecksum = rb_define_class_under( mTDriver, "Checksum", rb_cObject );
	
	// checksum methods
	rb_define_singleton_method( cChecksum, "crc16_ibm", crc16_ibm, -1 );

	rb_define_singleton_method( cChecksum, "crc16", crc16, -1 );

  // determines that native extension is in use
	rb_define_singleton_method( cChecksum, "native_extension", native_extension, 0 );

/*
  // determines that native extension is in use
	rb_define_singleton_method( cChecksum, "conv", conv, 1 );

*/

  // deprecated - for backwards compatibility
	VALUE mNativeExtensions = rb_define_module_under( mTDriver, "NativeExtensions" );
	VALUE mCRC = rb_define_module_under( mNativeExtensions, "CRC" );
	rb_define_singleton_method( mCRC, "crc16_ibm", crc16_ibm, -1 );


}
