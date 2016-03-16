<?xml version="1.0" encoding="utf-8"?>
<!--
  This stylesheet provides utility functions over jxom.
-->
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:t="http://www.bphx.com/jxom"
  xmlns:p="http://www.bphx.com/jxom/private/java-utils"
  xmlns:j="http://www.bphx.com/java-1.5/2008-02-07"
  xmlns="http://www.bphx.com/java-1.5/2008-02-07"
  xpath-default-namespace="http://www.bphx.com/java-1.5/2008-02-07"
  exclude-result-prefixes="xs t j p">

  <!-- Debug -->
  <!--
  <xsl:include href="java-optimizer.xslt"/>

  <xsl:template match="/unit">
    <xsl:sequence select="t:optimize-type-qualifiers(.)"/>
  </xsl:template>
  -->

  <!--
    Optimizes use of type qualifiers in the unit.
    Note: type qualifiers are not optimized when it has an attribute
      @t:optimize-type-qualifier = "false".
      $unit - a unit to optimize.
      Returns optimized unit.
  -->
  <xsl:function name="t:optimize-type-qualifiers" as="element()">
    <xsl:param name="unit" as="element()"/>

    <xsl:variable name="imports" as="element()*"
      select="$unit/imports/import"/>
    <xsl:variable name="import-qualified-names" as="xs:string*" select="
      $imports[not(xs:boolean(@static))]/p:get-type-qualified-name(type)"/>

    <xsl:variable name="names-to-optimize" as="xs:string*">
      <xsl:for-each-group 
        select="
          $unit/(* except imports)//
          (
            self::type |
            self::class | 
            self::enum | 
            self::interface | 
            self::annotation-decl
          )[p:is-unit-element(.)]"
        group-by="@name">

        <xsl:variable name="group" as="element()+"
          select="current-group()"/>
        <xsl:variable name="types" as="element()*"
          select="$group[self::type]"/>
        <xsl:variable name="qualified-name" as="xs:string?"
          select="$types[1]/p:get-type-qualified-name(.)"/>

        <xsl:if test="
          (
            exists($types/@package) or 
            ($qualified-name = $import-qualified-names)
          ) and
          not(xs:boolean($types/@t:optimize-type-qualifier) = false()) and
          not
          (
            $qualified-name != 
              subsequence($group, 2)/p:get-type-qualified-name(.)
          )">
          <xsl:sequence select="current-grouping-key()"/>
        </xsl:if>
      </xsl:for-each-group>
    </xsl:variable>

    <xsl:choose>
      <xsl:when test="
        some $import in $imports satisfies
          not(xs:boolean($import/@static)) and
          empty($import/type/@name)">
        <!--
          There are wildcard imports.
          It's not safe to optimize.
        -->
        <xsl:sequence select="$unit"/>
      </xsl:when>
      <xsl:when test="empty($names-to-optimize)">
        <xsl:sequence select="$unit"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:apply-templates mode="p:optimize-type-qualifiers" select="$unit">
          <xsl:with-param name="import-names" tunnel="yes"
            select="$imports/type/xs:string(@name)"/>
          <xsl:with-param name="names-to-optimize" tunnel="yes"
            select="$names-to-optimize"/>
        </xsl:apply-templates>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:function>

  <!-- Mode "optimize-type-qualifiers". Default template. -->
  <xsl:template mode="p:optimize-type-qualifiers"
    match="text() | meta | comment">
    <xsl:copy-of select="."/>
  </xsl:template>

  <!-- Mode "optimize-type-qualifiers". Default handler. -->
  <xsl:template mode="p:optimize-type-qualifiers" match="*">
    <xsl:copy>
      <xsl:sequence select="@*"/>
      <xsl:apply-templates mode="#current"/>
    </xsl:copy>
  </xsl:template>

  <!-- 
    Mode "optimize-type-qualifiers". Optimize type. 
      $import-names - a list of type names declared in imports.
      $names-to-optimize - a list of type names to optimize.
  -->
  <xsl:template mode="p:optimize-type-qualifiers" match="type">
    <xsl:param name="import-names" tunnel="yes" as="xs:string*"/>
    <xsl:param name="names-to-optimize" tunnel="yes" as="xs:string*"/>

    <xsl:choose>
      <xsl:when test="not(@name = $names-to-optimize)">
        <xsl:next-match/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:copy>
          <xsl:sequence select="@name"/>

          <xsl:choose>
            <xsl:when test="@name = $import-names">
              <xsl:apply-templates mode="#current" select="* except type"/>
            </xsl:when>
            <xsl:otherwise>
              <xsl:apply-templates mode="#current"/>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:copy>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!-- 
    Mode "optimize-type-qualifiers". Optimize compilation unit. 
      $names-to-optimize - a list of type names to optimize.
  -->
  <xsl:template mode="p:optimize-type-qualifiers" match="unit">
    <xsl:param name="names-to-optimize" tunnel="yes" as="xs:string*"/>

    <xsl:variable name="unit-package" as="xs:string?" select="@package"/>
    <xsl:variable name="imports" as="element()*" select="imports/import"/>

    <xsl:variable name="optimized-types" as="element()*">
      <xsl:for-each select="./(* except imports)//type[p:is-unit-element(.)]">
        <xsl:variable name="package" as="xs:string?" select="@package"/>
        <xsl:variable name="name" as="xs:string" select="@name"/>

        <xsl:if test="
          exists($package) and
          empty($unit-package) or ($unit-package != $package) and
          ($name = $names-to-optimize) and
          not($imports[p:get-import-name(.) = $name])">

          <xsl:sequence select="."/>
        </xsl:if>
      </xsl:for-each>
    </xsl:variable>

    <xsl:choose>
      <xsl:when test="empty($optimized-types)">
        <xsl:sequence select="."/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:copy>
          <xsl:sequence select="@* | comment"/>
          <xsl:apply-templates mode="#current" select="annotations"/>

          <xsl:variable name="import-list" as="xs:string*" select="
            $optimized-types,
            $imports[not(xs:boolean(@static))]/xs:string(@name)"/>

          <imports>
            <xsl:for-each-group 
              select="
                $optimized-types, 
                $imports[not(xs:boolean(@static))]/type"
              group-by="p:get-type-qualified-name(.)">
              <xsl:sort select="current-grouping-key()"/>

              <import>
                <xsl:sequence select="."/>
              </import>
            </xsl:for-each-group>

            <xsl:sequence select="$imports[xs:boolean(@static)]"/>
          </imports>

          <xsl:apply-templates mode="#current"
            select="* except (comment | imports | annotations)"/>
        </xsl:copy>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!--
    Gets type declarations for an element.
      $element - an element to get type declarations for.
      Returns type declarations for an element.
  -->
  <xsl:function name="p:get-type-declarations" as="element()*">
    <xsl:param name="element" as="element()"/>

    <xsl:sequence
      select="$element/(class | enum | interface | annotation-decl)"/>
  </xsl:function>

  <!--
    Verify that element belongs to the unit.
      $element - an element to test.
      Returns true is element belongs to the unit, and false otherwise
        (e.g. element is part of comment or meta).
  -->
  <xsl:function name="p:is-unit-element" as="xs:boolean">
    <xsl:param name="element" as="element()"/>

    <xsl:sequence
      select="empty($element/(ancestor::meta | $element/ancestor::comment))"/>
  </xsl:function>

  <!--
    Gets unit element for an element.
      $element - an unit descendant element, or unit itself.
      Returns unit element.
  -->
  <xsl:function name="p:find-unit" as="element()">
    <xsl:param name="element" as="element()"/>

    <xsl:sequence select="$element/ancestor-or-self::unit[1]"/>
  </xsl:function>

  <!--
    Gets import type name for an import element.
      $import - import element.
      Returns import type name name.
  -->
  <xsl:function name="p:get-import-name" as="xs:string?">
    <xsl:param name="import" as="element()"/>

    <xsl:sequence select="$import[not(xs:boolean(@static))]/type/@name"/>
  </xsl:function>

  <!--
    Gets type qualified name for a type element.
      $type - a type element.
      Returns type key.
  -->
  <xsl:function name="p:get-type-qualified-name" as="xs:string">
    <xsl:param name="type" as="element()"/>

    <xsl:choose>
      <xsl:when test="$type/self::type">
        <xsl:variable name="package" as="xs:string?" select="$type/@package"/>
        <xsl:variable name="name" as="xs:string" select="$type/@name"/>
        <xsl:variable name="container" as="element()?" select="$type/type"/>

        <xsl:choose>
          <xsl:when test="$container">
            <xsl:sequence select="
              concat(p:get-type-qualified-name($container), '.', $name)"/>
          </xsl:when>
          <xsl:when test="exists($package)">
            <xsl:sequence select="concat($package, '.', $name)"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:variable name="unit" as="element()"
              select="p:find-unit($type)"/>
            <xsl:variable name="imports" as="element()*"
              select="$unit/imports/import"/>
            <xsl:variable name="type-declarations" as="element()*" select="
              $type/ancestor::*[not($unit >> .)]/p:get-type-declarations(.)"/>
            <xsl:variable name="type-declaration" as="element()?"
              select="$type-declarations[@name = $name][last()]"/>
            <xsl:variable name="import" as="element()*"
              select="$imports[p:get-import-name(.) = $name]"/>

            <xsl:choose>
              <xsl:when test="exists($type-declaration)">
                <xsl:sequence select="
                  string-join
                  (
                    (
                      $unit/@package,
                      (
                        $type-declarations intersect
                          $type-declaration/ancestor-or-self::*
                      )/@name
                    ),
                    '.'
                  )"/>
              </xsl:when>
              <xsl:when test="count($import) = 1">
                <xsl:sequence
                  select="p:get-type-qualified-name($import/type)"/>
              </xsl:when>
              <xsl:otherwise>
                <xsl:sequence select="concat('?.', $name)"/>
              </xsl:otherwise>
            </xsl:choose>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:when>
      <xsl:otherwise>
        <xsl:variable name="unit" as="element()"
          select="p:find-unit($type)"/>

        <xsl:variable name="classes" as="element()+" select="
          $type/
          (
            ancestor-or-self::class |
            ancestor-or-self::enum |
            ancestor-or-self::interface |
            ancestor-or-self::annotation-decl
          )[. >> $unit]"/>

        <xsl:sequence
          select="string-join(($unit/@package, $classes/@name), '.')"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:function>

</xsl:stylesheet>
