<?xml version="1.0" encoding="utf-8"?>
<!--
  This stylesheet serializes COBOL xml object model document down to
  the COBOL text.
 -->
<xsl:stylesheet version="2.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:t="http://www.bphx.com/cobol"
  xmlns:p="http://www.bphx.com/cobol/private/cobol-serializer-main"
  xmlns="http://www.bphx.com/cobol/2009-12-15"
  xpath-default-namespace="http://www.bphx.com/cobol/2009-12-15"
  exclude-result-prefixes="xs t p">

  <xsl:include href="cobol-serializer.xslt"/>
  <xsl:include href="cobol-names.xslt"/>
  <xsl:include href="cobol-name-normalizer.xslt"/>
  <xsl:include href="cobol-qualified-name-normalizer.xslt"/>
  <xsl:include href="cobol-complex-element.xslt"/>

  <xsl:output byte-order-mark="no" encoding="utf-8" method="text"/>

  <!-- Entry point. -->
  <xsl:template match="/program">
    <xsl:variable name="program" as="element()" select="."/>

    <xsl:variable name="complex-normalized-program" as="element()">
      <xsl:call-template name="t:normalize-complex-elements">
        <xsl:with-param name="program" select="$program"/>
        <xsl:with-param name="section-import-handler" as="element()">
          <p:section-import/>
        </xsl:with-param>
      </xsl:call-template>
    </xsl:variable>

    <!--<xsl:message select="$complex-normalized-program"/>-->

    <xsl:variable name="name-normalized-program-document" as="document-node()">
      <xsl:document>
        <xsl:sequence
          select="t:normalize-names($complex-normalized-program, (), 30)"/>
      </xsl:document>
    </xsl:variable>

    <xsl:variable name="name-normalized-program" as="element()"
      select="$name-normalized-program-document/program"/>

    <xsl:variable name="data-ref-normalized-program" as="element()"
      select="t:normalize-data-refs($name-normalized-program)"/>

    <!--<xsl:message select="$data-ref-normalized-program"/>-->

    <!-- Other steps, if any. -->

    <!--<xsl:variable name="result-program" as="element()"
      select="$program"/>-->
    <xsl:variable name="result-program" as="element()"
      select="$data-ref-normalized-program"/>

    <xsl:variable name="tokens" as="item()*"
      select="t:get-program($result-program)"/>

    <xsl:variable name="lines" as="xs:string*" select="t:get-lines($tokens)"/>

    <xsl:value-of select="$lines" separator=""/>
  </xsl:template>

  <!--
    A section import handler.
      $program - a program being refactored.
      $section-ref - a section-ref element.
  -->
  <xsl:template mode="t:call" match="p:section-import">
    <xsl:param name="program" as="element()"/>
    <xsl:param name="section-ref" as="element()"/>

    <section name="{$section-ref/@name}"/>
  </xsl:template>

  <!-- DEBUG: Streamer test. -->
  <!--<xsl:template match="/">
    <xsl:variable name="tokens" as="item()*">
      <xsl:sequence select="'STRING'"/>

      <xsl:sequence select="' '"/>
      <xsl:sequence select="$t:terminator"/>
      <xsl:sequence select="
        '01234567890123456789012345678901234567890123456789012345678901234567890123456789'"/>

      <xsl:sequence select="' '"/>
      <xsl:sequence select="$t:terminator"/>

      <xsl:sequence select="$t:unindent"/>
      <xsl:sequence select="'DELIMITED'"/>
      <xsl:sequence select="' '"/>
      <xsl:sequence select="'BY'"/>
      <xsl:sequence select="$t:indent"/>

      <xsl:sequence select="' '"/>
      <xsl:sequence select="$t:terminator"/>

      <xsl:sequence select="'SIZE'"/>

      <xsl:sequence select="' '"/>
      <xsl:sequence select="$t:terminator"/>

      <xsl:sequence select="$t:unindent"/>
      <xsl:sequence select="'INTO'"/>
      <xsl:sequence select="$t:indent"/>

      <xsl:sequence select="' '"/>
      <xsl:sequence select="'XXXXXXXXXXXXX'"/>
    </xsl:variable>

    <xsl:variable name="lines" as="xs:string*" select="t:get-lines($tokens)"/>

    <xsl:result-document encoding="utf-8" method="text">
      <xsl:sequence select="string-join($lines, '')"/>
    </xsl:result-document>
  </xsl:template>-->

</xsl:stylesheet>