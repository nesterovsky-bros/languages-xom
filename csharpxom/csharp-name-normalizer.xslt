<?xml version="1.0" encoding="utf-8"?>
<!--
  This stylesheet provides functions resolve identifier names.
-->
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:t="http://www.bphx.com/csharp"
  xmlns:p="http://www.bphx.com/csharp/private/csharp-name-normalizer"
  xmlns="http://www.bphx.com/csharp-3.0/2009-05-23"
  xmlns:cs="http://www.bphx.com/csharp-3.0/2009-05-23"
  xpath-default-namespace="http://www.bphx.com/csharp-3.0/2009-05-23"
  exclude-result-prefixes="xs t p cs">

  <!--
    This api transforms input making all names unique in their scopes.

    To resolve name uniqueness it assumes two attributes:
      @name-id as ids - to define unique name identifier;
      @name-ref as xs:string - to refer to a name id.

    An attribute @name-id is used as an unique name identifiers, and
    @name as a suggested name, which can be suffixed to achieve uniqueness.
    An attribute @name-ref is used to refer to a name.

    The following elements may have attribute @name and @name-id:

    <from>
    <let>
    <join>
    <into>
    <var>
    <catch>
    <using-alias>
    <class>
    <type-parameter>
    <field>
    <method>
    <parameter>
    <property>
    <event>
    <constructor>
    <destructor>
    <struct>
    <fixed-size-field>
    <interface>
    <enum>
    <value>
    <delegate>

    The following elements may have attribute @name and @name-ref:

    <param>
    <paramref>
    <typeparam>
    <typeparamref>
    <type>
    <member>
    <argument>
    <var-ref>
    <field-ref>
    <property-ref>
    <event-ref>
    <method-ref>
    <static-field-ref>
    <static-property-ref>
    <static-event-ref>
    <static-method-ref>
    <pointer-member-ref>

    In addition statement <label> have a @name attribute, which may be
    accompanied with @name-id attribute. Statement <goto> may refer to a
    <label> through @name or @name-ref attributes.
  -->

  <!--
    Verifies whether the name normalization is required.
      $scope - a scope to check.
      Returns true if name normalization is required, and false otherwise.
  -->
  <xsl:function name="t:is-name-normalization-required" as="xs:boolean">
    <xsl:param name="scope" as="element()"/>

    <xsl:sequence select="
      exists
      (
        $scope//self::element()
        [
          (p:supports-name-id(.) or p:supports-label-id(.)) and
         exists(@name-id)
        ]
      )"/>
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
        <xsl:variable name="scope-id" as="xs:string?"
          select="$scope[p:supports-name-id(.)]/@name-id"/>

        <xsl:variable name="scope-names" as="xs:string*" select="
          (
            if (exists($scope-id)) then
              t:allocate-names($scope/@name, $names)
            else
              ()
          ),
          $names"/>

        <xsl:apply-templates mode="p:normalize-names" select="$scope">
          <xsl:with-param name="scope" tunnel="yes" select="$scope"/>
          <xsl:with-param name="scope-ids" tunnel="yes" select="$scope-id"/>
          <xsl:with-param name="scope-names" tunnel="yes"
            select="$scope-names"/>
        </xsl:apply-templates>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:function>

  <!--
    Get a scope elements for a given scope.
      $scope - a scope element.
  -->
  <xsl:function name="p:get-elements-in-scope" as="element()*">
    <xsl:param name="scope" as="element()"/>

    <xsl:sequence select="
      for $child in $scope/cs:* return
        if
        (
          $child
          [
            self::pp-region or
            self::pp-if or
            self::pp-then or
            self::pp-else or
            self::parameters or
            self::label or
            self::resource[parent::using or parent::lock] or
            self::from[ancestor::query] or
            self::let[ancestor::query] or
            self::join[ancestor::query]/into or
            self::select[ancestor::query]/into or
            self::groupby[ancestor::query]/into
          ]
        )
        then
          p:get-elements-in-scope($child)
        else
          $child[p:supports-name-id(.)]"/>
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
          self::from[ancestor::query] or
          self::let[ancestor::query] or
          self::join[ancestor::query] or
          self::into[ancestor::query] or
          self::var or
          self::catch[parent::try] or
          self::using-alias or
          self::class or
          self::type-parameter[parent::type-parameters] or
          self::field or
          self::method or
          self::parameter[parent::parameters] or
          self::property or
          self::event or
          self::constructor or
          self::destructor or
          self::struct or
          self::fixed-size-field or
          self::interface or
          self::enum or
          self::value[ancestor::enum] or
          self::delegate
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
          self::param[ancestor::comment] or
          self::paramref[ancestor::comment] or
          self::typeparam[ancestor::comment] or
          self::typeparamref[ancestor::comment] or
          self::type or
          self::member[ancestor::initialize] or
          self::argument[parent::attribute] or
          self::var-ref or
          self::field-ref or
          self::property-ref or
          self::event-ref or
          self::method-ref or
          self::static-field-ref or
          self::static-property-ref or
          self::static-event-ref or
          self::static-method-ref or
          self::pointer-member-ref
        ]
      )"/>
  </xsl:function>

  <!--
    Tests whether a specified element supports a label id attribute.
      $element - an element to test.
  -->
  <xsl:function name="p:supports-label-id" as="xs:boolean">
    <xsl:param name="element" as="element()"/>

    <xsl:sequence select="exists($element[self::label])"/>
  </xsl:function>

  <!--
    Tests whether a specified element supports a @label-ref attribute.
      $element - an element to test.
  -->
  <xsl:function name="p:supports-label-ref" as="xs:boolean">
    <xsl:param name="element" as="element()"/>

    <xsl:sequence select="exists($element[self::goto])"/>
  </xsl:function>

  <!--
    Mode "p:normalize-names". Default match.
  -->
  <xsl:template mode="p:normalize-names" match="text()">
    <xsl:sequence select="."/>
  </xsl:template>

  <!--
    Mode "p:normalize-names". Match scope element.
      $scope - a set of elements that constitutes a scope.
      $scope-ids - a list of name identifiers in scope.
      $scope-names - a list of resolved names in scope.
      $label-ids - a list of name label identifiers in scope.
      $label-names - a list of resolved label names in scope.
  -->
  <xsl:template mode="p:normalize-names" match="*">
    <xsl:param name="scope" tunnel="yes" as="element()*"/>
    <xsl:param name="scope-ids" tunnel="yes" as="xs:string*"/>
    <xsl:param name="scope-names" tunnel="yes" as="xs:string*"/>
    <xsl:param name="label-ids" tunnel="yes" as="xs:string*"/>
    <xsl:param name="label-names" tunnel="yes" as="xs:string*"/>

    <xsl:variable name="id-value" as="xs:string?" select="@name-id"/>
    <xsl:variable name="ref-value" as="xs:string?" select="@name-ref"/>

    <xsl:variable name="id" as="xs:string?" select="
      if (p:supports-name-id(.) and exists($id-value)) then
        $id-value
      else if (p:supports-name-ref(.) and exists($ref-value)) then
        $ref-value
      else
        ()"/>

    <xsl:variable name="new-scope" as="element()*" select="
      p:get-elements-in-scope(.)[p:supports-name-id(.)] except $scope"/>

    <xsl:copy>
      <xsl:sequence select="@* except (@name, @name-id, @name-ref)"/>

      <xsl:choose>
        <xsl:when test="exists($id)">
          <xsl:variable name="index" as="xs:integer?"
            select="p:index-of-id($scope-ids, $id)"/>

          <xsl:choose>
            <xsl:when test="exists($index)">
              <xsl:variable name="name" as="xs:string"
                select="$scope-names[$index]"/>

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
              <xsl:variable name="index" as="xs:integer"
                select="p:index-of-id($label-ids, $label-id)"/>
              <xsl:variable name="name" as="xs:string"
                select="$label-names[$index]"/>

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
              <xsl:variable name="index" as="xs:integer"
                select="p:index-of-id($label-ids, $label-ref)"/>
              <xsl:variable name="name" as="xs:string"
                select="$label-names[$index]"/>

              <xsl:attribute name="name" select="$name"/>
            </xsl:when>
            <xsl:otherwise>
              <xsl:sequence select="@name"/>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:when>
      </xsl:choose>

      <xsl:variable name="new-scope-names" as="xs:string*" select="
        (
          if ($new-scope[@name-id]) then
            t:allocate-names
            (
              $new-scope[@name-id]/exactly-one(xs:string(@name)),
              (
                $scope-names,
                $new-scope[not(@name-id)]/xs:string(@name)
              )
            )
          else
            ()
        ),
        $scope-names,
        $new-scope[not(@name-id)]/xs:string(@name)"/>

      <xsl:apply-templates mode="#current">
        <xsl:with-param name="scope" tunnel="yes"
          select="$scope | $new-scope"/>
        <xsl:with-param name="scope-ids" tunnel="yes" select="
          $new-scope/xs:string(@name-id),
          $scope-ids"/>
        <xsl:with-param name="scope-names" tunnel="yes"
          select="$new-scope-names"/>
      </xsl:apply-templates>
    </xsl:copy>
  </xsl:template>

  <!--
    Mode "p:normalize-names".
    Opens label scope.
  -->
  <xsl:template mode="p:normalize-names" match="
    constructor/block |
    destructor/block |
    method/block |
    property/get/block |
    property/set/block |
    event/add/block |
    event/remove/block">

    <xsl:variable name="block" as="element()" select="."/>

    <xsl:variable name="labeled-statements" as="element()*"
      select="$block//cs:*[p:supports-label-id(.)]"/>

    <xsl:next-match>
      <xsl:with-param name="label-ids" tunnel="yes"
        select="$labeled-statements/xs:string(@name-id)"/>
      <xsl:with-param name="label-names" tunnel="yes" select="
        t:allocate-names
        (
          $labeled-statements[@name-id]/xs:string(@name),
          $labeled-statements[not(@name-id)]/xs:string(@name)
        )"/>
    </xsl:next-match>
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
