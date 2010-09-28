<?xml version="1.0" encoding="ISO-8859-1"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:str="http://exslt.org/strings" extension-element-prefixes="str">
<xsl:template match="/">
<html>
  <head>
    <style  TYPE="text/css">
      
      tr.header
      {      
        background: #96E066;
        font-weight: bold;
      }

      td.tablebg_even
      {
        background: #ededed;
      }

      td.tablebg_odd
      {
        background: #dedede;
      }

      td.tablebg_disabled
      {
        background: #c5c5c5;
      }

      body
      {
        padding: 10px;
        border: #e7e7e7 1px solid;
        background: #ffffff;
        color: black;
        font-size: 13px;
      }

      pre.passed,pre.failed,pre.skipped{
      
        margin: 5px 2px 9px 2px;
        padding: 10px 10px 10px 8px;
            
      }

      pre.passed
      {
        border: #e7e7e7 1px solid;
        background: #f1f1f1;
        color: black;
      }

      pre.failed
      {
        border: #b70707 1px solid;
        background: #a11010;
        color: black;
      }

      pre.skipped
      {
        border: #b7b7b7 1px solid;
        background: #c1c1c1;
        color: #818181;
      }

      td.missing,div.missing
      {
        background: #a11010;
        color: #ffffff;
      }

    </style>
  </head>
  <body>
    <h2>Documentation</h2>
    <xsl:apply-templates/>
  </body>
</html>
</xsl:template>

<xsl:template name="feature_name">

  <!-- implements following features, e.g. method name, attribute reader, attribute writer or both when attribute accessor -->
  <xsl:for-each select="str:split(@name,';')">
    <b><u><xsl:value-of select="."/></u></b><br />
  </xsl:for-each>
  <br />

</xsl:template>

<xsl:template name="call_sequence">

  <b>Call sequence:</b><br />
  <small>

    <!-- method: call example using parameters -->
    <xsl:if test="@type='method'">
    
      object.<xsl:value-of select="@name" />

      <xsl:choose>

        <xsl:when test="count(arguments/argument)=0">()</xsl:when>
        
        <xsl:when test="count(arguments/argument)>0">
          (      
            <!-- collect arguments for example -->
            <xsl:for-each select="arguments/argument">

              <xsl:if test="@type='argument'">
              
                <xsl:if test="@optional='true'">[</xsl:if>                     
                <xsl:value-of select="@name"/>
                <xsl:if test="@optional='true'">]</xsl:if> 

                <!-- separate arguments with comma if next argument defintion is not type of block --> 
                <xsl:if test="position()!=last() and following-sibling::argument/@type!='block'">
                  <xsl:text>, </xsl:text>
                </xsl:if>
                
              </xsl:if>
              
            </xsl:for-each>
          )
          
          <!-- collect arguments for example -->
          <xsl:for-each select="arguments/argument">

                <xsl:if test="./@type='block'">
                
                  <xsl:text>{ </xsl:text><xsl:value-of select="@name"/><xsl:text> }</xsl:text>
                
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
      return_value = object.<xsl:value-of select="str:split(@name,';')[1]" /><br />
    </xsl:if>

    <!-- attr_writer/attr_accessor: call example -->
    <xsl:if test="@type='writer' or @type='accessor'">
      <!-- TODO: argument name from arguments array -->
      object.<xsl:value-of select="str:split(@name,';')[1]" /> = ( value )<br />
    </xsl:if>

  </small>
  <br />

</xsl:template>

<!-- template to capitalize string -->
<xsl:template name="capitalize">

  <xsl:param name="text" />
  
  <xsl:value-of select="concat(translate(substring($text,1,1), 'abcdefghijklmnopqrstuvwxyz','ABCDEFGHIJKLMNOPQRSTUVWXYZ'), substring($text,2))"/>

</xsl:template>

<xsl:template name="target_details">
<!--

  <feature type="method" object_type="*;sut" required_plugin="*" sut_type="qt" sut_version="*" name="flick" input_type="touch">
    <behaviour module="MobyBehaviour::QT::Gesture" name="QtExampleGestureBehaviour"/>


  Feature type: <b><xsl:value-of select="@type" /></b><br />
  object type: <b><xsl:value-of select="@object_type" /></b><br />
  required plugin: <b><xsl:value-of select="@required_plugin" /></b><br />
  sut_type: <b><xsl:value-of select="@sut_type" /></b><br />
  sut_version: <b><xsl:value-of select="@sut_version" /></b><br />
  input_type: <b><xsl:value-of select="@input_type" /></b><br />
  behaviour_name: <b><xsl:value-of select="behaviour/@name" /></b><br />
  behaviour_module: <b><xsl:value-of select="behaviour/@module" /></b><br />

  <br />
