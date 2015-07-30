<?xml version="1.0" encoding="utf-8"?>
<!--
  This stylesheet provides functions to refactor complex expressions.
-->
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:t="http://www.bphx.com/csharp"
  xmlns:p="http://www.bphx.com/csharp/private/csharp-complex-expression"
  xmlns="http://www.bphx.com/csharp-3.0/2009-05-23"
  xpath-default-namespace="http://www.bphx.com/csharp-3.0/2009-05-23"
  exclude-result-prefixes="xs t p">

  <!--
    This api refactors a special form of expressions defined through the
    anonymous delegate. E.g.:

    var j =
      ((Func<int>)delegate
      {
        if (i = 0)
        {
          throw new Exception();
        }

        return i;
      })() + 1;

    Such expressions are usually a result of generation when a statements are
    required to implement expression's logic. This expression is often can
    be simplified:

    if (i = 0)
    {
      throw new Exception();
    }

    var j = i + 1;

    The expression has a following format:
      <invoke>
        <cast>
          <anonymous-method>
            <block>
              statements

              <return>
                expression
              </return>
            </block>
          </anonymous-method>
          <type name="Func" namespace="System">
            <type-arguments>
              return type
            </type-arguments>
          </type>
        </cast>
      </invoke>

    <lambda> element can be used instead of <anonymous-method>.
    Body of the method should contain single return statement, and
    as the last statement in the body.
    A name normalization technique should be used to resolve names.
  -->

  <!--
    Optimizes complex expressions in the specified scope.
      $scope - a scope to optimize.
      Returns a scope with complex expressions optimized.
  -->
  <xsl:function name="t:optimize-complex-expressions" as="element()">
    <xsl:param name="scope" as="element()"/>

    <xsl:choose>
      <xsl:when test="empty(t:contains-complex-expression($scope))">
        <xsl:sequence select="$scope"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:sequence
          select="t:refactor-statements-with-complex-expressions($scope)"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:function>

  <!--
    Tests whether a specified scope contains complex expression.
      $scope - a scope to verify.
      Returns true if scope contains this is a complex expression, and
      false otherwise.
  -->
  <xsl:function name="t:contains-complex-expression" as="xs:boolean">
    <xsl:param name="scope" as="element()"/>

    <xsl:sequence select="exists(p:get-complex-expressions($scope))"/>
  </xsl:function>

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
      for
        $complex-expression in p:get-complex-expressions($expression)
      return
        $complex-expression
        [
          not
          (
            (ancestor::lambda | ancestor::anonymous-method)
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
            ancestor::coalesce,
            ancestor::condition[count(t:get-elements(.)) = 3]
          )">

        <xsl:variable name="condition" as="element()">
          <xsl:apply-templates mode="p:refactor-complex-condition"
            select="$expression"/>
        </xsl:variable>

        <xsl:sequence select="t:refactor-complex-expression($condition)"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:variable name="statements" as="element()*" select="
          $complex-expressions/cast/(anonymous-method, lambda)/
            block/(t:get-elements(.) except return)"/>

        <pp-region implicit="true">
          <xsl:sequence select="
            t:refactor-statements-with-complex-expressions($statements)"/>
        </pp-region>

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
    Gets continue statements in scope.
      $scope - a scope to get statements for.
      $result - a collected result.
  -->
  <xsl:function name="p:get-continue-statements" as="element()*">
    <xsl:param name="scope" as="element()*"/>
    <xsl:param name="result" as="element()*"/>

    <xsl:choose>
      <xsl:when test="empty($scope)">
        <xsl:sequence select="$result"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:variable name="children" as="element()*" select="
          t:get-scope-statements($scope)
          [
            not
            (
              self::while or
              self::do-while or
              self::for or
              self::foreach
            )
          ]"/>

        <xsl:sequence select="
          p:get-continue-statements
          (
            $children,
            ($result | $children[self::continue])
          )"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:function>

  <!--
    Gets direct (not nested) complex subexpressions within scope.
      $scope - an scope to look for complex subexpressions for.
      Returns a sequence of complex subexpressions within expression.
  -->
  <xsl:function name="p:get-complex-expressions" as="element()*">
    <xsl:param name="scope" as="element()*"/>

    <xsl:variable name="complex-expressions" as="element()*" select="
      $scope/descendant-or-self::invoke[t:is-complex-expression(.)]"/>

    <xsl:sequence select="
      $complex-expressions
      [
        empty(ancestor::invoke intersect $complex-expressions)
      ]"/>
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
    Mode "p:refactor-complex-expression". Complex expression.
  -->
  <xsl:template mode="p:refactor-complex-expression"
    match="invoke[t:is-complex-expression(.)]">
    
    <xsl:variable name="result" as="element()"
      select="cast/(anonymous-method, lambda)/block/t:get-elements(return)"/>

    <xsl:apply-templates mode="#current" select="$result"/>
  </xsl:template>

  <!--
    Mode "p:refactor-complex-expression". block statement.
  -->
  <xsl:template mode="p:refactor-complex-expression" 
    match="anonymous-method/block | lambda/block | lambda/expression">
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
    Mode "p:refactor-complex-condition". Complex and.
  -->
  <xsl:template mode="p:refactor-complex-condition"
    match="and[t:contains-complex-expression(.)]">

    <xsl:variable name="arguments" as="element()+"
      select="t:get-elements(.)"/>
    <xsl:variable name="name-id" as="xs:string"
      select="concat(generate-id(), '.complex-condition')"/>

    <xsl:variable name="condition" as="element()">
      <var-ref name="condition" name-ref="{$name-id}"/>
    </xsl:variable>

    <invoke>
      <cast>
        <lambda>
          <block>
            <var name="condition" name-id="{$name-id}">
              <initialize>
                <xsl:sequence select="$arguments[1]"/>
              </initialize>
            </var>

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
          </block>
        </lambda>
        <type name="Func" namespace="System">
          <type-arguments>
            <type name="bool"/>
          </type-arguments>
        </type>
      </cast>
    </invoke>
  </xsl:template>

  <!--
    Mode "p:refactor-complex-condition". Complex and.
  -->
  <xsl:template mode="p:refactor-complex-condition"
    match="or[t:contains-complex-expression(.)]">

    <xsl:variable name="arguments" as="element()+"
      select="t:get-elements(.)"/>
    <xsl:variable name="name-id" as="xs:string"
      select="concat(generate-id(), '.complex-condition')"/>

    <xsl:variable name="condition" as="element()">
      <var-ref name="condition" name-ref="{$name-id}"/>
    </xsl:variable>

    <invoke>
      <cast>
        <lambda>
          <block>
            <var name="condition" name-id="{$name-id}">
              <initialize>
                <xsl:sequence select="$arguments[1]"/>
              </initialize>
            </var>

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
          </block>
        </lambda>
        <type name="Func" namespace="System">
          <type-arguments>
            <type name="bool"/>
          </type-arguments>
        </type>
      </cast>
    </invoke>
  </xsl:template>

  <!--
    Mode "p:refactor-complex-condition". Complex coalesce.
  -->
  <xsl:template mode="p:refactor-complex-condition"
    match="coalesce[t:contains-complex-expression(.)]">

    <xsl:variable name="arguments" as="element()+"
      select="t:get-elements(.)"/>
    <xsl:variable name="name-id" as="xs:string"
      select="concat(generate-id(), '.complex-condition')"/>

    <xsl:variable name="value" as="element()">
      <var-ref name="value" name-ref="{$name-id}"/>
    </xsl:variable>

    <invoke>
      <cast>
        <lambda>
          <block>
            <var name="value" name-id="{$name-id}">
              <initialize>
                <xsl:sequence select="$arguments[1]"/>
              </initialize>
            </var>

            <if>
              <condition>
                <eq>
                  <xsl:sequence select="$value"/>
                  <null/>
                </eq>
              </condition>
              <then>
                <expression>
                  <assign>
                    <xsl:sequence select="$value"/>
                    <xsl:sequence select="subsequence($arguments, 2)"/>
                  </assign>
                </expression>
              </then>
            </if>

            <return>
              <xsl:sequence select="$value"/>
            </return>
          </block>
        </lambda>
        <type name="Func" namespace="System">
          <type-arguments>
            <xsl:sequence select="t:get-type-of(.)"/>
          </type-arguments>
        </type>
      </cast>
    </invoke>
  </xsl:template>

  <!--
    Mode "p:refactor-complex-condition". Complex condition expression.
  -->
  <xsl:template mode="p:refactor-complex-condition" match="
    condition[t:contains-complex-expression(.)][count(t:get-elements(.)) = 3]">

    <xsl:variable name="arguments" as="element()+"
      select="t:get-elements(.)"/>
    <xsl:variable name="name-id" as="xs:string"
      select="concat(generate-id(), '.complex-condition')"/>
    <xsl:variable name="type" as="element()" select="t:get-type-of(.)"/>

    <xsl:variable name="value" as="element()">
      <var-ref name="value" name-ref="{$name-id}"/>
    </xsl:variable>
    
    <invoke>
      <cast>
        <lambda>
          <block>
            <var name="value" name-id="{$name-id}">
              <xsl:sequence select="$type"/>
            </var>

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
          </block>
        </lambda>
        <type name="Func" namespace="System">
          <type-arguments>
            <xsl:sequence select="$type"/>
          </type-arguments>
        </type>
      </cast>
    </invoke>
  </xsl:template>

  <!--
    Mode "p:refactor-complex-statement". Default match.
  -->
  <xsl:template mode="p:refactor-complex-statement" match="*">
    <xsl:copy>
      <xsl:sequence select="@*"/>
      <xsl:apply-templates mode="#current"/>
    </xsl:copy>
  </xsl:template>

  <!-- Mode "p:refactor-complex-statement".  var. -->
  <xsl:template mode="p:refactor-complex-statement"
    match="var[initialize/t:contains-complex-expression(.)]">
    
    <xsl:variable name="initialize" as="element()" select="initialize"/>
    <xsl:variable name="closure" as="element()+"
      select="t:refactor-complex-expression($initialize)"/>

    <xsl:variable name="scope" as="element()" select="$closure[1]"/>
    <xsl:variable name="new-initialize" as="element()" select="$closure[2]"/>

    <xsl:apply-templates mode="#current" select="t:get-elements($scope)"/>

    <xsl:copy>
      <xsl:sequence select="@*"/>
      <xsl:apply-templates mode="#current" select="* except $initialize"/>
      <xsl:sequence select="$new-initialize"/>
    </xsl:copy>
  </xsl:template>

  <!-- Mode "p:refactor-complex-statement". if. -->
  <xsl:template mode="p:refactor-complex-statement"
    match="if[t:contains-complex-expression(condition)]">
    
    <xsl:variable name="condition" as="element()" select="condition"/>
    <xsl:variable name="closure" as="element()+"
      select="t:refactor-complex-expression($condition)"/>
    <xsl:variable name="scope" as="element()" select="$closure[1]"/>
    <xsl:variable name="new-condition" as="element()" select="$closure[2]"/>

    <xsl:apply-templates mode="#current" select="t:get-elements($scope)"/>

    <xsl:copy>
      <xsl:sequence select="@*"/>
      <xsl:apply-templates mode="#current" select="comment | meta"/>
      <xsl:sequence select="$new-condition"/>
      <xsl:apply-templates mode="#current" select="then | else"/>
    </xsl:copy>
  </xsl:template>

  <!--
    Mode "p:refactor-complex-statement".
    "for" statement with complex var-decl,
    initialize, condition, or update expressions.
      $refactored-cycles - a set of refactored cycles.
  -->
  <xsl:template mode="p:refactor-complex-statement" match="
    for
    [
      (var[condition >> .], initialize, condition, update)/
        t:contains-complex-expression(.) = true()
    ]">
    <xsl:param name="refactored-cycles" tunnel="yes" as="element()*"/>

    <xsl:variable name="condition" as="element()" select="condition"/>
    <xsl:variable name="var" as="element()*"
      select="$condition/preceding-sibling::var"/>
    <xsl:variable name="initialize" as="element()*" select="initialize"/>
    <xsl:variable name="update" as="element()*" select="update"/>
    <xsl:variable name="statements" as="element()*" select="
      t:get-elements(.) except ($var, $initialize, $condition, $update)"/>

    <xsl:variable name="complex-var" as="xs:boolean"
      select="$var/t:contains-complex-expression(.) = true()"/>
    <xsl:variable name="complex-initialize" as="xs:boolean"
      select="$initialize/t:contains-complex-expression(.) = true()"/>
    <xsl:variable name="complex-condition" as="xs:boolean"
      select="$condition/t:contains-complex-expression(.) = true()"/>
    <xsl:variable name="complex-update" as="xs:boolean"
      select="$update/t:contains-complex-expression(.) = true()"/>
    <xsl:variable name="has-continue" as="xs:boolean"
      select="exists(p:get-continue-statements(., ()))"/>

    <xsl:choose>
      <xsl:when test="$complex-initialize">
        <xsl:for-each select="$initialize">
          <xsl:variable name="closure" as="element()+"
            select="t:refactor-complex-expression(.)"/>
          <xsl:variable name="scope" as="element()"
            select="$closure[1]"/>
          <xsl:variable name="expression" as="element()"
            select="$closure[2]"/>

          <xsl:apply-templates mode="#current"
            select="t:get-elements($scope)"/>

          <expression>
            <xsl:apply-templates mode="#current" select="$expression/node()"/>
          </expression>
        </xsl:for-each>
      </xsl:when>
      <xsl:otherwise>
        <xsl:for-each select="$initialize">
          <expression>
            <xsl:apply-templates mode="#current" select="node()"/>
          </expression>
        </xsl:for-each>
      </xsl:otherwise>
    </xsl:choose>

    <xsl:choose>
      <xsl:when test="
        ($complex-var or $complex-initialize) and
        not($complex-condition) and
        not($complex-update)">

        <xsl:variable name="closure" as="element()*"
          select="$var/initialize/t:refactor-complex-expression(.)"/>

        <xsl:apply-templates mode="#current"
          select="$closure[(position() mod 2) = 1]/t:get-elements(.)"/>

        <xsl:copy>
          <xsl:sequence select="@*"/>

          <xsl:apply-templates mode="#current" select="comment | meta"/>

          <xsl:for-each select="$var">
            <xsl:variable name="index" as="xs:integer" select="position()"/>
            <xsl:variable name="refactored-initialize" as="element()"
              select="$closure[$index * 2]"/>

            <xsl:copy>
              <xsl:sequence select="@*"/>
              <xsl:apply-templates mode="#current"
                select="comment | meta | type"/>
              <xsl:sequence select="$refactored-initialize"/>
            </xsl:copy>
          </xsl:for-each>

          <xsl:apply-templates mode="#current" select="$condition"/>
          <xsl:apply-templates mode="#current" select="$update"/>
          <xsl:apply-templates mode="#current" select="$statements"/>
        </xsl:copy>
      </xsl:when>
      <xsl:otherwise>
        <xsl:variable name="new-update" as="element()">
          <xsl:for-each select="$update">
            <xsl:choose>
              <xsl:when test="$complex-update">
                <xsl:variable name="closure" as="element()+"
                  select="t:refactor-complex-expression(.)"/>
                <xsl:variable name="scope" as="element()"
                  select="$closure[1]"/>
                <xsl:variable name="expression" as="element()"
                  select="$closure[2]"/>

                <xsl:apply-templates mode="#current"
                  select="t:get-elements($scope)"/>

                <expression>
                  <xsl:apply-templates mode="#current"
                    select="$expression/node()"/>
                </expression>
              </xsl:when>
              <xsl:otherwise>
                <expression>
                  <xsl:apply-templates mode="#current"/>
                </expression>
              </xsl:otherwise>
            </xsl:choose>
          </xsl:for-each>
        </xsl:variable>

        <xsl:variable name="for-block" as="element()*">
          <xsl:apply-templates mode="#current" select="$statements">
            <xsl:with-param name="refactored-cycles" tunnel="yes" select="
              $refactored-cycles | .[$has-continue and exists($new-update)]"/>
          </xsl:apply-templates>

          <xsl:choose>
            <xsl:when test="$has-continue and exists($new-update)">
              <label name="next" name-id="continue.{generate-id()}.id">
                <xsl:sequence select="$new-update"/>
              </label>
            </xsl:when>
            <xsl:otherwise>
              <xsl:sequence select="$new-update"/>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:variable>

        <xsl:apply-templates mode="#current" select="$var"/>

        <xsl:choose>
          <xsl:when test="$complex-condition">
            <while>
              <condition>
                <bool value="true"/>
              </condition>

              <xsl:variable name="closure" as="element()+"
                select="t:refactor-complex-expression($condition)"/>
              <xsl:variable name="scope" as="element()+" select="$closure[1]"/>
              <xsl:variable name="new-condition" as="element()+"
                select="$closure[2]"/>

              <xsl:apply-templates mode="#current"
                select="t:get-elements($scope)"/>

              <if>
                <condition>
                  <xsl:sequence select="
                    t:generate-not-expression
                    (
                      t:get-elements($new-condition)
                    )"/>
                </condition>
                <then>
                  <break/>
                </then>
              </if>

              <xsl:sequence select="$for-block"/>
            </while>
          </xsl:when>
          <xsl:otherwise>
            <while>
              <xsl:apply-templates mode="#current" select="comment | meta"/>

              <xsl:choose>
                <xsl:when test="exists(t:get-elements($condition))">
                  <xsl:sequence select="$condition"/>
                </xsl:when>
                <xsl:otherwise>
                  <condition>
                    <bool value="true"/>
                  </condition>
                </xsl:otherwise>
              </xsl:choose>

              <xsl:sequence select="$for-block"/>
            </while>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!--
    Mode "p:refactor-complex-statement". sfor-each.
  -->
  <xsl:template mode="p:refactor-complex-statement"
    match="foreach[t:contains-complex-expression(var[1])]">
    
    <xsl:variable name="var" as="element()" select="var[1]"/>
    <xsl:variable name="initialize" as="element()"
      select="$var/initialize"/>

    <xsl:variable name="closure" as="element()+"
      select="t:refactor-complex-expression($initialize)"/>
    <xsl:variable name="scope" as="element()"
      select="$closure[1]"/>
    <xsl:variable name="new-initialize" as="element()"
      select="$closure[2]"/>

    <xsl:apply-templates mode="#current" select="t:get-elements($scope)"/>

    <foreach>
      <xsl:apply-templates mode="#current" select="meta | comment"/>

      <var>
        <xsl:sequence select="$var/@*"/>
        <xsl:apply-templates mode="#current"
          select="$var/(meta | comment | type)"/>
        <xsl:sequence select="$new-initialize"/>
      </var>

      <xsl:apply-templates mode="#current"
        select="t:get-elements(.) except $var"/>
    </foreach>
  </xsl:template>

  <!--
    Mode "p:refactor-complex-statement". while.
  -->
  <xsl:template mode="p:refactor-complex-statement"
    match="while[t:contains-complex-expression(condition)]">
    
    <xsl:variable name="condition" as="element()" select="condition"/>
    <xsl:variable name="closure" as="element()+"
      select="t:refactor-complex-expression($condition)"/>
    <xsl:variable name="scope" as="element()"
      select="$closure[1]"/>
    <xsl:variable name="new-condition" as="element()"
      select="$closure[2]"/>

    <xsl:copy>
      <xsl:sequence select="@*"/>
      <xsl:apply-templates mode="#current" select="meta | comment"/>

      <condition>
        <bool value="true"/>
      </condition>

      <xsl:apply-templates mode="#current" select="t:get-elements($scope)"/>

      <if>
        <condition>
          <xsl:sequence select="
            t:generate-not-expression
            (
              t:get-elements($new-condition)
            )"/>
        </condition>
        <then>
          <break/>
        </then>
      </if>

      <xsl:apply-templates mode="#current"
        select="t:get-elements(.) except $condition"/>
    </xsl:copy>
  </xsl:template>

  <!--
    Mode "p:refactor-complex-statement".
    "do-while" statement with complex condition.
      $refactored-cycles - a set of refactored cycles.
  -->
  <xsl:template mode="p:refactor-complex-statement"
    match="do-while[t:contains-complex-expression(condition)]">
    <xsl:param name="refactored-cycles" tunnel="yes" as="element()*"/>

    <xsl:variable name="condition" as="element()" select="condition"/>
    <xsl:variable name="block" as="element()" select="block"/>
    <xsl:variable name="has-continue" as="xs:boolean"
      select="exists(p:get-continue-statements(., ()))"/>

    <xsl:variable name="closure" as="element()+"
      select="t:refactor-complex-expression($condition)"/>
    <xsl:variable name="scope" as="element()"
      select="$closure[1]"/>
    <xsl:variable name="new-condition" as="element()"
      select="$closure[2]"/>

    <xsl:copy>
      <condition>
        <bool value="true"/>
      </condition>

      <xsl:apply-templates mode="#current" select="meta | comment">
        <xsl:with-param name="refactored-cycles" tunnel="yes" select="()"/>
      </xsl:apply-templates>

      <xsl:apply-templates mode="#current"
        select="t:get-elements(.) except $condition">
        <xsl:with-param name="refactored-cycles" tunnel="yes"
          select="$refactored-cycles | .[$has-continue]"/>
      </xsl:apply-templates>

      <xsl:choose>
        <xsl:when test="$has-continue">
          <label name="next" name-id="continue.{generate-id()}.id">
            <xsl:apply-templates mode="#current"
              select="t:get-elements($scope)"/>
          </label>
        </xsl:when>
        <xsl:otherwise>
          <xsl:apply-templates mode="#current"
            select="t:get-elements($scope)"/>
        </xsl:otherwise>
      </xsl:choose>

      <if>
        <xsl:sequence select="$new-condition"/>

        <then>
          <break/>
        </then>
      </if>
    </xsl:copy>
  </xsl:template>

  <!-- Mode "p:refactor-complex-statement". switch. -->
  <xsl:template mode="p:refactor-complex-statement"
    match="switch[t:contains-complex-expression(test)]">

    <xsl:variable name="test" as="element()" select="test"/>
    <xsl:variable name="closure" as="element()+"
      select="t:refactor-complex-expression($test)"/>
    <xsl:variable name="scope" as="element()"
      select="$closure[1]"/>
    <xsl:variable name="new-test" as="element()"
      select="$closure[2]"/>

    <xsl:apply-templates mode="#current" select="t:get-elements($scope)"/>s

    <xsl:copy>
      <xsl:sequence select="@*"/>
      <xsl:apply-templates mode="#current" select="meta | comment"/>
      <xsl:sequence select="$new-test"/>
      <xsl:apply-templates mode="#current" select="case"/>
    </xsl:copy>
  </xsl:template>

  <!-- Mode "p:refactor-complex-statement". lock, using. -->
  <xsl:template mode="p:refactor-complex-statement" match="
    lock[t:contains-complex-expression(resource)] |
    using[t:contains-complex-expression(resource)]">
    
    <xsl:variable name="resource" as="element()" select="monitor"/>
    <xsl:variable name="closure" as="element()+"
      select="t:refactor-complex-expression($resource)"/>
    <xsl:variable name="scope" as="element()"
      select="$closure[1]"/>
    <xsl:variable name="new-resource" as="element()"
      select="$closure[2]"/>

    <xsl:apply-templates mode="#current" select="t:get-elements($scope)"/>

    <xsl:copy>
      <xsl:sequence select="@*"/>
      <xsl:apply-templates mode="#current" select="comment | meta"/>
      <xsl:sequence select="$new-resource"/>
      <xsl:apply-templates mode="#current"
        select="t:get-elements(.) except $resource"/>
    </xsl:copy>
  </xsl:template>

  <!-- Mode "p:refactor-complex-statement". fixed. -->
  <xsl:template mode="p:refactor-complex-statement"
    match="fixed[t:contains-complex-expression(var[1])]">
    
    <xsl:variable name="var" as="element()" select="var[1]"/>
    <xsl:variable name="closure" as="element()+"
      select="t:refactor-complex-expression($var)"/>
    <xsl:variable name="scope" as="element()"
      select="$closure[1]"/>
    <xsl:variable name="new-var" as="element()"
      select="$closure[2]"/>

    <xsl:apply-templates mode="#current" select="t:get-elements($scope)"/>

    <xsl:copy>
      <xsl:sequence select="@*"/>
      <xsl:apply-templates mode="#current" select="comment | meta"/>
      <xsl:sequence select="$new-var"/>
      <xsl:apply-templates mode="#current"
        select="t:get-elements(.) except $var"/>
    </xsl:copy>
  </xsl:template>

  <!--
    Mode "p:refactor-complex-statement". return, throw, expression, yield.
  -->
  <xsl:template mode="p:refactor-complex-statement" match="
    return[t:contains-complex-expression(.)] |
    throw[t:contains-complex-expression(.)] |
    expression[t:contains-complex-expression(.)] |
    yield[t:contains-complex-expression(.)]">
    
    <xsl:variable name="closure" as="element()+"
      select="t:refactor-complex-expression(.)"/>
    <xsl:variable name="scope" as="element()"
      select="$closure[1]"/>
    <xsl:variable name="new-statement" as="element()"
      select="$closure[2]"/>

    <xsl:apply-templates mode="#current" select="t:get-elements($scope)"/>
    <xsl:sequence select="$new-statement"/>
  </xsl:template>

  <!--
    Mode "p:refactor-complex-statement". lambda/expression
  -->
  <xsl:template mode="p:refactor-complex-statement" priority="2" match="
    lambda/expression[t:contains-complex-expression(.)]">

    <xsl:variable name="closure" as="element()+"
      select="t:refactor-complex-expression(.)"/>
    <xsl:variable name="scope" as="element()"
      select="$closure[1]"/>
    <xsl:variable name="new-statement" as="element()"
      select="$closure[2]"/>

    <block>
      <xsl:apply-templates mode="#current" select="t:get-elements($scope)"/>
      <xsl:sequence select="$new-statement"/>
    </block>
  </xsl:template>

  <!--
    Mode "p:refactor-complex-statement". continue.
      $refactored-cycles - a set of refactored cycles.
  -->
  <xsl:template mode="p:refactor-complex-statement" match="continue">
    <xsl:param name="refactored-cycles" tunnel="yes" as="element()*"/>

    <xsl:variable name="cycle" as="element()?" select="
      $refactored-cycles[exists(p:get-continue-statements(., ()))]"/>

    <xsl:choose>
      <xsl:when test="empty($cycle)">
        <xsl:sequence select="."/>
      </xsl:when>
      <xsl:otherwise>
        <goto name="cycle" name-id="continue.{generate-id($cycle)}.id"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

</xsl:stylesheet>