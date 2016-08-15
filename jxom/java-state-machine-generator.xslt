<?xml version="1.0" encoding="utf-8"?>
<!--
  This stylesheet converts a method into a state machine.
-->
<xsl:stylesheet version="2.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:t="http://www.bphx.com/jxom"
  xmlns:p="http://www.bphx.com/jxom/private/java-state-maching-generator"
  xmlns="http://www.bphx.com/java-1.5/2008-02-07"
  xpath-default-namespace="http://www.bphx.com/java-1.5/2008-02-07"
  exclude-result-prefixes="xs t">

  <!--
    Statements are converted into a state machine, provided there are
    <snippet-statement yield="true"/>
    elements in the sequence.

    Conversion is performed into two stages:
      generate pseudo code;
      generate state machine.

    Example:
      if (x) { A /* yield */ B } else { C }

      is converted into pseudo code:

      l0: if (x) goto l1 else goto l3;
      l1: A /* yield; */ goto l2;
      l2: B goto l4;
      l3: C goto l4;
      l4: ;

      return new Callable<Boolean>()
      {
        Boolean call()
          throws Exception
        {
          while(true)
          {
            switch(state)
            {
              case 0:
              {
                if (x)
                {
                  state = 1;
                }
                else
                {
                  state = 3;
                }

                continue;
              }
              case 1:
              {
                A
                state = 2;

                return true;
              }
              case 2:
              {
                
                state = 4;

                return false;
              }
              case 3:
              {
                C
                state = 4;

                return false;
              }
              default:
              {
                throw new IllegalStateException();
              }
            }
          }
        }

        private state = 0;
      };
  -->

  <!--
    Tests whether method can be converted into a state machine.
      $method - a method to to test.
      Returns:
        yes - when statement can be converted into a state mache;
        no - a proceure contains no yield markers;
        contains-error - whenever method contains error bookmarks;
        returns-no-void - when method returns no void;
        synchronized - when method, or its part is synchronized;
  -->
  <xsl:function name="t:can-convert-method-to-state-machine" as="xs:string">
    <xsl:param name="method" as="element()"/>

    <xsl:variable name="block" as="element()?" select="$method/block"/>
    <xsl:variable name="yield-statements" as="element()*"
      select="$block/p:get-yield-statements(.)"/>
    <xsl:variable name="synchronized" as="xs:boolean?"
      select="$method/@synchronized"/>
    <xsl:variable name="return-type" as="element()?"
      select="$method/returns/type"/>

    <xsl:sequence select="
      if (empty($yield-statements)) then
        'no'
      else if
      (
        exists($return-type) and
        not($return-type[empty(@package)]/@name  = 'void')
      )
      then
        'returns-no-void'
      else if ($synchronized or $yield-statements[self::synchronized]) then
        'synchronized'
      else if (exists($method//bookmark/error)) then
        'contains-error'
      else
        'yes'"/>
  </xsl:function>

  <!--
    For a given class-method generates a state machine method.
    Original method should return void.
      $method - a method to convert.
      $name - an optional name for a new method;
        if value is not specified, then original method name is used.
      $serializable-state-machine - true to make state machine serializable,
        and false otherwise.
      $generate-suppress-warnings - true to generate suppress warnings annotation,
        and false otherwise.
      Returns a new method, returning state machine instance.
  -->
  <xsl:function name="t:convert-method-to-state-machine" as="element()">
    <xsl:param name="method" as="element()"/>
    <xsl:param name="name" as="xs:string?"/>
    <xsl:param name="serializable-state-machine" as="xs:boolean"/>
    <xsl:param name="generate-suppress-warnings" as="xs:boolean"/>

    <xsl:sequence select="
      t:convert-method-to-state-machine
      (
        $method,
        $name,
        $serializable-state-machine,
        $generate-suppress-warnings,
        ()
      )"/>
  </xsl:function>

  <!--
    For a given class-method generates a state machine method.
    Original method should return void.
      $method - a method to convert.
      $name - an optional name for a new method;
        if value is not specified, then original method name is used.
      $serializable-state-machine - true to make state machine serializable,
        and false otherwise.
      $generate-suppress-warnings - true to generate suppress warnings annotation,
        and false otherwise.
      $error-handler - optional generic error handler, which is an invoke
        with <t:error/> place holder for the error reference.
      Returns a new method, returning state machine instance.
  -->
  <xsl:function name="t:convert-method-to-state-machine" as="element()">
    <xsl:param name="method" as="element()"/>
    <xsl:param name="name" as="xs:string?"/>
    <xsl:param name="serializable-state-machine" as="xs:boolean"/>
    <xsl:param name="generate-suppress-warnings" as="xs:boolean"/>
    <xsl:param name="error-handler" as="element()?"/>

    <!--
      TODO: handle name resolution.
        We reserve "StateMachine" as a class name, and
        "error" as a method name.

        This can potentially conflict with names used in the method.

        We should probably qualify all java.lang objects also.
    -->

    <xsl:variable name="id" as="xs:string" select="generate-id($method)"/>
    <xsl:variable name="pseudo-code" as="element()"
      select="p:build-pseudo-code($method)"/>
    <xsl:variable name="has-try" as="xs:boolean"
      select="exists($pseudo-code//try[@p:try])"/>
    <xsl:variable name="has-next-state" as="xs:boolean"
      select="exists($pseudo-code//snippet-statement[@p:goto and @p:next])"/>
    <xsl:variable name="parameters" as="element()*"
      select="$method/parameters/parameter"/>
    <xsl:variable name="state-variables" as="element()*" select="
      $pseudo-code//(self::var-decl, self::parameter)[xs:boolean(@p:state)]"/>

    <class-method>
      <xsl:sequence select="$method/@*"/>

      <xsl:if test="exists($name)">
        <xsl:attribute name="name" select="$name"/>
      </xsl:if>

      <xsl:sequence select="$method/(meta | comment | type-parameters)"/>

      <returns>
        <type name="Callable" package="java.util.concurrent">
          <argument>
            <type name="Boolean"/>
          </argument>
        </type>
      </returns>

      <xsl:sequence select="$method/(parameters, throws)"/>

      <block>
        <class name="StateMachine">
          <xsl:if test="$generate-suppress-warnings">
            <annotation>
              <type name="SuppressWarnings"/>
              <parameter>
                <xsl:choose>
                  <xsl:when test="$serializable-state-machine">
                    <annotation-array>
                      <string value="serial"/>
                      <string value="unchecked"/>
                    </annotation-array>
                  </xsl:when>
                  <xsl:otherwise>
                    <string value="unchecked"/>
                  </xsl:otherwise>
                </xsl:choose>
              </parameter>
            </annotation>
          </xsl:if>
          
          <implements>
            <type name="Callable" package="java.util.concurrent">
              <argument>
                <type name="Boolean"/>
              </argument>
            </type>

            <xsl:if test="$serializable-state-machine">
              <type name="Serializable" package="java.io"/>
            </xsl:if>
          </implements>

          <xsl:if test="exists($parameters)">
            <constructor name="StateMachine" access="public">
              <parameters>
                <xsl:for-each select="$parameters">
                  <parameter name="{@name}">
                    <xsl:sequence select="type"/>
                  </parameter>
                </xsl:for-each>
              </parameters>
              <block>
                <xsl:for-each select="$parameters">
                  <expression>
                    <assign>
                      <field name="{@name}">
                        <this/>
                      </field>
                      <var name="{@name}"/>
                    </assign>
                  </expression>
                </xsl:for-each>
              </block>
            </constructor>
          </xsl:if>

          <class-method name="call" access="public">
            <returns>
              <type name="Boolean"/>
            </returns>
            <throws>
              <type name="Exception"/>
            </throws>

            <xsl:sequence select="
              p:create-state-machine-body
              (
                $pseudo-code,
                $has-try,
                $has-next-state,
                $error-handler
              )"/>
          </class-method>

          <xsl:if test="$has-try and empty($error-handler)">
            <class-method name="error" access="private">
              <type-parameters>
                <parameter name="T">
                  <type name="Throwable"/>
                </parameter>
              </type-parameters>
              <returns>
                <type name="boolean"/>
              </returns>
              <throws>
                <type name="T"/>
              </throws>
              <block>
                <throw>
                  <cast>
                    <type name="T"/>
                    <value>
                      <field
                        name="currentError"
                        name-ref="currentError.state-machine"/>
                    </value>
                  </cast>
                </throw>
              </block>
            </class-method>
          </xsl:if>

          <class-members>
            <comment>State machine variables.</comment>
            <class-field
              name="state"
              name-id="state.state-machine"
              access="private">
              <type name="int"/>
            </class-field>

            <xsl:if test="$has-try">
              <xsl:if test="$has-next-state">
                <class-field
                  name="nextState"
                  name-id="next-state.state-machine"
                  access="private">
                  <type name="int"/>
                </class-field>
              </xsl:if>

              <class-field
                name="currentError"
                name-id="currentError.state-machine"
                access="private">
                <type name="Throwable"/>
              </class-field>
            </xsl:if>
          </class-members>

          <xsl:if test="exists($parameters) or exists($state-variables)">
            <class-members>
              <comment>Method's variables.</comment>

              <xsl:for-each select="$parameters">
                <xsl:variable name="name" as="xs:string" select="@name"/>

                <class-field name="{$name}" access="private">
                  <xsl:sequence select="type"/>
                </class-field>
              </xsl:for-each>

              <xsl:for-each select="$state-variables">
                <class-field access="private">
                  <xsl:sequence select="@name, @name-id"/>
                  <xsl:sequence select="type"/>
                </class-field>
              </xsl:for-each>
            </class-members>
          </xsl:if>
        </class>

        <return>
          <new-object>
            <type name="StateMachine"/>

            <xsl:if test="exists($parameters)">
              <arguments>
                <xsl:for-each select="$parameters">
                  <var name="{@name}"/>
                </xsl:for-each>
              </arguments>
            </xsl:if>
          </new-object>
        </return>
      </block>
    </class-method>
  </xsl:function>

  <!--
    Gets all statements containing yield markers.
      $block - a block to test.
      Returns a set of statements containing yield marker.
  -->
  <xsl:function name="p:get-yield-statements" as="element()*">
    <xsl:param name="block" as="element()"/>

    <xsl:sequence select="
      $block//snippet-statement[xs:boolean(@yield)]
      [
        every $element in ancestor::*[not($block >> .)] satisfies
          p:is-complex-statement($element)
      ]/ancestor::*[not($block >> .)]"/>
  </xsl:function>

  <!--
    Tests whether an element is a complex statement or its part,
    that can contain sub statements.
  -->
  <xsl:function name="p:is-complex-statement" as="xs:boolean">
    <xsl:param name="element" as="element()"/>

    <xsl:sequence select="
      exists
      (
        $element
        [
          self::scope or
          self::block or
          self::if or self::then or self::else or
          self::for or
          self::for-each or
          self::while or
          self::do-while or
          self::try or self::catch or self::finally or
          self::switch or self::case or
          self::synchronized
        ]
      )"/>
  </xsl:function>

  <!--
    Converts a method into a pseudo code block.
      $method - a method to build pseudo code for.
      Returns a pseudo code block.
  -->
  <xsl:function name="p:build-pseudo-code" as="element()">
    <xsl:param name="method" as="element()"/>
    
    <xsl:variable name="normalized-method" as="element()">
      <xsl:apply-templates mode="p:normalize-code" select="$method"/>                           
    </xsl:variable>
    
    <xsl:variable name="id" as="xs:string" 
      select="generate-id($normalized-method)"/>
    <xsl:variable name="block" as="element()" 
      select="$normalized-method/block"/>
    <xsl:variable name="yield-statements" as="element()+"
      select="p:get-yield-statements($block)"/>

    <!-- Breaks, which should be converted into states. -->
    <xsl:variable name="breaks" as="element()*">
      <xsl:perform-sort select="
        $block//
          (continue, break, try[finally]/(., catch)/block//return)
          [
            every $element in ancestor::*[not($block >> .)] satisfies
              p:is-complex-statement($element)
          ]">
        <xsl:sort
          select="count(t:get-statement-for-break($block, .)/ancestor::*)"/>
      </xsl:perform-sort>
    </xsl:variable>

    <xsl:variable name="total-yield-statements" as="element()+"
      select="p:collect-break-states($breaks, 1, $block, $yield-statements)"/>

    <scope>
      <snippet-statement>
        <xsl:attribute name="p:label"
          select="concat('statement.', $id, '.start.state-machine')"/>
      </snippet-statement>

      <xsl:apply-templates mode="p:build-pseudo-code" select="$block">
        <xsl:with-param name="method" tunnel="yes" 
          select="$normalized-method"/>
        <xsl:with-param name="yield-statements" tunnel="yes"
          select="$total-yield-statements"/>
      </xsl:apply-templates>

      <snippet-statement>
        <xsl:attribute name="p:label"
          select="concat('statement.', $id, '.end.state-machine')"/>
      </snippet-statement>
    </scope>
  </xsl:function>

  <!--
    Collects yield statements caused by breaks.
      $breaks - break statements.
      $index - current index.
      $block - a reference block.
      $yield-statements - a set of collected yield statements.
      Returns a set of yield statements, including caused by breaks.
  -->
  <xsl:function name="p:collect-break-states" as="element()+">
    <xsl:param name="breaks" as="element()*"/>
    <xsl:param name="index" as="xs:integer"/>
    <xsl:param name="block" as="element()"/>
    <xsl:param name="yield-statements" as="element()+"/>

    <xsl:variable name="break" as="element()?" select="$breaks[$index]"/>

    <xsl:choose>
      <xsl:when test="empty($break)">
        <xsl:sequence select="$yield-statements"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:variable name="reference" as="element()+" select="
          if (exists($break[self::return])) then
            $break/ancestor::block/(., parent::catch)/parent::try[finally]
          else
            t:get-statement-for-break($block, $break)"/>

        <xsl:variable name="new-yield-statements" as="element()*" select="
          if (exists($reference intersect $yield-statements)) then
            $break/ancestor-or-self::*[not($block >> .)]
          else
            ()"/>

        <xsl:sequence select="
          p:collect-break-states
          (
            $breaks,
            $index + 1,
            $block,
            ($yield-statements | $new-yield-statements)
          )"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:function>

  <!--
    Creates state machine body from a pseudo code.
      $pseudo-code - a pseudo code block.
      $has-try - true if body contains try block converted
        into a state machine, and false otherwise.
      $has-next-state - true if return/break/continue is used to
        exit from try-finally block, and false otherwise.
      $error-handler - optional generic error handler.
      Returns a body of state machine.
  -->
  <xsl:function name="p:create-state-machine-body" as="element()">
    <xsl:param name="pseudo-code" as="element()"/>
    <xsl:param name="has-try" as="xs:boolean"/>
    <xsl:param name="has-next-state" as="xs:boolean"/>
    <xsl:param name="error-handler" as="element()?"/>

    <xsl:variable name="scopes" as="element()+" select="
      $pseudo-code//snippet-statement[@p:label]
      [
        empty
        (
          following-sibling::*[1]
          [
            self::try[@p:try] or
            self::snippet-statement[@p:label]
          ]
        )
      ]"/>

    <xsl:variable name="states" as="xs:string+" select="
      $scopes
      [
        (position() != 1) or
        empty
        (
          following-sibling::*[1][self::snippet-statement]
          [
            @p:goto and not(xs:boolean(@yield))
          ]
        )
      ]/xs:string(@p:label)"/>

    <xsl:variable name="unoptimized-switch-statement" as="element()">
      <switch>
        <test>
          <field
            name="state"
            name-ref="state.state-machine"/>
        </test>

        <xsl:variable name="yield-empty-states" as="xs:string*" select="
          $pseudo-code//snippet-statement[@p:goto and xs:boolean(@yield)]/
            p:get-destination(@p:goto, true(), (), $pseudo-code, $states)[1]"/>

        <xsl:sequence select="
          p:generate-cases
          (
            $pseudo-code,
            $pseudo-code/*,
            $states,
            $yield-empty-states,
            $has-next-state
          )"/>
      </switch>
    </xsl:variable>

    <xsl:variable name="switch-statement" as="element()" select="
      t:optimize-unreachable-code($unoptimized-switch-statement, true(), ())"/>

    <xsl:variable name="return" as="element()+">
      <xsl:choose>
        <xsl:when test="$has-try">
          <xsl:choose>
            <xsl:when test="exists($error-handler)">
              <expression>
                <xsl:apply-templates mode="p:generate-error-handler-call"
                  select="$error-handler"/>
              </expression>

              <return>
                <boolean value="false"/>
              </return>
            </xsl:when>
            <xsl:otherwise>
              <return>
                <invoke name="error">
                  <type-arguments>
                    <type name="Exception"/>
                  </type-arguments>
                  <instance>
                    <this/>
                  </instance>
                </invoke>
              </return>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:when>
        <xsl:otherwise>
          <throw>
            <new-object>
              <type name="IllegalStateException"/>
            </new-object>
          </throw>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>

    <block>
      <xsl:choose>
        <xsl:when test="$has-try">
          <xsl:variable name="error-cases" as="element()*" select="
            p:generate-error-cases
            (
              $pseudo-code,
              $scopes,
              $states
            )"/>
          
          <while>
            <condition>
              <boolean value="true"/>
            </condition>
            <block>
              <try>
                <block>
                  <xsl:sequence select="$switch-statement"/>

                  <if>
                    <condition>
                      <eq>
                        <field
                          name="currentError"
                          name-ref="currentError.state-machine"/>
                        <null/>
                      </eq>
                    </condition>
                    <then>
                      <expression>
                        <assign>
                          <field
                            name="currentError"
                            name-ref="currentError.state-machine"/>
                          <new-object>
                            <type name="IllegalStateException"/>
                          </new-object>
                        </assign>
                      </expression>
                    </then>
                  </if>
                </block>
                <catch>
                  <parameter name="error">
                    <type name="Throwable"/>
                  </parameter>
                  <block>
                    <xsl:if test="$has-next-state">
                      <expression>
                        <assign>
                          <field
                            name="nextState"
                            name-ref="next-state.state-machine"/>
                          <int value="0"/>
                        </assign>
                      </expression>
                    </xsl:if>

                    <xsl:if test="$error-cases">
                      <expression>
                        <assign>
                          <field
                            name="currentError"
                            name-ref="currentError.state-machine"/>
                          <null/>
                        </assign>
                      </expression>
          
                      <switch>
                        <test>
                          <field
                            name="state"
                            name-ref="state.state-machine"/>
                        </test>

                        <xsl:sequence select="$error-cases"/>
                      </switch>
                    </xsl:if>

                    <expression>
                      <assign>
                        <field
                          name="currentError"
                          name-ref="currentError.state-machine"/>
                        <var name="error"/>
                      </assign>
                    </expression>

                    <expression>
                      <assign>
                        <field
                          name="state"
                          name-ref="state.state-machine"/>
                        <int value="-1"/>
                      </assign>
                    </expression>
                  </block>
                </catch>
              </try>

              <xsl:sequence select="$return"/>
            </block>
          </while>
        </xsl:when>
        <xsl:when test="exists($switch-statement/case/block//continue)">
          <while>
            <condition>
              <boolean value="true"/>
            </condition>
            <block>
              <xsl:sequence select="$switch-statement"/>
              <xsl:sequence select="$return"/>
            </block>
          </while>
        </xsl:when>
        <xsl:otherwise>
          <xsl:sequence select="$switch-statement"/>
          <xsl:sequence select="$return"/>
        </xsl:otherwise>
      </xsl:choose>
    </block>
  </xsl:function>

  <!--
    Generates cases for a state machine.
      $pseudo-code - a pseudo code block.
      $statements - a sequence of statements.
      $states - a complete list of states.
      $yield-empty-states - empty state, which is not dead code.
      $has-next-state - true if return/break/continue is used to
        exit from try-finally block, and false otherwise.
      Returns cases for a state machine.
  -->
  <xsl:function name="p:generate-cases" as="element()*">
    <xsl:param name="pseudo-code" as="element()"/>
    <xsl:param name="statements" as="element()*"/>
    <xsl:param name="states" as="xs:string+"/>
    <xsl:param name="yield-empty-states" as="xs:string*"/>
    <xsl:param name="has-next-state" as="xs:boolean"/>

    <xsl:for-each-group
      group-starting-with="snippet-statement[@p:label]"
      select="$statements">

      <xsl:variable name="block" as="element()+" select="current-group()"/>
      <xsl:variable name="substatements" as="element()*"
        select="subsequence($block, 2)"/>

      <xsl:variable name="try" as="element()?"
        select="$substatements[self::try[@p:try]]"/>

      <xsl:variable name="id" as="xs:string" select="
        if (exists($try)) then
          $try/@p:try
        else
          $block[1][self::snippet-statement]/@p:label"/>

      <xsl:variable name="state" as="xs:integer?"
        select="index-of($states, $id) - 1"/>

      <xsl:choose>
        <xsl:when test="
          empty($state) or
          ($state != 0) and
          (
            empty($substatements) or
            $substatements[1][self::snippet-statement][@p:label]
          )">
          <!-- Optimized state. Do nothing. -->
        </xsl:when>
        <xsl:when test="exists($try)">
          <xsl:sequence select="
            $try/(block, catch/block, finally)/
              p:generate-cases
              (
                $pseudo-code,
                *,
                $states,
                $yield-empty-states,
                $has-next-state
              )"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:variable name="case-statements" as="element()*">
            <xsl:apply-templates mode="p:generate-case"
              select="$substatements">
              <xsl:with-param name="pseudo-code" tunnel="yes"
                select="$pseudo-code"/>
              <xsl:with-param name="states" tunnel="yes" select="$states"/>
              <xsl:with-param name="has-next-state" tunnel="yes"
                select="$has-next-state"/>
            </xsl:apply-templates>
          </xsl:variable>

          <xsl:variable name="next-state" as="xs:integer" select="
            if (count($states) le $state + 1) then
              -1
            else
              $state + 1"/>

          <xsl:variable name="dead-code" as="xs:boolean" select="
            if ((empty($substatements) and ($next-state = -1))) then
              true()
            else if ($state = 0) then
              false()
            else if
            (
              $substatements[1][self::snippet-statement][@p:goto]
              [
                (
                  not(xs:boolean(@yield)) or
                  not($id = $yield-empty-states)
                ) and
                not(xs:boolean(@p:finally)) and
                not(@p:next)
              ]
            )
            then
              true()
            else
              false()"/>

          <xsl:if test="not($dead-code)">
            <case>
              <value>
                <int value="{$state}"/>
              </value>

              <block>
                <xsl:sequence select="$case-statements"/>

                <xsl:choose>
                  <xsl:when test="$next-state = -1">
                    <xsl:sequence select="
                      p:generate-goto
                      (
                        (),
                        true(),
                        (),
                        $pseudo-code,
                        $states
                      )"/>
                  </xsl:when>
                  <xsl:otherwise>
                    <xsl:sequence select="
                      p:generate-goto
                      (
                        $states[$next-state + 1],
                        false(),
                        (),
                        $pseudo-code,
                        $states
                      )"/>
                  </xsl:otherwise>
                </xsl:choose>
              </block>
            </case>
          </xsl:if>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:for-each-group>
  </xsl:function>

  <!--
    Generates error cases for a state machine.
      $pseudo-code - a pseudo code block.
      $scope - a list of scopes.
      $states - a complete list of states.
      Return error cases for a state machine.
  -->
  <xsl:function name="p:generate-error-cases" as="element()*">
    <xsl:param name="pseudo-code" as="element()"/>
    <xsl:param name="scopes" as="element()*"/>
    <xsl:param name="states" as="xs:string+"/>

    <xsl:for-each-group
      select="
        $scopes
        [
          not
          (
            following-sibling::*[1][self::snippet-statement]
            [
              @p:label or @p:goto
            ]
          )
        ]"
      group-by="generate-id(p:get-error-handlers(.)[1])">
      <xsl:if test="current-grouping-key()">
        <xsl:variable name="handlers" as="element()+"
          select="p:get-error-handlers(.)"/>

        <xsl:variable name="finally" as="element()?"
          select="$handlers[self::finally]"/>
        
        <xsl:variable name="throwable-handler" as="element()?" select="
          $handlers[self::catch]
          [
            parameter/
              type[empty(@package) or (@package = 'java.lang')]
              [
                @name = 'Throwable'
              ]
          ]"/>

        <xsl:variable name="fallback" as="element()">
          <xsl:choose>
            <xsl:when test="exists($throwable-handler)">
              <scope>
                <expression>
                  <assign>
                    <field name="{$throwable-handler/parameter/@name}"/>
                    <var name="error"/>
                  </assign>
                </expression>
                
                <xsl:variable name="id" as="xs:string"
                  select="$throwable-handler/@p:catch"/>

                <xsl:sequence select="
                  p:generate-goto
                  (
                    $id,
                    false(),
                    (),
                    $pseudo-code,
                    $states
                  )"/>
              </scope>
            </xsl:when>
            <xsl:when test="exists($finally)">
              <scope>
                <expression>
                  <assign>
                    <field
                      name="currentError"
                      name-ref="currentError.state-machine"/>
                    <var name="error"/>
                  </assign>
                </expression>

                <xsl:variable name="id" as="xs:string"
                  select="$finally/@p:finally"/>

                <xsl:sequence select="
                  p:generate-goto
                  (
                    $id,
                    false(),
                    (),
                    $pseudo-code,
                    $states
                  )"/>
              </scope>
            </xsl:when>
            <xsl:otherwise>
              <break/>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:variable>

        <xsl:variable name="closure" as="element()*">
          <xsl:for-each
            select="$handlers except ($finally, $throwable-handler)">

            <xsl:variable name="parameter" as="element()" select="parameter"/>
            <xsl:variable name="type" as="element()" select="$parameter/type"/>

            <instance-of>
              <value>
                <var name="error"/>
              </value>

              <xsl:sequence select="$type"/>
            </instance-of>
            <block>
              <expression>
                <assign>
                  <field>
                    <xsl:sequence select="$parameter/@name"/>
                    <xsl:attribute name="name-ref"
                      select="$parameter/@name-id"/>
                  </field>
                  <cast>
                    <xsl:sequence select="$type"/>

                    <value>
                      <var name="error"/>
                    </value>
                  </cast>
                </assign>
              </expression>

              <xsl:variable name="id" as="xs:string" select="@p:catch"/>

              <xsl:sequence select="
                p:generate-goto
                (
                  $id,
                  false(),
                  (),
                  $pseudo-code,
                  $states
                )"/>
            </block>
          </xsl:for-each>
        </xsl:variable>

        <xsl:for-each select="current-group()">
          <case>
            <value>
              <xsl:variable name="state" as="xs:integer"
                select="index-of($states, @p:label) - 1"/>

              <int value="{$state}"/>
            </value>

            <xsl:if test="position() = last()">
              <block>
                <xsl:sequence select="
                  t:generate-if-statement
                  (
                    $closure,
                    count($closure) - 1,
                    $fallback
                  )"/>
              </block>
            </xsl:if>
          </case>
        </xsl:for-each>
      </xsl:if>
    </xsl:for-each-group>
  </xsl:function>

  <!--
    Mode "p:normalize-code".
    Default template.
  -->
  <xsl:template mode="p:normalize-code" match="text()"/>

  <!--
    Mode "p:normalize-code".
    Default template.
  -->
  <xsl:template mode="p:normalize-code" match="*">
    <xsl:variable name="children" as="element()*" select="*"/>
    
    <xsl:variable name="normalized-children" as="element()*">
      <xsl:apply-templates mode="#current" select="$children"/>
    </xsl:variable>

    <xsl:choose>
      <xsl:when test="
        (count($children) = count($normalized-children)) and
        (
          every $i in 1 to count($children) satisfies
            $children[$i] is $normalized-children[$i]
        )">
        <xsl:sequence select="."/>      
      </xsl:when>
      <xsl:otherwise>
        <xsl:copy>
          <xsl:sequence select="@*"/>
          <xsl:sequence select="$normalized-children"/>
        </xsl:copy>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template mode="p:normalize-code" match="try">
    <xsl:sequence select="t:rewrite-try-statement(., true(), true())"/>
  </xsl:template>

  <!--
    Mode "p:build-pseudo-code".
    Default template.
  -->
  <xsl:template mode="p:build-pseudo-code" match="text()"/>

  <!--
    Mode "p:build-pseudo-code".
    Default template.
  -->
  <xsl:template mode="p:build-pseudo-code" match="*">
    <xsl:copy>
      <xsl:sequence select="@*"/>
      <xsl:apply-templates mode="p:copy-pseudo-code"/>
    </xsl:copy>
  </xsl:template>

  <!--
    Mode "p:copy-pseudo-code".
    Default template.
  -->
  <xsl:template mode="p:copy-pseudo-code" match="node()">
    <xsl:copy>
      <xsl:sequence select="@*"/>
      <xsl:apply-templates mode="p:copy-pseudo-code"/>
    </xsl:copy>
  </xsl:template>

  <!--
    Mode "p:build-pseudo-code". Remove meta.
  -->
  <xsl:template mode="p:build-pseudo-code" match="meta"/>

  <!--
    Mode "p:build-pseudo-code". Comments.
  -->
  <xsl:template mode="p:build-pseudo-code" match="comment">
    <scope>
      <xsl:sequence select="."/>
    </scope>
  </xsl:template>

  <!--
    Gets variable declarations in a specified scope.
      $scope - a scope to get declarations for.
      Returns variable declarations in a specified scope.
  -->
  <xsl:function name="p:get-var-decls-in-scope" as="element()*">
    <xsl:param name="scope" as="element()"/>

    <xsl:sequence select="
      $scope/
      (
        var-decl |
        scope/p:get-var-decls-in-scope(.)
      )"/>
  </xsl:function>

  <!--
    Mode "p:copy-pseudo-code". var expression
      $method - a method to convert to a state machine.
      $yield-statements - a set of statements containing yield markers.
  -->
  <xsl:template mode="p:copy-pseudo-code" match="var">
    <xsl:param name="method" tunnel="yes" as="element()"/>
    <xsl:param name="yield-statements" tunnel="yes" as="element()+"/>

    <xsl:variable name="name" as="xs:string" select="@name"/>
    <xsl:variable name="name-id" as="xs:string?" select="@name-ref"/>

    <xsl:variable name="var-decl" as="element()?" select="
      (
        ancestor::*[. >> $method/block]/
        (
          preceding-sibling::var-decl |
          preceding-sibling::scope/p:get-var-decls-in-scope(.) |
          self::catch/parameter |
          self::for/var-decl |
          self::for-each/var-decl
        )
        [
          if (exists($name-id)) then
            @name-id = $name-id
          else
            (@name = $name) and empty(@name-id)
        ]
      )
      [last()]"/>

    <xsl:copy>
      <xsl:sequence select="@*"/>

      <xsl:if test="
        exists
        (
          $var-decl/
          (
            self::var-decl/parent::*,
            self::parameter/parent::catch/parent::try
          ) intersect $yield-statements
        )">

        <xsl:if test="empty($name-id)">
          <xsl:attribute name="name-ref"
            select="concat('var.', generate-id($var-decl), '.state-machine')"/>
        </xsl:if>

        <xsl:attribute name="p:state" select="true()"/>
      </xsl:if>

      <xsl:apply-templates mode="#current"/>
    </xsl:copy>
  </xsl:template>

  <!--
    Mode "p:build-pseudo-code".
    Defines whether to copy statement, or convert into state machine.
      $yield-statements - a set of statements containing yield markers.
  -->
  <xsl:template mode="p:build-pseudo-code" match="
    scope |
    block |
    if |
    for |
    for-each |
    while |
    do-while |
    try |
    switch"
    priority="2">
    <xsl:param name="yield-statements" tunnel="yes" as="element()+"/>

    <xsl:choose>
      <xsl:when test="exists(. intersect $yield-statements)">
        <xsl:next-match/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:apply-templates mode="p:copy-pseudo-code" select="."/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!--
    Mode "p:build-pseudo-code". Creates a pseudo code for a scope.
  -->
  <xsl:template mode="p:build-pseudo-code" match="scope">
    <xsl:apply-templates mode="p:build-pseudo-code"/>
  </xsl:template>

  <!--
    Mode "p:build-pseudo-code". Yield marker.
  -->
  <xsl:template mode="p:build-pseudo-code"
    match="snippet-statement[xs:boolean(@yield)]">
    <xsl:variable name="id" as="xs:string" select="generate-id()"/>

    <snippet-statement yield="true">
      <xsl:attribute name="p:goto"
        select="concat('statement.', $id, '.state-machine')"/>
    </snippet-statement>

    <snippet-statement>
      <xsl:attribute name="p:label"
        select="concat('statement.', $id, '.state-machine')"/>
    </snippet-statement>
  </xsl:template>

  <!--
    Mode "p:build-pseudo-code".
    Variable declarations.
  -->
  <xsl:template mode="p:build-pseudo-code" match="var-decl | parameter">
    <xsl:copy>
      <xsl:sequence select="@*"/>

      <xsl:if test="empty(@name-id)">
        <xsl:attribute name="name-id"
          select="concat('var.', generate-id(), '.state-machine')"/>
      </xsl:if>

      <xsl:attribute name="p:state" select="true()"/>

      <xsl:apply-templates mode="p:copy-pseudo-code"/>
    </xsl:copy>
  </xsl:template>

  <!--
    Mode "p:build-pseudo-code". Creates a pseudo code for a block.
  -->
  <xsl:template mode="p:build-pseudo-code" match="block">
    <xsl:variable name="label" as="xs:string?" select="@label"/>

    <xsl:apply-templates  mode="p:build-pseudo-code"/>

    <xsl:if test="exists($label)">
      <snippet-statement>
        <xsl:attribute name="p:label"
          select="concat('statement.', generate-id(), '.end.state-machine')"/>
      </snippet-statement>
    </xsl:if>
  </xsl:template>

  <!--
    Mode "p:build-pseudo-code". Creates a pseudo code for an "if" statement.
      $yield-statements - a set of statements containing yield markers.
  -->
  <xsl:template mode="p:build-pseudo-code" match="if">
    <xsl:param name="yield-statements" tunnel="yes" as="element()+"/>

    <xsl:variable name="id" as="xs:string" select="generate-id()"/>
    <xsl:variable name="label" as="xs:string?" select="@label"/>
    <xsl:variable name="then" as="element()" select="then"/>
    <xsl:variable name="else" as="element()?" select="else"/>

    <xsl:variable name="then-code" as="element()*">
      <xsl:apply-templates mode="p:build-pseudo-code" select="$then/*"/>
    </xsl:variable>

    <xsl:variable name="else-code" as="element()*">
      <xsl:apply-templates mode="p:build-pseudo-code" select="$else/*"/>
    </xsl:variable>

    <xsl:variable name="then-count" as="xs:integer"
      select="count($then-code)"/>
    <xsl:variable name="else-count" as="xs:integer"
      select="count($else-code)"/>

    <xsl:variable name="then-index" as="xs:integer?" select="
      (
        (
          for
            $i in 1 to $then-count,
            $statement in $then-code[$i],
            $label in $statement[self::snippet-statement][@p:label]
          return
            $i
        ),
        $then-count + 1
      )[1]"/>

    <xsl:variable name="else-index" as="xs:integer?" select="
      (
        (
          for
            $i in 1 to $else-count,
            $statement in $else-code[$i],
            $label in $statement[self::snippet-statement][@p:label]
          return
            $i
        ),
        $else-count + 1
      )[1]"/>

    <xsl:copy>
      <xsl:sequence select="@* except (@label, @label-id)"/>
      <xsl:sequence select="meta | comment"/>

      <xsl:apply-templates mode="p:copy-pseudo-code" select="condition"/>

      <then>
        <xsl:sequence select="subsequence($then-code, 1, $then-index - 1)"/>

        <snippet-statement>
          <xsl:attribute name="p:goto" select="
            if ($then-index lt $then-count) then
              concat('if.', $id, '.then.state-machine')
            else
              concat('statement.', $id, '.end.state-machine')"/>
        </snippet-statement>
      </then>

      <xsl:if test="($then-index lt $then-count) or ($else-count > 0)">
        <else>
          <xsl:sequence select="subsequence($else-code, 1, $else-index - 1)"/>

          <snippet-statement>
            <xsl:attribute name="p:goto" select="
              if ($else-index lt $else-count) then
                concat('if.', $id, '.else.state-machine')
              else
                concat('statement.', $id, '.end.state-machine')"/>
          </snippet-statement>
        </else>
      </xsl:if>
    </xsl:copy>

    <xsl:if test="$then-index lt $then-count">
      <snippet-statement>
        <xsl:attribute name="p:label"
          select="concat('if.', $id, '.then.state-machine')"/>
      </snippet-statement>

      <xsl:sequence select="subsequence($then-code, $then-index)"/>

      <xsl:if test="$else-index lt $else-count">
        <snippet-statement>
          <xsl:attribute name="p:goto"
            select="concat('statement.', $id, '.end.state-machine')"/>
        </snippet-statement>
      </xsl:if>
    </xsl:if>

    <xsl:if test="$else-index lt $else-count">
      <snippet-statement>
        <xsl:attribute name="p:label"
          select="concat('if.', $id, '.else.state-machine')"/>
      </snippet-statement>

      <xsl:sequence select="subsequence($else-code, $else-index)"/>
    </xsl:if>

    <xsl:if test="$then-index = $then-count">
      <xsl:sequence select="subsequence($then-code, $then-index)"/>
    </xsl:if>

    <xsl:if test="$else-index = $else-count">
      <xsl:sequence select="subsequence($else-code, $else-index)"/>
    </xsl:if>

    <snippet-statement>
      <xsl:attribute name="p:label"
        select="concat('statement.', $id, '.end.state-machine')"/>
    </snippet-statement>
  </xsl:template>

  <!--
    Mode "p:build-pseudo-code". Creates a pseudo code for a "switch" statement.
      $yield-statements - a set of statements containing yield markers.
  -->
  <xsl:template mode="p:build-pseudo-code" match="switch">
    <xsl:param name="yield-statements" tunnel="yes" as="element()+"/>

    <xsl:variable name="id" as="xs:string" select="generate-id()"/>
    <xsl:variable name="cases" as="element()+" select="case"/>

    <xsl:variable name="yields" as="xs:boolean+" select="
      for $case in $cases return
        exists($case intersect $yield-statements)"/>

    <xsl:copy>
      <xsl:sequence select="@* except (@label, @label-id)"/>
      <xsl:sequence select="meta | comment"/>

      <xsl:apply-templates mode="p:copy-pseudo-code" select="test"/>

      <xsl:for-each select="$cases">
        <xsl:variable name="index" as="xs:integer" select="position()"/>

        <xsl:variable name="preceding-breaks" as="xs:boolean" select="
          every $block in $cases[$index - 1]/block satisfies
            exists($block/(break, continue, return, throw))"/>

        <xsl:choose>
          <xsl:when test="
            not($preceding-breaks) and $yields[$index -1] or $yields[$index]">
            <case>
              <xsl:sequence select="@*"/>
              <xsl:sequence select="meta | comment"/>

              <xsl:apply-templates mode="p:copy-pseudo-code" select="value"/>

              <block>
                <snippet-statement>
                  <xsl:attribute name="p:goto" select="
                    concat
                    (
                      'statement.',
                      generate-id(),
                      '.case.state-machine'
                    )"/>
                </snippet-statement>
              </block>
            </case>
          </xsl:when>
          <xsl:otherwise>
            <xsl:apply-templates mode="p:copy-pseudo-code" select="."/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:for-each>
    </xsl:copy>

    <snippet-statement>
      <xsl:attribute name="p:goto"
        select="concat('statement.', $id, '.end.state-machine')"/>
    </snippet-statement>

    <xsl:for-each select="$cases">
      <xsl:variable name="index" as="xs:integer" select="position()"/>

      <xsl:variable name="preceding-breaks" as="xs:boolean" select="
        every $block in $cases[$index - 1]/block satisfies
          exists($block/(break, continue, return, throw))"/>

      <xsl:if test="
        not($preceding-breaks) and $yields[$index -1] or $yields[$index]">
        <snippet-statement>
          <xsl:attribute name="p:label" select="
            concat('statement.', generate-id(), '.case.state-machine')"/>
        </snippet-statement>

        <xsl:apply-templates mode="p:build-pseudo-code" select="block/*"/>

        <snippet-statement>
          <xsl:variable name="case-breaks" as="xs:boolean"
            select="exists(block/break)"/>
          <xsl:variable name="next-case" as="element()?"
            select="$cases[$index + 1]"/>

          <xsl:attribute name="p:goto" select="
            if ($case-breaks or empty($next-case)) then
              concat('statement.', $id, '.end.state-machine')
            else
              concat
              (
                'statement.',
                generate-id($next-case),
                '.case.state-machine'
              )"/>
        </snippet-statement>
      </xsl:if>
    </xsl:for-each>

    <snippet-statement>
      <xsl:attribute name="p:label"
        select="concat('statement.', $id, '.end.state-machine')"/>
    </snippet-statement>
  </xsl:template>

  <!--
    Mode "p:build-pseudo-code". Creates a pseudo code for a "for" statement.
      $yield-statements - a set of statements containing yield markers.
  -->
  <xsl:template mode="p:build-pseudo-code" match="for">
    <xsl:variable name="id" as="xs:string" select="generate-id()"/>
    <xsl:variable name="statement" as="element()" select="."/>

    <xsl:apply-templates mode="p:build-pseudo-code" select="comment"/>

    <xsl:variable name="var-decl" as="element()*" select="var-decl"/>
    <xsl:variable name="initialize" as="element()*" select="initialize"/>
    <xsl:variable name="condition" as="element()?" select="condition"/>
    <xsl:variable name="update" as="element()*" select="update"/>
    <xsl:variable name="block" as="element()" select="block"/>

    <xsl:choose>
      <xsl:when test="exists($var-decl)">
        <xsl:apply-templates mode="#current" select="$var-decl"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:for-each select="$initialize/(* except (meta, comment))">
          <expression>
            <xsl:apply-templates mode="p:copy-pseudo-code" select="."/>
          </expression>
        </xsl:for-each>
      </xsl:otherwise>
    </xsl:choose>

    <snippet-statement>
      <xsl:attribute name="p:label"
        select="concat('statement.', $id, '.next.state-machine')"/>
    </snippet-statement>

    <xsl:variable name="body-code" as="element()*">
      <xsl:apply-templates mode="p:build-pseudo-code" select="$block"/>

      <xsl:if test="
        exists
        (
          $block//
            continue[t:get-statement-for-break($statement, .) is $statement]
        )">
        <snippet-statement>
          <xsl:attribute name="p:label"
            select="concat('statement.', $id, '.continue.state-machine')"/>
        </snippet-statement>
      </xsl:if>

      <xsl:for-each select="$update/(* except (meta, comment))">
        <expression>
          <xsl:apply-templates mode="p:copy-pseudo-code" select="."/>
        </expression>
      </xsl:for-each>

      <snippet-statement>
        <xsl:attribute name="p:goto"
          select="concat('statement.', $id, '.next.state-machine')"/>
      </snippet-statement>
    </xsl:variable>

    <xsl:variable name="body-count" as="xs:integer"
      select="count($body-code)"/>

    <xsl:variable name="body-index" as="xs:integer?" select="
      (
        (
          for
            $i in 1 to $body-count,
            $statement in $body-code[$i],
            $label in $statement[self::snippet-statement][@p:label]
          return
            $i
        ),
        $body-count + 1
      )[1]"/>

    <xsl:choose>
      <xsl:when test="empty($condition[not(xs:boolean(boolean))])">
        <xsl:sequence select="$body-code"/>
      </xsl:when>
      <xsl:otherwise>
        <if>
          <xsl:apply-templates mode="p:copy-pseudo-code" select="$condition"/>

          <then>
            <xsl:sequence
              select="subsequence($body-code, 1, $body-index - 1)"/>

            <xsl:if test="$body-index lt $body-count">
              <snippet-statement>
                <xsl:attribute name="p:goto"
                  select="concat('statement.', $id, '.body.state-machine')"/>
              </snippet-statement>
            </xsl:if>
          </then>
        </if>

        <xsl:if test="$body-index le $body-count">
          <snippet-statement>
            <xsl:attribute name="p:goto"
              select="concat('statement.', $id, '.end.state-machine')"/>
          </snippet-statement>

          <snippet-statement>
            <xsl:attribute name="p:label"
              select="concat('statement.', $id, '.body.state-machine')"/>
          </snippet-statement>

          <xsl:sequence select="subsequence($body-code, $body-index)"/>
        </xsl:if>
      </xsl:otherwise>
    </xsl:choose>

    <snippet-statement>
      <xsl:attribute name="p:label"
        select="concat('statement.', $id, '.end.state-machine')"/>
    </snippet-statement>
  </xsl:template>

  <!--
    Mode "p:build-pseudo-code". Creates a pseudo code for a
    "for-each" statement.
      $yield-statements - a set of statements containing yield markers.
  -->
  <xsl:template mode="p:build-pseudo-code" match="for-each">
    <xsl:variable name="id" as="xs:string" select="generate-id()"/>
    <xsl:variable name="statement" as="element()" select="."/>

    <xsl:apply-templates mode="p:build-pseudo-code" select="comment"/>

    <xsl:variable name="var-decl" as="element()" select="var-decl"/>
    <xsl:variable name="type" as="element()" select="$var-decl/type"/>
    <xsl:variable name="collection-type" as="element()?" select="
      t:get-type-of(t:get-java-element($var-decl/initialize), false())"/>
    <xsl:variable name="block" as="element()" select="block"/>
    <xsl:variable name="is-array" as="xs:boolean?"
      select="xs:boolean($collection-type/@array)"/>

    <xsl:choose>
      <xsl:when test="$is-array">
        <var-decl name="array" p:state="true">
          <xsl:attribute name="name-id"
            select="concat('var.', $id, '.array.state-machine')"/>

          <xsl:sequence select="$collection-type"/>

          <initialize>
            <xsl:apply-templates mode="p:copy-pseudo-code"
              select="$var-decl/initialize/*"/>
          </initialize>
        </var-decl>
        <var-decl name="i" p:state="true">
          <xsl:attribute name="name-id"
            select="concat('var.', $id, '.index.state-machine')"/>

          <xsl:sequence select="$t:int"/>

          <initialize>
            <int value="0"/>
          </initialize>
        </var-decl>
      </xsl:when>
      <xsl:otherwise>
        <var-decl name="iterator" p:state="true">
          <xsl:attribute name="name-id"
            select="concat('var.', $id, '.iterator.state-machine')"/>

          <type name="Iterator" package="java.util">
            <argument>
              <xsl:sequence select="t:get-boxed-type($var-decl/type)"/>
            </argument>
          </type>
          <initialize>
            <invoke name="iterator">
              <instance>
                <xsl:apply-templates mode="p:copy-pseudo-code"
                  select="$var-decl/initialize/*"/>
              </instance>
            </invoke>
          </initialize>
        </var-decl>
      </xsl:otherwise>
    </xsl:choose>

    <snippet-statement>
      <xsl:attribute name="p:label"
        select="concat('statement.', $id, '.next.state-machine')"/>
    </snippet-statement>

    <xsl:variable name="body-code" as="element()*">
      <var-decl p:state="true">
        <xsl:sequence select="$var-decl/(@name, @name-id)"/>

        <xsl:if test="empty(@name-id)">
          <xsl:attribute name="name-id"
            select="concat('var.', generate-id($var-decl), '.state-machine')"/>
        </xsl:if>

        <xsl:sequence select="$var-decl/(meta | comment | type)"/>

        <initialize>
          <xsl:choose>
            <xsl:when test="$is-array">
              <subscript>
                <var name="array">
                  <xsl:attribute name="name-ref"
                    select="concat('var.', $id, '.array.state-machine')"/>
                </var>
                <postfix-inc>
                  <var name="i">
                    <xsl:attribute name="name-ref"
                      select="concat('var.', $id, '.index.state-machine')"/>
                  </var>
                </postfix-inc>
              </subscript>
            </xsl:when>
            <xsl:otherwise>
              <invoke name="next">
                <instance>
                  <var name="iterator">
                    <xsl:attribute name="name-ref"
                      select="concat('var.', $id, '.iterator.state-machine')"/>
                  </var>
                </instance>
              </invoke>
            </xsl:otherwise>
          </xsl:choose>
        </initialize>
      </var-decl>

      <xsl:apply-templates mode="p:build-pseudo-code" select="$block"/>

      <xsl:if test="
        exists
        (
          $block//
            continue[t:get-statement-for-break($statement, .) is $statement]
        )">
        <snippet-statement>
          <xsl:attribute name="p:label"
            select="concat('statement.', $id, '.continue.state-machine')"/>
        </snippet-statement>
      </xsl:if>

      <snippet-statement>
        <xsl:attribute name="p:goto"
          select="concat('statement.', $id, '.next.state-machine')"/>
      </snippet-statement>
    </xsl:variable>

    <xsl:variable name="body-count" as="xs:integer"
      select="count($body-code)"/>

    <xsl:variable name="body-index" as="xs:integer?" select="
      (
        (
          for
            $i in 1 to $body-count,
            $statement in $body-code[$i],
            $label in $statement[self::snippet-statement][@p:label]
          return
            $i
        ),
        $body-count + 1
      )[1]"/>

    <if>
      <condition>
        <xsl:choose>
          <xsl:when test="$is-array">
            <lt>
              <var name="i">
                <xsl:attribute name="name-ref"
                  select="concat('var.', $id, '.index.state-machine')"/>
              </var>
              <field name="length">
                <var name="array">
                  <xsl:attribute name="name-ref"
                    select="concat('var.', $id, '.array.state-machine')"/>
                </var>
              </field>
            </lt>
          </xsl:when>
          <xsl:otherwise>
            <invoke name="hasNext">
              <instance>
                <var name="iterator">
                  <xsl:attribute name="name-ref"
                    select="concat('var.', $id, '.iterator.state-machine')"/>
                </var>
              </instance>
            </invoke>
          </xsl:otherwise>
        </xsl:choose>
      </condition>
      <then>
        <xsl:sequence
          select="subsequence($body-code, 1, $body-index - 1)"/>

        <xsl:if test="$body-index lt $body-count">
          <snippet-statement>
            <xsl:attribute name="p:goto"
              select="concat('statement.', $id, '.body.state-machine')"/>
          </snippet-statement>
        </xsl:if>
      </then>
    </if>

    <xsl:if test="$body-index le $body-count">
      <snippet-statement>
        <xsl:attribute name="p:goto"
          select="concat('statement.', $id, '.end.state-machine')"/>
      </snippet-statement>

      <snippet-statement>
        <xsl:attribute name="p:label"
          select="concat('statement.', $id, '.body.state-machine')"/>
      </snippet-statement>

      <xsl:sequence select="subsequence($body-code, $body-index)"/>
    </xsl:if>

    <snippet-statement>
      <xsl:attribute name="p:label"
        select="concat('statement.', $id, '.end.state-machine')"/>
    </snippet-statement>
  </xsl:template>

  <!--
    Mode "p:build-pseudo-code". Creates a pseudo code for a "while" statement.
      $yield-statements - a set of statements containing yield markers.
  -->
  <xsl:template mode="p:build-pseudo-code" match="while">
    <xsl:variable name="id" as="xs:string" select="generate-id()"/>
    <xsl:variable name="statement" as="element()" select="."/>

    <xsl:apply-templates mode="p:copy-pseudo-code" select="comment"/>

    <xsl:variable name="condition" as="element()" select="condition"/>
    <xsl:variable name="block" as="element()" select="block"/>

    <xsl:if test="
      exists
      (
        $block//
          continue[t:get-statement-for-break($statement, .) is $statement]
      )">
      <snippet-statement>
        <xsl:attribute name="p:label"
          select="concat('statement.', $id, '.continue.state-machine')"/>
      </snippet-statement>
    </xsl:if>

    <snippet-statement>
      <xsl:attribute name="p:label"
        select="concat('statement.', $id, '.next.state-machine')"/>
    </snippet-statement>

    <xsl:variable name="body-code" as="element()*">
      <xsl:apply-templates mode="p:build-pseudo-code" select="$block"/>

      <snippet-statement>
        <xsl:attribute name="p:goto"
          select="concat('statement.', $id, '.next.state-machine')"/>
      </snippet-statement>
    </xsl:variable>

    <xsl:variable name="body-count" as="xs:integer"
      select="count($body-code)"/>

    <xsl:variable name="body-index" as="xs:integer?" select="
      (
        (
          for
            $i in 1 to $body-count,
            $statement in $body-code[$i],
            $label in $statement[self::snippet-statement][@p:label]
          return
            $i
        ),
        $body-count + 1
      )[1]"/>

    <xsl:choose>
      <xsl:when test="empty($condition[not(xs:boolean(boolean))])">
        <xsl:sequence select="$body-code"/>
      </xsl:when>
      <xsl:otherwise>
        <if>
          <xsl:apply-templates mode="p:copy-pseudo-code" select="$condition"/>

          <then>
            <xsl:sequence
              select="subsequence($body-code, 1, $body-index - 1)"/>

            <xsl:if test="$body-index lt $body-count">
              <snippet-statement>
                <xsl:attribute name="p:goto"
                  select="concat('statement.', $id, '.body.state-machine')"/>
              </snippet-statement>
            </xsl:if>
          </then>
        </if>

        <xsl:if test="$body-index le $body-count">
          <snippet-statement>
            <xsl:attribute name="p:goto"
              select="concat('statement.', $id, '.end.state-machine')"/>
          </snippet-statement>

          <snippet-statement>
            <xsl:attribute name="p:label"
              select="concat('statement.', $id, '.body.state-machine')"/>
          </snippet-statement>

          <xsl:sequence select="subsequence($body-code, $body-index)"/>
        </xsl:if>
      </xsl:otherwise>
    </xsl:choose>

    <snippet-statement>
      <xsl:attribute name="p:label"
        select="concat('statement.', $id, '.end.state-machine')"/>
    </snippet-statement>
  </xsl:template>

  <!--
    Mode "p:build-pseudo-code". Creates a pseudo code for a
    "do-while" statement.
      $yield-statements - a set of statements containing yield markers.
  -->
  <xsl:template mode="p:build-pseudo-code" match="do-while">
    <xsl:variable name="id" as="xs:string" select="generate-id()"/>
    <xsl:variable name="statement" as="element()" select="."/>

    <xsl:apply-templates mode="p:build-pseudo-code" select="comment"/>

    <xsl:variable name="condition" as="element()" select="condition"/>
    <xsl:variable name="block" as="element()" select="block"/>

    <snippet-statement>
      <xsl:attribute name="p:label"
        select="concat('statement.', $id, '.next.state-machine')"/>
    </snippet-statement>

    <xsl:apply-templates mode="p:build-pseudo-code" select="$block"/>

    <xsl:if test="
      exists
      (
        $block//
          continue[t:get-statement-for-break($statement, .) is $statement]
      )">
      <snippet-statement>
        <xsl:attribute name="p:label"
          select="concat('statement.', $id, '.continue.state-machine')"/>
      </snippet-statement>
    </xsl:if>

    <xsl:choose>
      <xsl:when test="empty($condition/boolean[xs:boolean(.)])">
        <if>
          <xsl:apply-templates mode="p:copy-pseudo-code"
            select="$condition"/>

          <then>
            <snippet-statement>
              <xsl:attribute name="p:goto"
                select="concat('statement.', $id, '.next.state-machine')"/>
            </snippet-statement>
          </then>
        </if>
      </xsl:when>
      <xsl:otherwise>
        <snippet-statement>
          <xsl:attribute name="p:goto"
            select="concat('statement.', $id, '.next.state-machine')"/>
        </snippet-statement>
      </xsl:otherwise>
    </xsl:choose>

    <snippet-statement>
      <xsl:attribute name="p:label"
        select="concat('statement.', $id, '.end.state-machine')"/>
    </snippet-statement>
  </xsl:template>

  <!--
    Mode "p:build-pseudo-code". Creates a pseudo code for a "try" statement.
      $method - a method to convert into a state machine.
  -->
  <xsl:template mode="p:build-pseudo-code" match="try">
    <xsl:variable name="id" as="xs:string" select="generate-id(.)"/>

    <snippet-statement>
      <xsl:attribute name="p:goto"
        select="concat('statement.', $id, '.try.state-machine')"/>
    </snippet-statement>

    <snippet-statement>
      <xsl:attribute name="p:label"
        select="concat('statement.', $id, '.begin.state-machine')"/>
    </snippet-statement>

    <xsl:copy>
      <xsl:sequence select="@* except (@label, @label-id)"/>
      <xsl:attribute name="p:try"
        select="concat('statement.', $id, '.try.state-machine')"/>
      <xsl:sequence select="meta | comment"/>

      <xsl:variable name="finally" as="element()?" select="finally"/>

      <block>
        <snippet-statement>
          <xsl:attribute name="p:label"
            select="concat('statement.', $id, '.try.state-machine')"/>
        </snippet-statement>

        <xsl:variable name="block" as="element()" select="block"/>

        <xsl:sequence select="$block/@*"/>

        <xsl:apply-templates mode="p:build-pseudo-code" select="$block/*"/>

        <snippet-statement>
          <xsl:attribute name="p:goto" select="
            if (exists($finally)) then
              concat
              (
                'statement.',
                generate-id($finally),
                '.begin.state-machine'
              )
            else
              concat('statement.', $id, '.end.state-machine')"/>
        </snippet-statement>
      </block>

      <xsl:for-each select="catch">
        <xsl:copy>
          <xsl:sequence select="@*"/>
          <xsl:attribute name="p:catch" select="
            concat('statement.', generate-id(.), '.begin.state-machine')"/>
          <xsl:sequence select="meta | comment"/>

          <xsl:apply-templates mode="#current" select="parameter"/>

          <block>
            <snippet-statement>
              <xsl:attribute name="p:label" select="
                concat('statement.', generate-id(.), '.begin.state-machine')"/>
            </snippet-statement>

            <xsl:variable name="block" as="element()" select="block"/>

            <xsl:sequence select="$block/@*"/>

            <xsl:apply-templates mode="p:build-pseudo-code" select="$block/*"/>

            <snippet-statement>
              <xsl:attribute name="p:goto" select="
                if (exists($finally)) then
                  concat
                  (
                    'statement.',
                    generate-id($finally),
                    '.begin.state-machine'
                  )
                else
                  concat('statement.', $id, '.end.state-machine')"/>
            </snippet-statement>
          </block>
        </xsl:copy>
      </xsl:for-each>

      <xsl:for-each select="$finally">
        <xsl:copy>
          <xsl:sequence select="@*"/>
          <xsl:attribute name="p:finally" select="
            concat('statement.', generate-id(.), '.begin.state-machine')"/>

          <snippet-statement>
            <xsl:attribute name="p:label" select="
              concat
              (
                'statement.',
                generate-id($finally),
                '.begin.state-machine'
              )"/>
          </snippet-statement>

          <xsl:apply-templates mode="p:build-pseudo-code"/>

          <snippet-statement p:finally="true">
            <xsl:variable name="next-try" as="element()?" select="
              (ancestor::block/(., parent::catch)/parent::try[finally])
              [
                last()
              ]"/>

            <xsl:attribute name="p:goto"
              select="concat('statement.', $id, '.end.state-machine')"/>

            <xsl:if test="exists($next-try)">
              <xsl:attribute name="p:next-try" select="
                concat
                (
                  'statement.',
                  generate-id($next-try),
                  '.try.state-machine'
                )"/>

              <xsl:attribute name="p:next-finally" select="
                concat
                (
                  'statement.',
                  generate-id($next-try/finally),
                  '.begin.state-machine'                             
                )"/>
            </xsl:if>
          </snippet-statement>
        </xsl:copy>
      </xsl:for-each>
    </xsl:copy>

    <snippet-statement>
      <xsl:attribute name="p:label"
        select="concat('statement.', $id, '.end.state-machine')"/>
    </snippet-statement>
  </xsl:template>

  <!--
    Mode "p:build-pseudo-code". Creates a pseudo code for a "return" statement.
      $method - a method to convert.
  -->
  <xsl:template mode="p:build-pseudo-code" match="return">
    <xsl:param name="method" tunnel="yes" as="element()"/>

    <xsl:variable name="id" as="xs:string" select="generate-id($method)"/>

    <xsl:variable name="finally" as="element()?" select="
      (ancestor::block/(., parent::catch)/parent::try[finally])[last()]/
        finally"/>

    <snippet-statement>
      <xsl:choose>
        <xsl:when test="exists($finally)">
          <xsl:attribute name="p:goto" select="
            concat
            (
              'statement.',
              generate-id($finally),
              '.begin.state-machine'
            )"/>
          <xsl:attribute name="p:next"
            select="concat('statement.', $id, '.end.state-machine')"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:attribute name="p:goto"
            select="concat('statement.', $id, '.end.state-machine')"/>
        </xsl:otherwise>
      </xsl:choose>
    </snippet-statement>
  </xsl:template>

  <!--
    Mode "p:build-pseudo-code". Creates a pseudo code for a "break" statement.
      $method - a method to convert into a state machine.
  -->
  <xsl:template mode="p:build-pseudo-code" match="break">
    <xsl:param name="method" tunnel="yes" as="element()"/>

    <xsl:variable name="reference" as="element()"
      select="t:get-statement-for-break($method/block, .)"/>
    <xsl:variable name="try" as="element()?" select="
      (ancestor::block/(., parent::catch)/parent::try[finally])[last()]"/>

    <snippet-statement>
      <xsl:choose>
        <xsl:when test="($try >> $reference) or ($try is $reference)">
          <xsl:attribute name="p:goto" select="
            concat
            (
              'statement.',
              generate-id($try/finally),
              '.begin.state-machine'
            )"/>
          <xsl:attribute name="p:next" select="
            concat
            (
              'statement.',
              generate-id($reference),
              '.end.state-machine'
            )"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:attribute name="p:goto" select="
            concat
            (
              'statement.',
              generate-id($reference),
              '.end.state-machine'
            )"/>
        </xsl:otherwise>
      </xsl:choose>
    </snippet-statement>
  </xsl:template>

  <!--
    Mode "p:build-pseudo-code". Creates a pseudo code for a
    "continue" statement.
      $method - a method to convert into a state machine.
  -->
  <xsl:template mode="p:build-pseudo-code" match="continue">
    <xsl:param name="method" tunnel="yes" as="element()"/>

    <xsl:variable name="reference" as="element()"
      select="t:get-statement-for-break($method/block, .)"/>
    <xsl:variable name="try" as="element()?" select="
      (ancestor::block/(., parent::catch)/parent::try[finally])[last()]"/>

    <snippet-statement>
      <xsl:choose>
        <xsl:when test="($try >> $reference) or ($try is $reference)">
          <xsl:attribute name="p:goto" select="
            concat
            (
              'statement.',
              generate-id($try/finally),
              '.begin.state-machine'
            )"/>
          <xsl:attribute name="p:next" select="
            concat
            (
              'statement.',
              generate-id($reference),
              '.continue.state-machine'
            )"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:attribute name="p:goto" select="
            concat
            (
              'statement.',
              generate-id($reference),
              '.continue.state-machine'
            )"/>
        </xsl:otherwise>
      </xsl:choose>
    </snippet-statement>
  </xsl:template>

  <!--
    Mode "p:generate-case".
    Generates state machine case from a pseudo code.
    Default match.
  -->
  <xsl:template mode="p:generate-case" match="node()">
    <xsl:copy>
      <xsl:sequence select="@*"/>
      <xsl:apply-templates mode="#current"/>
    </xsl:copy>
  </xsl:template>

  <!--
    Mode "p:generate-case".
    Copy comment and meta.
  -->
  <xsl:template mode="p:generate-case" match="meta | comment">
    <xsl:sequence select="."/>
  </xsl:template>

  <!--
    Mode "p:generate-case".
    Remove state variables.
  -->
  <xsl:template mode="p:generate-case" match="var-decl[xs:boolean(@p:state)]">
    <xsl:variable name="initialize" as="element()?" select="initialize"/>

    <xsl:if test="exists($initialize)">
      <expression>
        <xsl:sequence select="meta | comment"/>

        <assign>
          <var>
            <xsl:sequence select="@name"/>
            <xsl:attribute name="name-ref" select="@name-id"/>
          </var>

          <xsl:apply-templates mode="#current"
            select="$initialize/(* except (comment, meta))"/>
        </assign>
      </expression>
    </xsl:if>
  </xsl:template>

  <!--
    Mode "p:generate-case".
    Fixup variables.
  -->
  <xsl:template mode="p:generate-case" match="var[xs:boolean(@p:state)]">
    <xsl:copy>
      <xsl:sequence select="@* except @p:state"/>
      <xsl:sequence select="node()"/>
    </xsl:copy>
  </xsl:template>

  <!--
    Mode "p:generate-case".
    Reduces label.
  -->
  <xsl:template mode="p:generate-case" match="snippet-statement[@p:label]"/>

  <!--
    Mode "p:generate-case".
    Change state.
      $pseudo-code - a pseudo code block.
      $statements - a pseudo stateemts.
      $states - a state ids.
      $has-next-state - true if return/break/continue is used to
        exit from try-finally block, and false otherwise.
  -->
  <xsl:template mode="p:generate-case" match="snippet-statement[@p:goto]">
    <xsl:param name="pseudo-code" tunnel="yes" as="element()"/>
    <xsl:param name="states" tunnel="yes" as="xs:string+"/>
    <xsl:param name="has-next-state" tunnel="yes" as="xs:boolean"/>

    <xsl:variable name="goto" as="element()+" select="
      p:generate-goto
      (
        @p:goto,
        xs:boolean(@yield) = true(),
        @p:next,
        $pseudo-code,
        $states
      )"/>

    <xsl:choose>
      <xsl:when test="xs:boolean(@p:finally)">
        <if>
          <condition>
            <ne>
              <field
                name="currentError"
                name-ref="currentError.state-machine"/>
              <null/>
            </ne>
          </condition>
          <then>
            <throw>
              <field
                name="currentError"
                name-ref="currentError.state-machine"/>
            </throw>
          </then>
        </if>

        <xsl:choose>
          <xsl:when test="$has-next-state">
            <xsl:variable name="next-try" as="xs:string?"
              select="@p:next-try"/>
            <xsl:variable name="next-finally" as="xs:string?"
              select="@p:next-finally"/>

            <if>
              <condition>
                <eq>
                  <field
                    name="nextState"
                    name-ref="next-state.state-machine"/>
                  <int value="0"/>
                </eq>
              </condition>
              <then>
                <xsl:sequence select="$goto"/>
              </then>
            </if>

            <xsl:choose>
              <xsl:when test="exists($next-try)">
                <xsl:variable name="next-try-state" as="xs:integer"
                  select="index-of($states, $next-try) - 1"/>
                <xsl:variable name="next-finally-state" as="xs:integer"
                  select="index-of($states, $next-finally) - 1"/>

                <if>
                  <condition>
                    <or>
                      <lt>
                        <field
                          name="nextState"
                          name-ref="next-state.state-machine"/>
                        <int value="{$next-try-state}"/>
                      </lt>
                      <gt>
                        <field
                          name="nextState"
                          name-ref="next-state.state-machine"/>
                        <int value="{$next-finally-state}"/>
                      </gt>
                    </or>
                  </condition>
                  <then>
                    <expression>
                      <assign>
                        <field
                          name="state"
                          name-ref="state.state-machine"/>
                        <int value="{$next-finally-state}"/>
                      </assign>
                    </expression>
                  </then>
                  <else>
                    <expression>
                      <assign>
                        <field
                          name="state"
                          name-ref="state.state-machine"/>
                        <field
                          name="nextState"
                          name-ref="next-state.state-machine"/>
                      </assign>
                    </expression>
                    <expression>
                      <assign>
                        <field
                          name="nextState"
                          name-ref="next-state.state-machine"/>
                        <int value="0"/>
                      </assign>
                    </expression>
                  </else>
                </if>

                <continue/>
              </xsl:when>
              <xsl:otherwise>
                <expression>
                  <assign>
                    <field
                      name="state"
                      name-ref="state.state-machine"/>
                    <field
                      name="nextState"
                      name-ref="next-state.state-machine"/>
                  </assign>
                </expression>
                <expression>
                  <assign>
                    <field
                      name="nextState"
                      name-ref="next-state.state-machine"/>
                    <int value="0"/>
                  </assign>
                </expression>

                <if>
                  <condition>
                    <eq>
                      <field
                        name="state"
                        name-ref="state.state-machine"/>
                      <int value="-1"/>
                    </eq>
                  </condition>
                  <then>
                    <return>
                      <boolean value="false"/>
                    </return>
                  </then>
                </if>

                <continue/>
              </xsl:otherwise>
            </xsl:choose>
          </xsl:when>
          <xsl:otherwise>
            <xsl:sequence select="$goto"/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:when>
      <xsl:otherwise>
        <xsl:sequence select="$goto"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!--
    Generate state transfer for a specified state id.
      $state-id - a state id.
      $yield - a yield marker.
      $next-id - a next state id.
      $statements - a pseudo code block.
      $states - a states set.
  -->
  <xsl:function name="p:generate-goto" as="element()+">
    <xsl:param name="state-id" as="xs:string?"/>
    <xsl:param name="yield" as="xs:boolean"/>
    <xsl:param name="next-id" as="xs:string?"/>
    <xsl:param name="pseudo-code" as="element()"/>
    <xsl:param name="states" as="xs:string+"/>

    <xsl:variable name="target" as="item()*" select="
      p:get-destination($state-id, $yield, $next-id, $pseudo-code, $states)"/>

    <xsl:variable name="target-id" as="xs:string?" select="$target[1]"/>
    <xsl:variable name="target-yield" as="xs:boolean?" select="$target[2]"/>
    <xsl:variable name="target-next-id" as="xs:string?"
      select="$target[3]"/>

    <xsl:choose>
      <xsl:when test="empty($target)">
        <expression>
          <assign>
            <field
              name="state"
              name-ref="state.state-machine"/>
            <int value="-1"/>
          </assign>
        </expression>

        <return>
          <boolean value="false"/>
        </return>
      </xsl:when>
      <xsl:otherwise>
        <xsl:variable name="state" as="xs:integer"
          select="index-of($states, $target-id) - 1"/>

        <expression>
          <assign>
            <field
              name="state"
              name-ref="state.state-machine"/>
            <int value="{$state}"/>
          </assign>
        </expression>

        <xsl:if test="exists($target-next-id)">
          <xsl:variable name="next-target" as="item()*" select="
            p:get-destination
            (
              $target-next-id,
              false(),
              (),
              $pseudo-code,
              $states
            )"/>

          <xsl:variable name="next-target-id" as="xs:string?"
            select="$next-target[1]"/>

          <xsl:variable name="next-state" as="xs:integer" select="
            if (exists($next-target-id)) then
              index-of($states, $next-target-id) - 1
            else
              -1"/>

          <expression>
            <assign>
              <field
                name="nextState"
                name-ref="next-state.state-machine"/>
              <int value="{$next-state}"/>
            </assign>
          </expression>
        </xsl:if>

        <xsl:choose>
          <xsl:when test="$target-yield">
            <return>
              <boolean value="true"/>
            </return>
          </xsl:when>
          <xsl:otherwise>
            <continue/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:function>

  <!--
    For a specified state id returns a closure of destination state id and
    yield status, or empty sequence if this is a last state.
      $state-id - a state id.
      $yield - a yield marker.
      $next-id - a next state id.
      $statements - a pseudo code block.
      $states - a states set.
      Returns a closure of destination state id, yield status, and
        an optional next state id or empty sequence if this is a last state.
  -->
  <xsl:function name="p:get-destination" as="item()*">
    <xsl:param name="state-id" as="xs:string?"/>
    <xsl:param name="yield" as="xs:boolean"/>
    <xsl:param name="next-id" as="xs:string?"/>
    <xsl:param name="pseudo-code" as="element()"/>
    <xsl:param name="states" as="xs:string+"/>

    <xsl:choose>
      <xsl:when test="empty($state-id)">
        <!-- Last state. -->
      </xsl:when>
      <xsl:when test="exists($next-id)">
        <xsl:sequence select="$state-id, $yield, $next-id"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:variable name="target-label" as="element()"
          select="$pseudo-code//snippet-statement[@p:label = $state-id]"/>

        <xsl:variable name="target" as="element()?" select="
          $target-label/
            following-sibling::*[1][self::snippet-statement]
            [
              @p:goto and not(@p:next) and not(@p:finally) or @p:label
            ]"/>

        <xsl:variable name="try" as="element()?" select="
          $target-label/following-sibling::*[1][self::try][@p:try]"/>

        <xsl:variable name="target-yield" as="xs:boolean"
          select="$target/xs:boolean(@yield) = true()"/>

        <xsl:choose>
          <xsl:when test="exists($target/@p:label)">
            <xsl:sequence select="
              p:get-destination
              (
                $target/@p:label,
                $yield,
                $next-id,
                $pseudo-code,
                $states
              )"/>
          </xsl:when>
          <xsl:when test="
            ($target-label/@p:label = $states[last()]) and
            empty($target-label/following-sibling::*)">
            <!-- Last state. -->
          </xsl:when>
          <xsl:when test="exists($target) and not($yield and $target-yield)">
            <xsl:sequence select="
              p:get-destination
              (
                $target/@p:goto,
                $yield or $target-yield,
                $target/@p:next,
                $pseudo-code,
                $states
              )"/>
          </xsl:when>
          <xsl:when test="exists($try)">
            <xsl:sequence select="
              p:get-destination
              (
                $try/@p:try,
                $yield,
                $next-id,
                $pseudo-code,
                $states
              )"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:sequence select="$target-label/xs:string(@p:label)"/>
            <xsl:sequence select="$yield or $target-yield"/>
            <xsl:sequence select="$next-id"/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:function>

  <!--
    Mode "p:generate-case".
    Return point.
  -->
  <!--
  <xsl:template mode="p:generate-case" match="return">
    <expression>
      <assign>
        <field
          name="state"
          name-ref="state.state-machine"/>
        <int value="-1"/>
      </assign>
    </expression>

    <return>
      <boolean value="false"/>
    </return>
  </xsl:template>
  -->

  <!--
    Gets an error handlers for a specified element.
      $element - an element to get error handler for.
      Returns error handlers.
  -->
  <xsl:function name="p:get-error-handlers" as="element()*">
    <xsl:param name="element" as="element()"/>

    <xsl:apply-templates mode="p:error-handlers" select="$element"/>
  </xsl:function>

  <!--
    Mode "p:error-handlers". Default match.
  -->
  <xsl:template mode="p:error-handlers" match="*"/>

  <!--
    Mode "p:error-handlers".
    Gets an error handlers for try/block statement.
  -->
  <xsl:template mode="p:error-handlers" match="try[@p:try]/block/*" as="element()*">
    <xsl:sequence select="../../(catch | finally)"/>
  </xsl:template>

  <!--
    Mode "p:error-handlers".
    Gets an error handlers for try/catch (with finally) statement.
  -->
  <xsl:template mode="p:error-handlers" match="try[@p:try][finally]/catch/block/*"
    priority="2"
    as="element()*">
    <xsl:sequence select="../../../finally"/>
  </xsl:template>

  <!--
    Mode "p:error-handlers".
    Gets an error handlers for try/catch (without finally).
  -->
  <xsl:template mode="p:error-handlers" match="try[@p:try]/catch/block/*"
    as="element()*">
    <xsl:apply-templates mode="#current" select="../../.."/>
  </xsl:template>

  <!--
    Mode "p:error-handlers".
    Gets an error handlers for try/finally statement.
  -->
  <xsl:template mode="p:error-handlers" match="try[@p:try]/finally/*" as="element()*">
    <xsl:apply-templates mode="#current" select="../.."/>
  </xsl:template>

  <!--
    Mode "p:generate-error-handler-call".
    Generates an error call.
  -->
  <xsl:template mode="p:generate-error-handler-call" match="*">
    <xsl:copy>
      <xsl:sequence select="@*"/>
      <xsl:apply-templates mode="#current"/>
    </xsl:copy>
  </xsl:template>

  <!--
    Mode "p:generate-error-handler-call".
    Generates an error call.
  -->
  <xsl:template mode="p:generate-error-handler-call" match="t:error">
    <field
      name="currentError"
      name-ref="currentError.state-machine"/>
  </xsl:template>

</xsl:stylesheet>