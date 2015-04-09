<?xml version="1.0" encoding="utf-8"?>
<!--
  This stylesheet serializes C# xml object model document down to
  the COBOL text.
-->
<xsl:stylesheet version="2.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:t="http://www.bphx.com/cobol"
  xmlns="http://www.bphx.com/cobol/2009-12-15"
  xpath-default-namespace="http://www.bphx.com/cobol/2009-12-15"
  exclude-result-prefixes="xs t">

  <!--
    Gets a sequence of tokens for a condition.
      $value - a condition element.
      Returns a sequence of tokens.
  -->
  <xsl:function name="t:get-condition" as="item()*">
    <xsl:param name="value" as="element()"/>

    <xsl:variable name="tokens" as="item()+">
      <xsl:apply-templates mode="t:condition" select="$value"/>
    </xsl:variable>

    <xsl:sequence select="$tokens"/>
  </xsl:function>

  <!--
    Gets a sequence of tokens for a condition-name-reference.
      $value - a condition-name-reference element.
      Returns a sequence of tokens.
  -->
  <xsl:function name="t:get-condition-name-reference" as="item()*">
    <xsl:param name="value" as="element()"/>

    <xsl:variable name="tokens" as="item()+">
      <xsl:apply-templates mode="t:condition-name-reference" select="$value"/>
    </xsl:variable>

    <xsl:sequence select="$t:soft-line-break"/>
    <xsl:sequence select="$tokens"/>
  </xsl:function>

  <!--
    Gets a sequence of tokens for a literal.
      $value - a literal element.
      Returns a sequence of tokens.
  -->
  <xsl:function name="t:get-literal" as="item()*">
    <xsl:param name="value" as="element()"/>

    <xsl:variable name="tokens" as="item()+">
      <xsl:apply-templates mode="t:literal" select="$value"/>
    </xsl:variable>

    <xsl:sequence select="$t:soft-line-break"/>
    <xsl:sequence select="$tokens"/>
  </xsl:function>

  <!--
    Gets a sequence of tokens for a qualified-data-name.
      $value - a qualified-data-name element.
      Returns a sequence of tokens.
  -->
  <xsl:function name="t:get-qualified-data-name" as="item()*">
    <xsl:param name="value" as="element()"/>

    <xsl:variable name="tokens" as="item()+">
      <xsl:apply-templates mode="t:qualified-data-name" select="$value"/>
    </xsl:variable>

    <xsl:sequence select="$t:soft-line-break"/>
    <xsl:sequence select="$tokens"/>
  </xsl:function>

  <!--
    Gets a sequence of tokens for a data-ref.
      $value - a data-ref element.
      Returns a sequence of tokens.
  -->
  <xsl:function name="t:get-data-ref" as="item()*">
    <xsl:param name="value" as="element()"/>

    <xsl:variable name="tokens" as="item()+">
      <xsl:apply-templates mode="t:data-ref" select="$value"/>
    </xsl:variable>

    <xsl:sequence select="$t:soft-line-break"/>
    <xsl:sequence select="$tokens"/>
  </xsl:function>

  <!--
    Gets a sequence of tokens for a data-ref.
      $value - a data-ref element.
      Returns a sequence of tokens.
  -->
  <xsl:function name="t:get-data-name-ref" as="item()*">
    <xsl:param name="value" as="element()"/>

    <xsl:if test="t:get-elements($value)">
      <xsl:sequence
        select="error(xs:QName('no-children-allowed-in-data-name'))"/>
    </xsl:if>

    <xsl:variable name="tokens" as="item()+">
      <xsl:apply-templates mode="t:data-ref" select="$value"/>
    </xsl:variable>

    <xsl:sequence select="$t:soft-line-break"/>
    <xsl:sequence select="$tokens"/>
  </xsl:function>

  <!--
    Gets a sequence of tokens for a file-ref.
      $value - a file-ref element.
      Returns a sequence of tokens.
  -->
  <xsl:function name="t:get-file-ref" as="item()*">
    <xsl:param name="value" as="element()"/>

    <xsl:variable name="tokens" as="item()+">
      <xsl:apply-templates mode="t:file-ref" select="$value"/>
    </xsl:variable>

    <xsl:sequence select="$t:soft-line-break"/>
    <xsl:sequence select="$tokens"/>
  </xsl:function>

  <!--
    Gets a sequence of tokens for an identifier.
      $value - an identifier element.
      Returns a sequence of tokens.
  -->
  <xsl:function name="t:get-identifier" as="item()*">
    <xsl:param name="value" as="element()"/>

    <xsl:variable name="tokens" as="item()+">
      <xsl:apply-templates mode="t:identifier" select="$value"/>
    </xsl:variable>

    <xsl:sequence select="$t:soft-line-break"/>
    <xsl:sequence select="$tokens"/>
  </xsl:function>

  <!--
    Gets a sequence of tokens for an index-ref.
      $value - an index-ref element.
      Returns a sequence of tokens.
  -->
  <xsl:function name="t:get-index-ref" as="item()*">
    <xsl:param name="value" as="element()"/>

    <xsl:variable name="tokens" as="item()+">
      <xsl:apply-templates mode="t:index-ref" select="$value"/>
    </xsl:variable>

    <xsl:sequence select="$t:soft-line-break"/>
    <xsl:sequence select="$tokens"/>
  </xsl:function>

  <!--
    Gets a sequence of tokens for an integer.
      $integer - a integer element.
      Returns a sequence of tokens.
  -->
  <xsl:function name="t:get-integer" as="item()*">
    <xsl:param name="value" as="element()"/>

    <xsl:variable name="tokens" as="item()+">
      <xsl:apply-templates mode="t:integer" select="$value"/>
    </xsl:variable>

    <xsl:sequence select="$tokens"/>
  </xsl:function>

  <!--
    Gets a sequence of tokens for an qualified-data-name integer.
      $integer - a integer element.
      Returns a sequence of tokens.
  -->
  <xsl:function name="t:get-qualified-data-name-or-integer" as="item()*">
    <xsl:param name="value" as="element()"/>

    <xsl:variable name="tokens" as="item()+">
      <xsl:apply-templates mode="t:qualified-data-name-or-integer"
        select="$value"/>
    </xsl:variable>

    <xsl:sequence select="$t:soft-line-break"/>
    <xsl:sequence select="$tokens"/>
  </xsl:function>

  <!--
    Gets a sequence of tokens for an arithmetic-expression.
      $value - a arithmetic-expression element.
      Returns a sequence of tokens.
  -->
  <xsl:function name="t:get-arithmetic-expression" as="item()*">
    <xsl:param name="value" as="element()"/>

    <xsl:variable name="tokens" as="item()+">
      <xsl:apply-templates mode="t:arithmetic-expression" select="$value"/>
    </xsl:variable>

    <xsl:sequence select="$tokens"/>
  </xsl:function>

  <!--
    Gets a sequence of tokens for a condition.
      $value - a condition element.
      Returns a sequence of tokens.
  -->
  <xsl:function name="t:get-arithmetic-expression-or-condition" as="item()*">
    <xsl:param name="value" as="element()"/>

    <xsl:variable name="tokens" as="item()+">
      <xsl:apply-templates mode="t:arithmetic-expression-or-condition" 
        select="$value"/>
    </xsl:variable>

    <xsl:sequence select="$tokens"/>
  </xsl:function>

  <!--
    Gets a sequence of tokens for a qualified-data-name or a literal.
      $value - a a qualified-data-name or a literal element.
      Returns a sequence of tokens.
  -->
  <xsl:function name="t:get-qualified-data-name-or-literal" as="item()*">
    <xsl:param name="value" as="element()"/>

    <xsl:variable name="tokens" as="item()+">
      <xsl:apply-templates mode="t:qualified-data-name-or-literal"
        select="$value"/>
    </xsl:variable>

    <xsl:sequence select="$t:soft-line-break"/>
    <xsl:sequence select="$tokens"/>
  </xsl:function>

  <!--
    Gets a sequence of tokens for a identifier or a literal.
      $value - a a identifier or a literal element.
      Returns a sequence of tokens.
  -->
  <xsl:function name="t:get-identifier-or-literal" as="item()*">
    <xsl:param name="value" as="element()"/>

    <xsl:variable name="tokens" as="item()+">
      <xsl:apply-templates mode="t:identifier-or-literal" select="$value"/>
    </xsl:variable>

    <xsl:sequence select="$t:soft-line-break"/>
    <xsl:sequence select="$tokens"/>
  </xsl:function>

  <!--
    Gets a sequence of tokens for a identifier or an index-ref.
      $value - a a identifier or an index-ref element.
      Returns a sequence of tokens.
  -->
  <xsl:function name="t:get-identifier-or-index-ref" as="item()*">
    <xsl:param name="value" as="element()"/>

    <xsl:variable name="tokens" as="item()+">
      <xsl:apply-templates mode="t:identifier-or-index-ref" select="$value"/>
    </xsl:variable>

    <xsl:sequence select="$t:soft-line-break"/>
    <xsl:sequence select="$tokens"/>
  </xsl:function>

  <!--
    snippet-expression data-ref.
  -->
  <xsl:template match="snippet-expression" mode="
    t:data-ref
    t:data-ref-or-file-ref
    t:data-ref-or-subscript
    t:qualified-data-name
    t:identifier
    t:identifier-or-literal
    t:identifier-or-index-ref
    t:arithmetic-expression
    t:arithmetic-expression-or-condition
    t:subcript-expression
    t:qualified-data-name-or-literal
    t:qualified-data-name-or-integer
    t:qualified-data-name-or-index-ref">
    <xsl:variable name="value" as="xs:string" select="@value"/>

    <xsl:sequence select="$value"/>
  </xsl:template>

  <!--
    data-ref data-ref.
  -->
  <xsl:template match="data-ref" mode="
    t:data-ref
    t:data-ref-or-file-ref
    t:data-ref-or-subscript
    t:qualified-data-name
    t:identifier
    t:identifier-or-literal
    t:identifier-or-index-ref
    t:arithmetic-expression
    t:arithmetic-expression-or-condition
    t:subcript-expression
    t:qualified-data-name-or-literal
    t:qualified-data-name-or-integer
    t:qualified-data-name-or-index-ref">
    <xsl:variable name="name" as="xs:string" select="@name"/>
    <xsl:variable name="parent" as="element()?" select="t:get-elements(.)"/>

    <xsl:sequence select="$name"/>

    <xsl:if test="$parent">
      <xsl:variable name="tokens" as="item()+">
        <xsl:apply-templates mode="t:data-ref-or-file-ref"
          select="t:get-elements(.)"/>
      </xsl:variable>

      <xsl:sequence select="' '"/>

      <xsl:sequence select="
        if ($parent[self::file-ref]) then
          'IN'
        else
          'OF'"/>

      <xsl:sequence select="' '"/>
      <xsl:sequence select="$tokens"/>
    </xsl:if>
  </xsl:template>

  <!--
    file-ref file-ref.
  -->
  <xsl:template match="file-ref" mode="
    t:file-ref
    t:data-ref-or-file-ref">
    <xsl:variable name="name" as="xs:string" select="@name"/>

    <xsl:sequence select="$name"/>
  </xsl:template>

  <!--
    length-of qualified-data-name.
  -->
  <xsl:template match="length-of" mode="
    t:qualified-data-name
    t:identifier
    t:identifier-or-literal
    t:identifier-or-index-ref
    t:arithmetic-expression
    t:arithmetic-expression-or-condition
    t:subcript-expression
    t:qualified-data-name-or-literal
    t:qualified-data-name-or-integer
    t:qualified-data-name-or-index-ref">

    <xsl:sequence select="'LENGTH'"/>
    <xsl:sequence select="' '"/>
    <xsl:sequence select="'OF'"/>
    <xsl:sequence select="' '"/>
    <xsl:sequence select="t:get-identifier(t:get-elements(.))"/>
  </xsl:template>

  <!--
    address-of qualified-data-name.
  -->
  <xsl:template match="address-of" mode="
    t:qualified-data-name
    t:identifier
    t:identifier-or-literal
    t:identifier-or-index-ref
    t:arithmetic-expression
    t:arithmetic-expression-or-condition
    t:subcript-expression
    t:qualified-data-name-or-literal
    t:qualified-data-name-or-integer
    t:qualified-data-name-or-index-ref">

    <xsl:sequence select="'ADDRESS'"/>
    <xsl:sequence select="' '"/>
    <xsl:sequence select="'OF'"/>
    <xsl:sequence select="' '"/>
    <xsl:sequence select="t:get-identifier(t:get-elements(.))"/>
  </xsl:template>

  <!--
    debug-item qualified-data-name.
  -->
  <xsl:template match="debug-item" mode="
    t:qualified-data-name
    t:identifier
    t:identifier-or-literal
    t:identifier-or-index-ref
    t:arithmetic-expression
    t:arithmetic-expression-or-condition
    t:subcript-expression
    t:qualified-data-name-or-literal
    t:qualified-data-name-or-integer
    t:qualified-data-name-or-index-ref">

    <xsl:sequence select="'DEBUG-ITEM'"/>
  </xsl:template>


  <!--
    return-code qualified-data-name.
  -->
  <xsl:template match="return-code" mode="
    t:qualified-data-name
    t:identifier
    t:identifier-or-literal
    t:identifier-or-index-ref
    t:arithmetic-expression
    t:arithmetic-expression-or-condition
    t:subcript-expression
    t:qualified-data-name-or-literal
    t:qualified-data-name-or-integer
    t:qualified-data-name-or-index-ref">

    <xsl:sequence select="'RETURN-CODE'"/>
  </xsl:template>

  <!--
    shift-out qualified-data-name.
  -->
  <xsl:template match="shift-out" mode="
    t:qualified-data-name
    t:identifier
    t:identifier-or-literal
    t:identifier-or-index-ref
    t:arithmetic-expression
    t:arithmetic-expression-or-condition
    t:subcript-expression
    t:qualified-data-name-or-literal
    t:qualified-data-name-or-integer
    t:qualified-data-name-or-index-ref">

    <xsl:sequence select="'SHIFT-OUT'"/>
  </xsl:template>

  <!--
    shift-in qualified-data-name.
  -->
  <xsl:template match="shift-in" mode="
    t:qualified-data-name
    t:identifier
    t:identifier-or-literal
    t:identifier-or-index-ref
    t:arithmetic-expression
    t:arithmetic-expression-or-condition
    t:subcript-expression
    t:qualified-data-name-or-literal
    t:qualified-data-name-or-integer
    t:qualified-data-name-or-index-ref">

    <xsl:sequence select="'SHIFT-IN'"/>
  </xsl:template>

  <!--
    sort-control qualified-data-name.
  -->
  <xsl:template match="sort-control" mode="
    t:qualified-data-name
    t:identifier
    t:identifier-or-literal
    t:identifier-or-index-ref
    t:arithmetic-expression
    t:arithmetic-expression-or-condition
    t:subcript-expression
    t:qualified-data-name-or-literal
    t:qualified-data-name-or-integer
    t:qualified-data-name-or-index-ref">

    <xsl:sequence select="'SORT-CONTROL'"/>
  </xsl:template>

  <!--
    sort-core-size qualified-data-name.
  -->
  <xsl:template match="sort-core-size" mode="
    t:qualified-data-name
    t:identifier
    t:identifier-or-literal
    t:identifier-or-index-ref
    t:arithmetic-expression
    t:arithmetic-expression-or-condition
    t:subcript-expression
    t:qualified-data-name-or-literal
    t:qualified-data-name-or-integer
    t:qualified-data-name-or-index-ref">

    <xsl:sequence select="'SORT-CORE-SIZE'"/>
  </xsl:template>

  <!--
    sort-file-size qualified-data-name.
  -->
  <xsl:template match="sort-file-size" mode="
    t:qualified-data-name
    t:identifier
    t:identifier-or-literal
    t:identifier-or-index-ref
    t:arithmetic-expression
    t:arithmetic-expression-or-condition
    t:subcript-expression
    t:qualified-data-name-or-literal
    t:qualified-data-name-or-integer
    t:qualified-data-name-or-index-ref">

    <xsl:sequence select="'SORT-FILE-SIZE'"/>
  </xsl:template>

  <!--
    sort-message qualified-data-name.
  -->
  <xsl:template match="sort-message" mode="
    t:qualified-data-name
    t:identifier
    t:identifier-or-literal
    t:identifier-or-index-ref
    t:arithmetic-expression
    t:arithmetic-expression-or-condition
    t:subcript-expression
    t:qualified-data-name-or-literal
    t:qualified-data-name-or-integer
    t:qualified-data-name-or-index-ref">

    <xsl:sequence select="'SORT-MESSAGE'"/>
  </xsl:template>

  <!--
    sort-mode-size qualified-data-name.
  -->
  <xsl:template match="sort-mode-size" mode="
    t:qualified-data-name
    t:identifier
    t:identifier-or-literal
    t:identifier-or-index-ref
    t:arithmetic-expression
    t:arithmetic-expression-or-condition
    t:subcript-expression
    t:qualified-data-name-or-literal
    t:qualified-data-name-or-integer
    t:qualified-data-name-or-index-ref">

    <xsl:sequence select="'SORT-MODE-SIZE'"/>
  </xsl:template>

  <!--
    sort-return qualified-data-name.
  -->
  <xsl:template match="sort-return" mode="
    t:qualified-data-name
    t:identifier
    t:identifier-or-literal
    t:identifier-or-index-ref
    t:arithmetic-expression
    t:arithmetic-expression-or-condition
    t:subcript-expression
    t:qualified-data-name-or-literal
    t:qualified-data-name-or-integer
    t:qualified-data-name-or-index-ref">

    <xsl:sequence select="'SORT-RETURN'"/>
  </xsl:template>

  <!--
    tally qualified-data-name.
  -->
  <xsl:template match="tally" mode="
    t:qualified-data-name
    t:identifier
    t:identifier-or-literal
    t:identifier-or-index-ref
    t:arithmetic-expression
    t:arithmetic-expression-or-condition
    t:subcript-expression
    t:qualified-data-name-or-literal
    t:qualified-data-name-or-integer
    t:qualified-data-name-or-index-ref">

    <xsl:sequence select="'TALLY'"/>
  </xsl:template>

  <!--
    when-compiled qualified-data-name.
  -->
  <xsl:template match="when-compiled" mode="
    t:qualified-data-name
    t:identifier
    t:identifier-or-literal
    t:identifier-or-index-ref
    t:arithmetic-expression
    t:arithmetic-expression-or-condition
    t:subcript-expression
    t:qualified-data-name-or-literal
    t:qualified-data-name-or-integer
    t:qualified-data-name-or-index-ref">

    <xsl:sequence select="'WHEN-COMPILED'"/>
  </xsl:template>

  <!--
    subscript identifier.
  -->
  <xsl:template match="subscript" mode="
    t:identifier
    t:data-ref-or-subscript
    t:identifier-or-literal
    t:identifier-or-index-ref
    t:arithmetic-expression
    t:arithmetic-expression-or-condition">

    <xsl:variable name="elements" as="element()+" select="t:get-elements(.)"/>
    <xsl:variable name="data-ref" as="element()" select="$elements[1]"/>
    <xsl:variable name="indices" as="element()+"
      select="subsequence($elements, 2)"/>

    <xsl:variable name="data-ref-tokens" as="item()+">
      <xsl:apply-templates mode="t:data-ref" select="$data-ref"/>
    </xsl:variable>

    <xsl:sequence select="$data-ref-tokens"/>
    <xsl:sequence select="'('"/>

    <xsl:for-each select="$indices">
      <xsl:variable name="index-tokens" as="item()+">
        <xsl:apply-templates mode="t:subcript-expression" select="."/>
      </xsl:variable>

      <xsl:sequence select="$t:soft-line-break"/>

      <xsl:if test="position() > 1">
        <xsl:sequence select="','"/>
        <xsl:sequence select="' '"/>
      </xsl:if>

      <xsl:sequence select="$index-tokens"/>
    </xsl:for-each>

    <xsl:sequence select="')'"/>
  </xsl:template>

  <!--
    add or sub in subscript.
  -->
  <xsl:template match="add | sub" mode="t:subcript-expression">
    <xsl:variable name="elements" as="element()+" select="t:get-elements(.)"/>
    <xsl:variable name="first" as="element()" select="$elements[1]"/>
    <xsl:variable name="second" as="element()"
      select="subsequence($elements, 2)"/>

    <xsl:variable name="first-tokens" as="item()+">
      <xsl:apply-templates mode="t:qualified-data-name-or-index-ref"
        select="$first"/>
    </xsl:variable>

    <xsl:variable name="second-tokens" as="item()+">
      <xsl:apply-templates mode="t:integer" select="$second"/>
    </xsl:variable>

    <xsl:sequence select="$first-tokens"/>

    <xsl:sequence select="' '"/>

    <xsl:sequence select="
      if (exists(self::add)) then
        '+'
      else
        '-'"/>

    <xsl:sequence select="$t:soft-line-break"/>
    <xsl:sequence select="' '"/>

    <xsl:sequence select="$second-tokens"/>
  </xsl:template>

  <!--
    substring identifier.
  -->
  <xsl:template match="substring" mode="
    t:identifier
    t:identifier-or-literal
    t:identifier-or-index-ref
    t:arithmetic-expression
    t:arithmetic-expression-or-condition">

    <xsl:variable name="elements" as="element()+"
      select="t:get-elements(.)"/>
    <xsl:variable name="data-ref" as="element()" select="$elements[1]"/>
    <xsl:variable name="position" as="element()" select="$elements[2]"/>
    <xsl:variable name="length" as="element()?"
      select="subsequence($elements, 3)"/>

    <xsl:variable name="data-ref-tokens" as="item()+">
      <xsl:apply-templates mode="t:data-ref-or-subscript" select="$data-ref"/>
    </xsl:variable>

    <xsl:variable name="position-tokens" as="item()+">
      <xsl:apply-templates mode="t:arithmetic-expression" select="$position"/>
    </xsl:variable>


    <xsl:sequence select="$data-ref-tokens"/>
    <xsl:sequence select="'('"/>
    <xsl:sequence select="$t:soft-line-break"/>
    <xsl:sequence select="$position-tokens"/>
    <xsl:sequence select="' '"/>
    <xsl:sequence select="':'"/>

    <xsl:if test="$length">
      <xsl:variable name="length-tokens" as="item()+">
        <xsl:apply-templates mode="t:arithmetic-expression" select="$length"/>
      </xsl:variable>

      <xsl:sequence select="' '"/>
      <xsl:sequence select="$t:soft-line-break"/>
      <xsl:sequence select="$length-tokens"/>
    </xsl:if>

    <xsl:sequence select="')'"/>
  </xsl:template>

  <!--
    linage-counter identifier.
  -->
  <xsl:template match="linage-counter" mode="
    t:identifier
    t:identifier-or-literal
    t:identifier-or-index-ref
    t:arithmetic-expression
    t:arithmetic-expression-or-condition">

    <xsl:variable name="file-ref" as="element()?" select="file-ref"/>

    <xsl:sequence select="'LINAGE-COUNTER'"/>

    <xsl:if test="$file-ref">
      <xsl:sequence select="' '"/>
      <xsl:sequence select="'IN'"/>
      <xsl:sequence select="' '"/>
      <xsl:sequence select="t:get-file-ref($file-ref)"/>
    </xsl:if>
  </xsl:template>

  <!--
    index-ref.
  -->
  <xsl:template match="index-ref" mode="
    t:index-ref
    t:subcript-expression
    t:identifier-or-index-ref
    t:qualified-data-name-or-index-ref">
    <xsl:variable name="name" as="xs:string" select="@name"/>

    <xsl:sequence select="$name"/>
  </xsl:template>

  <!--
    string literal.
  -->
  <xsl:template match="string" mode="
    t:literal
    t:identifier-or-literal
    t:identifier-or-index-ref
    t:arithmetic-expression
    t:arithmetic-expression-or-condition
    t:qualified-data-name-or-literal">

    <xsl:variable name="value" as="xs:string" select="@value"/>
    <xsl:variable name="type" as="xs:string?" select="@type"/>

    <xsl:variable name="escaped-value" as="xs:string"
      select="concat('''', replace(@value, '''', ''''''), '''')"/>

    <xsl:choose>
      <xsl:when test="empty($type) or ($type = 'basic')">
        <xsl:sequence select="$escaped-value"/>
      </xsl:when>
      <xsl:when test="$type = 'hex'">
        <xsl:sequence select="X"/>
        <xsl:sequence select="$escaped-value"/>
      </xsl:when>
      <xsl:when test="$type = 'null-terminated'">
        <xsl:sequence select="Z"/>
        <xsl:sequence select="$escaped-value"/>
      </xsl:when>
      <xsl:when test="$type = 'dbcs'">
        <xsl:sequence select="G"/>
        <xsl:sequence select="$escaped-value"/>
      </xsl:when>
      <xsl:when test="$type = 'national-dbcs'">
        <xsl:sequence select="N"/>
        <xsl:sequence select="$escaped-value"/>
      </xsl:when>
      <xsl:when test="$type = 'national'">
        <xsl:sequence select="N"/>
        <xsl:sequence select="$escaped-value"/>
      </xsl:when>
      <xsl:when test="$type = 'national-hex'">
        <xsl:sequence select="NX"/>
        <xsl:sequence select="$escaped-value"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:sequence
          select="error(xs:QName('invalid-string-type'))"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!--
    integer literal.
  -->
  <xsl:template match="integer" mode="
    t:integer
    t:literal
    t:identifier-or-literal
    t:identifier-or-index-ref
    t:arithmetic-expression
    t:arithmetic-expression-or-condition
    t:subcript-expression
    t:qualified-data-name-or-integer
    t:qualified-data-name-or-literal">
    <xsl:variable name="value" as="xs:integer" select="@value"/>

    <xsl:sequence select="xs:string($value)"/>
  </xsl:template>

  <!--
    decimal literal.
  -->
  <xsl:template match="decimal" mode="
    t:literal
    t:identifier-or-literal
    t:identifier-or-index-ref
    t:arithmetic-expression
    t:arithmetic-expression-or-condition
    t:qualified-data-name-or-literal">
    <xsl:variable name="value" as="xs:decimal" select="@value"/>

    <xsl:sequence select="xs:string($value)"/>
  </xsl:template>

  <!--
    ZERO figurative-constant.
  -->
  <xsl:template match="zero" mode="
    t:figurative-constant
    t:literal
    t:identifier-or-literal
    t:identifier-or-index-ref
    t:arithmetic-expression
    t:arithmetic-expression-or-condition
    t:qualified-data-name-or-literal">
    <xsl:sequence select="'ZERO'"/>
  </xsl:template>

  <!--
    SPACE figurative-constant.
  -->
  <xsl:template match="space" mode="
    t:figurative-constant
    t:literal
    t:identifier-or-literal
    t:identifier-or-index-ref
    t:arithmetic-expression
    t:arithmetic-expression-or-condition
    t:qualified-data-name-or-literal">
    <xsl:sequence select="'SPACE'"/>
  </xsl:template>

  <!--
    HIGH-VALUE figurative-constant.
  -->
  <xsl:template match="high-value" mode="
    t:figurative-constant
    t:literal
    t:identifier-or-literal
    t:identifier-or-index-ref
    t:arithmetic-expression
    t:arithmetic-expression-or-condition
    t:qualified-data-name-or-literal">
    <xsl:sequence select="'HIGH-VALUE'"/>
  </xsl:template>

  <!--
    low-value figurative-constant.
  -->
  <xsl:template match="low-value" mode="
    t:figurative-constant
    t:literal
    t:identifier-or-literal
    t:identifier-or-index-ref
    t:arithmetic-expression
    t:arithmetic-expression-or-condition
    t:qualified-data-name-or-literal">
    <xsl:sequence select="'LOW-VALUE'"/>
  </xsl:template>

  <!--
    QUOTE figurative-constant.
  -->
  <xsl:template match="quote" mode="
    t:figurative-constant
    t:literal
    t:identifier-or-literal
    t:identifier-or-index-ref
    t:arithmetic-expression
    t:arithmetic-expression-or-condition
    t:qualified-data-name-or-literal">
    <xsl:sequence select="'QUOTE'"/>
  </xsl:template>

  <!--
    NULL figurative-constant.
  -->
  <xsl:template match="null" mode="
    t:figurative-constant
    t:literal
    t:identifier-or-literal
    t:identifier-or-index-ref
    t:arithmetic-expression
    t:arithmetic-expression-or-condition
    t:qualified-data-name-or-literal">
    <xsl:sequence select="'NULL'"/>
  </xsl:template>

  <!--
    ALL literal figurative-constant.
  -->
  <xsl:template match="all" mode="
    t:figurative-constant
    t:literal
    t:identifier-or-literal
    t:identifier-or-index-ref
    t:arithmetic-expression
    t:arithmetic-expression-or-condition
    t:qualified-data-name-or-literal">
    <xsl:sequence select="'ALL'"/>
    <xsl:sequence select="' '"/>
    <xsl:sequence select="t:get-literal(t:get-elements(.))"/>
  </xsl:template>

  <!--
    macro figurative-constant.
  -->
  <xsl:template match="macro" mode="
    t:figurative-constant
    t:literal
    t:identifier-or-literal
    t:identifier-or-index-ref
    t:arithmetic-expression
    t:arithmetic-expression-or-condition
    t:qualified-data-name-or-literal">
    <xsl:variable name="name" as="xs:string" select="@name"/>

    <xsl:variable name="value" as="xs:string" select="
      if ($name = 'program') then
        ancestor::program[1]/xs:string(@name)
      else if ($name = 'section') then
        string(ancestor::section[1]/@name)
      else if ($name = 'paragraph') then
        string(ancestor::paragraph[1]/@name)
      else
        error(xs:QName('invalid-macro-name'))"/>

    <xsl:sequence
      select="concat('''', replace($value, '''', ''''''), '''')"/>
  </xsl:template>

  <!--
    add, sub, mul, div, power arithmetic-expression.
  -->
  <xsl:template match="add | sub | mul | div | power" mode="
    t:arithmetic-expression
    t:arithmetic-expression-or-condition">

    <xsl:call-template name="t:get-binary-expression">
      <xsl:with-param name="expression" select="."/>
    </xsl:call-template>
  </xsl:template>

  <!--
    plus, neg arithmetic-expression.
  -->
  <xsl:template match="plus | neg" mode="
    t:arithmetic-expression
    t:arithmetic-expression-or-condition">

    <xsl:call-template name="t:get-unary-expression">
      <xsl:with-param name="expression" select="."/>
    </xsl:call-template>
  </xsl:template>

  <!--
    parens arithmetic-expression.
  -->
  <xsl:template match="parens" mode="
    t:arithmetic-expression
    t:arithmetic-expression-or-condition">

    <xsl:variable name="argument" as="element()"
      select="t:get-elements(.)"/>

    <xsl:variable name="tokens" as="item()+">
      <xsl:apply-templates mode="t:arithmetic-expression" select="$argument"/>
    </xsl:variable>

    <xsl:sequence select="'('"/>
    <xsl:sequence select="$tokens"/>
    <xsl:sequence select="')'"/>
  </xsl:template>

  <!--
    function-call t:arithmetic-expression.
  -->
  <xsl:template match="function-call" mode="
    t:data-ref
    t:data-ref-or-file-ref
    t:data-ref-or-subscript
    t:qualified-data-name
    t:identifier
    t:identifier-or-literal
    t:identifier-or-index-ref
    t:arithmetic-expression
    t:arithmetic-expression-or-condition
    t:subcript-expression
    t:qualified-data-name-or-literal
    t:qualified-data-name-or-integer
    t:qualified-data-name-or-index-ref">
    <xsl:variable name="name" as="xs:string" select="@name"/>
    <xsl:variable name="arguments" as="element()*"
      select="t:get-elements(.)"/>

    <xsl:sequence select="'FUNCTION'"/>
    <xsl:sequence select="' '"/>
    <xsl:sequence select="$name"/>

    <xsl:if test="$arguments">
      <xsl:sequence select="'('"/>
      <xsl:sequence select="$t:soft-line-break"/>

      <xsl:for-each select="$arguments">
        <xsl:if test="position() gt 1">
          <xsl:sequence select="','"/>
          <xsl:sequence select="$t:soft-line-break"/>
          <xsl:sequence select="' '"/>
        </xsl:if>

        <xsl:sequence select="t:get-arithmetic-expression(.)"/>
      </xsl:for-each>

      <xsl:sequence select="')'"/>
    </xsl:if>
  </xsl:template>

  <xsl:template name="t:get-binary-expression" as="item()*">
    <xsl:param name="expression" as="element()"/>

    <xsl:variable name="elements" as="element()+"
      select="t:get-elements(.)"/>
    <xsl:variable name="first" as="element()" select="$elements[1]"/>
    <xsl:variable name="second" as="element()"
      select="subsequence($elements, 2)"/>

    <xsl:variable name="first-tokens" as="item()+">
      <xsl:apply-templates mode="#current" select="$first"/>
    </xsl:variable>

    <xsl:variable name="second-tokens" as="item()+">
      <xsl:apply-templates mode="#current" select="$second"/>
    </xsl:variable>

    <xsl:variable name="info" as="element()?"
      select="t:get-expression-info(node-name(.))"/>
    <xsl:variable name="first-info" as="element()?"
      select="t:get-expression-info(node-name($first))"/>
    <xsl:variable name="second-info" as="element()?"
      select="t:get-expression-info(node-name($second))"/>

    <xsl:choose>
      <xsl:when test="
        xs:integer($info/@priority) lt xs:integer($first-info/@priority)">
        <xsl:sequence select="'('"/>
        <xsl:sequence select="$first-tokens"/>
        <xsl:sequence select="')'"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:sequence select="$first-tokens"/>
      </xsl:otherwise>
    </xsl:choose>

    <xsl:sequence select="' '"/>
    <xsl:sequence select="string($info/@operator)"/>
    <xsl:sequence select="$t:soft-line-break"/>
    <xsl:sequence select="' '"/>

    <xsl:choose>
      <xsl:when test="
        xs:integer($info/@priority) lt xs:integer($second-info/@priority)">
        <xsl:sequence select="'('"/>
        <xsl:sequence select="$second-tokens"/>
        <xsl:sequence select="')'"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:sequence select="$second-tokens"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="t:get-unary-expression" as="item()*">
    <xsl:param name="expression" as="element()"/>

    <xsl:variable name="argument" as="element()"
      select="t:get-elements(.)"/>

    <xsl:variable name="tokens" as="item()+">
      <xsl:apply-templates mode="#current" select="$argument"/>
    </xsl:variable>

    <xsl:variable name="info" as="element()?"
      select="t:get-expression-info(node-name(.))"/>
    <xsl:variable name="argument-info" as="element()?"
      select="t:get-expression-info(node-name($argument))"/>

    <xsl:sequence select="string($info/@operator)"/>

    <xsl:choose>
      <xsl:when test="
        xs:integer($info/@priority) lt xs:integer($argument-info/@priority)">
        <xsl:sequence select="'('"/>
        <xsl:sequence select="$tokens"/>
        <xsl:sequence select="')'"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:sequence select="$tokens"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!--
    not condition.
  -->
  <xsl:template match="not" mode="
    t:condition
    t:arithmetic-expression-or-condition">
    <xsl:param name="negative" as="xs:boolean?"/>

    <xsl:variable name="argument" as="element()"
      select="t:get-elements(.)"/>

    <xsl:variable name="argument-info" as="element()?"
      select="t:get-expression-info(node-name($argument))"/>
    <xsl:variable name="has-negative" as="xs:boolean?"
      select="$argument-info/xs:boolean(@has-negative)"/>

    <xsl:variable name="tokens" as="item()+">
      <xsl:apply-templates mode="t:condition" select="$argument">
        <xsl:with-param name="negative"
          select="not($negative) and ($has-negative = true())"/>
      </xsl:apply-templates>
    </xsl:variable>

    <xsl:if test="not($negative) and not($has-negative)">
      <xsl:sequence select="'NOT'"/>
      <xsl:sequence select="' '"/>
    </xsl:if>

    <xsl:sequence select="$tokens"/>
  </xsl:template>

  <!--
    and, or condition.
  -->
  <xsl:template match="and | or" mode="
    t:condition
    t:arithmetic-expression-or-condition">
    <xsl:call-template name="t:get-binary-expression">
      <xsl:with-param name="expression" select="."/>
    </xsl:call-template>
  </xsl:template>

  <!--
    gt, lt, eq, ge, le condition.
  -->
  <xsl:template match="gt | lt | eq | ge | le" mode="
    t:condition
    t:arithmetic-expression-or-condition">
    <xsl:param name="negative" as="xs:boolean?"/>

    <xsl:variable name="elements" as="element()+"
      select="t:get-elements(.)"/>
    <xsl:variable name="first" as="element()" select="$elements[1]"/>
    <xsl:variable name="second" as="element()"
      select="subsequence($elements, 2)"/>

    <xsl:variable name="first-tokens" as="item()+">
      <xsl:apply-templates mode="t:arithmetic-expression" select="$first"/>
    </xsl:variable>

    <xsl:variable name="second-tokens" as="item()+">
      <xsl:apply-templates mode="t:arithmetic-expression" select="$second"/>
    </xsl:variable>

    <xsl:variable name="info" as="element()?"
      select="t:get-expression-info(node-name(.))"/>
    <xsl:variable name="first-info" as="element()?"
      select="t:get-expression-info(node-name($first))"/>
    <xsl:variable name="second-info" as="element()?"
      select="t:get-expression-info(node-name($second))"/>

    <xsl:choose>
      <xsl:when test="
        xs:integer($info/@priority) lt xs:integer($first-info/@priority)">
        <xsl:sequence select="'('"/>
        <xsl:sequence select="$first-tokens"/>
        <xsl:sequence select="')'"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:sequence select="$first-tokens"/>
      </xsl:otherwise>
    </xsl:choose>

    <xsl:sequence select="' '"/>

    <xsl:if test="$negative">
      <xsl:sequence select="'NOT'"/>
      <xsl:sequence select="' '"/>
    </xsl:if>

    <xsl:sequence select="string($info/@operator)"/>
    <xsl:sequence select="' '"/>

    <xsl:choose>
      <xsl:when test="
        xs:integer($info/@priority) lt xs:integer($second-info/@priority)">
        <xsl:sequence select="'('"/>
        <xsl:sequence select="$second-tokens"/>
        <xsl:sequence select="')'"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:sequence select="$second-tokens"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!--
    is-positive, is-negative, is-zero condition.
  -->
  <xsl:template match="is-positive | is-negative | is-zero" mode="
    t:condition
    t:arithmetic-expression-or-condition">
    <xsl:param name="negative" as="xs:boolean?"/>

    <xsl:variable name="argument" as="element()"
      select="t:get-elements(.)"/>

    <xsl:variable name="info" as="element()?"
      select="t:get-expression-info(node-name(.))"/>

    <xsl:variable name="tokens" as="item()+">
      <xsl:apply-templates mode="t:arithmetic-expression" select="$argument"/>
    </xsl:variable>

    <xsl:sequence select="'IS'"/>
    <xsl:sequence select="' '"/>

    <xsl:if test="$negative">
      <xsl:sequence select="'NOT'"/>
      <xsl:sequence select="' '"/>
    </xsl:if>

    <xsl:sequence select="string($info/@operator)"/>
  </xsl:template>

  <!--
    is-numeric, is-alphabetic, is-alphabetic-lower,
    is-alphabetic-upper, is-alphabetic-dbcs, is-alphabetic-kanji condition.
  -->
  <xsl:template match="
    is-numeric |
    is-alphabetic |
    is-alphabetic-lower |
    is-alphabetic-upper |
    is-alphabetic-dbcs |
    is-alphabetic-kanji"
    mode="
      t:condition
      t:arithmetic-expression-or-condition">
    <xsl:param name="negative" as="xs:boolean?"/>

    <xsl:variable name="argument" as="element()"
      select="t:get-elements(.)"/>

    <xsl:variable name="info" as="element()?"
      select="t:get-expression-info(node-name(.))"/>

    <xsl:variable name="tokens" as="item()+">
      <xsl:apply-templates mode="t:identifier" select="$argument"/>
    </xsl:variable>

    <xsl:sequence select="$tokens"/>
    <xsl:sequence select="' '"/>
    <xsl:sequence select="'IS'"/>
    <xsl:sequence select="' '"/>

    <xsl:if test="$negative">
      <xsl:sequence select="'NOT'"/>
      <xsl:sequence select="' '"/>
    </xsl:if>

    <xsl:sequence select="string($info/@operator)"/>
  </xsl:template>

  <!--
    is-class condition.
  -->
  <xsl:template match="is-class" mode="
    t:condition
    t:arithmetic-expression-or-condition">
    <xsl:param name="negative" as="xs:boolean?"/>

    <xsl:variable name="name" as="xs:string" select="@name"/>
    <xsl:variable name="argument" as="element()"
      select="t:get-elements(.)"/>

    <xsl:variable name="tokens" as="item()+">
      <xsl:apply-templates mode="t:identifier" select="$argument"/>
    </xsl:variable>

    <xsl:sequence select="$tokens"/>
    <xsl:sequence select="' '"/>
    <xsl:sequence select="'IS'"/>
    <xsl:sequence select="' '"/>

    <xsl:if test="$negative">
      <xsl:sequence select="'NOT'"/>
      <xsl:sequence select="' '"/>
    </xsl:if>

    <xsl:sequence select="$name"/>
  </xsl:template>

  <!--
    logical-parens condition.
  -->
  <xsl:template match="logical-parens" mode="
    t:condition
    t:arithmetic-expression-or-condition">

    <xsl:variable name="argument" as="element()"
      select="t:get-elements(.)"/>

    <xsl:variable name="tokens" as="item()+">
      <xsl:apply-templates mode="#current" select="$argument"/>
    </xsl:variable>

    <xsl:sequence select="'('"/>
    <xsl:sequence select="$tokens"/>
    <xsl:sequence select="')'"/>
  </xsl:template>

  <!--
    condition-ref condition.
  -->
  <xsl:template match="condition-ref" mode="
    t:condition
    t:arithmetic-expression-or-condition
    t:condition-name-reference">

    <xsl:variable name="name" as="xs:string" select="@name"/>
    <xsl:variable name="identifier" as="element()?"
      select="t:get-elements(.)"/>

    <xsl:sequence select="$name"/>

    <xsl:if test="$identifier">
      <xsl:variable name="tokens" as="item()+">
        <xsl:apply-templates mode="t:identifier" select="$identifier"/>
      </xsl:variable>

      <xsl:sequence select="' '"/>
      <xsl:sequence select="'IN'"/>
      <xsl:sequence select="' '"/>
      <xsl:sequence select="$tokens"/>
    </xsl:if>
  </xsl:template>

  <!-- Default template. -->
  <xsl:template match="node()" mode="
    t:arithmetic-expression
    t:arithmetic-expression-or-condition
    t:condition
    t:condition-name-reference
    t:element
    t:figurative-constant
    t:identifier
    t:identifier-or-literal
    t:identifier-or-index-ref
    t:index-ref
    t:integer
    t:literal
    t:qualified-data-name
    t:qualified-data-name-or-index-ref
    t:qualified-data-name-or-integer
    t:subcript-expression">

    <xsl:sequence select="error(xs:QName('invalid-node'), t:get-path(.))"/>
  </xsl:template>

</xsl:stylesheet>