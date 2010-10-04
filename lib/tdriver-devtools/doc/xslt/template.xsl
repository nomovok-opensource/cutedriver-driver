<?xml version="1.0" encoding="ISO-8859-1"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:str="http://exslt.org/strings" extension-element-prefixes="str">
<xsl:preserve-space elements="*"/>
<xsl:output method="html"/>

<xsl:template match="/">
<html>
  <head>
    <style  TYPE="text/css">
     
      div.feature_title
      {

        background: #f1f1f1;

        border-top: 1px solid #f9f9f9;
        border-left: 1px solid #f9f9f9;

        border-bottom: 1px solid #dadada;
        border-right: 1px solid #dadada;


        background: #d1d1d1;

        border-top: 1px solid #d9d9d9;
        border-left: 1px solid #d9d9d9;

        border-bottom: 1px solid #bababa;
        border-right: 1px solid #bababa;

        background: #c1c1c1;

        border-top: 1px solid #c9c9c9;
        border-left: 1px solid #c9c9c9;

        border-bottom: 1px solid #aaaaaa;
        border-right: 1px solid #aaaaaa;

        color: #404040;

        padding: 8px; 

      }

      span.feature_title_text
      {
        text-decoration: underline;    
        font-size: 14px; 
        font-weight: bold;
      }

      div.feature_section_title
      {

        font-family: arial;
        font-size: 13px;
        font-weight: bold;
        color: #000000;
      
      }
      
      div.feature_description, div.feature_call_sequence, div.scenario_description
      {

        padding: 2px;
        font-family: 'Times New Roman', Times, serif;
        font-size: 13px;
        font-weight: normal; 
        
      }
      
      div.feature_description, div.scenario_description
      {
        font-style: normal; // normal more readable than italic;
      }
      
      div.feature_call_sequence
      {
            
      }

      table.default
      {
      
        margin-top: 2px;
      
        width: 100%;
              
        text-align: left;
      
        <!-- cellspacing -->
        border-spacing: 1px;
            
        border: 1px solid #c1c1c1;
        border-top: 1px solid #e1e1e1;
        border-left: 1px solid #e1e1e1;
      
      }

      tr.header
      {      
        background: #96E066;
        font-weight: bold;
      }

      <!-- table-style: cellpadding -->
      td
      {
      
        padding: 6px;
        font-family: arial;
        font-size: 11px;      
      
      }

      td.header
      {

        font-size: 11px;      
        border-top: 1px solid #a6f076;
        border-left: 1px solid #a6f076;

        border-bottom: 1px solid #7fc94f;
        border-right: 1px solid #7fc94f;

      }

      td.tablebg_even
      {
        background: #ededed;
        border-top: 1px solid #f5f5f5;
        border-left: 1px solid #f5f5f5;

        border-bottom: 1px solid #d6d6d6;
        border-right: 1px solid #d6d6d6;

      }

      td.tablebg_odd
      {
        background: #dedede;
        border-top: 1px solid #e6e6e6;
        border-left: 1px solid #e6e6e6;
        border-bottom: 1px solid #c7c7c7;
        border-right: 1px solid #c7c7c7;

      }

      td.warning,div.warning, td.tablebg_warning, pre.failed, pre.skipped
      {

        background: #a11010;
        color: #ffff00;

      }

      td.tablebg_warning, td.warning, pre.failed, pre.skipped
      {

        border-top: 1px solid #a91818;
        border-left: 1px solid #a91818;

        border-bottom: 1px solid #8a0000;
        border-right: 1px solid #8a0000;

      }

      td.tablebg_disabled
      {
        background: #c5c5c5;

        border-top: 1px solid #cdcdcd;
        border-left: 1px solid #cdcdcd;
        border-bottom: 1px solid #aeaeae;
        border-right: 1px solid #aeaeae;

      }

      div.warning
      {
        color: #ffff00;

        font-family: arial;
        font-size: 11px;      
        padding: 6px;
      
      }

      span.optional_argument
      {
        font-style: italic;
      }

      body
      {
        padding: 10px;
        border: #e7e7e7 1px solid;
        background: #ffffff;
        color: black;
        font-size: 13px;
        cursor:default;
      }

      pre
      {
      
        font-family: monospace;
        font-size: 11px;
      
      }

      pre.passed, pre.failed, pre.skipped{
      
        margin: 5px 2px 9px 2px;
        padding: 10px 10px 10px 8px;
            
      }

      pre.passed
      {

        background: #f1f1f1;

        border-top: 1px solid #f9f9f9;
        border-left: 1px solid #f9f9f9;

        border-bottom: 1px solid #dadada;
        border-right: 1px solid #dadada;

        color: black;
      }

      pre.failed, pre.skipped
      {

        color: black;

      }
      span.hover_text
      {
      
        cursor: help; //pointer;
        border-bottom: 1px dotted #b1b1b1;
      
      }

      span.hover_text:hover
      {
      
        cursor: help; //pointer;
        border-bottom: 1px dotted #515151;
      
      }
      
      span.toc_title
      {
      
        font-size: 14px;
        font-weight: bold;
      
      }
      
      div.toc
      {
      
        padding: 5px;
        width: 100%;
        word-spacing: normal;
      }

      span.toc_block
      {
      
        padding: 7px;
      }
      
      a.toc_item
      {
      
        font-size: 11px;
        text-decoration: none;
        color: #313131;

      }

      a.toc_item:hover
      {
      
        //text-decoration: underline;
        border-bottom: 1px dotted #515151;

      }

      
    </style>
  </head>
  <body>

    <a name="top">
      <h2>Documentation</h2>
    </a>
    
    <xsl:apply-templates/>

  </body>
