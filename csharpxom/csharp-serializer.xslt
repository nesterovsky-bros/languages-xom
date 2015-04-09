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
  xmlns:cs="http://www.bphx.com/csharp-3.0/2009-05-23"
  xpath-default-namespace="http://www.bphx.com/csharp-3.0/2009-05-23"
  exclude-result-prefixes="xs t cs">

  <xsl:include href="csharp-common.xslt"/>
  <xsl:include href="csharp-streamer.xslt"/>
  <xsl:include href="csharp-serializer-comments.xslt"/>
  <xsl:include href="csharp-serializer-type-declarations.xslt"/>
  <xsl:include href="csharp-serializer-expressions.xslt"/>
  <xsl:include href="csharp-serializer-statements.xslt"/>

  <!-- Unit declaration table. -->
  <xsl:variable name="t:unit-declarations">
    <declaration name="extern-alias"/>
    <declaration name="using-alias"/>
    <declaration name="using-namespace"/>
    <declaration name="attributes"/>
    <declaration name="namespace"/>
    <declaration name="class"/>
    <declaration name="struct"/>
    <declaration name="interface"/>
    <declaration name="enum"/>
    <declaration name="delegate"/>
  </xsl:variable>

  <!-- Preprocessor instructions. -->
  <xsl:variable name="t:preprocessor-instructions">
    <instruction name="pp-define"/>
    <instruction name="pp-undef"/>
    <instruction name="pp-line"/>
    <instruction name="pp-pragma"/>
    <instruction name="pp-warning"/>
    <instruction name="pp-error"/>
    <instruction name="pp-region"/>
    <instruction name="pp-if"/>
  </xsl:variable>

  <!--
    Gets unit declaration info by the name.
      $name - an declaration name.
      Return unit declaration info.
  -->
  <xsl:function name="t:get-unit-declaration-info" as="element()?">
    <xsl:param name="name" as="xs:string"/>

    <xsl:sequence
      select="key('t:name', $name, $t:unit-declarations)"/>
  </xsl:function>

  <!--
    Gets preprocessor instruction info by the name.
      $name - an instruction name.
      Return preprocessor instruction info.
  -->
  <xsl:function name="t:get-preprocessor-instruction-info" as="element()?">
    <xsl:param name="name" as="xs:string"/>

    <xsl:sequence
      select="key('t:name', $name, $t:preprocessor-instructions)"/>
  </xsl:function>

  <!--
    Gets a sequence of tokens for a compilation unit.
      $unit - a compilation unit.
      Returns a sequence of tokens.
  -->
  <xsl:function name="t:get-unit" as="item()*">
    <xsl:param name="unit" as="element()"/>

    <xsl:sequence select="t:get-comments($unit)"/>

    <xsl:call-template name="t:get-unit-declarations">
      <xsl:with-param name="declarations" select="t:get-elements($unit)"/>
      <xsl:with-param name="content-handler" tunnel="yes" as="element()">
        <t:unit-declaration/>
      </xsl:with-param>
    </xsl:call-template>
  </xsl:function>

  <!-- Generates unit declarations. -->
  <xsl:template name="t:get-unit-declarations">
    <xsl:param name="declarations" as="element()*"/>

    <xsl:for-each select="$declarations">
      <xsl:variable name="index" as="xs:integer" select="position()"/>
      <xsl:variable name="next" as="element()?"
        select="$declarations[$index + 1]"/>

      <xsl:sequence select="t:get-comments(.)"/>

      <xsl:apply-templates mode="t:unit-declaration" select=".">
        <xsl:with-param name="generate-comments" select="false()"/>
      </xsl:apply-templates>

      <xsl:if test="
        exists($next) and
        (
          not
          (
            (self::using-namespace and $next[self::using-namespace]) or
            (self::using-alias and $next[self::using-alias]) or
            (self::extern-alias and $next[self::extern-alias])
          ) or
          exists($next/comment)
        )">
        <xsl:sequence select="$t:new-line"/>
      </xsl:if>
    </xsl:for-each>
  </xsl:template>

  <!--
    A content handler for the unit-declaration
  -->
  <xsl:template mode="t:call" match="t:unit-declaration">
    <xsl:param name="content" as="element()*"/>

    <xsl:call-template name="t:get-unit-declarations">
      <xsl:with-param name="declarations" select="$content"/>
    </xsl:call-template>
  </xsl:template>

  <!--
    Mode "t:unit-declaration". Default match.
  -->
  <xsl:template mode="t:unit-declaration" match="*">
    <xsl:sequence select="
      error
      (
        xs:QName('invalid-unit-declaration'),
        'Invalid unit declaration',
        .
      )"/>
  </xsl:template>

  <!--
    Mode "t:unit-declaration". Default match.
  -->
  <xsl:template mode="t:unit-declaration" match="unit">
    <xsl:apply-templates mode="#current" select="*"/>
  </xsl:template>

  <!--
    Generates extern alias declaration.
  -->
  <xsl:template mode="t:unit-declaration" match="extern-alias">
    <xsl:variable name="name" as="xs:string" select="@name"/>

    <xsl:sequence select="'extern'"/>
    <xsl:sequence select="' '"/>
    <xsl:sequence select="'alias'"/>
    <xsl:sequence select="' '"/>
    <xsl:sequence select="t:tokenize($name)"/>
    <xsl:sequence select="';'"/>
    <xsl:sequence select="$t:new-line"/>
  </xsl:template>

  <!--
    Generates using-alias directive.
  -->
  <xsl:template mode="t:unit-declaration" match="using-alias">
    <xsl:variable name="name" as="xs:string" select="@name"/>
    <xsl:variable name="type" as="element()" select="type"/>

    <xsl:variable name="is-namespace" as="xs:boolean"
      select="empty($type/@name)"/>

    <xsl:sequence select="'using'"/>
    <xsl:sequence select="' '"/>
    <xsl:sequence select="$name"/>
    <xsl:sequence select="' '"/>
    <xsl:sequence select="'='"/>
    <xsl:sequence select="' '"/>

    <xsl:choose>
      <xsl:when test="$is-namespace">
        <xsl:variable name="namespace" as="xs:string" select="$type/@namespace"/>

        <xsl:sequence select="t:tokenize($namespace)"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:sequence select="t:get-type($type)"/>
      </xsl:otherwise>
    </xsl:choose>

    <xsl:sequence select="';'"/>
    <xsl:sequence select="$t:new-line"/>
  </xsl:template>

  <!--
    Generates using-namespace directive.
  -->
  <xsl:template mode="t:unit-declaration" match="using-namespace">
    <xsl:variable name="name" as="xs:string" select="@name"/>

    <xsl:sequence select="'using'"/>
    <xsl:sequence select="' '"/>
    <xsl:sequence select="$name"/>
    <xsl:sequence select="';'"/>
    <xsl:sequence select="$t:new-line"/>
  </xsl:template>

  <!-- Generates global-attributes. -->
  <xsl:template mode="t:unit-declaration" match="attributes">
    <xsl:sequence select="t:get-attributes(.)"/>
  </xsl:template>

  <!-- Generates namespace-declaration. -->
  <xsl:template mode="t:unit-declaration" match="namespace">
    <xsl:variable name="name" as="xs:string" select="@name"/>

    <xsl:sequence select="'namespace'"/>
    <xsl:sequence select="' '"/>
    <xsl:sequence select="t:tokenize($name)"/>
    <xsl:sequence select="$t:new-line"/>
    <xsl:sequence select="'{'"/>
    <xsl:sequence select="$t:new-line"/>
    <xsl:sequence select="$t:indent"/>

    <xsl:call-template name="t:get-unit-declarations">
      <xsl:with-param name="declarations" select="t:get-elements(.)"/>
    </xsl:call-template>

    <xsl:sequence select="$t:unindent"/>
    <xsl:sequence select="'}'"/>
    <xsl:sequence select="$t:new-line"/>
  </xsl:template>

  <!--
    Gets a sequence of tokens for attributes.
      $attributes - an attributes.
      Returns a sequence of tokens.
  -->
  <xsl:function name="t:get-attributes" as="item()*">
    <xsl:param name="attributes" as="element()?"/>

    <xsl:sequence select="$attributes/attribute/t:get-attribute(.)"/>
  </xsl:function>

  <!--
    Gets a sequence of tokens for an attribute.
      $attribute - an attribute.
      Returns a sequence of tokens.
  -->
  <xsl:function name="t:get-attribute" as="item()+">
    <xsl:param name="attribute" as="element()"/>

    <xsl:variable name="target" as="xs:string?" select="$attribute/@target"/>
    <xsl:variable name="attribute-name" as="element()"
      select="$attribute/type"/>
    <xsl:variable name="arguments" as="element()?"
      select="$attribute/arguments"/>

    <xsl:sequence select="'['"/>

    <xsl:if test="$target">
      <xsl:sequence select="$target"/>
      <xsl:sequence select="':'"/>
    </xsl:if>

    <xsl:sequence select="t:get-type($attribute-name, true(), false())"/>

    <xsl:if test="exists($arguments)">
      <xsl:variable name="argument-list" as="element()+"
        select="t:get-elements($arguments)"/>

      <xsl:variable name="verbose" as="xs:integer?" select="
        (
          $arguments/@serialization-verbose,
          2
          [
            exists($argument-list/self::argument) and
            (count($argument-list) > 1)
          ]
        )[1]"/>

      <xsl:sequence select="'('"/>

      <xsl:for-each select="$argument-list">
        <xsl:choose>
          <xsl:when test="self::argument">
            <xsl:variable name="argument-name" as="xs:string" select="@name"/>
            <xsl:variable name="argument-expression" as="element()"
              select="t:get-elements(.)"/>

            <xsl:sequence select="$argument-name"/>
            <xsl:sequence select="' '"/>
            <xsl:sequence select="'='"/>
            <xsl:sequence select="' '"/>
            <xsl:sequence select="t:get-expression($argument-expression)"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:sequence select="t:get-expression(.)"/>
          </xsl:otherwise>
        </xsl:choose>

        <xsl:if test="position() != last()">
          <xsl:sequence select="','"/>
          <xsl:sequence select="' '"/>
          <xsl:sequence select="$t:soft-line-break"/>
        </xsl:if>
      </xsl:for-each>

      <xsl:sequence select="')'"/>
    </xsl:if>

    <xsl:sequence select="']'"/>
    <xsl:sequence select="$t:new-line"/>
  </xsl:function>

  <!--
    Gets tokens for a type.
      $type - a type element.
      Returns tokens for a type element.
  -->
  <xsl:function name="t:get-type" as="item()+">
    <xsl:param name="type" as="element()"/>

    <xsl:sequence select="t:get-type($type, false(), false())"/>
  </xsl:function>

  <!--
    Gets tokens for a type.
      $type - a type element.
      $attribute - attribute indicator.
      $container - a container type indicator.
      Returns tokens for a type element.
  -->
  <xsl:function name="t:get-type" as="item()+">
    <xsl:param name="type" as="element()"/>
    <xsl:param name="attribute" as="xs:boolean"/>
    <xsl:param name="container" as="xs:boolean"/>

    <xsl:variable name="nullable" as="xs:boolean"
      select="t:is-nullable-type($type)"/>

    <xsl:variable name="unwrapped-type" as="element()" select="
      if ($nullable) then
        $type/type-arguments/type
      else
        $type"/>

    <xsl:variable name="qualifier" as="xs:string?"
      select="$unwrapped-type/@qualifier"/>
    <xsl:variable name="namespace" as="xs:string?"
      select="$unwrapped-type/@namespace"/>
    <xsl:variable name="name" as="xs:string"
      select="$unwrapped-type/@name"/>
    <xsl:variable name="container-type" as="element()?"
      select="$unwrapped-type/type"/>
    <xsl:variable name="type-arguments" as="element()?"
      select="$unwrapped-type/type-arguments"/>
    <xsl:variable name="pointer" as="xs:integer?"
      select="$unwrapped-type/@pointer"/>
    <xsl:variable name="ranks" as="xs:integer*" select="
      for $item in tokenize($unwrapped-type/@rank, '\s', 'm') return
        xs:integer($item)"/>

    <xsl:if test="exists($container-type) and ($qualifier or $namespace)">
      <xsl:sequence select="
        error
        (
          xs:QName('nested-type-with-namespace-or-qualifier'),
          'Nested type cannot have a namespace or type qualifier.',
          $type
        )"/>
    </xsl:if>

    <xsl:if test="$container and ($nullable or $pointer or exists($ranks))">
      <xsl:sequence select="
        error
        (
          xs:QName('invalid-container-type'),
          'Container type cannot be nullable or a pointer or an array.',
          $type
        )"/>
    </xsl:if>

    <xsl:if test="exists($container-type)">
      <xsl:sequence select="t:get-type($container-type, false(), true())"/>
      <xsl:sequence select="'.'"/>
    </xsl:if>

    <xsl:if test="$qualifier">
      <xsl:sequence select="$qualifier"/>
      <xsl:sequence select="'::'"/>
    </xsl:if>

    <xsl:if test="$namespace">
      <xsl:sequence select="t:tokenize($namespace)"/>
      <xsl:sequence select="'.'"/>
    </xsl:if>

    <xsl:choose>
      <xsl:when test="
        $attribute and
        not($namespace) and
        not(xs:boolean($unwrapped-type/@remove-attribute-suffix)) and
        ends-with($name, 'Attribute') and
        (string-length($name) > 9)">
        <xsl:sequence
          select="substring($name, 1, string-length($name) - 9)"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:sequence select="$name"/>
      </xsl:otherwise>
    </xsl:choose>

    <xsl:if test="exists($type-arguments)">
      <xsl:sequence select="t:get-type-argument-list($type-arguments/type)"/>
    </xsl:if>

    <xsl:choose>
      <xsl:when test="exists($ranks)">
        <xsl:if test="$nullable or $pointer">
          <xsl:sequence select="
            error
            (
              xs:QName('type-array-nullable-or-pointer'),
              'no nullable or pointer specifier are compatible to array  type.',
              $type
            )"/>
        </xsl:if>

        <xsl:for-each select="$ranks">
          <xsl:variable name="rank" as="xs:integer" select="."/>

          <xsl:if test="$rank lt 1">
            <xsl:sequence select="
              error
              (
                xs:QName('type-array-positive-rank'),
                'array type rank must be a positive integer value.',
                $type
              )"/>
          </xsl:if>

          <xsl:sequence select="'['"/>

          <xsl:sequence select="
            for $i in 1 to $rank - 1 return
              ','"/>

          <xsl:sequence select="']'"/>
        </xsl:for-each>
      </xsl:when>
      <xsl:when test="$nullable">
        <xsl:if test="$pointer">
          <xsl:sequence select="
            error
            (
              xs:QName('type-nullable-pointer-mutually-exclusive'),
              'nullable and pointer specifiers are mutually exclusive in type.',
              $type
            )"/>
        </xsl:if>

        <xsl:sequence select="'?'"/>
      </xsl:when>
      <xsl:when test="$pointer">
        <xsl:sequence select="
          for $i in 1 to $pointer return
            '*'"/>
      </xsl:when>
    </xsl:choose>
  </xsl:function>

  <!--
    Gets tokens for a type argument list.
      $type-arguments - a list of type arguments.
      Returns a sequence of tokens.
  -->
  <xsl:function name="t:get-type-argument-list" as="item()+">
    <xsl:param name="type-arguments" as="element()+"/>

    <xsl:sequence select="'&lt;'"/>

    <xsl:for-each select="$type-arguments">
      <xsl:choose>
        <xsl:when
          test="empty(@name) and empty(type-arguments) and empty(type)">
          <!-- Unbounded type. -->
        </xsl:when>
        <xsl:otherwise>
          <xsl:sequence select="t:get-type(.)"/>
        </xsl:otherwise>
      </xsl:choose>

      <xsl:if test="position() != last()">
        <xsl:sequence select="','"/>
        <xsl:sequence select="' '"/>
      </xsl:if>
    </xsl:for-each>

    <xsl:sequence select="'&gt;'"/>
  </xsl:function>

  <!--
    Gets a list of preprocessor instructions.
      $element - a scope to get preprocessor instructions for.
      Returns a list of preprocessor instructions.
  -->
  <xsl:function name="t:get-preprocessor-instructions" as="element()*">
    <xsl:param name="element" as="element()"/>

    <xsl:sequence select="
      $element/
      (
        pp-define,
        pp-undef,
        pp-line,
        pp-pragma,
        pp-warning,
        pp-error,
        pp-region,
        pp-if
      )"/>
  </xsl:function>

  <!--
    Mode "t:preprocessor-instruction". Default match.
  -->
  <xsl:template mode="t:preprocessor-instruction" match="*"/>

  <!--
    Mode "t:preprocessor-instruction".
    Generates preprocessor #define and #undef.
  -->
  <xsl:template mode="
    t:preprocessor-instruction
    t:unit-declaration
    t:class-member-declaration
    t:struct-member-declaration
    t:interface-member-declaration
    t:enum-member-declaration
    t:statement"
    match="pp-define | pp-undef" as="item()+">
    <xsl:variable name="name" as="xs:string" select="@name"/>

    <xsl:sequence select="$t:new-line"/>
    <xsl:sequence select="$t:line-indent"/>
    <xsl:sequence select="$t:noformat"/>
    <xsl:sequence select="'#'"/>

    <xsl:sequence select="
      if (self::pp-define) then
        'define'
      else
        'undef'"/>

    <xsl:sequence select="' '"/>
    <xsl:sequence select="$name"/>
    <xsl:sequence select="$t:new-line"/>
  </xsl:template>

  <!--
    Mode "t:preprocessor-instruction".
    Generates preprocessor #line.
  -->
  <xsl:template mode="
    t:preprocessor-instruction
    t:unit-declaration
    t:class-member-declaration
    t:struct-member-declaration
    t:interface-member-declaration
    t:enum-member-declaration
    t:statement"
    match="pp-line" as="item()+">
    <xsl:variable name="line" as="xs:integer?" select="@line"/>
    <xsl:variable name="file" as="xs:string?" select="@file"/>
    <xsl:variable name="hidden" as="xs:boolean?" select="@hidden"/>
    <xsl:variable name="default" as="xs:boolean?" select="@default"/>

    <xsl:sequence select="$t:new-line"/>
    <xsl:sequence select="$t:line-indent"/>
    <xsl:sequence select="$t:noformat"/>
    <xsl:sequence select="'#'"/>
    <xsl:sequence select="'line'"/>
    <xsl:sequence select="' '"/>

    <xsl:choose>
      <xsl:when test="$hidden">
        <xsl:sequence select="'hidden'"/>
      </xsl:when>
      <xsl:when test="$default">
        <xsl:sequence select="'default'"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:if test="empty($line)">
          <xsl:sequence select="
            error
            (
              xs:QName('pp-line-line'),
              'Either line number, hidden or default is expected.',
              .
            )"/>
        </xsl:if>

        <xsl:if test="matches($file, '[\r\n&quot;]', 'm')">
          <xsl:sequence select="
            error
            (
              xs:QName('pp-line-file'),
              'Invalid file name.',
              .
            )"/>
        </xsl:if>

        <xsl:sequence select="xs:string($line)"/>
        <xsl:sequence select="concat('&quot;', $file, '&quot;')"/>
      </xsl:otherwise>
    </xsl:choose>

    <xsl:sequence select="$t:new-line"/>
  </xsl:template>


  <!--
    Mode "t:preprocessor-instruction".
    Generates preprocessor #pragma.
  -->
  <xsl:template mode="
    t:preprocessor-instruction
    t:unit-declaration
    t:class-member-declaration
    t:struct-member-declaration
    t:interface-member-declaration
    t:enum-member-declaration
    t:statement"
    match="pp-pragma" as="item()+">
    <xsl:variable name="name" as="xs:string" select="@name"/>
    <xsl:variable name="options" as="xs:string?" select="@options"/>

    <xsl:sequence select="$t:new-line"/>
    <xsl:sequence select="$t:line-indent"/>
    <xsl:sequence select="$t:noformat"/>
    <xsl:sequence select="'#'"/>
    <xsl:sequence select="'pragma'"/>
    <xsl:sequence select="' '"/>
    <xsl:sequence select="$name"/>

    <xsl:if test="$options">
      <xsl:sequence select="' '"/>
      <xsl:sequence select="$options"/>
    </xsl:if>

    <xsl:sequence select="$t:new-line"/>
  </xsl:template>

  <!--
    Mode "t:preprocessor-instruction".
    Generates preprocessor #warning or #error.
  -->
  <xsl:template mode="
    t:preprocessor-instruction
    t:unit-declaration
    t:class-member-declaration
    t:struct-member-declaration
    t:interface-member-declaration
    t:enum-member-declaration
    t:statement"
    match="pp-warning | pp-error" as="item()+">
    <xsl:variable name="message" as="xs:string?" select="@message"/>

    <xsl:sequence select="$t:new-line"/>
    <xsl:sequence select="$t:line-indent"/>
    <xsl:sequence select="$t:noformat"/>
    <xsl:sequence select="'#'"/>

    <xsl:sequence select="
      if (self::pp-warning) then
        'warning'
      else
        'error'"/>

    <xsl:if test="$message">
      <xsl:if test="matches($message, '[\r\n]', 'm')">
        <xsl:sequence select="
          error
          (
            xs:QName('pp-diagnostics-message'),
            'Invalid message.',
            .
          )"/>
      </xsl:if>

      <xsl:sequence select="' '"/>
      <xsl:sequence select="$message"/>
    </xsl:if>

    <xsl:sequence select="$t:new-line"/>
  </xsl:template>

  <!--
    Mode "t:preprocessor-instruction".
    Generates preprocessor #region.
      $content-handler - a content handler.
      $generate-comments - true or empty to generate comment, false to omit.
  -->
  <xsl:template mode="
    t:preprocessor-instruction
    t:unit-declaration
    t:class-member-declaration
    t:struct-member-declaration
    t:interface-member-declaration
    t:enum-member-declaration
    t:statement"
    match="pp-region" as="item()*">
    <xsl:param name="content-handler" tunnel="yes" as="element()"/>
    <xsl:param name="generate-comments" as="xs:boolean?" select="true()"/>

    <xsl:variable name="name" as="xs:string?" select="@name"/>
    <xsl:variable name="implicit" as="xs:boolean?" select="@implicit"/>

    <xsl:if test="not($implicit)">
      <xsl:sequence select="$t:line-indent"/>
      <xsl:sequence select="$t:noformat"/>
      <xsl:sequence select="'#'"/>

      <xsl:sequence select="'region'"/>

      <xsl:if test="$name">
        <xsl:if test="matches($name, '[\r\n]', 'm')">
          <xsl:sequence select="
            error
            (
              xs:QName('pp-region-name'),
              'Invalid region name.',
              $name
            )"/>
        </xsl:if>

        <xsl:sequence select="' '"/>
        <xsl:sequence select="$name"/>
      </xsl:if>

      <xsl:sequence select="$t:new-line"/>
    </xsl:if>

    <xsl:if test="not($generate-comments = false())">
      <xsl:sequence select="t:get-comments(.)"/>
    </xsl:if>

    <xsl:apply-templates mode="t:call" select="$content-handler">
      <xsl:with-param name="content" select="t:get-elements(.)"/>
    </xsl:apply-templates>

    <xsl:if test="not($implicit)">
      <xsl:sequence select="$t:line-indent"/>
      <xsl:sequence select="$t:noformat"/>
      <xsl:sequence select="'#'"/>

      <xsl:sequence select="'endregion'"/>
      <xsl:sequence select="$t:new-line"/>
    </xsl:if>
  </xsl:template>

  <!--
    Mode "t:preprocessor-instruction".
    Generates preprocessor #if.
      $content-handler - a content handler.
      $elseif - elseif indicator.
  -->
  <xsl:template mode="
    t:preprocessor-instruction
    t:unit-declaration
    t:class-member-declaration
    t:struct-member-declaration
    t:interface-member-declaration
    t:enum-member-declaration
    t:statement"
    match="pp-if" as="item()+">
    <xsl:param name="content-handler" tunnel="yes" as="element()"/>
    <xsl:param name="elseif" as="xs:boolean?" select="false()"/>

    <xsl:variable name="condition" as="element()" select="pp-condition"/>
    <xsl:variable name="then" as="element()" select="pp-then"/>
    <xsl:variable name="else" as="element()?" select="pp-else"/>
    <xsl:variable name="else-elements" as="element()*"
      select="t:get-elements($else)"/>

    <xsl:sequence select="$t:line-indent"/>
    <xsl:sequence select="$t:noformat"/>
    <xsl:sequence select="'#'"/>

    <xsl:choose>
      <xsl:when test="$elseif">
        <xsl:sequence select="'elif'"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:sequence select="'if'"/>
      </xsl:otherwise>
    </xsl:choose>

    <xsl:sequence select="' '"/>

    <xsl:apply-templates mode="t:preprocessor-expression"
      select="t:get-preprocessor-expressions($condition)"/>

    <xsl:sequence select="$t:new-line"/>

    <xsl:sequence select="t:get-comments($then)"/>

    <xsl:apply-templates mode="t:call" select="$content-handler">
      <xsl:with-param name="content" select="t:get-elements($then)"/>
    </xsl:apply-templates>

    <xsl:choose>
      <xsl:when test="empty($else)">
        <xsl:sequence select="$t:line-indent"/>
        <xsl:sequence select="$t:noformat"/>
        <xsl:sequence select="'#'"/>
        <xsl:sequence select="'endif'"/>
        <xsl:sequence select="$t:new-line"/>
      </xsl:when>
      <xsl:when test="
        (count($else-elements) = 1) and exists($else-elements[self::pp-if])">
        <xsl:apply-templates mode="#current" select="$else-elements">
          <xsl:with-param name="elseif" select="true()"/>
        </xsl:apply-templates>
      </xsl:when>
      <xsl:otherwise>
        <xsl:sequence select="$t:line-indent"/>
        <xsl:sequence select="$t:noformat"/>
        <xsl:sequence select="'#'"/>
        <xsl:sequence select="'else'"/>
        <xsl:sequence select="$t:new-line"/>

        <xsl:sequence select="t:get-comments($else)"/>

        <xsl:apply-templates mode="t:call" select="$content-handler">
          <xsl:with-param name="content" select="$else-elements"/>
        </xsl:apply-templates>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!--
    Gets a preprocessor expressions for an element.
      $element - an element to get preprocessor expression for.
      Returns a preprocesor expressions, if any.
  -->
  <xsl:function name="t:get-preprocessor-expressions" as="element()*">
    <xsl:param name="element" as="element()"/>

    <xsl:sequence select="
      $element/
      (
        pp-macro |
        pp-or |
        pp-and |
        pp-eq |
        pp-ne |
        pp-not |
        pp-parens
      )"/>
  </xsl:function>

  <!--
    Mode "t:preprocessor-expression". Default match.
  -->
  <xsl:template mode="t:preprocessor-expression" match="*"/>

  <!--
    Mode "t:preprocessor-expression". macro.
  -->
  <xsl:template mode="t:preprocessor-expression" match="pp-macro" as="item()+">
    <xsl:variable name="name" as="xs:string" select="@name"/>

    <xsl:sequence select="$name"/>
  </xsl:template>

  <!--
    Mode "t:preprocessor-expression". or, and, eq, ne.
  -->
  <xsl:template mode="t:preprocessor-expression"
    match="pp-or | pp-and | pp-eq | pp-ne" as="item()+">

    <xsl:variable name="expressions" as="element()+"
      select="t:get-preprocessor-expressions(.)"/>

    <xsl:variable name="left-tokens" as="item()+">
      <xsl:apply-templates mode="#current" select="$expressions[1]"/>
    </xsl:variable>

    <xsl:variable name="right-tokens" as="item()+">
      <xsl:apply-templates mode="#current" select="$expressions[2]"/>
    </xsl:variable>

    <xsl:sequence select="$left-tokens"/>
    <xsl:sequence select="' '"/>

    <xsl:sequence select="
      if (self::pp-or) then
        '||'
      else if (self::pp-and) then
        '&amp;&amp;'
      else if (self::pp-eq) then
        '=='
      else (: if (self::pp-ne) then :)
        '!='"/>

    <xsl:sequence select="' '"/>
    <xsl:sequence select="$right-tokens"/>
  </xsl:template>

  <!--
    Mode "t:preprocessor-expression". not.
  -->
  <xsl:template mode="t:preprocessor-expression" match="pp-not" as="item()+">
    <xsl:variable name="expression" as="element()"
      select="t:get-preprocessor-expressions(.)"/>

    <xsl:variable name="tokens" as="item()+">
      <xsl:apply-templates mode="#current" select="$expression"/>
    </xsl:variable>

    <xsl:sequence select="'!'"/>

    <xsl:choose>
      <xsl:when
        test="$expression[self::pp-macro or self::pp-not or self::pp-parens]">
        <xsl:sequence select="$tokens"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:sequence select="'('"/>
        <xsl:sequence select="$tokens"/>
        <xsl:sequence select="')'"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!--
    Mode "t:preprocessor-expression". parens.
  -->
  <xsl:template mode="t:preprocessor-expression"
    match="pp-parens" as="item()+">
    <xsl:variable name="expression" as="element()"
      select="t:get-preprocessor-expressions(.)"/>

    <xsl:variable name="tokens" as="item()+">
      <xsl:apply-templates mode="#current" select="$expression"/>
    </xsl:variable>

    <xsl:sequence select="'('"/>
    <xsl:sequence select="$tokens"/>
    <xsl:sequence select="')'"/>
  </xsl:template>

  <!--
    Gets tokens for an element.
      $element - an element to get tokens for.
  -->
  <xsl:function name="t:get-tokens-for-element" as="item()*">
    <xsl:param name="element" as="element()"/>

    <xsl:if test="exists($element[self::cs:*])">
      <xsl:variable name="name" as="xs:string" select="local-name($element)"/>

      <xsl:choose>
        <xsl:when test="exists($element[self::unit])">
          <xsl:call-template name="t:get-unit-declarations">
            <xsl:with-param name="declarations"
              select="t:get-elements($element)"/>
            <xsl:with-param name="content-handler" tunnel="yes" as="element()">
              <t:any-declaration/>
            </xsl:with-param>
          </xsl:call-template>
        </xsl:when>
        <xsl:when test="exists(t:get-unit-declaration-info($name))">
          <xsl:call-template name="t:get-unit-declarations">
            <xsl:with-param name="declarations" select="$element"/>
            <xsl:with-param name="content-handler" tunnel="yes" as="element()">
              <t:any-declaration/>
            </xsl:with-param>
          </xsl:call-template>
        </xsl:when>
        <xsl:when test="exists(t:get-preprocessor-instruction-info($name))">
          <xsl:apply-templates mode="t:preprocessor-instruction" select="$element">
            <xsl:with-param name="content-handler" tunnel="yes" as="element()">
              <t:any-declaration/>
            </xsl:with-param>
          </xsl:apply-templates>
        </xsl:when>
        <xsl:when test="exists(t:get-class-member-info($name))">
          <xsl:call-template name="t:get-class-member-declarations">
            <xsl:with-param name="declarations" select="$element"/>
            <xsl:with-param name="content-handler" tunnel="yes" as="element()">
              <t:any-declaration/>
            </xsl:with-param>
          </xsl:call-template>
        </xsl:when>
        <xsl:when test="exists(t:get-struct-member-info($name))">
          <xsl:call-template name="t:get-struct-member-declarations">
            <xsl:with-param name="declarations" select="$element"/>
            <xsl:with-param name="content-handler" tunnel="yes" as="element()">
              <t:any-declaration/>
            </xsl:with-param>
          </xsl:call-template>
        </xsl:when>
        <xsl:when test="exists(t:get-interface-member-info($name))">
          <xsl:call-template name="t:get-interface-member-declarations">
            <xsl:with-param name="declarations" select="$element"/>
            <xsl:with-param name="content-handler" tunnel="yes" as="element()">
              <t:any-declaration/>
            </xsl:with-param>
          </xsl:call-template>
        </xsl:when>
        <xsl:when test="exists(t:get-enum-member-info($name))">
          <xsl:call-template name="t:get-enum-member-declarations">
            <xsl:with-param name="declarations" select="$element"/>
            <xsl:with-param name="content-handler" tunnel="yes" as="element()">
              <t:any-declaration/>
            </xsl:with-param>
          </xsl:call-template>
        </xsl:when>
        <xsl:when test="exists(t:get-statement-info($name))">
          <xsl:apply-templates mode="t:statement" select="$element">
            <xsl:with-param name="content-handler" tunnel="yes" as="element()">
              <t:any-declaration/>
            </xsl:with-param>
          </xsl:apply-templates>
        </xsl:when>
        <xsl:when test="exists(t:get-expression-info($name))">
          <xsl:apply-templates mode="t:expression" select="$element"/>
        </xsl:when>
      </xsl:choose>
    </xsl:if>
  </xsl:function>

  <!--
    A content handler for the unit-declaration
  -->
  <xsl:template mode="t:call" match="t:any-declaration">
    <xsl:param name="content" as="element()*"/>

    <xsl:sequence select="$content/t:get-tokens-for-element(.)"/>
  </xsl:template>

</xsl:stylesheet>