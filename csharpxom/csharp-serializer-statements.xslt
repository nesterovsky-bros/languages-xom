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

  <!-- Statements table. -->
  <xsl:variable name="t:statements">
    <statement name="label"/>
    <statement name="var"/>
    <statement name="block"/>
    <statement name="empty-statement"/>
    <statement name="expression"/>
    <statement name="if"/>
    <statement name="switch"/>
    <statement name="while"/>
    <statement name="do-while"/>
    <statement name="for"/>
    <statement name="for-each"/>
    <statement name="break"/>
    <statement name="continue"/>
    <statement name="goto"/>
    <statement name="throw"/>
    <statement name="return"/>
    <statement name="try"/>
    <statement name="lock"/>
    <statement name="using"/>
    <statement name="yield"/>
    <statement name="fixed"/>
    <statement name="snippet-statement"/>
  </xsl:variable>

  <!--
    Gets statement info by the name.
      $name - a statement name.
      Return statement info.
  -->
  <xsl:function name="t:get-statement-info" as="element()?">
    <xsl:param name="name" as="xs:string"/>

    <xsl:sequence
      select="key('t:name', $name, $t:statements)"/>
  </xsl:function>

  <!--
    Gets a sequence of tokens for a statement.
      $statement - a statment.
      Returns a sequence of tokens.
  -->
  <xsl:function name="t:get-statement" as="item()*">
    <xsl:param name="statement" as="element()"/>

    <xsl:apply-templates mode="t:statement" select="$statement">
      <xsl:with-param name="content-handler" tunnel="yes" as="element()">
        <t:statement/>
      </xsl:with-param>
    </xsl:apply-templates>
  </xsl:function>

  <!--
    Gets a sequence of tokens for a statement list.
      $statements - a statment list.
      Returns a sequence of tokens.
  -->
  <xsl:function name="t:get-statements" as="item()*">
    <xsl:param name="statements" as="element()*"/>

    <xsl:call-template name="t:get-statements">
      <xsl:with-param name="statements" select="$statements"/>
      <xsl:with-param name="content-handler" tunnel="yes" as="element()">
        <t:statement/>
      </xsl:with-param>
    </xsl:call-template>
  </xsl:function>

  <!--
    Gets a sequence of tokens for a statement list.
      $statements - a statment list.
      Returns a sequence of tokens.
  -->
  <xsl:template name="t:get-statements" as="item()*">
    <xsl:param name="statements" as="element()*"/>

    <xsl:for-each select="$statements">
      <xsl:variable name="index" as="xs:integer" select="position()"/>
      <xsl:variable name="next" as="element()?"
        select="$statements[$index + 1]"/>

      <xsl:variable name="tokens" as="item()*">
        <xsl:apply-templates mode="t:statement" select="."/>
      </xsl:variable>

      <xsl:if test="not(self::block or self::pp-region)">
        <xsl:sequence select="t:get-comments(.)"/>
      </xsl:if>

      <xsl:sequence select="$tokens"/>

      <xsl:if test="
        exists($next) and
        not
        (
          self::pp-region[xs:boolean(@implicit)][empty(t:get-elements(.))]
        ) and
        (
          not
          (
            (self::var and $next[self::var]) or
            (self::expression and $next[self::expression])
          ) or
          t:is-multiline($tokens) or
          exists($next/comment)
        )">
        <xsl:sequence select="$t:new-line"/>
      </xsl:if>
    </xsl:for-each>
  </xsl:template>

  <!--
    Gets a sequence of tokens for a block of statements.
      $comments - optional comments.
      $statements - a statment list.
      Returns a sequence of tokens.
  -->
  <xsl:template name="t:get-statements-block" as="item()+">
    <xsl:param name="comments" as="element()*"/>
    <xsl:param name="statements" as="element()*"/>

    <xsl:choose>
      <xsl:when test="
        empty($comments) and
        (count($statements) = 1) and
        exists($statements[self::block[not(@type)]])">
        <xsl:call-template name="t:get-statements">
          <xsl:with-param name="statements" select="$statements"/>
        </xsl:call-template>
      </xsl:when>
      <xsl:otherwise>
        <xsl:sequence select="'{'"/>
        <xsl:sequence select="$t:new-line"/>
        <xsl:sequence select="$t:indent"/>

        <xsl:sequence select="$comments/t:get-comment(.)"/>

        <xsl:call-template name="t:get-statements">
          <xsl:with-param name="statements" select="$statements"/>
        </xsl:call-template>

        <xsl:sequence select="$t:unindent"/>
        <xsl:sequence select="'}'"/>
        <xsl:sequence select="$t:new-line"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!-- A content handler for the unit-declaration. -->
  <xsl:template mode="t:call" match="t:statement">
    <xsl:param name="content" as="element()*"/>

    <xsl:call-template name="t:get-statements">
      <xsl:with-param name="statements" select="$content"/>
    </xsl:call-template>
  </xsl:template>

  <!-- Mode "t:statement". Default match. -->
  <xsl:template mode="t:statement" match="*">
    <xsl:sequence select="
      error
      (
        xs:QName('invalid-statement'),
        'Invalid statement',
        .
      )"/>
  </xsl:template>

  <!--  Mode "t:statement". block. -->
  <xsl:template mode="t:statement" match="block">
    <xsl:variable name="type" as="xs:string?" select="@type"/>

    <xsl:choose>
      <xsl:when test="not($type)">
        <!-- Regular block. -->
      </xsl:when>
      <xsl:when test="$type = ('unsafe', 'checked', 'unchecked')">
        <xsl:sequence select="$type"/>
        <xsl:sequence select="$t:new-line"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:sequence select="
          error
          (
            xs:QName('invalid-block-type'),
            'Invalid block type',
            .
          )"/>
      </xsl:otherwise>
    </xsl:choose>

    <xsl:call-template name="t:get-statements-block">
      <xsl:with-param name="comments" select="comment"/>
      <xsl:with-param name="statements" select="t:get-elements(.)"/>
    </xsl:call-template>
  </xsl:template>

  <!-- Mode "t:statement". labeled-statement. -->
  <xsl:template mode="t:statement" match="label">
    <xsl:variable name="name" as="xs:string" select="@name"/>
    <xsl:variable name="statements" as="element()+"
      select="t:get-elements(.)"/>

    <xsl:sequence select="$t:line-indent"/>
    <xsl:sequence select="$name"/>
    <xsl:sequence select="':'"/>
    <xsl:sequence select="$t:new-line"/>

    <xsl:call-template name="t:get-statements">
      <xsl:with-param name="statements" select="$statements"/>
    </xsl:call-template>
  </xsl:template>

  <!-- Mode "t:statement". snippet-statement. -->
  <xsl:template mode="t:statement" match="snippet-statement">
    <xsl:variable name="statement" as="xs:string?" select="@value"/>

    <xsl:if test="$statement">
      <xsl:sequence select="$statement"/>
      <xsl:sequence select="$t:new-line"/>
    </xsl:if>
  </xsl:template>

  <!-- Mode "t:statement". empty-statement. -->
  <xsl:template mode="t:statement" match="empty-statement">
    <xsl:sequence select="';'"/>
    <xsl:sequence select="$t:new-line"/>
  </xsl:template>

  <!-- Mode "t:statement". declaration-statement. -->
  <xsl:template mode="t:statement" match="var">
    <xsl:variable name="name" as="xs:string" select="@name"/>
    <xsl:variable name="const" as="xs:boolean?" select="@const"/>
    <xsl:variable name="type" as="element()?" select="type"/>
    <xsl:variable name="initializer" as="element()?" select="initialize"/>

    <xsl:choose>
      <xsl:when test="$const">
        <xsl:sequence select="'const'"/>
        <xsl:sequence select="' '"/>
        <xsl:sequence select="t:get-type($type)"/>
      </xsl:when>
      <xsl:when test="exists($type)">
        <xsl:sequence select="t:get-type($type)"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:sequence select="'var'"/>
      </xsl:otherwise>
    </xsl:choose>

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

  <!-- Mode "t:statement". expression-statement. -->
  <xsl:template mode="t:statement" match="expression">
    <xsl:variable name="expression" as="element()" select="t:get-elements(.)"/>

    <xsl:sequence select="t:get-statement-expression($expression)"/>
    <xsl:sequence select="';'"/>
    <xsl:sequence select="$t:new-line"/>
  </xsl:template>

  <!-- Mode "t:statement". if-statement. -->
  <xsl:template mode="t:statement" match="if">
    <xsl:variable name="condition" as="element()" select="condition"/>
    <xsl:variable name="then" as="element()" select="then"/>
    <xsl:variable name="else" as="element()?" select="else"/>

    <xsl:sequence select="'if'"/>
    <xsl:sequence select="' '"/>
    <xsl:sequence select="'('"/>
    <xsl:sequence select="t:get-expression(t:get-elements($condition))"/>
    <xsl:sequence select="')'"/>
    <xsl:sequence select="$t:new-line"/>

    <xsl:call-template name="t:get-statements-block">
      <xsl:with-param name="comments" select="$then/comment"/>
      <xsl:with-param name="statements" select="t:get-elements($then)"/>
    </xsl:call-template>

    <xsl:if test="exists($else)">
      <xsl:variable name="else-statements" as="element()*"
        select="t:get-elements($else)"/>

      <xsl:sequence select="'else'"/>

      <xsl:choose>
        <xsl:when test="
          (count($else-statements) = 1) and
          exists($else-statements[self::if[empty(comment)]])">
          <xsl:sequence select="' '"/>

          <xsl:call-template name="t:get-statements">
            <xsl:with-param name="statements" select="$else-statements"/>
          </xsl:call-template>
        </xsl:when>
        <xsl:otherwise>
          <xsl:sequence select="$t:new-line"/>

          <xsl:call-template name="t:get-statements-block">
            <xsl:with-param name="comments" select="$else/comment"/>
            <xsl:with-param name="statements" select="$else-statements"/>
          </xsl:call-template>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:if>
  </xsl:template>

  <!-- Mode "t:statement". switch-statement. -->
  <xsl:template mode="t:statement" match="switch">
    <xsl:variable name="test" as="element()" select="test"/>
    <xsl:variable name="cases" as="element()+" select="case"/>

    <xsl:sequence select="'switch'"/>
    <xsl:sequence select="'('"/>
    <xsl:sequence select="t:get-expression(t:get-elements($test))"/>
    <xsl:sequence select="')'"/>
    <xsl:sequence select="$t:new-line"/>
    <xsl:sequence select="'{'"/>
    <xsl:sequence select="$t:new-line"/>
    <xsl:sequence select="$t:indent"/>

    <xsl:for-each select="$cases">
      <xsl:variable name="values" as="element()*" select="value"/>
      <xsl:variable name="statements" as="element()+"
        select="t:get-elements(.) except $values"/>

      <xsl:choose>
        <xsl:when test="empty($values)">
          <xsl:sequence select="'default'"/>
          <xsl:sequence select="':'"/>
          <xsl:sequence select="$t:new-line"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:for-each select="$values">
            <xsl:variable name="expression" as="element()?"
              select="t:get-elements(.)"/>

            <xsl:choose>
              <xsl:when test="empty($expression)">
                <xsl:sequence select="'default'"/>
                <xsl:sequence select="':'"/>
                <xsl:sequence select="$t:new-line"/>
              </xsl:when>
              <xsl:otherwise>
                <xsl:sequence select="'case'"/>
                <xsl:sequence select="' '"/>
                <xsl:sequence select="t:get-expression($expression)"/>
                <xsl:sequence select="':'"/>
                <xsl:sequence select="$t:new-line"/>
              </xsl:otherwise>
            </xsl:choose>
          </xsl:for-each>
        </xsl:otherwise>
      </xsl:choose>

      <xsl:choose>
        <xsl:when test="(count($statements) = 1) and $statements[self::block]">
          <xsl:call-template name="t:get-statements">
            <xsl:with-param name="statements" select="$statements"/>
          </xsl:call-template>
        </xsl:when>
        <xsl:otherwise>
          <xsl:call-template name="t:get-statements-block">
            <xsl:with-param name="comments" select="comment"/>
            <xsl:with-param name="statements" select="$statements"/>
          </xsl:call-template>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:for-each>

    <xsl:sequence select="$t:unindent"/>
    <xsl:sequence select="'}'"/>
    <xsl:sequence select="$t:new-line"/>
  </xsl:template>

  <!-- Mode "t:statement". while-statement. -->
  <xsl:template mode="t:statement" match="while">
    <xsl:variable name="condition" as="element()" select="condition"/>
    <xsl:variable name="statements" as="element()*"
      select="t:get-elements(.) except $condition"/>

    <xsl:sequence select="'while'"/>
    <xsl:sequence select="'('"/>
    <xsl:sequence select="t:get-expression(t:get-elements($condition))"/>
    <xsl:sequence select="')'"/>
    <xsl:sequence select="$t:new-line"/>

    <xsl:call-template name="t:get-statements-block">
      <xsl:with-param name="statements" select="$statements"/>
    </xsl:call-template>
  </xsl:template>

  <!-- Mode "t:statement". do-statement. -->
  <xsl:template mode="t:statement" match="do-while">
    <xsl:variable name="condition" as="element()" select="condition"/>
    <xsl:variable name="statements" as="element()*"
      select="t:get-elements(.) except $condition"/>

    <xsl:sequence select="'do'"/>
    <xsl:sequence select="$t:new-line"/>

    <xsl:call-template name="t:get-statements-block">
      <xsl:with-param name="statements" select="$statements"/>
    </xsl:call-template>

    <xsl:sequence select="'while'"/>
    <xsl:sequence select="'('"/>
    <xsl:sequence select="t:get-expression(t:get-elements($condition))"/>
    <xsl:sequence select="')'"/>
    <xsl:sequence select="';'"/>
    <xsl:sequence select="$t:new-line"/>
  </xsl:template>

  <!-- Mode "t:statement". for-statement. -->
  <xsl:template mode="t:statement" match="for">
    <xsl:variable name="condition" as="element()?" select="condition"/>
    <xsl:variable name="initializer" as="element()*" select="initialize"/>
    <xsl:variable name="update" as="element()*" select="update"/>
    <xsl:variable name="var" as="element()*"
      select="($initializer, $condition, $update)/preceding-sibling::var"/>
    <xsl:variable name="statements" as="element()*" select="
      t:get-elements(.) except ($var, $initializer, $condition, $update)"/>
    <xsl:variable name="condition-expression" as="element()?"
      select="t:get-elements($condition)"/>

    <xsl:if test="exists($var) and exists($initializer)">
      <xsl:sequence select="
        error
        (
          xs:QName('for-var-initializer-mutually-exclusive'),
          concat
          (
            'Variable declaration and initializer are ',
            'mutually exclusive in ''for'' statement.'
          ),
          ($var, $initializer)
        )"/>
    </xsl:if>

    <xsl:if test="$statements[self::var]">
      <xsl:sequence select="
        error
        (
          xs:QName('for-var-in-statement-list'),
          concat
          (
            'Variable declaration is not allowed in statement list of for. ', 
            'Use block statement instead.'
          ),
          $statements
        )"/>
    </xsl:if>

    <xsl:sequence select="'for'"/>
    <xsl:sequence select="'('"/>

    <xsl:if test="exists($var)">
      <xsl:variable name="reference" as="element()" select="$var[1]"/>
      <xsl:variable name="const" as="xs:boolean?"
        select="$reference/@const"/>
      <xsl:variable name="type" as="element()?" select="$reference/type"/>

      <xsl:choose>
        <xsl:when test="$const">
          <xsl:sequence select="'const'"/>
          <xsl:sequence select="' '"/>
          <xsl:sequence select="t:get-type($type)"/>
        </xsl:when>
        <xsl:when test="exists($type)">
          <xsl:sequence select="t:get-type($type)"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:sequence select="'var'"/>
        </xsl:otherwise>
      </xsl:choose>

      <xsl:sequence select="' '"/>

      <xsl:for-each select="$var">
        <xsl:variable name="var-name" as="xs:string" select="@name"/>
        <xsl:variable name="var-initializer" as="element()?"
          select="initialize"/>

        <xsl:sequence select="$var-name"/>

        <xsl:if test="exists($var-initializer)">
          <xsl:sequence select="' '"/>
          <xsl:sequence select="'='"/>
          <xsl:sequence select="' '"/>
          <xsl:sequence
            select="t:get-variable-initializer($var-initializer)"/>
        </xsl:if>

        <xsl:if test="position() != last()">
          <xsl:sequence select="','"/>
          <xsl:sequence select="' '"/>
        </xsl:if>
      </xsl:for-each>
    </xsl:if>

    <xsl:for-each select="$initializer">
      <xsl:sequence select="t:get-expression(t:get-elements(.))"/>

      <xsl:if test="position() != last()">
        <xsl:sequence select="','"/>
        <xsl:sequence select="' '"/>
      </xsl:if>
    </xsl:for-each>

    <xsl:sequence select="';'"/>


    <xsl:if test="exists($condition-expression)">
      <xsl:sequence select="' '"/>
      <xsl:sequence select="t:get-expression($condition-expression)"/>
    </xsl:if>

    <xsl:sequence select="';'"/>

    <xsl:if test="exists($update)">
      <xsl:sequence select="' '"/>

      <xsl:for-each select="$update">
        <xsl:sequence select="t:get-expression(t:get-elements(.))"/>

        <xsl:if test="position() != last()">
          <xsl:sequence select="','"/>
          <xsl:sequence select="' '"/>
        </xsl:if>
      </xsl:for-each>
    </xsl:if>

    <xsl:sequence select="')'"/>

    <xsl:sequence select="$t:new-line"/>

    <xsl:call-template name="t:get-statements-block">
      <xsl:with-param name="statements" select="$statements"/>
    </xsl:call-template>
  </xsl:template>

  <!-- Mode "t:statement". foreach-statement. -->
  <xsl:template mode="t:statement" match="foreach">
    <xsl:variable name="var" as="element()" select="var[1]"/>
    <xsl:variable name="type" as="element()?" select="$var/type"/>
    <xsl:variable name="name" as="xs:string" select="$var/@name"/>
    <xsl:variable name="initializer" as="element()?"
      select="$var/initialize"/>
    <xsl:variable name="statements" as="element()*"
      select="t:get-elements(.) except $var"/>

    <xsl:sequence select="'foreach'"/>
    <xsl:sequence select="'('"/>

    <xsl:choose>
      <xsl:when test="exists($type)">
        <xsl:sequence select="t:get-type($type)"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:sequence select="'var'"/>
      </xsl:otherwise>
    </xsl:choose>

    <xsl:sequence select="' '"/>
    <xsl:sequence select="$name"/>
    <xsl:sequence select="' '"/>
    <xsl:sequence select="'in'"/>
    <xsl:sequence select="' '"/>
    <xsl:sequence select="t:get-variable-initializer($initializer)"/>

    <xsl:sequence select="')'"/>

    <xsl:sequence select="$t:new-line"/>

    <xsl:call-template name="t:get-statements-block">
      <xsl:with-param name="statements" select="$statements"/>
    </xsl:call-template>
  </xsl:template>

  <!-- Mode "t:statement". break-statement. -->
  <xsl:template mode="t:statement" match="break">
    <xsl:sequence select="'break'"/>
    <xsl:sequence select="';'"/>
    <xsl:sequence select="$t:new-line"/>
  </xsl:template>

  <!-- Mode "t:statement". continue-statement. -->
  <xsl:template mode="t:statement" match="continue">
    <xsl:sequence select="'continue'"/>
    <xsl:sequence select="';'"/>
    <xsl:sequence select="$t:new-line"/>
  </xsl:template>

  <!-- Mode "t:statement". goto-statement. -->
  <xsl:template mode="t:statement" match="goto">
    <xsl:variable name="label" as="xs:string?" select="@name"/>
    <xsl:variable name="case" as="element()?" select="t:get-elements(.)"/>

    <xsl:if test="exists($label) and exists($case)">
      <xsl:sequence select="
        error
        (
          xs:QName('goto-case-label-mutually-exclusive'),
          'Case and label are mutually exclusive in ''goto'' statement.',
          ($label, $case)
        )"/>
    </xsl:if>

    <xsl:sequence select="'goto'"/>
    <xsl:sequence select="' '"/>

    <xsl:choose>
      <xsl:when test="exists($label)">
        <xsl:sequence select="$label"/>
      </xsl:when>
      <xsl:when test="exists($case)">
        <xsl:sequence select="'case'"/>
        <xsl:sequence select="' '"/>
        <xsl:sequence select="t:get-expression($case)"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:sequence select="'default'"/>
      </xsl:otherwise>
    </xsl:choose>

    <xsl:sequence select="';'"/>
    <xsl:sequence select="$t:new-line"/>
  </xsl:template>

  <!-- Mode "t:statement". return-statement. -->
  <xsl:template mode="t:statement" match="return">
    <xsl:variable name="expression" as="element()?"
      select="t:get-elements(.)"/>

    <xsl:sequence select="'return'"/>

    <xsl:if test="exists($expression)">
      <xsl:sequence select="' '"/>
      <xsl:sequence select="t:get-expression($expression)"/>
    </xsl:if>

    <xsl:sequence select="';'"/>
    <xsl:sequence select="$t:new-line"/>
  </xsl:template>

  <!-- Mode "t:statement". throw-statement. -->
  <xsl:template mode="t:statement" match="throw">
    <xsl:variable name="expression" as="element()?"
      select="t:get-elements(.)"/>

    <xsl:sequence select="'throw'"/>

    <xsl:if test="exists($expression)">
      <xsl:sequence select="' '"/>
      <xsl:sequence select="t:get-expression($expression)"/>
    </xsl:if>

    <xsl:sequence select="';'"/>
    <xsl:sequence select="$t:new-line"/>
  </xsl:template>

  <!-- Mode "t:statement". try-statement. -->
  <xsl:template mode="t:statement" match="try">
    <xsl:variable name="catch" as="element()*" select="catch"/>
    <xsl:variable name="finally" as="element()?" select="finally"/>
    <xsl:variable name="statements" as="element()*"
      select="t:get-elements(.) except ($catch, $finally)"/>

    <xsl:if test="empty($catch) and empty($finally)">
      <xsl:sequence select="
        error
        (
          xs:QName('try-catch-finally-expected'),
          'Either catch or finally clause is expected in ''try'' statement.',
          .
        )"/>
    </xsl:if>

    <xsl:sequence select="'try'"/>
    <xsl:sequence select="$t:new-line"/>

    <xsl:call-template name="t:get-statements-block">
      <xsl:with-param name="statements" select="$statements"/>
    </xsl:call-template>

    <xsl:for-each select="$catch">
      <xsl:variable name="name" as="xs:string?" select="@name"/>
      <xsl:variable name="type" as="element()?" select="type"/>
      <xsl:variable name="filter" as="element()?" select="when"/>
      <xsl:variable name="catch-statements" as="element()*"
        select="t:get-elements(.) except ($type, $filter)"/>

      <xsl:sequence select="'catch'"/>

      <xsl:if test="exists($type)">
        <xsl:sequence select="'('"/>
        <xsl:sequence select="t:get-type($type)"/>

        <xsl:if test="exists($name)">
          <xsl:sequence select="' '"/>
          <xsl:sequence select="$name"/>
        </xsl:if>

        <xsl:sequence select="')'"/>
      </xsl:if>

      <xsl:if test="$filter">
        <xsl:sequence select="' '"/>
        <xsl:sequence select="'when'"/>
        <xsl:sequence select="'('"/>
        <xsl:sequence select="t:get-expression(t:get-elements($filter))"/>
        <xsl:sequence select="')'"/>
      </xsl:if>

      <xsl:sequence select="$t:new-line"/>

      <xsl:call-template name="t:get-statements-block">
        <xsl:with-param name="comments" select="comment"/>
        <xsl:with-param name="statements" select="$catch-statements"/>
      </xsl:call-template>
    </xsl:for-each>

    <xsl:if test="exists($finally)">
      <xsl:sequence select="'finally'"/>
      <xsl:sequence select="$t:new-line"/>

      <xsl:call-template name="t:get-statements-block">
        <xsl:with-param name="comments" select="$finally/comment"/>
        <xsl:with-param name="statements" select="t:get-elements($finally)"/>
      </xsl:call-template>
    </xsl:if>
  </xsl:template>

  <!-- Mode "t:statement". lock-statement. -->
  <xsl:template mode="t:statement" match="lock">
    <xsl:variable name="resource" as="element()" select="resource"/>
    <xsl:variable name="statements" as="element()*"
      select="t:get-elements(.) except $resource"/>

    <xsl:sequence select="'lock'"/>
    <xsl:sequence select="'('"/>
    <xsl:sequence select="t:get-expression(t:get-elements($resource))"/>
    <xsl:sequence select="')'"/>
    <xsl:sequence select="$t:new-line"/>

    <xsl:choose>
      <xsl:when test="
        (count($statements) = 1) and exists($statements[self::lock])">
        <xsl:call-template name="t:get-statements">
          <xsl:with-param name="statements" select="$statements"/>
        </xsl:call-template>
      </xsl:when>
      <xsl:otherwise>
        <xsl:call-template name="t:get-statements-block">
          <xsl:with-param name="statements" select="$statements"/>
        </xsl:call-template>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!-- Mode "t:statement". using-statement. -->
  <xsl:template mode="t:statement" match="using">
    <xsl:variable name="resource" as="element()" select="resource"/>
    <xsl:variable name="var" as="element()?" select="$resource/var"/>
    <xsl:variable name="statements" as="element()*"
      select="t:get-elements(.) except $resource"/>

    <xsl:sequence select="'using'"/>
    <xsl:sequence select="'('"/>

    <xsl:choose>
      <xsl:when test="exists($var)">
        <xsl:variable name="name" as="xs:string" select="$var/@name"/>
        <xsl:variable name="type" as="element()?" select="$var/type"/>
        <xsl:variable name="initializer" as="element()"
          select="$var/initialize"/>

        <xsl:choose>
          <xsl:when test="exists($type)">
            <xsl:sequence select="t:get-type($type)"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:sequence select="'var'"/>
          </xsl:otherwise>
        </xsl:choose>

        <xsl:sequence select="' '"/>
        <xsl:sequence select="$name"/>

        <xsl:sequence select="' '"/>
        <xsl:sequence select="'='"/>
        <xsl:sequence select="' '"/>
        <xsl:sequence select="t:get-variable-initializer($initializer)"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:sequence select="t:get-expression(t:get-elements($resource))"/>
      </xsl:otherwise>
    </xsl:choose>

    <xsl:sequence select="')'"/>
    <xsl:sequence select="$t:new-line"/>

    <xsl:choose>
      <xsl:when test="
        (count($statements) = 1) and exists($statements[self::using])">
        <xsl:call-template name="t:get-statements">
          <xsl:with-param name="statements" select="$statements"/>
        </xsl:call-template>
      </xsl:when>
      <xsl:otherwise>
        <xsl:call-template name="t:get-statements-block">
          <xsl:with-param name="statements" select="$statements"/>
        </xsl:call-template>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!-- Mode "t:statement". yield-statement. -->
  <xsl:template mode="t:statement" match="yield">
    <xsl:variable name="expression" as="element()?"
      select="t:get-elements(.)"/>

    <xsl:sequence select="'yield'"/>
    <xsl:sequence select="' '"/>

    <xsl:choose>
      <xsl:when test="exists($expression)">
        <xsl:sequence select="'return'"/>
        <xsl:sequence select="' '"/>
        <xsl:sequence select="t:get-expression($expression)"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:sequence select="'break'"/>
      </xsl:otherwise>
    </xsl:choose>

    <xsl:sequence select="';'"/>
    <xsl:sequence select="$t:new-line"/>
  </xsl:template>

  <!-- Mode "t:statement". fixed. -->
  <xsl:template mode="t:statement" match="fixed">
    <xsl:variable name="var" as="element()" select="var"/>
    <xsl:variable name="statements" as="element()*"
      select="t:get-elements(.) except $var"/>
    <xsl:variable name="name" as="xs:string" select="$var/@name"/>
    <xsl:variable name="type" as="element()" select="$var/type"/>
    <xsl:variable name="initializer" as="element()"
      select="$var/initialize"/>

    <xsl:sequence select="'fixed'"/>
    <xsl:sequence select="'('"/>
    <xsl:sequence select="t:get-type($type)"/>
    <xsl:sequence select="' '"/>
    <xsl:sequence select="$name"/>
    <xsl:sequence select="' '"/>
    <xsl:sequence select="'='"/>
    <xsl:sequence select="' '"/>
    <xsl:sequence select="t:get-variable-initializer($initializer)"/>
    <xsl:sequence select="')'"/>
    <xsl:sequence select="$t:new-line"/>

    <xsl:choose>
      <xsl:when test="
        (count($statements) = 1) and exists($statements[self::fixed])">
        <xsl:call-template name="t:get-statements">
          <xsl:with-param name="statements" select="$statements"/>
        </xsl:call-template>
      </xsl:when>
      <xsl:otherwise>
        <xsl:call-template name="t:get-statements-block">
          <xsl:with-param name="statements" select="$statements"/>
        </xsl:call-template>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

</xsl:stylesheet>