</html>
</xsl:template>

<xsl:template match="documentation">

  <!-- table of contents -->
  <span class="toc_title">Table of contents:</span>
  <br />
  
  <div class="toc">
    <xsl:for-each select="feature/@name">
      <xsl:sort select="." />

      <xsl:variable name="name"><xsl:value-of select="../@name"/></xsl:variable>

      <xsl:for-each select="str:split(.,';')">
        <span class="toc_block">
          <a href="#{ $name }" class="toc_item">
            <xsl:value-of select="." />
          </a>
        </span>
      </xsl:for-each>

      <xsl:text> </xsl:text>
    
    </xsl:for-each>
    
  </div>
  <br />

  <!-- content -->

  <xsl:for-each select="feature">
    <xsl:sort select="@name" />
    <xsl:call-template name="feature">
    </xsl:call-template>
  
  </xsl:for-each>

</xsl:template>

<xsl:template name="feature_name">

  <!-- implements following features, e.g. method name, attribute reader, attribute writer or both when attribute accessor -->

  <a name="{ @name }">
  <div class="feature_title">
  <xsl:for-each select="str:split(@name,';')">
    <span class="feature_title_text">
      <xsl:value-of select="."/> 
    </span>
    <xsl:if test="position()!=last()">
    <xsl:text>, </xsl:text>
    </xsl:if>
  </xsl:for-each>
  </div>
  </a>

  <br />

</xsl:template>

