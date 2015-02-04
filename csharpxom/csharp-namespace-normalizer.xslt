<?xml version="1.0" encoding="utf-8"?>
<!--
  This stylesheet provides functions to normalize type namespaces.

  $Id$
-->
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:t="http://www.bphx.com/csharp"
  xmlns:p="http://www.bphx.com/csharp/private/csharp-namespace-normalizer"
  xmlns="http://www.bphx.com/csharp-3.0/2009-05-23"
  xpath-default-namespace="http://www.bphx.com/csharp-3.0/2009-05-23"
  exclude-result-prefixes="xs t p">

  <!--
    Optimizes use of type qualifiers in the unit or in the namespace.
    Note: type is not normalized when it has an attribute
      @t:normalize-namespace = "false".
      $scope - a unit or namespace to optimize.
      Returns optimized scope.
  -->
  <xsl:function name="t:optimize-type-qualifiers" as="element()">
    <xsl:param name="scope" as="element()"/>

    <xsl:variable name="local-declarations" as="element()*" select="
      $scope/(. | ancestor::class | ancestor::struct)/
        (., t:get-scope-elements(.))
        [
          self::class or
          self::struct or
          self::interface or
          self::enum or
          self::delegate
        ]"/>

    <xsl:apply-templates mode="p:optimize-type-qualifiers" select="$scope">
      <xsl:with-param name="local-declarations" tunnel="yes"
        select="$local-declarations"/>
    </xsl:apply-templates>
  </xsl:function>

  <!-- Mode "optimize-type-qualifiers". Default template. -->
  <xsl:template mode="p:optimize-type-qualifiers" match="text()">
    <xsl:sequence select="."/>
  </xsl:template>

  <!-- Mode "optimize-type-qualifiers". Default template. -->
  <xsl:template mode="p:optimize-type-qualifiers" match="*">
    <xsl:copy>
      <xsl:sequence select="@*"/>
      <xsl:apply-templates mode="#current"/>
    </xsl:copy>
  </xsl:template>

  <!--
    Mode "optimize-type-qualifiers". unit or namespace.
      $using-namespaces - namespaces in scope.
      $using-aliases - type aliases in scope.
  -->
  <xsl:template mode="p:optimize-type-qualifiers" match="unit | namespace">
    <xsl:param name="using-namespaces" tunnel="yes" as="element()*"/>
    <xsl:param name="using-aliases" tunnel="yes" as="element()*"/>

    <xsl:variable name="element" as="element()" select="."/>
    <xsl:variable name="namespace" as="element()?" select="self::namespace"/>
    <xsl:variable name="elements" as="element()*"
      select="t:get-scope-elements(., false())"/>
    <xsl:variable name="combined-using-namespaces" as="element()*"
      select="$using-namespaces | $elements[self::using-namespace]"/>
    <xsl:variable name="combined-using-aliases" as="element()*"
      select="$using-aliases | $elements[self::using-alias]"/>

    <xsl:variable name="local-declarations" as="element()*" select="
      (., t:get-scope-elements(.))
      [
        self::class or
        self::struct or
        self::interface or
        self::enum or
        self::delegate
      ]"/>
    
    <xsl:variable name="types" as="element()*">
      <xsl:apply-templates mode="p:collect-types"
        select="$elements[not(self::namespace)]">
        <xsl:with-param name="local-declarations" tunnel="yes"
          select="$local-declarations"/>
      </xsl:apply-templates>
    </xsl:variable>

    <xsl:variable name="last-using" as="element()?"
      select="(using-namespace | using-alias)[last()]"/>
    <xsl:variable name="using" as="node()*"
      select="$last-using/(preceding-sibling::node(), .)"/>

    <xsl:variable name="after-using" as="node()*" select="
      if (exists($last-using)) then
        $last-using/following-sibling::node()
      else
        node()"/>

    <xsl:variable name="unordered-optimized-types" as="element()*">
      <!-- Belongs to using-namespace. -->
      <xsl:sequence select="
        $types
        [
          (@namespace = $combined-using-namespaces/@name) and
          not(@name = $combined-using-aliases/@name)
        ]"/>

      <xsl:for-each-group
        select="$types[not(@namespace = $combined-using-namespaces/@name)]"
        group-by="@name">
        <xsl:variable name="type-group" as="element()+"
          select="current-group()"/>

        <xsl:choose>
          <xsl:when test="
            count
            (
              distinct-values($type-group/t:get-type-qualified-name(.))
            ) != 1">
            <!--Suspicious types. Do not optimize them.-->
          </xsl:when>
          <xsl:otherwise>
            <xsl:sequence select="
              for $type in $type-group return
                $type
                [
                  (: There is a using-alias. :)
                  ($combined-using-aliases/deep-equal(type, $type) = true()) or
                  (: Name is not used in using-alias. :)
                  (
                    empty(type-arguments) and
                    not(@name = $combined-using-aliases/@name)
                  )
                ]"/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:for-each-group>
    </xsl:variable>

    <!--
      Ensure that $optimized-types are
      document ordered to help to a processor.
    -->
    <xsl:variable name="optimized-types" as="element()*"
      select="$unordered-optimized-types/."/>

    <xsl:variable name="using-types" as="element()*" select="
      $optimized-types
      [
        not(@namespace = $combined-using-namespaces/@name) and
        not($namespace/@name = @namespace) and
        not
        (
          p:match-local-type
          (
            (ancestor::class, ancestor::struct)/
              (
                .,
                t:get-scope-elements(.)
                [
                  self::class or
                  self::struct or
                  self::interface or
                  self::enum or
                  self::delegate
                ]
              ),
            .
          ) = 'yes'
        )
      ]"/>

    <xsl:variable name="new-aliases" as="element()*">
      <xsl:for-each-group select="$using-types"
        group-by="concat(@namespace, '.', @name)">
        <xsl:variable name="type" as="element()" select="."/>
        <xsl:variable name="name" as="xs:string" select="@name"/>

        <xsl:if test="
          empty
          (
            $combined-using-aliases/type
            [
              empty(type-arguments) and
              (@name = $type/@name) and
              (@namespace = $type/@namespace)
            ]
          )">
          <using-alias name="{$name}">
            <xsl:sequence select="$type"/>
          </using-alias>
        </xsl:if>
      </xsl:for-each-group>
    </xsl:variable>

    <xsl:copy>
      <xsl:sequence select="@*"/>

      <xsl:variable name="result-usings" as="node()*">
        <xsl:apply-templates mode="#current" select="$using">
          <xsl:with-param name="using-namespaces" tunnel="yes"
            select="$combined-using-namespaces"/>
          <xsl:with-param name="using-aliases" tunnel="yes"
            select="$combined-using-aliases, $new-aliases"/>
          <xsl:with-param name="optimized-types" tunnel="yes"
            select="$optimized-types"/>
        </xsl:apply-templates>

        <xsl:sequence select="$new-aliases"/>
      </xsl:variable>

      <xsl:perform-sort select="$result-usings">
        <xsl:sort select="empty(self::using-namespace)"/>
        <xsl:sort select="empty(self::using-alias)"/>
        <xsl:sort select="
          not(starts-with(self::using-namespace/@name, 'System'))"/>
        <xsl:sort select="self::using-namespace/xs:string(@name)"/>
        <xsl:sort select="
          not(starts-with(self::using-alias/type/@namespace, 'System'))"/>
        <xsl:sort select="self::using-alias/type/xs:string(@namespace)"/>
        <xsl:sort select="self::using-alias/xs:string(@name)"/>
      </xsl:perform-sort>

      <xsl:apply-templates mode="#current" select="$after-using">
        <xsl:with-param name="using-namespaces" tunnel="yes"
          select="$combined-using-namespaces"/>
        <xsl:with-param name="using-aliases" tunnel="yes"
          select="$combined-using-aliases, $new-aliases"/>
        <xsl:with-param name="local-declarations" tunnel="yes" select="()"/>
        <xsl:with-param name="optimized-types" tunnel="yes"
          select="$optimized-types"/>
      </xsl:apply-templates>
    </xsl:copy>
  </xsl:template>

  <!--
    Mode "optimize-type-qualifiers". elements with type declarations.
      $local-declarations - local declarations in scope.
  -->
  <xsl:template mode="p:optimize-type-qualifiers p:collect-types"
    match="class | struct">
    <xsl:param name="local-declarations" tunnel="yes" as="element()*"/>

    <xsl:variable name="scope-local-declarations" as="element()*" select="
      $local-declarations,
      t:get-scope-elements(.)
      [
        self::class or
        self::struct or
        self::interface or
        self::enum or
        self::delegate
      ]"/>

    <xsl:next-match>
      <xsl:with-param name="local-declarations" tunnel="yes"
        select="$scope-local-declarations"/>
    </xsl:next-match>
  </xsl:template>

  <!--
    Mode "optimize-type-qualifiers". Optimize type but not within using-alias.
      $using-namespaces - namespaces in scope.
      $using-aliases - type aliases in scope.
      $local-declarations - local declarations in scope.
      $optimized-types - a set of optimized types.
  -->
  <xsl:template mode="p:optimize-type-qualifiers"
    match="type[not(ancestor::using-alias)]">
    <xsl:param name="using-namespaces" tunnel="yes" as="element()*"/>
    <xsl:param name="using-aliases" tunnel="yes" as="element()*"/>
    <xsl:param name="local-declarations" tunnel="yes" as="element()*"/>
    <xsl:param name="optimized-types" tunnel="yes" as="element()*"/>

    <xsl:variable name="type" as="element()" select="."/>

    <xsl:choose>
      <xsl:when
        test="$type/@namespace and exists($optimized-types[. is $type])">
        <xsl:copy>
          <!-- Get name from alias. -->
          <xsl:sequence select="
            (
              $using-aliases
              [
                type
                [
                  empty(type-arguments) and
                  (@name = $type/@name) and
                  (@namespace = $type/@namespace)
                ]
              ]/@name,
              @name
            )[1]"/>

          <xsl:sequence select="@* except (@namespace, @name)"/>
          <xsl:apply-templates mode="#current"/>
        </xsl:copy>
      </xsl:when>
      <xsl:when test="p:match-local-type($local-declarations, $type) = 'yes'">
        <xsl:copy>
          <xsl:sequence select="@* except @namespace"/>
          <xsl:apply-templates mode="#current" select="* except type"/>
        </xsl:copy>
      </xsl:when>
      <xsl:otherwise>
        <xsl:next-match/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!--
    Collects types for the optimization.
  -->
  <xsl:template mode="p:collect-types"
    match="text() | namespace" as="element()*"/>

  <!--
    Collects types for the optimization.
  -->
  <xsl:template mode="p:collect-types" match="*" as="element()*">
    <xsl:apply-templates mode="#current"/>
  </xsl:template>

  <!--
    Collects types for the optimization.
      $local-declarations - local declarations in scope.
  -->
  <xsl:template mode="p:collect-types" match="type" as="element()*">
    <xsl:param name="local-declarations" tunnel="yes" as="element()*"/>

    <xsl:if test="
      (: Is not unbound-type-name or a namespace. :)
      boolean(@name) and
      (: Has a namespace. :)
      boolean(@namespace) and
      (: Does not have a qualifier (like 'global::') :)
      not(@qualifier) and
      not(xs:boolean(@t:normalize-namespace) = false()) and
      not(p:match-local-type($local-declarations, .) = 'conflicts') and
      (: Not a System.Nullable&lt;T&gt; :)
      not(t:is-nullable-type(.))">
      <xsl:sequence select="."/>
    </xsl:if>

    <xsl:next-match/>
  </xsl:template>

  <!--
    Tests whether the specified type matches or conflicts with a local type.
      $local-declarations - a sequence of local declarations in document order.
      $type - a type to test.
      Returns
        'yes' - when type matches the local type;
        'no' - when type does not refer to and does not
          conflict with a local type;
        'conflicts' - when type conflicts with a local type.
  -->
  <xsl:function name="p:match-local-type" as="xs:string?">
    <xsl:param name="local-declarations" as="element()*"/>
    <xsl:param name="type" as="element()"/>

    <xsl:variable name="name" as="xs:string?" select="$type/@name"/>
    <xsl:variable name="qualified-name" as="xs:string"
     select="t:get-type-qualified-name($type)"/>
    <xsl:variable name="local" as="element()*"
      select="$local-declarations[@name = $name]"/>

    <xsl:variable name="local-name" as="xs:string" select="
      string-join
      (
        $local/ancestor-or-self::*
        [
          self::class or
          self::struct or
          self::interface or
          self::enum or
          self::delegate or
          self::namespace
        ]/@name,
        '.'
      )"/>

    <xsl:choose>
      <xsl:when test="empty($local)">
        <xsl:sequence select="'no'"/>
      </xsl:when>
      <xsl:when test="(count($local) > 1) or ($qualified-name != $local-name)">
        <xsl:sequence select="'conflicts'"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:sequence select="'yes'"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:function>

</xsl:stylesheet>