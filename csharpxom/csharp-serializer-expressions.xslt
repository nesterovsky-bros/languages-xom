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

  <!-- Expression table. -->
  <xsl:variable name="t:expressions">
    <t:expression name="true" overloadable="true" operator="true"/>
    <t:expression name="false" overloadable="true" operator="false"/>

    <t:expression name="bool" precedence="0"/>
    <t:expression name="sbyte" precedence="0"/>
    <t:expression name="byte" precedence="0"/>
    <t:expression name="short" precedence="0"/>
    <t:expression name="ushort" precedence="0"/>
    <t:expression name="int" precedence="0"/>
    <t:expression name="uint" precedence="0"/>
    <t:expression name="long" precedence="0"/>
    <t:expression name="ulong" precedence="0"/>
    <t:expression name="float" precedence="0"/>
    <t:expression name="double" precedence="0"/>
    <t:expression name="decimal" precedence="0"/>
    <t:expression name="char" precedence="0"/>
    <t:expression name="string" precedence="0"/>
    <t:expression name="null" precedence="0"/>
    <t:expression name="var-ref" precedence="1"/>
    <t:expression name="field-ref" precedence="1"/>
    <t:expression name="property-ref" precedence="1"/>
    <t:expression name="event-ref" precedence="1"/>
    <t:expression name="method-ref" precedence="1"/>
    <t:expression name="static-field-ref" precedence="1"/>
    <t:expression name="static-property-ref" precedence="1"/>
    <t:expression name="static-event-ref" precedence="1"/>
    <t:expression name="static-method-ref" precedence="1"/>
    <t:expression name="parens" precedence="0"/>
    <t:expression name="invoke" precedence="1" statement-expression="true"/>
    <t:expression name="subscript" precedence="1"/>
    <t:expression name="this" precedence="0"/>
    <t:expression name="base" precedence="1"/>
    <t:expression name="post-inc" precedence="1" statement-expression="true"/>
    <t:expression name="post-dec" precedence="1" statement-expression="true"/>
    <t:expression name="new-object" precedence="1" statement-expression="true"/>
    <t:expression name="new-array" precedence="1"/>
    <t:expression name="stackalloc" precedence="0"/>
    <t:expression name="new-delegate" precedence="1"/>
    <t:expression name="typeof" precedence="1"/>
    <t:expression name="checked" precedence="1"/>
    <t:expression name="unchecked" precedence="1"/>
    <t:expression name="pointer-member-ref" precedence="1"/>
    <t:expression name="pointer-subscript" precedence="1"/>
    <t:expression name="sizeof" precedence="1"/>
    
    <t:expression name="await" precedence="1" statement-expression="true"/>
    
    <t:expression name="default" precedence="1"/>
    <t:expression name="plus" precedence="2" overloadable="true" operator="+"/>
    <t:expression name="neg" precedence="2" overloadable="true" operator="-"/>
    <t:expression name="not" precedence="2" overloadable="true" operator="!"/>
    <t:expression name="inv" precedence="2" overloadable="true" operator="~"/>
    <t:expression name="inc" precedence="2" overloadable="true"
      operator="++" statement-expression="true"/>
    <t:expression name="dec" precedence="2" overloadable="true"
      operator="--" statement-expression="true"/>
    <t:expression name="cast" precedence="2"/>
    <t:expression name="deref" precedence="2" operator="*"/>
    <t:expression name="addressof" precedence="2" operator="&amp;"/>
    <t:expression name="mul" precedence="3" overloadable="true" 
      operator="*" associative="true"/>
    <t:expression name="div" precedence="3" overloadable="true" operator="/"/>
    <t:expression name="mod" precedence="3" overloadable="true" operator="%"/>
    <t:expression name="add" precedence="4" overloadable="true" 
      operator="+" associative="true"/>
    <t:expression name="sub" precedence="4" overloadable="true" operator="-"/>
    <t:expression name="lsh" precedence="5" overloadable="true"
      operator="&lt;&lt;"/>
    <t:expression name="rsh" precedence="5" overloadable="true"
      operatr="&gt;&gt;"/>
    <t:expression name="lt" precedence="6" overloadable="true" operator="&lt;"/>
    <t:expression name="gt" precedence="6" overloadable="true" operator="&gt;"/>
    <t:expression name="le" precedence="6" overloadable="true"
      operator="&lt;="/>
    <t:expression name="ge" precedence="6" overloadable="true"
      operator="&gt;="/>
    <t:expression name="is" precedence="6" operator="is"/>
    <t:expression name="as" precedence="6" operator="as"/>
    <t:expression name="eq" precedence="7" overloadable="true" operator="=="/>
    <t:expression name="ne" precedence="7" overloadable="true" operator="!="/>
    <t:expression name="binary-and" precedence="8" overloadable="true"
      operator="&amp;" associative="true"/>
    <t:expression name="binary-xor" precedence="9" overloadable="true"
      operator="^"/>
    <t:expression name="binary-or" precedence="10" overloadable="true"
      operator="|" associative="true"/>
    <t:expression name="and" precedence="11"
      operator="&amp;&amp;" associative="true"/>
    <t:expression name="or" precedence="12" operator="||" 
      associative="true"/>
    <t:expression name="coalesce" precedence="13" operator="??"
      associative="true"/>
    <t:expression name="condition" precedence="14"/>
    <t:expression name="lambda" precedence="15" operator="=>"/>
    <t:expression name="anonymous-method" precedence="1"/>
    <t:expression name="assign" precedence="15" operator="="
      statement-expression="true" right-to-left="true"/>
    <t:expression name="add-to" precedence="15"  operator="+="
      statement-expression="true" right-to-left="true"/>
    <t:expression name="sub-from" precedence="15"  operator="-="
      statement-expression="true" right-to-left="true"/>
    <t:expression name="mul-to" precedence="15"  operator="*="
      statement-expression="true" right-to-left="true"/>
    <t:expression name="div-by" precedence="15"  operator="/="
      statement-expression="true" right-to-left="true"/>
    <t:expression name="mod-by" precedence="15"  operator="%="
      statement-expression="true" right-to-left="true"/>
    <t:expression name="binary-and-with" precedence="15" operator="&amp;="
      statement-expression="true" right-to-left="true"/>
    <t:expression name="binary-or-with" precedence="15" operator="|="
      statement-expression="true" right-to-left="true"/>
    <t:expression name="binary-xor-with" precedence="15" operator="^="
      statement-expression="true" right-to-left="true"/>
    <t:expression name="lsh-to" precedence="15"  operator="&lt;&lt;="
      statement-expression="true" right-to-left="true"/>
    <t:expression name="rsh-to" precedence="15"  operator=">>="
      statement-expression="true" right-to-left="true"/>

    <t:expression name="snippet-expression" precedence="1"
      statement-expression="true"/>
    <t:expression name="transparent-expression" precedence="1"
      statement-expression="true"/>
  </xsl:variable>

  <!--
    Gets expression info by the name.
      $name - an expression name.
      Return expression info.
  -->
  <xsl:function name="t:get-expression-info" as="element()?">
    <xsl:param name="name" as="xs:string"/>

    <xsl:sequence
      select="key('t:name', $name, $t:expressions)"/>
  </xsl:function>

  <!--
    Gets expression precedence.
      $expression - an expression to get precedence for.
      Return expression precedence.
  -->
  <xsl:function name="t:get-expression-precedence" as="xs:integer">
    <xsl:param name="expression" as="element()"/>

    <xsl:choose>
      <xsl:when test="$expression[self::transparent-expression]">
        <xsl:sequence
          select="t:get-expression-precedence(t:get-elements($expression))"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:sequence select="
          t:get-expression-info(local-name($expression))/@precedence"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:function>

  <!--
    Gets a sequence of tokens for an expression.
      $expression - an expression.
      Returns a sequence of tokens.
  -->
  <xsl:function name="t:get-expression" as="item()+">
    <xsl:param name="expression" as="element()"/>

    <xsl:variable name="tokens" as="item()+"
      select="t:get-nested-expression($expression)"/>

    <xsl:sequence select="t:indent-from-second-line($tokens)"/>
  </xsl:function>

  <!--
    Gets a sequence of tokens for a nested expression.
      $expression - an expression.
      Returns a sequence of tokens.
  -->
  <xsl:function name="t:get-nested-expression" as="item()+">
    <xsl:param name="expression" as="element()"/>

    <xsl:apply-templates mode="t:expression" select="$expression"/>
  </xsl:function>

  <!--
    Gets a sequence of tokens for an statement expression.
      $expression - a statement expression.
      Returns a sequence of tokens.
  -->
  <xsl:function name="t:get-statement-expression" as="item()+">
    <xsl:param name="expression" as="element()"/>

    <xsl:variable name="statement-expression" as="xs:boolean?" select="
      t:get-expression-info(local-name($expression))/@statement-expression"/>

    <xsl:if test="not($statement-expression)">
      <xsl:sequence select="
        error
        (
          xs:QName('statement-expression-expected'),
          'A statement expression is expected.',
          $expression
        )"/>
    </xsl:if>

    <xsl:sequence select="t:get-expression($expression)"/>
  </xsl:function>

  <!--
    Gets a sequence of tokens for an variable initializer.
      $initializer - a variable initializer.
      Returns a sequence of tokens.
  -->
  <xsl:function name="t:get-variable-initializer" as="item()*">
    <xsl:param name="initializer" as="element()"/>

    <xsl:variable name="elements" as="element()*"
     select="t:get-elements($initializer)"/>
    <xsl:variable name="stackalloc" as="element()?"
      select="$elements[self::stackalloc]"/>

    <xsl:choose>
      <xsl:when test="exists($stackalloc)">
        <xsl:variable name="type" as="element()" select="$stackalloc/type"/>
        <xsl:variable name="expression" as="element()"
          select="t:get-elements($stackalloc) except $type"/>

        <xsl:sequence select="'stackalloc'"/>
        <xsl:sequence select="' '"/>
        <xsl:sequence select="t:get-type($type)"/>
        <xsl:sequence select="'['"/>
        <xsl:sequence select="t:get-nested-expression($expression)"/>
        <xsl:sequence select="']'"/>
      </xsl:when>
      <xsl:when test="
        exists($elements) and empty($elements[self::member or self::item])">
        <xsl:variable name="expression" as="element()" select="$elements"/>

        <xsl:sequence select="t:get-expression($expression)"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:sequence
          select="t:get-object-or-collection-initializer($elements)"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:function>

  <!--
    Gets a sequence of tokens for an variable initializer.
      $elements - initializer elements.
      Returns a sequence of tokens.
  -->
  <xsl:function name="t:get-object-or-collection-initializer" as="item()*">
    <xsl:param name="elements" as="element()*"/>

    <xsl:variable name="members" as="element()*"
      select="$elements[self::member]"/>
    <xsl:variable name="items" as="element()*"
      select="$elements[self::item]"/>

    <xsl:if test="exists($members) and exists($items)">
      <xsl:sequence select="
        error
        (
          xs:QName('invalid-object-or-collection-initializer'),
          'Invalid object or collection initializer.',
          $elements
        )"/>
    </xsl:if>

    <xsl:variable name="long-list" as="xs:boolean"
      select="count($elements) > 2"/>

    <xsl:choose>
      <xsl:when test="exists($members)">
        <xsl:choose>
          <xsl:when test="$long-list">
            <xsl:sequence select="$t:new-line"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:sequence select="' '"/>
          </xsl:otherwise>
        </xsl:choose>

        <xsl:sequence select="'{'"/>

        <xsl:choose>
          <xsl:when test="$long-list">
            <xsl:sequence select="$t:new-line"/>
            <xsl:sequence select="$t:indent"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:sequence select="' '"/>
          </xsl:otherwise>
        </xsl:choose>

        <xsl:for-each select="$members">
          <xsl:variable name="elements" as="element()*"
            select="t:get-elements(.)"/>
          <xsl:variable name="name" as="xs:string?" select="@name"/>

          <xsl:if test="
            empty($name) and
            empty
            (
              $elements
              [
                var-ref or
                field-ref or
                property-ref or
                event-ref or
                method-ref or
                static-field-ref or
                static-property-ref or
                static-event-ref or
                static-method-ref or
                base[exists(@name)]
              ]
            )">
            <xsl:sequence select="
              error
              (
                xs:QName('member-name-expected'),
                'A member name is expected.',
                .
              )"/>
          </xsl:if>

          <xsl:if test="exists($name)">
            <xsl:sequence select="$name"/>
            <xsl:sequence select="' '"/>
            <xsl:sequence select="'='"/>
            <xsl:sequence select="' '"/>
          </xsl:if>

          <xsl:choose>
            <xsl:when test="
              exists($elements) and
              empty($elements[self::member or self::item])">
              <xsl:variable name="expression" as="element()" select="$elements"/>

              <xsl:sequence select="t:get-expression($expression)"/>
            </xsl:when>
            <xsl:otherwise>
              <xsl:sequence
                select="t:get-object-or-collection-initializer($elements)"/>
            </xsl:otherwise>
          </xsl:choose>

          <xsl:if test="position() != last()">
            <xsl:sequence select="','"/>

            <xsl:choose>
              <xsl:when test="$long-list">
                <xsl:sequence select="$t:new-line"/>
              </xsl:when>
              <xsl:otherwise>
                <xsl:sequence select="' '"/>
              </xsl:otherwise>
            </xsl:choose>
          </xsl:if>
        </xsl:for-each>

        <xsl:choose>
          <xsl:when test="$long-list">
            <xsl:sequence select="$t:unindent"/>
            <xsl:sequence select="$t:new-line"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:sequence select="' '"/>
          </xsl:otherwise>
        </xsl:choose>

        <xsl:sequence select="'}'"/>
      </xsl:when>
      <xsl:when test="exists($items)">
        <xsl:choose>
          <xsl:when test="$long-list">
            <xsl:sequence select="$t:new-line"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:sequence select="' '"/>
          </xsl:otherwise>
        </xsl:choose>

        <xsl:sequence select="'{'"/>

        <xsl:choose>
          <xsl:when test="$long-list">
            <xsl:sequence select="$t:new-line"/>
            <xsl:sequence select="$t:indent"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:sequence select="' '"/>
          </xsl:otherwise>
        </xsl:choose>

        <xsl:for-each select="$items">
          <xsl:variable name="elements" as="element()*"
            select="t:get-elements(.)"/>

          <xsl:choose>
            <xsl:when test="
              exists($elements) and
              empty($elements[self::member or self::item])">
              <xsl:variable name="expression" as="element()" select="$elements"/>

              <xsl:sequence select="t:get-expression($expression)"/>
            </xsl:when>
            <xsl:otherwise>
              <xsl:sequence
                select="t:get-object-or-collection-initializer($elements)"/>
            </xsl:otherwise>
          </xsl:choose>

          <xsl:if test="position() != last()">
            <xsl:sequence select="','"/>

            <xsl:choose>
              <xsl:when test="$long-list">
                <xsl:sequence select="$t:new-line"/>
              </xsl:when>
              <xsl:otherwise>
                <xsl:sequence select="' '"/>
              </xsl:otherwise>
            </xsl:choose>
          </xsl:if>
        </xsl:for-each>

        <xsl:choose>
          <xsl:when test="$long-list">
            <xsl:sequence select="$t:unindent"/>
            <xsl:sequence select="$t:new-line"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:sequence select="' '"/>
          </xsl:otherwise>
        </xsl:choose>

        <xsl:sequence select="'}'"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:sequence select="'{'"/>
        <xsl:sequence select="'}'"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:function>

  <!--
    Gets a sequence of tokens for an arguments.
      $arguments - arguments element.
      Returns a sequence of tokens.
  -->
  <xsl:function name="t:get-arguments" as="item()*">
    <xsl:param name="arguments" as="element()"/>

    <xsl:variable name="tokens" as="item()*">
      <xsl:for-each select="t:get-elements($arguments)">
        <xsl:choose>
          <xsl:when test="self::argument">
            <xsl:variable name="name" as="xs:string" select="@name"/>

            <xsl:sequence select="$name"/>
            <xsl:sequence select="':'"/>
            <xsl:sequence select="' '"/>
            <xsl:sequence select="t:get-argument-value(t:get-elements(.))"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:sequence select="t:get-argument-value(.)"/>
          </xsl:otherwise>
        </xsl:choose>

        <xsl:if test="position() != last()">
          <xsl:sequence select="','"/>
          <xsl:sequence select="$t:terminator"/>
        </xsl:if>
      </xsl:for-each>
    </xsl:variable>

    <xsl:variable name="verbose" as="xs:integer?"
      select="$arguments/@serialization-verbose"/>

    <xsl:sequence select="
      t:reformat-tokens
      (
        $tokens,
        $verbose,
        ' ',
        $t:new-line,
        false(),
        false()
      )"/>
  </xsl:function>

  <!--
    Gets a sequence of tokens for an argument value.
      $argument - an argument.
      Returns a sequence of tokens.
  -->
  <xsl:function name="t:get-argument-value" as="item()*">
    <xsl:param name="argument" as="element()"/>

    <xsl:choose>
      <xsl:when test="$argument/self::ref">
        <xsl:sequence select="'ref'"/>
        <xsl:sequence select="' '"/>
        <xsl:sequence select="t:get-expression(t:get-elements($argument))"/>
      </xsl:when>
      <xsl:when test="$argument/self::out">
        <xsl:sequence select="'out'"/>
        <xsl:sequence select="' '"/>
        <xsl:sequence select="t:get-expression(t:get-elements($argument))"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:sequence select="t:get-expression($argument)"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:function>

  <!-- Mode "t:expression". Default match. -->
  <xsl:template mode="t:expression" match="*">
    <xsl:sequence select="
      error
      (
        xs:QName('invalid-expression'),
        'Invalid expression',
        .
      )"/>
  </xsl:template>

  <!-- Mode "t:expression". boolean-literal. -->
  <xsl:template mode="t:expression" match="bool">
    <xsl:variable name="value" as="xs:boolean" select="@value"/>

    <xsl:choose>
      <xsl:when test="$value">
        <xsl:sequence select="'true'"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:sequence select="'false'"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!-- Mode "t:expression". sbyte. -->
  <xsl:template mode="t:expression" match="sbyte">
    <xsl:variable name="value" as="xs:string" select="@value"/>

    <xsl:sequence select="'('"/>
    <xsl:sequence select="'sbyte'"/>
    <xsl:sequence select="')'"/>
    <xsl:sequence select="$value"/>
  </xsl:template>

  <!-- Mode "t:expression". byte. -->
  <xsl:template mode="t:expression" match="byte">
    <xsl:variable name="value" as="xs:string" select="@value"/>

    <xsl:sequence select="'('"/>
    <xsl:sequence select="'byte'"/>
    <xsl:sequence select="')'"/>
    <xsl:sequence select="$value"/>
  </xsl:template>

  <!-- Mode "t:expression". short. -->
  <xsl:template mode="t:expression" match="short">
    <xsl:variable name="value" as="xs:string" select="@value"/>

    <xsl:sequence select="'('"/>
    <xsl:sequence select="'short'"/>
    <xsl:sequence select="')'"/>
    <xsl:sequence select="$value"/>
  </xsl:template>

  <!-- Mode "t:expression". ushort. -->
  <xsl:template mode="t:expression" match="ushort">
    <xsl:variable name="value" as="xs:string" select="@value"/>

    <xsl:sequence select="'('"/>
    <xsl:sequence select="'ushort'"/>
    <xsl:sequence select="')'"/>
    <xsl:sequence select="$value"/>
  </xsl:template>

  <!-- Mode "t:expression". int. -->
  <xsl:template mode="t:expression" match="int">
    <xsl:variable name="value" as="xs:string" select="@value"/>

    <xsl:sequence select="$value"/>
  </xsl:template>

  <!-- Mode "t:expression". uint. -->
  <xsl:template mode="t:expression" match="uint">
    <xsl:variable name="value" as="xs:string" select="@value"/>
    <xsl:variable name="escaped" as="xs:boolean?" select="@escaped"/>

    <xsl:sequence select="concat($value, 'U')"/>
  </xsl:template>

  <!-- Mode "t:expression". long. -->
  <xsl:template mode="t:expression" match="long">
    <xsl:variable name="value" as="xs:string" select="@value"/>
    <xsl:variable name="escaped" as="xs:boolean?" select="@escaped"/>

    <xsl:sequence select="
      if ($escaped) then
        $value
      else
        concat($value, 'L')"/>
  </xsl:template>

  <!-- Mode "t:expression". ulong. -->
  <xsl:template mode="t:expression" match="ulong">
    <xsl:variable name="value" as="xs:string" select="@value"/>
    <xsl:variable name="escaped" as="xs:boolean?" select="@escaped"/>

    <xsl:sequence select="
      if ($escaped) then
        $value
      else
        concat($value, 'UL')"/>
  </xsl:template>

  <!-- Mode "t:expression". float. -->
  <xsl:template mode="t:expression" match="float">
    <xsl:variable name="value" as="xs:string" select="@value"/>
    <xsl:variable name="escaped" as="xs:boolean?" select="@escaped"/>

    <xsl:sequence select="
      if ($escaped) then
        $value
      else
        concat($value, 'F')"/>
  </xsl:template>

  <!-- Mode "t:expression". double. -->
  <xsl:template mode="t:expression" match="double">
    <xsl:variable name="value" as="xs:string" select="@value"/>

    <xsl:sequence select="$value"/>
  </xsl:template>

  <!-- Mode "t:expression". decimal. -->
  <xsl:template mode="t:expression" match="decimal">
    <xsl:variable name="value" as="xs:string" select="@value"/>
    <xsl:variable name="escaped" as="xs:boolean?" select="@escaped"/>

    <xsl:sequence select="
      if ($escaped) then
        $value
      else
        concat($value, 'M')"/>
  </xsl:template>

  <!-- Mode "t:expression". char. -->
  <xsl:template mode="t:expression" match="char">
    <xsl:variable name="value" as="xs:string" select="@value"/>
    <xsl:variable name="escaped" as="xs:boolean?" select="@escaped"/>

    <xsl:sequence select="
      if ($escaped) then
        concat('''', $value, '''')
      else
        concat
        (
          '''',
          replace
          (
            replace
            (
              replace
              (
                replace($value, '''', '\\'''),
                '\t',
                '\\t'
              ),
              '\n',
              '\\n'
            ),
            '\r',
            '\\r'
          ),
          ''''
        )"/>
  </xsl:template>

  <!-- Mode "t:expression". string. -->
  <xsl:template mode="t:expression" match="string">
    <xsl:variable name="value" as="xs:string" select="@value"/>
    <xsl:variable name="escaped" as="xs:boolean?" select="@escaped"/>
    <xsl:variable name="verbatim" as="xs:boolean?" select="@verbatim"/>

    <xsl:choose>
      <xsl:when test="$verbatim">
        <xsl:sequence select="
          concat
          (
            '@&quot;',
            replace($value, '&quot;', '&quot;&quot;'),
            '&quot;'
          )"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:sequence select="
          if ($escaped) then
            concat('&quot;', $value, '&quot;')
          else
            concat
            (
              '&quot;',
              replace
              (
                replace
                (
                  replace
                  (
                    replace
                    (
                      replace($value, '\\', '\\\\'),
                      '&quot;',
                      '\\&quot;'
                    ),
                    '\t',
                    '\\t'
                  ),
                  '\n',
                  '\\n'
                ),
                '\r',
                '\\r'
              ),
              '&quot;'
            )"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!-- Mode "t:expression". null-literal. -->
  <xsl:template mode="t:expression" match="null">

    <xsl:sequence select="'null'"/>
  </xsl:template>

  <!-- Mode "t:expression". var-ref. -->
  <xsl:template mode="t:expression" match="var-ref">
    <xsl:variable name="name" as="xs:string" select="@name"/>

    <xsl:sequence select="$name"/>
  </xsl:template>

  <!--
    Gets a container expression.
      $expression - a container expression.
      $child - a child expression.
  -->
  <xsl:function name="t:get-container-expression" as="item()*">
    <xsl:param name="container" as="element()?"/>
    <xsl:param name="child" as="element()"/>

    <xsl:if test="exists($container)">
      <xsl:variable name="child-precedence" as="xs:integer"
        select="t:get-expression-precedence($child)"/>
      <xsl:variable name="container-precedence" as="xs:integer"
        select="t:get-expression-precedence($container)"/>

      <xsl:choose>
        <xsl:when test="$child-precedence lt $container-precedence">
          <xsl:sequence select="'('"/>
          <xsl:sequence select="t:get-nested-expression($container)"/>
          <xsl:sequence select="')'"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:sequence select="t:get-nested-expression($container)"/>
        </xsl:otherwise>
      </xsl:choose>

      <xsl:sequence select="'.'"/>
    </xsl:if>
  </xsl:function>

  <!-- Mode "t:expression". field-ref, property-ref, event-ref. -->
  <xsl:template mode="t:expression"
    match="field-ref | property-ref | event-ref">
    <xsl:variable name="name" as="xs:string" select="@name"/>
    <xsl:variable name="expression" as="element()?"
      select="t:get-elements(.)"/>

    <xsl:sequence select="t:get-container-expression($expression, .)"/>
    <xsl:sequence select="$name"/>
  </xsl:template>

  <!-- Mode "t:expression". method-ref. -->
  <xsl:template mode="t:expression" match="method-ref">
    <xsl:variable name="name" as="xs:string" select="@name"/>
    <xsl:variable name="type-arguments" as="element()*"
      select="type-arguments"/>
    <xsl:variable name="expression" as="element()?"
      select="t:get-elements(.) except $type-arguments"/>

    <xsl:sequence select="t:get-container-expression($expression, .)"/>
    <xsl:sequence select="$name"/>

    <xsl:if test="exists($type-arguments)">
      <xsl:variable name="types" as="element()+"
        select="$type-arguments/type"/>

      <xsl:sequence select="'&lt;'"/>

      <xsl:for-each select="$types">
        <xsl:sequence select="t:get-type(.)"/>

        <xsl:if test="position() != last()">
          <xsl:sequence select="','"/>
          <xsl:sequence select="' '"/>
        </xsl:if>
      </xsl:for-each>

      <xsl:sequence select="'&gt;'"/>
    </xsl:if>
  </xsl:template>

  <!--
    Mode "t:expression".
    static-field-ref, static-property-ref, static-event-ref.
  -->
  <xsl:template mode="t:expression"
    match="static-field-ref | static-property-ref | static-event-ref">
    <xsl:variable name="name" as="xs:string" select="@name"/>
    <xsl:variable name="type" as="element()?" select="type"/>

    <xsl:if test="exists($type)">
      <xsl:sequence select="t:get-type($type)"/>
      <xsl:sequence select="'.'"/>
    </xsl:if>

    <xsl:sequence select="$name"/>
  </xsl:template>

  <!-- Mode "t:expression". static-method-ref. -->
  <xsl:template mode="t:expression" match="static-method-ref">
    <xsl:variable name="name" as="xs:string" select="@name"/>
    <xsl:variable name="type-arguments" as="element()*"
      select="type-arguments"/>
    <xsl:variable name="type" as="element()?" select="type"/>

    <xsl:if test="exists($type)">
      <xsl:sequence select="t:get-type($type)"/>
      <xsl:sequence select="'.'"/>
    </xsl:if>

    <xsl:sequence select="$name"/>

    <xsl:if test="exists($type-arguments)">
      <xsl:variable name="types" as="element()+"
        select="$type-arguments/type"/>

      <xsl:sequence select="'&lt;'"/>

      <xsl:for-each select="$types">
        <xsl:sequence select="t:get-type(.)"/>

        <xsl:if test="position() != last()">
          <xsl:sequence select="','"/>
          <xsl:sequence select="' '"/>
        </xsl:if>
      </xsl:for-each>

      <xsl:sequence select="'&gt;'"/>
    </xsl:if>
  </xsl:template>

  <!-- Mode "t:expression". parenthesized-expression. -->
  <xsl:template mode="t:expression" match="parens">
    <xsl:sequence select="'('"/>
    <xsl:sequence select="t:get-nested-expression(t:get-elements(.))"/>
    <xsl:sequence select="')'"/>
  </xsl:template>

  <!-- Mode "t:expression". invocation-expression. -->
  <xsl:template mode="t:expression" match="invoke">
    <xsl:variable name="arguments" as="element()?" select="arguments"/>
    <xsl:variable name="object" as="element()"
      select="t:get-elements(.) except $arguments"/>

    <xsl:variable name="this-precedence" as="xs:integer"
      select="t:get-expression-precedence(.)"/>
    <xsl:variable name="object-precedence" as="xs:integer"
      select="t:get-expression-precedence($object)"/>

    <xsl:choose>
      <xsl:when test="$this-precedence lt $object-precedence">
        <xsl:sequence select="'('"/>
        <xsl:sequence select="t:get-nested-expression($object)"/>
        <xsl:sequence select="')'"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:sequence select="t:get-nested-expression($object)"/>
      </xsl:otherwise>
    </xsl:choose>

    <xsl:sequence select="'('"/>
    <xsl:sequence select="$arguments/t:get-arguments(.)"/>
    <xsl:sequence select="')'"/>
  </xsl:template>

  <!-- Mode "t:expression". element-access. -->
  <xsl:template mode="t:expression" match="subscript">
    <xsl:variable name="elements" as="element()+"
      select="t:get-elements(.)"/>
    <xsl:variable name="object" as="element()" select="$elements[1]"/>
    <xsl:variable name="arguments" as="element()+"
      select="subsequence($elements, 2)"/>

    <xsl:sequence select="t:get-nested-expression($object)"/>
    <xsl:sequence select="'['"/>

    <xsl:for-each select="$arguments">
      <xsl:sequence select="t:get-expression(.)"/>

      <xsl:if test="position() != last()">
        <xsl:sequence select="','"/>
        <xsl:sequence select="' '"/>
      </xsl:if>
    </xsl:for-each>

    <xsl:sequence select="']'"/>
  </xsl:template>

  <!-- Mode "t:expression". this-access. -->
  <xsl:template mode="t:expression" match="this">
    <xsl:sequence select="'this'"/>
  </xsl:template>

  <!-- Mode "t:expression". base-access. -->
  <xsl:template mode="t:expression" match="base">
    <xsl:sequence select="'base'"/>
  </xsl:template>

  <!-- Mode "t:expression". post-increment-expression. -->
  <xsl:template mode="t:expression" match="post-inc">
    <xsl:variable name="expression" as="element()" select="t:get-elements(.)"/>

    <xsl:sequence select="t:get-nested-expression($expression)"/>
    <xsl:sequence select="'++'"/>
  </xsl:template>

  <!-- Mode "t:expression". post-decrement-expression. -->
  <xsl:template mode="t:expression" match="post-dec">
    <xsl:variable name="expression" as="element()" select="t:get-elements(.)"/>

    <xsl:sequence select="t:get-nested-expression($expression)"/>
    <xsl:sequence select="'--'"/>
  </xsl:template>

  <!-- Mode "t:expression". object-creation-expression. -->
  <xsl:template mode="t:expression" match="new-object">
    <xsl:variable name="type" as="element()?" select="type"/>
    <xsl:variable name="arguments" as="element()?" select="arguments"/>
    <xsl:variable name="initializer" as="element()?" select="initialize"/>

    <xsl:if
      test="empty($type) and (exists($arguments) or empty($initializer))">
      <xsl:sequence select="
        error
        (
          xs:QName('invalid-anonymous-object-creation-expression'),
          concat
          (
            'Anonymous object creation must have an initializer ',
            'and empty arguments.'
          ),
          .
        )"/>
    </xsl:if>

    <xsl:sequence select="'new'"/>

    <xsl:if test="exists($type)">
      <xsl:sequence select="' '"/>
      <xsl:sequence select="t:get-type($type)"/>
    </xsl:if>

    <xsl:if test="exists($arguments) or empty($initializer)">
      <xsl:sequence select="'('"/>
      <xsl:sequence select="$arguments/t:get-arguments(.)"/>
      <xsl:sequence select="')'"/>
    </xsl:if>

    <xsl:if test="exists($initializer)">
      <xsl:sequence select="
        t:get-object-or-collection-initializer(t:get-elements($initializer))"/>
    </xsl:if>
  </xsl:template>

  <!-- Mode "t:expression". array-creation-expression. -->
  <xsl:template mode="t:expression" match="new-array">
    <xsl:variable name="type" as="element()?" select="type"/>
    <xsl:variable name="initializer" as="element()?" select="initialize"/>
    <xsl:variable name="expressions" as="element()*"
      select="t:get-elements(.) except ($type, $initializer)"/>

    <xsl:variable name="ranks" as="xs:integer*" select="
      for $item in tokenize(@rank, '\s') return
        xs:integer($item)"/>

    <xsl:if test="empty($type) and empty($ranks) and empty($expressions)">
      <xsl:sequence select="
        error
        (
          xs:QName('array-rank-expected'),
          'Array rank is expected.',
          .
        )"/>
    </xsl:if>

    <xsl:sequence select="'new'"/>

    <xsl:if test="exists($type)">
      <xsl:sequence select="' '"/>
      <xsl:sequence select="t:get-type($type)"/>
    </xsl:if>

    <xsl:if test="exists($expressions)">
      <xsl:sequence select="'['"/>

      <xsl:for-each select="$expressions">
        <xsl:sequence select="t:get-expression(.)"/>

        <xsl:if test="position() != last()">
          <xsl:sequence select="','"/>
          <xsl:sequence select="' '"/>
        </xsl:if>
      </xsl:for-each>

      <xsl:sequence select="']'"/>
    </xsl:if>

    <xsl:for-each select="$ranks">
      <xsl:variable name="rank" as="xs:integer" select="."/>

      <xsl:if test="$rank lt 1">
        <xsl:sequence select="
          error
          (
            xs:QName('array-positive-rank'),
            'array rank must be a positive integer value.',
            .
          )"/>
      </xsl:if>

      <xsl:sequence select="'['"/>

      <xsl:sequence select="
        for $i in 1 to $rank - 1 return
          ','"/>

      <xsl:sequence select="']'"/>
    </xsl:for-each>

    <xsl:if test="exists($initializer)">
      <xsl:sequence select="
        t:get-object-or-collection-initializer(t:get-elements($initializer))"/>
    </xsl:if>
  </xsl:template>

  <!-- Mode "t:expression". delegate-creation-expression. -->
  <xsl:template mode="t:expression" match="new-delegate">
    <xsl:variable name="type" as="element()" select="type"/>
    <xsl:variable name="expression" as="element()"
      select="t:get-elements(.) except $type"/>

    <xsl:sequence select="'new'"/>
    <xsl:sequence select="' '"/>
    <xsl:sequence select="t:get-type($type)"/>
    <xsl:sequence select="'('"/>
    <xsl:sequence select="t:get-nested-expression($expression)"/>
    <xsl:sequence select="')'"/>
  </xsl:template>

  <!-- Mode "t:expression". typeof-expression. -->
  <xsl:template mode="t:expression" match="typeof">
    <xsl:variable name="type" as="element()" select="type"/>

    <xsl:sequence select="'typeof'"/>
    <xsl:sequence select="'('"/>
    <xsl:sequence select="t:get-type($type)"/>
    <xsl:sequence select="')'"/>
  </xsl:template>

  <!-- Mode "t:expression". checked-expression. -->
  <xsl:template mode="t:expression" match="checked">
    <xsl:variable name="expression" as="element()" select="t:get-elements(.)"/>

    <xsl:sequence select="'checked'"/>
    <xsl:sequence select="'('"/>
    <xsl:sequence select="t:get-nested-expression($expression)"/>
    <xsl:sequence select="')'"/>
  </xsl:template>

  <!-- Mode "t:expression". pointer-member-access. -->
  <xsl:template mode="t:expression" match="pointer-member-ref">
    <xsl:variable name="name" as="xs:string" select="@name"/>
    <xsl:variable name="expression" as="element()" select="t:get-elements(.)"/>

    <xsl:sequence select="t:get-nested-expression($expression)"/>
    <xsl:sequence select="'->'"/>
    <xsl:sequence select="$name"/>
  </xsl:template>

  <!-- Mode "t:expression". pointer-element-access. -->
  <xsl:template mode="t:expression" match="pointer-subscript">
    <xsl:variable name="expressions" as="element()+" select="t:get-elements(.)"/>
    <xsl:variable name="object" as="element()" select="$expressions[1]"/>
    <xsl:variable name="index" as="element()" select="$expressions[2]"/>

    <xsl:sequence select="t:get-nested-expression($object)"/>
    <xsl:sequence select="'['"/>
    <xsl:sequence select="t:get-nested-expression($index)"/>
    <xsl:sequence select="']'"/>
  </xsl:template>

  <!-- Mode "t:expression". sizeof-expression. -->
  <xsl:template mode="t:expression" match="sizeof">
    <xsl:variable name="type" as="element()" select="type"/>

    <xsl:sequence select="'sizeof'"/>
    <xsl:sequence select="'('"/>
    <xsl:sequence select="t:get-type($type)"/>
    <xsl:sequence select="')'"/>
  </xsl:template>

  <!-- Mode "t:expression". await-expression. -->
  <xsl:template mode="t:expression" match="await">
    <xsl:variable name="expression" as="element()" select="t:get-elements(.)"/>

    <xsl:sequence select="'await'"/>
    <xsl:sequence select="' '"/>
    <xsl:sequence select="t:get-nested-expression($expression)"/>
  </xsl:template>

  <!-- Mode "t:expression". default-value-expression. -->
  <xsl:template mode="t:expression" match="default">
    <xsl:variable name="type" as="element()" select="type"/>

    <xsl:sequence select="'default'"/>
    <xsl:sequence select="'('"/>
    <xsl:sequence select="t:get-type($type)"/>
    <xsl:sequence select="')'"/>
  </xsl:template>

  <!-- Mode "t:expression". plus, neg, not, inv, deref, addressof. -->
  <xsl:template mode="t:expression"
    match="plus | neg | not | inv | inc | dec | deref | addressof">
    <xsl:variable name="expression" as="element()" select="t:get-elements(.)"/>
    <xsl:variable name="name" as="xs:string"
      select="t:get-expression-info(local-name())/@operator"/>
    <xsl:variable name="this-precedence" as="xs:integer"
      select="t:get-expression-precedence(.)"/>
    <xsl:variable name="expression-precedence" as="xs:integer"
      select="t:get-expression-precedence($expression)"/>

    <xsl:sequence select="$name"/>

    <xsl:choose>
      <xsl:when test="
        ($this-precedence lt $expression-precedence) or
        exists
        (
          $expression
          [
            self::inc or
            self::dec or
            self::post-inc or
            self::post-dec
          ]
        )">
        <xsl:sequence select="'('"/>
        <xsl:sequence select="t:get-nested-expression($expression)"/>
        <xsl:sequence select="')'"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:sequence select="t:get-nested-expression($expression)"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!-- Mode "t:expression". cast-expression. -->
  <xsl:template mode="t:expression" match="cast">
    <xsl:variable name="type" as="element()" select="type"/>
    <xsl:variable name="expression" as="element()"
      select="t:get-elements(.) except $type"/>
    <xsl:variable name="cast-precedence" as="xs:integer"
      select="t:get-expression-precedence(.)"/>
    <xsl:variable name="expression-precedence" as="xs:integer"
      select="t:get-expression-precedence($expression)"/>

    <xsl:sequence select="'('"/>
    <xsl:sequence select="t:get-type($type)"/>
    <xsl:sequence select="')'"/>

    <xsl:choose>
      <xsl:when test="$cast-precedence le $expression-precedence">
        <xsl:sequence select="'('"/>
        <xsl:sequence select="t:get-nested-expression($expression)"/>
        <xsl:sequence select="')'"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:sequence select="t:get-nested-expression($expression)"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!-- Mode "t:expression". binary expressions. -->
  <xsl:template mode="t:expression" match="
    mul | div | mod | add | sub | lsh | rsh |
    lt | gt | le | ge | eq | ne |
    binary-and | binary-xor | binary-or |
    coalesce |
    assign | add-to | sub-from | mul-to | div-by | mod-by |
    binary-and-with | binary-or-with | binary-xor-with |
    lsh-to | rsh-to |
    and | or">
    <xsl:variable name="expressions" as="element()+"
      select="t:get-elements(.)"/>
    <xsl:variable name="left" as="element()" select="$expressions[1]"/>
    <xsl:variable name="right" as="element()" select="$expressions[2]"/>

    <xsl:variable name="operator-name" as="xs:string" select="local-name()"/>
    <xsl:variable name="operator-info" as="element()"
      select="t:get-expression-info($operator-name)"/>
    <xsl:variable name="associative" as="xs:boolean?"
      select="$operator-info/@associative"/>
    <xsl:variable name="right-to-left" as="xs:boolean?"
      select="$operator-info/@right-to-left"/>
    <xsl:variable name="name" as="xs:string" select="$operator-info/@operator"/>
    <xsl:variable name="this-precedence" as="xs:integer"
      select="t:get-expression-precedence(.)"/>
    <xsl:variable name="left-precedence" as="xs:integer"
      select="t:get-expression-precedence($left)"/>
    <xsl:variable name="right-precedence" as="xs:integer"
      select="t:get-expression-precedence($right)"/>

    <xsl:choose>
      <xsl:when test="
        ($this-precedence lt $left-precedence) or
        (($operator-name = local-name($left)) and $right-to-left)">
        <xsl:sequence select="'('"/>
        <xsl:sequence select="t:get-nested-expression($left)"/>
        <xsl:sequence select="')'"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:sequence select="t:get-nested-expression($left)"/>
      </xsl:otherwise>
    </xsl:choose>

    <xsl:sequence select="' '"/>
    <xsl:sequence select="$name"/>
    <xsl:sequence select="' '"/>

    <xsl:if test="self::or or self::and or self::coalesce">
      <xsl:sequence select="$t:soft-line-break"/>
    </xsl:if>

    <xsl:choose>
      <xsl:when test="
        not
        (
          ($operator-name = local-name($right)) and
          ($associative or $right-to-left)
        ) and
        ($this-precedence le $right-precedence)">
        <xsl:sequence select="'('"/>
        <xsl:sequence select="t:get-nested-expression($right)"/>
        <xsl:sequence select="')'"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:sequence select="t:get-nested-expression($right)"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!-- Mode "t:expression". is, as. -->
  <xsl:template mode="t:expression" match="is | as">
    <xsl:variable name="type" as="element()" select="type"/>
    <xsl:variable name="expression" as="element()"
      select="t:get-elements(.) except $type"/>
    <xsl:variable name="name" as="xs:string"
      select="t:get-expression-info(local-name())/@operator"/>
    <xsl:variable name="precedence" as="xs:integer"
      select="t:get-expression-precedence(.)"/>
    <xsl:variable name="expression-precedence" as="xs:integer"
      select="t:get-expression-precedence($expression)"/>

    <xsl:choose>
      <xsl:when test="$precedence lt $expression-precedence">
        <xsl:sequence select="'('"/>
        <xsl:sequence select="t:get-nested-expression($expression)"/>
        <xsl:sequence select="')'"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:sequence select="t:get-nested-expression($expression)"/>
      </xsl:otherwise>
    </xsl:choose>

    <xsl:sequence select="' '"/>
    <xsl:sequence select="$name"/>
    <xsl:sequence select="' '"/>
    <xsl:sequence select="t:get-type($type)"/>
  </xsl:template>

  <!-- Mode "t:expression". conditional-expression. -->
  <xsl:template mode="t:expression" match="condition">
    <xsl:variable name="expressions" as="element()+"
      select="t:get-elements(.)"/>
    <xsl:variable name="condition" as="element()" select="$expressions[1]"/>
    <xsl:variable name="true-value" as="element()" select="$expressions[2]"/>
    <xsl:variable name="false-value" as="element()" select="$expressions[3]"/>
    <xsl:variable name="this-precedence" as="xs:integer"
      select="t:get-expression-precedence(.)"/>
    <xsl:variable name="condition-precedence" as="xs:integer"
      select="t:get-expression-precedence($condition)"/>
    <xsl:variable name="true-value-precedence" as="xs:integer"
      select="t:get-expression-precedence($true-value)"/>
    <xsl:variable name="false-value-precedence" as="xs:integer"
      select="t:get-expression-precedence($true-value)"/>

    <xsl:choose>
      <xsl:when test="$this-precedence lt $condition-precedence">
        <xsl:sequence select="'('"/>
        <xsl:sequence select="t:get-nested-expression($condition)"/>
        <xsl:sequence select="')'"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:sequence select="t:get-nested-expression($condition)"/>
      </xsl:otherwise>
    </xsl:choose>

    <xsl:sequence select="' '"/>
    <xsl:sequence select="'?'"/>
    <xsl:sequence select="' '"/>

    <xsl:choose>
      <xsl:when test="$this-precedence le $true-value-precedence">
        <xsl:sequence select="'('"/>
        <xsl:sequence select="t:get-nested-expression($true-value)"/>
        <xsl:sequence select="')'"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:sequence select="t:get-nested-expression($true-value)"/>
      </xsl:otherwise>
    </xsl:choose>

    <xsl:sequence select="' '"/>
    <xsl:sequence select="':'"/>
    <xsl:sequence select="' '"/>
    <xsl:sequence select="$t:soft-line-break"/>

    <xsl:choose>
      <xsl:when test="$this-precedence le $false-value-precedence">
        <xsl:sequence select="'('"/>
        <xsl:sequence select="t:get-nested-expression($false-value)"/>
        <xsl:sequence select="')'"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:sequence select="t:get-nested-expression($false-value)"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!-- Mode "t:expression". lambda-expression. -->
  <xsl:template mode="t:expression" match="lambda">
    <xsl:variable name="async" as="xs:boolean?" select="@async"/>
    <xsl:variable name="parameters" as="element()?" select="parameters"/>
    <xsl:variable name="block" as="element()?" select="block"/>
    <xsl:variable name="expression" as="element()?" select="expression"/>

    <xsl:if test="empty($block) and empty($expression)">
      <xsl:sequence select="
        error
        (
          xs:QName('lambda-body-expected'),
          'Either block statement or expression is expected.',
          .
        )"/>
    </xsl:if>

    <xsl:if test="$async">
      <xsl:sequence select="'async'"/>
      <xsl:sequence select="' '"/>
    </xsl:if>

    <xsl:choose>
      <xsl:when test="exists($parameters)">
        <xsl:variable name="parameter" as="element()*"
          select="$parameters/parameter"/>

        <xsl:choose>
          <xsl:when test="empty($parameter)">
            <!-- Do nothing. -->
          </xsl:when>
          <xsl:when test="
            (count($parameter) = 1) and
            empty($parameter/type) and
            empty($parameter/@modifier)">
            <xsl:variable name="name" as="xs:string" select="$parameter/@name"/>

            <xsl:sequence select="$name"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:sequence select="'('"/>

            <xsl:for-each select="$parameter">
              <xsl:variable name="name" as="xs:string" select="@name"/>
              <xsl:variable name="modifier" as="xs:string?" select="@modifier"/>
              <xsl:variable name="type" as="element()?" select="type"/>

              <xsl:if test="$modifier">
                <xsl:sequence select="$modifier"/>
                <xsl:sequence select="' '"/>
              </xsl:if>

              <xsl:if test="exists($type)">
                <xsl:sequence select="t:get-type($type)"/>
                <xsl:sequence select="' '"/>
              </xsl:if>

              <xsl:sequence select="$name"/>

              <xsl:if test="position() != last()">
                <xsl:sequence select="','"/>
                <xsl:sequence select="' '"/>
              </xsl:if>
            </xsl:for-each>

            <xsl:sequence select="')'"/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:when>
      <xsl:otherwise>
        <xsl:sequence select="'('"/>
        <xsl:sequence select="')'"/>
      </xsl:otherwise>
    </xsl:choose>

    <xsl:sequence select="' '"/>
    <xsl:sequence select="'=>'"/>

    <xsl:choose>
      <xsl:when test="exists($expression)">
        <xsl:sequence select="' '"/>
        <xsl:sequence
          select="t:get-nested-expression(t:get-elements($expression))"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:sequence select="$t:new-line"/>
        <xsl:sequence select="'{'"/>
        <xsl:sequence select="$t:new-line"/>
        <xsl:sequence select="$t:indent"/>
        <xsl:sequence select="t:get-statements(t:get-elements($block))"/>
        <xsl:sequence select="$t:unindent"/>
        <xsl:sequence select="'}'"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!-- Mode "t:expression". anonymous-method-expression. -->
  <xsl:template mode="t:expression" match="anonymous-method">
    <xsl:variable name="async" as="xs:boolean?" select="@async"/>
    <xsl:variable name="parameters" as="element()?" select="parameters"/>
    <xsl:variable name="block" as="element()" select="block"/>

    <xsl:if test="$async">
      <xsl:sequence select="'async'"/>
      <xsl:sequence select="' '"/>
    </xsl:if>

    <xsl:sequence select="'delegate'"/>

    <xsl:if test="exists($parameters)">
      <xsl:sequence select="' '"/>
      <xsl:sequence select="'('"/>
      <xsl:sequence select="t:get-formal-parameter-list($parameters)"/>
      <xsl:sequence select="')'"/>
    </xsl:if>

    <xsl:sequence select="$t:new-line"/>
    <xsl:sequence select="'{'"/>
    <xsl:sequence select="$t:new-line"/>
    <xsl:sequence select="$t:indent"/>
    <xsl:sequence select="t:get-statements(t:get-elements($block))"/>
    <xsl:sequence select="$t:unindent"/>
    <xsl:sequence select="'}'"/>
  </xsl:template>

  <!-- Mode "t:expression". query-expression. -->
  <xsl:template mode="t:expression" match="query">
    <xsl:variable name="clauses" as="element()+"
      select="from | let | where | join | orderby | select | groupby"/>

    <xsl:for-each select="$clauses">
      <xsl:apply-templates mode="t:query-expression"  select="."/>

      <xsl:if test="position() != last()">
        <xsl:sequence select="$t:new-line"/>
      </xsl:if>
    </xsl:for-each>
  </xsl:template>

  <!-- Mode "t:query-expression". Default match. -->
  <xsl:template mode="t:query-expression" match="*">
    <xsl:sequence select="
      error
      (
        xs:QName('invalid-query-clause'),
        'Invalid query clause',
        .
      )"/>
  </xsl:template>

  <!-- Mode "t:query-expression". from clause. -->
  <xsl:template mode="t:query-expression" match="from">
    <xsl:variable name="name" as="xs:string" select="@name"/>
    <xsl:variable name="type" as="element()?" select="type"/>
    <xsl:variable name="expression" as="element()"
      select="t:get-elements(.) except $type"/>

    <xsl:sequence select="'from'"/>
    <xsl:sequence select="' '"/>

    <xsl:if test="exists($type)">
      <xsl:sequence select="t:get-type($type)"/>
      <xsl:sequence select="' '"/>
    </xsl:if>

    <xsl:sequence select="$name"/>
    <xsl:sequence select="' '"/>
    <xsl:sequence select="'in'"/>
    <xsl:sequence select="' '"/>
    <xsl:sequence select="t:get-nested-expression($expression)"/>
  </xsl:template>

  <!-- Mode "t:query-expression". let clause. -->
  <xsl:template mode="t:query-expression" match="let">
    <xsl:variable name="name" as="xs:string" select="@name"/>
    <xsl:variable name="expression" as="element()" select="t:get-elements(.)"/>

    <xsl:sequence select="'let'"/>
    <xsl:sequence select="' '"/>
    <xsl:sequence select="$name"/>
    <xsl:sequence select="' '"/>
    <xsl:sequence select="'='"/>
    <xsl:sequence select="' '"/>
    <xsl:sequence select="t:get-nested-expression($expression)"/>
  </xsl:template>

  <!-- Mode "t:query-expression". where clause. -->
  <xsl:template mode="t:query-expression" match="where">
    <xsl:variable name="expression" as="element()" select="t:get-elements(.)"/>

    <xsl:sequence select="'where'"/>
    <xsl:sequence select="' '"/>
    <xsl:sequence select="t:get-nested-expression($expression)"/>
  </xsl:template>

  <!-- Mode "t:query-expression". join clause. -->
  <xsl:template mode="t:query-expression" match="join">
    <xsl:variable name="into" as="element()?" select="into"/>
    <xsl:variable name="name" as="xs:string" select="@name"/>
    <xsl:variable name="type" as="element()?" select="type"/>
    <xsl:variable name="expressions" as="element()+"
      select="t:get-elements(.) except ($type, $into)"/>

    <xsl:sequence select="'join'"/>
    <xsl:sequence select="' '"/>

    <xsl:if test="exists($type)">
      <xsl:sequence select="t:get-type($type)"/>
      <xsl:sequence select="' '"/>
    </xsl:if>

    <xsl:sequence select="$name"/>
    <xsl:sequence select="' '"/>
    <xsl:sequence select="'in'"/>
    <xsl:sequence select="' '"/>
    <xsl:sequence select="t:get-nested-expression($expressions[1])"/>
    <xsl:sequence select="' '"/>
    <xsl:sequence select="'on'"/>
    <xsl:sequence select="$t:new-line"/>
    <xsl:sequence select="$t:indent"/>
    <xsl:sequence select="t:get-nested-expression($expressions[2])"/>
    <xsl:sequence select="' '"/>
    <xsl:sequence select="'equals'"/>
    <xsl:sequence select="' '"/>
    <xsl:sequence select="t:get-nested-expression($expressions[3])"/>

    <xsl:if test="exists($into)">
      <xsl:variable name="into-name" as="xs:string" select="$into/@name"/>

      <xsl:sequence select="' '"/>
      <xsl:sequence select="'into'"/>
      <xsl:sequence select="' '"/>
      <xsl:sequence select="$into-name"/>
    </xsl:if>

    <xsl:sequence select="$t:unindent"/>
  </xsl:template>

  <!-- Mode "t:query-expression". orderby clause. -->
  <xsl:template mode="t:query-expression" match="orderby">
    <xsl:variable name="orderings" as="element()+" select="t:get-elements(.)"/>

    <xsl:sequence select="'orderby'"/>
    <xsl:sequence select="' '"/>

    <xsl:for-each select="$orderings">
      <xsl:choose>
        <xsl:when test="self::ascending">
          <xsl:sequence select="t:get-nested-expression(t:get-elements(.))"/>
          <xsl:sequence select="' '"/>
          <xsl:sequence select="'ascending'"/>
        </xsl:when>
        <xsl:when test="self::descending">
          <xsl:sequence select="t:get-nested-expression(t:get-elements(.))"/>
          <xsl:sequence select="' '"/>
          <xsl:sequence select="'descending'"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:sequence select="t:get-nested-expression(.)"/>
        </xsl:otherwise>
      </xsl:choose>

      <xsl:if test="position() != last()">
        <xsl:sequence select="','"/>
        <xsl:sequence select="' '"/>
      </xsl:if>
    </xsl:for-each>
  </xsl:template>

  <!-- Mode "t:query-expression". select clause. -->
  <xsl:template mode="t:query-expression" match="select">
    <xsl:variable name="into" as="element()?" select="into"/>
    <xsl:variable name="expression" as="element()"
      select="t:get-elements(.) except $into"/>

    <xsl:sequence select="'select'"/>
    <xsl:sequence select="' '"/>
    <xsl:sequence select="t:get-nested-expression($expression)"/>

    <xsl:if test="exists($into)">
      <xsl:variable name="into-name" as="xs:string" select="$into/@name"/>

      <xsl:sequence select="' '"/>
      <xsl:sequence select="'into'"/>
      <xsl:sequence select="' '"/>
      <xsl:sequence select="$into-name"/>
    </xsl:if>
  </xsl:template>

  <!-- Mode "t:query-expression". groupby clause. -->
  <xsl:template mode="t:query-expression" match="groupby">
    <xsl:variable name="into" as="element()?" select="into"/>
    <xsl:variable name="expressions" as="element()+"
      select="t:get-elements(.) except $into"/>

    <xsl:sequence select="'group'"/>
    <xsl:sequence select="' '"/>
    <xsl:sequence select="t:get-nested-expression($expressions[1])"/>
    <xsl:sequence select="' '"/>
    <xsl:sequence select="'by'"/>
    <xsl:sequence select="' '"/>
    <xsl:sequence select="t:get-nested-expression($expressions[2])"/>

    <xsl:if test="exists($into)">
      <xsl:variable name="into-name" as="xs:string" select="$into/@name"/>

      <xsl:sequence select="' '"/>
      <xsl:sequence select="'into'"/>
      <xsl:sequence select="' '"/>
      <xsl:sequence select="$into-name"/>
    </xsl:if>
  </xsl:template>

  <!-- Mode "t:expression". snippet-expression. -->
  <xsl:template mode="t:expression" match="snippet-expression">
    <xsl:variable name="value" as="xs:string?" select="@value"/>

    <xsl:sequence select="$value"/>
  </xsl:template>

  <!-- Mode "t:expression". expression. -->
  <xsl:template mode="t:expression" match="expression">
    <xsl:sequence select="t:get-nested-expression(t:get-elements(.))"/>
  </xsl:template>

</xsl:stylesheet>