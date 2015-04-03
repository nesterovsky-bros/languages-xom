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
      $module-items - optional indicator of module items (default false).
      Returns a sequence of tokens.
  -->
  <xsl:template name="t:get-statements" as="item()*">
    <xsl:param name="statements" as="element()*"/>
    <xsl:param name="module-items" as="xs:boolean?"/>

    <xsl:for-each select="$statements">
      <xsl:variable name="index" as="xs:integer" select="position()"/>
      <xsl:variable name="next" as="element()?"
        select="$statements[$index + 1]"/>

      <xsl:variable name="tokens" as="item()*">
        <xsl:choose>
          <xsl:when test="$module-items">
            <xsl:apply-templates mode="t:module-item" select="."/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:apply-templates mode="t:statement" select="."/>
          </xsl:otherwise>
        </xsl:choose>
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
              (self::var or self::let or self::const) and 
              $next[self::var or self::let or self::const]
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
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!-- Mode "t:statement t:module-item". Default match. -->
  <xsl:template mode="t:statement t:module-item" match="*">
    <xsl:sequence select="
      error
      (
        xs:QName('invalid-statement'),
        concat('Invalid statement. ', t:get-path(.)),
        .
      )"/>
  </xsl:template>

  <!--  Mode "t:statement t:module-item". scope. -->
  <xsl:template mode="t:statement t:module-item" match="scope">
    <xsl:sequence select="comment/t:get-comment(.)"/>
    <xsl:apply-templates mode="#current" select="t:get-elements(.)"/>
  </xsl:template>

  <!--  Mode "t:statement t:module-item". block, body. -->
  <xsl:template mode="t:statement t:module-item" match="block | body">
    <xsl:call-template name="t:get-statements-block">
      <xsl:with-param name="comments" select="comment"/>
      <xsl:with-param name="statements" select="t:get-elements(.)"/>
    </xsl:call-template>
  </xsl:template>

  <!-- Mode "t:statement t:module-item". labeled-statement. -->
  <xsl:template mode="t:statement t:module-item" match="label">
    <xsl:variable name="name" as="element()" select="name"/>
    <xsl:variable name="statements" as="element()+"
      select="t:get-elements(.) except $name"/>

    <xsl:sequence select="$t:line-indent"/>
    <xsl:sequence select="string($name/@value)"/>
    <xsl:sequence select="':'"/>
    <xsl:sequence select="$t:new-line"/>

    <xsl:call-template name="t:get-statements">
      <xsl:with-param name="statements" select="$statements"/>
    </xsl:call-template>
  </xsl:template>

  <!-- Mode "t:statement t:module-item". statement. -->
  <xsl:template mode="t:statement t:module-item" match="statement">
    <xsl:sequence select="';'"/>
    <xsl:sequence select="$t:new-line"/>
  </xsl:template>

  <!-- Mode "t:statement t:module-item". declaration-statement. -->
  <xsl:template mode="t:statement t:module-item" match="var | let | const">
    <xsl:variable name="export" as="xs:string?" select="@export"/>
    <xsl:variable name="name" as="element()?" select="name"/>
    <xsl:variable name="initialize" as="element()?" select="initialize"/>

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

  <!-- Mode "t:statement t:module-item". expression. -->
  <xsl:template mode="t:statement t:module-item" match="expression">
    <xsl:variable name="expressions" as="element()+" 
      select="t:get-elements(.)"/>

    <xsl:for-each select="$expressions">
      <xsl:sequence select="t:expression(.)"/>

      <xsl:if test="position() != last()">
        <xsl:sequence select="','"/>
        <xsl:sequence select="' '"/>
        <xsl:sequence select="$t:soft-line-break"/>
      </xsl:if>
    </xsl:for-each>

    <xsl:sequence select="';'"/>
    <xsl:sequence select="$t:new-line"/>
  </xsl:template>

  <!-- Mode "t:statement t:module-item". if-statement. -->
  <xsl:template mode="t:statement t:module-item" match="if">
    <xsl:variable name="condition" as="element()" select="condition"/>
    <xsl:variable name="then" as="element()" select="then"/>
    <xsl:variable name="else" as="element()?" select="else"/>

    <xsl:sequence select="'if'"/>
    <xsl:sequence select="' '"/>
    <xsl:sequence select="'('"/>
    <xsl:sequence select="t:expression(t:get-elements($condition))"/>
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

  <!-- Mode "t:statement t:module-item". do-while. -->
  <xsl:template mode="t:statement t:module-item" match="do-while">
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
    <xsl:sequence select="t:expression(t:get-elements($condition))"/>
    <xsl:sequence select="')'"/>
    <xsl:sequence select="';'"/>
    <xsl:sequence select="$t:new-line"/>
  </xsl:template>

  <!-- Mode "t:statement t:module-item". while-statement. -->
  <xsl:template mode="t:statement t:module-item" match="while">
    <xsl:variable name="condition" as="element()" select="condition"/>
    <xsl:variable name="statements" as="element()*"
      select="t:get-elements(.) except $condition"/>

    <xsl:sequence select="'while'"/>
    <xsl:sequence select="'('"/>
    <xsl:sequence select="t:expression(t:get-elements($condition))"/>
    <xsl:sequence select="')'"/>
    <xsl:sequence select="$t:new-line"/>

    <xsl:call-template name="t:get-statements-block">
      <xsl:with-param name="statements" select="$statements"/>
    </xsl:call-template>
  </xsl:template>

  <!-- Mode "t:statement t:module-item". for. -->
  <xsl:template mode="t:statement t:module-item" match="for">
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
            'mutually exclusive in ''for'' statement. ', 
            t:get-path(.)
          ),
          .
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
      <xsl:sequence select="t:expression(.)"/>

      <xsl:if test="position() != last()">
        <xsl:sequence select="','"/>
        <xsl:sequence select="' '"/>
      </xsl:if>
    </xsl:for-each>

    <xsl:sequence select="';'"/>

    <xsl:if test="exists($condition)">
      <xsl:sequence select="' '"/>
      <xsl:sequence select="t:expression(t:get-elements($condition))"/>
    </xsl:if>

    <xsl:sequence select="';'"/>

    <xsl:if test="exists($update)">
      <xsl:sequence select="' '"/>

      <xsl:for-each select="$update/t:get-elements(.)">
        <xsl:sequence select="t:expression(.)"/>

        <xsl:if test="position() != last()">
          <xsl:sequence select="','"/>
          <xsl:sequence select="' '"/>
        </xsl:if>
      </xsl:for-each>
    </xsl:if>

    <xsl:sequence select="')'"/>

    <xsl:sequence select="$t:new-line"/>
    <xsl:apply-templates mode="t:statement" select="$block"/>
  </xsl:template>

  <!-- Mode "t:statement t:module-item". for. -->
  <xsl:template mode="t:statement t:module-item" match="for-in | for-of">
    <xsl:variable name="elements" as="element()+" select="t:get-elements(.)"/>
    <xsl:variable name="assign" as="element()?"
      select="$elements[1][self::assign]"/>
    <xsl:variable name="var" as="element()?"
      select="$elements[1][self::var or self::let or self::const]"/>
    <xsl:variable name="block" as="element()?"
      select="$elements[2][self::block]"/>
    
    <xsl:if test="xs:integer(exists($assign)) + xs:integer(exists($var)) != 1">
      <xsl:sequence select="
        error
        (
          xs:QName('for-source'),
          concat('For-source is expected. ', t:get-path(.)),
          .
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
    <xsl:sequence select="t:get-nested-expression($source)"/>
    <xsl:sequence select="')'"/>
    <xsl:sequence select="$t:new-line"/>
    <xsl:apply-templates mode="t:statement" select="$block"/>
  </xsl:template>

  <!-- Mode "t:statement t:module-item". switch. -->
  <xsl:template mode="t:statement t:module-item" match="switch">
    <xsl:variable name="test" as="element()" select="test"/>
    <xsl:variable name="cases" as="element()+" select="case | default"/>

    <xsl:sequence select="'switch'"/>
    <xsl:sequence select="'('"/>
    <xsl:sequence select="t:expression(t:get-elements($test))"/>
    <xsl:sequence select="')'"/>
    <xsl:sequence select="$t:new-line"/>
    <xsl:sequence select="'{'"/>
    <xsl:sequence select="$t:new-line"/>
    <xsl:sequence select="$t:indent"/>

    <xsl:for-each select="$cases">
      <xsl:choose>
        <xsl:when test="exists(self::default)">
          <xsl:sequence select="'default'"/>
          <xsl:sequence select="':'"/>
          <xsl:sequence select="$t:new-line"/>
          
          <xsl:call-template name="t:get-statements-block">
            <xsl:with-param name="comments" select="comment"/>
            <xsl:with-param name="statements" select="t:get-elements(.)"/>
          </xsl:call-template>
        </xsl:when>
        <xsl:otherwise>
          <xsl:variable name="value" as="element()" select="value"/>
          <xsl:variable name="block" as="element()?" select="block"/>

          <xsl:sequence select="'case'"/>
          <xsl:sequence select="' '"/>
          <xsl:sequence select="t:expression(t:get-elements($value))"/>
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

  <!-- Mode "t:statement t:module-item". break. -->
  <xsl:template mode="t:statement t:module-item" match="break">
    <xsl:variable name="ref" as="element()?" select="ref"/>
    
    <xsl:sequence select="'break'"/>
    
    <xsl:if test="$ref">
      <xsl:sequence select="$t:nbsp"/>
      <xsl:sequence select="string($ref/@name)"/>
    </xsl:if>
    
    <xsl:sequence select="';'"/>
    <xsl:sequence select="$t:new-line"/>
  </xsl:template>

  <!-- Mode "t:statement t:module-item". continue. -->
  <xsl:template mode="t:statement t:module-item" match="continue">
    <xsl:variable name="ref" as="element()?" select="ref"/>

    <xsl:sequence select="'continue'"/>
    
    <xsl:if test="$ref">
      <xsl:sequence select="$t:nbsp"/>
      <xsl:sequence select="string($ref/@name)"/>
    </xsl:if>

    <xsl:sequence select="';'"/>
    <xsl:sequence select="$t:new-line"/>
  </xsl:template>

  <!-- Mode "t:statement t:module-item". return. -->
  <xsl:template mode="t:statement t:module-item" match="return">
    <xsl:variable name="expression" as="element()?"
      select="t:get-elements(.)"/>

    <xsl:sequence select="'return'"/>

    <xsl:if test="exists($expression)">
      <xsl:sequence select="$t:nbsp"/>
      <xsl:sequence select="t:expression($expression)"/>
    </xsl:if>

    <xsl:sequence select="';'"/>
    <xsl:sequence select="$t:new-line"/>
  </xsl:template>

  <!-- Mode "t:statement t:module-item". with. -->
  <xsl:template mode="t:statement t:module-item" match="with">
    <xsl:variable name="scope" as="element()" select="scope"/>
    <xsl:variable name="block" as="element()" select="block"/>
  
    <xsl:sequence select="'with'"/>
    <xsl:sequence select="'('"/>
    <xsl:sequence select="t:expression(t:get-elements($scope))"/>
    <xsl:sequence select="')'"/>
    <xsl:sequence select="$t:new-line"/>
    <xsl:apply-templates mode="t:statement" select="$block"/>
  </xsl:template>

  <!-- Mode "t:statement t:module-item". throw. -->
  <xsl:template mode="t:statement t:module-item" match="throw">
    <xsl:variable name="expression" as="element()" select="t:get-elements(.)"/>
  
    <xsl:sequence select="'throw'"/>
    <xsl:sequence select="$t:nbsp"/>
    <xsl:sequence select="t:expression($expression)"/>
    <xsl:sequence select="';'"/>
  </xsl:template>

  <!-- Mode "t:statement t:module-item". try. -->
  <xsl:template mode="t:statement t:module-item" match="try">
    <xsl:variable name="block" as="element()" select="block"/>
    <xsl:variable name="catch" as="element()?" select="catch"/>
    <xsl:variable name="finally" as="element()?" select="finally"/>

    <xsl:if test="empty($catch) and empty($finally)">
      <xsl:sequence select="
        error
        (
          xs:QName('invalid-try'),
          concat
          (
            'Invalid try statement. ',
            'Catch or finally clauses are expected. ', 
            t:get-path(.)
          ),
          .
        )"/>
    </xsl:if>
      
    <xsl:sequence select="'try'"/>
    <xsl:sequence select="$t:new-line"/>
    <xsl:apply-templates mode="t:statement" select="$block"/>
  
    <xsl:if test="$catch">
      <xsl:variable name="parameter" as="element()" select="$catch/parameter"/>
      <xsl:variable name="name" as="element()?" select="$parameter/name"/>
      <xsl:variable name="catch-block" as="element()" select="$catch/block"/>
      
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

      <xsl:call-template name="t:get-statements-block">
        <xsl:with-param name="comments" select="$finally/comment"/>
        <xsl:with-param name="statements" select="t:get-elements($finally)"/>
      </xsl:call-template>
    </xsl:if>
  </xsl:template>

  <!-- Mode "t:statement t:module-item". debugger. -->
  <xsl:template mode="t:statement t:module-item" match="debugger">
    <xsl:sequence select="'debugger'"/>
    <xsl:sequence select="';'"/>
  </xsl:template>

</xsl:stylesheet>