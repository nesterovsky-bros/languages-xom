<?xml version="1.0" encoding="utf-8"?>
<!--
  This stylesheet defines common API for the cobolxom.
 -->
<xsl:stylesheet version="2.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:t="http://www.bphx.com/cobol"
  xmlns:c="http://www.bphx.com/cobol/2009-12-15"
  xmlns="http://www.bphx.com/cobol/2009-12-15"
  xpath-default-namespace="http://www.bphx.com/cobol/2009-12-15"
  exclude-result-prefixes="xs c t">

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
    Gets content elements except comments and meta information.
      $element - an element to get content element for.
      Returns content elements.
  -->
  <xsl:function name="t:get-elements" as="element()*">
    <xsl:param name="element" as="element()"/>

    <xsl:sequence select="$element/(c:* except (comment, meta))"/>
  </xsl:function>

  <!--
    Gets content elements of a procedure-ref group.
      $element - an element to get procedure-ref for.
      Returns content elements of a procedure-ref group.
  -->
  <xsl:function name="t:get-procedure-ref-elements" as="element()*">
    <xsl:param name="element" as="element()"/>

    <xsl:sequence select="$element/(paragraph-ref | section-ref)"/>
  </xsl:function>

  <!--
    Gets content elements of a range-ref group.
      $element - an element to get range-ref for.
      Returns content elements of a range-ref group.
  -->
  <xsl:function name="t:get-range-ref-elements" as="element()*">
    <xsl:param name="element" as="element()"/>

    <xsl:sequence select="$element/(paragraph-ref | section-ref | range-ref)"/>
  </xsl:function>

  <!--
    Gets and expression info for an expression name.
      $name - an expression name.
      Returns expression info.
  -->
  <xsl:function name="t:get-expression-info" as="element()?">
    <xsl:param name="name" as="xs:QName"/>

    <xsl:sequence select="key('t:info', $name, $t:expression-infos)"/>
  </xsl:function>

  <!--
    Gets and expression info for an expression name.
      $name - an expression name.
      Returns expression info.
  -->
  <xsl:function name="t:get-statement-info" as="element()?">
    <xsl:param name="name" as="xs:QName"/>

    <xsl:sequence select="key('t:info', $name, $t:statement-infos)"/>
  </xsl:function>

  <!--
    Generates if/then/else if ... statements.
      $closure - a series of conditions and blocks.
      Returns if/then/else if ... statements.
  -->
  <xsl:function name="t:generate-if-statement" as="element()">
    <xsl:param name="closure" as="element()*"/>

    <xsl:sequence
      select="t:generate-if-statement($closure, count($closure) - 1, ())"/>
  </xsl:function>

  <!--
    Generates if/then/else if ... statements.
      $closure - a series of conditions and blocks.
      $index - current index.
      $result - collected result.
      Returns if/then/else if ... statements.
  -->
  <xsl:function name="t:generate-if-statement" as="element()">
    <xsl:param name="closure" as="element()*"/>
    <xsl:param name="index" as="xs:integer"/>
    <xsl:param name="result" as="element()?"/>

    <xsl:variable name="condition" as="element()?" select="$closure[$index]"/>

    <xsl:choose>
      <xsl:when test="empty($condition)">
        <xsl:sequence select="$result"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:variable name="block" as="element()"
          select="$closure[$index + 1]"/>

        <xsl:variable name="next-result" as="element()">
          <if-statement>
            <condition>
              <xsl:sequence select="$condition"/>
            </condition>
            <then>
              <xsl:sequence select="$block"/>
            </then>

            <xsl:if test="exists($result)">
              <else>
                <xsl:sequence select="$result"/>
              </else>
            </xsl:if>
          </if-statement>
        </xsl:variable>

        <xsl:sequence select="
          t:generate-if-statement($closure, $index - 2, $next-result)"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:function>

  <!--
    Generates an expression from parts.
      $operator - an operator name
      $expressions - a sequence of expressions.
      Returns a combined condition
  -->
  <xsl:function name="t:combine-expression" as="element()">
    <xsl:param name="operator" as="xs:string"/>
    <xsl:param name="expressions" as="element()+"/>

    <xsl:sequence
      select="t:combine-expression($operator, $expressions, 1, ())"/>
  </xsl:function>

  <!--
    Generates an expression from parts.
      $operator - an operator name
      $expressions - a sequence of expressions.
      $index - current index.
      $result - collected result.
      Returns a combined condition
  -->
  <xsl:function name="t:combine-expression" as="element()">
    <xsl:param name="operator" as="xs:string"/>
    <xsl:param name="expressions" as="element()+"/>
    <xsl:param name="index" as="xs:integer"/>
    <xsl:param name="result" as="element()?"/>

    <xsl:variable name="expression" as="element()?"
      select="$expressions[$index]"/>

    <xsl:choose>
      <xsl:when test="empty($expression)">
        <xsl:sequence select="$result"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:variable name="next-result" as="element()">
          <xsl:choose>
            <xsl:when test="empty($result)">
              <xsl:sequence select="$expression"/>
            </xsl:when>
            <xsl:otherwise>
              <xsl:element name="{$operator}">
                <xsl:sequence select="$result"/>
                <xsl:sequence select="$expression"/>
              </xsl:element>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:variable>

        <xsl:sequence select="
          t:combine-expression
          (
            $operator,
            $expressions,
            $index + 1,
            $next-result
          )"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:function>

  <!-- Key to get expression or statement infos. -->
  <xsl:key name="t:info" match="element" use="resolve-QName(@name, .)"/>

  <!-- Expression infos. -->
  <xsl:variable name="t:expression-infos">
    <element name="snippet-expression" precedence="0"/>

    <element name="add" precedence="4" operator="+"/>
    <element name="sub" precedence="4" operator="-"/>
    <element name="mul" precedence="3" operator="*"/>
    <element name="div" precedence="3" operator="/"/>
    <element name="power" precedence="1" operator="**"/>
    <element name="plus" precedence="2" operator="+"/>
    <element name="neg" precedence="2" operator="-"/>
    <element name="data-ref" precedence="0" kind="identifier"/>
    <element name="length-of" precedence="0" kind="identifier"/>
    <element name="address-of" precedence="0" kind="identifier"/>
    <element name="debug-item" precedence="0" kind="identifier"/>
    <element name="return-code" precedence="0" kind="identifier"/>
    <element name="shift-out" precedence="0" kind="identifier"/>
    <element name="shift-in" precedence="0" kind="identifier"/>
    <element name="sort-control" precedence="0" kind="identifier"/>
    <element name="sort-core-size" precedence="0" kind="identifier"/>
    <element name="sort-file-size" precedence="0" kind="identifier"/>
    <element name="sort-message" precedence="0" kind="identifier"/>
    <element name="sort-mode-size" precedence="0" kind="identifier"/>
    <element name="sort-return" precedence="0" kind="identifier"/>
    <element name="tally" precedence="0" kind="identifier"/>
    <element name="when-compiled" precedence="0" kind="identifier"/>
    <element name="subscript" precedence="0" kind="identifier"/>
    <element name="substring" precedence="0" kind="identifier"/>
    <element name="linage-counter" precedence="0" kind="identifier"/>
    <element name="string" precedence="0" kind="literal"/>
    <element name="integer" precedence="0" kind="literal"/>
    <element name="decimal" precedence="0" kind="literal"/>
    <element name="dbcs" precedence="0" kind="literal"/>
    <element name="zero" precedence="0" kind="literal"/>
    <element name="space" precedence="0" kind="literal"/>
    <element name="high-value" precedence="0" kind="literal"/>
    <element name="low-value" precedence="0" kind="literal"/>
    <element name="quote" precedence="0" kind="literal"/>
    <element name="null" precedence="0"/>
    <element name="all" precedence="0"/>
    <element name="parens" precedence="0"/>

    <!-- conditions -->
    <element name="logical-parens" precedence="0" condition="true"/>
    <element name="is-numeric" operator="NUMERIC"
      has-negative="true" precedence="0" condition="true"/>
    <element name="is-alphabetic" operator="ALHABETIC"
      has-negative="true" precedence="0" condition="true"/>
    <element name="is-alphabetic-lower" operator="ALPHABETIC-LOWER"
      has-negative="true" precedence="0" condition="true"/>
    <element name="is-alphabetic-upper" operator="ALPHABETIC-UPPER"
      has-negative="true" precedence="0" condition="true"/>
    <element name="is-dbcs" operator="DBCS"
      has-negative="true" precedence="0" condition="true"/>
    <element name="is-kanji" operator="KANJI" has-negative="true"
      precedence="0" condition="true"/>
    <element name="is-class-name" has-negative="true" 
      precedence="0" condition="true"/>

    <element name="function-call" precedence="0" kind="identifier"/>

    <element name="condition-ref" precedence="0" condition="true"/>
    <element name="gt" has-negative="true" operator="&gt;" precedence="5" 
      condition="true"/>
    <element name="lt" has-negative="true" operator="&lt;" precedence="5" 
      condition="true"/>
    <element name="eq" has-negative="true" operator="=" precedence="5"
      condition="true"/>
    <element name="ge" has-negative="true" operator="&gt;=" precedence="5"
      condition="true"/>
    <element name="le" has-negative="true" operator="&lt;=" precedence="5"
      condition="true"/>
    <element name="is-positive" has-negative="true" precedence="0"
       condition="true"/>
    <element name="is-negative" has-negative="true" precedence="0"
       condition="true"/>
    <element name="is-zero" has-negative="true" precedence="0"
       condition="true"/>
    <element name="not" precedence="0" has-negative="true"
       condition="true"/>
    <element name="and" operator="AND" precedence="6"
       condition="true"/>
    <element name="or" operator="OR" precedence="7"
       condition="true"/>
  </xsl:variable>

  <!-- Statement infos. -->
  <xsl:variable name="t:statement-infos">
    <element name="scope-statement" line-before="true" line-after="true"/>
    <element name="snippet-statement" line-before="true" line-after="true"/>

    <element name="accept-statement" has-short-form="true"/>
    <element name="add-statement" line-before="true" line-after="true"/>
    <element name="alter-statement" has-short-form="true"/>
    <element name="call-statement" line-before="true" line-after="true"/>
    <element name="cancel-statement" line-before="true" line-after="true"/>
    <element name="close-statement"/>
    <element name="compute-statement" has-short-form="true"/>
    <element name="continue-statement" line-before="true"/>
    <element name="delete-statement" line-before="true" line-after="true"/>
    <element name="display-statement" has-short-form="true"/>
    <element name="divide-statement" line-before="true" line-after="true"/>
    <element name="entry-statement" has-short-form="true"/>
    <element name="evaluate-statement" line-before="true" line-after="true"/>
    <element name="exit-statement" line-before="true"/>
    <element name="exit-program-statement"/>
    <element name="goback-statement" line-before="true"/>
    <element name="go-to-statement" line-before="true"/>
    <element name="if-statement" line-before="true" line-after="true"/>
    <element name="initialize-statement"/>
    <element name="inspect-statement"/>
    <element name="merge-statement"/>
    <element name="move-statement"/>
    <element name="multiply-statement" line-before="true" line-after="true"/>
    <element name="open-statement" line-before="true" line-after="true"/>
    <element name="perform-statement"
      has-short-form="true"
      line-before="true" line-after="true"/>
    <element name="read-statement" line-before="true" line-after="true"/>
    <element name="release-statement" line-before="true" line-after="true"/>
    <element name="return-statement" line-before="true" line-after="true"/>
    <element name="rewrite-statement" line-before="true" line-after="true"/>
    <element name="search-statement" line-before="true" line-after="true"/>
    <element name="set-statement"/>
    <element name="sort-statement" line-before="true" line-after="true"/>
    <element name="start-statement" line-before="true" line-after="true"/>
    <element name="stop-statement" line-before="true" line-after="true"/>
    <element name="string-statement" line-before="true" line-after="true"/>
    <element name="subtract-statement" line-before="true" line-after="true"/>
    <element name="unstring-statement" line-before="true" line-after="true"/>
    <element name="write-statement" line-before="true" line-after="true"/>

    <element name="copy"/>
    <element name="exec-sql"
      has-short-form="true"
      line-before="true" line-after="true"/>

    <element name="expression-statement"/>

    <element name="next-sentence"/>
  </xsl:variable>

  <!--
    Builds friendly xpath to the element or attribute.
      $node - a node to build xpath for.
      Returns node's xpath.
  -->
  <xsl:function name="t:get-path" as="xs:string">
    <xsl:param name="node" as="node()"/>

    <xsl:sequence select="
      string-join
      (
        if ($node instance of document-node()) then
        (
          '/'
        )
        else
        (
          for $node in $node/ancestor-or-self::* return
          (
            if ($node instance of attribute()) then
            (
              '/@*[self::*:',
              local-name($node),
              ']'
            )
            else
            (
              '/*[',
              xs:string(count($node/preceding-sibling::*) + 1),
              '][self::*:',
              local-name($node),
              ']',
                  
              for 
                $suffix in ('id', 'ref', 'name', 'type', 'ids'),
                $attribute in 
                  $node/@*[ends-with(lower-case(local-name()), $suffix)]
              return
              (
                '[@', 
                name($attribute), 
                ' = ''',
                xs:string($attribute),
                ''']'
              )
            )
          )
        ),
        ''
      )"/>
  </xsl:function>

</xsl:stylesheet>