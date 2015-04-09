<?xml version="1.0" encoding="utf-8"?>
<!--
  This stylesheet serializes C# xml object model document down to
  the C# text.
-->
<xsl:stylesheet version="2.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:t="http://www.bphx.com/csharp"
  xmlns="http://www.bphx.com/csharp-3.0/2009-05-23"
  xpath-default-namespace="http://www.bphx.com/csharp-3.0/2009-05-23"
  exclude-result-prefixes="xs t">

  <xsl:include href="csharp-serializer.xslt"/>
  <xsl:include href="csharp-name-normalizer.xslt"/>
  <xsl:include href="csharp-names.xslt"/>
  <xsl:include href="csharp-namespace-normalizer.xslt"/>
  <xsl:include href="csharp-complex-expression.xslt"/>
  <xsl:include href="csharp-optimizer.xslt"/>

  <xsl:output byte-order-mark="yes" encoding="utf-8" method="text"/>

  <!-- Entry point. -->
  <xsl:template match="/unit">
    <xsl:variable name="unit" as="element()" select="."/>

    <!-- Optional step: simplify complex expressions. -->
    <xsl:variable name="unit-with-simplified-complex-expressions" as="element()"
      select="t:optimize-complex-expressions($unit)"/>

    <!-- Optional step: Normalize names. -->
    <xsl:variable name="name-normalized-unit" as="element()" select="
      t:normalize-names($unit-with-simplified-complex-expressions, ())"/>

    <!-- Optional step: Normalize type qualifiers. -->
    <xsl:variable name="namespace-normalized-unit" as="element()"
      select="t:optimize-type-qualifiers($name-normalized-unit)"/>

    <xsl:variable name="tokens" as="item()*"
      select="t:get-unit($namespace-normalized-unit)"/>

    <xsl:variable name="lines" as="xs:string*" select="t:get-lines($tokens)"/>

    <xsl:value-of select="$lines" separator=""/>
  </xsl:template>

</xsl:stylesheet>