<xsl:template name="call_sequence">

  <div class="feature_section_title">Call sequence:</div>

  <div class="feature_call_sequence">
    <!-- method: call example using parameters -->
    <xsl:if test="@type='method'">
    
      object.<xsl:value-of select="@name" />

      <xsl:choose>

        <xsl:when test="count(arguments/argument)=0">()</xsl:when>
        
        <xsl:when test="count(arguments/argument)>0">
          <xsl:text>( </xsl:text>

            <!-- collect arguments for example -->
            <xsl:for-each select="arguments/argument">

              <xsl:if test="@type='normal' or @type='multi'">

                <xsl:choose>

                  <xsl:when test="@optional='true'">
                    <span class="optional_argument" title="Optional argument">
                     <xsl:if test="@type='multi'">
                       <xsl:text></xsl:text>        
                     </xsl:if>
                      <xsl:text>[ </xsl:text>
                      <span class="hover_text">
                        <xsl:value-of select="@name"/>
                         <xsl:if test="@type='multi'">
                           <xsl:text>, ..., ...</xsl:text>        
                         </xsl:if>
                      </span>
                      <xsl:text> ]</xsl:text>
                    </span>
                  </xsl:when>

                  <xsl:otherwise>
                    <span title="Mandatory argument" class="hover_text"><xsl:value-of select="@name"/></span>
                  </xsl:otherwise>

                </xsl:choose>

                <!-- separate arguments with comma if next argument defintion is not type of block --> 
                <xsl:if test="position()!=last() and following-sibling::argument/@type!='block'">
                  <xsl:text>, </xsl:text>
                </xsl:if>
                
              </xsl:if>
              
            </xsl:for-each>
          <xsl:text> ) </xsl:text>
          
          <!-- collect arguments for example -->
          <xsl:for-each select="arguments/argument">

                <xsl:if test="./@type='block'">
                
                  <xsl:text>{ </xsl:text>
                  <span class="hover_text" title="Code block, mandatory or optional"><xsl:value-of select="@name"/></span>
                  <xsl:text> }</xsl:text>
                
                </xsl:if>
                
          </xsl:for-each>

        </xsl:when>
                  
      </xsl:choose>

      <!-- describe block usage --> 
      <xsl:if test="count(arguments/block)>0">
        <xsl:text>{ </xsl:text>
        <!-- TODO: block arguments -->
        <xsl:value-of select="arguments/block/@name" />
        <xsl:text> }</xsl:text>
      </xsl:if>
      <br />
    </xsl:if>

    <!-- attr_reader/attr_accessor: call example -->
    <xsl:if test="@type='reader' or @type='accessor'">
      <xsl:text>return_value = object.</xsl:text>
      <xsl:value-of select="str:split(@name,';')[1]" />
      <br />
    </xsl:if>

    <!-- attr_writer/attr_accessor: call example -->
    <xsl:if test="@type='writer' or @type='accessor'">
    
      <!-- TODO: argument name from arguments array -->
      <xsl:text>object.</xsl:text>
      <xsl:value-of select="str:split(@name,';')[1]" />
      <xsl:text> = ( </xsl:text>

      <xsl:choose>
      
        <xsl:when test="count(arguments/argument)=0">
          <span title="Mandatory value" class="hover_text"><xsl:text>new_value</xsl:text></span>
        </xsl:when>
        
        <xsl:otherwise>
          <span title="Mandatory value" class="hover_text"><xsl:value-of select="arguments/argument[1]/@name" /></span>
        </xsl:otherwise>

      </xsl:choose>

      <xsl:text> )</xsl:text>
      <br />
    </xsl:if>

  </div>

  <br />

</xsl:template>

<!-- template to capitalize string -->
<xsl:template name="capitalize">

  <xsl:param name="text" />
  
  <xsl:value-of select="concat(translate(substring($text,1,1), 'abcdefghijklmnopqrstuvwxyz','ABCDEFGHIJKLMNOPQRSTUVWXYZ'), substring($text,2))"/>

</xsl:template>

