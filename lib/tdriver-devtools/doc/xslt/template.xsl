<?xml version="1.0" encoding="ISO-8859-1"?>
<!-- Edited by XMLSpy® -->
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

      body
      {
        padding: 10px;
        border: #e7e7e7 1px solid;
        background: #ffffff;
        color: black;
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

      
    </style>
  </head>

  <body>

        <h2>Documentation</h2>

        <xsl:for-each select="features/feature">

          <!-- implements following features, e.g. method name, attribute reader, attribute writer or both when attribute accessor -->
          <xsl:for-each select="str:split(@name,';')">
          <!--<xsl:for-each select="str:tokenize(@name,';')">-->
            <b><xsl:value-of select="."/></b><br />
          </xsl:for-each>
          <br />

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

                      <xsl:if test="@optional='true'"><xsl:text>[</xsl:text></xsl:if>                     
                      <xsl:value-of select="@name"/>
                      <xsl:if test="@optional='true'"><xsl:text>]</xsl:text></xsl:if> 

                      <xsl:if test="position()!=last()">
                      <xsl:text>, </xsl:text>
                      </xls:if>
                    </xsl:for-each>
                  )
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
              return_value = object.<xsl:value-of select="@name" /><br />
            </xsl:if>

            <!-- attr_writer/attr_accessor: call example -->
            <xsl:if test="@type='writer' or @type='accessor'">
              <!-- TODO: argument name from arguments array -->
              object.<xsl:value-of select="@name" /> = ( value )<br />
            </xsl:if>

          </small>
          <br />
          
          <!-- display feature description (split lines with '\n') -->
          <xsl:for-each select="str:split(description,'\n')" name="value">
              <xsl:value-of select="." /><br />
          </xsl:for-each>
          <br />
          
          <b>Arguments</b><br />

          <table width="100%" align="center" cellpadding="2" cellspacing="1" border="0">
          <tr class="header">
            <td>Name</td>
            <td>Type</td>
            <td>Description</td>
            <td>Example</td>
            <td>Default</td>
          </tr>
          <!-- arguments element -->
          <xsl:for-each select="arguments/argument">
            <tr valign="top">
            <!-- <tr rowspan="#"> -->
            <xsl:element name="td">
             <xsl:attribute name="rowspan">
              <xsl:value-of select="count(type)+1">
             </xsl:attribute>
            </xsl:element>
            <xsl:value-of select="@name"/></td>
            <!--<td>optional: <xsl:value-of select="@optional"/></td>
            <td>default_value: <xsl:value-of select="@default"/></td>-->
            <xsl:for-each select="type">
              <td><xsl:value-of select="@name"/></td>
              <td><xsl:for-each select="str:split(description,'\n')" name="value">
                <xsl:value-of select="text()" /><br />
              </xsl:for-each>
              </td>
              <td><xsl:value-of select="example"/></td>
              <td><xsl:value-of select="default"/></td>
              <xsl:if test="position()!=1">
               </tr><tr>
              </xsl:if>
            </xsl:for-each>
            </tr>            
          </xsl:for-each>
          </table>
          <br />

          <!-- return values -->
          <b>Returns</b>
          <table width="100%" align="center" cellpadding="2" cellspacing="1" border="0">
          <tr class="header">
            <td>Type</td>
            <td>Description</td>
            <td>Example</td>
          </tr>
          <xsl:for-each select="returns/type">
            <tr valign="top">
              <td><xsl:value-of select="@name"/></td>
              <td><xsl:for-each select="str:split(description,'\n')" name="value">
                <xsl:value-of select="text()" /><br />
              </xsl:for-each>
              </td>
              <td><xsl:value-of select="example"/></td>
            </tr>
          </xsl:for-each>
          </table>
          <br />

          <!-- exceptions -->
          <b>Exceptions</b>
          <table width="100%" align="center" cellpadding="2" cellspacing="1" border="0">
          <tr class="header">
            <td>Type</td>
            <td>Description</td>
          </tr>
          <xsl:for-each select="exceptions/type">
            <tr valign="top">
              <td><xsl:value-of select="@name"/></td>
              <td><xsl:for-each select="str:split(description,'\n')" name="value">
                <xsl:value-of select="text()" /><br />
              </xsl:for-each>
              </td>
            </tr>
          </xsl:for-each>
          </table>
          <br />

          <!-- exceptions -->
          <b>Examples</b>
          <br />
          <!-- tests element 
          
            tests_count: <xsl:value-of select="tests/@count"/>
            tests_passed: <xsl:value-of select="tests/@passed"/>
            tests_failed: <xsl:value-of select="tests/@failed"/>
            tests_skipped: <xsl:value-of select="tests/@skipped"/>

          -->
          <xsl:for-each select="tests/scenario">

            <!--type: <xsl:value-of select="@type"/>
            status: <xsl:value-of select="@status"/>-->

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


          <!-- returns_described: <xsl:value-of select="returns/@described"/> -->                    
          <!-- feature type: "method", (attribute) "reader", (attribute) "writer" or (attribute) "accessor" ) -->
          <!-- type: <xsl:value-of select="@type" /> -->

          <!-- behaviour name -->
          <!--behaviour_name: <xsl:value-of select="behaviour/@name" />-->

          <!-- behaviour module -->
          <!--module_name: <xsl:value-of select="behaviour/@module" />-->

          <!-- required plugin -->
          <!--required_plugin: <xsl:value-of select="@required_plugin" />-->

          <!-- feature is applied to following sut types, remember to use xsl:for-each -->
          <!--sut_types: <xsl:for-each select="str:split(@sut_type,';')">
             <xsl:value-of select="." /><xsl:text>&nbsp;</xsl:text>
          </xsl:for-each>-->

          <!-- feature is applied to following sut versions, remember to use xsl:for-each -->
          <!--<sut_versions: <xsl:for-each select="str:split(@sut_version,';')">
             <xsl:value-of select="." /><xsl:text>&nbsp;</xsl:text>
          </xsl:for-each>-->

          <!-- feature is applied to suts with following input type, remember to use xsl:for-each -->
          <!--input_types: <xsl:for-each select="str:split(@input_type,';')">
             <xsl:value-of select="." /><xsl:text>&nbsp;</xsl:text>
          </xsl:for-each>-->

          <!-- total number of arguments that can be passed to feature, note that this includes count of optinal arguments -->
          <!--arguments_count: <xsl:value-of select="arguments/@count" />-->


          <!-- total number of optional arguments, required arguments = arguments_count - optional_arguments_count -->
          <!--optional_arguments_count:<xsl:value-of select="arguments/@optional" />-->

          <!-- arguments-documented -->
          <!--documented_arguments_count: <xsl:value-of select="arguments/@described"/>-->

          <!--exceptions_described: <xsl:value-of select="exceptions/@described"/>-->

          <br />
          <!-- display feature description (split lines with '\n') -->
          <xsl:for-each select="str:split(info,'\n')" name="value">
              <xsl:value-of select="." /><br />
          </xsl:for-each>
          <br />

      </body>
    </html>

  </xsl:template>

</xsl:stylesheet>
