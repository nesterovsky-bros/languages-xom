<?xml version="1.0" encoding="utf-8"?>
<!-- This stylesheet introduces a support for a complex expressions. -->
<xsl:stylesheet version="2.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:t="http://www.bphx.com/jxom"
  xmlns:p="http://www.bphx.com/jxom/private/java-complex-expression"
  xmlns="http://www.bphx.com/java-1.5/2008-02-07"
  xpath-default-namespace="http://www.bphx.com/java-1.5/2008-02-07"
  exclude-result-prefixes="xs t p">

  <!--
  <xsl:include href="java-optimizer.xslt"/>

  <xsl:template match="/">
    <xsl:sequence select="t:refactor-statements-with-complex-expressions(*)"/>
  </xsl:template>
  -->

  <!--
    This API supports refactoring of lambda expressions in the form:
    
    com.nesterovskyBros.Supplier.get(() => { statements... return result; })
    
    com.nesterovskyBros.Supplier class is assumed has get() overload for 
    every return type, and returns a value from a lambda function call.
    
    The API refactors:
    
    expression ... com.nesterovskyBros.Supplier.get(() => { statements... return result; }) ... expression
    
    into:
    
    statements;
    
    expression ... result ... expression.

    The lambda expression has a following format:
      <static-invoke name="get">
        <type name="Supplier" package="com.nesterovskyBros"/>
        <arguments>
          <lambda>
            <block>
              statements.
            
              <return>
                ...
              </return>
            </block>
          </lambda>
        </arguments>
      </static-invoke>
  -->

  <!--
    Refactors complex expression into a closure ($scope, $expression),
    where $scope - is a statement scope, and $expression is
    refactored expression.
      $expression - an expression to refactor.
      Returns a closure ($scope, $expression).
  -->
  <xsl:function name="t:refactor-complex-expression" as="element()+">
    <xsl:param name="expression" as="element()"/>

    <xsl:variable name="complex-expressions" as="element()*" select="
      t:get-complex-expressions($expression)
      [
        not
        (
          (
            ancestor::class-method |
            ancestor::method |
            ancestor::constructor | 
            ancestor::class-initializer |
            ancestor::lambda
          )
          [
            . >> $expression
          ]
        )
      ]"/>

    <xsl:choose>
      <xsl:when test="
        $complex-expressions/
          (
            ancestor::and, 
            ancestor::or, 
            ancestor::condition[count(t:get-java-element(.)) = 3]
          )">
        
        <xsl:variable name="condition" as="element()">
          <xsl:apply-templates mode="p:refactor-complex-condition" 
            select="$expression"/>
        </xsl:variable>

        <xsl:sequence select="t:refactor-complex-expression($condition)"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:variable name="statements" as="element()*" select="
          $complex-expressions/arguments/lambda/
            t:get-java-element(block)[not(self::return)]"/>

        <scope>
          <xsl:sequence
            select="t:refactor-statements-with-complex-expressions($statements)"/>
        </scope>

        <xsl:apply-templates mode="p:refactor-complex-expression"
          select="$expression"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:function>

  <!--
    Refactors statements containing complex expressions.
      $statements - a sequence of statements to refactor.
      Returns refactored statements.
  -->
  <xsl:function name="t:refactor-statements-with-complex-expressions"
    as="element()*">
    <xsl:param name="statements" as="element()*"/>

    <xsl:apply-templates mode="p:refactor-complex-statement"
      select="$statements"/>
  </xsl:function>

  <!--
    Mode "p:refactor-complex-expression". Default match.
  -->
  <xsl:template mode="p:refactor-complex-expression" match="*">
    <xsl:copy>
      <xsl:sequence select="@*"/>
      <xsl:apply-templates mode="#current"/>
    </xsl:copy>
  </xsl:template>

  <!--
    Mode "p:refactor-complex-expression". Metas and comments.
  -->
  <xsl:template mode="p:refactor-complex-expression" match="meta | comment">
    <xsl:sequence select="."/>
  </xsl:template>

  <!--
    Mode "p:refactor-complex-expression". Complex expression.
  -->
  <xsl:template mode="p:refactor-complex-expression" match="
    static-invoke[@name = 'get']
    [
      type
      [
        (@name = $t:complex-type/@name) and 
        (@package = $t:complex-type/@package)
      ]
    ]">

    <xsl:variable name="result" as="element()"
      select="t:get-java-element(arguments/lambda/block/return)"/>

    <xsl:apply-templates mode="#current" select="$result"/>
  </xsl:template>

  <!--
    Mode "p:refactor-complex-expression". block statement.
  -->
  <xsl:template mode="p:refactor-complex-expression" match="block">
    <xsl:sequence select="t:refactor-statements-with-complex-expressions(.)"/>
  </xsl:template>

  <!--
    Mode "p:refactor-complex-condition". Default match.
  -->
  <xsl:template mode="p:refactor-complex-condition" match="*">
    <xsl:copy>
      <xsl:sequence select="@*"/>
      <xsl:apply-templates mode="#current"/>
    </xsl:copy>
  </xsl:template>

  <!--
    Mode "p:refactor-complex-condition". Metas and comments.
  -->
  <xsl:template mode="p:refactor-complex-condition" match="meta | comment">
    <xsl:sequence select="."/>
  </xsl:template>

  <!--
    Mode "p:refactor-complex-condition". and expression.
  -->
  <xsl:template mode="p:refactor-complex-condition"
    match="and[t:contains-complex-expression(.)]">

    <xsl:variable name="arguments" as="element()+"
      select="t:get-java-element(.)"/>
    <xsl:variable name="name-id" as="xs:string" 
      select="concat(generate-id(), '.complex-condition')"/>
    
    <xsl:variable name="condition" as="element()">
      <var name="condition" name-ref="{$name-id}">
        <meta>
          <type name="boolean"/>
        </meta>
      </var>
    </xsl:variable>

    <xsl:variable name="statements" as="element()+">
      <var-decl name="condition" name-id="{$name-id}">
        <type name="boolean"/>
        <initialize>
          <xsl:sequence select="$arguments[1]"/>
        </initialize>
      </var-decl>

      <if>
        <condition>
          <xsl:sequence select="$condition"/>
        </condition>
        <then>
          <expression>
            <assign>
              <xsl:sequence select="$condition"/>
              <xsl:sequence select="subsequence($arguments, 2)"/>
            </assign>
          </expression>
        </then>
      </if>

      <return>
        <xsl:sequence select="$condition"/>
      </return>
    </xsl:variable>

    <xsl:sequence select="t:create-complex-expression($statements)"/>
  </xsl:template>

  <!--
    Mode "p:refactor-complex-condition". or expression.
  -->
  <xsl:template mode="p:refactor-complex-condition"
    match="or[t:contains-complex-expression(.)]">

    <xsl:variable name="arguments" as="element()+"
      select="t:get-java-element(.)"/>
    <xsl:variable name="name-id" as="xs:string"
      select="concat(generate-id(), '.complex-condition')"/>

    <xsl:variable name="condition" as="element()">
      <var name="condition" name-ref="{$name-id}">
        <meta>
          <type name="boolean"/>
        </meta>
      </var>
    </xsl:variable>

    <xsl:variable name="statements" as="element()+">
      <var-decl name="condition" name-id="{$name-id}">
        <type name="boolean"/>
        <initialize>
          <xsl:sequence select="$arguments[1]"/>
        </initialize>
      </var-decl>

      <if>
        <condition>
          <not>
            <xsl:sequence select="$condition"/>
          </not>
        </condition>
        <then>
          <expression>
            <assign>
              <xsl:sequence select="$condition"/>
              <xsl:sequence select="subsequence($arguments, 2)"/>
            </assign>
          </expression>
        </then>
      </if>

      <return>
        <xsl:sequence select="$condition"/>
      </return>
    </xsl:variable>

    <xsl:sequence select="t:create-complex-expression($statements)"/>
  </xsl:template>

  <!--
    Mode "p:refactor-complex-condition". condition expression.
  -->
  <xsl:template mode="p:refactor-complex-condition" match="
    condition[t:contains-complex-expression(.)]
    [
      count(t:get-java-element(.)) = 3
    ]">

    <xsl:variable name="arguments" as="element()+"
      select="t:get-java-element(.)"/>
    <xsl:variable name="name-id" as="xs:string"
      select="concat(generate-id(), '.complex-condition')"/>
    
    <xsl:variable name="type" as="element()" 
      select="t:get-type-of(., true())"/>

    <xsl:variable name="value" as="element()">
      <var name="value" name-ref="{$name-id}">
        <meta>
          <xsl:sequence select="$type"/>
        </meta>
      </var>
    </xsl:variable>

    <xsl:variable name="statements" as="element()+">
      <var-decl name="value" name-id="{$name-id}">
        <xsl:sequence select="$type"/>
      </var-decl>

      <if>
        <condition>
          <xsl:sequence select="$arguments[1]"/>
        </condition>
        <then>
          <expression>
            <assign>
              <xsl:sequence select="$value"/>
              <xsl:sequence select="$arguments[2]"/>
            </assign>
          </expression>
        </then>
        <else>
          <expression>
            <assign>
              <xsl:sequence select="$value"/>
              <xsl:sequence select="subsequence($arguments, 3)"/>
            </assign>
          </expression>
        </else>
      </if>

      <return>
        <xsl:sequence select="$value"/>
      </return>
    </xsl:variable>

    <xsl:sequence select="t:create-complex-expression($statements)"/>
  </xsl:template>

  <!--
    Mode "p:refactor-complex-statement". Default match.
  -->
  <xsl:template mode="p:refactor-complex-statement" match="*"
    name="p:refactor-complex-statement-default">
    <xsl:copy>
      <xsl:sequence select="@*"/>
      <xsl:apply-templates mode="#current"/>
    </xsl:copy>
  </xsl:template>

  <!--
    Mode "p:refactor-complex-statement". Metas and comments.
  -->
  <xsl:template mode="p:refactor-complex-statement" match="meta | comment">
    <xsl:sequence select="."/>
  </xsl:template>

  <!--
    Mode "p:refactor-complex-statement".
    Variable declaration with initializer.
  -->
  <xsl:template mode="p:refactor-complex-statement"
    match="var-decl[initialize/t:contains-complex-expression(.) = true()]">
    
    <xsl:variable name="initialize" as="element()" select="initialize"/>
    <xsl:variable name="closure" as="element()+"
      select="t:refactor-complex-expression($initialize)"/>

    <xsl:variable name="scope" as="element()" select="$closure[1]"/>
    <xsl:variable name="new-initialize" as="element()" select="$closure[2]"/>

    <xsl:sequence select="t:get-java-element($scope)"/>

    <xsl:copy>
      <xsl:sequence select="@*"/>
      <xsl:sequence select="comment | meta | annotation | type"/>
      <xsl:sequence select="$new-initialize"/>
    </xsl:copy>
  </xsl:template>

  <!--
    Mode "p:refactor-complex-statement".
    "assert" statement.
  -->
  <xsl:template mode="p:refactor-complex-statement" match="
    assert[(condition, message)/t:contains-complex-expression(.) = true()]">
    
    <xsl:variable name="condition" as="element()" select="condition"/>
    <xsl:variable name="message" as="element()?" select="message"/>

    <xsl:variable name="complex-condition" as="xs:boolean"
      select="t:contains-complex-expression($condition)"/>
    <xsl:variable name="complex-message" as="xs:boolean"
      select="$message/t:contains-complex-expression(.) = true()"/>

    <xsl:choose>
      <xsl:when test="not($complex-message)">
        <xsl:variable name="closure" as="element()+"
          select="t:refactor-complex-expression($condition)"/>
        <xsl:variable name="scope" as="element()" select="$closure[1]"/>
        <xsl:variable name="new-condition" as="element()"
          select="$closure[2]"/>

        <xsl:sequence select="t:get-java-element($scope)"/>

        <assert>
          <xsl:sequence select="@*"/>
          <xsl:sequence select="comment | meta"/>

          <xsl:sequence select="$new-condition"/>
          <xsl:sequence select="$message"/>
        </assert>
      </xsl:when>
      <xsl:otherwise>
        <xsl:variable name="message-closure" as="element()+"
          select="t:refactor-complex-expression($message)"/>
        <xsl:variable name="message-scope" as="element()"
          select="$message-closure[1]"/>
        <xsl:variable name="new-message" as="element()"
          select="$message-closure[2]"/>

        <xsl:variable name="block" as="element()+">
          <xsl:sequence select="t:get-java-element($message-scope)"/>

          <assert>
            <xsl:sequence select="@*"/>
            <xsl:sequence select="comment | meta"/>

            <condition>
              <boolean value="false"/>
            </condition>

            <xsl:sequence select="$new-message"/>
          </assert>
        </xsl:variable>

        <xsl:choose>
          <xsl:when test="$complex-condition">
            <xsl:variable name="closure" as="element()+"
              select="t:refactor-complex-expression($condition)"/>
            <xsl:variable name="scope" as="element()"
              select="$closure[1]"/>
            <xsl:variable name="new-condition" as="element()"
              select="$closure[2]"/>

            <xsl:sequence select="t:get-java-element($scope)"/>

            <if>
              <xsl:sequence select="$new-condition"/>

              <then>
                <xsl:sequence select="$block"/>
              </then>
            </if>
          </xsl:when>
          <xsl:otherwise>
            <if>
              <xsl:sequence select="$condition"/>

              <then>
                <xsl:sequence select="$block"/>
              </then>
            </if>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!--
    Mode "p:refactor-complex-statement".
    "if" statement with complex condition.
  -->
  <xsl:template mode="p:refactor-complex-statement"
    match="if[t:contains-complex-expression(condition)]">
    
    <xsl:variable name="condition" as="element()" select="condition"/>
    <xsl:variable name="closure" as="element()+"
      select="t:refactor-complex-expression($condition)"/>
    <xsl:variable name="scope" as="element()" select="$closure[1]"/>
    <xsl:variable name="new-condition" as="element()" select="$closure[2]"/>

    <xsl:sequence select="t:get-java-element($scope)"/>

    <xsl:copy>
      <xsl:sequence select="@*"/>
      <xsl:sequence select="comment | meta"/>
      <xsl:sequence select="$new-condition"/>
      <xsl:apply-templates mode="#current" select="then | else"/>
    </xsl:copy>
  </xsl:template>

  <!--
    Mode "p:refactor-complex-statement".
    "for" statement with complex var-decl,
    initialize, condition, or update expressions.
      $continue-targets - a set of statements, which are target of a
        continue statement, and refactored in the way that continue should
        be changed to a break statement.
  -->
  <xsl:template mode="p:refactor-complex-statement" match="
    for
    [
      (var-decl, initialize, condition, update)/
        t:contains-complex-expression(.) = true()
    ]">
    <xsl:param name="continue-targets" tunnel="yes" as="element()*"/>

    <xsl:variable name="statement" as="element()" select="."/>
    <xsl:variable name="var-decl" as="element()*" select="var-decl"/>
    <xsl:variable name="initialize" as="element()*" select="initialize"/>
    <xsl:variable name="condition" as="element()?" select="condition"/>
    <xsl:variable name="update" as="element()*" select="update"/>

    <xsl:variable name="complex-var-decl" as="xs:boolean"
      select="$var-decl/t:contains-complex-expression(.) = true()"/>
    <xsl:variable name="complex-initialize" as="xs:boolean"
      select="$initialize/t:contains-complex-expression(.) = true()"/>
    <xsl:variable name="complex-condition" as="xs:boolean"
      select="$condition/t:contains-complex-expression(.) = true()"/>
    <xsl:variable name="complex-update" as="xs:boolean"
      select="$update/t:contains-complex-expression(.) = true()"/>

    <xsl:variable name="block" as="element()" select="block"/>

    <xsl:variable name="has-continue" as="xs:boolean" select="
      exists
      (
        $block//continue
        [
          t:get-statement-for-break($statement, .) is $statement
        ]
      )"/>

    <xsl:choose>
      <xsl:when test="$complex-initialize">
        <xsl:for-each select="$initialize">
          <xsl:variable name="closure" as="element()+"
            select="t:refactor-complex-expression(.)"/>
          <xsl:variable name="scope" as="element()"
            select="$closure[1]"/>
          <xsl:variable name="expression" as="element()"
            select="$closure[2]"/>

          <xsl:sequence select="t:get-java-element($scope)"/>

          <expression>
            <xsl:sequence select="$expression/node()"/>
          </expression>
        </xsl:for-each>
      </xsl:when>
      <xsl:otherwise>
        <xsl:for-each select="$initialize">
          <expression>
            <xsl:sequence select="node()"/>
          </expression>
        </xsl:for-each>
      </xsl:otherwise>
    </xsl:choose>

    <xsl:choose>
      <xsl:when test="
        ($complex-var-decl or $complex-initialize) and
        not($complex-condition) and
        not($complex-update)">

        <xsl:variable name="closure" as="element()*"
          select="$var-decl/initialize/t:refactor-complex-expression(.)"/>

        <xsl:sequence
          select="$closure[(position() mod 2) = 1]/t:get-java-element(.)"/>

        <xsl:copy>
          <xsl:sequence select="@*"/>
          <xsl:sequence select="comment | meta"/>

          <xsl:for-each select="$var-decl">
            <xsl:variable name="index" as="xs:integer" select="position()"/>
            <xsl:variable name="refactored-initialize" as="element()"
              select="$closure[$index * 2]"/>

            <xsl:copy>
              <xsl:sequence select="@*"/>
              <xsl:sequence 
                select="comment | meta | annotations | annotation | type"/>

              <xsl:sequence select="$refactored-initialize"/>
            </xsl:copy>
          </xsl:for-each>

          <xsl:sequence select="$condition"/>
          <xsl:sequence select="$update"/>
          <xsl:sequence select="$block"/>
        </xsl:copy>
      </xsl:when>
      <xsl:otherwise>
        <xsl:variable name="for-block" as="element()*">
          <xsl:choose>
            <xsl:when test="$complex-update">
              <xsl:choose>
                <xsl:when test="$has-continue">
                  <xsl:variable name="label-id" as="xs:string" select="
                    concat(generate-id(), '.iterator.complex-expression')"/>

                  <block label="iteration" label-id="{$label-id}">
                    <xsl:apply-templates mode="#current" select="$block/node()">
                      <xsl:with-param name="continue-targets" tunnel="yes"
                        select="$continue-targets, ."/>
                    </xsl:apply-templates>
                  </block>
                </xsl:when>
                <xsl:otherwise>
                  <xsl:apply-templates mode="#current" select="$block/node()"/>
                </xsl:otherwise>
              </xsl:choose>

              <xsl:for-each select="$update">
                <xsl:variable name="closure" as="element()+"
                  select="t:refactor-complex-expression(.)"/>
                <xsl:variable name="scope" as="element()"
                  select="$closure[1]"/>
                <xsl:variable name="expression" as="element()"
                  select="$closure[2]"/>

                <xsl:sequence select="t:get-java-element($scope)"/>

                <expression>
                  <xsl:sequence select="$expression/node()"/>
                </expression>
              </xsl:for-each>
            </xsl:when>
            <xsl:otherwise>
              <xsl:apply-templates mode="#current" select="$block/node()"/>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:variable>

        <xsl:variable name="while" as="element()">
          <xsl:choose>
            <xsl:when test="$complex-condition">
              <while>
                <condition>
                  <boolean value="true"/>
                </condition>
                <block>
                  <xsl:variable name="closure" as="element()+"
                    select="t:refactor-complex-expression($condition)"/>
                  <xsl:variable name="scope" as="element()+" select="$closure[1]"/>
                  <xsl:variable name="new-condition" as="element()+"
                    select="$closure[2]"/>

                  <xsl:sequence select="t:get-java-element($scope)"/>

                  <if>
                    <condition>
                      <xsl:sequence select="
                        t:generate-not-expression
                        (
                          t:get-java-element($new-condition)
                        )"/>
                    </condition>
                    <then>
                      <break/>
                    </then>
                  </if>

                  <xsl:sequence select="$for-block"/>
                </block>
              </while>
            </xsl:when>
            <xsl:otherwise>
              <while>
                <xsl:sequence select="comment | meta"/>

                <xsl:choose>
                  <xsl:when test="exists($condition)">
                    <xsl:sequence select="$condition"/>
                  </xsl:when>
                  <xsl:otherwise>
                    <condition>
                      <boolean value="true"/>
                    </condition>
                  </xsl:otherwise>
                </xsl:choose>

                <block>
                  <xsl:sequence select="$for-block"/>
                </block>
              </while>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:variable>

        <xsl:choose>
          <xsl:when test="exists($var-decl)">
            <block>
              <xsl:apply-templates mode="#current" select="$var-decl"/>
              <xsl:sequence select="$while"/>
            </block>
          </xsl:when>
          <xsl:otherwise>
            <xsl:sequence select="$while"/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!--
    Mode "p:refactor-complex-statement".
    "for-each" statement with complex var-decl.
  -->
  <xsl:template mode="p:refactor-complex-statement"
    match="for-each[t:contains-complex-expression(var-decl)]">
    
    <xsl:variable name="var-decl" as="element()" select="var-decl"/>
    <xsl:variable name="initialize" as="element()"
      select="$var-decl/initialize"/>

    <xsl:variable name="type" as="element()" select="$var-decl/type"/>
    <xsl:variable name="collection-type" as="element()?" select="
      t:get-type-of(t:get-java-element($var-decl/initialize), false())"/>

    <xsl:variable name="iterator-var-id" as="xs:string"
      select="concat(generate-id(), '.iterator.complex-expression')"/>

    <xsl:variable name="closure" as="element()+"
      select="t:refactor-complex-expression($initialize)"/>
    <xsl:variable name="scope" as="element()"
      select="$closure[1]"/>
    <xsl:variable name="new-initialize" as="element()"
      select="$closure[2]"/>

    <xsl:sequence select="t:get-java-element($scope)"/>

    <var-decl name="iterator" name-id="{$iterator-var-id}">
      <xsl:choose>
        <xsl:when test="exists($collection-type)">
          <xsl:sequence select="$collection-type"/>
        </xsl:when>
        <xsl:otherwise>
          <type name="Iterator" package="java.util">
            <argument>
              <xsl:sequence select="t:get-boxed-type($type)"/>
            </argument>
          </type>
        </xsl:otherwise>
      </xsl:choose>
      <xsl:sequence select="$new-initialize"/>
    </var-decl>

    <for-each>
      <xsl:sequence select="meta | comment"/>

      <var-decl>
        <xsl:sequence select="$var-decl/@*"/>
        <xsl:sequence select="$var-decl/(annotations | annotation)"/>
        <xsl:sequence select="$type"/>

        <initialize>
          <var name="iterator" name-ref="{$iterator-var-id}"/>
        </initialize>
      </var-decl>

      <xsl:apply-templates mode="#current" select="block"/>
    </for-each>
  </xsl:template>

  <!--
    Mode "p:refactor-complex-statement".
    "while" statement with complex condition.
  -->
  <xsl:template mode="p:refactor-complex-statement"
    match="while[t:contains-complex-expression(condition)]">
    
    <xsl:variable name="condition" as="element()" select="condition"/>

    <xsl:copy>
      <xsl:sequence select="@*"/>
      <xsl:sequence select="meta | comment"/>

      <condition>
        <boolean value="true"/>
      </condition>
      <block>
        <xsl:variable name="closure" as="element()+"
          select="t:refactor-complex-expression($condition)"/>
        <xsl:variable name="scope" as="element()"
          select="$closure[1]"/>
        <xsl:variable name="new-condition" as="element()"
          select="$closure[2]"/>

        <xsl:sequence select="t:get-java-element($scope)"/>

        <if>
          <condition>
            <xsl:sequence select="
              t:generate-not-expression
              (
                t:get-java-element($new-condition)
              )"/>
          </condition>
          <then>
            <break/>
          </then>
        </if>

        <xsl:apply-templates mode="#current" select="block/node()"/>
      </block>
    </xsl:copy>
  </xsl:template>

  <!--
    Mode "p:refactor-complex-statement".
    "do-while" statement with complex condition.
      $continue-targets - a set of statements, which a target of a
        continue statement, and refactored in the way that continue should
        be changed to a break statement.
  -->
  <xsl:template mode="p:refactor-complex-statement"
    match="do-while[t:contains-complex-expression(condition)]">
    <xsl:param name="continue-targets" tunnel="yes" as="element()*"/>

    <xsl:variable name="statement" as="element()" select="."/>
    <xsl:variable name="condition" as="element()" select="condition"/>
    <xsl:variable name="block" as="element()" select="block"/>

    <xsl:variable name="has-continue" as="xs:boolean" select="
      exists
      (
        $block//continue
        [
          t:get-statement-for-break($statement, .) is $statement
        ]
      )"/>

    <xsl:variable name="closure" as="element()+"
      select="t:refactor-complex-expression($condition)"/>
    <xsl:variable name="scope" as="element()"
      select="$closure[1]"/>
    <xsl:variable name="new-condition" as="element()"
      select="$closure[2]"/>

    <while>
      <condition>
        <boolean value="true"/>
      </condition>
      <block>
        <xsl:sequence select="meta | comment"/>

        <xsl:choose>
          <xsl:when test="$has-continue">
            <xsl:variable name="label-id" as="xs:string"
              select="concat(generate-id(), '.iterator.complex-expression')"/>

            <block label="iteration" label-id="{$label-id}">
              <xsl:apply-templates mode="#current" select="$block/node()">
                <xsl:with-param name="continue-targets" tunnel="yes"
                  select="$continue-targets, ."/>
              </xsl:apply-templates>
            </block>
          </xsl:when>
          <xsl:otherwise>
            <xsl:apply-templates mode="#current" select="block/node()"/>
          </xsl:otherwise>
        </xsl:choose>

        <xsl:sequence select="t:get-java-element($scope)"/>

        <if>
          <xsl:sequence select="$new-condition"/>
          
          <then>
            <break/>
          </then>
        </if>
      </block>
    </while>
  </xsl:template>

  <!--
    Mode "p:refactor-complex-statement".
    "switch" statement with complex test.
  -->
  <xsl:template mode="p:refactor-complex-statement"
    match="switch[t:contains-complex-expression(test)]">
    
    <xsl:variable name="test" as="element()" select="test"/>
    <xsl:variable name="closure" as="element()+"
      select="t:refactor-complex-expression($test)"/>
    <xsl:variable name="scope" as="element()"
      select="$closure[1]"/>
    <xsl:variable name="new-test" as="element()"
      select="$closure[2]"/>

    <xsl:sequence select="t:get-java-element($scope)"/>

    <xsl:copy>
      <xsl:sequence select="@*"/>
      <xsl:sequence select="meta | comment"/>
      <xsl:sequence select="$new-test"/>

      <xsl:apply-templates mode="#current" select="case"/>
    </xsl:copy>
  </xsl:template>

  <!--
    Mode "p:refactor-complex-statement".
    "synchronized" statement with complex monitor.
  -->
  <xsl:template mode="p:refactor-complex-statement"
    match="synchronized[t:contains-complex-expression(monitor)]">
    
    <xsl:variable name="monitor" as="element()" select="monitor"/>
    <xsl:variable name="closure" as="element()+"
      select="t:refactor-complex-expression($monitor)"/>
    <xsl:variable name="scope" as="element()"
      select="$closure[1]"/>
    <xsl:variable name="new-monitor" as="element()"
      select="$closure[2]"/>

    <xsl:sequence select="t:get-java-element($scope)"/>

    <xsl:copy>
      <xsl:sequence select="@*"/>
      <xsl:sequence select="meta | comment"/>
      <xsl:sequence select="$new-monitor"/>
      <xsl:apply-templates mode="#current" select="block"/>
    </xsl:copy>
  </xsl:template>

  <!--
    Mode "p:refactor-complex-statement".
    "return", "throw", "expression" statements with complex expression.
  -->
  <xsl:template mode="p:refactor-complex-statement" match="
    return[t:contains-complex-expression(.)] |
    throw[t:contains-complex-expression(.)] |
    expression[t:contains-complex-expression(.)]">
    
    <xsl:variable name="closure" as="element()+"
      select="t:refactor-complex-expression(.)"/>
    <xsl:variable name="scope" as="element()"
      select="$closure[1]"/>
    <xsl:variable name="new-statement" as="element()"
      select="$closure[2]"/>

    <xsl:sequence select="t:get-java-element($scope)"/>
    <xsl:sequence select="$new-statement"/>
  </xsl:template>

  <!--
    Mode "p:refactor-complex-statement".
    "continue" statement.
      $continue-targets - a set of statements, which a target of a
        continue statement, and refactored in the way that continue should
        be changed to a break statement.
  -->
  <xsl:template mode="p:refactor-complex-statement" match="continue">
    <xsl:param name="continue-targets" tunnel="yes" as="element()*"/>

    <xsl:variable name="target" as="element()?"
      select="t:get-statement-for-break((), .)"/>

    <xsl:choose>
      <xsl:when test="$target intersect $continue-targets">
        <xsl:variable name="label-id" as="xs:string" select="
          concat(generate-id($target), '.iterator.complex-expression')"/>

        <break destination-label="iteration" label-ref="{$label-id}">
          <xsl:sequence select="meta | comment"/>
        </break>
      </xsl:when>
      <xsl:otherwise>
        <xsl:sequence select="."/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!--
    Mode "p:refactor-complex-statement".
    "try" with resources statement with complex expression.
  -->
  <xsl:template mode="p:refactor-complex-statement" match="try">
    <xsl:for-each select="t:rewrite-try-statement(., false(), false())">
      <xsl:call-template name="p:refactor-complex-statement-default"/>
    </xsl:for-each>
  </xsl:template>

</xsl:stylesheet>