<xsl:template name="target_details">
  
  <div class="feature_section_title">Feature and target details:</div>
  <table class="default">
    <tr class="header">
      <td class="header">Type</td>
      <td class="header">Target object(s)</td>
      <td class="header">SUT type(s)</td>
      <td class="header">SUT version(s)</td>
      <td class="header">SUT input type(s)</td>
      <td class="header">Behaviour module</td>
      <td class="header">Required plugin</td>
    </tr>
    <tr>
    
      <!-- feature type -->
      <td class="tablebg_even" valign="top">
        <!-- capitalize text() -->
        <xsl:call-template name="capitalize">
         <xsl:with-param name="text" select="@type" />
        </xsl:call-template>    
      </td>
      
      <!-- target object -->
      <xsl:choose>
        <xsl:when test="string-length(@object_type)>0">
          <td class="tablebg_even" valign="top">
            <xsl:for-each select="str:split(@object_type,';')">
              <xsl:choose>
                <xsl:when test="text()='*'">
                  <xsl:text>Any test object</xsl:text>
                </xsl:when>
                <xsl:when test="text()='sut'">
                  <xsl:text>SUT object</xsl:text>
                </xsl:when>
                <xsl:otherwise>
                  <xsl:value-of select="text()" />
                </xsl:otherwise>
              </xsl:choose>
              <xsl:if test="position()!=last()">
              <xsl:text>,</xsl:text> 
              </xsl:if>
              <br />
            </xsl:for-each>
          </td>
        </xsl:when>
        <xsl:otherwise>
          <td class="tablebg_warning" valign="top">
            <xsl:call-template name="div_warning">
            <xsl:with-param name="text">Not defined</xsl:with-param>
            </xsl:call-template>
          </td>
        </xsl:otherwise>
      </xsl:choose>

                  

      <!-- target sut -->
      <xsl:choose>
        <xsl:when test="string-length(@sut_type)>0">
          <td class="tablebg_even" valign="top">
            <xsl:for-each select="str:split(@sut_type,';')">
              <xsl:choose>
                <xsl:when test="text()='*'">
                  <xsl:text>Any SUT type</xsl:text>
                </xsl:when>
                <xsl:otherwise>
                  <!-- capitalize text() -->
                  <xsl:call-template name="capitalize">
                   <xsl:with-param name="text" select="text()" />
                  </xsl:call-template>    
                </xsl:otherwise>
              </xsl:choose>
              <xsl:if test="position()!=last()">
                <xsl:text>,</xsl:text> 
              </xsl:if>
              <br />
            </xsl:for-each>                
          </td>
        </xsl:when>
        <xsl:otherwise>
          <td class="tablebg_warning" valign="top">
            <xsl:call-template name="div_warning">
            <xsl:with-param name="text">Not defined</xsl:with-param>
            </xsl:call-template>
          </td>
        </xsl:otherwise>
      </xsl:choose>

      <!-- sut version -->
      <xsl:choose>      
        <xsl:when test="string-length(@sut_version)>0">
          <td class="tablebg_even" valign="top">
            <xsl:for-each select="str:split(@sut_version,';')">

              <xsl:choose>
                <xsl:when test="text()='*'">
                  <xsl:text>All</xsl:text>
                </xsl:when>
                <xsl:otherwise>
                  <!-- capitalize text() -->
                  <xsl:call-template name="capitalize">
                   <xsl:with-param name="text" select="text()" />
                  </xsl:call-template>    
                </xsl:otherwise>
              </xsl:choose>
              <xsl:if test="position()!=last()">
                <xsl:text>,</xsl:text> 
              </xsl:if>
              <br />
            </xsl:for-each> 
          </td>
        </xsl:when>
        <xsl:otherwise>
          <td class="tablebg_warning" valign="top">
            <xsl:call-template name="div_warning">
            <xsl:with-param name="text">Not defined</xsl:with-param>
            </xsl:call-template>
          </td>
        </xsl:otherwise>
      </xsl:choose>

      <!-- input type -->
      <xsl:choose>
        <xsl:when test="string-length(@input_type)=0">
          <td class="tablebg_warning" valign="top">
            <xsl:call-template name="div_warning">
            <xsl:with-param name="text">Not defined</xsl:with-param>
            </xsl:call-template>
          </td> 
        </xsl:when>
        <xsl:otherwise>
          <td class="tablebg_even" valign="top">
            <xsl:for-each select="str:split(@input_type,';')">
              <xsl:choose>
                <xsl:when test="text()='*'">
                  <xsl:text>All</xsl:text>
                </xsl:when>
                <xsl:otherwise>
                  <!-- capitalize text() -->
                  <xsl:call-template name="capitalize">
                   <xsl:with-param name="text" select="text()" />
                  </xsl:call-template>    
                </xsl:otherwise>
              </xsl:choose>
              <xsl:if test="position()!=last()">
                <xsl:text>,</xsl:text> 
              </xsl:if>
              <br />
            </xsl:for-each> 
          </td>
        </xsl:otherwise>
      </xsl:choose>

      <!-- behaviour module -->
      <xsl:choose>
        <xsl:when test="string-length(behaviour/@module)>0">
          <td class="tablebg_even" valign="top">
            <xsl:value-of select="behaviour/@module" />
          </td>
        </xsl:when>
        <xsl:otherwise>
          <td class="tablebg_warning" valign="top">
            <xsl:call-template name="div_warning">
            <xsl:with-param name="text">Not defined</xsl:with-param>
            </xsl:call-template>
          </td>
        </xsl:otherwise>
      </xsl:choose>

      <!-- required plugin -->
      <xsl:choose>
        <xsl:when test="string-length(@required_plugin)=0">
          <td class="tablebg_warning" valign="top">
            <xsl:call-template name="div_warning">
            <xsl:with-param name="text">Not defined</xsl:with-param>
            </xsl:call-template>
          </td>
        </xsl:when>
        <xsl:when test="@required_plugin!='*'">
          <td class="tablebg_even" valign="top">
            <xsl:value-of select="@required_plugin" />
          </td>
        </xsl:when>
        <xsl:otherwise>
          <td class="tablebg_disabled" valign="top"></td>
        </xsl:otherwise>
      </xsl:choose>

    </tr>

  </table>
  <br />

</xsl:template>

