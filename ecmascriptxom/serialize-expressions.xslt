<?xml version="1.0" encoding="utf-8"?>
<!--
  This stylesheet serializes ecmascript xml object model document 
  into ecmascript text.
 -->
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns="http://www.nesterovsky-bros.com/ecmascript6/2015-02-20"
  xmlns:t="http://www.nesterovsky-bros.com/ecmascript"
  xpath-default-namespace="http://www.nesterovsky-bros.com/ecmascript6/2015-02-20"
  exclude-result-prefixes="xs t">

  <!--
    Gets a sequence of tokens for an expression.
      $expression - an expression.
      Returns a sequence of tokens.
  -->
  <xsl:function name="t:expression" as="item()+">
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

  <!-- Mode "t:expression". null. -->
  <xsl:template mode="t:expression" match="null">
    <xsl:sequence select="'null'"/>
  </xsl:template>

  <!-- Mode "t:expression". this. -->
  <xsl:template mode="t:expression" match="this">
    <xsl:sequence select="'this'"/>
  </xsl:template>

  <!-- Mode "t:expression". super. -->
  <xsl:template mode="t:expression" match="super">
    <xsl:sequence select="'super'"/>
  </xsl:template>

  <!-- Mode "t:expression t:lefthand-side-expression". ref. -->
  <xsl:template mode="t:expression t:lefthand-side-expression" match="ref">
    <xsl:variable name="name" as="xs:string" select="@name"/>
    <xsl:variable name="base" as="element()?" select="t:get-elements(.)"/>

    <xsl:if test="$base">
      <xsl:sequence select="t:get-nested-expression($base)"/>
      <xsl:sequence select="'.'"/>
    </xsl:if>

    <xsl:sequence select="$name"/>
  </xsl:template>

  <!-- Mode "t:expression". boolean. -->
  <xsl:template mode="t:expression" match="boolean">
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

  <!-- Mode "t:expression". boolean. -->
  <xsl:template mode="t:expression" match="number">
    <xsl:variable name="value" as="xs:double" select="@value"/>
    <xsl:variable name="form" as="xs:xsting?" select="@form"/>

    <xsl:choose>
      <xsl:when test="$form = 'binary'">
        <xsl:sequence select="concat('0b', t:integer-to-string($value, 2))"/>
      </xsl:when>
      <xsl:when test="$form = 'octal'">
        <xsl:sequence select="concat('0o', t:integer-to-string($value, 2))"/>
      </xsl:when>
      <xsl:when test="$form = 'hex'">
        <xsl:sequence select="concat('0x', t:integer-to-string($value, 2))"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:sequence select="string($value)"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!-- Mode "t:expression". string. -->
  <xsl:template mode="t:expression" match="string">
    <xsl:variable name="value" as="xs:string" select="@value"/>

    <xsl:sequence
      select="concat('&quot;', t:escape-string($value), '&quot;')"/>
  </xsl:template>

  <!-- Mode "t:expression". regex. -->
  <xsl:template mode="t:expression" match="regex">
    <xsl:variable name="value" as="xs:string" select="@value"/>
    <xsl:variable name="flags" as="xs:string" select="@flags"/>

    <xsl:sequence
      select="concat('/', t:escape-string($value), '/', $flags)"/>
  </xsl:template>

  <!-- Mode "t:expression". template. -->
  <xsl:template mode="t:expression" match="template">
    <xsl:for-each-group select="t:get-elements(.)" 
      group-adjacent="xs:boolean(self::string)">
      <xsl:choose>
        <xsl:when test="current-grouping-key()">
          <xsl:variable name="parts" as="xs:string*">
            <xsl:for-each select="current-group()/@value">
              <xsl:analyze-string select="." regex="\.|[`$\]">
                <xsl:matching-substring>
                  <xsl:choose>
                    <xsl:when test=". = ('`', '$', '\')">
                      <xsl:sequence select="concat('\', .)"/>
                    </xsl:when>
                    <xsl:otherwise>
                      <xsl:sequence select="."/>
                    </xsl:otherwise>
                  </xsl:choose>
                </xsl:matching-substring>
                <xsl:non-matching-substring>
                  <xsl:sequence select="."/>
                </xsl:non-matching-substring>
              </xsl:analyze-string>
            </xsl:for-each>
          </xsl:variable>

          <xsl:sequence select="
            string-join
            (
              (
                (
                  if (position() = 1) then
                    '`'
                  else
                    '}'
                ),
                $parts,
                (
                  if (position() = last()) then
                    '`'
                  else
                    '${'
                )
              ),
              ''
            )"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:if test="position() = 1">
            <xsl:sequence select="'`${'"/>
          </xsl:if>
          
          <xsl:sequence select="t:get-nested-expression(.)"/>

          <xsl:if test="position() = last()">
            <xsl:sequence select="'}`'"/>
          </xsl:if>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:for-each-group>
  </xsl:template>

  <!-- Mode "t:expression t:lefthand-side-expression". parens. -->
  <xsl:template mode="t:expression t:lefthand-side-expression" match="parens">
    <xsl:sequence select="'('"/>

    <xsl:for-each select="t:get-elements(.)">
      <xsl:sequence select="t:get-nested-expression(.)"/>

      <xsl:if test="position() != last()">
        <xsl:sequence select="','"/>
        <xsl:sequence select="' '"/>
        <xsl:sequence select="$t:soft-line-break"/>
      </xsl:if>
    </xsl:for-each>

    <xsl:sequence select="')'"/>
  </xsl:template>

  <!-- Mode "t:expression". array. -->
  <xsl:template mode="t:expression" match="array">
    <xsl:sequence select="'['"/>
    <xsl:sequence select="$t:soft-line-break"/>

    <xsl:for-each select="t:get-elements(.)">
      <xsl:choose>
        <xsl:when test="self::elision">
          <!-- Do nothing. -->
        </xsl:when>
        <xsl:when test="self::spread">
          <xsl:sequence select="'...'"/>
          <xsl:sequence select="t:get-nested-expression(t:get-elements(.))"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:sequence select="t:get-nested-expression(.)"/>
        </xsl:otherwise>
      </xsl:choose>

      <xsl:if test="position() != last()">
        <xsl:sequence select="','"/>
        <xsl:sequence select="' '"/>
      </xsl:if>

      <xsl:sequence select="$t:soft-line-break"/>
    </xsl:for-each>

    <xsl:sequence select="']'"/>
  </xsl:template>
  
  <!-- Mode "t:expression". object. -->
  <xsl:template mode="t:expression" match="object">
    <xsl:sequence select="'{'"/>
    <xsl:sequence select="$t:soft-line-break"/>

    <xsl:for-each select="t:get-elements(.)">
      <xsl:sequence select="t:get-comments(.)"/>
      <xsl:apply-templates mode="t:object-member" select="."/>

      <xsl:if test="position() != last()">
        <xsl:sequence select="','"/>
        <xsl:sequence select="' '"/>
      </xsl:if>

      <xsl:sequence select="$t:soft-line-break"/>
    </xsl:for-each>

    <xsl:sequence select="'}'"/>
  </xsl:template>
  
  <!-- Mode "t:property-name". name -->
  <xsl:template mode="t:property-name" match="name">
    <xsl:variable name="name" as="xs:string?" select="@value"/>
    <xsl:variable name="expression" as="element()?" 
      select="t:get-elements(.)"/>
  
    <xsl:if test="boolean($name) = exists($expression)">
      <xsl:sequence select="
        error
        (
          xs:QName('invalid-property-name'),
          'Property name is required either in the form of identifier, string, number or expression.',
          .
        )"/>
    </xsl:if>
  
    <xsl:choose>
      <xsl:when test="$name">
        <xsl:sequence select="$name"/>
      </xsl:when>
      <xsl:when test="$expression[self::number or self::string]">
        <xsl:sequence select="t:get-nested-expression(.)"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:sequence select="'['"/>
        <xsl:sequence select="t:get-nested-expression(.)"/>
        <xsl:sequence select="']'"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template mode="t:object-member" match="scope">
    <xsl:sequence select="$t:new-line"/>

    <xsl:for-each select="t:get-elements(.)">
      <xsl:sequence select="t:get-comments(.)"/>
      <xsl:apply-templates mode="t:object-member" select="."/>

      <xsl:if test="position() != last()">
        <xsl:sequence select="','"/>
        <xsl:sequence select="' '"/>
      </xsl:if>

      <xsl:sequence select="$t:soft-line-break"/>
    </xsl:for-each>
    
    <xsl:sequence select="$t:new-line"/>
  </xsl:template>

  <!-- Mode "t:object-member" property. -->
  <xsl:template mode="t:object-member" match="property">
    <xsl:variable name="name" as="element()" select="$name"/>
    <xsl:variable name="value" as="element()?" 
      select="t:get-elements(.) except $name"/>
  
    <xsl:apply-templates mode="t:property-name" select="$name"/>
  
    <xsl:if test="not($name/@name) and not($value)">
      <xsl:sequence select="
        error
        (
          xs:QName('invalid-property-value'),
          'Property value is expected.',
          .
        )"/>
    </xsl:if>
  
    <xsl:if test="$value">
      <xsl:sequence select="':'"/>
      <xsl:sequence select="' '"/>
      <xsl:sequence select="$t:soft-line-break"/>
      <xsl:sequence select="t:get-nested-expression($value)"/>
    </xsl:if>
  </xsl:template>

  <!-- 
    Mode "t:object-member t:method-definition t:declaration t:expression" 
    function.
  -->
  <xsl:template match="function"
    mode="t:object-member t:method-definition t:declaration t:expression">
    <!-- TODO: implement this. -->
  </xsl:template>
  
  <!-- Mode "t:object-member t:method-definition t:declaration" get-function. -->
  <xsl:template match="get-function"
    mode="t:object-member t:method-definition">
    <!-- TODO: implement this. -->
  </xsl:template>
  
  <!-- Mode "t:object-member t:method-definition" set-function. -->
  <xsl:template match="set-function"
    mode="t:object-member t:method-definition">
    <!-- TODO: implement this. -->
  </xsl:template>

  <!-- 
    Mode "t:object-member t:method-definition t:declaration t:expression"
    generator-function.
  -->
  <xsl:template match="generator-function"
    mode="t:object-member t:method-definition t:declaration t:expression">
    <!-- TODO: implement this. -->
  </xsl:template>

  <!-- Mode "t:declaration t:expression" class. -->
  <xsl:template match="class"
    mode="t:declaration t:expression">
    <!-- TODO: implement this. -->
  </xsl:template>

  <!-- Mode "t:expression". conditional. -->
  <xsl:template mode="t:expression" match="conditional">
    <xsl:variable name="expressions" as="element()+"
      select="t:get-elements(.)"/>
    <xsl:variable name="condition" as="element()" select="$expressions[1]"/>
    <xsl:variable name="true-value" as="element()" select="$expressions[2]"/>
    <xsl:variable name="false-value" as="element()" select="$expressions[3]"/>

    <xsl:sequence select="t:get-nested-expression($condition)"/>
    <xsl:sequence select="' '"/>
    <xsl:sequence select="'?'"/>
    <xsl:sequence select="' '"/>
    <xsl:sequence select="$t:soft-line-break"/>
    <xsl:sequence select="t:get-nested-expression($true-value)"/>
    <xsl:sequence select="' '"/>
    <xsl:sequence select="':'"/>
    <xsl:sequence select="' '"/>
    <xsl:sequence select="$t:soft-line-break"/>
    <xsl:sequence select="t:get-nested-expression($false-value)"/>
  </xsl:template>

  <!-- Mode "t:expression". or. -->
  <xsl:template mode="t:expression" match="or">
    <xsl:variable name="expressions" as="element()+"
      select="t:get-elements(.)"/>
    <xsl:variable name="left" as="element()" select="$expressions[1]"/>
    <xsl:variable name="right" as="element()" select="$expressions[2]"/>

    <xsl:sequence select="t:get-nested-expression($left)"/>
    <xsl:sequence select="' '"/>
    <xsl:sequence select="'||'"/>
    <xsl:sequence select="' '"/>
    <xsl:sequence select="$t:soft-line-break"/>
    <xsl:sequence select="t:get-nested-expression($right)"/>
  </xsl:template>

  <!-- Mode "t:expression". and. -->
  <xsl:template mode="t:expression" match="and">
    <xsl:variable name="expressions" as="element()+"
      select="t:get-elements(.)"/>
    <xsl:variable name="left" as="element()" select="$expressions[1]"/>
    <xsl:variable name="right" as="element()" select="$expressions[2]"/>

    <xsl:sequence select="t:get-nested-expression($left)"/>
    <xsl:sequence select="' '"/>
    <xsl:sequence select="'&amp;&amp;'"/>
    <xsl:sequence select="' '"/>
    <xsl:sequence select="$t:soft-line-break"/>
    <xsl:sequence select="t:get-nested-expression($right)"/>
  </xsl:template>

  <!-- Mode "t:expression". bitwise-or. -->
  <xsl:template mode="t:expression" match="bitwise-or">
    <xsl:variable name="expressions" as="element()+"
      select="t:get-elements(.)"/>
    <xsl:variable name="left" as="element()" select="$expressions[1]"/>
    <xsl:variable name="right" as="element()" select="$expressions[2]"/>

    <xsl:sequence select="t:get-nested-expression($left)"/>
    <xsl:sequence select="' '"/>
    <xsl:sequence select="'|'"/>
    <xsl:sequence select="' '"/>
    <xsl:sequence select="t:get-nested-expression($right)"/>
  </xsl:template>


  <!-- Mode "t:expression". bitwise-xor. -->
  <xsl:template mode="t:expression" match="bitwise-xor">
    <xsl:variable name="expressions" as="element()+"
      select="t:get-elements(.)"/>
    <xsl:variable name="left" as="element()" select="$expressions[1]"/>
    <xsl:variable name="right" as="element()" select="$expressions[2]"/>

    <xsl:sequence select="t:get-nested-expression($left)"/>
    <xsl:sequence select="' '"/>
    <xsl:sequence select="'^'"/>
    <xsl:sequence select="' '"/>
    <xsl:sequence select="t:get-nested-expression($right)"/>
  </xsl:template>
  
  <!-- Mode "t:expression". bitwise-and. -->
  <xsl:template mode="t:expression" match="bitwise-and">
    <xsl:variable name="expressions" as="element()+"
      select="t:get-elements(.)"/>
    <xsl:variable name="left" as="element()" select="$expressions[1]"/>
    <xsl:variable name="right" as="element()" select="$expressions[2]"/>

    <xsl:sequence select="t:get-nested-expression($left)"/>
    <xsl:sequence select="' '"/>
    <xsl:sequence select="'&amp;'"/>
    <xsl:sequence select="' '"/>
    <xsl:sequence select="t:get-nested-expression($right)"/>
  </xsl:template>

  <!-- Mode "t:expression". eq. -->
  <xsl:template mode="t:expression" match="eq">
    <xsl:variable name="expressions" as="element()+"
      select="t:get-elements(.)"/>
    <xsl:variable name="left" as="element()" select="$expressions[1]"/>
    <xsl:variable name="right" as="element()" select="$expressions[2]"/>

    <xsl:sequence select="t:get-nested-expression($left)"/>
    <xsl:sequence select="' '"/>
    <xsl:sequence select="'=='"/>
    <xsl:sequence select="' '"/>
    <xsl:sequence select="t:get-nested-expression($right)"/>
  </xsl:template>

  <!-- Mode "t:expression". ne. -->
  <xsl:template mode="t:expression" match="ne">
    <xsl:variable name="expressions" as="element()+"
      select="t:get-elements(.)"/>
    <xsl:variable name="left" as="element()" select="$expressions[1]"/>
    <xsl:variable name="right" as="element()" select="$expressions[2]"/>

    <xsl:sequence select="t:get-nested-expression($left)"/>
    <xsl:sequence select="' '"/>
    <xsl:sequence select="'!='"/>
    <xsl:sequence select="' '"/>
    <xsl:sequence select="t:get-nested-expression($right)"/>
  </xsl:template>

  <!-- Mode "t:expression". strict-eq. -->
  <xsl:template mode="t:expression" match="strict-eq">
    <xsl:variable name="expressions" as="element()+"
      select="t:get-elements(.)"/>
    <xsl:variable name="left" as="element()" select="$expressions[1]"/>
    <xsl:variable name="right" as="element()" select="$expressions[2]"/>

    <xsl:sequence select="t:get-nested-expression($left)"/>
    <xsl:sequence select="' '"/>
    <xsl:sequence select="'==='"/>
    <xsl:sequence select="' '"/>
    <xsl:sequence select="t:get-nested-expression($right)"/>
  </xsl:template>

  <!-- Mode "t:expression". strict-ne. -->
  <xsl:template mode="t:expression" match="strict-ne">
    <xsl:variable name="expressions" as="element()+"
      select="t:get-elements(.)"/>
    <xsl:variable name="left" as="element()" select="$expressions[1]"/>
    <xsl:variable name="right" as="element()" select="$expressions[2]"/>

    <xsl:sequence select="t:get-nested-expression($left)"/>
    <xsl:sequence select="' '"/>
    <xsl:sequence select="'!=='"/>
    <xsl:sequence select="' '"/>
    <xsl:sequence select="t:get-nested-expression($right)"/>
  </xsl:template>

  <!-- Mode "t:expression". lt. -->
  <xsl:template mode="t:expression" match="lt">
    <xsl:variable name="expressions" as="element()+"
      select="t:get-elements(.)"/>
    <xsl:variable name="left" as="element()" select="$expressions[1]"/>
    <xsl:variable name="right" as="element()" select="$expressions[2]"/>

    <xsl:sequence select="t:get-nested-expression($left)"/>
    <xsl:sequence select="' '"/>
    <xsl:sequence select="'&lt;'"/>
    <xsl:sequence select="' '"/>
    <xsl:sequence select="t:get-nested-expression($right)"/>
  </xsl:template>

  <!-- Mode "t:expression". gt. -->
  <xsl:template mode="t:expression" match="gt">
    <xsl:variable name="expressions" as="element()+"
      select="t:get-elements(.)"/>
    <xsl:variable name="left" as="element()" select="$expressions[1]"/>
    <xsl:variable name="right" as="element()" select="$expressions[2]"/>

    <xsl:sequence select="t:get-nested-expression($left)"/>
    <xsl:sequence select="' '"/>
    <xsl:sequence select="'&gt;'"/>
    <xsl:sequence select="' '"/>
    <xsl:sequence select="t:get-nested-expression($right)"/>
  </xsl:template>

  <!-- Mode "t:expression". le. -->
  <xsl:template mode="t:expression" match="le">
    <xsl:variable name="expressions" as="element()+"
      select="t:get-elements(.)"/>
    <xsl:variable name="left" as="element()" select="$expressions[1]"/>
    <xsl:variable name="right" as="element()" select="$expressions[2]"/>

    <xsl:sequence select="t:get-nested-expression($left)"/>
    <xsl:sequence select="' '"/>
    <xsl:sequence select="'&lt;='"/>
    <xsl:sequence select="' '"/>
    <xsl:sequence select="t:get-nested-expression($right)"/>
  </xsl:template>

  <!-- Mode "t:expression". ge. -->
  <xsl:template mode="t:expression" match="ge">
    <xsl:variable name="expressions" as="element()+"
      select="t:get-elements(.)"/>
    <xsl:variable name="left" as="element()" select="$expressions[1]"/>
    <xsl:variable name="right" as="element()" select="$expressions[2]"/>

    <xsl:sequence select="t:get-nested-expression($left)"/>
    <xsl:sequence select="' '"/>
    <xsl:sequence select="'&gt;='"/>
    <xsl:sequence select="' '"/>
    <xsl:sequence select="t:get-nested-expression($right)"/>
  </xsl:template>

  <!-- Mode "t:expression". instanceof. -->
  <xsl:template mode="t:expression" match="instanceof">
    <xsl:variable name="expressions" as="element()+"
      select="t:get-elements(.)"/>
    <xsl:variable name="left" as="element()" select="$expressions[1]"/>
    <xsl:variable name="right" as="element()" select="$expressions[2]"/>

    <xsl:sequence select="t:get-nested-expression($left)"/>
    <xsl:sequence select="' '"/>
    <xsl:sequence select="'instanceof'"/>
    <xsl:sequence select="' '"/>
    <xsl:sequence select="t:get-nested-expression($right)"/>
  </xsl:template>

  <!-- Mode "t:expression". in. -->
  <xsl:template mode="t:expression" match="in">
    <xsl:variable name="expressions" as="element()+"
      select="t:get-elements(.)"/>
    <xsl:variable name="left" as="element()" select="$expressions[1]"/>
    <xsl:variable name="right" as="element()" select="$expressions[2]"/>

    <xsl:sequence select="t:get-nested-expression($left)"/>
    <xsl:sequence select="' '"/>
    <xsl:sequence select="'in'"/>
    <xsl:sequence select="' '"/>
    <xsl:sequence select="t:get-nested-expression($right)"/>
  </xsl:template>

  <!-- Mode "t:expression". left-shift. -->
  <xsl:template mode="t:expression" match="left-shift">
    <xsl:variable name="expressions" as="element()+"
      select="t:get-elements(.)"/>
    <xsl:variable name="left" as="element()" select="$expressions[1]"/>
    <xsl:variable name="right" as="element()" select="$expressions[2]"/>

    <xsl:sequence select="t:get-nested-expression($left)"/>
    <xsl:sequence select="' '"/>
    <xsl:sequence select="'&lt;&lt;'"/>
    <xsl:sequence select="' '"/>
    <xsl:sequence select="t:get-nested-expression($right)"/>
  </xsl:template>

  <!-- Mode "t:expression". right-shift. -->
  <xsl:template mode="t:expression" match="right-shift">
    <xsl:variable name="expressions" as="element()+"
      select="t:get-elements(.)"/>
    <xsl:variable name="left" as="element()" select="$expressions[1]"/>
    <xsl:variable name="right" as="element()" select="$expressions[2]"/>

    <xsl:sequence select="t:get-nested-expression($left)"/>
    <xsl:sequence select="' '"/>
    <xsl:sequence select="'&gt;&gt;'"/>
    <xsl:sequence select="' '"/>
    <xsl:sequence select="t:get-nested-expression($right)"/>
  </xsl:template>

  <!-- Mode "t:expression". unsigned-right-shift. -->
  <xsl:template mode="t:expression" match="unsigned-right-shift">
    <xsl:variable name="expressions" as="element()+"
      select="t:get-elements(.)"/>
    <xsl:variable name="left" as="element()" select="$expressions[1]"/>
    <xsl:variable name="right" as="element()" select="$expressions[2]"/>

    <xsl:sequence select="t:get-nested-expression($left)"/>
    <xsl:sequence select="' '"/>
    <xsl:sequence select="'&gt;&gt;&gt;'"/>
    <xsl:sequence select="' '"/>
    <xsl:sequence select="t:get-nested-expression($right)"/>
  </xsl:template>

  <!-- Mode "t:expression". add. -->
  <xsl:template mode="t:expression" match="add">
    <xsl:variable name="expressions" as="element()+"
      select="t:get-elements(.)"/>
    <xsl:variable name="left" as="element()" select="$expressions[1]"/>
    <xsl:variable name="right" as="element()" select="$expressions[2]"/>

    <xsl:sequence select="t:get-nested-expression($left)"/>
    <xsl:sequence select="' '"/>
    <xsl:sequence select="'+'"/>
    <xsl:sequence select="' '"/>
    <xsl:sequence select="t:get-nested-expression($right)"/>
  </xsl:template>

  <!-- Mode "t:expression". sub. -->
  <xsl:template mode="t:expression" match="sub">
    <xsl:variable name="expressions" as="element()+"
      select="t:get-elements(.)"/>
    <xsl:variable name="left" as="element()" select="$expressions[1]"/>
    <xsl:variable name="right" as="element()" select="$expressions[2]"/>

    <xsl:sequence select="t:get-nested-expression($left)"/>
    <xsl:sequence select="' '"/>
    <xsl:sequence select="'-'"/>
    <xsl:sequence select="' '"/>
    <xsl:sequence select="t:get-nested-expression($right)"/>
  </xsl:template>

  <!-- Mode "t:expression". mul. -->
  <xsl:template mode="t:expression" match="mul">
    <xsl:variable name="expressions" as="element()+"
      select="t:get-elements(.)"/>
    <xsl:variable name="left" as="element()" select="$expressions[1]"/>
    <xsl:variable name="right" as="element()" select="$expressions[2]"/>

    <xsl:sequence select="t:get-nested-expression($left)"/>
    <xsl:sequence select="' '"/>
    <xsl:sequence select="'*'"/>
    <xsl:sequence select="' '"/>
    <xsl:sequence select="t:get-nested-expression($right)"/>
  </xsl:template>

  <!-- Mode "t:expression". div. -->
  <xsl:template mode="t:expression" match="div">
    <xsl:variable name="expressions" as="element()+"
      select="t:get-elements(.)"/>
    <xsl:variable name="left" as="element()" select="$expressions[1]"/>
    <xsl:variable name="right" as="element()" select="$expressions[2]"/>

    <xsl:sequence select="t:get-nested-expression($left)"/>
    <xsl:sequence select="' '"/>
    <xsl:sequence select="'/'"/>
    <xsl:sequence select="' '"/>
    <xsl:sequence select="t:get-nested-expression($right)"/>
  </xsl:template>

  <!-- Mode "t:expression". mod. -->
  <xsl:template mode="t:expression" match="mod">
    <xsl:variable name="expressions" as="element()+"
      select="t:get-elements(.)"/>
    <xsl:variable name="left" as="element()" select="$expressions[1]"/>
    <xsl:variable name="right" as="element()" select="$expressions[2]"/>

    <xsl:sequence select="t:get-nested-expression($left)"/>
    <xsl:sequence select="' '"/>
    <xsl:sequence select="'%'"/>
    <xsl:sequence select="' '"/>
    <xsl:sequence select="t:get-nested-expression($right)"/>
  </xsl:template>

  <!-- Mode "t:expression". delete. -->
  <xsl:template mode="t:expression" match="delete">
    <xsl:variable name="expression" as="element()" select="t:get-elements(.)"/>

    <xsl:sequence select="'delete'"/>
    <xsl:sequence select="' '"/>
    <xsl:sequence select="t:get-nested-expression($expression)"/>
  </xsl:template>

  <!-- Mode "t:expression". void. -->
  <xsl:template mode="t:expression" match="void">
    <xsl:variable name="expression" as="element()" select="t:get-elements(.)"/>

    <xsl:sequence select="'void'"/>
    <xsl:sequence select="' '"/>
    <xsl:sequence select="t:get-nested-expression($expression)"/>
  </xsl:template>

  <!-- Mode "t:expression". typeof. -->
  <xsl:template mode="t:expression" match="typeof">
    <xsl:variable name="expression" as="element()" select="t:get-elements(.)"/>

    <xsl:sequence select="'typeof'"/>
    <xsl:sequence select="' '"/>
    <xsl:sequence select="t:get-nested-expression($expression)"/>
  </xsl:template>

  <!-- Mode "t:expression". inc. -->
  <xsl:template mode="t:expression" match="inc">
    <xsl:variable name="expression" as="element()" select="t:get-elements(.)"/>

    <xsl:sequence select="'++'"/>
    <xsl:sequence select="t:get-nested-expression($expression)"/>
  </xsl:template>

  <!-- Mode "t:expression". dec. -->
  <xsl:template mode="t:expression" match="dec">
    <xsl:variable name="expression" as="element()" select="t:get-elements(.)"/>

    <xsl:sequence select="'--'"/>
    <xsl:sequence select="t:get-nested-expression($expression)"/>
  </xsl:template>

  <!-- Mode "t:expression". plus. -->
  <xsl:template mode="t:expression" match="plus">
    <xsl:variable name="expression" as="element()" select="t:get-elements(.)"/>

    <xsl:sequence select="'+'"/>
    <xsl:sequence select="t:get-nested-expression($expression)"/>
  </xsl:template>

  <!-- Mode "t:expression". neg. -->
  <xsl:template mode="t:expression" match="neg">
    <xsl:variable name="expression" as="element()" select="t:get-elements(.)"/>

    <xsl:sequence select="'-'"/>
    <xsl:sequence select="t:get-nested-expression($expression)"/>
  </xsl:template>

  <!-- Mode "t:expression". inv. -->
  <xsl:template mode="t:expression" match="inv">
    <xsl:variable name="expression" as="element()" select="t:get-elements(.)"/>

    <xsl:sequence select="'~'"/>
    <xsl:sequence select="t:get-nested-expression($expression)"/>
  </xsl:template>

  <!-- Mode "t:expression". not. -->
  <xsl:template mode="t:expression" match="not">
    <xsl:variable name="expression" as="element()" select="t:get-elements(.)"/>

    <xsl:sequence select="'!'"/>
    <xsl:sequence select="t:get-nested-expression($expression)"/>
  </xsl:template>

  <!-- Mode "t:expression". post-inc. -->
  <xsl:template mode="t:expression" match="post-inc">
    <xsl:variable name="expression" as="element()" select="t:get-elements(.)"/>

    <xsl:sequence select="t:get-nested-expression($expression)"/>
    <xsl:sequence select="'++'"/>
  </xsl:template>

  <!-- Mode "t:expression". post-dec. -->
  <xsl:template mode="t:expression" match="post-dec">
    <xsl:variable name="expression" as="element()" select="t:get-elements(.)"/>

    <xsl:sequence select="t:get-nested-expression($expression)"/>
    <xsl:sequence select="'--'"/>
  </xsl:template>

  <!-- Mode "t:expression t:lefthand-side-expression". subscript. -->
  <xsl:template match="subscript"
    mode="t:expression t:lefthand-side-expression">
    <xsl:variable name="elements" as="element()+"
      select="t:get-elements(.)"/>
    <xsl:variable name="object" as="element()" select="$elements[1]"/>
    <xsl:variable name="subscript" as="element()"
      select="subsequence($elements, 2)"/>

    <xsl:sequence select="t:get-nested-expression($object)"/>
    <xsl:sequence select="'['"/>
    <xsl:sequence select="t:get-expression($subscript)"/>
    <xsl:sequence select="']'"/>
  </xsl:template>
  
  <xs:element name="tag" type="tag"/>
  <xs:element name="new-target" type="expression"/>
  <xs:element name="new" type="call"/>
  <xs:element name="call" type="call"/>
  <xs:element name="yield" type="yield"/>
  <xs:element name="arrow-function" type="arrow-function"/>
  
  
  <xs:element name="assign" type="assignment-expression"/>
  <xs:element name="mul-to" type="assignment-expression"/>
  <xs:element name="div-by" type="assignment-expression"/>
  <xs:element name="mod-by" type="assignment-expression"/>
  <xs:element name="add-to" type="assignment-expression"/>
  <xs:element name="sub-from" type="assignment-expression"/>
  <xs:element name="left-shift-by" type="assignment-expression"/>
  <xs:element name="right-shift-by" type="assignment-expression"/>
  <xs:element name="unsigned-right-shift-by" type="assignment-expression"/>
  <xs:element name="and-with" type="assignment-expression"/>
  <xs:element name="xor-with" type="assignment-expression"/>
  <xs:element name="or-with" type="assignment-expression"/>

  <xs:element name="spread" type="spread" contexts="array arguments"/>

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

</xsl:stylesheet>