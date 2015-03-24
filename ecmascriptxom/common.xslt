<?xml version="1.0" encoding="utf-8"?>
<!--
  This stylesheet provides common functions used during serialization.
-->
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:t="http://www.nesterovsky-bros.com/ecmascript"
  xmlns="http://www.nesterovsky-bros.com/ecmascript6/2015-02-20"
  xpath-default-namespace="http://www.nesterovsky-bros.com/ecmascript6/2015-02-20"
  exclude-result-prefixes="xs t">

  <!--
    Key to get element infos.
  -->
  <xsl:key name="t:name" match="*" use="xs:string(@name)"/>

  <!-- 
    Splits id list into into a sequence of ids.
      $value - a value to split.
      Returns a sequence of ids.
  -->
  <xsl:function name="t:ids" as="xs:string*">
    <xsl:param name="value" as="xs:string?"/>

    <xsl:sequence select="tokenize($value, '\s+')"/>
  </xsl:function>
  
  <!--
    Gets content elements except comments and meta information
      $element - an element to get content element for.
      Returns content elements.
  -->
  <xsl:function name="t:get-elements" as="element()*">
    <xsl:param name="element" as="element()"/>

    <xsl:sequence select="$element/(* except (comment, meta))"/>
  </xsl:function>

  <!--
    Get elements in a scope.
      $scope - a scope to get elements from comments and meta are not counted.
      Returns elements in a scope.
  -->
  <xsl:function name="t:get-scope-elements" as="element()*">
    <xsl:param name="scope" as="element()*"/>

    <xsl:sequence select="t:get-scope-elements($scope, false())"/>
  </xsl:function>

  <!--
    Get elements in a scope.
      $scope - a scope to get elements from
      $include-comments-and-meta - true to include comments and meta, and
        false otherwise.
      Returns elements in a scope.
  -->
  <xsl:function name="t:get-scope-elements" as="element()*">
    <xsl:param name="scope" as="element()*"/>
    <xsl:param name="include-comments-and-meta" as="xs:boolean"/>

    <xsl:sequence select="
      for $element in $scope/* return
        if (xs:boolean($element/self::block/@scope)) then
          t:get-scope-elements($element, $include-comments-and-meta)
        else
          $element
          [
            $include-comments-and-meta or
            not(self::comment or self::meta)
          ]"/>
  </xsl:function>

  <!--
    Gets statements that are children of a specified scope.
      $scope - a scope to get children statements for.
      Returns children statements in scope.
  -->
  <xsl:function name="t:get-scope-statements" as="element()*">
    <xsl:param name="scope" as="element()*"/>

    <xsl:apply-templates mode="t:get-children-statements"
      select="$scope"/>
  </xsl:function>

  <!--
    Mode "t:get-children-statements". Default match.
  -->
  <xsl:template mode="t:get-children-statements" match="*"/>

  <!--
    Mode "t:get-children-statements". function, generator-function.
  -->
  <xsl:template mode="t:get-children-statements" 
    match="function | generator-function">
    <xsl:sequence select="body/t:get-elements(.)"/>
  </xsl:template>

  <!--
    Mode "t:get-children-statements". label, block, body.
  -->
  <xsl:template mode="t:get-children-statements" match="block | label">
    <xsl:sequence select="t:get-elements(.)"/>
  </xsl:template>

  <!--
    Mode "t:get-children-statements". if.
  -->
  <xsl:template mode="t:get-children-statements" match="if">
    <xsl:sequence select="(then, else)/t:get-elements(.)"/>
  </xsl:template>

  <!--
    Mode "t:get-children-statements". switch.
  -->
  <xsl:template mode="t:get-children-statements" match="switch">
    <xsl:sequence select="(case/block | default)/t:get-elements(.)"/>
  </xsl:template>

  <!--
    Mode "t:get-children-statements". 
    while, do-while, for, for-in, for-of, with.
  -->
  <xsl:template mode="t:get-children-statements" 
    match="while | do-while | for | for-in | for-of | with">
    <xsl:sequence select="block/t:get-elements(.)"/>
  </xsl:template>

  <!--
    Mode "t:get-children-statements". try.
  -->
  <xsl:template mode="t:get-children-statements" match="try">
    <xsl:sequence 
      select="(try/block | catch/block | finally)/t:get-elements(.)"/>
  </xsl:template>

</xsl:stylesheet>