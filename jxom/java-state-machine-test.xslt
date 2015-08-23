<?xml version="1.0" encoding="utf-8"?>
<!--
  Test for the state machine generator.
-->
<xsl:stylesheet version="2.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:t="http://www.bphx.com/jxom"
  xmlns:p="http://www.bphx.com/jxom/private/java-state-machine-test"
  xmlns="http://www.bphx.com/java-1.5/2008-02-07"
  xpath-default-namespace="http://www.bphx.com/java-1.5/2008-02-07"
  exclude-result-prefixes="xs t p">

  <xsl:include href="java-state-machine-generator.xslt"/>
  <xsl:include href="java-qualified-name-normalizer.xslt"/>
  <xsl:include href="java-optimizer.xslt"/>
  <xsl:include href="java-name-normalizer.xslt"/>
  <xsl:include href="java-optimize-unreacable-code.xslt"/>
  <xsl:include href="java-serializer.xslt"/>

  <xsl:output
    indent="yes"
    byte-order-mark="yes"
    encoding="utf-8"
    method="xml"/>

  <xsl:output
    name="java"
    byte-order-mark="no"
    encoding="utf-8"
    method="text"/>

  <!-- Entry point. -->
  <xsl:template match="/unit">
    <xsl:result-document href="input.java" format="java">
      <xsl:value-of select="p:generate-java(.)" separator=""/>
    </xsl:result-document>

    <xsl:variable name="converted-unit">
      <xsl:apply-templates mode="p:generate-state-machine" select="."/>
    </xsl:variable>

    <xsl:sequence select="$converted-unit"/>

    <xsl:result-document href="output.java" format="java">
      <xsl:value-of select="p:generate-java($converted-unit/unit)"
        separator=""/>
    </xsl:result-document>
  </xsl:template>

  <xsl:template mode="p:generate-state-machine" match="@* | node()">
    <xsl:copy>
      <xsl:apply-templates mode="#current" select="@* | node()"/>
    </xsl:copy>
  </xsl:template>

  <xsl:template mode="p:generate-state-machine" match="class-method">
    <xsl:variable name="method" as="element()"
      select="t:optimize-unreachable-code(., false(), ())"/>
    <xsl:variable name="result" as="xs:string"
      select="t:can-convert-method-to-state-machine($method)"/>

    <xsl:choose>
      <xsl:when test="$result = 'yes'">
        <xsl:variable name="converted-method" as="element()" select="
          t:convert-method-to-state-machine
          (
            $method,
            concat(@name, 'AsStateMachine'),
            true(),
            false()
          )"/>

        <xsl:sequence select="t:normalize-names($converted-method, ())"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:if test="$result != 'no'">
          <scope>
            <meta>
              <bookmark>
                <warning>
                  <xsl:text>A metod: </xsl:text>
                  <xsl:value-of select="$method/@name"/>
                  <xsl:text> contains yield markers, but</xsl:text>
                  <xsl:text> cannot be converted into</xsl:text>
                  <xsl:text> a state machine.</xsl:text>
                  <xsl:text> A reason is: </xsl:text>
                  <xsl:value-of select="$result"/>
                  <xsl:text>.</xsl:text>
                </warning>
              </bookmark>
            </meta>
          </scope>
        </xsl:if>

        <xsl:sequence select="$method"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!--
    Generates java text.
      $unit - a java unit to generate.
      Returns java text.
  -->
  <xsl:function name="p:generate-java" as="xs:string*">
    <xsl:param name="unit" as="element()"/>

    <xsl:variable name="unit-1" as="element()"
      select="t:optimize-type-qualifiers($unit)"/>

    <!--
      Print warnings:
    -->
    <xsl:variable name="bookmarks" as="element()*"
      select="$unit-1//meta/bookmark"/>

    <xsl:if test="exists($bookmarks)">
      <xsl:variable name="new-line" as="item()*">
        <xsl:text disable-output-escaping="yes">
</xsl:text>
      </xsl:variable>

      <xsl:for-each select="$bookmarks">
        <xsl:message>
          <xsl:sequence select="@* | node()"/>
          <xsl:sequence select="$new-line"/>
          <xsl:text> at: </xsl:text>
          <xsl:sequence select="t:get-path(../..)"/>
          <xsl:sequence select="$new-line"/>
        </xsl:message>
      </xsl:for-each>
    </xsl:if>

    <xsl:variable name="tokens" as="item()*" select="t:get-unit($unit-1)"/>
    <xsl:variable name="lines" as="xs:string*" select="t:get-lines($tokens)"/>

    <xsl:sequence select="$lines"/>
  </xsl:function>

</xsl:stylesheet>
