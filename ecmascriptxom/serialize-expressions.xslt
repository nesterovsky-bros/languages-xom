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

  <!-- Mode "t:binding-pattern". Default match. -->
  <xsl:template match="*"
    mode="t:binding-pattern t:binding-pattern-content t:binding-property">
    <xsl:sequence select="
      error
      (
        xs:QName('invalid-pattern'),
        concat('Invalid pattern. ', t:get-path(.)),
        .
      )"/>
  </xsl:template>

  <!-- Mode "t:binding-pattern". pattern. -->
  <xsl:template mode="t:binding-pattern" match="pattern">
    <xsl:apply-templates mode="t:binding-pattern-content"/>
  </xsl:template>

  <!-- Mode "t:binding-pattern". object. -->
  <xsl:template mode="t:binding-pattern-content" match="object">
    <xsl:sequence select="'{'"/>
    <xsl:sequence select="' '"/>

    <xsl:for-each select="t:get-elements(.)">
      <xsl:sequence select="t:get-comments(.)"/>
      <xsl:apply-templates mode="t:binding-property" select="."/>

      <xsl:if test="position() != last()">
        <xsl:sequence select="','"/>
      </xsl:if>

      <xsl:sequence select="' '"/>
    </xsl:for-each>

    <xsl:sequence select="'}'"/>
  </xsl:template>

  <!-- Mode "t:binding-property" property. -->
  <xsl:template mode="t:binding-property" match="property">
    <xsl:variable name="name" as="element()" select="name"/>
    <xsl:variable name="initialize" as="element()?" select="initialize"/>
    <xsl:variable name="value" as="element()?"
      select="t:get-elements(.) except ($name, $initialize)"/>

    <xsl:apply-templates mode="t:property-name" select="$name"/>

    <xsl:if test="not($name/@value) and not($value)">
      <xsl:sequence select="
        error
        (
          xs:QName('invalid-property-value'),
          concat('Property value is expected. ', t:get-path(.)),
          .
        )"/>
    </xsl:if>

    <xsl:if test="$value">
      <xsl:sequence select="':'"/>
      <xsl:sequence select="' '"/>

      <xsl:choose>
        <xsl:when test="$value[self::ref]">
          <xsl:sequence select="t:get-nested-expression($value)"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:apply-templates mode="t:binding-pattern-content"
            select="$value"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:if>

    <xsl:if test="$initialize">
      <xsl:sequence select="' '"/>
      <xsl:sequence select="'='"/>
      <xsl:sequence select="' '"/>
      <xsl:sequence
        select="t:get-nested-expression(t:get-elements($initialize))"/>
    </xsl:if>
  </xsl:template>

  <!-- Mode "t:binding-pattern". array. -->
  <xsl:template mode="t:binding-pattern-content" match="array">
    <xsl:sequence select="'['"/>

    <xsl:for-each select="t:get-elements(.)">
      <xsl:choose>
        <xsl:when test="self::ref">
          <xsl:sequence select="t:get-nested-expression(.)"/>
        </xsl:when>
        <xsl:when test="self::elision">
          <!-- Do nothing. -->
        </xsl:when>
        <xsl:when test="self::spread">
          <xsl:sequence select="'...'"/>
          <xsl:sequence select="t:get-nested-expression(ref)"/>
        </xsl:when>
        <xsl:when test="self::element">
          <xsl:variable name="initialize" as="element()" select="initialize"/>
          <xsl:variable name="name" as="element()"
            select="t:get-elements(.) except $initialize"/>

          <xsl:choose>
            <xsl:when test="$name[self::ref]">
              <xsl:sequence select="t:get-nested-expression($name)"/>
            </xsl:when>
            <xsl:otherwise>
              <xsl:apply-templates mode="#current" select="$name"/>
            </xsl:otherwise>
          </xsl:choose>

          <xsl:if test="$initialize">
            <xsl:sequence select="' '"/>
            <xsl:sequence select="'='"/>
            <xsl:sequence select="' '"/>
            <xsl:sequence
              select="t:get-nested-expression(t:get-elements($initialize))"/>
          </xsl:if>
        </xsl:when>
        <xsl:otherwise>
          <xsl:apply-templates mode="#current" select="."/>
        </xsl:otherwise>
      </xsl:choose>

      <xsl:if test="position() != last()">
        <xsl:sequence select="','"/>
        <xsl:sequence select="' '"/>
      </xsl:if>
    </xsl:for-each>

    <xsl:sequence select="']'"/>
  </xsl:template>

  <!-- Mode "t:expression". Default match. -->
  <xsl:template mode="t:expression" match="*">
    <xsl:sequence select="
      error
      (
        xs:QName('invalid-expression'),
        concat('Invalid expression. ', t:get-path(.)),
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
    <xsl:variable name="form" as="xs:string?" select="@form"/>

    <xsl:choose>
      <xsl:when test="$form = 'binary'">
        <xsl:sequence 
          select="concat('0b', t:integer-to-string(xs:integer($value), 2))"/>
      </xsl:when>
      <xsl:when test="$form = 'octal'">
        <xsl:sequence 
          select="concat('0o', t:integer-to-string(xs:integer($value), 8))"/>
      </xsl:when>
      <xsl:when test="$form = 'hex'">
        <xsl:sequence 
          select="concat('0x', t:integer-to-string(xs:integer($value), 16))"/>
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
              <xsl:analyze-string select="." regex="\.|[`$\\]">
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

      <xsl:choose>
        <xsl:when test="self::function">
          <xsl:sequence select="$t:new-line"/>
        </xsl:when>
        <xsl:when test="position() != last()">
          <xsl:sequence select="','"/>
          <xsl:sequence select="' '"/>
        </xsl:when>
      </xsl:choose>

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
          concat
          (
            'Property name is required either in the form of identifier, ',
            'string, number or expression. ',
            t:get-path(.)
          ),
          .
        )"/>
    </xsl:if>

    <xsl:choose>
      <xsl:when test="$name">
        <xsl:sequence select="$name"/>
      </xsl:when>
      <xsl:when test="$expression[self::number or self::string]">
        <xsl:sequence select="t:get-nested-expression(t:get-elements(.))"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:sequence select="'['"/>
        <xsl:sequence select="t:get-nested-expression(t:get-elements(.))"/>
        <xsl:sequence select="']'"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template mode="t:object-member t:class-method" match="scope">
    <xsl:sequence select="$t:new-line"/>

    <xsl:for-each select="t:get-elements(.)">
      <xsl:sequence select="t:get-comments(.)"/>
      <xsl:apply-templates mode="#current" select="."/>

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
    <xsl:variable name="name" as="element()" select="name"/>
    <xsl:variable name="value" as="element()?"
      select="t:get-elements(.) except $name"/>

    <xsl:apply-templates mode="t:property-name" select="$name"/>

    <xsl:if test="not($name/@value) and not($value)">
      <xsl:sequence select="
        error
        (
          xs:QName('invalid-property-value'),
          concat('Property value is expected. ', t:get-path(.)),
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
    Mode "t:object-member t:method-definition t:declaration t:statement
      t:module-declaration t:module-item t:expression" 
    function.
  -->
  <xsl:template match="function" mode="
    t:object-member 
    t:method-definition 
    t:class-method
    t:declaration 
    t:statement
    t:module-declaration 
    t:module-item
    t:expression">

    <xsl:variable name="export" as="xs:string?" select="@export"/>
    <xsl:variable name="static" as="xs:boolean?" select="@static"/>
    <xsl:variable name="generator" as="xs:boolean?" select="@generator"/>
    <xsl:variable name="type" as="xs:string?" select="@type"/>
    <xsl:variable name="name" as="element()?" select="name"/>
    <xsl:variable name="parameters" as="element()*" select="parameter"/>
    <xsl:variable name="rest-parameter" as="element()*"
      select="rest-parameter"/>
    <xsl:variable name="body" as="element()?" select="body"/>

    <xsl:choose>
      <xsl:when test="$export = 'true'">
        <xsl:sequence select="'export'"/>
        <xsl:sequence select="' '"/>
      </xsl:when>
      <xsl:when test="$export = 'default'">
        <xsl:sequence select="'export'"/>
        <xsl:sequence select="' '"/>
        <xsl:sequence select="'default'"/>
        <xsl:sequence select="' '"/>
      </xsl:when>
    </xsl:choose>

    <xsl:if test="$static">
      <xsl:sequence select="'static'"/>
      <xsl:sequence select="' '"/>
    </xsl:if>

    <xsl:choose>
      <xsl:when test="$type = 'get'">
        <xsl:sequence select="'get'"/>
        <xsl:sequence select="' '"/>
        <xsl:sequence select="'function'"/>
      </xsl:when>
      <xsl:when test="$type = 'set'">
        <xsl:sequence select="'set'"/>
        <xsl:sequence select="' '"/>
        <xsl:sequence select="'function'"/>
      </xsl:when>
      <xsl:when test="$generator">
        <xsl:sequence select="'function'"/>
        <xsl:sequence select="'*'"/>
      </xsl:when>
    </xsl:choose>

    <xsl:if test="$name">
      <xsl:sequence select="' '"/>
      <xsl:sequence select="string($name/@value)"/>
    </xsl:if>

    <xsl:sequence select="'('"/>

    <xsl:for-each select="$parameters">
      <xsl:variable name="initialize" as="element()?" select="initialize"/>
      <xsl:variable name="parameter-name" as="element()?" select="name"/>

      <xsl:choose>
        <xsl:when test="$parameter-name">
          <xsl:sequence select="string(@value)"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:variable name="pattern" as="element()" select="pattern"/>

          <xsl:apply-templates mode="t:binding-pattern" select="$pattern"/>
        </xsl:otherwise>
      </xsl:choose>

      <xsl:if test="$initialize">
        <xsl:sequence select="' '"/>
        <xsl:sequence select="'='"/>
        <xsl:sequence select="' '"/>
        <xsl:sequence
          select="t:get-nested-expression(t:get-elements($initialize))"/>
      </xsl:if>

      <xsl:if test="$rest-parameter or (position() != last())">
        <xsl:sequence select="','"/>
        <xsl:sequence select="' '"/>
      </xsl:if>
    </xsl:for-each>

    <xsl:for-each select="$rest-parameter">
      <xsl:variable name="parameter-name" as="element()" select="name"/>

      <xsl:sequence select="'...'"/>
      <xsl:sequence select="string(@value)"/>
    </xsl:for-each>
    
    <xsl:sequence select="')'"/>
    <xsl:sequence select="$t:new-line"/>
    <xsl:apply-templates mode="t:statement" select="$body"/>
  </xsl:template>

  <!-- 
    Mode "t:expression" arrow-function.
  -->
  <xsl:template match="arrow-function" mode="t:expression">
    <xsl:variable name="parameters" as="element()*" select="parameter"/>
    <xsl:variable name="rest-parameter" as="element()*"
      select="rest-parameter"/>
    <xsl:variable name="body" as="element()?" select="body"/>
    <xsl:variable name="expression" as="element()?" select="expression"/>

    <xsl:variable name="simple-parameters" as="xs:boolean" select="
      not($rest-parameter) and (count($parameters) = 1) and $parameters/name"/>
  
    <xsl:if test="$simple-parameters">
       <xsl:sequence select="'('"/>
    </xsl:if>

    <xsl:for-each select="$parameters">
      <xsl:variable name="parameter-name" as="element()?" select="name"/>

      <xsl:choose>
        <xsl:when test="$parameter-name">
          <xsl:sequence select="string(@value)"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:variable name="pattern" as="element()" select="pattern"/>

          <xsl:apply-templates mode="t:binding-pattern" select="$pattern"/>
        </xsl:otherwise>
      </xsl:choose>

      <xsl:if test="$rest-parameter or (position() != last())">
        <xsl:sequence select="','"/>
        <xsl:sequence select="' '"/>
      </xsl:if>
    </xsl:for-each>

    <xsl:for-each select="$rest-parameter">
      <xsl:variable name="parameter-name" as="element()" select="name"/>

      <xsl:sequence select="'...'"/>
      <xsl:sequence select="string(@value)"/>
    </xsl:for-each>

    <xsl:if test="$simple-parameters">
       <xsl:sequence select="')'"/>
    </xsl:if>
    
    <xsl:sequence select="' '"/>
    <xsl:sequence select="'=>'"/>
  
    <xsl:choose>
      <xsl:when test="$body">
        <xsl:sequence select="$t:new-line"/>
        <xsl:apply-templates mode="t:statement" select="$body"/>
      </xsl:when>
      <xsl:when test="$expression/object">
        <xsl:sequence select="' '"/>
        <xsl:sequence select="'('"/>
        <xsl:sequence 
          select="t:get-nested-expression(t:get-elements($expression))"/>
        <xsl:sequence select="')'"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:sequence select="' '"/>
        <xsl:sequence 
          select="t:get-nested-expression(t:get-elements($expression))"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!-- 
    Mode "t:declaration t:statement t:module-declaration 
      t:module-item t:expression" class. 
  -->
  <xsl:template match="class" mode="
    t:declaration 
    t:statement 
    t:module-declaration 
    t:module-item 
    t:expression">
    <xsl:variable name="name" as="element()?" select="name"/>
    <xsl:variable name="extends" as="element()?" select="extends"/>
    <xsl:variable name="members" as="element()*" 
      select="t:get-elements(.) except ($name, $extends)"/>
  
    <xsl:sequence select="t:get-comments(.)"/>
    <xsl:sequence select="'class'"/>
    
    <xsl:if test="$name">
      <xsl:sequence select="' '"/>
      <xsl:sequence select="string($name/@value)"/>
    </xsl:if>

    <xsl:sequence select="$t:new-line"/>
    <xsl:sequence select="'{'"/>
    <xsl:sequence select="$t:new-line"/>
    <xsl:sequence select="$t:indent"/>
    
    <xsl:for-each select="$members">
      <xsl:sequence select="t:get-comments(.)"/>
      <xsl:apply-templates mode="t:class-method" select="."/>
      <xsl:sequence select="$t:new-line"/>
    </xsl:for-each>
    
    <xsl:sequence select="$t:unindent"/>
    <xsl:sequence select="'}'"/>
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
    <xsl:sequence select="t:get-nested-expression($subscript)"/>
    <xsl:sequence select="']'"/>
  </xsl:template>

  <!-- Mode "t:expression". tag. -->
  <xsl:template match="tag" mode="t:expression">
    <xsl:variable name="template" as="element()" select="template"/>
    <xsl:variable name="expression" as="element()"
      select="t:get-elements(.) except $template"/>

    <xsl:sequence select="t:get-nested-expression($expression)"/>
    <xsl:sequence select="t:get-nested-expression($template)"/>
  </xsl:template>

  <!-- Mode "t:expression". new-target. -->
  <xsl:template match="new-target" mode="t:expression">
    <xsl:sequence select="new"/>
    <xsl:sequence select="."/>
    <xsl:sequence select="target"/>
  </xsl:template>

  <!-- Mode "t:expression". new, call. -->
  <xsl:template match="new | call" mode="t:expression">
    <xsl:variable name="is-new" as="xs:boolean" select="exists(self::new)"/>
    <xsl:variable name="elements" as="element()+"
      select="t:get-elements(.)"/>
    <xsl:variable name="name" as="element()" select="$elements[1]"/>
    <xsl:variable name="arguments" as="element()*"
      select="subsequence($elements, 2)"/>

    <xsl:if test="$is-new">
      <xsl:sequence select="'new'"/>
      <xsl:sequence select="' '"/>
    </xsl:if>

    <xsl:sequence select="t:get-nested-expression($name)"/>

    <xsl:if test="not($is-new) or exists($arguments)">
      <xsl:sequence select="'('"/>

      <xsl:for-each select="$arguments">
        <xsl:choose>
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
          <xsl:sequence select="$t:soft-line-break"/>
        </xsl:if>
      </xsl:for-each>

      <xsl:sequence select="')'"/>
    </xsl:if>
  </xsl:template>

  <!-- Mode "t:expression". yield. -->
  <xsl:template match="yield" mode="t:expression">
    <xsl:variable name="expression" as="element()?"
      select="t:get-elements(.)"/>
    <xsl:variable name="delegate" as="xs:boolean" select="@delegate"/>

    <xsl:if test="$delegate and not($expression)">
      <xsl:sequence select="
        error
        (
          xs:QName('invalid-yield-expression'),
          concat('Yield argument is expected. ', t:get-path(.)),
          .
        )"/>
    </xsl:if>

    <xsl:sequence select="'yield'"/>

    <xsl:if test="$delegate">
      <xsl:sequence select="*"/>
    </xsl:if>

    <xsl:sequence select="'&#160;'"/>
    <xsl:sequence select="t:get-nested-expression($expression)"/>
  </xsl:template>

  <!-- Mode "t:expression". assign. -->
  <xsl:template match="assign" mode="t:expression">
    <xsl:variable name="expressions" as="element()+"
      select="t:get-elements(.)"/>
    <xsl:variable name="left" as="element()" select="$expressions[1]"/>
    <xsl:variable name="right" as="element()" select="$expressions[2]"/>

    <xsl:choose>
      <xsl:when test="$left[self::pattern]">
        <xsl:apply-templates mode="t:binding-pattern" select="$left"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:apply-templates mode="t:lefthand-side-expression" select="$left"/>
      </xsl:otherwise>
    </xsl:choose>

    <xsl:sequence select="' '"/>
    <xsl:sequence select="'='"/>
    <xsl:sequence select="' '"/>
    <xsl:sequence select="t:get-nested-expression($right)"/>
  </xsl:template>

  <!-- Mode "t:expression". mul-to. -->
  <xsl:template match="mul-to" mode="t:expression">
    <xsl:variable name="expressions" as="element()+"
      select="t:get-elements(.)"/>
    <xsl:variable name="left" as="element()" select="$expressions[1]"/>
    <xsl:variable name="right" as="element()" select="$expressions[2]"/>

    <xsl:apply-templates mode="t:lefthand-side-expression" select="$left"/>
    <xsl:sequence select="' '"/>
    <xsl:sequence select="'*='"/>
    <xsl:sequence select="' '"/>
    <xsl:sequence select="t:get-nested-expression($right)"/>
  </xsl:template>

  <!-- Mode "t:expression". div-by. -->
  <xsl:template match="div-by" mode="t:expression">
    <xsl:variable name="expressions" as="element()+"
      select="t:get-elements(.)"/>
    <xsl:variable name="left" as="element()" select="$expressions[1]"/>
    <xsl:variable name="right" as="element()" select="$expressions[2]"/>

    <xsl:apply-templates mode="t:lefthand-side-expression" select="$left"/>
    <xsl:sequence select="' '"/>
    <xsl:sequence select="'/='"/>
    <xsl:sequence select="' '"/>
    <xsl:sequence select="t:get-nested-expression($right)"/>
  </xsl:template>

  <!-- Mode "t:expression". mod-by. -->
  <xsl:template match="mod-by" mode="t:expression">
    <xsl:variable name="expressions" as="element()+"
      select="t:get-elements(.)"/>
    <xsl:variable name="left" as="element()" select="$expressions[1]"/>
    <xsl:variable name="right" as="element()" select="$expressions[2]"/>

    <xsl:apply-templates mode="t:lefthand-side-expression" select="$left"/>
    <xsl:sequence select="' '"/>
    <xsl:sequence select="'%='"/>
    <xsl:sequence select="' '"/>
    <xsl:sequence select="t:get-nested-expression($right)"/>
  </xsl:template>

  <!-- Mode "t:expression". add-to. -->
  <xsl:template match="add-to" mode="t:expression">
    <xsl:variable name="expressions" as="element()+"
      select="t:get-elements(.)"/>
    <xsl:variable name="left" as="element()" select="$expressions[1]"/>
    <xsl:variable name="right" as="element()" select="$expressions[2]"/>

    <xsl:apply-templates mode="t:lefthand-side-expression" select="$left"/>
    <xsl:sequence select="' '"/>
    <xsl:sequence select="'+='"/>
    <xsl:sequence select="' '"/>
    <xsl:sequence select="t:get-nested-expression($right)"/>
  </xsl:template>

  <!-- Mode "t:expression". sub-from. -->
  <xsl:template match="sub-from" mode="t:expression">
    <xsl:variable name="expressions" as="element()+"
      select="t:get-elements(.)"/>
    <xsl:variable name="left" as="element()" select="$expressions[1]"/>
    <xsl:variable name="right" as="element()" select="$expressions[2]"/>

    <xsl:apply-templates mode="t:lefthand-side-expression" select="$left"/>
    <xsl:sequence select="' '"/>
    <xsl:sequence select="'-='"/>
    <xsl:sequence select="' '"/>
    <xsl:sequence select="t:get-nested-expression($right)"/>
  </xsl:template>


  <!-- Mode "t:expression". left-shift-by. -->
  <xsl:template match="left-shift-by" mode="t:expression">
    <xsl:variable name="expressions" as="element()+"
      select="t:get-elements(.)"/>
    <xsl:variable name="left" as="element()" select="$expressions[1]"/>
    <xsl:variable name="right" as="element()" select="$expressions[2]"/>

    <xsl:apply-templates mode="t:lefthand-side-expression" select="$left"/>
    <xsl:sequence select="' '"/>
    <xsl:sequence select="'&lt;&lt;='"/>
    <xsl:sequence select="' '"/>
    <xsl:sequence select="t:get-nested-expression($right)"/>
  </xsl:template>

  <!-- Mode "t:expression". right-shift-by. -->
  <xsl:template match="right-shift-by" mode="t:expression">
    <xsl:variable name="expressions" as="element()+"
      select="t:get-elements(.)"/>
    <xsl:variable name="left" as="element()" select="$expressions[1]"/>
    <xsl:variable name="right" as="element()" select="$expressions[2]"/>

    <xsl:apply-templates mode="t:lefthand-side-expression" select="$left"/>
    <xsl:sequence select="' '"/>
    <xsl:sequence select="'&gt;&gt;='"/>
    <xsl:sequence select="' '"/>
    <xsl:sequence select="t:get-nested-expression($right)"/>
  </xsl:template>

  <!-- Mode "t:expression". unsigned-right-shift-by. -->
  <xsl:template match="unsigned-right-shift-by" mode="t:expression">
    <xsl:variable name="expressions" as="element()+"
      select="t:get-elements(.)"/>
    <xsl:variable name="left" as="element()" select="$expressions[1]"/>
    <xsl:variable name="right" as="element()" select="$expressions[2]"/>

    <xsl:apply-templates mode="t:lefthand-side-expression" select="$left"/>
    <xsl:sequence select="' '"/>
    <xsl:sequence select="'&gt;&gt;&gt;='"/>
    <xsl:sequence select="' '"/>
    <xsl:sequence select="t:get-nested-expression($right)"/>
  </xsl:template>

  <!-- Mode "t:expression". and-with. -->
  <xsl:template match="and-with" mode="t:expression">
    <xsl:variable name="expressions" as="element()+"
      select="t:get-elements(.)"/>
    <xsl:variable name="left" as="element()" select="$expressions[1]"/>
    <xsl:variable name="right" as="element()" select="$expressions[2]"/>

    <xsl:apply-templates mode="t:lefthand-side-expression" select="$left"/>
    <xsl:sequence select="' '"/>
    <xsl:sequence select="'&amp;='"/>
    <xsl:sequence select="' '"/>
    <xsl:sequence select="t:get-nested-expression($right)"/>
  </xsl:template>

  <!-- Mode "t:expression". xor-with. -->
  <xsl:template match="xor-with" mode="t:expression">
    <xsl:variable name="expressions" as="element()+"
      select="t:get-elements(.)"/>
    <xsl:variable name="left" as="element()" select="$expressions[1]"/>
    <xsl:variable name="right" as="element()" select="$expressions[2]"/>

    <xsl:apply-templates mode="t:lefthand-side-expression" select="$left"/>
    <xsl:sequence select="' '"/>
    <xsl:sequence select="'~='"/>
    <xsl:sequence select="' '"/>
    <xsl:sequence select="t:get-nested-expression($right)"/>
  </xsl:template>

  <!-- Mode "t:expression". or-with. -->
  <xsl:template match="or-with" mode="t:expression">
    <xsl:variable name="expressions" as="element()+"
      select="t:get-elements(.)"/>
    <xsl:variable name="left" as="element()" select="$expressions[1]"/>
    <xsl:variable name="right" as="element()" select="$expressions[2]"/>

    <xsl:apply-templates mode="t:lefthand-side-expression" select="$left"/>
    <xsl:sequence select="' '"/>
    <xsl:sequence select="'|='"/>
    <xsl:sequence select="' '"/>
    <xsl:sequence select="t:get-nested-expression($right)"/>
  </xsl:template>

</xsl:stylesheet>