-->
  
  <b>Feature and target details</b>
  <table width="100%" align="center" cellpadding="2" cellspacing="1" border="0">
    <tr class="header">
      <td>Type</td>
      <td>Target object(s)</td>
      <td>SUT type(s)</td>
      <td>SUT version(s)</td>
      <td>SUT input type(s)</td>
      <td>Behaviour module</td>
      <td>Required plugin</td>
    </tr>
    <tr>
      <td class="tablebg_even" valign="top">

        <!-- capitalize text() -->
        <xsl:call-template name="capitalize">
         <xsl:with-param name="text" select="@type" />
        </xsl:call-template>    
      
      </td>
                  
      <!-- target object -->
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

      <!-- target sut -->
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

      <!-- sut version -->
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

      <!-- input type -->
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

      <!-- behaviour module -->
      <td class="tablebg_even" valign="top"><xsl:value-of select="behaviour/@module" /></td>

      <!-- required plugin -->
      <xsl:if test="@required_plugin='*'">
        <td class="tablebg_disabled" valign="top"></td>
      </xsl:if>

      <xsl:if test="@required_plugin!='*'">
        <td class="tablebg_even" valign="top">
          <xsl:value-of select="@required_plugin" />
        </td>
      </xsl:if>
    </tr>

  </table>
  <br />

</xsl:template>

<xsl:template match="feature">

  <xsl:call-template name="feature_name" />
  
  <xsl:apply-templates select="description" />

  <xsl:call-template name="call_sequence" />

  <xsl:call-template name="target_details" />

  <xsl:call-template name="arguments" />

  <xsl:call-template name="returns">
    <xsl:with-param name="type" select="returns/type" />
    <xsl:with-param name="feature_type" select="@type" />
  </xsl:call-template>

  <xsl:call-template name="exceptions">
    <xsl:with-param name="type" select="returns/type" />
    <xsl:with-param name="feature_type" select="@type" />
  </xsl:call-template>

  <!--<xsl:apply-templates select="exceptions" />-->
  
  <xsl:apply-templates select="info" />
  
</xsl:template>

<xsl:template name="exceptions">

  <xsl:param name="type" />
  <xsl:param name="feature_type" />

  <xsl:if test="count($type)>0">
  
    <!-- exceptions -->
    <b>Exceptions</b>

    <table width="100%" align="center" cellpadding="2" cellspacing="1" border="0">
    <tr class="header">
      <td>Type</td>
      <td>Description</td>
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

<xsl:template match="tests">

  <!-- examples -->
  <b>Examples</b>
  <br />

  <xsl:for-each select="scenario">

    <!-- description (splitted with '\n') -->
    <small>description:
    <xsl:for-each select="str:split(description,'\n')">
      <xsl:value-of select="text()" /><br />
    </xsl:for-each>
    </small>
    <xsl:value-of select="@name"/>
    <xsl:element name="pre">
      <xsl:attribute name="class">
        <xsl:value-of select="@status"/>
      </xsl:attribute>
      <xsl:text># scenario </xsl:text><xsl:value-of select="@status" /><br />
      <xsl:for-each select="str:split(example,'\n')">
        <xsl:value-of select="text()" /><br />
      </xsl:for-each><br />
    </xsl:element>                        

  </xsl:for-each>

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
        <td rowspan="{$argument_types}" class="{ $class }"><xsl:value-of select="$argument_name" /></td>
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

  <b>Arguments</b><br />
  <table width="100%" align="center" cellpadding="2" cellspacing="1" border="0">
  <tr class="header">
    <td>Name</td>
    <td>Type</td>
    <td>Description</td>
    <td>Example</td>
    <td>Default</td>
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
  
  <!-- show error message if argument are not described -->
  <xsl:if test="count(argument)&lt;@count">
    <tr>
    <td colspan="5" class="missing">
      Incomplete documentation: only <xsl:value-of select="count(argument)" />  of <xsl:value-of select="@count" /> arguments documented
    </td>
    </tr>
  </xsl:if>

  </table>
  <br />

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

<xsl:template name="returns">

  <xsl:param name="type" />
  <xsl:param name="feature_type" />

  <!-- show return value types table if feature type is method, reader or accessor -->
  <!--<xsl:if test="@type='reader' or @type='accessor' or @type='method'"> -->
  <!-- return values -->
  <b>Returns</b>
  <table width="100%" align="center" cellpadding="2" cellspacing="1" border="0">
  <tr class="header">
    <td>Type</td>
    <td>Description</td>
    <td>Example</td>
  </tr>

  <!-- show error message if no return values defined -->
  <xsl:if test="( count($type)=0 ) and (($feature_type='method') or ($feature_type='accessor') or ($feature_type='reader'))">
    <tr><td colspan="3" class="missing">Incomplete documentation: No return value type(s) defined for method, attribute reader or attribute accessor</td></tr>
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

</xsl:template>

<xsl:template match="description">

  <b>Description<br /></b>

  <xsl:if test="string-length(text())>0">
    <!-- display feature description (split lines with '\n') -->
    <xsl:for-each select="str:split(text(),'\n')">
        <xsl:value-of select="." /><br />
    </xsl:for-each>
    <br />
  </xsl:if>

  <xsl:if test="string-length(text())=0">
    <div class="missing">Incomplete documentation: No feature description defined</div>
    <br />
  </xsl:if>

</xsl:template>

<xsl:template match="info">

  <!-- display feature description (split lines with '\n') 
  -->
  <xsl:for-each select="str:split(text(),'\n')">
      <xsl:value-of select="." /><br />
  </xsl:for-each>
  <br />

</xsl:template>

</xsl:stylesheet>
