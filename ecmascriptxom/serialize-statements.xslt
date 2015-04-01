<?xml version="1.0" encoding="utf-8"?>
<!--
  This stylesheet to serialize ecmascript statements.
 -->
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns="http://www.nesterovsky-bros.com/ecmascript6/2015-02-20"
  xmlns:t="http://www.nesterovsky-bros.com/ecmascript"
  xpath-default-namespace="http://www.nesterovsky-bros.com/ecmascript6/2015-02-20"
  exclude-result-prefixes="xs t">

  <!--
    Gets a sequence of tokens for a statement.
      $statement - a statment.
      Returns a sequence of tokens.
  -->
  <xsl:function name="t:get-statement" as="item()*">
    <xsl:param name="statement" as="element()"/>

    <xsl:apply-templates mode="t:statement" select="$statement"/>
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

      <xsl:if test="not(self::block)">
        <xsl:sequence select="t:get-comments(.)"/>
      </xsl:if>

      <xsl:sequence select="$tokens"/>

      <xsl:if test="
        exists($next) and
        (
          not
          (
            (
              (self::var or self:let or self:const) and 
              $next[self::var or self:let or self:const]
            ) or
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
        exists($statements[self::block])">
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

  <!--  Mode "t:statement". scope. -->
  <xsl:template mode="t:statement" match="scope">
    <xsl:variable name="comments" as="element()*" select="comment"/>
    <xsl:variable name="statements" as="element()*" select="t:get-elements(.)"/>

    <xsl:sequence select="$comments/t:get-comment(.)"/>

    <xsl:call-template name="t:get-statements">
      <xsl:with-param name="statements" select="$statements"/>
    </xsl:call-template>
  </xsl:template>

  <!--  Mode "t:statement". block, body. -->
  <xsl:template mode="t:statement" match="block body">
    <xsl:call-template name="t:get-statements-block">
      <xsl:with-param name="comments" select="comment"/>
      <xsl:with-param name="statements" select="t:get-elements(.)"/>
    </xsl:call-template>
  </xsl:template>

  <!-- Mode "t:statement". labeled-statement. -->
  <xsl:template mode="t:statement" match="label">
    <xsl:variable name="name" as="xs:string" select="name/@value"/>
    <xsl:variable name="statements" as="element()+"
      select="t:get-elements(.) except $name"/>

    <xsl:sequence select="$t:line-indent"/>
    <xsl:sequence select="$name"/>
    <xsl:sequence select="':'"/>
    <xsl:sequence select="$t:new-line"/>

    <xsl:call-template name="t:get-statements">
      <xsl:with-param name="statements" select="$statements"/>
    </xsl:call-template>
  </xsl:template>

  <!-- Mode "t:statement". statement. -->
  <xsl:template mode="t:statement" match="statement">
    <xsl:sequence select="';'"/>
    <xsl:sequence select="$t:new-line"/>
  </xsl:template>

  <!-- Mode "t:statement". declaration-statement. -->
  <xsl:template mode="t:statement" match="var | let | const">
    <xsl:variable name="export" as="xs:string?" select="@export"/>
    <xsl:variable name="name" as="element()?" select="name"/>
    <xsl:variable name="initialize" as="element()" select="initialize"/>

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

    <xsl:choose>
      <xsl:when test="self::let">
        <xsl:sequence select="'let'"/>
      </xsl:when>
      <xsl:when test="self::const">
        <xsl:sequence select="'const'"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:sequence select="'var'"/>
      </xsl:otherwise>
    </xsl:choose>

    <xsl:sequence select="' '"/>

    <xsl:choose>
      <xsl:when test="$name">
        <xsl:sequence select="string($name/@value)"/>
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

    <xsl:sequence select="';'"/>
    <xsl:sequence select="$t:new-line"/>
  </xsl:template>

  <!-- Mode "t:statement". expression. -->
  <xsl:template mode="t:statement" match="expression">
    <xsl:variable name="expressions" as="element()+" 
      select="t:get-elements(.)"/>

    <xsl:for-each select="expressions">
      <xsl:sequence select="t:get-statement-expression(.)"/>

      <xsl:if test="position() != last()">
        <xsl:sequence select="','"/>
        <xsl:sequence select="' '"/>
        <xsl:sequence select="$t:soft-line-break"/>
      </xsl:if>
    </xsl:for-each>

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

  <!-- Mode "t:statement". do-while. -->
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

  <!-- Mode "t:statement". for. -->
  <xsl:template mode="t:statement" match="for">
    <xsl:variable name="initialize" as="element()?" select="initialize"/>
    <xsl:variable name="var" as="element()*" select="var"/>
    <xsl:variable name="let" as="element()*" select="let"/>
    <xsl:variable name="const" as="element()*" select="const"/>
    <xsl:variable name="condition" as="element()?" select="condition"/>
    <xsl:variable name="update" as="element()*" select="update"/>
    <xsl:variable name="block" as="element()" select="block"/>
    
    <xsl:if test="
      xs:integer(exists($initialize)) + 
      xs:integer(exists($var)) + 
      xs:integer(exists($let)) + 
      xs:integer(exists($const)) > 1">
      <xsl:sequence select="
        error
        (
          xs:QName('for-var-initializer-mutually-exclusive'),
          concat
          (
            'Variable declaration and initializer are ',
            'mutually exclusive in ''for'' statement.'
          ),
          ($var, $const, $let, $initializer)
        )"/>
    </xsl:if>

    <xsl:sequence select="'for'"/>
    <xsl:sequence select="'('"/>

    <xsl:for-each select="$var, $let, $const">
      <xsl:variable name="name" as="element()?" select="name"/>
      <xsl:variable name="var-initialize" as="element()" select="initialize"/>

      <xsl:choose>
        <xsl:when test="position() != 1">
          <xsl:sequence select="','"/>
        </xsl:when>
        <xsl:when test="self::let">
          <xsl:sequence select="'let'"/>
        </xsl:when>
        <xsl:when test="self::const">
          <xsl:sequence select="'const'"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:sequence select="'var'"/>
        </xsl:otherwise>
      </xsl:choose>

      <xsl:sequence select="' '"/>

      <xsl:choose>
        <xsl:when test="$name">
          <xsl:sequence select="string($name/@value)"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:variable name="pattern" as="element()" select="pattern"/>

          <xsl:apply-templates mode="t:binding-pattern" select="$pattern"/>
        </xsl:otherwise>
      </xsl:choose>

      <xsl:if test="$var-initialize">
        <xsl:sequence select="' '"/>
        <xsl:sequence select="'='"/>
        <xsl:sequence select="' '"/>
        <xsl:sequence
          select="t:get-nested-expression(t:get-elements($var-initialize))"/>
      </xsl:if>
    </xsl:for-each>

    <xsl:for-each select="initialize/t:get-elements(.)">
      <xsl:sequence select="t:get-statement-expression(.)"/>

      <xsl:if test="position() != last()">
        <xsl:sequence select="','"/>
        <xsl:sequence select="' '"/>
      </xsl:if>
    </xsl:for-each>

    <xsl:sequence select="';'"/>

    <xsl:if test="exists($condition)">
      <xsl:sequence select="' '"/>
      <xsl:sequence select="t:get-expression(t:get-elements($condition))"/>
    </xsl:if>

    <xsl:sequence select="';'"/>

    <xsl:if test="exists($update)">
      <xsl:sequence select="' '"/>

      <xsl:for-each select="$update/t:get-elements(.)">
        <xsl:sequence select="t:get-expression(.)"/>

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

  <!-- Mode "t:statement". for. -->
  <xsl:template mode="t:statement" match="for-in | for-of">
    <xsl:variable name="elements" as="element()+" select="t:get-elements(.)"/>
    <xsl:variable name="assign" as="element()?"
      select="$elements[1][self::assign]"/>
    <xsl:variable name="var" as="element()?"
      select="$elements[1][self::var or self::left or self::const]"/>
    <xsl:variable name="block" as="element()?"
      select="$elements[2][self::block]"/>
    
    <xsl:if test="xs:integer(exists($assign)) + xs:integer(exists($var)) != 1">
      <xsl:sequence select="
        error
        (
          xs:QName('for-source'),
          'For source is expected.',
          ($assign, $var, $let, $const)
        )"/>
    </xsl:if>

    <xsl:sequence select="'for'"/>
    <xsl:sequence select="'('"/>

    <xsl:variable name="source" as="element()" select="
      $assign/t:get-elements(.)[2], 
      $var/t:get-elements(initialize)"/>

    <xsl:choose>
      <xsl:when test="$assign">
        <xsl:variable name="left" as="element()" 
          select="t:get-elements($assign)[1]"/>

        <xsl:choose>
          <xsl:when test="$left[self::pattern]">
            <xsl:apply-templates mode="t:binding-pattern" select="$left"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:apply-templates mode="t:lefthand-side-expression" select="$left"/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:when>
      <xsl:otherwise>
        <xsl:choose>
          <xsl:when test="$var[self::var]">
            <xsl:sequence select="'var'"/>
          </xsl:when>
          <xsl:when test="$var[self::let]">
            <xsl:sequence select="'let'"/>
          </xsl:when>
          <xsl:when test="$var[self::const]">
            <xsl:sequence select="'const'"/>
          </xsl:when>
        </xsl:choose>

        <xsl:sequence select="' '"/>

        <xsl:variable name="name" as="element()?" select="$var/name"/>

        <xsl:choose>
          <xsl:when test="$name">
            <xsl:sequence select="string($name/@value)"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:variable name="pattern" as="element()" select="$var/pattern"/>

            <xsl:apply-templates mode="t:binding-pattern" select="$pattern"/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:otherwise>
    </xsl:choose>

    <xsl:sequence select="' '"/>

    <xsl:choose>
      <xsl:when test="self::for-in">
        <xsl:sequence select="'in'"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:sequence select="'of'"/>
      </xsl:otherwise>
    </xsl:choose>

    <xsl:sequence select="' '"/>
    <xsl:sequence select="t:get-nested-expression($right)"/>
    <xsl:sequence select="')'"/>
    <xsl:sequence select="$t:new-line"/>
    <xsl:apply-templates mode="t:statement" select="$body"/>
  </xsl:template>

  <!-- Mode "t:statement". switch-statement. -->
  <xsl:template mode="t:statement" match="switch">
    <xsl:variable name="test" as="element()" select="test"/>
    <xsl:variable name="cases" as="element()+" select="case | default"/>

    <xsl:sequence select="'switch'"/>
    <xsl:sequence select="'('"/>
    <xsl:sequence select="t:get-expression(t:get-elements($test))"/>
    <xsl:sequence select="')'"/>
    <xsl:sequence select="$t:new-line"/>
    <xsl:sequence select="'{'"/>
    <xsl:sequence select="$t:new-line"/>
    <xsl:sequence select="$t:indent"/>

    <xsl:for-each select="$cases">
      <xsl:choose>
        <xsl:when test="empty(self::default)">
          <xsl:sequence select="'default'"/>
          <xsl:sequence select="':'"/>
          <xsl:sequence select="$t:new-line"/>
          <xsl:apply-templates mode="t:statement" select="."/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:variable name="value" as="element()" select="value"/>
          <xsl:variable name="block" as="element()?" select="block"/>

          <xsl:sequence select="'case'"/>
          <xsl:sequence select="' '"/>
          <xsl:sequence select="t:get-expression(t:get-elements($value))"/>
          <xsl:sequence select="':'"/>
          <xsl:sequence select="$t:new-line"/>
          <xsl:apply-templates mode="t:statement" select="$block"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:for-each>

    <xsl:sequence select="$t:unindent"/>
    <xsl:sequence select="'}'"/>
    <xsl:sequence select="$t:new-line"/>
  </xsl:template>

  <!-- Mode "t:statement". break. -->
  <xsl:template mode="t:statement" match="break">
    <xsl:variable name="ref" as="element()?" select="ref"/>
    
    <xsl:sequence select="'break'"/>
    
    <xsl:if test="$ref">
      <xsl:sequence select="'&#160;'"/>
      <xsl:sequence select="string($ref/@name)"/>
    </xsl:if>
    
    <xsl:sequence select="';'"/>
    <xsl:sequence select="$t:new-line"/>
  </xsl:template>

  <!-- Mode "t:statement". continue. -->
  <xsl:template mode="t:statement" match="continue">
    <xsl:variable name="ref" as="element()?" select="ref"/>

    <xsl:sequence select="'continue'"/>
    
    <xsl:if test="$ref">
      <xsl:sequence select="'&#160;'"/>
      <xsl:sequence select="string($ref/@name)"/>
    </xsl:if>

    <xsl:sequence select="';'"/>
    <xsl:sequence select="$t:new-line"/>
  </xsl:template>

  <!-- Mode "t:statement". return. -->
  <xsl:template mode="t:statement" match="return">
    <xsl:variable name="expression" as="element()?"
      select="t:get-elements(.)"/>

    <xsl:sequence select="'return'"/>

    <xsl:if test="exists($expression)">
      <xsl:sequence select="'&#160;'"/>
      <xsl:sequence select="t:get-expression($expression)"/>
    </xsl:if>

    <xsl:sequence select="';'"/>
    <xsl:sequence select="$t:new-line"/>
  </xsl:template>

  <!-- Mode "t:statement". with. -->
  <xsl:template mode="t:statement" match="with">
    <xsl:variable name="scope" as="element()" select="scope"/>
    <xsl:variable name="block" as="element()" select="block"/>
  
    <xsl:sequence select="'with'"/>
    <xsl:sequence select="'('"/>
    <xsl:sequence select="t:get-expression(t:get-elements($scope))"/>
    <xsl:sequence select="')'"/>
    <xsl:sequence select="$t:new-line"/>
    <xsl:apply-templates mode="t:statement" select="$block"/>
  </xsl:template>

  <!-- Mode "t:statement". throw. -->
  <xsl:template mode="t:statement" match="throw">
    <xsl:variable name="expression" as="element()" select="t:get-elements(.)"/>
  
    <xsl:sequence select="'throw'"/>
    <xsl:sequence select="'&#160;'"/>
    <xsl:sequence select="t:get-expression($expression)"/>
    <xsl:sequence select="';'"/>
  </xsl:template>

  <!-- Mode "t:statement". try. -->
  <xsl:template mode="t:statement" match="try">
    <xsl:variable name="block" as="element()" select="block"/>
    <xsl:variable name="catch" as="element()?" select="catch"/>
    <xsl:variable name="finally" as="element()?" select="finally"/>

    <xsl:if test="empty($catch) and empty($finally)">
      <xsl:sequence select="
        error
        (
          xs:QName('invalid-try'),
          'Invalid try statement. Catch or finally clauses are expected.',
          .
        )"/>
    </xsl:if>
      
    <xsl:sequence select="'try'"/>
    <xsl:sequence select="$t:new-line"/>
    <xsl:apply-templates mode="t:statement" select="$block"/>
  
    <xsl:if test="$catch">
      <xsl:variable name="parameter" as="element()" select="parameter"/>
      <xsl:variable name="name" as="element()?" select="$parameter/name"/>
      <xsl:variable name="catch-block" as="element()" select="block"/>
      
      <xsl:sequence select="'catch'"/>
      <xsl:sequence select="'('"/>
      
      <xsl:choose>
        <xsl:when test="$name">
          <xsl:sequence select="string($name/@value)"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:variable name="pattern" as="element()" select="$parameter/pattern"/>

          <xsl:apply-templates mode="t:binding-pattern" select="$pattern"/>
        </xsl:otherwise>
      </xsl:choose>
      
      <xsl:sequence select="')'"/>
      <xsl:sequence select="$t:new-line"/>
      <xsl:apply-templates mode="t:statement" select="$catch-block"/>
    </xsl:if>
  
    <xsl:if test="$finally">
      <xsl:sequence select="'finally'"/>
      <xsl:sequence select="$t:new-line"/>
      <xsl:apply-templates mode="t:statement" select="$finally"/>
    </xsl:if>
  </xsl:template>

  <!-- Mode "t:statement". debugger. -->
  <xsl:template mode="t:statement" match="debugger">
    <xsl:sequence select="'debugger'"/>
    <xsl:sequence select="';'"/>
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
      <xsl:variable name="catch-statements" as="element()*"
        select="t:get-elements(.) except $type"/>

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

</xsl:stylesheet>