<?xml version="1.0" encoding="utf-8"?>
<!--
  This stylesheet provides common functions used during serialization.

  $Id$
-->
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:t="http://www.bphx.com/csharp"
  xmlns="http://www.bphx.com/csharp-3.0/2009-05-23"
  xpath-default-namespace="http://www.bphx.com/csharp-3.0/2009-05-23"
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
        if ($element/self::pp-region) then
          t:get-scope-elements($element, $include-comments-and-meta)
        else if ($element/self::pp-if) then
          t:get-scope-elements
          (
            $element/(pp-then, pp-else),
            $include-comments-and-meta
          )
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

    <xsl:apply-templates mode="t:get-children-statement"
      select="$scope"/>
  </xsl:function>

  <!--
    Mode "t:get-children-statement". Default match.
  -->
  <xsl:template mode="t:get-children-statement" match="*"/>

  <!--
    Mode "t:get-children-statement". label, block.
  -->
  <xsl:template mode="t:get-children-statement" match="label | block">
    <xsl:sequence select="t:get-elements(.)"/>
  </xsl:template>

  <!--
    Mode "t:get-children-statement". if.
  -->
  <xsl:template mode="t:get-children-statement" match="if">
    <xsl:sequence select="(then, else)/t:get-elements(.)"/>
  </xsl:template>

  <!--
    Mode "t:get-children-statement". switch.
  -->
  <xsl:template mode="t:get-children-statement" match="switch">
    <xsl:sequence select="case/(t:get-elements(.) except value)"/>
  </xsl:template>

  <!--
    Mode "t:get-children-statement". while, do-while.
  -->
  <xsl:template mode="t:get-children-statement" match="while | do-while">
    <xsl:sequence select="t:get-elements(.) except condition"/>
  </xsl:template>

  <!--
    Mode "t:get-children-statement". for.
  -->
  <xsl:template mode="t:get-children-statement" match="for">
    <xsl:sequence select="
      t:get-elements(.) except
        (initialize, update, condition/(preceding-sibling::*, .))"/>
  </xsl:template>

  <!--
    Mode "t:get-children-statement". foreach.
  -->
  <xsl:template mode="t:get-children-statement" match="foreach">
    <xsl:sequence select="t:get-elements(.) except var[1]"/>
  </xsl:template>

  <!--
    Mode "t:get-children-statement". try.
  -->
  <xsl:template mode="t:get-children-statement" match="try">
    <xsl:sequence select="
      t:get-elements(.) except (catch, finally) |
      catch/(t:get-elements(.) except type) |
      finally/t:get-elements(.)"/>
  </xsl:template>

  <!--
    Mode "t:get-children-statement". lock, using.
  -->
  <xsl:template mode="t:get-children-statement" match="lock | using">
    <xsl:sequence select="t:get-elements(.) except resource"/>
  </xsl:template>

  <!--
    Mode "t:get-children-statement". fixed.
  -->
  <xsl:template mode="t:get-children-statement" match="fixed">
    <xsl:sequence select="t:get-elements(.) except var[1]"/>
  </xsl:template>

  <!--
    Makes type nullable.
      $type - a type to make nullable.
      Returns nullable type.
  -->
  <xsl:function name="t:get-nullable" as="element()">
    <xsl:param name="type" as="element()"/>

    <type name="Nullable" namespace="System">
      <type-arguments>
        <xsl:sequence select="$type"/>
      </type-arguments>
    </type>
  </xsl:function>

  <!--
    Checks whether two types are the same.
    Note we consider types to be equal only and only if
    type1 and type2 are deep equal.
      $type1 - first type.
      $type2 - second type.
      Returns true if types are the same, and false otherwise.
  -->
  <xsl:function name="t:is-same-type" as="xs:boolean?">
    <xsl:param name="type1" as="element()?"/>
    <xsl:param name="type2" as="element()?"/>

    <xsl:sequence select="deep-equal($type1, $type2)"/>
  </xsl:function>

  <!--
    Tests whether a specified type is nullable.
      $type - a type to test.
      Return true if type is nullable, and false otherwise.
  -->
  <xsl:function name="t:is-nullable-type" as="xs:boolean">
    <xsl:param name="type" as="element()"/>

    <xsl:sequence select="
      exists
      (
        $type
        [
          (@name = 'Nullable') and
          (@namespace = 'System') and
          (count(type-arguments/type) = 1)
        ]
      )"/>
  </xsl:function>

  <!--
    Gets a qualified name for a type.
      $type - a type to get qualified name.
      Returns type qualified name.
  -->
  <xsl:function name="t:get-type-qualified-name" as="xs:string">
    <xsl:param name="type" as="element()"/>

    <xsl:variable name="qualifier" as="xs:string?" select="$type/@qualifier"/>
    <xsl:variable name="namespace" as="xs:string?" select="$type/@namespace"/>
    <xsl:variable name="name" as="xs:string?" select="$type/@name"/>
    <xsl:variable name="container-type" as="element()?" select="$type/type"/>
    <xsl:variable name="type-arguments" as="element()?"
      select="$type/type-arguments"/>
    <xsl:variable name="pointer" as="xs:integer?" select="$type/@pointer"/>

    <xsl:variable name="ranks" as="xs:integer*" select="
      for $item in tokenize($type/@rank, '\s', 'm') return
        xs:integer($item)"/>

    <xsl:variable name="elements" as="xs:string+">
      <xsl:if test="exists($container-type)">
        <xsl:sequence select="t:get-type-qualified-name($container-type)"/>
        <xsl:sequence select="'.'"/>
      </xsl:if>

      <xsl:if test="$qualifier">
        <xsl:sequence select="$qualifier"/>
        <xsl:sequence select="'::'"/>
      </xsl:if>

      <xsl:if test="$namespace">
        <xsl:sequence select="$namespace"/>
        <xsl:sequence select="'.'"/>
      </xsl:if>

      <xsl:sequence select="$name"/>

      <xsl:if test="exists($type-arguments)">
        <xsl:variable name="types" as="element()+"
          select="$type-arguments/type"/>

        <xsl:sequence select="'&lt;'"/>

        <xsl:for-each select="$types">
          <xsl:sequence select="t:get-type-qualified-name(.)"/>

          <xsl:if test="position() != last()">
            <xsl:sequence select="','"/>
          </xsl:if>
        </xsl:for-each>

        <xsl:sequence select="'&gt;'"/>
      </xsl:if>

      <xsl:choose>
        <xsl:when test="exists($ranks)">
          <xsl:for-each select="$ranks">
            <xsl:variable name="rank" as="xs:integer" select="."/>

            <xsl:sequence select="'['"/>

            <xsl:sequence select="
              for $i in 1 to $rank - 1 return
                ','"/>

            <xsl:sequence select="']'"/>
          </xsl:for-each>
        </xsl:when>
        <xsl:when test="$pointer">
          <xsl:sequence select="
            for $i in 1 to $pointer return
              '*'"/>
        </xsl:when>
      </xsl:choose>
    </xsl:variable>

    <xsl:sequence select="string-join($elements, '')"/>
  </xsl:function>

</xsl:stylesheet>