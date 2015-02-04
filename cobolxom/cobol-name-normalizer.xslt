<?xml version="1.0" encoding="utf-8"?>
<!--
  This stylesheet provides functions resolve identifier names.

  $Id$
-->
<xsl:stylesheet version="2.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:t="http://www.bphx.com/cobol"
  xmlns:p="http://www.bphx.com/cobol/private/cobol-name-normalizer"
  xmlns="http://www.bphx.com/cobol/2009-12-15"
  xpath-default-namespace="http://www.bphx.com/cobol/2009-12-15"
  exclude-result-prefixes="xs t p">

  <!--
    This api transforms input making all names unique in their scopes.

    To resolve name uniqueness it assumes two attributes:
      @name-id as xs:string - to define unique name identifier;
      @name-ref as xs:string - to refer to a name id.

    An attribute @name-id is used as an unique name identifier, and
    @name as a suggested name, which can be suffixed to achieve uniqueness.
    An attribute @name-ref is used to refer to a name.

    The following elements may have attribute @name and @name-id:

    <data>
    <data-rename>
    <data-condition>
    <file-description>
    <sort-description>

    <section>
    <paragraph>

    The following elements may have attribute @name and @name-ref:

    <condition-ref>
    <file-ref>
    <data-ref>
    <index-ref>

    <paragraph-ref>
    <section-ref>
  -->

  <!--
    Varifies whether the name normalization is required.
      $scope - a scope to check.
      Returns true if name normalization is required, and false otherwise.
  -->
  <xsl:function name="t:is-name-normalization-required" as="xs:boolean">
    <xsl:param name="scope" as="element()"/>

    <xsl:sequence select="
      exists
      (
        $scope//self::*
        [
          (p:supports-name-id(.) or p:supports-label-id(.)) and
          exists(@name-id)
        ]
      )"/>
  </xsl:function>

  <!--
    Normalizes names in a give scope.
      $scope - a scope to check.
      $names - a name pool.
      $name-max-length - a longest allowable name length.
      Returns scope, with names normalized.
  -->
  <xsl:function name="t:normalize-names" as="element()">
    <xsl:param name="scope" as="element()"/>
    <xsl:param name="names" as="xs:string*"/>
    <xsl:param name="name-max-length" as="xs:integer?"/>

    <xsl:sequence select="
      t:normalize-names($scope, $names, $name-max-length, true())"/>
  </xsl:function>

  <!--
    Normalizes names in a give scope.
      $scope - a scope to check.
      $names - a name pool.
      $name-max-length - a longest allowable name length.
      $check-normalization-required - true to check whether the normalization
        is required, and false to normalize unconditionally.
      Returns scope, with names normalized.
  -->
  <xsl:function name="t:normalize-names" as="element()">
    <xsl:param name="scope" as="element()"/>
    <xsl:param name="names" as="xs:string*"/>
    <xsl:param name="name-max-length" as="xs:integer?"/>
    <xsl:param name="check-normalization-required" as="xs:boolean"/>

    <xsl:choose>
      <xsl:when test="
        $check-normalization-required and
        not(t:is-name-normalization-required($scope))">
        <xsl:sequence select="$scope"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:variable name="all-name-elements" as="element()*"
          select="$scope//self::*[p:supports-name-id(.)]"/>
        <xsl:variable name="name-elements" as="element()*"
          select="$all-name-elements[@name-id]"/>
        <xsl:variable name="name-ids" as="xs:string*"
          select="$name-elements/@name-id"/>

        <xsl:variable name="total-names" as="xs:string*" select="
          t:allocate-names
          (
            $name-elements/string(@name),
            ($names, $all-name-elements[not(@name-id)]/string(@name)),
            $name-max-length
          )"/>

        <xsl:variable name="all-label-elements" as="element()*"
          select="$scope//self::*[p:supports-label-id(.)]"/>
        <xsl:variable name="label-elements" as="element()*"
          select="$all-label-elements[@name-id]"/>
        <xsl:variable name="label-ids" as="xs:string*"
          select="$label-elements/@name-id"/>

        <xsl:variable name="label-names" as="xs:string*" select="
          t:allocate-names
          (
            $label-elements/string(@name),
            $all-label-elements[not(@name-id)]/xs:string(@name),
            $name-max-length
          )"/>

        <xsl:apply-templates mode="p:normalize-names" select="$scope">
          <xsl:with-param name="scope" tunnel="yes" select="$scope"/>
          <xsl:with-param name="names" tunnel="yes" select="$total-names"/>
          <xsl:with-param name="name-ids" tunnel="yes" select="$name-ids"/>
          <xsl:with-param name="labels" tunnel="yes" select="$label-names"/>
          <xsl:with-param name="label-ids" tunnel="yes" select="$label-ids"/>
        </xsl:apply-templates>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:function>

  <!--
    Tests whether a specified element supports a @name-id attribute.
      $element - an element to test.
  -->
  <xsl:function name="p:supports-name-id" as="xs:boolean">
    <xsl:param name="element" as="element()"/>

    <xsl:sequence select="
      exists
      (
        $element
        [
          self::data or
          self::data-rename or
          self::data-condition or
          self::file-description or
          self::sort-description
        ]
      )"/>
  </xsl:function>

  <!--
    Tests whether a specified element supports a @name-ref attribute.
      $element - an element to test.
  -->
  <xsl:function name="p:supports-name-ref" as="xs:boolean">
    <xsl:param name="element" as="element()"/>

    <xsl:sequence select="
      exists
      (
        $element
        [
          self::condition-ref or
          self::file-ref or
          self::data-ref or
          self::index-ref
        ]
      )"/>
  </xsl:function>

  <!--
    Tests whether a specified element supports a label id attribute.
      $element - an element to test.
  -->
  <xsl:function name="p:supports-label-id" as="xs:boolean">
    <xsl:param name="element" as="element()"/>

    <xsl:sequence select="
      exists
      (
        $element
        [
          self::section or
          self::paragraph
        ]
      )"/>
  </xsl:function>

  <!--
    Tests whether a specified element supports a @label-ref attribute.
      $element - an element to test.
  -->
  <xsl:function name="p:supports-label-ref" as="xs:boolean">
    <xsl:param name="element" as="element()"/>

    <xsl:sequence select="
      exists
      (
        $element
        [
          self::section-ref or
          self::paragraph-ref
        ]
      )"/>
  </xsl:function>

  <!--
    Mode "p:normalize-names". Default match.
  -->
  <xsl:template mode="p:normalize-names" match="text()">
    <xsl:sequence select="."/>
  </xsl:template>

  <!--
    Mode "p:normalize-names". Match scope element.
      $scope - a set of elements that consitutes a scope.
      $names - a list of resolved names in scope.
      $name-ids - a list of name identifiers in scope.
      $labels - a list of resolved label names in scope.
      $label-ids - a list of name label identifiers in scope.
  -->
  <xsl:template mode="p:normalize-names" match="*">
    <xsl:param name="scope" tunnel="yes" as="element()*"/>
    <xsl:param name="names" tunnel="yes" as="xs:string*"/>
    <xsl:param name="name-ids" tunnel="yes" as="xs:string*"/>
    <xsl:param name="labels" tunnel="yes" as="xs:string*"/>
    <xsl:param name="label-ids" tunnel="yes" as="xs:string*"/>

    <xsl:variable name="id-value" as="xs:string?" select="@name-id"/>
    <xsl:variable name="ref-value" as="xs:string?" select="@name-ref"/>

    <xsl:variable name="id" as="xs:string?" select="
      if (p:supports-name-id(.) and exists($id-value)) then
        $id-value
      else if (p:supports-name-ref(.) and exists($ref-value)) then
        $ref-value
      else
        ()"/>

    <xsl:copy>
      <xsl:sequence select="@* except (@name, @name-id, @name-ref)"/>

      <xsl:choose>
        <xsl:when test="exists($id)">
          <xsl:variable name="indices" as="xs:integer*"
            select="p:index-of-id($name-ids, $id)"/>

          <xsl:if test="count($indices) > 1">
            <xsl:sequence select="error(xs:QName('duplicate-name-id'), $id)"/>
          </xsl:if>

          <xsl:variable name="index" as="xs:integer?" select="$indices"/>

          <xsl:choose>
            <xsl:when test="exists($index)">
              <xsl:variable name="name" as="xs:string"
                select="$names[$index]"/>

              <xsl:attribute name="name" select="$name"/>
            </xsl:when>
            <xsl:otherwise>
              <xsl:sequence select="@name, @name-id, @name-ref"/>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:when>
        <xsl:otherwise>
          <xsl:sequence select="@name"/>
        </xsl:otherwise>
      </xsl:choose>

      <xsl:choose>
        <xsl:when test="p:supports-label-id(.)">
          <xsl:variable name="label-id" as="xs:string?" select="@name-id"/>

          <xsl:choose>
            <xsl:when test="exists($label-id)">
              <xsl:variable name="indices" as="xs:integer*"
                select="p:index-of-id($label-ids, $label-id)"/>

              <xsl:if test="count($indices) != 1">
                <xsl:sequence select="
                  error(xs:QName('empty-or-duplicate-label-id'), $label-id)"/>
              </xsl:if>

              <xsl:variable name="index" as="xs:integer" select="$indices"/>
              <xsl:variable name="name" as="xs:string"
                select="$labels[$index]"/>

              <xsl:attribute name="name" select="$name"/>
            </xsl:when>
            <xsl:otherwise>
              <xsl:sequence select="@name"/>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:when>
        <xsl:when test="p:supports-label-ref(.)">
          <xsl:variable name="label-ref" as="xs:string?" select="@name-ref"/>

          <xsl:choose>
            <xsl:when test="exists($label-ref)">
              <xsl:variable name="indices" as="xs:integer*"
                select="p:index-of-id($label-ids, $label-ref)"/>

              <xsl:if test="count($indices) != 1">
                <xsl:sequence select="
                  error(xs:QName('empty-or-duplicate-label-id'), $label-ref)"/>
              </xsl:if>

              <xsl:variable name="index" as="xs:integer" select="$indices"/>
              <xsl:variable name="name" as="xs:string"
                select="$labels[$index]"/>

              <xsl:attribute name="name" select="$name"/>
            </xsl:when>
            <xsl:otherwise>
              <xsl:sequence select="@name"/>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:when>
      </xsl:choose>

      <xsl:apply-templates mode="#current"/>
    </xsl:copy>
  </xsl:template>

  <!--
    Search an id in the the sequence of list of ids.
      $ids-list - a sequence of a list of ids.
      $id - an id to test.
      Returns an index of id, if any
  -->
  <xsl:function name="p:index-of-id" as="xs:integer?">
    <xsl:param name="ids-list" as="xs:string*"/>
    <xsl:param name="id" as="xs:string?"/>

    <xsl:sequence select="
      index-of
      (
        (
          for $ids in $ids-list return
            contains($ids, $id) and
            contains(concat(' ', $ids, ' '), concat(' ', $id, ' '))
        ),
        true()
      )[1]"/>
  </xsl:function>

</xsl:stylesheet>