<?xml version="1.0" encoding="utf-8"?>
<!--
  This stylesheet serializes C# xml object model document down to
  the C# text.
-->
<xsl:stylesheet version="2.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:t="http://www.bphx.com/csharp"
  xmlns="http://www.bphx.com/csharp-3.0/2009-05-23"
  xpath-default-namespace="http://www.bphx.com/csharp-3.0/2009-05-23"
  exclude-result-prefixes="xs t">

  <xsl:variable name="t:class-members">
    <member name="class"/>
    <member name="struct"/>
    <member name="interface"/>
    <member name="enum"/>
    <member name="delegate"/>
    <member name="field"/>
    <member name="method"/>
    <member name="property"/>
    <member name="event"/>
    <member name="operator"/>
    <member name="constructor"/>
    <member name="destructor"/>
  </xsl:variable>

  <xsl:variable name="t:struct-members">
    <member name="class"/>
    <member name="struct"/>
    <member name="interface"/>
    <member name="enum"/>
    <member name="delegate"/>
    <member name="field"/>
    <member name="fixed-size-field"/>
    <member name="method"/>
    <member name="property"/>
    <member name="event"/>
    <member name="operator"/>
    <member name="constructor"/>
  </xsl:variable>

  <xsl:variable name="t:interface-members">
    <member name="method"/>
    <member name="property"/>
    <member name="event"/>
  </xsl:variable>

  <xsl:variable name="t:enum-members">
    <member name="value"/>
  </xsl:variable>

  <!--
    Gets class member info by the name.
      $name - a member name.
      Return class member info.
  -->
  <xsl:function name="t:get-class-member-info" as="element()?">
    <xsl:param name="name" as="xs:string"/>

    <xsl:sequence
      select="key('t:name', $name, $t:class-members)"/>
  </xsl:function>

  <!--
    Gets struct member info by the name.
      $name - a member name.
      Return struct member info.
  -->
  <xsl:function name="t:get-struct-member-info" as="element()?">
    <xsl:param name="name" as="xs:string"/>

    <xsl:sequence
      select="key('t:name', $name, $t:struct-members)"/>
  </xsl:function>

  <!--
    Gets interface member info by the name.
      $name - a member name.
      Return interface member info.
  -->
  <xsl:function name="t:get-interface-member-info" as="element()?">
    <xsl:param name="name" as="xs:string"/>

    <xsl:sequence
      select="key('t:name', $name, $t:interface-members)"/>
  </xsl:function>

  <!--
    Gets enum member info by the name.
      $name - a member name.
      Return enum member info.
  -->
  <xsl:function name="t:get-enum-member-info" as="element()?">
    <xsl:param name="name" as="xs:string"/>

    <xsl:sequence
      select="key('t:name', $name, $t:enum-members)"/>
  </xsl:function>

  <!--
    Gets a list of type declarations into a specified scope.
      $scope - a scope to get type declarations for.
      Returns a list of type declarations.
  -->
  <xsl:function name="t:get-type-declaration-list" as="element()*">
    <xsl:param name="scope" as="element()"/>

    <xsl:sequence select="$scope/(class, struct, interface, enum, delegate)"/>
  </xsl:function>

  <!--
    Generates class-declaration.
  -->
  <xsl:template mode="
    t:unit-declaration
    t:class-member-declaration
    t:struct-member-declaration"
    match="class">
    <xsl:sequence select="t:get-class-declaration(.)"/>
  </xsl:template>

  <!--
    Generates struct-declaration.
  -->
  <xsl:template mode="
    t:unit-declaration
    t:class-member-declaration
    t:struct-member-declaration"
    match="struct">
    <xsl:sequence select="t:get-struct-declaration(.)"/>
  </xsl:template>

  <!--
    Generates interface-declaration.
  -->
  <xsl:template mode="
    t:unit-declaration
    t:class-member-declaration
    t:struct-member-declaration"
    match="interface">
    <xsl:sequence select="t:get-interface-declaration(.)"/>
  </xsl:template>

  <!--
    Generates enum-declaration.
  -->
  <xsl:template mode="
    t:unit-declaration
    t:class-member-declaration
    t:struct-member-declaration"
    match="enum">
    <xsl:sequence select="t:get-enum-declaration(.)"/>
  </xsl:template>

  <!--
    Generates delegate-declaration.
  -->
  <xsl:template mode="
    t:unit-declaration
    t:class-member-declaration
    t:struct-member-declaration"
    match="delegate">
    <xsl:sequence select="t:get-delegate-declaration(.)"/>
  </xsl:template>

  <!--
    Gets sequence of tokens for a class declaration.
      $class - a class element.
      Returns a sequence of tokens.
  -->
  <xsl:function name="t:get-class-declaration" as="item()+">
    <xsl:param name="class" as="element()"/>

    <xsl:variable name="name" as="xs:string" select="$class/@name"/>
    <xsl:variable name="attributes" as="element()?"
      select="$class/attributes"/>
    <xsl:variable name="type-parameters" as="element()?"
      select="$class/type-parameters"/>
    <xsl:variable name="base" as="element()*"
      select="$class/base-class, $class/base-interface"/>
    <xsl:variable name="constraints" as="element()*"
      select="$class/constraints"/>
    <xsl:variable name="declarations" as="element()*"
      select="t:get-class-member-declaration-list($class)"/>

    <xsl:sequence select="t:get-attributes($attributes)"/>
    <xsl:sequence select="t:get-modifiers($class)"/>
    <xsl:sequence select="'class'"/>
    <xsl:sequence select="' '"/>
    <xsl:sequence select="$name"/>
    <xsl:sequence select="t:get-type-parameters($type-parameters)"/>

    <xsl:if test="exists($base)">
      <xsl:sequence select="':'"/>
      <xsl:sequence select="' '"/>

      <xsl:for-each select="$base">
        <xsl:sequence select="t:get-type(type)"/>

        <xsl:if test="position() != last()">
          <xsl:sequence select="','"/>
          <xsl:sequence select="' '"/>
        </xsl:if>
      </xsl:for-each>
    </xsl:if>

    <xsl:if test="exists($constraints)">
      <xsl:sequence select="$t:new-line"/>
      <xsl:sequence
        select="t:get-type-parameter-constraints-clauses($constraints)"/>
    </xsl:if>

    <xsl:sequence select="$t:new-line"/>
    <xsl:sequence select="'{'"/>
    <xsl:sequence select="$t:new-line"/>
    <xsl:sequence select="$t:indent"/>

    <xsl:call-template name="t:get-class-member-declarations">
      <xsl:with-param name="declarations" select="$declarations"/>
      <xsl:with-param name="content-handler" tunnel="yes" as="element()">
        <t:class-member-declaration/>
      </xsl:with-param>
    </xsl:call-template>

    <xsl:sequence select="$t:unindent"/>
    <xsl:sequence select="'}'"/>
    <xsl:sequence select="$t:new-line"/>
  </xsl:function>

  <!--
    Gets sequence of tokens for a struct declaration.
      $struct - a struct element.
      Returns a sequence of tokens.
  -->
  <xsl:function name="t:get-struct-declaration" as="item()+">
    <xsl:param name="struct" as="element()"/>

    <xsl:variable name="name" as="xs:string" select="$struct/@name"/>
    <xsl:variable name="attributes" as="element()?"
      select="$struct/attributes"/>
    <xsl:variable name="type-parameters" as="element()?"
      select="$struct/type-parameters"/>
    <xsl:variable name="base" as="element()*"
      select="$struct/base-interface"/>
    <xsl:variable name="constraints" as="element()*"
      select="$struct/constraints"/>
    <xsl:variable name="declarations" as="element()*"
      select="t:get-struct-member-declaration-list($struct)"/>

    <xsl:sequence select="t:get-attributes($attributes)"/>
    <xsl:sequence select="t:get-modifiers($struct)"/>
    <xsl:sequence select="'struct'"/>
    <xsl:sequence select="' '"/>
    <xsl:sequence select="$name"/>
    <xsl:sequence select="t:get-type-parameters($type-parameters)"/>

    <xsl:if test="exists($base)">
      <xsl:sequence select="':'"/>
      <xsl:sequence select="' '"/>

      <xsl:for-each select="$base">
        <xsl:sequence select="t:get-type(type)"/>

        <xsl:if test="position() != last()">
          <xsl:sequence select="','"/>
          <xsl:sequence select="' '"/>
        </xsl:if>
      </xsl:for-each>
    </xsl:if>

    <xsl:if test="exists($constraints)">
      <xsl:sequence select="$t:new-line"/>
      <xsl:sequence
        select="t:get-type-parameter-constraints-clauses($constraints)"/>
    </xsl:if>

    <xsl:sequence select="$t:new-line"/>
    <xsl:sequence select="'{'"/>
    <xsl:sequence select="$t:new-line"/>
    <xsl:sequence select="$t:indent"/>

    <xsl:call-template name="t:get-struct-member-declarations">
      <xsl:with-param name="declarations" select="$declarations"/>
      <xsl:with-param name="content-handler" tunnel="yes" as="element()">
        <t:struct-member-declaration/>
      </xsl:with-param>
    </xsl:call-template>

    <xsl:sequence select="$t:unindent"/>
    <xsl:sequence select="'}'"/>
    <xsl:sequence select="$t:new-line"/>
  </xsl:function>

  <!--
    Gets sequence of tokens for a interface declaration.
      $interface - a interface element.
      Returns a sequence of tokens.
  -->
  <xsl:function name="t:get-interface-declaration" as="item()+">
    <xsl:param name="interface" as="element()"/>

    <xsl:variable name="name" as="xs:string" select="$interface/@name"/>
    <xsl:variable name="attributes" as="element()?"
      select="$interface/attributes"/>
    <xsl:variable name="type-parameters" as="element()?"
      select="$interface/type-parameters"/>
    <xsl:variable name="base" as="element()*"
      select="$interface/base-interface"/>
    <xsl:variable name="constraints" as="element()*"
      select="$interface/constraints"/>
    <xsl:variable name="declarations" as="element()*"
      select="t:get-interface-member-declaration-list($interface)"/>

    <xsl:sequence select="t:get-attributes($attributes)"/>
    <xsl:sequence select="t:get-modifiers($interface)"/>
    <xsl:sequence select="'interface'"/>
    <xsl:sequence select="' '"/>
    <xsl:sequence select="$name"/>
    <xsl:sequence select="t:get-type-parameters($type-parameters)"/>

    <xsl:if test="exists($base)">
      <xsl:sequence select="':'"/>
      <xsl:sequence select="' '"/>

      <xsl:for-each select="$base">
        <xsl:sequence select="t:get-type(type)"/>

        <xsl:if test="position() != last()">
          <xsl:sequence select="','"/>
          <xsl:sequence select="' '"/>
        </xsl:if>
      </xsl:for-each>
    </xsl:if>

    <xsl:if test="exists($constraints)">
      <xsl:sequence select="$t:new-line"/>
      <xsl:sequence
        select="t:get-type-parameter-constraints-clauses($constraints)"/>
    </xsl:if>

    <xsl:sequence select="$t:new-line"/>
    <xsl:sequence select="'{'"/>
    <xsl:sequence select="$t:new-line"/>
    <xsl:sequence select="$t:indent"/>

    <xsl:call-template name="t:get-interface-member-declarations">
      <xsl:with-param name="declarations" select="$declarations"/>
      <xsl:with-param name="content-handler" tunnel="yes" as="element()">
        <t:interface-member-declaration/>
      </xsl:with-param>
    </xsl:call-template>

    <xsl:sequence select="$t:unindent"/>
    <xsl:sequence select="'}'"/>
    <xsl:sequence select="$t:new-line"/>
  </xsl:function>

  <!--
    Gets sequence of tokens for a enum declaration.
      $enum - a enum element.
      Returns a sequence of tokens.
  -->
  <xsl:function name="t:get-enum-declaration" as="item()+">
    <xsl:param name="enum" as="element()"/>

    <xsl:variable name="name" as="xs:string" select="$enum/@name"/>
    <xsl:variable name="attributes" as="element()?"
      select="$enum/attributes"/>
    <xsl:variable name="base" as="element()?"
      select="$enum/base-class"/>
    <xsl:variable name="declarations" as="element()*"
      select="t:get-enum-member-declaration-list($enum)"/>

    <xsl:sequence select="t:get-attributes($attributes)"/>
    <xsl:sequence select="t:get-modifiers($enum)"/>
    <xsl:sequence select="'enum'"/>
    <xsl:sequence select="' '"/>
    <xsl:sequence select="$name"/>

    <xsl:if test="exists($base)">
      <xsl:sequence select="':'"/>
      <xsl:sequence select="' '"/>
      <xsl:sequence select="t:get-type($base/type)"/>
    </xsl:if>

    <xsl:sequence select="$t:new-line"/>
    <xsl:sequence select="'{'"/>
    <xsl:sequence select="$t:new-line"/>
    <xsl:sequence select="$t:indent"/>

    <xsl:call-template name="t:get-enum-member-declarations">
      <xsl:with-param name="declarations" select="$declarations"/>
      <xsl:with-param name="content-handler" tunnel="yes" as="element()">
        <t:enum-member-declaration/>
      </xsl:with-param>
    </xsl:call-template>

    <xsl:sequence select="$t:unindent"/>
    <xsl:sequence select="'}'"/>
    <xsl:sequence select="$t:new-line"/>
  </xsl:function>

  <!--
    Gets sequence of tokens for a delegate declaration.
      $delegate - a delegate element.
      Returns a sequence of tokens.
  -->
  <xsl:function name="t:get-delegate-declaration" as="item()+">
    <xsl:param name="delegate" as="element()"/>

    <xsl:variable name="name" as="xs:string" select="$delegate/@name"/>
    <xsl:variable name="attributes" as="element()?"
      select="$delegate/attributes"/>
    <xsl:variable name="return-type" as="element()?"
      select="$delegate/returns/type"/>
    <xsl:variable name="type-parameters" as="element()?"
      select="$delegate/type-parameters"/>
    <xsl:variable name="parameters" as="element()?"
      select="$delegate/parameters"/>
    <xsl:variable name="constraints" as="element()*"
      select="$delegate/constraints"/>

    <xsl:sequence select="t:get-attributes($attributes)"/>
    <xsl:sequence select="t:get-modifiers($delegate)"/>
    <xsl:sequence select="'delegate'"/>
    <xsl:sequence select="' '"/>

    <xsl:choose>
      <xsl:when test="exists($return-type)">
        <xsl:sequence select="t:get-type($return-type)"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:sequence select="'void'"/>
      </xsl:otherwise>
    </xsl:choose>

    <xsl:sequence select="' '"/>

    <xsl:sequence select="$name"/>
    <xsl:sequence select="t:get-type-parameters($type-parameters)"/>
    <xsl:sequence select="'('"/>
    <xsl:sequence select="$parameters/t:get-formal-parameter-list(.)"/>
    <xsl:sequence select="')'"/>

    <xsl:if test="exists($constraints)">
      <xsl:sequence select="$t:new-line"/>
      <xsl:sequence
        select="t:get-type-parameter-constraints-clauses($constraints)"/>
    </xsl:if>

    <xsl:sequence select="';'"/>
    <xsl:sequence select="$t:new-line"/>
  </xsl:function>

  <!--
    Gets a sequence of tokens for element modifiers.
      $element - an element to get modifiers for.
      Returns a sequence of tokens.
  -->
  <xsl:function name="t:get-modifiers" as="item()*">
    <xsl:param name="element" as="element()"/>

    <xsl:variable name="new" as="xs:boolean?" select="$element/@new"/>
    <xsl:variable name="static" as="xs:boolean?" select="$element/@static"/>
    <xsl:variable name="partial" as="xs:boolean?" select="$element/@partial"/>
    <xsl:variable name="extern" as="xs:boolean?" select="$element/@extern"/>
    <xsl:variable name="async" as="xs:boolean?" select="$element/@async"/>
    <xsl:variable name="unsafe" as="xs:boolean?" select="$element/@unsafe"/>
    <xsl:variable name="access" as="xs:string?" select="$element/@access"/>
    <xsl:variable name="override" as="xs:string?" select="$element/@override"/>

    <xsl:if test="$access">
      <xsl:choose>
        <xsl:when test="$access = 'public'">
          <xsl:sequence select="'public'"/>
        </xsl:when>
        <xsl:when test="$access = 'protected'">
          <xsl:sequence select="'protected'"/>
        </xsl:when>
        <xsl:when test="$access = 'internal'">
          <xsl:sequence select="'internal'"/>
        </xsl:when>
        <xsl:when test="$access = 'internal-protected'">
          <xsl:sequence select="'internal'"/>
          <xsl:sequence select="' '"/>
          <xsl:sequence select="'protected'"/>
        </xsl:when>
        <xsl:when test="$access = 'private'">
          <xsl:sequence select="'private'"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:sequence select="
            error
            (
              xs:QName('invalid-access-modifier'),
              'Invalid access modifier.',
              $access
            )"/>
        </xsl:otherwise>
      </xsl:choose>

      <xsl:sequence select="' '"/>
    </xsl:if>

    <xsl:if test="$new">
      <xsl:sequence select="'new'"/>
      <xsl:sequence select="' '"/>
    </xsl:if>

    <xsl:if test="$static">
      <xsl:sequence select="'static'"/>
      <xsl:sequence select="' '"/>
    </xsl:if>

    <xsl:if test="$unsafe">
      <xsl:sequence select="'unsafe'"/>
      <xsl:sequence select="' '"/>
    </xsl:if>

    <xsl:if test="$async">
      <xsl:sequence select="'async'"/>
      <xsl:sequence select="' '"/>
    </xsl:if>

    <xsl:if test="$extern">
      <xsl:sequence select="'extern'"/>
      <xsl:sequence select="' '"/>
    </xsl:if>

    <xsl:if test="$override">
      <xsl:choose>
        <xsl:when test="$override = 'virtual'">
          <xsl:sequence select="'virtual'"/>
        </xsl:when>
        <xsl:when test="$override = 'sealed'">
          <xsl:sequence select="'sealed'"/>
        </xsl:when>
        <xsl:when test="$override = 'override'">
          <xsl:sequence select="'override'"/>
        </xsl:when>
        <xsl:when test="$override = 'abstract'">
          <xsl:sequence select="'abstract'"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:sequence select="
            error
            (
              xs:QName('invalid-override-modifier'),
              'Invalid override modifier.',
              $override
            )"/>
        </xsl:otherwise>
      </xsl:choose>

      <xsl:sequence select="' '"/>
    </xsl:if>

    <xsl:if test="$partial">
      <xsl:sequence select="'partial'"/>
      <xsl:sequence select="' '"/>
    </xsl:if>
  </xsl:function>

  <!--
    Gets a sequence of tokens for a type parameter list.
      $type-parameters - a type parameters element.
      $variance - true to support variance, and false otherwise.
      Returns a sequence of tokens.
  -->
  <xsl:function name="t:get-type-parameters" as="item()*">
    <xsl:param name="type-parameters" as="element()?"/>

    <xsl:if test="exists($type-parameters)">
      <xsl:variable name="parameters" as="element()+"
        select="$type-parameters/type-parameter"/>

      <xsl:sequence select="'&lt;'"/>

      <xsl:for-each select="$parameters">
        <xsl:variable name="name" as="xs:string" select="@name"/>
        <xsl:variable name="attributes" as="element()?" select="attributes"/>
        <xsl:variable name="variance" as="xs:string?" select="@variance"/>

        <xsl:sequence select="t:get-attributes($attributes)"/>

        <xsl:if test="$variance = ('in', 'out')">
          <xsl:sequence select="$variance"/>
          <xsl:sequence select="' '"/>
        </xsl:if>

        <xsl:sequence select="$name"/>

        <xsl:if test="position() != last()">
          <xsl:sequence select="','"/>

          <xsl:sequence select="
            if (exists($parameters/attributes)) then
              $t:new-line
            else
              ' '"/>
        </xsl:if>
      </xsl:for-each>

      <xsl:sequence select="'&gt;'"/>
    </xsl:if>
  </xsl:function>

  <!--
    Gets a sequence of tokens for a type parameter constraints.
      $constraints - a type parameters constraints.
      Returns a sequence of tokens.
  -->
  <xsl:function name="t:get-type-parameter-constraints-clauses" as="item()*">
    <xsl:param name="constraints" as="element()*"/>

    <xsl:if test="exists($constraints)">
      <xsl:sequence select="$t:indent"/>

      <xsl:for-each select="$constraints">
        <xsl:variable name="type" as="element()" select="type[1]"/>
        <xsl:variable name="constraint" as="element()+"
          select="t:get-elements(.) except $type"/>

        <xsl:sequence select="'where'"/>
        <xsl:sequence select="' '"/>
        <xsl:sequence select="t:get-type($type)"/>
        <xsl:sequence select="':'"/>
        <xsl:sequence select="' '"/>

        <xsl:for-each select="$constraint">
          <xsl:choose>
            <xsl:when test="self::type">
              <xsl:sequence select="t:get-type(.)"/>
            </xsl:when>
            <xsl:when test="self::class">
              <xsl:sequence select="'class'"/>
            </xsl:when>
            <xsl:when test="self::struct">
              <xsl:sequence select="'struct'"/>
            </xsl:when>
            <xsl:when test="self::constructor">
              <xsl:sequence select="'new'"/>
              <xsl:sequence select="'('"/>
              <xsl:sequence select="')'"/>
            </xsl:when>
            <xsl:otherwise>
              <xsl:sequence select="
                error
                (
                  xs:QName('unknown-type-constraint'),
                  'Unknown type constraint.',
                  .
                )"/>
            </xsl:otherwise>
          </xsl:choose>

          <xsl:if test="position() != last()">
            <xsl:sequence select="','"/>
            <xsl:sequence select="' '"/>
          </xsl:if>
        </xsl:for-each>

        <xsl:if test="position() != last()">
          <xsl:sequence select="$t:new-line"/>
        </xsl:if>
      </xsl:for-each>

      <xsl:sequence select="$t:unindent"/>
    </xsl:if>
  </xsl:function>

  <!--
    Gets a list of class members.
      $class - a class to get class members for.
      Returns a list of class members.
  -->
  <xsl:function name="t:get-class-member-declaration-list" as="element()*">
    <xsl:param name="class" as="element()"/>

    <xsl:sequence select="
      $class/
      (
        field,
        method,
        property,
        event,
        operator,
        constructor,
        destructor
      ) |
      t:get-type-declaration-list($class) |
      t:get-preprocessor-instructions($class)"/>
  </xsl:function>

  <!--
    Gets a list of struct members.
      $struct - a struct to get members for.
      Returns a list of struct members.
  -->
  <xsl:function name="t:get-struct-member-declaration-list" as="element()*">
    <xsl:param name="struct" as="element()"/>

    <xsl:sequence select="
      $struct/
      (
        field,
        fixed-size-field,
        method,
        property,
        event,
        operator,
        constructor
      ) |
      t:get-type-declaration-list($struct) |
      t:get-preprocessor-instructions($struct)"/>
  </xsl:function>

  <!--
    Gets a list of interface members.
      $interface - a interface to get members for.
      Returns a list of interface members.
  -->
  <xsl:function name="t:get-interface-member-declaration-list" as="element()*">
    <xsl:param name="interface" as="element()"/>

    <xsl:sequence select="
      $interface/
      (
        method,
        property,
        event
      ) |
      t:get-preprocessor-instructions($interface)"/>
  </xsl:function>

  <!--
    Gets a list of enum members.
      $enum - a enum to get members for.
      Returns a list of enum members.
  -->
  <xsl:function name="t:get-enum-member-declaration-list" as="element()*">
    <xsl:param name="enum" as="element()"/>

    <xsl:sequence select="
      $enum/value |
      t:get-preprocessor-instructions($enum)"/>
  </xsl:function>

  <!--
    Gets a sequence of tokens for a formal parameter list.
      $parameters - a parameters element.
      Returns a sequence of tokens.
  -->
  <xsl:function name="t:get-formal-parameter-list" as="item()*">
    <xsl:param name="parameters" as="element()"/>

    <xsl:variable name="parameter" as="element()*"
      select="$parameters/parameter"/>

    <xsl:variable name="tokens" as="item()*">
      <xsl:for-each select="$parameter">
        <xsl:variable name="name" as="xs:string" select="@name"/>
        <xsl:variable name="modifier" as="xs:string?" select="@modifier"/>
        <xsl:variable name="attributes" as="element()?" select="attributes"/>
        <xsl:variable name="type" as="element()" select="type"/>
        <xsl:variable name="initializer" as="element()?" select="initialize"/>

        <xsl:sequence select="t:get-attributes($attributes)"/>

        <xsl:if test="$modifier">
          <xsl:sequence select="$modifier"/>
          <xsl:sequence select="' '"/>
        </xsl:if>

        <xsl:sequence select="t:get-type($type)"/>
        <xsl:sequence select="' '"/>

        <xsl:sequence select="$name"/>

        <xsl:if test="exists($initializer)">
          <xsl:sequence select="' '"/>
          <xsl:sequence select="'='"/>
          <xsl:sequence select="' '"/>
          <xsl:sequence
            select="t:get-expression(t:get-elements($initializer))"/>
        </xsl:if>

        <xsl:if test="position() != last()">
          <xsl:sequence select="','"/>
        </xsl:if>

        <xsl:sequence select="$t:terminator"/>
      </xsl:for-each>
    </xsl:variable>

    <xsl:sequence select="
      t:reformat-tokens($tokens, 3, ' ', $t:new-line, false(), false())"/>
  </xsl:function>

  <!-- Generates class member declarations. -->
  <xsl:template name="t:get-class-member-declarations">
    <xsl:param name="declarations" as="element()*"/>

    <xsl:for-each select="$declarations">
      <xsl:variable name="index" as="xs:integer" select="position()"/>
      <xsl:variable name="next" as="element()?"
        select="$declarations[$index + 1]"/>

      <xsl:sequence select="t:get-comments(.)"/>

      <xsl:apply-templates mode="t:class-member-declaration" select=".">
        <xsl:with-param name="generate-comments" select="false()"/>
      </xsl:apply-templates>

      <xsl:if test="
        exists($next) and
        (
          exists($next/comment) or
          exists($next/attributes) or
          not(self::field and $next[self::field]) or
          (string(@access) != string($next/@access)) or
          (not(xs:boolean(@static)) != not(xs:boolean($next/@static)))
        )">
        <xsl:sequence select="$t:new-line"/>
      </xsl:if>

    </xsl:for-each>
  </xsl:template>

  <!--
    A content handler for the class-member-declaration
  -->
  <xsl:template mode="t:call" match="t:class-member-declaration">
    <xsl:param name="content" as="element()*"/>

    <xsl:call-template name="t:get-class-member-declarations">
      <xsl:with-param name="declarations" select="$content"/>
    </xsl:call-template>
  </xsl:template>

  <!-- Generates struct member declarations. -->
  <xsl:template name="t:get-struct-member-declarations">
    <xsl:param name="declarations" as="element()*"/>

    <xsl:for-each select="$declarations">
      <xsl:variable name="index" as="xs:integer" select="position()"/>
      <xsl:variable name="next" as="element()?"
        select="$declarations[$index + 1]"/>

      <xsl:sequence select="t:get-comments(.)"/>

      <xsl:apply-templates mode="t:struct-member-declaration" select=".">
        <xsl:with-param name="generate-comments" select="false()"/>
      </xsl:apply-templates>

      <xsl:if test="
        exists($next) and
        (
          exists($next/comment) or
          exists($next/attributes) or
          not(self::field and $next[self::field]) or
          (string(@access) != string($next/@access)) or
          (not(xs:boolean(@static)) != not(xs:boolean($next/@static)))
        )">
        <xsl:sequence select="$t:new-line"/>
      </xsl:if>

    </xsl:for-each>
  </xsl:template>

  <!--
    A content handler for the struct-member-declaration
  -->
  <xsl:template mode="t:call" match="t:struct-member-declaration">
    <xsl:param name="content" as="element()*"/>

    <xsl:call-template name="t:get-struct-member-declarations">
      <xsl:with-param name="declarations" select="$content"/>
    </xsl:call-template>
  </xsl:template>

  <!-- Generates interface member declarations. -->
  <xsl:template name="t:get-interface-member-declarations">
    <xsl:param name="declarations" as="element()*"/>

    <xsl:for-each select="$declarations">
      <xsl:variable name="index" as="xs:integer" select="position()"/>
      <xsl:variable name="next" as="element()?"
        select="$declarations[$index + 1]"/>

      <xsl:sequence select="t:get-comments(.)"/>

      <xsl:apply-templates mode="t:interface-member-declaration" select=".">
        <xsl:with-param name="generate-comments" select="false()"/>
      </xsl:apply-templates>

      <xsl:if test="
        exists($next) and
        (
          exists($next/comment) or
          exists($next/attributes) or
          not(self::property and $next[self::property])
        )">
        <xsl:sequence select="$t:new-line"/>
      </xsl:if>

    </xsl:for-each>
  </xsl:template>

  <!--
    A content handler for the enum-member-declaration
  -->
  <xsl:template mode="t:call" match="t:interface-member-declaration">
    <xsl:param name="content" as="element()*"/>

    <xsl:call-template name="t:get-interface-member-declarations">
      <xsl:with-param name="declarations" select="$content"/>
    </xsl:call-template>
  </xsl:template>

  <!-- Generates enum member declarations. -->
  <xsl:template name="t:get-enum-member-declarations">
    <xsl:param name="declarations" as="element()*"/>

    <xsl:for-each select="$declarations">
      <xsl:variable name="index" as="xs:integer" select="position()"/>
      <xsl:variable name="next" as="element()?"
        select="$declarations[$index + 1]"/>

      <xsl:sequence select="t:get-comments(.)"/>

      <xsl:apply-templates mode="t:enum-member-declaration" select=".">
        <xsl:with-param name="generate-comments" select="false()"/>
      </xsl:apply-templates>

      <xsl:if test="
        exists($next) and
        (
          exists($next/comment) or
          exists($next/attributes) or
          not(self::value and $next[self::value])
        )">
        <xsl:sequence select="$t:new-line"/>
      </xsl:if>

    </xsl:for-each>
  </xsl:template>

  <!--
    A content handler for the enum-member-declaration
  -->
  <xsl:template mode="t:call" match="t:enum-member-declaration">
    <xsl:param name="content" as="element()*"/>

    <xsl:call-template name="t:get-enum-member-declarations">
      <xsl:with-param name="declarations" select="$content"/>
    </xsl:call-template>
  </xsl:template>

  <!-- Default match for a member declaration. -->
  <xsl:template mode="
    t:class-member-declaration
    t:struct-member-declaration
    t:interface-member-declaration"
    match="*">
    <xsl:sequence select="
      error
      (
        xs:QName('invalid-member-declaration'),
        'Invalid member declaration.',
        .
      )"/>
  </xsl:template>

  <!-- field-declaration. -->
  <xsl:template mode="
    t:class-member-declaration
    t:struct-member-declaration"
    match="field">
    <xsl:variable name="name" as="xs:string" select="@name"/>
    <xsl:variable name="readonly" as="xs:boolean?" select="@readonly"/>
    <xsl:variable name="const" as="xs:boolean?" select="@const"/>
    <xsl:variable name="volatile" as="xs:boolean?" select="@volatile"/>
    <xsl:variable name="attributes" as="element()?" select="attributes"/>
    <xsl:variable name="type" as="element()" select="type"/>
    <xsl:variable name="initializer" as="element()?" select="initialize"/>

    <xsl:sequence select="t:get-attributes($attributes)"/>
    <xsl:sequence select="t:get-modifiers(.)"/>

    <xsl:if test="exists($const)">
      <xsl:sequence select="'const'"/>
      <xsl:sequence select="' '"/>
    </xsl:if>

    <xsl:if test="exists($readonly)">
      <xsl:sequence select="'readonly'"/>
      <xsl:sequence select="' '"/>
    </xsl:if>

    <xsl:if test="exists($volatile)">
      <xsl:sequence select="'volatile'"/>
      <xsl:sequence select="' '"/>
    </xsl:if>

    <xsl:sequence select="t:get-type($type)"/>
    <xsl:sequence select="' '"/>
    <xsl:sequence select="$name"/>

    <xsl:if test="exists($initializer)">
      <xsl:sequence select="' '"/>
      <xsl:sequence select="'='"/>
      <xsl:sequence select="' '"/>
      <xsl:sequence select="t:get-variable-initializer($initializer)"/>
    </xsl:if>

    <xsl:sequence select="';'"/>
    <xsl:sequence select="$t:new-line"/>
  </xsl:template>

  <!-- fixed-size-buffer-declaration. -->
  <xsl:template mode="t:struct-member-declaration"
    match="fixed-size-field">
    <xsl:variable name="name" as="xs:string" select="@name"/>
    <xsl:variable name="attributes" as="element()?" select="attributes"/>
    <xsl:variable name="type" as="element()" select="type"/>
    <xsl:variable name="size" as="element()" select="size"/>

    <xsl:sequence select="t:get-attributes($attributes)"/>
    <xsl:sequence select="t:get-modifiers(.)"/>
    <xsl:sequence select="'fixed'"/>
    <xsl:sequence select="' '"/>
    <xsl:sequence select="t:get-type($type)"/>
    <xsl:sequence select="' '"/>
    <xsl:sequence select="$name"/>
    <xsl:sequence select="'['"/>
    <xsl:sequence select="t:get-expression(t:get-elements($size))"/>
    <xsl:sequence select="']'"/>
    <xsl:sequence select="';'"/>
    <xsl:sequence select="$t:new-line"/>
  </xsl:template>

  <!-- method-declaration. -->
  <xsl:template mode="
    t:class-member-declaration
    t:struct-member-declaration
    t:interface-member-declaration"
    match="method">
    <xsl:variable name="name" as="xs:string" select="@name"/>
    <xsl:variable name="attributes" as="element()?" select="attributes"/>
    <xsl:variable name="return-type" as="element()?" select="returns/type"/>
    <xsl:variable name="explicit-interface" as="element()?"
      select="explicit-interface/type"/>
    <xsl:variable name="type-parameters" as="element()?"
      select="type-parameters"/>
    <xsl:variable name="parameters" as="element()?" select="parameters"/>
    <xsl:variable name="constraints" as="element()*" select="constraints"/>
    <xsl:variable name="block" as="element()?" select="block"/>

    <xsl:sequence select="t:get-attributes($attributes)"/>
    <xsl:sequence select="t:get-modifiers(.)"/>

    <xsl:choose>
      <xsl:when test="exists($return-type)">
        <xsl:sequence select="t:get-type($return-type)"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:sequence select="'void'"/>
      </xsl:otherwise>
    </xsl:choose>

    <xsl:sequence select="' '"/>

    <xsl:if test="exists($explicit-interface)">
      <xsl:sequence select="t:get-type($explicit-interface)"/>
      <xsl:sequence select="'.'"/>
    </xsl:if>

    <xsl:sequence select="$name"/>
    <xsl:sequence select="t:get-type-parameters($type-parameters)"/>
    <xsl:sequence select="'('"/>
    <xsl:sequence select="$parameters/t:get-formal-parameter-list(.)"/>
    <xsl:sequence select="')'"/>

    <xsl:if test="exists($constraints)">
      <xsl:sequence select="$t:new-line"/>
      <xsl:sequence
        select="t:get-type-parameter-constraints-clauses($constraints)"/>
    </xsl:if>

    <xsl:choose>
      <xsl:when test="exists($block)">
        <xsl:sequence select="$t:new-line"/>
        <xsl:sequence select="t:get-statement($block)"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:sequence select="';'"/>
        <xsl:sequence select="$t:new-line"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!-- property-declaration. -->
  <xsl:template mode="
    t:class-member-declaration
    t:struct-member-declaration
    t:interface-member-declaration"
    match="property">
    <xsl:variable name="name" as="xs:string" select="@name"/>
    <xsl:variable name="attributes" as="element()?" select="attributes"/>
    <xsl:variable name="type" as="element()" select="type"/>
    <xsl:variable name="explicit-interface" as="element()?"
      select="explicit-interface/type"/>
    <xsl:variable name="parameters" as="element()?" select="parameters"/>
    <xsl:variable name="getter" as="element()?" select="get"/>
    <xsl:variable name="setter" as="element()?" select="set"/>

    <xsl:if test="empty($getter) and empty($setter)">
      <xsl:sequence select="
        error
        (
          xs:QName('property-accessor-expected'),
          'Property getter or setter is expected.',
          .
        )"/>
    </xsl:if>

    <xsl:sequence select="t:get-attributes($attributes)"/>
    <xsl:sequence select="t:get-modifiers(.)"/>
    <xsl:sequence select="t:get-type($type)"/>
    <xsl:sequence select="' '"/>

    <xsl:if test="exists($explicit-interface)">
      <xsl:sequence select="t:get-type($explicit-interface)"/>
      <xsl:sequence select="'.'"/>
    </xsl:if>

    <xsl:sequence select="$name"/>

    <xsl:if test="exists($parameters)">
      <xsl:sequence select="'['"/>
      <xsl:sequence select="t:get-formal-parameter-list($parameters)"/>
      <xsl:sequence select="']'"/>
    </xsl:if>

    <xsl:variable name="compact" as="xs:boolean"
      select="empty(($getter, $setter)/(attributes, block))"/>

    <xsl:choose>
      <xsl:when test="$compact">
        <xsl:sequence select="' '"/>
        <xsl:sequence select="'{'"/>
        <xsl:sequence select="' '"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:sequence select="$t:new-line"/>
        <xsl:sequence select="'{'"/>
        <xsl:sequence select="$t:new-line"/>
      </xsl:otherwise>
    </xsl:choose>

    <xsl:sequence select="$t:indent"/>

    <xsl:for-each select="$getter, $setter">
      <xsl:variable name="accessor-attributes" as="element()?"
        select="attributes"/>
      <xsl:variable name="accessor-body" as="element()?" select="block"/>

      <xsl:sequence select="t:get-attributes($accessor-attributes)"/>
      <xsl:sequence select="t:get-modifiers(.)"/>

      <xsl:sequence select="
        if (self::get) then
          'get'
        else
          'set'"/>

      <xsl:choose>
        <xsl:when test="exists($accessor-body)">
          <xsl:sequence select="$t:new-line"/>
          <xsl:sequence select="t:get-statement($accessor-body)"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:sequence select="';'"/>

          <xsl:choose>
            <xsl:when test="$compact">
              <xsl:sequence select="' '"/>
            </xsl:when>
            <xsl:otherwise>
              <xsl:sequence select="$t:new-line"/>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:for-each>

    <xsl:sequence select="$t:unindent"/>
    <xsl:sequence select="'}'"/>

    <xsl:sequence select="$t:new-line"/>
  </xsl:template>

  <!-- event-declaration. -->
  <xsl:template mode="
    t:class-member-declaration
    t:struct-member-declaration
    t:interface-member-declaration"
    match="event">
    <xsl:variable name="name" as="xs:string" select="@name"/>
    <xsl:variable name="attributes" as="element()?" select="attributes"/>
    <xsl:variable name="type" as="element()" select="type"/>
    <xsl:variable name="explicit-interface" as="element()?"
      select="explicit-interface/type"/>
    <xsl:variable name="add" as="element()?" select="add"/>
    <xsl:variable name="remove" as="element()?" select="remove"/>
    <xsl:variable name="initializer" as="element()?" select="initialize"/>

    <xsl:if test="exists($add) != exists($remove)">
      <xsl:sequence select="
        error
        (
          xs:QName('event-accessor-expected'),
          'add and remove event accessors are mutually inclusive.',
          .
        )"/>
    </xsl:if>

    <xsl:if test="exists($add) and exists($initializer)">
      <xsl:sequence select="
        error
        (
          xs:QName('event-accessor-and-initializer-mutually-exclusive'),
          'Event accessors and initializer are mutually exclusive.',
          .
        )"/>
    </xsl:if>

    <xsl:sequence select="t:get-attributes($attributes)"/>
    <xsl:sequence select="t:get-modifiers(.)"/>
    <xsl:sequence select="'event'"/>
    <xsl:sequence select="' '"/>
    <xsl:sequence select="t:get-type($type)"/>
    <xsl:sequence select="' '"/>

    <xsl:if test="exists($explicit-interface)">
      <xsl:sequence select="t:get-type($explicit-interface)"/>
      <xsl:sequence select="'.'"/>
    </xsl:if>

    <xsl:sequence select="$name"/>

    <xsl:choose>
      <xsl:when test="exists($initializer)">
        <xsl:sequence select="' '"/>
        <xsl:sequence select="'='"/>
        <xsl:sequence select="' '"/>
        <xsl:sequence select="t:get-variable-initializer($initializer)"/>
        <xsl:sequence select="';'"/>
      </xsl:when>
      <xsl:when test="exists($add)">
        <xsl:sequence select="$t:new-line"/>
        <xsl:sequence select="'{'"/>
        <xsl:sequence select="$t:new-line"/>
        <xsl:sequence select="$t:indent"/>

        <xsl:for-each select="$add, $remove">
          <xsl:variable name="accessor-attributes" as="element()?"
            select="attributes"/>
          <xsl:variable name="accessor-body" as="element()?" select="block"/>

          <xsl:sequence select="t:get-attributes($accessor-attributes)"/>
          <xsl:sequence select="t:get-modifiers(.)"/>

          <xsl:sequence select="
            if (self::add) then
              'add'
            else
              'remove'"/>

          <xsl:choose>
            <xsl:when test="exists($accessor-body)">
              <xsl:sequence select="$t:new-line"/>
              <xsl:sequence select="t:get-statement($accessor-body)"/>
            </xsl:when>
            <xsl:otherwise>
              <xsl:sequence select="';'"/>
              <xsl:sequence select="$t:new-line"/>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:for-each>

        <xsl:sequence select="$t:unindent"/>
        <xsl:sequence select="'}'"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:sequence select="';'"/>
      </xsl:otherwise>
    </xsl:choose>

    <xsl:sequence select="$t:new-line"/>
  </xsl:template>

  <!-- operator-declaration. -->
  <xsl:template mode="
    t:class-member-declaration
    t:struct-member-declaration"
    match="operator">
    <xsl:variable name="name" as="xs:string?" select="@name"/>
    <xsl:variable name="implicit" as="xs:boolean?" select="@implicit"/>
    <xsl:variable name="attributes" as="element()?" select="attributes"/>
    <xsl:variable name="return-type" as="element()" select="returns/type"/>
    <xsl:variable name="parameters" as="element()" select="parameters"/>
    <xsl:variable name="block" as="element()?" select="block"/>

    <xsl:sequence select="t:get-attributes($attributes)"/>
    <xsl:sequence select="t:get-modifiers(.)"/>

    <xsl:if test="empty($name)">
      <xsl:sequence select="
        if ($implicit) then
          'implicit'
        else
          'explicit'"/>
      <xsl:sequence select="' '"/>
      <xsl:sequence select="'operator'"/>
      <xsl:sequence select="' '"/>
    </xsl:if>

    <xsl:sequence select="t:get-type($return-type)"/>
    <xsl:sequence select="' '"/>

    <xsl:if test="exists($name)">
      <xsl:variable name="operator" as="xs:string" select="
        t:get-expression-info($name)[xs:boolean(@overloadable)]/@operator"/>

      <xsl:sequence select="'operator'"/>
      <xsl:sequence select="' '"/>
      <xsl:sequence select="$operator"/>
    </xsl:if>

    <xsl:sequence select="'('"/>
    <xsl:sequence select="t:get-formal-parameter-list($parameters)"/>
    <xsl:sequence select="')'"/>

    <xsl:choose>
      <xsl:when test="exists($block)">
        <xsl:sequence select="$t:new-line"/>
        <xsl:sequence select="t:get-statement($block)"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:sequence select="';'"/>
        <xsl:sequence select="$t:new-line"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!-- constructor-declaration. -->
  <xsl:template mode="
    t:class-member-declaration
    t:struct-member-declaration"
    match="constructor">
    <xsl:variable name="name" as="xs:string" select="@name"/>
    <xsl:variable name="attributes" as="element()?" select="attributes"/>
    <xsl:variable name="parameters" as="element()?" select="parameters"/>
    <xsl:variable name="initializer" as="element()?" select="initialize"/>
    <xsl:variable name="block" as="element()?" select="block"/>

    <xsl:sequence select="t:get-attributes($attributes)"/>
    <xsl:sequence select="t:get-modifiers(.)"/>
    <xsl:sequence select="$name"/>
    <xsl:sequence select="'('"/>
    <xsl:sequence select="$parameters/t:get-formal-parameter-list(.)"/>
    <xsl:sequence select="')'"/>

    <xsl:if test="exists($initializer)">
      <xsl:variable name="initializer-type" as="xs:string"
        select="$initializer/@type"/>
      <xsl:variable name="arguments" as="element()?"
        select="$initializer/arguments"/>

      <xsl:sequence select="':'"/>
      <xsl:sequence select="$t:new-line"/>
      <xsl:sequence select="$t:indent"/>
      <xsl:sequence select="$initializer-type"/>
      <xsl:sequence select="'('"/>
      <xsl:sequence select="$arguments/t:get-arguments(.)"/>
      <xsl:sequence select="')'"/>
      <xsl:sequence select="$t:unindent"/>
    </xsl:if>

    <xsl:choose>
      <xsl:when test="exists($block)">
        <xsl:sequence select="$t:new-line"/>
        <xsl:sequence select="t:get-statement($block)"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:sequence select="';'"/>
        <xsl:sequence select="$t:new-line"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!-- destructor-declaration. -->
  <xsl:template mode="t:class-member-declaration" match="destructor">
    <xsl:variable name="name" as="xs:string" select="@name"/>
    <xsl:variable name="attributes" as="element()?" select="attributes"/>
    <xsl:variable name="block" as="element()?" select="block"/>

    <xsl:sequence select="t:get-attributes($attributes)"/>
    <xsl:sequence select="t:get-modifiers(.)"/>
    <xsl:sequence select="'~'"/>
    <xsl:sequence select="$name"/>
    <xsl:sequence select="'('"/>
    <xsl:sequence select="')'"/>

    <xsl:choose>
      <xsl:when test="exists($block)">
        <xsl:sequence select="$t:new-line"/>
        <xsl:sequence select="t:get-statement($block)"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:sequence select="';'"/>
        <xsl:sequence select="$t:new-line"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!-- enum-member-declaration. -->
  <xsl:template mode="t:enum-member-declaration" match="value">
    <xsl:variable name="name" as="xs:string" select="@name"/>
    <xsl:variable name="attributes" as="element()?" select="attributes"/>
    <xsl:variable name="initializer" as="element()?" select="initialize"/>

    <xsl:sequence select="t:get-attributes($attributes)"/>
    <xsl:sequence select="$name"/>

    <xsl:if test="exists($initializer)">
      <xsl:sequence select="' '"/>
      <xsl:sequence select="'='"/>
      <xsl:sequence select="' '"/>
      <xsl:sequence select="t:get-variable-initializer($initializer)"/>
    </xsl:if>

    <xsl:sequence select="','"/>
    <xsl:sequence select="$t:new-line"/>
  </xsl:template>

</xsl:stylesheet>