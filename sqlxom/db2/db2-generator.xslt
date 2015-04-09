<?xml version="1.0" encoding="utf-8"?>
<!--
  This stylesheet generates sql statement text.
-->
<xsl:stylesheet version="2.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:t="http://www.bphx.com/public/sql"
  xmlns:p="http://www.bphx.com/private/db2/sql-generator"
  xmlns:sql="http://www.bphx.com/basic-sql/2008-12-11"
  xmlns:db2="http://www.bphx.com/basic-sql/2008-12-11/db2"
  exclude-result-prefixes="t p xs">

  <xsl:include href="db2-serializer.xslt"/>

  <xsl:include href="../sql-streamer.xslt"/>
  <xsl:include href="../sql-serializer.xslt"/>
  <xsl:include href="../sql-optimizer.xslt"/>

  <xsl:output
    indent="yes"
    method="text"
    byte-order-mark="yes"
    encoding="utf-8"/>

  <!-- Entry point. -->
  <xsl:template match="/">
    <xsl:variable name="tokens" as="item()*"
      select="t:get-sql-statement-tokens(*)"/>

    <xsl:sequence select="
      string-join
      (
        t:get-lines(p:format-sql-tokens($tokens)),
        ''
      )"/>
  </xsl:template>

  <!--
    Format sql statement.
      $tokens - statement tokens.
      Returns formatted tokens.
  -->
  <xsl:function name="p:format-sql-tokens" as="item()*">
    <xsl:param name="tokens" as="item()*"/>

    <xsl:sequence select="
      for $item in $tokens return
        if ($item instance of element(sql:host-expression)) then
          '?'
        else
          $item"/>
  </xsl:function>

</xsl:stylesheet>
