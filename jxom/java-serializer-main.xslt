<?xml version="1.0" encoding="utf-8"?>
<!--
  This stylesheet serializes java xml object model document down to
  the java text.

  $Id$
 -->
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
  <xsl:include href="java-optimize-unreacable-code.xslt"/>

  <xsl:output byte-order-mark="no" encoding="utf-8" method="text"/>

  <!-- Entry point. -->
  <xsl:template match="/unit">
    <xsl:variable name="unit-1" as="element()" select="
      if (t:is-name-normalization-required(.)) then
        t:normalize-names(., ())
      else
        ."/>

    <xsl:message select="$unit-1"/>

    <xsl:variable name="unit-2" as="element()"
      select="t:optimize-type-qualifiers($unit-1)"/>

    <xsl:variable name="unit" as="element()" select="
      t:optimize-unreachable-code
      (
        $unit-2,
        false(),
        'NOTE: this is unreachable code.'
      )"/>

    <!--
      Print warnings:
    -->
    <xsl:variable name="bookmarks" as="element()*"
      select="$unit//meta/bookmark"/>

    <xsl:for-each select="$bookmarks">
      <xsl:message>
        <xsl:sequence select="@* | node()"/>
        <xsl:sequence select="$t:new-line"/>
        <xsl:text>
</xsl:text>
        <xsl:text> at: </xsl:text>
        <xsl:text>
</xsl:text>
        <xsl:sequence select="t:get-path(../..)"/>
      </xsl:message>
    </xsl:for-each>

    <xsl:variable name="tokens" as="item()*" select="t:get-unit($unit)"/>
    <xsl:variable name="lines" as="xs:string*" select="t:get-lines($tokens)"/>

    <xsl:value-of select="$lines" separator=""/>
  </xsl:template>

  <!-- Streammer test. -->
  <!--<xsl:template match="/">
    <xsl:variable name="tokens" as="item()*">
      <xsl:sequence select="'package'"/>
      <xsl:sequence select="' '"/>
      <xsl:sequence select="'A'"/>
      <xsl:sequence select="'.'"/>
      <xsl:sequence select="'B'"/>
      <xsl:sequence select="';'"/>
      <xsl:sequence select="$t:new-line"/>

      <xsl:sequence select="$t:new-line"/>

      <xsl:sequence select="'import'"/>
      <xsl:sequence select="' '"/>
      <xsl:sequence select="t:tokenize('A.B.C')"/>
      <xsl:sequence select="';'"/>
      <xsl:sequence select="$t:new-line"/>

      <xsl:sequence select="$t:begin-doc"/>
      <xsl:sequence select="$t:new-line"/>

      <xsl:sequence select="$t:doc"/>
      <xsl:sequence select="'this'"/>
      <xsl:sequence select="' '"/>
      <xsl:sequence select="'is'"/>
      <xsl:sequence select="' '"/>
      <xsl:sequence select="'class'"/>
      <xsl:sequence select="'.'"/>
      <xsl:sequence select="$t:new-line"/>

      <xsl:sequence select="$t:end-doc"/>
      <xsl:sequence select="$t:new-line"/>

      <xsl:sequence select="'public'"/>
      <xsl:sequence select="' '"/>
      <xsl:sequence select="'class'"/>
      <xsl:sequence select="' '"/>
      <xsl:sequence select="'A'"/>
      <xsl:sequence select="$t:new-line"/>

      <xsl:sequence select="'{'"/>
      <xsl:sequence select="$t:new-line"/>

      <xsl:sequence select="$t:indent"/>

      <xsl:sequence select="$t:comment"/>
      <xsl:sequence select="'this'"/>
      <xsl:sequence select="' '"/>
      <xsl:sequence select="'is'"/>
      <xsl:sequence select="' '"/>
      <xsl:sequence select="'comment'"/>
      <xsl:sequence select="'.'"/>
      <xsl:sequence select="$t:new-line"/>

      <xsl:sequence select="'public'"/>
      <xsl:sequence select="' '"/>
      <xsl:sequence select="'int'"/>
      <xsl:sequence select="' '"/>
      <xsl:sequence select="'a'"/>
      <xsl:sequence select="';'"/>
      <xsl:sequence select="$t:unindent"/>
      <xsl:sequence select="$t:new-line"/>


      <xsl:sequence select="'}'"/>
      <xsl:sequence select="$t:new-line"/>

      <xsl:variable name="indent-tokens" as="item()*">
        <xsl:sequence select="'public'"/>
        <xsl:sequence select="' '"/>
        <xsl:sequence select="'int'"/>
        <xsl:sequence select="' '"/>
        <xsl:sequence select="'b'"/>
        <xsl:sequence select="'='"/>
        <xsl:sequence select="$t:new-line"/>


        <xsl:sequence select="'5'"/>
        <xsl:sequence select="';'"/>
      </xsl:variable>

      <xsl:sequence select="t:indent-from-second-line($indent-tokens)"/>
      <xsl:sequence select="$t:new-line"/>

      <xsl:sequence select="'end'"/>
      <xsl:sequence select="'.'"/>
      <xsl:sequence select="$t:new-line"/>
    </xsl:variable>

    <xsl:variable name="lines" as="xs:string*"
      select="t:get-lines($tokens)"/>

    <xsl:value-of select="$lines" separator=""/>
  </xsl:template>-->

</xsl:stylesheet>
