<?xml version="1.0" encoding="utf-8"?>
<!--
  This stylesheet provides API to resolve identifier names.
-->
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns="http://www.nesterovsky-bros.com/ecmascript6/2015-02-20"
  xmlns:t="http://www.nesterovsky-bros.com/ecmascript"
  xmlns:p="http://www.nesterovsky-bros.com/ecmascript/private/name-normalizer"
  xpath-default-namespace="http://www.nesterovsky-bros.com/ecmascript6/2015-02-20"
  xmlns:js="http://www.nesterovsky-bros.com/ecmascript6/2015-02-20"
  exclude-result-prefixes="xs t p js">

  <!--
    API to transform input making all names unique in their scopes.

    xs:boolean(@normalize) = true() is an indicator that a name normalization
    is required.
    
    @id - attribute is used to identify name element.
    @ref - attribute is used to identify named reference.
    
    <name> element may have @id attribute, and 
    <ref> element uses @ref attribute to refer to the name.
    
    object patterns use <ref> element to bind a name.
    In this case that <ref> element has @id attribute.
    
    Subject of normalization are named declarations, and labelled statements. 
  -->

  <!--
    Verifies whether the name normalization is required.
      $scope - a scope to check.
      Returns true if name normalization is required, and false otherwise.
  -->
  <xsl:function name="t:is-name-normalization-required" as="xs:boolean">
    <xsl:param name="scope" as="element()"/>

    <xsl:sequence select="
      $scope//(self::name, self::ref)/xs:boolean(@normalize) = true()"/>
  </xsl:function>

  <!--
    Normalizes names in a given scope.
      $scope - a scope to check.
      $names - a name pool.
      Returns scope, with names normalized.
  -->
  <xsl:function name="t:normalize-names" as="element()">
    <xsl:param name="scope" as="element()"/>
    <xsl:param name="names" as="xs:string*"/>

    <xsl:sequence select="t:normalize-names($scope, $names, true())"/>
  </xsl:function>

  <!--
    Normalizes names in a given scope.
      $scope - a scope to check.
      $names - a name pool.
      $check-normalization-required - true to check whether the normalization
        is required, and false to normalize unconditionally.
      Returns scope, with names normalized.
  -->
  <xsl:function name="t:normalize-names" as="element()">
    <xsl:param name="scope" as="element()"/>
    <xsl:param name="names" as="xs:string*"/>
    <xsl:param name="check-normalization-required" as="xs:boolean"/>

    <xsl:choose>
      <xsl:when test="
        $check-normalization-required and
        not(t:is-name-normalization-required($scope))">
        <xsl:sequence select="$scope"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:call-template name="t:normalize-names">
          <xsl:with-param name="scope" select="$scope"/>
          <xsl:with-param name="scope-names" tunnel="yes" select="$names"/>
        </xsl:call-template>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:function>

  <!--
    Mode "t:normalize-names". Default match.
  -->
  <xsl:template mode="t:normalize-names" match="text()">
    <xsl:sequence select="."/>
  </xsl:template>

  <!--
    Mode "t:normalize-names". Labelled statement.
      $label-ids - a list of name label identifiers in scope.
      $label-names - a list of resolved label names in scope.
  -->
  <xsl:template mode="t:normalize-names" 
    match="label/name[xs:boolean(@normalize)]">
    <xsl:param name="label-ids" tunnel="yes" as="xs:string*"/>
    <xsl:param name="label-names" tunnel="yes" as="xs:string*"/>

    <xsl:variable name="id" as="xs:string" select="@id"/>
    <xsl:variable name="index" as="xs:integer"
      select="index-of($label-ids, $id)"/>
    <xsl:variable name="name" as="xs:string" select="$label-names[$index]"/>

    <xsl:copy>
      <xsl:sequence select="@* except (@value, @normalize)"/>
      <xsl:attribute name="value" select="$name"/>
      <xsl:apply-templates mode="#current"/>
    </xsl:copy>
  </xsl:template>

  <!--
    Mode "t:normalize-names". Breakable statement.
      $label-ids - a list of name label identifiers in scope.
      $label-names - a list of resolved label names in scope.
  -->
  <xsl:template mode="t:normalize-names" match="
    break/ref[xs:boolean(@normalize)] | 
    continue/ref[xs:boolean(@normalize)]">
    <xsl:param name="label-ids" tunnel="yes" as="xs:string*"/>
    <xsl:param name="label-names" tunnel="yes" as="xs:string*"/>

    <xsl:variable name="id" as="xs:string" select="@ref"/>
    <xsl:variable name="index" as="xs:integer"
      select="index-of($label-ids, $id)"/>
    <xsl:variable name="name" as="xs:string" select="$label-names[$index]"/>

    <xsl:copy>
      <xsl:sequence select="@* except (@name, @normalize)"/>
      <xsl:attribute name="name" select="$name"/>
      <xsl:apply-templates mode="#current"/>
    </xsl:copy>
  </xsl:template>

  <!--
    Mode "t:normalize-names". Name clause.
      $scope-ids - a list of name identifiers in scope.
      $scope-names - a list of resolved names in scope.
  -->
  <xsl:template mode="t:normalize-names" match="name[xs:boolean(@normalize)]">
    <xsl:param name="scope-ids" tunnel="yes" as="xs:string*"/>
    <xsl:param name="scope-names" tunnel="yes" as="xs:string*"/>

    <xsl:variable name="id" as="xs:string" select="@id"/>
    <xsl:variable name="index" as="xs:integer"
      select="index-of($scope-ids, $id)"/>
    <xsl:variable name="name" as="xs:string" select="$scope-names[$index]"/>

    <xsl:copy>
      <xsl:sequence select="@* except (@value, @normalize)"/>
      <xsl:attribute name="value" select="$name"/>
      <xsl:apply-templates mode="#current"/>
    </xsl:copy>
  </xsl:template>

  <!--
    Mode "t:normalize-names". Ref clause.
      $scope-ids - a list of name identifiers in scope.
      $scope-names - a list of resolved names in scope.
  -->
  <xsl:template mode="t:normalize-names" match="ref[xs:boolean(@normalize)]">
    <xsl:param name="scope-ids" tunnel="yes" as="xs:string*"/>
    <xsl:param name="scope-names" tunnel="yes" as="xs:string*"/>

    <xsl:variable name="id" as="xs:string" select="@id, @ref"/>
    <xsl:variable name="index" as="xs:integer"
      select="index-of($scope-ids, $id)"/>
    <xsl:variable name="name" as="xs:string" select="$scope-names[$index]"/>

    <xsl:copy>
      <xsl:sequence select="@* except (@name, @normalize)"/>
      <xsl:attribute name="name" select="$name"/>
      <xsl:apply-templates mode="#current"/>
    </xsl:copy>
  </xsl:template>

  <!--
    Mode "t:normalize-names". Match scope element.
      $scope - a scope element.
      $scope-ids - a list of name identifiers in scope.
      $scope-names - a list of resolved names in scope.
      $label-ids - a list of name label identifiers in scope.
      $label-names - a list of resolved label names in scope.
  -->
  <xsl:template name="t:normalize-names" mode="t:normalize-names" match="
    function | 
    generator-function |
    get-function |
    set-function |
    class">

    <xsl:param name="scope" as="element()" select="."/>
    <xsl:param name="scope-ids" tunnel="yes" as="xs:string*"/>
    <xsl:param name="scope-names" tunnel="yes" as="xs:string*"/>

    <xsl:variable name="total-names" as="element()*"
      select="p:get-scope-names($scope)"/>
    <xsl:variable name="new-labels" as="element()*" 
      select="$total-names[parent::label]"/>
    <xsl:variable name="new-names" as="element()*" select="
      $total-names[not(parent::label or parent::break or parent::continue)]"/>
    
    <xsl:variable name="name-pool" as="xs:string*" select="
      $scope-names,
      distinct-values
      (
        $new-names[not(xs:boolean(@normalize))]/
          (self::ref/@name, self::name/@value)
      )"/>

    <xsl:variable name="new-scope-ids" as="xs:string*" select="
      $new-names[xs:boolean(@normalize) and @id]/@id,
      $scope-ids"/>
    
    <xsl:variable name="new-scope-names" as="xs:string*" select="
      t:allocate-names
      (
        $new-names[xs:boolean(@normalize) and @id]/
          (self::ref/@name, self::name/@value),
        $name-pool
      ),
      $name-pool"/>
    
    <xsl:variable name="new-label-ids" as="xs:string*" 
      select="$new-labels[xs:boolean(@normalize)]/exactly-one(@id)"/>

    <xsl:variable name="new-label-names" as="xs:string*" select="
      t:allocate-names
      (
        $new-labels[xs:boolean(@normalize)]/@value, 
        $new-labels[not(xs:boolean(@normalize))]/@value
      )"/>

    <xsl:apply-templates mode="#current" select="$scope/*">
      <xsl:with-param name="scope-ids" tunnel="yes" select="$new-scope-ids"/>
      <xsl:with-param name="scope-names" tunnel="yes"
        select="$new-scope-names"/>
      <xsl:with-param name="label-ids" tunnel="yes" select="$new-label-ids"/>
      <xsl:with-param name="label-names" tunnel="yes"
        select="$new-label-names"/>
    </xsl:apply-templates>
  </xsl:template>

  <!--
    Gets ref and name elements in scope.
      $scope - a scope.
      Returns ref and name elements in scope.
  -->
  <xsl:function name="p:get-scope-names" as="element()*">
    <xsl:param name="scope" as="element()"/>

    <xsl:sequence select="
      $scope/js:*
      [
        not
        (
          self::comment or
          self::meta or
          self::function or
          self::generator-function or
          self::get-function or
          self::set-function or
          self::class
        )
      ]/
        (
          if (self::ref or self::name) then
            .
          else
            p:get-scope-names(.)
        )"/>
  </xsl:function>

</xsl:stylesheet>
