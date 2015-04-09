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
    Gets block element.
      $element - a block element.
      Returns block as token sequence.
  -->
  <xsl:function name="t:get-block" as="item()+">
    <xsl:param name="element" as="element()"/>

    <xsl:sequence select="'{'"/>
    <xsl:sequence select="$t:new-line"/>
    <xsl:sequence select="$t:indent"/>
    <xsl:sequence select="t:get-comments($element)"/>
    <xsl:sequence select="t:get-statement-scope($element)"/>
    <xsl:sequence select="$t:unindent"/>
    <xsl:sequence select="'}'"/>
    <xsl:sequence select="$t:new-line"/>
  </xsl:function>

  <!--
    Generates statement scope.
      $scope - a scope of statements.
      Returns statement tokens.
  -->
  <xsl:function name="t:get-statement-scope" as="item()*">
    <xsl:param name="scope" as="element()"/>

    <xsl:variable name="statements" as="element()*"
      select="t:get-java-element($scope)"/>

    <xsl:for-each select="$statements">
      <xsl:variable name="position" as="xs:integer" select="position()"/>
      <xsl:variable name="previous" as="element()?"
        select="$statements[$position - 1]"/>

      <xsl:if test="
        ($position != 1) and
        (
          (
            not($previous[self::scope[empty(* except meta)]]) and
            not(self::statement) and
            not($previous[self::statement]) and
            not(self::assert and $previous[self::assert]) and
            not(self::expression and $previous[self::expression]) and
            not((self::var-decl) and $previous[self::var-decl])
          ) or
          comment or
          @label
        )">
        <xsl:sequence select="$t:new-line"/>
      </xsl:if>

      <xsl:apply-templates mode="t:statement" select="."/>
    </xsl:for-each>
  </xsl:function>

  <!--
    Mode "t:statement". Empty match.
  -->
  <xsl:template mode="t:statement" match="@* | node()">
    <xsl:choose>
      <xsl:when test="t:is-type-declaration(.)">
        <xsl:apply-templates mode="t:typeDeclaration" select="."/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:sequence select="
          error
          (
            xs:QName('invalid-statement'),
            t:get-path(.)
          )"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!--
    Mode "t:statement". Statement scope.
  -->
  <xsl:template mode="t:statement" match="scope">
    <xsl:sequence select="t:get-comments(.)"/>
    <xsl:sequence select="t:get-statement-scope(.)"/>
  </xsl:template>

  <!--
    Mode "t:statement". localVariableDeclaration.
  -->
  <xsl:template mode="t:statement" match="var-decl">
    <xsl:sequence select="t:get-comments(.)"/>
    <xsl:sequence select="t:get-annotations(., true())"/>

    <xsl:variable name="name" as="xs:string" select="@name"/>
    <xsl:variable name="final" as="xs:boolean?" select="@final"/>
    <xsl:variable name="initializer" as="item()*"
      select="t:get-initializer(., false())"/>

    <xsl:if test="$final">
      <xsl:sequence select="'final'"/>
      <xsl:sequence select="' '"/>
    </xsl:if>

    <xsl:sequence select="t:get-type(type)"/>
    <xsl:sequence select="' '"/>
    <xsl:sequence select="$name"/>

    <xsl:if test="exists($initializer)">
      <xsl:variable name="tokens" as="item()*">
        <xsl:sequence select="' '"/>
        <xsl:sequence select="'='"/>
        <xsl:sequence select="' '"/>
        <xsl:sequence select="$initializer"/>
      </xsl:variable>

      <xsl:sequence select="t:indent-from-second-line($tokens)"/>
    </xsl:if>

    <xsl:sequence select="';'"/>
    <xsl:sequence select="$t:new-line"/>
  </xsl:template>

  <!--
    Gets statement label, if any.
      $element - a statement element.
      Returns optional sequence of tokens that define statement label.
  -->
  <xsl:function name="t:get-statement-label" as="item()*">
    <xsl:param name="element" as="element()"/>

    <xsl:variable name="label" as="xs:string?" select="$element/@label"/>

    <xsl:if test="$label">
      <xsl:sequence select="$t:line-indent"/>
      <xsl:sequence select="$label"/>
      <xsl:sequence select="':'"/>
      <xsl:sequence select="$t:new-line"/>
    </xsl:if>
  </xsl:function>

  <!--
    Mode "t:statement". snippet-statement.
  -->
  <xsl:template mode="t:statement" match="snippet-statement">
    <xsl:sequence select="t:get-comments(.)"/>
    <xsl:sequence select="t:get-statement-label(.)"/>

    <xsl:variable name="value" as="xs:string" select="@value"/>

    <xsl:sequence select="t:tokenize($value)"/>
  </xsl:template>

  <!--
    Mode "t:statement". block.
  -->
  <xsl:template mode="t:statement" match="block">
    <xsl:sequence select="t:get-statement-label(.)"/>
    <xsl:sequence select="t:get-block(.)"/>
  </xsl:template>

  <!--
    Mode "t:statement". statement.
  -->
  <xsl:template mode="t:statement" match="statement">
    <xsl:variable name="comments" as="item()*"
      select="t:get-comments(.)"/>

    <xsl:choose>
      <xsl:when test="exists($comments)">
        <xsl:sequence select="$comments"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:sequence select="$t:new-line"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!--
    Mode "t:statement". assert.
  -->
  <xsl:template mode="t:statement" match="assert">
    <xsl:sequence select="t:get-comments(.)"/>
    <xsl:sequence select="t:get-statement-label(.)"/>

    <xsl:variable name="condition" as="element()" select="condition"/>
    <xsl:variable name="message" as="element()?" select="message"/>

    <xsl:variable name="expression-tokens" as="item()*"
      select="t:get-expression(t:get-java-element($condition))"/>

    <xsl:sequence select="'assert'"/>
    <xsl:sequence select="' '"/>
    <xsl:sequence select="$expression-tokens"/>

    <xsl:if test="exists($message)">
      <xsl:variable name="message-tokens" as="item()*"
        select="t:get-expression(t:get-java-element($message))"/>

      <xsl:sequence select="' '"/>
      <xsl:sequence select="':'"/>

      <xsl:choose>
        <xsl:when test="
            t:is-multiline($expression-tokens) or
            t:is-multiline($message-tokens)">

          <xsl:sequence select="$t:new-line"/>

          <xsl:sequence select="$t:indent"/>

          <xsl:sequence select="$message-tokens"/>

          <xsl:sequence select="$t:unindent"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:sequence select="' '"/>
          <xsl:sequence select="$message-tokens"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:if>

    <xsl:sequence select="';'"/>
    <xsl:sequence select="$t:new-line"/>
  </xsl:template>

  <!--
    Mode "t:statement". if.
      $else-if - true when if is a part of "else if" statements, and
      false otherwise.
  -->
  <xsl:template mode="t:statement" match="if">
    <xsl:param name="else-if" as="xs:boolean" select="false()"/>

    <xsl:if test="not($else-if)">
      <xsl:sequence select="t:get-comments(.)"/>
      <xsl:sequence select="t:get-statement-label(.)"/>
    </xsl:if>

    <xsl:variable name="condition" as="element()" select="condition"/>
    <xsl:variable name="then" as="element()" select="then"/>
    <xsl:variable name="else" as="element()?" select="else"/>

    <xsl:sequence select="'if'"/>
    <xsl:sequence select="' '"/>
    <xsl:sequence select="'('"/>

    <xsl:sequence select="
      t:indent-from-second-line
      (
        t:get-expression(t:get-java-element($condition))
      )"/>

    <xsl:sequence select="')'"/>
    <xsl:sequence select="$t:new-line"/>

    <xsl:variable name="then-statement" as="element()*"
      select="t:get-java-element($then)"/>

    <xsl:choose>
      <xsl:when test="
        (count($then-statement) = 1) and
        exists($then-statement[self::block[empty(@label)]])">
        <xsl:sequence select="t:get-block($then-statement)"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:sequence select="t:get-block($then)"/>
      </xsl:otherwise>
    </xsl:choose>

    <xsl:if test="$else">
      <xsl:variable name="else-statement" as="element()*"
        select="t:get-java-element($else)"/>

      <xsl:choose>
        <xsl:when test="
          (count($else-statement) = 1) and
          exists($else-statement[self::block[empty(@label)]])">
          <xsl:sequence select="'else'"/>
          <xsl:sequence select="$t:new-line"/>
          <xsl:sequence select="t:get-block($else-statement)"/>
        </xsl:when>
        <xsl:when test="
          (count($else-statement) = 1) and
          exists($else-statement[self::if]) and
          empty($else-statement/@label)">
          <xsl:sequence select="t:get-comments($else)"/>
          <xsl:sequence select="t:get-comments($else-statement)"/>
          <xsl:sequence select="'else'"/>
          <xsl:sequence select="' '"/>
          <xsl:apply-templates mode="t:statement" select="$else-statement">
            <xsl:with-param name="else-if" select="true()"/>
          </xsl:apply-templates>
        </xsl:when>
        <xsl:otherwise>
          <xsl:sequence select="'else'"/>
          <xsl:sequence select="$t:new-line"/>
          <xsl:sequence select="t:get-block($else)"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:if>
  </xsl:template>

  <!--
    Mode "t:statement". for.
  -->
  <xsl:template mode="t:statement" match="for">
    <xsl:sequence select="t:get-comments(.)"/>
    <xsl:sequence select="t:get-statement-label(.)"/>

    <xsl:variable name="vars" as="element()*" select="var-decl"/>
    <xsl:variable name="initialize" as="element()*" select="initialize"/>
    <xsl:variable name="condition" as="element()?" select="condition"/>
    <xsl:variable name="update" as="element()*" select="update"/>

    <xsl:if test="exists($vars)">
      <xsl:if test="exists($initialize)">
        <xsl:sequence select="
          error
          (
            xs:QName('var-initialize-mutually-exclusive'),
            'var and initialize are mutually exclusive.'
          )"/>
      </xsl:if>

      <xsl:variable name="count" as="xs:integer" select="count($vars)"/>

      <xsl:if test="$count gt 1">
        <xsl:variable name="type" as="element()" select="$vars[1]/type"/>

        <xsl:if test="
          some $other-type in subsequence($vars, 2)/type satisfies
            not(deep-equal($type, $other-type))">
          <xsl:sequence select="
            error
            (
              xs:QName('incompatible-vars'),
              'All var declarations should be of the same type.'
            )"/>
        </xsl:if>
      </xsl:if>
    </xsl:if>

    <xsl:variable name="tokens" as="item()*">
      <xsl:variable name="var-tokens" as="item()*">
        <xsl:for-each select="$vars">
          <xsl:variable name="name" as="xs:string" select="@name"/>
          <xsl:variable name="initializer" as="item()*"
            select="t:get-initializer(., false())"/>

          <xsl:sequence select="$name"/>

          <xsl:if test="exists($initializer)">
            <xsl:sequence select="' '"/>
            <xsl:sequence select="'='"/>
            <xsl:sequence select="' '"/>
            <xsl:sequence select="$initializer"/>
          </xsl:if>

          <xsl:if test="position() != last()">
            <xsl:sequence select="','"/>
          </xsl:if>

          <xsl:sequence select="$t:terminator"/>
        </xsl:for-each>

        <xsl:for-each select="$initialize">
          <xsl:sequence select="t:get-expression(t:get-java-element(.))"/>

          <xsl:if test="position() != last()">
            <xsl:sequence select="','"/>
          </xsl:if>

          <xsl:sequence select="$t:terminator"/>
        </xsl:for-each>
      </xsl:variable>

      <xsl:variable name="condition-tokens" as="item()*"
        select="$condition/t:get-expression(t:get-java-element(.))"/>

      <xsl:variable name="update-tokens" as="item()*">
        <xsl:for-each select="$update">
          <xsl:sequence select="t:get-expression(t:get-java-element(.))"/>

          <xsl:if test="position() != last()">
            <xsl:sequence select="','"/>
          </xsl:if>

          <xsl:sequence select="$t:terminator"/>
        </xsl:for-each>
      </xsl:variable>

      <xsl:variable name="verbose" as="xs:boolean" select="
        (count($vars) >= 3) or
        (count($update) >= 3) or
        t:is-multiline($var-tokens) or
        t:is-multiline($condition-tokens) or
        t:is-multiline($update-tokens)"/>

      <xsl:sequence select="
        t:reformat-tokens(
          $var-tokens,
          3,
          ' ',
          $t:new-line,
          false(),
          false()
        )"/>

      <xsl:sequence select="';'"/>

      <xsl:if test="exists($condition)">
        <xsl:sequence select="if ($verbose) then $t:new-line else ' '"/>
        <xsl:sequence select="$condition-tokens"/>
      </xsl:if>

      <xsl:sequence select="';'"/>

      <xsl:if test="exists($update)">
        <xsl:sequence select="if ($verbose) then $t:new-line else ' '"/>

        <xsl:sequence select="
          t:reformat-tokens
          (
            $update-tokens,
            3,
            ' ',
            $t:new-line,
            false(),
            false()
          )"/>
      </xsl:if>
    </xsl:variable>

    <xsl:sequence select="'for'"/>
    <xsl:sequence select="'('"/>

    <xsl:if test="exists($vars)">
      <xsl:variable name="var" as="element()" select="$vars[1]"/>
      <xsl:variable name="final" as="xs:boolean?" select="$var/@final"/>

      <xsl:sequence select="t:get-annotations($var, true())"/>

      <xsl:if test="$final">
        <xsl:sequence select="'final'"/>
        <xsl:sequence select="' '"/>
      </xsl:if>

      <xsl:sequence select="t:get-type($var/type)"/>
      <xsl:sequence select="' '"/>
    </xsl:if>

    <xsl:sequence select="t:indent-from-second-line($tokens)"/>

    <xsl:sequence select="')'"/>
    <xsl:sequence select="$t:new-line"/>

    <xsl:sequence select="t:get-block(block)"/>
  </xsl:template>

  <!--
    Mode "t:statement". for-each.
  -->
  <xsl:template mode="t:statement" match="for-each">
    <xsl:sequence select="t:get-comments(.)"/>
    <xsl:sequence select="t:get-statement-label(.)"/>

    <xsl:variable name="tokens" as="item()+">
      <xsl:variable name="var" as="element()" select="var-decl"/>
      <xsl:variable name="name" as="xs:string" select="$var/@name"/>
      <xsl:variable name="final" as="xs:boolean?" select="$var/@final"/>
      <xsl:variable name="initializer" as="item()+"
        select="t:get-initializer($var, false())"/>

      <xsl:sequence select="t:get-annotations($var, true())"/>

      <xsl:if test="$final">
        <xsl:sequence select="'final'"/>
        <xsl:sequence select="' '"/>
      </xsl:if>

      <xsl:sequence select="t:get-type($var/type)"/>
      <xsl:sequence select="' '"/>
      <xsl:sequence select="$name"/>

      <xsl:sequence select="':'"/>
      <xsl:sequence select="' '"/>
      <xsl:sequence select="$initializer"/>
    </xsl:variable>

    <xsl:sequence select="'for'"/>
    <xsl:sequence select="'('"/>

    <xsl:sequence select="t:indent-from-second-line($tokens)"/>

    <xsl:sequence select="')'"/>
    <xsl:sequence select="$t:new-line"/>

    <xsl:sequence select="t:get-block(block)"/>
  </xsl:template>

  <!--
    Mode "t:statement". while.
  -->
  <xsl:template mode="t:statement" match="while">
    <xsl:sequence select="t:get-comments(.)"/>
    <xsl:sequence select="t:get-statement-label(.)"/>

    <xsl:sequence select="'while'"/>
    <xsl:sequence select="'('"/>

    <xsl:variable name="tokens" as="item()+"
      select="t:get-expression(t:get-java-element(condition))"/>

    <xsl:sequence select="t:indent-from-second-line($tokens)"/>

    <xsl:sequence select="')'"/>
    <xsl:sequence select="$t:new-line"/>

    <xsl:sequence select="t:get-block(block)"/>
  </xsl:template>

  <!--
    Mode "t:statement". do-while.
  -->
  <xsl:template mode="t:statement" match="do-while">
    <xsl:sequence select="t:get-comments(.)"/>
    <xsl:sequence select="t:get-statement-label(.)"/>

    <xsl:sequence select="'do'"/>
    <xsl:sequence select="$t:new-line"/>

    <xsl:sequence select="t:get-block(block)"/>

    <xsl:sequence select="'while'"/>
    <xsl:sequence select="'('"/>

    <xsl:variable name="tokens" as="item()+"
      select="t:get-expression(t:get-java-element(condition))"/>

    <xsl:sequence select="t:indent-from-second-line($tokens)"/>

    <xsl:sequence select="')'"/>
    <xsl:sequence select="';'"/>
    <xsl:sequence select="$t:new-line"/>
  </xsl:template>

  <!--
    Mode "t:statement". try.
  -->
  <xsl:template mode="t:statement" match="try">
    <xsl:sequence select="t:get-comments(.)"/>
    <xsl:sequence select="t:get-statement-label(.)"/>

    <xsl:variable name="resource" as="element()?" select="resource"/>
    <xsl:variable name="catch" as="element()*" select="catch"/>
    <xsl:variable name="finally" as="element()?" select="finally"/>

    <xsl:if test="empty($resource) and empty($catch) and empty($finally)">
      <xsl:sequence select="
        error
        (
          xs:QName('invalid-try'),
          'Either resource, catch or finally element is expected.'
        )"/>
    </xsl:if>

    <xsl:sequence select="'try'"/>

    <xsl:if test="$resource">
      <xsl:variable name="vars" as="element()+"
        select="$resource/var-decl"/>

      <xsl:sequence select="'('"/>

      <xsl:for-each select="$vars">
        <xsl:variable name="name" as="xs:string" select="@name"/>
        <xsl:variable name="final" as="xs:boolean?" select="@final"/>
        <xsl:variable name="initializer" as="item()+"
            select="t:get-initializer(., true())"/>

        <xsl:if test="$final">
          <xsl:sequence select="'final'"/>
          <xsl:sequence select="' '"/>
        </xsl:if>

        <xsl:sequence select="t:get-type(type)"/>
        <xsl:sequence select="' '"/>

        <xsl:sequence select="$name"/>
        <xsl:sequence select="' '"/>
        <xsl:sequence select="'='"/>
        <xsl:sequence select="' '"/>
        <xsl:sequence select="$initializer"/>

        <xsl:if test="position() != last()">
          <xsl:sequence select="';'"/>
          <xsl:sequence select="$t:soft-line-break"/>
        </xsl:if>
      </xsl:for-each>

      <xsl:sequence select="')'"/>
    </xsl:if>
    
    <xsl:sequence select="$t:new-line"/>

    <xsl:sequence select="t:get-block(block)"/>

    <xsl:for-each select="$catch">
      <xsl:variable name="parameter" as="element()" select="parameter"/>
      <xsl:variable name="name" as="xs:string" select="$parameter/@name"/>
      <xsl:variable name="final" as="xs:boolean?" select="$parameter/@final"/>
      <xsl:variable name="types" as="element()+" select="$parameter/type"/>

      <xsl:sequence select="'catch'"/>
      <xsl:sequence select="'('"/>

      <xsl:sequence select="t:get-annotations($parameter, true())"/>

      <xsl:if test="$final">
        <xsl:sequence select="'final'"/>
        <xsl:sequence select="' '"/>
      </xsl:if>

      <xsl:for-each select="$types">
        <xsl:sequence select="t:get-type(.)"/>

        <xsl:if test="position() != last()">
          <xsl:sequence select="' '"/>
          <xsl:sequence select="'|'"/>
          <xsl:sequence select="' '"/>
          <xsl:sequence select="$t:soft-line-break"/>
        </xsl:if>
      </xsl:for-each>

      <xsl:sequence select="' '"/>
      <xsl:sequence select="$name"/>
      <xsl:sequence select="')'"/>
      <xsl:sequence select="$t:new-line"/>

      <xsl:sequence select="t:get-block(block)"/>
    </xsl:for-each>

    <xsl:if test="$finally">
      <xsl:sequence select="'finally'"/>
      <xsl:sequence select="$t:new-line"/>

      <xsl:variable name="statement" as="element()*"
        select="t:get-java-element($finally)"/>

      <xsl:choose>
        <xsl:when test="
          (count($statement) = 1) and
          exists($statement[self::block[empty(@label)]])">
          <xsl:sequence select="t:get-block($statement)"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:sequence select="t:get-block($finally)"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:if>
  </xsl:template>

  <!--
    Mode "t:statement". switch.
  -->
  <xsl:template mode="t:statement" match="switch">
    <xsl:sequence select="t:get-comments(.)"/>
    <xsl:sequence select="t:get-statement-label(.)"/>

    <xsl:sequence select="'switch'"/>
    <xsl:sequence select="'('"/>

    <xsl:variable name="tokens" as="item()+"
      select="t:get-expression(t:get-java-element(test))"/>

    <xsl:sequence select="t:indent-from-second-line($tokens)"/>

    <xsl:sequence select="')'"/>
    <xsl:sequence select="$t:new-line"/>

    <xsl:sequence select="'{'"/>
    <xsl:sequence select="$t:new-line"/>

    <xsl:sequence select="$t:indent"/>

    <xsl:variable name="case" as="element()+" select="case"/>

    <xsl:for-each select="$case">
      <xsl:variable name="value" as="element()?" select="value"/>

      <xsl:choose>
        <xsl:when test="exists($value)">
          <xsl:variable name="enumValue" as="xs:string?"
            select="$value/@enum"/>

          <xsl:choose>
            <xsl:when test="exists($enumValue)">
              <xsl:sequence select="'case'"/>
              <xsl:sequence select="' '"/>
              <xsl:sequence select="$enumValue"/>
              <xsl:sequence select="':'"/>
              <xsl:sequence select="$t:new-line"/>
            </xsl:when>
            <xsl:otherwise>
              <xsl:sequence select="'case'"/>
              <xsl:sequence select="' '"/>

              <xsl:variable name="value-tokens" as="item()+"
                select="t:get-expression(t:get-java-element($value))"/>

              <xsl:sequence select="t:indent-from-second-line($value-tokens)"/>

              <xsl:sequence select="':'"/>
              <xsl:sequence select="$t:new-line"/>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:when>
        <xsl:otherwise>
          <xsl:sequence select="'default'"/>
          <xsl:sequence select="':'"/>
          <xsl:sequence select="$t:new-line"/>
        </xsl:otherwise>
      </xsl:choose>

      <xsl:sequence select="block/t:get-block(.)"/>
    </xsl:for-each>

    <xsl:sequence select="$t:unindent"/>

    <xsl:sequence select="'}'"/>
    <xsl:sequence select="$t:new-line"/>
  </xsl:template>

  <!--
    Mode "t:statement". synchronized.
  -->
  <xsl:template mode="t:statement" match="synchronized">
    <xsl:sequence select="t:get-comments(.)"/>
    <xsl:sequence select="t:get-statement-label(.)"/>

    <xsl:sequence select="'synchronized'"/>
    <xsl:sequence select="'('"/>

    <xsl:variable name="tokens" as="item()+"
      select="t:get-expression(t:get-java-element(monitor))"/>

    <xsl:sequence select="t:indent-from-second-line($tokens)"/>

    <xsl:sequence select="')'"/>
    <xsl:sequence select="$t:new-line"/>

    <xsl:sequence select="t:get-block(block)"/>
  </xsl:template>

  <!--
    Mode "t:statement". return.
  -->
  <xsl:template mode="t:statement" match="return">
    <xsl:sequence select="t:get-comments(.)"/>
    <xsl:sequence select="t:get-statement-label(.)"/>

    <xsl:variable name="expression" as="element()?"
      select="t:get-java-element(.)"/>

    <xsl:sequence select="'return'"/>

    <xsl:if test="$expression">
      <xsl:sequence select="' '"/>

      <xsl:variable name="tokens" as="item()+"
        select="t:get-expression($expression)"/>

      <xsl:sequence select="t:indent-from-second-line($tokens)"/>
    </xsl:if>

    <xsl:sequence select="';'"/>
    <xsl:sequence select="$t:new-line"/>
  </xsl:template>

  <!--
    Mode "t:statement". throw.
  -->
  <xsl:template mode="t:statement" match="throw">
    <xsl:sequence select="t:get-comments(.)"/>
    <xsl:sequence select="t:get-statement-label(.)"/>

    <xsl:sequence select="'throw'"/>
    <xsl:sequence select="' '"/>

    <xsl:variable name="tokens" as="item()+"
      select="t:get-expression(t:get-java-element(.))"/>

    <xsl:sequence select="t:indent-from-second-line($tokens)"/>

    <xsl:sequence select="';'"/>
    <xsl:sequence select="$t:new-line"/>
  </xsl:template>

  <!--
    Mode "t:statement". break.
  -->
  <xsl:template mode="t:statement" match="break">
    <xsl:sequence select="t:get-comments(.)"/>
    <xsl:sequence select="t:get-statement-label(.)"/>

    <xsl:variable name="label" as="xs:string?" select="@destination-label"/>

    <xsl:sequence select="'break'"/>

    <xsl:if test="exists($label)">
      <xsl:sequence select="' '"/>
      <xsl:sequence select="$label"/>
    </xsl:if>

    <xsl:sequence select="';'"/>
    <xsl:sequence select="$t:new-line"/>
  </xsl:template>

  <!--
    Mode "t:statement". continue.
  -->
  <xsl:template mode="t:statement" match="continue">
    <xsl:sequence select="t:get-comments(.)"/>
    <xsl:sequence select="t:get-statement-label(.)"/>

    <xsl:variable name="label" as="xs:string?" select="@destination-label"/>

    <xsl:sequence select="'continue'"/>

    <xsl:if test="exists($label)">
      <xsl:sequence select="' '"/>
      <xsl:sequence select="$label"/>
    </xsl:if>

    <xsl:sequence select="';'"/>
    <xsl:sequence select="$t:new-line"/>
  </xsl:template>

  <!--
    Mode "t:statement". expression.
  -->
  <xsl:template mode="t:statement" match="expression">
    <xsl:sequence select="t:get-comments(.)"/>
    <xsl:sequence select="t:get-statement-label(.)"/>

    <xsl:variable name="tokens" as="item()+"
      select="t:get-expression(t:get-java-element(.))"/>

    <xsl:sequence select="t:indent-from-second-line($tokens)"/>

    <xsl:sequence select="';'"/>
    <xsl:sequence select="$t:new-line"/>
  </xsl:template>

</xsl:stylesheet>