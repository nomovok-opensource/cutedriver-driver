<?xml version="1.0" encoding="ISO-8859-1"?>
<!-- Edited by XMLSpy® -->
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:str="http://exslt.org/strings" extension-element-prefixes="str">

  <xsl:template match="/">

    <html>

      <body>

        <h2>Documentation</h2>

        <xsl:for-each select="features/feature">

          <!-- feature type: "method", (attribute) "reader", (attribute) "writer" or (attribute) "accessor" ) -->
          type: <xsl:value-of select="@type" />

          <!-- implements following features, e.g. method name, attribute reader, attribute writer or both when attribute accessor -->
          implements: <xsl:for-each select="str:split(@name,';')">
          <!--<xsl:for-each select="str:tokenize(@name,';')">-->
            <xsl:value-of select="."/><xsl:text> </xsl:text>
          </xsl:for-each>

          <!-- display feature description (split lines with '\n') -->
          description: <xsl:for-each select="str:split(description,'\n')" name="value">
              <xsl:value-of select="." /><br />
          </xsl:for-each>

          <!-- behaviour name -->
          behaviour_name: <xsl:value-of select="behaviour/@name" />

          <!-- behaviour module -->
          module_name: <xsl:value-of select="behaviour/@module" />

          <!-- required plugin -->
          required_plugin: <xsl:value-of select="@required_plugin" />

          <!-- feature is applied to following sut types, remember to use xsl:for-each -->
          sut_types: <xsl:for-each select="str:split(@sut_type,';')">
             <xsl:value-of select="." /><xsl:text>&nbsp;</xsl:text>
          </xsl:for-each>

          <!-- feature is applied to following sut versions, remember to use xsl:for-each -->
          sut_versions: <xsl:for-each select="str:split(@sut_version,';')">
             <xsl:value-of select="." /><xsl:text>&nbsp;</xsl:text>
          </xsl:for-each>

          <!-- feature is applied to suts with following input type, remember to use xsl:for-each -->
          input_types: <xsl:for-each select="str:split(@input_type,';')">
             <xsl:value-of select="." /><xsl:text>&nbsp;</xsl:text>
          </xsl:for-each>

          <!-- total number of arguments that can be passed to feature, note that this includes count of optinal arguments -->
          arguments_count: <xsl:value-of select="arguments/@count" />

          <!-- total number of optional arguments, required arguments = arguments_count - optional_arguments_count -->
          optional_arguments_count:<xsl:value-of select="arguments/@optional" />

          <!-- arguments-documented -->
          documented_arguments_count: <xsl:value-of select="arguments/@described"/>

          <!-- arguments element -->
          arguments: <xsl:for-each select="arguments/argument">

            name: <xsl:value-of select="@name"/>
            optional: <xsl:value-of select="@optional"/>
            default_value: <xsl:value-of select="@default"/>
            <xsl:for-each select="./type">
              type_name: <xsl:value-of select="name"/>
              type_example: <xsl:value-of select="example"/>
              type_description: <xsl:for-each select="str:split(description,'\n')" name="value">
                <xsl:value-of select="text()" /><br />
              </xsl:for-each>
            </xsl:for-each>

          </xsl:for-each>

            returns_described: <xsl:value-of select="returns/@described"/>

          <!-- returns element -->
          <xsl:for-each select="returns/type">

            returns_name: <xsl:value-of select="@name"/>
            returns_example: <xsl:value-of select="example"/>
            <!-- return value description (splitted with '\n') -->
            returns_description: <xsl:for-each select="str:split(description,'\n')">
              <xsl:value-of select="text()" /><br />
            </xsl:for-each>

          </xsl:for-each>

            exceptions_described: <xsl:value-of select="exceptions/@described"/>

          <!-- exceptions element -->
          <xsl:for-each select="exceptions/type">

            exception_type: <xsl:value-of select="@name"/>
            <!-- description (splitted with '\n') -->
            exception_description: <xsl:for-each select="str:split(description,'\n')">
              <xsl:value-of select="text()" /><br />
            </xsl:for-each>
          </xsl:for-each>

            tests_count: <xsl:value-of select="tests/@count"/>
            tests_passed: <xsl:value-of select="tests/@passed"/>
            tests_failed: <xsl:value-of select="tests/@failed"/>
            tests_skipped: <xsl:value-of select="tests/@skipped"/>

          <!-- tests element -->
          <xsl:for-each select="tests/scenario">

            type: <xsl:value-of select="@type"/>
            status: <xsl:value-of select="@status"/>


            <!-- description (splitted with '\n') -->
            scenario_description: <xsl:for-each select="str:split(description,'\n')">
              <xsl:value-of select="text()" /><br />
            </xsl:for-each>
            scenario_example: <xsl:for-each select="str:split(example,'\n')">
              <xsl:value-of select="text()" /><br />
            </xsl:for-each>
          </xsl:for-each>

          <!-- feature info/additional description, e.g. see related features x, y -->
          info: <xsl:for-each select="str:split(info/.,'\n')" name="value">
              <xsl:value-of select="." /><br />
          </xsl:for-each>

        </xsl:for-each>

      </body>
    </html>

  </xsl:template>

</xsl:stylesheet>