<xsl:template name="feature">

  <xsl:call-template name="feature_name" />
  
  <xsl:call-template name="description" />

  <xsl:call-template name="call_sequence" />

  <xsl:call-template name="target_details" />

  <xsl:call-template name="arguments" />

  <xsl:call-template name="returns">
    <xsl:with-param name="type" select="returns/type" />
    <xsl:with-param name="feature_type" select="@type" />
  </xsl:call-template>

  <xsl:call-template name="exceptions">
    <xsl:with-param name="type" select="exceptions/type" />
    <xsl:with-param name="feature_type" select="@type" />
  </xsl:call-template>
  
  <xsl:call-template name="tests">
    <xsl:with-param name="tests" select="tests" />
  </xsl:call-template>
    
  <xsl:call-template name="info" />
  
  <xsl:if test="position()!=last()-1">
    <!-- feature separator? -->
   </xsl:if>
        
  <a href="#top" class="toc_item">Jump to top of page</a><br />
  <br />
          
</xsl:template>

<xsl:template name="exceptions">

  <xsl:param name="type" />
  <xsl:param name="feature_type" />

  <xsl:if test="count($type)>0">
  
    <!-- exceptions -->
    <div class="feature_section_title">Exceptions:</div>

    <table class="default">
    <tr class="header">
      <td class="header">Type</td>
      <td class="header">Description</td>
    </tr>

    <xsl:for-each select="$type">

      <xsl:if test="(position() mod 2)=0" >
        <xsl:call-template name="exception_type">
          <xsl:with-param name="type" select="." />
          <xsl:with-param name="class">tablebg_odd</xsl:with-param>                        
        </xsl:call-template>
      </xsl:if>

      <xsl:if test="(position() mod 2)=1" >
        <xsl:call-template name="exception_type">
          <xsl:with-param name="type" select="." />
          <xsl:with-param name="class">tablebg_even</xsl:with-param>                        
        </xsl:call-template>
      </xsl:if>
      
    </xsl:for-each>

    </table>
    <br />

  </xsl:if>

</xsl:template>

<xsl:template name="exception_type">

  <xsl:param name="type" />
  <xsl:param name="class" />

  <tr valign="top" class="{ $class }">
    <td class="{ $class }"><xsl:value-of select="$type/@name"/></td>
    <td class="{ $class }"><xsl:for-each select="str:split($type/description,'\n')">
      <xsl:value-of select="text()" /><br />
    </xsl:for-each>
    </td>
  </tr>

</xsl:template>

<xsl:template name="argument_details">

  <xsl:param name="argument_name" />
  <xsl:param name="type" />
  <xsl:param name="default" />
  <xsl:param name="class" />

  <xsl:variable name="argument_types" select="count(type)" />

  <xsl:for-each select="type">

    <tr valign="top" class="{ $class }">
    
      <xsl:if test="position()=1">

        <xsl:choose>

          <xsl:when test="../@optional='true' and ../@type!='block'">
            
              <td rowspan="{$argument_types}" class="{ $class }">
                <span class="optional_argument" title="Optional argument">
                <span class="hover_text"><xsl:value-of select="$argument_name" /></span>
                </span>
              </td>
            
          </xsl:when>

          <xsl:when test="../@type='block'">
            
            <td rowspan="{$argument_types}" class="{ $class }">
              <span title="Code block, mandatory or optional" class="hover_text"><xsl:value-of select="$argument_name" /></span>
            </td>
            
          </xsl:when>

          <xsl:otherwise>
          
            <td rowspan="{$argument_types}" class="{ $class }">
              <span title="Mandatory argument" class="hover_text"><xsl:value-of select="$argument_name" /></span>
            </td>

          </xsl:otherwise>

        </xsl:choose>

      </xsl:if>
      
      <td class="{ $class }">
        <xsl:value-of select="@name"/> 
      </td>
      
      <td class="{ $class }">
        <xsl:for-each select="str:split(description,'\n')"><xsl:value-of select="text()" /><br /></xsl:for-each>
      </td>

      <td class="{ $class }"><xsl:value-of select="example"/></td>
      
      <xsl:if test="string-length($default)=0">
      <td class="tablebg_disabled"><xsl:value-of select="$default"/></td>
      </xsl:if>

      <xsl:if test="string-length($default)>0">
        <td class="{ $class }"><xsl:value-of select="$default"/></td>
      </xsl:if>

    </tr>  

  </xsl:for-each>

</xsl:template>

