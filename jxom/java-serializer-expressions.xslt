<?xml version="1.0" encoding="utf-8"?>
<!--
  This stylesheet serializes java xml object model document down to
  the java text.
-->
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:t="http://www.bphx.com/jxom"
  xmlns:j="http://www.bphx.com/java-1.5/2008-02-07"
  xmlns="http://www.bphx.com/java-1.5/2008-02-07"
  xpath-default-namespace="http://www.bphx.com/java-1.5/2008-02-07"
  exclude-result-prefixes="xs t j">

  <!--
    Key to get operator precedence.
  -->
  <xsl:key name="t:operator" match="operator" use="xs:string(@name)"/>

  <!-- Operator precedence table. -->
  <xsl:variable name="t:operators">
    <operator name="postfix-inc" precedence="14"/>
    <operator name="postfix-dec" precedence="14"/>

    <operator name="inc" precedence="13"/>
    <operator name="dec" precedence="13"/>
    <operator name="plus" precedence="13"/>
    <operator name="neg" precedence="13"/>
    <operator name="not" precedence="13"/>
    <operator name="binary-not" precedence="13"/>
    <operator name="cast" precedence="13"/>

    <operator name="mul" precedence="12" associative="true"/>
    <operator name="div" precedence="12"/>
    <operator name="mod" precedence="12"/>

    <operator name="add" precedence="11" associative="true"/>
    <operator name="sub" precedence="11"/>

    <operator name="shl" precedence="10"/>
    <operator name="shr" precedence="10"/>
    <operator name="sshr" precedence="10"/>

    <operator name="lt" precedence="9"/>
    <operator name="le" precedence="9"/>
    <operator name="gt" precedence="9"/>
    <operator name="ge" precedence="9"/>
    <operator name="instance-of" precedence="9"/>

    <operator name="eq" precedence="8"/>
    <operator name="ne" precedence="8"/>

    <operator name="binary-and" precedence="7" associative="true"/>

    <operator name="binary-xor" precedence="6"/>

    <operator name="binary-or" precedence="5" associative="true"/>

    <operator name="and" precedence="4" associative="true"/>

    <operator name="or" precedence="3" associative="true"/>

    <operator name="condition" precedence="2"/>

    <operator name="assign" precedence="1" right-to-left="true"/>
    <operator name="add-to" precedence="1" right-to-left="true"/>
    <operator name="sub-from" precedence="1" right-to-left="true"/>
    <operator name="mul-to" precedence="1" right-to-left="true"/>
    <operator name="div-by" precedence="1" right-to-left="true"/>
    <operator name="and-with" precedence="1" right-to-left="true"/>
    <operator name="or-with" precedence="1" right-to-left="true"/>
    <operator name="xor-with" precedence="1" right-to-left="true"/>
    <operator name="mod-by" precedence="1" right-to-left="true"/>
    <operator name="shl-by" precedence="1" right-to-left="true"/>
    <operator name="shr-by" precedence="1" right-to-left="true"/>
    <operator name="sshr-by" precedence="1" right-to-left="true"/>

    <operator name="lambda" precedence="0"/>
  </xsl:variable>

  <!--
    Gets precedence of the operator.
      $operator - an operator to get precedence for.
      Return operator precedence.
  -->
  <xsl:function name="t:get-operator" as="element()?">
    <xsl:param name="operator" as="xs:string"/>

    <xsl:sequence select="key('t:operator', $operator, $t:operators)"/>
  </xsl:function>

  <!--
    Gets precedence of the operator.
      $operator - an operator to get precedence for.
      Return operator precedence.
  -->
  <xsl:function name="t:get-precedence" as="xs:integer">
    <xsl:param name="operator" as="xs:string"/>

    <xsl:variable name="operator" as="element()?"
      select="t:get-operator($operator)"/>
    <xsl:variable name="result" as="xs:integer?" 
      select="$operator/@precedence"/>

    <xsl:sequence select="
      if (empty($result)) then
        100
      else
        $result"/>
  </xsl:function>

  <!--
    Gets expression.
      $element - expression element.
      Returns expression tokens.
  -->
  <xsl:function name="t:get-expression" as="item()*">
    <xsl:param name="element" as="element()"/>

    <xsl:apply-templates mode="t:expression" select="$element"/>
  </xsl:function>

  <!--
    Gets expression list.
      $elements - expression element.
      Returns expression tokens.
  -->
  <xsl:function name="t:get-expression-list" as="item()*">
    <xsl:param name="elements" as="element()*"/>

    <xsl:variable name="tokens" as="item()*">
      <xsl:for-each select="$elements">
        <xsl:sequence select="t:get-expression(.)"/>

        <xsl:if test="position() != last()">
          <xsl:sequence select="','"/>
          <xsl:sequence select="$t:terminator"/>
        </xsl:if>
      </xsl:for-each>
    </xsl:variable>

    <xsl:sequence select="
      t:reformat-tokens($tokens, (), ' ', $t:new-line, false(), false())"/>
  </xsl:function>

  <!--
    Gets variable/field initializer.
      $element - an element to initialize.
      Returns initializer, if any, as sequence tokens.
  -->
  <xsl:function name="t:get-initializer" as="item()*">
    <xsl:param name="element" as="element()"/>
    <xsl:param name="required" as="xs:boolean"/>

    <xsl:variable name="initialize" as="element()?"
      select="$element/initialize"/>

    <xsl:if test="$required and empty($initialize)">
      <xsl:sequence select="
        error
        (
          xs:QName('initializer-required'),
          t:get-path($element)
        )"/>
    </xsl:if>

    <xsl:if test="$initialize">
      <xsl:variable name="array" as="element()?" select="$initialize/array"/>

      <xsl:choose>
        <xsl:when test="$array">
          <xsl:sequence select="t:get-array-initializer($array)"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:sequence
            select="t:get-expression(t:get-java-element($initialize))"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:if>
  </xsl:function>

  <!--
    Gets array initializer.
      $element - an array element.
      Returns array initializer as sequence of tokens.
  -->
  <xsl:function name="t:get-array-initializer" as="item()+">
    <xsl:param name="element" as="element()"/>

    <xsl:variable name="elements" as="element()*" 
      select="t:get-java-element($element)"/>

    <xsl:choose>
      <xsl:when test="empty($elements)">
        <xsl:sequence select="'{'"/>
        <xsl:sequence select="'}'"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:sequence select="$t:new-line"/>

        <xsl:sequence select="'{'"/>
        <xsl:sequence select="$t:new-line"/>

        <xsl:sequence select="$t:indent"/>

        <xsl:for-each select="$elements">
          <xsl:choose>
            <xsl:when test="self::array">
              <xsl:sequence select="t:get-array-initializer(.)"/>
            </xsl:when>
            <xsl:otherwise>
              <xsl:sequence select="t:get-expression(.)"/>
            </xsl:otherwise>
          </xsl:choose>

          <xsl:if test="position() != last()">
            <xsl:sequence select="','"/>
            <xsl:sequence select="$t:new-line"/>
          </xsl:if>
        </xsl:for-each>

        <xsl:sequence select="$t:new-line"/>

        <xsl:sequence select="$t:unindent"/>

        <xsl:sequence select="'}'"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:function>

  <!--
    Gets instance expression (one that should be serialized before '.' token).
    Wraps expression into parentheesis, if required.
      $expression - an instance expression.
      Return result expression.
  -->
  <xsl:function name="t:get-instance-expression" as="element()">
    <xsl:param name="expression" as="element()"/>

    <xsl:choose>
      <xsl:when test="t:get-precedence(local-name($expression)) lt 100">
        <parens>
          <xsl:sequence select="$expression"/>
        </parens>
      </xsl:when>
      <xsl:otherwise>
        <xsl:sequence select="$expression"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:function>

  <!--
    Gets binary expression.
      $element - binary expression.
      $operator - expression operator token.
      Returns expression token sequence.
  -->
  <xsl:function name="t:get-binary-expression" as="item()*">
    <xsl:param name="element" as="element()"/>
    <xsl:param name="operator" as="xs:string"/>

    <xsl:variable name="name" as="xs:string" select="local-name($element)"/>
    <xsl:variable name="operator-info" as="element()?"
      select="t:get-operator($name)"/>
    <xsl:variable name="associative" as="xs:boolean?"
      select="$operator-info/@associative"/>
    <xsl:variable name="right-to-left" as="xs:boolean?"
      select="$operator-info/@right-to-left"/>

    <xsl:variable name="precedence" as="xs:integer"
      select="t:get-precedence($name)"/>

    <xsl:variable name="expressions" as="element()+"
      select="t:get-java-element($element)"/>

    <xsl:variable name="expression1" as="element()">
      <xsl:variable name="expression" as="element()" select="$expressions[1]"/>
      <xsl:variable name="expression-name" as="xs:string"
        select="local-name($expression)"/>

      <xsl:choose>
        <xsl:when test="
          ($precedence gt t:get-precedence($expression-name)) or
          (($name = $expression-name) and $right-to-left)">
          <parens>
            <xsl:sequence select="$expression"/>
          </parens>
        </xsl:when>
        <xsl:otherwise>
          <xsl:sequence select="$expression"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>

    <xsl:variable name="expression2" as="element()">
      <xsl:variable name="expression" as="element()" select="$expressions[2]"/>
      <xsl:variable name="expression-name" as="xs:string"
        select="local-name($expression)"/>

      <xsl:choose>
        <xsl:when test="
          not
          (
            ($name = $expression-name) and 
            ($associative or $right-to-left)
          ) and
          ($precedence ge t:get-precedence($expression-name))">
          <parens>
            <xsl:sequence select="$expression"/>
          </parens>
        </xsl:when>
        <xsl:otherwise>
          <xsl:sequence select="$expression"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>

    <xsl:variable name="argument1" as="item()+"
      select="t:get-expression($expression1)"/>
    <xsl:variable name="argument2" as="item()+"
      select="t:get-expression($expression2)"/>

    <xsl:sequence select="$argument1"/>
    <xsl:sequence select="' '"/>
    <xsl:sequence select="$operator"/>

    <xsl:choose>
      <xsl:when test="$element[self::or or self::and]">
        <xsl:sequence select="' '"/>
        <xsl:sequence select="$t:soft-line-break"/>
        <xsl:sequence select="$argument2"/>
      </xsl:when>
      <xsl:when test="t:is-multiline($argument1)">
        <xsl:sequence select="$t:new-line"/>
        <xsl:sequence select="$t:indent"/>

        <xsl:sequence select="$argument2"/>

        <xsl:sequence select="$t:unindent"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:choose>
          <xsl:when test="exists($element[self::add and string])">
            <xsl:sequence select="$t:new-line"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:sequence select="' '"/>
          </xsl:otherwise>
        </xsl:choose>

        <xsl:sequence select="$argument2"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:function>

  <!--
    Gets unary  expression.
      $element - assignment expression.
      $operator - expression operator.
      $is-prefix - indicates whether operator is placed in the prefix or
        in the suffix of expression.
      Returns expression token sequence.
  -->
  <xsl:function name="t:get-unary-expression" as="item()*">
    <xsl:param name="element" as="element()"/>
    <xsl:param name="operator" as="xs:string"/>
    <xsl:param name="is-prefix" as="xs:boolean"/>

    <xsl:variable name="precedence" as="xs:integer"
      select="t:get-precedence(local-name($element))"/>

    <xsl:variable name="expressions" as="element()"
      select="t:get-java-element($element)"/>

    <xsl:variable name="expression" as="element()">
      <xsl:variable name="inner-expression" as="element()"
        select="$expressions[1]"/>

      <xsl:choose>
        <xsl:when test="
          $precedence gt t:get-precedence(local-name($inner-expression))">
          <parens>
            <xsl:sequence select="$inner-expression"/>
          </parens>
        </xsl:when>
        <xsl:otherwise>
          <xsl:sequence select="$inner-expression"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>

    <xsl:variable name="tokens" as="item()+"
      select="t:get-expression($expression)"/>

    <xsl:choose>
      <xsl:when test="$is-prefix">
        <xsl:sequence select="$operator"/>
        <xsl:sequence select="$tokens"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:sequence select="$tokens"/>
        <xsl:sequence select="$operator"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:function>

  <!--
    Gets an optional comma separated, enclosed in angle brackets type list.
      $element - an element to generate type list for.
      Returns optional comma separated, enclosed in angle brackets type list.
  -->
  <xsl:function name="t:get-generic-type-list" as="item()*">
    <xsl:param name="element" as="element()+"/>

    <xsl:variable name="types" as="element()?" select="$element/types"/>

    <xsl:if test="exists($types)">
      <xsl:variable name="type-list" as="element()+" select="$types/type"/>

      <xsl:sequence select="'&lt;'"/>

      <xsl:for-each select="$type-list">
        <xsl:sequence select="t:get-type(.)"/>

        <xsl:if test="position() != last()">
          <xsl:sequence select="','"/>
          <xsl:sequence select="' '"/>
        </xsl:if>
      </xsl:for-each>

      <xsl:sequence select="'>'"/>
    </xsl:if>
  </xsl:function>


  <!--
    Mode "t:expression". Empty match.
  -->
  <xsl:template mode="t:expression" match="@*|node()">
    <xsl:sequence select="
      error
      (
        xs:QName('invalid-expression'),
        t:get-path(.)
      )"/>
  </xsl:template>

  <!--
    Mode "t:expression". lambda.
  -->
  <xsl:template mode="t:expression" match="lambda">
    <xsl:variable name="parameters" as="element()*"
      select="parameters/parameter"/>
    <xsl:variable name="inferred" as="xs:boolean"
      select="exists($parameters[not(type)])"/>
    <xsl:variable name="block" as="element()" select="block"/>

    <xsl:variable name="expression" as="element()?" select="
      $block[xs:boolean(@expression) and (count(*) = 1)]/
        return/t:get-java-element(.)"/>

    <xsl:if test="$parameters[type] and $inferred">
      <xsl:sequence select="
        error(xs:QName('lambda-inconsistent-parameters'), t:get-path(.))"/>
    </xsl:if>

    <xsl:choose>
      <xsl:when test="not($inferred)">
        <xsl:sequence select="'('"/>
        <xsl:sequence select="t:get-method-parameters(.)"/>
        <xsl:sequence select="')'"/>
      </xsl:when>
      <xsl:when test="count($parameters) = 1">
        <xsl:variable name="name" as="xs:string" select="$parameters/@name"/>

        <xsl:sequence select="$name"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:variable name="tokens" as="item()*">
          <xsl:for-each select="$parameters">
            <xsl:variable name="name" as="xs:string" select="@name"/>

            <xsl:sequence select="$name"/>

            <xsl:if test="position() != last()">
              <xsl:sequence select="','"/>
              <xsl:sequence select="$t:terminator"/>
            </xsl:if>
          </xsl:for-each>
        </xsl:variable>

        <xsl:sequence select="'('"/>
        <xsl:sequence select="
          t:reformat-tokens($tokens, 5, ' ', $t:new-line, false(), false())"/>
        <xsl:sequence select="')'"/>
      </xsl:otherwise>
    </xsl:choose>

    <xsl:sequence select="' '"/>
    <xsl:sequence select="'->'"/>
    <xsl:sequence select="' '"/>
    
    <xsl:choose>
      <xsl:when test="$expression">
        <xsl:sequence select="t:get-expression($expression)"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:sequence select="$t:new-line"/>
        <xsl:sequence select="'{'"/>
        <xsl:sequence select="$t:new-line"/>
        <xsl:sequence select="$t:indent"/>
        <xsl:sequence select="t:get-comments($block)"/>
        <xsl:sequence select="t:get-statement-scope($block)"/>
        <xsl:sequence select="$t:unindent"/>
        <xsl:sequence select="'}'"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!--
    Mode "t:expression". assign.
  -->
  <xsl:template mode="t:expression" match="assign">
    <xsl:sequence select="t:get-binary-expression(., '=')"/>
  </xsl:template>

  <!--
    Mode "t:expression". add-to.
  -->
  <xsl:template mode="t:expression" match="add-to">
    <xsl:sequence select="t:get-binary-expression(., '+=')"/>
  </xsl:template>

  <!--
    Mode "t:expression". sub-from.
  -->
  <xsl:template mode="t:expression" match="sub-from">
    <xsl:sequence select="t:get-binary-expression(., '-=')"/>
  </xsl:template>

  <!--
    Mode "t:expression". mul-to.
  -->
  <xsl:template mode="t:expression" match="mul-to">
    <xsl:sequence select="t:get-binary-expression(., '*=')"/>
  </xsl:template>

  <!--
    Mode "t:expression". div-by.
  -->
  <xsl:template mode="t:expression" match="div-by">
    <xsl:sequence select="t:get-binary-expression(., '/=')"/>
  </xsl:template>

  <!--
    Mode "t:expression". and-with.
  -->
  <xsl:template mode="t:expression" match="and-with">
    <xsl:sequence select="t:get-binary-expression(., '&amp;=')"/>
  </xsl:template>

  <!--
    Mode "t:expression". or-with.
  -->
  <xsl:template mode="t:expression" match="or-with">
    <xsl:sequence select="t:get-binary-expression(., '|=')"/>
  </xsl:template>

  <!--
    Mode "t:expression". xor-with.
  -->
  <xsl:template mode="t:expression" match="xor-with">
    <xsl:sequence select="t:get-binary-expression(., '^=')"/>
  </xsl:template>

  <!--
    Mode "t:expression". mod-by.
  -->
  <xsl:template mode="t:expression" match="mod-by">
    <xsl:sequence select="t:get-binary-expression(., '%=')"/>
  </xsl:template>

  <!--
    Mode "t:expression". shl-by.
  -->
  <xsl:template mode="t:expression" match="shl-by">
    <xsl:sequence select="t:get-binary-expression(., '&lt;&lt;=')"/>
  </xsl:template>

  <!--
    Mode "t:expression". shr-by.
  -->
  <xsl:template mode="t:expression" match="shr-by">
    <xsl:sequence select="t:get-binary-expression(., '>>=')"/>
  </xsl:template>

  <!--
    Mode "t:expression". sshr-by.
  -->
  <xsl:template mode="t:expression" match="sshr-by">
    <xsl:sequence select="t:get-binary-expression(., '>>>=')"/>
  </xsl:template>

  <!--
    Mode "t:expression". condition.
  -->
  <xsl:template mode="t:expression" match="condition">
    <xsl:variable name="expressions" as="element()+"
      select="t:get-java-element(.)"/>
    <xsl:variable name="condition" as="item()+"
      select="t:get-expression($expressions[1])"/>

    <xsl:variable name="precedence" as="xs:integer"
      select="t:get-precedence(local-name())"/>

    <xsl:variable name="then-expression" as="element()">
      <xsl:variable name="expression" as="element()" select="$expressions[2]"/>

      <xsl:choose>
        <xsl:when
          test="$precedence gt t:get-precedence(local-name($expression))">
          <parens>
            <xsl:sequence select="$expression"/>
          </parens>
        </xsl:when>
        <xsl:otherwise>
          <xsl:sequence select="$expression"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>

    <xsl:variable name="else-expression" as="element()">
      <xsl:variable name="expression" as="element()" select="$expressions[3]"/>

      <xsl:choose>
        <xsl:when
          test="$precedence gt t:get-precedence(local-name($expression))">
          <parens>
            <xsl:sequence select="$expression"/>
          </parens>
        </xsl:when>
        <xsl:otherwise>
          <xsl:sequence select="$expression"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>

    <xsl:sequence select="$condition"/>
    <xsl:sequence select="' '"/>
    <xsl:sequence select="'?'"/>
    <xsl:sequence select="' '"/>
    <xsl:sequence select="t:get-expression($then-expression)"/>
    <xsl:sequence select="' '"/>
    <xsl:sequence select="':'"/>
    <xsl:sequence select="' '"/>
    <xsl:sequence select="$t:soft-line-break"/>
    <xsl:sequence select="t:get-expression($else-expression)"/>
  </xsl:template>

  <!--
    Mode "t:expression". or.
  -->
  <xsl:template mode="t:expression" match="or">
    <xsl:sequence select="t:get-binary-expression(., '||')"/>
  </xsl:template>

  <!--
    Mode "t:expression". and.
  -->
  <xsl:template mode="t:expression" match="and">
    <xsl:sequence select="t:get-binary-expression(., '&amp;&amp;')"/>
  </xsl:template>

  <!--
    Mode "t:expression". binary-or.
  -->
  <xsl:template mode="t:expression" match="binary-or">
    <xsl:sequence select="t:get-binary-expression(., '|')"/>
  </xsl:template>

  <!--
    Mode "t:expression". binary-xor.
  -->
  <xsl:template mode="t:expression" match="binary-xor">
    <xsl:sequence select="t:get-binary-expression(., '^')"/>
  </xsl:template>

  <!--
    Mode "t:expression". binary-and.
  -->
  <xsl:template mode="t:expression" match="binary-and">
    <xsl:sequence select="t:get-binary-expression(., '&amp;')"/>
  </xsl:template>

  <!--
    Mode "t:expression". eq.
  -->
  <xsl:template mode="t:expression" match="eq">
    <xsl:sequence select="t:get-binary-expression(., '==')"/>
  </xsl:template>

  <!--
    Mode "t:expression". ne.
  -->
  <xsl:template mode="t:expression" match="ne">
    <xsl:sequence select="t:get-binary-expression(., '!=')"/>
  </xsl:template>

  <!--
    Mode "t:expression". instance-of.
  -->
  <xsl:template mode="t:expression" match="instance-of">
    <xsl:variable name="value" as="element()" select="value"/>
    <xsl:variable name="type" as="element()" select="type"/>

    <xsl:variable name="tokens" as="item()+"
      select="t:get-expression(t:get-java-element($value))"/>

    <xsl:sequence select="$tokens"/>
    <xsl:sequence select="' '"/>
    <xsl:sequence select="'instanceof'"/>
    <xsl:sequence select="' '"/>
    <xsl:sequence select="t:get-type($type)"/>
  </xsl:template>

  <!--
    Mode "t:expression". le.
  -->
  <xsl:template mode="t:expression" match="le">
    <xsl:sequence select="t:get-binary-expression(., '&lt;=')"/>
  </xsl:template>

  <!--
    Mode "t:expression". ge.
  -->
  <xsl:template mode="t:expression" match="ge">
    <xsl:sequence select="t:get-binary-expression(., '>=')"/>
  </xsl:template>

  <!--
    Mode "t:expression". lt.
  -->
  <xsl:template mode="t:expression" match="lt">
    <xsl:sequence select="t:get-binary-expression(., '&lt;')"/>
  </xsl:template>

  <!--
    Mode "t:expression". gt.
  -->
  <xsl:template mode="t:expression" match="gt">
    <xsl:sequence select="t:get-binary-expression(., '&gt;')"/>
  </xsl:template>

  <!--
    Mode "t:expression". shl.
  -->
  <xsl:template mode="t:expression" match="shl">
    <xsl:sequence select="t:get-binary-expression(., '&lt;&lt;')"/>
  </xsl:template>

  <!--
    Mode "t:expression". sshr.
  -->
  <xsl:template mode="t:expression" match="sshr">
    <xsl:sequence select="t:get-binary-expression(., '>>>')"/>
  </xsl:template>

  <!--
    Mode "t:expression". shr.
  -->
  <xsl:template mode="t:expression" match="shr">
    <xsl:sequence select="t:get-binary-expression(., '>>')"/>
  </xsl:template>

  <!--
    Mode "t:expression". add.
  -->
  <xsl:template mode="t:expression" match="add">
    <xsl:sequence select="t:get-binary-expression(., '+')"/>
  </xsl:template>

  <!--
    Mode "t:expression". sub.
  -->
  <xsl:template mode="t:expression" match="sub">
    <xsl:sequence select="t:get-binary-expression(., '-')"/>
  </xsl:template>

  <!--
    Mode "t:expression". mul.
  -->
  <xsl:template mode="t:expression" match="mul">
    <xsl:sequence select="t:get-binary-expression(., '*')"/>
  </xsl:template>

  <!--
    Mode "t:expression". div.
  -->
  <xsl:template mode="t:expression" match="div">
    <xsl:sequence select="t:get-binary-expression(., '/')"/>
  </xsl:template>

  <!--
    Mode "t:expression". mod.
  -->
  <xsl:template mode="t:expression" match="mod">
    <xsl:sequence select="t:get-binary-expression(., '%')"/>
  </xsl:template>

  <!--
    Mode "t:expression". plus.
  -->
  <xsl:template mode="t:expression" match="plus">
    <xsl:sequence select="t:get-unary-expression(., '+', true())"/>
  </xsl:template>

  <!--
    Mode "t:expression". neg.
  -->
  <xsl:template mode="t:expression" match="neg">
    <xsl:sequence select="t:get-unary-expression(., '-', true())"/>
  </xsl:template>

  <!--
    Mode "t:expression". inc.
  -->
  <xsl:template mode="t:expression" match="inc">
    <xsl:sequence select="t:get-unary-expression(., '++', true())"/>
  </xsl:template>

  <!--
    Mode "t:expression". dec.
  -->
  <xsl:template mode="t:expression" match="dec">
    <xsl:sequence select="t:get-unary-expression(., '--', true())"/>
  </xsl:template>

  <!--
    Mode "t:expression". postfix-inc.
  -->
  <xsl:template mode="t:expression" match="postfix-inc">
    <xsl:sequence select="t:get-unary-expression(., '++', false())"/>
  </xsl:template>

  <!--
    Mode "t:expression". postfix-dec.
  -->
  <xsl:template mode="t:expression" match="postfix-dec">
    <xsl:sequence select="t:get-unary-expression(., '--', false())"/>
  </xsl:template>

  <!--
    Mode "t:expression". not.
  -->
  <xsl:template mode="t:expression" match="not">
    <xsl:sequence select="t:get-unary-expression(., '!', true())"/>
  </xsl:template>

  <!--
    Mode "t:expression". binary-not.
  -->
  <xsl:template mode="t:expression" match="binary-not">
    <xsl:sequence select="t:get-unary-expression(., '~', true())"/>
  </xsl:template>

  <!--
    Mode "t:expression". cast.
  -->
  <xsl:template mode="t:expression" match="cast">
    <xsl:variable name="types" as="element()+" select="type"/>
    <xsl:variable name="value" as="element()" select="value"/>

    <xsl:variable name="precedence" as="xs:integer"
      select="t:get-precedence('cast')"/>

    <xsl:variable name="expression" as="element()">
      <xsl:variable name="inner-expression" as="element()"
        select="t:get-java-element($value)"/>

      <xsl:choose>
        <xsl:when test="
          $precedence gt t:get-precedence(local-name($inner-expression))">
          <parens>
            <xsl:sequence select="$inner-expression"/>
          </parens>
        </xsl:when>
        <xsl:otherwise>
          <xsl:sequence select="$inner-expression"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>

    <xsl:variable name="tokens" as="item()+"
      select="t:get-expression($expression)"/>

    <xsl:sequence select="'('"/>
    
    <xsl:for-each select="$types">
      <xsl:if test="position() gt 1">
        <xsl:sequence select="' '"/>
        <xsl:sequence select="'&amp;'"/>
        <xsl:sequence select="' '"/>
      </xsl:if>
    
      <xsl:sequence select="t:get-type(.)"/>
    </xsl:for-each>
    
    <xsl:sequence select="')'"/>
    <xsl:sequence select="$tokens"/>
  </xsl:template>

  <!--
    Mode "t:expression". this.
  -->
  <xsl:template mode="t:expression" match="this">
    <xsl:variable name="type" as="element()?" select="type"/>
      
    <xsl:if test="$type">
      <xsl:sequence select="t:get-type(.)"/>
      <xsl:sequence select="'.'"/>
    </xsl:if>

    <xsl:sequence select="'this'"/>
  </xsl:template>

  <!--
    Mode "t:expression". super.
  -->
  <xsl:template mode="t:expression" match="super">
    <xsl:sequence select="'super'"/>
  </xsl:template>

  <!--
    Mode "t:expression". scope-expression.
  -->
  <xsl:template mode="t:expression" match="scope-expression">
    <xsl:apply-templates mode="t:expression" select="t:get-java-element(.)"/>
  </xsl:template>

  <!--
    Mode "t:expression". parens.
  -->
  <xsl:template mode="t:expression" match="parens">
    <xsl:variable name="tokens" as="item()+"
      select="t:get-expression(t:get-java-element(.))"/>

    <xsl:sequence select="'('"/>
    <xsl:sequence select="$tokens"/>
    <xsl:sequence select="')'"/>
  </xsl:template>

  <!--
    Mode "t:expression". subscript.
  -->
  <xsl:template mode="t:expression" match="subscript">
    <xsl:variable name="expressions" as="element()+"
      select="t:get-java-element(.)"/>
    <xsl:variable name="index-tokens" as="item()+"
      select="t:get-expression($expressions[2])"/>

    <xsl:variable name="tokens" as="item()+">
      <xsl:sequence select="t:get-expression($expressions[1])"/>
      <xsl:sequence select="'['"/>
      <xsl:sequence select="t:indent-from-second-line($index-tokens)"/>
      <xsl:sequence select="']'"/>
    </xsl:variable>

    <xsl:sequence select="t:indent-from-second-line($tokens)"/>
  </xsl:template>

  <!--
    Mode "t:expression". snippet-expression.
  -->
  <xsl:template mode="t:expression" match="snippet-expression">
    <xsl:variable name="value" as="xs:string" select="@value"/>

    <xsl:sequence select="t:tokenize($value)"/>
  </xsl:template>

  <!--
    Mode "t:expression". var.
  -->
  <xsl:template mode="t:expression" match="var">
    <xsl:variable name="name" as="xs:string" select="@name"/>

    <xsl:sequence select="$name"/>
  </xsl:template>

  <!--
    Mode "t:expression". field.
  -->
  <xsl:template mode="t:expression" match="field">
    <xsl:variable name="name" as="xs:string" select="@name"/>

    <xsl:variable name="tokens" as="item()*" select="
      t:get-java-element(.)/t:get-instance-expression(.)/t:get-expression(.)"/>

    <xsl:if test="$tokens">
      <xsl:sequence select="$tokens"/>
      <xsl:sequence select="'.'"/>
    </xsl:if>

    <xsl:sequence select="$name"/>
  </xsl:template>

  <!--
    Mode "t:expression". static-field.
  -->
  <xsl:template mode="t:expression" match="static-field">
    <xsl:variable name="name" as="xs:string" select="@name"/>

    <xsl:variable name="type" as="element()?" select="type"/>
    <xsl:variable name="value" as="element()?" select="value"/>

    <xsl:choose>
      <xsl:when test="exists($type) and exists($value)">
        <xsl:sequence select="error(xs:QName('invalid-static-field'))"/>
      </xsl:when>
      <xsl:when test="exists($type)">
        <xsl:sequence select="t:get-type($type)"/>
        <xsl:sequence select="'.'"/>
      </xsl:when>
      <xsl:when test="exists($value)">
        <xsl:variable name="tokens" as="item()+" select="
          t:get-expression
          (
            t:get-instance-expression(t:get-java-element($value))
          )"/>

        <xsl:if test="$tokens">
          <xsl:sequence select="$tokens"/>
          <xsl:sequence select="'.'"/>
        </xsl:if>
      </xsl:when>
    </xsl:choose>

    <xsl:sequence select="$name"/>
  </xsl:template>

  <!--
    Mode "t:expression". class-of.
  -->
  <xsl:template mode="t:expression" match="class-of">
    <xsl:sequence select="t:get-type(type)"/>
    <xsl:sequence select="'.'"/>
    <xsl:sequence select="'class'"/>
  </xsl:template>

  <!--
    Mode "t:expression". int, short, byte, double.
  -->
  <xsl:template mode="t:expression" match="int | short | byte">
    <xsl:variable name="value" as="xs:string" select="@value"/>

    <xsl:sequence select="t:trim($value)"/>
  </xsl:template>

  <!--
    Mode "t:expression". long.
  -->
  <xsl:template mode="t:expression" match="long">
    <xsl:variable name="value" as="xs:string" select="@value"/>
    <xsl:variable name="escaped" as="xs:boolean?" select="@escaped"/>

    <xsl:sequence select="
      if ($escaped) then
        $value
      else
        concat(t:trim($value), 'L')"/>
  </xsl:template>

  <!--
    Mode "t:expression". int, short, byte, double.
  -->
  <xsl:template mode="t:expression" match="double">
    <xsl:variable name="value" as="xs:string" select="@value"/>
    <xsl:variable name="escaped" as="xs:boolean?" select="@escaped"/>

    <xsl:choose>
      <xsl:when test="$escaped">
        <xsl:sequence select="$value"/>
      </xsl:when>
      <xsl:when test="
        contains($value, '.') or
        contains($value, 'e') or
        contains($value, 'E')">
        <xsl:sequence select="$value"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:sequence select="concat($value, '.0')"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!--
    Mode "t:expression". float.
  -->
  <xsl:template mode="t:expression" match="float">
    <xsl:variable name="value" as="xs:string" select="@value"/>
    <xsl:variable name="escaped" as="xs:boolean?" select="@escaped"/>

    <xsl:sequence select="
      if ($escaped) then
        $value
      else
        concat(t:trim($value), 'F')"/>
  </xsl:template>

  <!--
    Mode "t:expression". string.
  -->
  <xsl:template mode="t:expression" match="string">
    <xsl:variable name="value" as="xs:string" select="@value"/>
    <xsl:variable name="escaped" as="xs:boolean?" select="@escaped"/>

    <xsl:variable name="escaped-value" as="xs:string" select="
      if ($escaped) then
        $value
      else
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
        )"/>

    <xsl:choose>
      <xsl:when test="
        empty($t:long-string-width-threshold) or
        (string-length($escaped-value) > $t:long-string-width-threshold)">

        <xsl:variable name="parts" as="xs:string+">
          <xsl:analyze-string regex="(\\n|\\r)+"
            select="$escaped-value">
            <xsl:matching-substring>
              <xsl:sequence select="."/>
            </xsl:matching-substring>
            <xsl:non-matching-substring>
              <xsl:sequence select="."/>
            </xsl:non-matching-substring>
          </xsl:analyze-string>
        </xsl:variable>

        <xsl:for-each select="$parts">
          <xsl:variable name="index" as="xs:integer" select="position()"/>

          <xsl:if test="$index mod 2 = 1">
            <xsl:sequence
              select="concat('&quot;', ., $parts[$index + 1], '&quot;')"/>

            <xsl:if test="$index + 1 lt last()">
              <xsl:sequence select="' '"/>
              <xsl:sequence select="'+'"/>
              <xsl:sequence select="$t:new-line"/>
            </xsl:if>
          </xsl:if>
        </xsl:for-each>
      </xsl:when>
      <xsl:otherwise>
        <xsl:sequence select="concat('&quot;', $escaped-value, '&quot;')"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!--
    Mode "t:expression". char.
  -->
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

  <!--
    Mode "t:expression". boolean.
  -->
  <xsl:template mode="t:expression" match="boolean">
    <xsl:variable name="value" as="xs:boolean" select="@value"/>

    <xsl:sequence select="
      if ($value) then 
        'true' 
      else 
        'false'"/>
  </xsl:template>

  <!--
    Mode "t:expression". null.
  -->
  <xsl:template mode="t:expression" match="null">
    <xsl:sequence select="'null'"/>
  </xsl:template>

  <!--
    Mode "t:expression". invoke.
  -->
  <xsl:template mode="t:expression" match="invoke">
    <xsl:variable name="invoke-tokens" as="item()*">
      <xsl:variable name="name" as="xs:string" select="@name"/>
      <xsl:variable name="arguments" as="element()?" select="arguments"/>

      <xsl:sequence select="$name"/>
      <xsl:sequence select="'('"/>

      <xsl:if test="exists($arguments)">
        <xsl:sequence
          select="t:get-expression-list(t:get-java-element($arguments))"/>
      </xsl:if>

      <xsl:sequence select="')'"/>
    </xsl:variable>

    <xsl:variable name="tokens" as="item()*">
      <xsl:variable name="instance" as="element()?" select="instance"/>

      <xsl:if test="$instance">
        <xsl:sequence select="
          t:get-expression
          (
            t:get-instance-expression(t:get-java-element($instance))
          )"/>

        <xsl:sequence select="'.'"/>
      </xsl:if>

      <xsl:sequence select="t:get-generic-type-list(.)"/>

      <xsl:sequence select="$invoke-tokens"/>
    </xsl:variable>

    <xsl:sequence select="t:indent-from-second-line($tokens)"/>
  </xsl:template>

  <!--
    Mode "t:expression". static-invoke.
  -->
  <xsl:template mode="t:expression" match="static-invoke">
    <xsl:variable name="invoke-tokens" as="item()*">
      <xsl:variable name="name" as="xs:string" select="@name"/>
      <xsl:variable name="arguments" as="element()?" select="arguments"/>

      <xsl:sequence select="$name"/>
      <xsl:sequence select="'('"/>

      <xsl:if test="exists($arguments)">
        <xsl:sequence
          select="t:get-expression-list(t:get-java-element($arguments))"/>
      </xsl:if>

      <xsl:sequence select="')'"/>
    </xsl:variable>

    <xsl:variable name="tokens" as="item()*">
      <xsl:variable name="type" as="element()?" select="type"/>
      <xsl:variable name="instance" as="element()?" select="value"/>

      <xsl:choose>
        <xsl:when test="exists($type) and exists($instance)">
          <xsl:sequence select="error(xs:QName('invalid-static-invoke'))"/>
        </xsl:when>
        <xsl:when test="exists($type)">
          <xsl:sequence select="t:get-type($type)"/>
          <xsl:sequence select="'.'"/>
        </xsl:when>
        <xsl:when test="exists($instance)">
          <xsl:variable name="tokens" as="item()+"
            select="t:get-expression(t:get-java-element($instance))"/>

          <xsl:if test="$tokens">
            <xsl:sequence select="$tokens"/>
            <xsl:sequence select="'.'"/>
          </xsl:if>
        </xsl:when>
      </xsl:choose>

      <xsl:sequence select="t:get-generic-type-list(.)"/>

      <xsl:sequence select="$invoke-tokens"/>
    </xsl:variable>

    <xsl:sequence select="t:indent-from-second-line($tokens)"/>
  </xsl:template>

  <!--
    Mode "t:expression". method-ref.
  -->
  <xsl:template mode="t:expression" match="method-ref">
    <xsl:variable name="name" as="xs:string" select="@name"/>
    <xsl:variable name="instance" as="element()?" select="instance"/>

    <xsl:if test="$instance">
      <xsl:sequence select="
        t:get-expression
        (
          t:get-instance-expression(t:get-java-element($instance))
        )"/>

      <xsl:sequence select="'::'"/>
    </xsl:if>

    <xsl:sequence select="t:get-generic-type-list(.)"/>
    <xsl:sequence select="$name"/>
  </xsl:template>

  <!--
    Mode "t:expression". static-method-ref.
  -->
  <xsl:template mode="t:expression" match="static-method-ref">
    <xsl:variable name="name" as="xs:string" select="@name"/>
    <xsl:variable name="type" as="element()?" select="type"/>
    <xsl:variable name="instance" as="element()?" select="value"/>

    <xsl:choose>
      <xsl:when test="exists($type) and exists($instance)">
        <xsl:sequence select="error(xs:QName('invalid-static-invoke'))"/>
      </xsl:when>
      <xsl:when test="exists($type)">
        <xsl:sequence select="t:get-type($type)"/>
        <xsl:sequence select="'::'"/>
      </xsl:when>
      <xsl:when test="exists($instance)">
        <xsl:variable name="tokens" as="item()+"
          select="t:get-expression(t:get-java-element($instance))"/>

        <xsl:if test="$tokens">
          <xsl:sequence select="$tokens"/>
          <xsl:sequence select="'::'"/>
        </xsl:if>
      </xsl:when>
    </xsl:choose>

    <xsl:sequence select="t:get-generic-type-list(.)"/>
    <xsl:sequence select="$name"/>
  </xsl:template>

  <!--
    Mode "t:expression". constructor-ref.
  -->
  <xsl:template mode="t:expression" match="constructor-ref">
    <xsl:variable name="type" as="element()?" select="type"/>
    <xsl:variable name="instance" as="element()?" select="value"/>

    <xsl:choose>
      <xsl:when test="exists($type) and exists($instance)">
        <xsl:sequence select="error(xs:QName('invalid-static-invoke'))"/>
      </xsl:when>
      <xsl:when test="exists($type)">
        <xsl:sequence select="t:get-type($type)"/>
        <xsl:sequence select="'::'"/>
      </xsl:when>
      <xsl:when test="exists($instance)">
        <xsl:variable name="tokens" as="item()+"
          select="t:get-expression(t:get-java-element($instance))"/>

        <xsl:if test="$tokens">
          <xsl:sequence select="$tokens"/>
          <xsl:sequence select="'::'"/>
        </xsl:if>
      </xsl:when>
    </xsl:choose>

    <xsl:sequence select="t:get-generic-type-list(.)"/>
    <xsl:sequence select="'new'"/>
  </xsl:template>

  <!--
    Mode "t:expression". construct.
  -->
  <xsl:template mode="t:expression" match="construct">
    <xsl:variable name="super" as="element()?" select="super"/>
    <xsl:variable name="expression" as="element()?" 
      select="t:get-java-element($super)"/>
    <xsl:variable name="arguments" as="element()?" select="arguments"/>

    <xsl:variable name="tokens" as="item()*">
      <xsl:if test="$super">
        <xsl:choose>
          <xsl:when test="$expression[self::type]">
            <xsl:sequence select="t:get-type($expression)"/>
            <xsl:sequence select="'.'"/>
          </xsl:when>
          <xsl:when test="$expression">
            <xsl:sequence select="t:get-expression($expression)"/>
            <xsl:sequence select="'.'"/>
          </xsl:when>
        </xsl:choose>
      </xsl:if>
      
      <xsl:sequence select="t:get-generic-type-list(.)"/>

      <xsl:choose>
        <xsl:when test="$super">
          <xsl:sequence select="'super'"/>
        </xsl:when>
        <xsl:when test="this">
          <xsl:sequence select="'this'"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:sequence
            select="error(xs:QName('invalid-construct'), t:get-path(.))"/>
        </xsl:otherwise>
      </xsl:choose>

      <xsl:sequence select="'('"/>

      <xsl:if test="exists($arguments)">
        <xsl:sequence
          select="t:get-expression-list(t:get-java-element($arguments))"/>
      </xsl:if>

      <xsl:sequence select="')'"/>
    </xsl:variable>

    <xsl:sequence select="t:indent-from-second-line($tokens)"/>
  </xsl:template>

  <!--
    Mode "t:expression". new-object.
  -->
  <xsl:template mode="t:expression" match="new-object">
    <xsl:variable name="type" as="element()" select="type"/>
    <xsl:variable name="instance" as="element()?" select="instance"/>
    <xsl:variable name="declaration" as="element()?" select="declaration"/>

    <xsl:variable name="new-tokens" as="item()*">
      <xsl:variable name="arguments" as="element()?" select="arguments"/>

      <xsl:sequence select="'new'"/>
      <xsl:sequence select="' '"/>
      <xsl:sequence select="t:get-type(type)"/>

      <xsl:sequence select="t:get-generic-type-list(.)"/>

      <xsl:sequence select="'('"/>

      <xsl:if test="exists($arguments)">
        <xsl:sequence
          select="t:get-expression-list(t:get-java-element($arguments))"/>
      </xsl:if>

      <xsl:sequence select="')'"/>
    </xsl:variable>

    <xsl:variable name="tokens" as="item()*">
      <xsl:if test="$instance">
        <xsl:sequence
          select="t:get-expression(t:get-java-element($instance))"/>
        <xsl:sequence select="'.'"/>
      </xsl:if>

      <xsl:sequence select="$new-tokens"/>
    </xsl:variable>

    <xsl:sequence select="t:indent-from-second-line($tokens)"/>

    <xsl:if test="$declaration">
      <xsl:sequence select="$t:new-line"/>

      <xsl:sequence select="'{'"/>
      <xsl:sequence select="$t:new-line"/>

      <xsl:sequence select="$t:indent"/>

      <xsl:variable name="declarations" as="element()*"
        select="t:get-class-declarations($declaration)"/>

      <xsl:for-each select="$declarations">
        <xsl:if test="position() > 1">
          <xsl:sequence select="$t:new-line"/>
        </xsl:if>

        <xsl:apply-templates mode="t:classBodyDeclaration" select="."/>
      </xsl:for-each>

      <xsl:sequence select="$t:unindent"/>

      <xsl:sequence select="'}'"/>
    </xsl:if>
  </xsl:template>

  <!--
    Mode "t:expression". new-array.
  -->
  <xsl:template mode="t:expression" match="new-array">
    <xsl:variable name="type" as="element()" select="type"/>
    <xsl:variable name="array" as="element()?" select="array"/>
    <xsl:variable name="dimensions" as="element()?" select="dimensions"/>

    <xsl:sequence select="'new'"/>
    <xsl:sequence select="' '"/>

    <xsl:choose>
      <xsl:when test="exists($array) = exists($dimensions)">
        <xsl:sequence select="error(xs:QName('invalid-new-array'))"/>
      </xsl:when>
      <xsl:when test="$array">
        <xsl:sequence select="t:get-type($type)"/>
        <xsl:sequence select="t:get-array-initializer($array)"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:variable name="closure" as="item()+" 
          select="t:get-type-with-arity($type, 0)"/>
        <xsl:variable name="element-type" as="element()" 
          select="$closure[. instance of element()]"/>
        <xsl:variable name="arity" as="xs:integer" 
          select="$closure[not(. instance of element())]"/>
        <xsl:variable name="dimension-expressions" as="element()+"
          select="t:get-java-element($dimensions)"/>
        <xsl:variable name="count" as="xs:integer"
          select="count($dimension-expressions)"/>

        <xsl:sequence select="t:get-type($element-type)"/>

        <xsl:if test="$count > $arity">
          <xsl:sequence select="error(xs:QName('invalid-new-array'))"/>
        </xsl:if>

        <xsl:for-each select="$dimension-expressions">
          <xsl:sequence select="'['"/>
          <xsl:sequence select="t:get-expression(.)"/>
          <xsl:sequence select="']'"/>
        </xsl:for-each>

        <xsl:for-each select="$count + 1 to $arity">
          <xsl:sequence select="'['"/>
          <xsl:sequence select="']'"/>
        </xsl:for-each>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

</xsl:stylesheet>