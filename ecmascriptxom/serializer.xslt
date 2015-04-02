<?xml version="1.0" encoding="utf-8"?>
<!--
  This stylesheet serializes ecmascript xml object model document 
  into ecmascript text.
 -->
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns="http://www.nesterovsky-bros.com/ecmascript6/2015-02-20"
  xmlns:t="http://www.nesterovsky-bros.com/ecmascript"
  xmlns:js="http://www.nesterovsky-bros.com/ecmascript6/2015-02-20"
  xpath-default-namespace="http://www.nesterovsky-bros.com/ecmascript6/2015-02-20"
  exclude-result-prefixes="xs t js">

  <xsl:include href="common.xslt"/>
  <xsl:include href="streamer.xslt"/>
  <xsl:include href="serialize-comments.xslt"/>
  <xsl:include href="serialize-expressions.xslt"/>
  <xsl:include href="serialize-statements.xslt"/>

  <!--
    Gets a sequence of tokens for a script.
      $script - a script or module.
  -->
  <xsl:function name="t:get-script" as="item()*">
    <xsl:param name="script" as="element()"/>

    <xsl:choose>
      <xsl:when test="$script[self::script]">
        <xsl:sequence select="t:get-statements(t:get-elements(.))"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:call-template name="t:get-statements">
          <xsl:with-param name="statements" select="t:get-elements(.)"/>
          <xsl:with-param name="module-items" select="true()"/>
        </xsl:call-template>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:function>
  
  <!--
    Mode "t:module-item". import.    
  -->
  <xsl:template mode="t:module-item" match="import">
    <xsl:variable name="name" as="element()?" select="name"/>
    <xsl:variable name="namespace" as="element()?" select="namespace"/>
    <xsl:variable name="refs" as="element()*" select="ref"/>
    <xsl:variable name="from" as="element()" select="from"/>
    
    <xsl:sequence select="'import'"/>
    
    <xsl:if test="$name">
      <xsl:sequence select="' '"/>
      <xsl:sequence select="string($name/@value)"/>
    </xsl:if>
    
    <xsl:if test="$namespace">
      <xsl:variable name="namespace-name" as="element()" 
        select="$namespace/name"/>
          
      <xsl:if test="$name">
        <xsl:sequence select="','"/>
      </xsl:if>

      <xsl:sequence select="' '"/>
      <xsl:sequence select="'*'"/>
      <xsl:sequence select="' '"/>
      <xsl:sequence select="'as'"/>
      <xsl:sequence select="' '"/>
      <xsl:sequence select="string($namespace-name/@value)"/>
    </xsl:if>
    
    <xsl:if test="$refs">
      <xsl:if test="$name or $namespace">
        <xsl:sequence select="','"/>
      </xsl:if>
      
      <xsl:sequence select="$t:new-line"/>
      <xsl:sequence select="$t:indent"/>
      <xsl:sequence select="'{'"/>
      <xsl:sequence select="$t:new-line"/>

      <xsl:for-each select="$refs">
        <xsl:variable name="ref-name" as="element()?" select="name"/>
        
        <xsl:sequence select="string(@name)"/>
        
        <xsl:if test="$ref-name">
          <xsl:sequence select="' '"/>
          <xsl:sequence select="'as'"/>
          <xsl:sequence select="' '"/>
          <xsl:sequence select="string($ref-name/@value)"/>
        </xsl:if>
      
        <xsl:if test="position() != last()">
          <xsl:sequence select="','"/>
        </xsl:if>

        <xsl:sequence select="$t:new-line"/>
      </xsl:for-each>

      <xsl:sequence select="'}'"/>
      <xsl:sequence select="$t:unindent"/>
      <xsl:sequence select="$t:new-line"/>
    </xsl:if>
    
    <xsl:if test="$name or $namespace or $refs">
      <xsl:sequence select="' '"/>
      <xsl:sequence select="'from'"/>
      <xsl:sequence select="' '"/>
    </xsl:if>
    
    <xsl:sequence select="t:get-expression($from/string)"/>
    <xsl:sequence select="';'"/>
  </xsl:template>

  <!--
    Mode "t:module-item". export.    
  -->
  <xsl:template mode="t:module-item" match="export">
    <xsl:variable name="from" as="element()?" select="from"/>

    <xsl:sequence select="'export'"/>
    
    <xsl:choose>
      <xsl:when test="namespace">
        <xsl:sequence select="' '"/>
        <xsl:sequence select="'*'"/>
        <xsl:sequence select="' '"/>
        <xsl:sequence select="'from'"/>
        <xsl:sequence select="' '"/>
        <xsl:sequence select="t:get-expression($from/string)"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:variable name="refs" as="element()+" select="ref"/>
        
        <xsl:sequence select="$t:new-line"/>
        <xsl:sequence select="$t:indent"/>
        <xsl:sequence select="'{'"/>
        <xsl:sequence select="$t:new-line"/>

        <xsl:for-each select="$refs">
          <xsl:variable name="ref-name" as="element()?" select="name"/>
        
          <xsl:sequence select="string(@name)"/>
        
          <xsl:if test="$ref-name">
            <xsl:sequence select="' '"/>
            <xsl:sequence select="'as'"/>
            <xsl:sequence select="' '"/>
            <xsl:sequence select="string($ref-name/@value)"/>
          </xsl:if>
      
          <xsl:if test="position() != last()">
            <xsl:sequence select="','"/>
          </xsl:if>

          <xsl:sequence select="$t:new-line"/>
        </xsl:for-each>

        <xsl:sequence select="'}'"/>
        
        <xsl:if test="$from">
          <xsl:sequence select="$t:new-line"/>
          <xsl:sequence select="'from'"/>
          <xsl:sequence select="' '"/>
          <xsl:sequence select="t:get-expression($from/string)"/>
        </xsl:if>
        
        <xsl:sequence select="$t:unindent"/>
      </xsl:otherwise>
    </xsl:choose>

    <xsl:sequence select="';'"/>
  </xsl:template>

</xsl:stylesheet>