<xsl:template name="arguments">

  <xsl:if test="@type='writer' or @type='accessor' or (@type='method' and number(arguments/@count)>0)">

    <div class="feature_section_title">Arguments:</div>

    <table class="default">
    <tr class="header">
      <td class="header">Name</td>
      <td class="header">Type</td>
      <td class="header">Description</td>
      <td class="header">Example</td>
      <td class="header">Default</td>
    </tr>

    <xsl:for-each select="arguments/argument">

      <!-- table stripes: position even -->
      <xsl:if test="(position() mod 2)=1">
        <xsl:call-template name="argument_details">
          <xsl:with-param name="argument_name" select="@name" />
          <xsl:with-param name="type" select="type" />
          <xsl:with-param name="class">tablebg_even</xsl:with-param>
          <xsl:with-param name="default" select="@default" />
        </xsl:call-template>
      </xsl:if>

      <!-- table stripes: position odd -->
      <xsl:if test="(position() mod 2)=0">
        <xsl:call-template name="argument_details">
          <xsl:with-param name="argument_name" select="@name" />
          <xsl:with-param name="type" select="type" />
          <xsl:with-param name="class">tablebg_odd</xsl:with-param>
          <xsl:with-param name="default" select="@default" />
        </xsl:call-template>
        
      </xsl:if>
    
    </xsl:for-each>
    
    <!-- show error message if argument is not described -->
    <xsl:if test="@type='method' and (arguments/@described&lt;arguments/@count)">
      <xsl:call-template name="row_warning" >
        <xsl:with-param name="colspan">5</xsl:with-param>
        <xsl:with-param name="text">Incomplete documentation: only <xsl:value-of select="arguments/@described" /> of <xsl:value-of select="arguments/@count" /> arguments documented. Please note that block is also counted as one argument.</xsl:with-param>
      </xsl:call-template>
    </xsl:if>

    <!-- show error message if argument is not described -->
    <xsl:if test="(@type='accessor' or @type='writer') and arguments/@described=0">
      <xsl:call-template name="row_warning" >
        <xsl:with-param name="colspan">5</xsl:with-param>
        <xsl:with-param name="text">Incomplete documentation: Attribute writer/accessor input value needs to be documented.</xsl:with-param>
      </xsl:call-template>
    </xsl:if>

    </table>
    <br />

  </xsl:if>

</xsl:template>

<xsl:template name="returns_type">

  <xsl:param name="type" />
  <xsl:param name="class" />

  <tr valign="top" class="{ $class }">
    <td class="{ $class }"><xsl:value-of select="$type/@name"/></td>
    <td class="{ $class }"><xsl:for-each select="str:split($type/description,'\n')">
      <xsl:value-of select="text()" /><br />
    </xsl:for-each>
    </td>
    <td class="{ $class }"><xsl:value-of select="$type/example"/></td>
  </tr>

</xsl:template>

<xsl:template name="row_warning">

  <xsl:param name="text" />
  <xsl:param name="colspan" />

  <tr>
   <td colspan="{ $colspan }" class="warning">[!!] <xsl:value-of select="$text" /></td>
  </tr>
  
</xsl:template>

<xsl:template name="div_warning">
  <xsl:param name="text" />
  <div class="warning">[!!] <xsl:value-of select="$text" /></div>  
</xsl:template>

<xsl:template name="returns">

  <xsl:param name="type" />
  <xsl:param name="feature_type" />

  <!-- show return value types table if feature type is method, reader or accessor -->
  <!--<xsl:if test="@type='reader' or @type='accessor' or @type='method'"> -->

  <xsl:if test="@type='reader' or @type='accessor' or @type='method'">

    <!-- return values -->
    <div class="feature_section_title">Returns:</div>
    <table class="default">
    <tr class="header">
      <td class="header">Type</td>
      <td class="header">Description</td>
      <td class="header">Example</td>
    </tr>

    <!-- show error message if no return values defined -->
    <xsl:if test="(( count($type)=0 ) or ( count( arguments )=0 ) ) and ((@type='method') or (@type='accessor') or (@type='reader'))">
      <xsl:call-template name="row_warning">
        <xsl:with-param name="text">Incomplete documentation: No return value type(s) defined for method, attribute reader or attribute accessor</xsl:with-param>
        <xsl:with-param name="colspan">3</xsl:with-param>
      </xsl:call-template>
    </xsl:if>
    
    <xsl:if test="count($type)>0">

      <xsl:for-each select="$type">

        <xsl:if test="(position() mod 2)=0" >
          <xsl:call-template name="returns_type" >
            <xsl:with-param name="type" select="." />
            <xsl:with-param name="class">tablebg_odd</xsl:with-param>                        
          </xsl:call-template>
        </xsl:if>

        <xsl:if test="(position() mod 2)=1" >
          <xsl:call-template name="returns_type" >
            <xsl:with-param name="type" select="." />
            <xsl:with-param name="class">tablebg_even</xsl:with-param>                        
          </xsl:call-template>
        </xsl:if>
        
      </xsl:for-each>

    </xsl:if>

    </table>
    <br />

  </xsl:if>

