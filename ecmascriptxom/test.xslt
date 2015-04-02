<?xml version="1.0" encoding="utf-8"?>
<!--
  Test entry point.
-->
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns="http://www.nesterovsky-bros.com/ecmascript6/2015-02-20"
  xmlns:t="http://www.nesterovsky-bros.com/ecmascript"
  xpath-default-namespace="http://www.nesterovsky-bros.com/ecmascript6/2015-02-20"
  exclude-result-prefixes="xs t">

  <xsl:include href="serializer.xslt"/>
  <xsl:include href="name-normalizer.xslt"/>
  <xsl:include href="names.xslt"/>

  <xsl:output name="ecmascript" byte-order-mark="yes" encoding="utf-8" method="text"/>

  <!-- Entry point. -->
  <xsl:template match="/files">
    <xsl:for-each select="file">
      <xsl:variable name="file-uri" as="xs:anyURI" 
        select="resolve-uri(@name, base-uri())"/>
      <xsl:variable name="result-uri" as="xs:anyURI" select="
        replace($file-uri, '/(.*)\..*$', '/output/$1.js')"/>

      <xsl:variable name="script" as="document-node()"
        select="document($file-uri)/*"/>

      <!-- Optional step: Normalize names. -->
      <xsl:variable name="name-normalized-script" as="element()" 
        select="t:normalize-names($script, ())"/>

      <xsl:variable name="tokens" as="item()*"
        select="t:get-script($name-normalized-script)"/>

      <xsl:variable name="lines" as="xs:string*" 
        select="t:get-lines($tokens)"/>

      <xsl:result-document href="{$result-uri}" format="ecmascript">
        <xsl:sequence select="string-join($lines, '')"/>
      </xsl:result-document>
    </xsl:for-each>
  </xsl:template>

</xsl:stylesheet>