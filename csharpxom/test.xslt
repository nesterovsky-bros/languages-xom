<?xml version="1.0" encoding="utf-8"?>
<!-- Test entry point. -->
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

  <xsl:output name="csharp"
    byte-order-mark="yes" 
    encoding="utf-8" 
    method="text"/>

  <!-- Entry point. -->
  <xsl:template match="/t:files">
    <xsl:for-each select="t:file">
      <xsl:variable name="file-uri" as="xs:string"
        select="xs:string(resolve-uri(@name, base-uri()))"/>
      <xsl:variable name="result-uri" as="xs:string" select="
        replace($file-uri, '(.*)/(.*)\..*$', '$1/output/$2.cs')"/>

      <xsl:message>
        <test>
          source: <xsl:value-of select="$file-uri"/>
          target: <xsl:value-of select="$result-uri"/>
        </test>
      </xsl:message>

      <xsl:variable name="unit" as="element()"
        select="document($file-uri)/*"/>

      <!-- Optional step: simplify complex expressions. -->
      <xsl:variable name="unit-with-simplified-complex-expressions" 
        as="element()"
        select="t:optimize-complex-expressions($unit)"/>

      <!-- Optional step: Normalize names. -->
      <xsl:variable name="name-normalized-unit" as="element()" select="
        t:normalize-names($unit-with-simplified-complex-expressions, ())"/>

      <!-- Optional step: Normalize type qualifiers. -->
      <xsl:variable name="namespace-normalized-unit" as="element()"
        select="t:optimize-type-qualifiers($name-normalized-unit)"/>

      <xsl:variable name="tokens" as="item()*"
        select="t:get-unit($namespace-normalized-unit)"/>

      <xsl:variable name="lines" as="xs:string*" 
        select="t:get-lines($tokens)"/>

      <xsl:result-document href="{$result-uri}" format="csharp">
        <xsl:sequence select="string-join($lines, '')"/>
      </xsl:result-document>
    </xsl:for-each>
  </xsl:template>

</xsl:stylesheet>