</xsl:template>

<xsl:template name="description">

  <div class="feature_section_title">Description:</div>

  <xsl:if test="string-length(description/text())>0">
    <!-- display feature description (split lines with '\n') -->

    <div class="feature_description">
  <!--
      <xsl:for-each select="str:split(description/text(),'\n')">
  -->

      <xsl:call-template name="formatted_content">

        <xsl:with-param name="text" select="description/text()"/> 

      </xsl:call-template><br />

  <!--           
      </xsl:for-each>
  -->
    </div>
  </xsl:if>

  <xsl:if test="string-length(description/text())=0">
    <xsl:call-template name="div_warning">
      <xsl:with-param name="text">Incomplete documentation: No feature description defined</xsl:with-param>
    </xsl:call-template>
  </xsl:if>
  <br />

</xsl:template>

<xsl:template name="tests">

  <xsl:param name="tests" />

  <!-- examples -->
  <div class="feature_section_title">Examples:</div>

  <xsl:for-each select="$tests/scenario">

    <!-- description (splitted with '\n') -->
    <div class="scenario_description">

      <xsl:for-each select="str:split(description,'\n')">
        <xsl:value-of select="text()" /><br />
      </xsl:for-each>

    </div>

    <xsl:value-of select="@name"/>

    <pre class="{@status}">
      <xsl:text># scenario </xsl:text><xsl:value-of select="@status" /><br />
      <xsl:for-each select="str:split(example,'\n')">
        <xsl:value-of select="text()" /><br />
      </xsl:for-each>
    </pre>

  </xsl:for-each>
  
  <xsl:if test="count($tests/scenario)=0">
    <xsl:call-template name="div_warning">
      <xsl:with-param name="text">Incomplete documentation: No examples/test scenarios</xsl:with-param>
    </xsl:call-template>
  </xsl:if>

  <br />

</xsl:template>

<xsl:template name="info">

  <xsl:if test="string-length(info/text())>0">
     <!-- display feature description (split lines with '\n') -->
    <xsl:for-each select="str:split(info/text(),'\n')">
        <xsl:value-of select="." /><br />
    </xsl:for-each>
    <br />
  </xsl:if>
</xsl:template>

<xsl:template name="formatted_content">

  <xsl:param name="text"/>

  <xsl:variable name="text_with_linefeeds">
    <xsl:call-template name="split_lines">
      <xsl:with-param name="text" select="$text" />
    </xsl:call-template>  
  </xsl:variable>

<!--
  <xsl:value-of select="$text_with_linefeeds" /><br />

    -->
  <xsl:call-template name="process_tags">

    <xsl:with-param name="text" select="$text_with_linefeeds" />

  </xsl:call-template>
     
</xsl:template>

<xsl:template name="split_lines">

  <xsl:param name="text"/>

  <!-- content before \n -->
  <xsl:variable name="before_linefeed" select="substring-before($text, '\')"/>

  <!-- content after \n -->
  <xsl:variable name="after_linefeed" select="substring-after($text, '\')"/>

  <xsl:choose>
    <xsl:when test="substring(substring-after($text,'\'),1,1)='n'">
      <xsl:value-of select="$before_linefeed" /><xsl:text>[br]</xsl:text>
      <xsl:call-template name="split_lines">
        <xsl:with-param name="text" select="substring($text,string-length($before_linefeed)+3,string-length($text))" />
      </xsl:call-template>
    </xsl:when>
    <xsl:otherwise>
      <xsl:value-of select="$text" />
    </xsl:otherwise>
  </xsl:choose>

</xsl:template>

