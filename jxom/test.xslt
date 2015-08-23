<?xml version="1.0" encoding="utf-8"?>
<!-- Test entry point. -->
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:t="http://www.bphx.com/jxom"
  xmlns:j="http://www.bphx.com/java-1.5/2008-02-07"
  xmlns="http://www.bphx.com/java-1.5/2008-02-07"
  xpath-default-namespace="http://www.bphx.com/java-1.5/2008-02-07"
  exclude-result-prefixes="xs t j">

  <xsl:include href="java-serializer.xslt"/>
  <xsl:include href="java-qualified-name-normalizer.xslt"/>
  <xsl:include href="java-name-normalizer.xslt"/>
  <xsl:include href="java-optimizer.xslt"/>
  <xsl:include href="java-complex-expression.xslt"/>
  <xsl:include href="java-optimize-unreacable-code.xslt"/>
  <xsl:include href="java-state-machine-generator.xslt"/>

  <xsl:output name="java"
    byte-order-mark="no" 
    encoding="utf-8" 
    method="text"/>

  <!-- Entry point. -->
  <xsl:template match="/t:files">
    <xsl:for-each select="t:file">
      <xsl:variable name="file-uri" as="xs:string"
        select="xs:string(resolve-uri(@name, base-uri()))"/>
      <xsl:variable name="result-uri" as="xs:string" select="
        replace($file-uri, '(.*)/(.*)\..*$', '$1/output/$2.java')"/>

      <xsl:message>
        <test>
          source: <xsl:value-of select="$file-uri"/>
          target: <xsl:value-of select="$result-uri"/>
        </test>
      </xsl:message>

      <xsl:variable name="unit" as="element()" select="document($file-uri)/*"/>

      <xsl:variable name="unit-0" as="element()" select="
        if 
        (
          $unit//(method, class-method)/
            t:can-convert-method-to-state-machine(.) != 'no'
        ) 
        then
          t:refactor-state-machine($unit)
        else
          $unit"/>

      <xsl:variable name="unit-1" as="element()" select="
        t:refactor-statements-with-complex-expressions($unit-0)"/>

      <xsl:variable name="unit-2" as="element()" select="
        if (t:is-name-normalization-required($unit-0)) then
          t:normalize-names($unit-1, ())
        else
          $unit-1"/>

      <xsl:variable name="unit-3" as="element()"
        select="t:optimize-type-qualifiers($unit-2)"/>

      <xsl:variable name="unit-4" as="element()" select="
        t:optimize-unreachable-code
        (
          $unit-3,
          false(),
          'NOTE: this is unreachable code.'
        )"/>

      <xsl:variable name="unit-final" as="element()" select="$unit-4"/>

      <!--
        Print warnings:
      -->
      <xsl:variable name="bookmarks" as="element()*"
        select="$unit-final//meta/bookmark"/>

      <xsl:for-each select="$bookmarks">
        <xsl:message>
          <xsl:sequence select="@* | node()"/>
          <xsl:text>
</xsl:text>
          <xsl:text> at: </xsl:text>
          <xsl:text>
</xsl:text>
          <xsl:sequence select="t:get-path(../..)"/>
        </xsl:message>
      </xsl:for-each>

      <xsl:variable name="tokens" as="item()*" select="t:get-unit($unit-final)"/>
      <xsl:variable name="lines" as="xs:string*" select="t:get-lines($tokens)"/>

      <xsl:result-document href="{$result-uri}" format="java">
        <xsl:sequence select="string-join($lines, '')"/>
      </xsl:result-document>
    </xsl:for-each>
  </xsl:template>

  <!-- Refactors state machines in the unit. -->
  <xsl:function name="t:refactor-state-machine" as="element()">
    <xsl:param name="unit" as="element()"/>

    <xsl:apply-templates mode="t:refactor-state-machine" select="$unit"/>
  </xsl:function>

  <xsl:template mode="t:refactor-state-machine" match="@* | node()">
    <xsl:copy>
      <xsl:apply-templates mode="#current" select="@* | node()"/>
    </xsl:copy>
  </xsl:template>

  <xsl:template mode="t:refactor-state-machine" match="method | class-method">
    <xsl:variable name="method" as="element()"
      select="t:optimize-unreachable-code(., false(), ())"/>
    <xsl:variable name="result" as="xs:string"
      select="t:can-convert-method-to-state-machine($method)"/>

    <xsl:choose>
      <xsl:when test="$result = 'yes'">
        <xsl:variable name="converted-method" as="element()" select="
          t:convert-method-to-state-machine
          (
            .,
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

</xsl:stylesheet>
