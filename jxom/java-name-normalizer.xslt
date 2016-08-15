<?xml version="1.0" encoding="utf-8"?>
<!--This stylesheet normalizes names. -->
<xsl:stylesheet version="2.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:t="http://www.bphx.com/jxom"
  xmlns:p="http://www.bphx.com/jxom/private/java-name-normalizer"
  xmlns="http://www.bphx.com/java-1.5/2008-02-07"
  xmlns:java="http://www.bphx.com/java-1.5/2008-02-07"
  xpath-default-namespace="http://www.bphx.com/java-1.5/2008-02-07"
  exclude-result-prefixes="xs t p java">

  <!--
    The following elements may have attribute @name.

    <class/>
    <enum/>
    <interface/>
    <annotation-decl/>
    <method/>
    <field/>
    <constructor/>
    <class-method/>
    <class-field/>
    <interface-method/>
    <interface-field/>
    <annotion-method/>
    <annotion-field/>
    <parameter/>
    <var-decl/>
    <var/>
    <type/>
    <invoke/>
    <static-invoke/>

    To resolve name uniqueness this api assumes two more attributes:
      @name-id as xs:string - to define unique name identifier;
      @name-ref as xs:string - to refer to a name id.

    This api transforms input making all names unique in their scopes.
    An attribute @name-id is used as unique name identifier, and
    @name as a suggested name, which can be suffixed to achieve uniqueness.
    An attribute @name-ref is used to refer to a name.

    Statements, which may have a @label, also may use @label-id as xs:string.
    These are:
      <block/>
      <if/>
      <for/>
      <for-each/>
      <while/>
      <do-while/>
      <try/>
      <switch/>
      <synchronized/>

    Statements, which may have a @destination-label, also may use
    @label-ref as xs:string.
    These are:
      <break/>
      <continue/>
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
        $scope/descendant-or-self::java:*
        [
          (exists(@name-id) and p:supports-name-id(.)) or
          (exists(@label-id) and p:supports-label-id(.))
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

    <xsl:variable name="scope-id" as="xs:string?"
      select="$scope[p:supports-name-id(.)]/@name-id"/>

    <xsl:variable name="scope-names" as="xs:string*" select="
      $scope[exists($scope-id)]/t:allocate-names(@name, $names),
      $names"/>

    <xsl:apply-templates mode="p:normalize-names" select="$scope">
      <xsl:with-param name="scope" tunnel="yes" select="$scope"/>
      <xsl:with-param name="scope-ids" tunnel="yes" select="$scope-id"/>
      <xsl:with-param name="scope-names" tunnel="yes" select="$scope-names"/>
    </xsl:apply-templates>
  </xsl:function>

  <!--
    Get a scope elements for a given scope.
      $scope - a scope element.
  -->
  <xsl:function name="p:get-elements-in-scope" as="element()*">
    <xsl:param name="scope" as="element()"/>

    <xsl:sequence select="
      for $child in $scope/java:* return
        if
        (
          $child
          [
            self::scope,
            self::resource[parent::try],
            self::members,
            self::class-members,
            self::interface-members,
            self::annotation-members,
            self::parameters
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
          self::class or
          self::enum or
          self::interface or
          self::annotation-decl or
          self::method or
          self::field or
          self::class-method or
          self::class-field or
          self::interface-method or
          self::interface-field or
          self::annotion-method or
          self::annotion-field or
          self::parameter or
          self::var-decl
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
          self::constructor or
          self::field or
          self::var or
          self::type or
          self::invoke or
          self::static-invoke
        ]
      )"/>
  </xsl:function>

  <!--
    Tests whether a specified element supports a @label-id attribute.
      $element - an element to test.
  -->
  <xsl:function name="p:supports-label-id" as="xs:boolean">
    <xsl:param name="element" as="element()"/>

    <xsl:sequence select="
      exists
      (
        $element
        [
          self::block or
          self::if or
          self::for or
          self::for-each or
          self::while or
          self::do-while or
          self::try or
          self::switch or
          self::synchronized
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
          self::break or
          self::continue
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

    <xsl:variable name="new-scope" as="element()*" select="
      p:get-elements-in-scope(.) except $scope"/>
    <xsl:variable name="name-id" as="xs:string?" select="@name-id"/>
    <xsl:variable name="name-ref" as="xs:string?" select="@name-ref"/>
    <xsl:variable name="label-id" as="xs:string?" select="@label-id"/>
    <xsl:variable name="label-ref" as="xs:string?" select="@label-ref"/>

    <xsl:copy>
      <xsl:sequence
        select="@* except (@name-id, @name-ref, @label-id, @label-ref)"/>

      <xsl:choose>
        <xsl:when test="exists($name-id) and p:supports-name-id(.)">
          <xsl:variable name="index" as="xs:integer?"
            select="p:index-of-id($scope-ids, $name-id)"/>

          <xsl:choose>
            <xsl:when test="exists($index)">
              <xsl:variable name="name" as="xs:string"
                select="$scope-names[$index]"/>

              <xsl:attribute name="name" select="$name"/>
            </xsl:when>
            <xsl:otherwise>
              <xsl:sequence select="@name-id"/>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:when>
        <xsl:when test="exists($name-ref) and p:supports-name-ref(.)">
          <xsl:variable name="index" as="xs:integer?"
            select="p:index-of-id($scope-ids, $name-ref)"/>

          <xsl:choose>
            <xsl:when test="exists($index)">
              <xsl:variable name="name" as="xs:string"
                select="$scope-names[$index]"/>

              <xsl:attribute name="name" select="$name"/>
            </xsl:when>
            <xsl:otherwise>
              <xsl:sequence select="@name-ref"/>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:when>
        <xsl:when test="exists($label-id) and p:supports-label-id(.)">
          <xsl:variable name="index" as="xs:integer"
            select="p:index-of-id($label-ids, $label-id)"/>
          <xsl:variable name="name" as="xs:string"
            select="$label-names[$index]"/>

          <xsl:attribute name="label" select="$name"/>
        </xsl:when>
        <xsl:when test="exists($label-ref) and p:supports-label-ref(.)">
          <xsl:variable name="index" as="xs:integer"
            select="p:index-of-id($label-ids, $label-ref)"/>
          <xsl:variable name="name" as="xs:string"
            select="$label-names[$index]"/>

          <xsl:attribute name="destination-label" select="$name"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:sequence select="@label-id, @label-ref"/>
        </xsl:otherwise>
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
        <xsl:with-param name="scope-ids" tunnel="yes"
          select="$new-scope/xs:string(@name-id), $scope-ids"/>
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
    class-initializer/block |
    constructor/block |
    method/block |
    class-method/block |
    enum-method/block">

    <xsl:variable name="block" as="element()" select="."/>

    <xsl:variable name="labeled-statements" as="element()*" select="
      $block/descendant::java:*
      [
        ancestor-or-self::java:*[. >> $block]
        [
          self::scope or
          p:supports-label-id(.)
        ]
      ][@label]"/>

    <xsl:next-match>
      <xsl:with-param name="label-ids" tunnel="yes"
        select="$labeled-statements/@label-id"/>
      <xsl:with-param name="label-names" tunnel="yes" select="
        t:allocate-names
        (
          $labeled-statements[@label-id]/xs:string(@label),
          $labeled-statements[not(@label-id)]/xs:string(@label)
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
      (
        index-of($ids-list, $id),
        index-of
        (
          (
            for 
              $id2 in concat(' ', $id, ' '),
              $ids in $ids-list 
            return
              contains(concat(' ', $ids, ' '), $id2)
          ),
          true()
        )
      )[1]"/>
  </xsl:function>

</xsl:stylesheet>