<xsl:template name="process_tags">

  <xsl:param name="text"/>

  <xsl:variable name="remainingContent" select="$text"/>

  <!-- content before start tag -->
  <xsl:variable name="content_before_tag" select="substring-before($text, '[')"/>

  <!-- content after start tag -->
  <xsl:variable name="content_after_tag" select="substring-after(substring-after($text, '['), ']')"/>

  <!-- start tag -->
  <xsl:variable name="tag" select="substring-after(substring-before($text, ']'), '[')"/>

  <!-- content between tag -->
  <xsl:variable name="tag_content" select="substring-before($content_after_tag, concat('[/', $tag, ']'))"/>

  <xsl:variable name="content_after_start_tag" select="substring-after($text, concat('[',$tag,']'))"/>

  <xsl:variable name="content_after_end_tag" select="substring-after($content_after_tag, concat('[/', $tag, ']'))"/>

<!--
  <br /><b>tag: </b><xsl:value-of select="$tag" />
  <br /><b>before: </b><xsl:value-of select="$content_before_tag" />
  <br /><b>after: </b><xsl:value-of select="$content_after_tag" />
  <br /><b>content: </b><xsl:value-of select="$tag_content" />
  <br /><b>content_after_end_tag: </b><xsl:value-of select="$content_after_end_tag" />

  <br /><br />
  -->

  <!-- show leading text before tag... -->
  <xsl:value-of select="$content_before_tag" />

  <xsl:choose>
  
    <xsl:when test="string-length($tag)>0">
 
        <xsl:call-template name="process_tag" >
          <xsl:with-param name="tag" select="$tag" />
          <xsl:with-param name="content" select="$tag_content" />
          <xsl:with-param name="content_after" select="$content_after_end_tag" />
        </xsl:call-template>
    
        <xsl:if test="string-length($tag_content)=0">

          <xsl:call-template name="process_tags">              
            <xsl:with-param name="text" select="$content_after_start_tag" />
          </xsl:call-template>
        
        </xsl:if>
      
    </xsl:when>
  
    <xsl:otherwise>

      <xsl:value-of select="$text" />

    </xsl:otherwise>
  
  </xsl:choose>

</xsl:template>

<xsl:template name="process_tag" >

  <xsl:param name="tag" />
  <xsl:param name="content" />
  <xsl:param name="content_after" />

  <!--
  <br /><b>tag:</b> <xsl:value-of select="$tag" />
  <br /><b>content:</b> <xsl:value-of select="$content" />
  <br /><b>content_after:</b> <xsl:value-of select="$content_after" />
  -->

  <xsl:choose>
    <xsl:when test="$tag='b'">

      <b><xsl:call-template name="process_tags" >
        <xsl:with-param name="text" select="$content" />
      </xsl:call-template></b>

      <xsl:call-template name="process_tags" >
        <xsl:with-param name="text" select="$content_after" />
      </xsl:call-template>

    </xsl:when>

    <xsl:when test="$tag='u'">
      <u><xsl:call-template name="process_tags" >
        <xsl:with-param name="text" select="$content" />
      </xsl:call-template></u>
      <xsl:call-template name="process_tags" >
        <xsl:with-param name="text" select="$content_after" />
      </xsl:call-template>

    </xsl:when>

    <xsl:when test="$tag='i'">
      <i><xsl:call-template name="process_tags" >
        <xsl:with-param name="text" select="$content" />
      </xsl:call-template></i>
      <xsl:call-template name="process_tags" >
        <xsl:with-param name="text" select="$content_after" />
      </xsl:call-template>

    </xsl:when>

    <xsl:when test="$tag='br'">
      <br />
    </xsl:when>

    <xsl:otherwise>

      <xsl:choose>

        <xsl:when test="string-length($content)>0">
          <xsl:text>[</xsl:text><xsl:value-of select="$tag" /><xsl:text>]</xsl:text>
          <xsl:value-of select="$content" />
          <xsl:text>[/</xsl:text><xsl:value-of select="$tag" /><xsl:text>]</xsl:text>
        </xsl:when>

        <xsl:otherwise>
          <xsl:text>[</xsl:text><xsl:value-of select="$tag" /><xsl:text>]</xsl:text>
        </xsl:otherwise>
      
      </xsl:choose>

      <xsl:call-template name="process_tags" >
        <xsl:with-param name="text" select="$content_after" />
      </xsl:call-template>
    
    </xsl:otherwise>

  </xsl:choose>

</xsl:template>

</xsl:stylesheet>
