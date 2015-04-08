<?xml version="1.0" encoding="utf-8"?>
<!--
  This stylesheet optimizes (removes) dead code.

  $Id$
-->
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:t="http://www.bphx.com/jxom"
  xmlns:p="http://www.bphx.com/jxom/private/optimizer"
  xmlns:j="http://www.bphx.com/java-1.5/2008-02-07"
  xmlns="http://www.bphx.com/java-1.5/2008-02-07"
  xpath-default-namespace="http://www.bphx.com/java-1.5/2008-02-07"
  exclude-result-prefixes="xs t j p">

  <!--
    The reachability rules repeated here, are defined at:
    http://java.sun.com/docs/books/jls/second_edition/html/statements.doc.html#236365

    1. The block that is the body of a constructor, method, instance
    initializer or static initializer is reachable.

    2. An empty block that is not a switch block can complete normally iff
    it is reachable. A nonempty block that is not a switch block can
    complete normally iff the last statement in it can complete normally.
    The first statement in a nonempty block that is not a switch block is
    reachable iff the block is reachable. Every other statement S in a
    nonempty block that is not a switch block is reachable iff the
    statement preceding S can complete normally.

    3. A local class declaration statement can complete normally iff it is
    reachable.

    4. A local variable declaration statement can complete normally iff it is
    reachable.

    5. An empty statement can complete normally iff it is reachable.

    6. A labeled statement can complete normally if at least one of the
    following is true:
      The contained statement can complete normally.
      There is a reachable break statement that exits the labeled statement.
      The contained statement is reachable iff the labeled statement is reachable.

    7. An expression statement can complete normally iff it is reachable.
    The if statement, whether or not it has an else part, is handled in an
    unusual manner.

    8. A switch statement can complete normally iff at least one of the
    following is true:
      The last statement in the switch block can complete normally.
      The switch block is empty or contains only switch labels.
      There is at least one switch label after the last switch
      block statement group.
      The switch block does not contain a default label.
      There is a reachable break statement that exits the switch statement.

    9. A switch block is reachable iff its switch statement is reachable.

    10. A statement in a switch block is reachable iff its switch statement
    is reachable and at least one of the following is true:
      It bears a case or default label.
      There is a statement preceding it in the switch block and that
      preceding statement can complete normally.

    11. A while statement can complete normally iff at least one of the
    following is true:
      The while statement is reachable and the condition expression
      is not a constant expression with value true.
      There is a reachable break statement that exits the while statement.
      The contained statement is reachable iff the while statement is
      reachable and the condition expression is not a constant expression
      whose value is false.

    12. A do statement can complete normally iff at least one of the
    following is true:
      The contained statement can complete normally and the condition
      expression is not a constant expression with value true.
      The do statement contains a reachable continue statement with no label,
      and the do statement is the innermost while, do, or for statement that
      contains that continue statement, and the condition expression is not
      a constant expression with value true.
      The do statement contains a reachable continue statement with a label
      L, and the do statement has label L, and the condition expression is
      not a constant expression with value true.
      There is a reachable break statement that exits the do statement.
      The contained statement is reachable iff the do statement is reachable.

    13. A for statement can complete normally iff at least one of the
    following is true:
      The for statement is reachable, there is a condition expression, and
      the condition expression is not a constant expression with value true.
      There is a reachable break statement that exits the for statement.
      The contained statement is reachable iff the for statement is reachable
      and the condition expression is not a constant expression whose value
      is false.

    14. A break, continue, return, or throw statement cannot complete
    normally.

    15. A synchronized statement can complete normally iff the contained
    statement can complete normally. The contained statement is reachable
    iff the synchronized statement is reachable.

    16. A try statement can complete normally iff both of the following are
    true:
      The try block can complete normally or any catch block can complete
      normally.
      If the try statement has a finally block, then the finally block
      can complete normally.
      The try block is reachable iff the try statement is reachable.

    17. A catch block C is reachable iff both of the following are true:
      Some expression or throw statement in the try block is reachable and
      can throw an exception whose type is assignable to the parameter of
      the catch clause C. (An expression is considered reachable iff the
      innermost statement containing it is reachable.)
      There is no earlier catch block A in the try statement such that
      the type of C's parameter is the same as or a subclass of the type
      of A's parameter.
      If a finally block is present, it is reachable iff the try statement
      is reachable.
        
    ===========
    Additional rules:
    
    13.1. for-update expression is reachable iff contained statement 
      is reachable, and 
      contained statement completes normally, or there is a continue 
      for the for statement.
  -->

  <!--
    Collects unreachable statements for a statement.
      $statement - a statement to collect unreachable statements for.
      Returns an optional sequence of unreachable statements.
  -->
  <xsl:template name="t:collect-unreachable-statements" as="element()*">
    <xsl:param name="statement" as="element()"/>

    <xsl:variable name="closure" as="item()+">
      <xsl:apply-templates mode="p:collect-unreachable" select="$statement"/>
    </xsl:variable>

    <xsl:variable name="unreachable" as="element()*"
      select="subsequence($closure, 2)"/>

    <xsl:sequence select="$unreachable"/>
  </xsl:template>

  <!--
    Optimizes unreachable code.
      $scope - an scope element to check.
      $remove - true to remove unreachable code, and false to comment it out.
      $comment - an optional comment text to put near unreachable code.
      Returns optimized scope element.
  -->
  <xsl:function name="t:optimize-unreachable-code" as="element()">
    <xsl:param name="scope" as="element()"/>
    <xsl:param name="remove" as="xs:boolean"/>
    <xsl:param name="comment" as="xs:string?"/>

    <xsl:variable name="unreachable-statements" as="element()*">
      <xsl:call-template name="t:collect-unreachable-statements">
        <xsl:with-param name="statement" select="$scope"/>
      </xsl:call-template>
    </xsl:variable>

    <xsl:choose>
      <xsl:when test="empty($unreachable-statements)">
        <xsl:sequence select="$scope"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:apply-templates mode="p:optimize-unreachable-code" select="$scope">
          <xsl:with-param name="unreachable-statements" tunnel="yes"
            select="$unreachable-statements"/>
          <xsl:with-param name="remove" tunnel="yes" select="$remove"/>
          <xsl:with-param name="comment" tunnel="yes" select="$comment"/>
        </xsl:apply-templates>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:function>

  <!--
    Collects unreachable statements.
    Rule 1, 3, 5, 7.
      Returns a closure:
        (
          $completes-normally as xs:boolean,
          $unreacable-statements as element()*
        ).
  -->
  <xsl:template mode="p:collect-unreachable" match="*" as="item()+">
    <xsl:sequence select="true()"/>

    <xsl:for-each select="t:get-java-element(.)">
      <xsl:variable name="closure" as="item()+">
        <xsl:apply-templates mode="#current" select="."/>
      </xsl:variable>

      <xsl:variable name="unreachable" as="element()*"
        select="subsequence($closure, 2)"/>

      <xsl:sequence select="$unreachable"/>
    </xsl:for-each>
  </xsl:template>

  <!--
    Collects unreachable statements.
    Rule 4.
      Returns a closure:
        (
          $completes-normally as xs:boolean,
          $unreacable-statements as element()*
        ).
  -->
  <xsl:template mode="p:collect-unreachable" match="var-decl" as="item()+">
    <xsl:sequence select="true()"/>

    <xsl:for-each select="initialize/t:get-java-element(.)">
      <xsl:variable name="closure" as="item()+">
        <xsl:apply-templates mode="#current" select="."/>
      </xsl:variable>

      <xsl:variable name="unreachable" as="element()*"
        select="subsequence($closure, 2)"/>

      <xsl:sequence select="$unreachable"/>
    </xsl:for-each>
  </xsl:template>

  <!--
    Collects unreachable statements.
    Rule 2.
      Returns a closure:
        (
          $completes-normally as xs:boolean,
          $unreacable-statements as element()*
        ).
  -->
  <xsl:template
    mode="p:collect-unreachable"
    match="scope | block | then | else | finally"
    as="item()+">

    <xsl:variable name="statements" as="element()*"
      select="p:get-child-statements(.)"/>

    <xsl:call-template name="p:collect-unreachable">
      <xsl:with-param name="statements" select="$statements"/>
      <xsl:with-param name="index" select="1"/>
    </xsl:call-template>
  </xsl:template>

  <!--
    Implements Rule 2.
      $statements - block statements.
      $index - current index.
      $unreachable - collected unreachable statemetns.
      Returns a closure:
        (
          $completes-normally as xs:boolean,
          $unreacable-statements as element()*
        ).
  -->
  <xsl:template name="p:collect-unreachable" as="item()+">
    <xsl:param name="statements" as="element()*"/>
    <xsl:param name="index" as="xs:integer"/>
    <xsl:param name="unreachable" as="element()*"/>

    <xsl:variable name="statement" as="element()?"
      select="$statements[$index]"/>

    <xsl:choose>
      <xsl:when test="empty($statement)">
        <xsl:sequence select="true()"/>
        <xsl:sequence select="$unreachable"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:variable name="closure" as="item()+">
          <xsl:apply-templates
            mode="p:collect-unreachable"
            select="$statement"/>
        </xsl:variable>

        <xsl:variable name="statement-completes-normally" as="xs:boolean"
          select="$closure[1]"/>
        <xsl:variable name="statement-unreachable" as="element()*"
          select="subsequence($closure, 2)"/>

        <xsl:choose>
          <xsl:when test="not($statement-completes-normally)">
            <xsl:sequence select="false()"/>
            <xsl:sequence select="$unreachable"/>
            <xsl:sequence select="$statement-unreachable"/>

            <xsl:sequence select="
              subsequence($statements, $index + 1)/
              (
                .,
                p:get-descendant-statements(.)
              )"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:call-template name="p:collect-unreachable">
              <xsl:with-param name="statements" select="$statements"/>
              <xsl:with-param name="index" select="$index + 1"/>
              <xsl:with-param name="unreachable"
                select="$unreachable, $statement-unreachable"/>
            </xsl:call-template>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!--
    Collects unreachable statements.
    Rule 6.
      Returns a closure:
        (
          $completes-normally as xs:boolean,
          $unreacable-statements as element()*
        ).
  -->
  <xsl:template
    mode="p:collect-unreachable"
    priority="2"
    match="*[@label]"
    as="item()+">

    <xsl:variable name="label" as="xs:string" select="@label"/>
    <xsl:variable name="label-id" as="xs:string?" select="@label-id"/>

    <xsl:variable name="breaks" as="element()*" select="
      p:get-descendant-statements(.)[self::break]
      [
        if (exists($label-id)) then
          @label-ref = $label-id
        else
          (@destination-label = $label) and empty(@label-ref)
      ]"/>

    <xsl:variable name="closure" as="item()+">
      <xsl:next-match/>
    </xsl:variable>

    <xsl:variable name="completes-normally" as="xs:boolean"
      select="$closure[1]"/>
    <xsl:variable name="unreachable" as="element()*"
      select="subsequence($closure, 2)"/>

    <xsl:choose>
      <xsl:when test="$completes-normally">
        <xsl:sequence select="$closure"/>
      </xsl:when>
      <xsl:when test="exists($breaks except $unreachable)">
        <xsl:sequence select="true()"/>
        <xsl:sequence select="$unreachable"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:sequence select="false()"/>
        <xsl:message select="p:get-descendant-statements(.)"/>
        <xsl:sequence select="$unreachable"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!--
    Collects unreachable statements.
    Rule 7.
      Returns a closure:
        (
          $completes-normally as xs:boolean,
          $unreacable-statements as element()*
        ).
  -->
  <xsl:template
    mode="p:collect-unreachable"
    match="if"
    as="item()+">

    <xsl:variable name="condition" as="element()" select="condition"/>
    <xsl:variable name="then" as="element()" select="then"/>
    <xsl:variable name="else" as="element()?" select="else"/>

    <xsl:variable name="condition-closure" as="item()+">
      <xsl:apply-templates mode="#current" select="$condition"/>
    </xsl:variable>

    <xsl:variable name="condition-unreachable" as="element()*"
      select="subsequence($condition-closure, 2)"/>

    <xsl:variable name="then-closure" as="item()+">
      <xsl:apply-templates mode="#current" select="$then"/>
    </xsl:variable>

    <xsl:variable name="then-completes-normally" as="xs:boolean"
      select="$then-closure[1]"/>
    <xsl:variable name="then-unreachable" as="element()*"
      select="subsequence($then-closure, 2)"/>

    <xsl:variable name="else-closure" as="item()*">
      <xsl:apply-templates mode="#current" select="$else"/>
    </xsl:variable>

    <xsl:variable name="else-completes-normally" as="xs:boolean?"
      select="$else-closure[1]"/>
    <xsl:variable name="else-unreachable" as="element()*"
      select="subsequence($else-closure, 2)"/>

    <xsl:sequence select="
      $then-completes-normally or not($else-completes-normally = false())"/>
    <xsl:sequence
      select="$condition-unreachable, $then-unreachable, $else-unreachable"/>
  </xsl:template>

  <!--
    Collects unreachable statements.
    Rule 8, 9, 10.
      Returns a closure:
        (
          $completes-normally as xs:boolean,
          $unreacable-statements as element()*
        ).
  -->
  <xsl:template
    mode="p:collect-unreachable"
    match="switch"
    as="item()+">

    <xsl:variable name="statement" as="element()" select="."/>
    <xsl:variable name="test" as="element()" select="test"/>
    <xsl:variable name="case" as="element()*" select="case"/>

    <xsl:variable name="test-closure" as="item()+">
      <xsl:apply-templates mode="#current" select="$test"/>
    </xsl:variable>

    <xsl:variable name="test-unreachable" as="element()*"
      select="subsequence($test-closure, 2)"/>

    <xsl:variable name="case-closure" as="item()*">
      <xsl:apply-templates mode="#current" select="$case/block"/>
    </xsl:variable>

    <xsl:variable name="case-completes-normally" as="xs:boolean*"
      select="$case-closure[. instance of xs:boolean]"/>
    <xsl:variable name="case-unreachable" as="element()*"
      select="$case-closure[not(. instance of xs:boolean)]"/>

    <xsl:variable name="breaks" as="element()*" select="
      $case/block/p:get-descendant-statements(.)[self::break]
      [
        empty(@destination-label) and
        p:is-break-of($statement, .)
      ]"/>

    <xsl:sequence select="
      empty($case) or
      empty($case[empty(value) and empty(@enum)]) or
      $case-completes-normally[last()] or
      exists($breaks except $case-unreachable)"/>

    <xsl:sequence select="$test-unreachable"/>
    <xsl:sequence select="$case-unreachable"/>
  </xsl:template>

  <!--
    Collects unreachable statements.
    Rule 11.
      Returns a closure:
        (
          $completes-normally as xs:boolean,
          $unreacable-statements as element()*
        ).
  -->
  <xsl:template
    mode="p:collect-unreachable"
    match="while"
    as="item()+">

    <xsl:variable name="statement" as="element()" select="."/>
    <xsl:variable name="condition" as="element()"
      select="t:get-java-element(condition)"/>
    <xsl:variable name="block" as="element()" select="block"/>

    <xsl:variable name="condition-closure" as="item()+">
      <xsl:apply-templates mode="#current" select="$condition"/>
    </xsl:variable>

    <xsl:variable name="condition-unreachable" as="element()*"
      select="subsequence($condition-closure, 2)"/>

    <xsl:variable name="block-closure" as="item()+">
      <xsl:apply-templates mode="#current" select="$block"/>
    </xsl:variable>

    <xsl:variable name="block-completes-normally" as="xs:boolean"
      select="$block-closure[1]"/>
    <xsl:variable name="block-unreachable" as="element()*"
      select="subsequence($block-closure, 2)"/>

    <xsl:variable name="breaks" as="element()*" select="
      p:get-descendant-statements($block)[self::break]
      [
        empty(@destination-label) and
        p:is-break-of($statement, .)
      ]"/>

    <xsl:choose>
      <xsl:when test="t:is-boolean-false-expression($condition)">
        <xsl:sequence select="true()"/>
        <xsl:sequence select="., p:get-descendant-statements(.)"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:sequence select="
          not(t:is-boolean-true-expression($condition)) or
          exists($breaks except $block-unreachable)"/>

        <xsl:sequence select="$condition-unreachable"/>
        <xsl:sequence select="$block-unreachable"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!--
    Collects unreachable statements.
    Rule 12.
      Returns a closure:
        (
          $completes-normally as xs:boolean,
          $unreacable-statements as element()*
        ).
  -->
  <xsl:template
    mode="p:collect-unreachable"
    match="do-while"
    as="item()+">

    <xsl:variable name="statement" as="element()" select="."/>
    <xsl:variable name="condition" as="element()"
      select="t:get-java-element(condition)"/>
    <xsl:variable name="block" as="element()" select="block"/>

    <xsl:variable name="condition-closure" as="item()+">
      <xsl:apply-templates mode="#current" select="$condition"/>
    </xsl:variable>

    <xsl:variable name="condition-unreachable" as="element()*"
      select="subsequence($condition-closure, 2)"/>

    <xsl:variable name="block-closure" as="item()+">
      <xsl:apply-templates mode="#current" select="$block"/>
    </xsl:variable>

    <xsl:variable name="block-completes-normally" as="xs:boolean"
      select="$block-closure[1]"/>
    <xsl:variable name="block-unreachable" as="element()*"
      select="subsequence($block-closure, 2)"/>

    <xsl:variable name="label" as="xs:string?" select="@label"/>
    <xsl:variable name="label-id" as="xs:string?" select="@label-id"/>

    <xsl:variable name="descendant-statements" as="element()*"
      select="p:get-descendant-statements($block)"/>
    
    <xsl:variable name="breaks" as="element()*" select="
      $descendant-statements[self::break]
      [
        empty(@destination-label) and
        p:is-break-of($statement, .)
      ]"/>

    <xsl:variable name="continue" as="element()*" select="
      $descendant-statements[self::continue]
      [
        (
          if (exists($label-id)) then
            @label-ref = $label-id
          else
            (@destination-label = $label) and empty(@label-ref)
        )[exists($label)] or
        p:is-break-of($statement, .)
      ]"/>

    <xsl:variable name="is-true-condition" as="xs:boolean"
      select="t:is-boolean-true-expression($condition)"/>

    <xsl:sequence select="
      ($block-completes-normally and not($is-true-condition)) or
      (
        exists($continue except $block-unreachable) and
        not($is-true-condition)
      ) or
      exists($breaks except $block-unreachable)"/>

    <xsl:sequence select="$condition-unreachable"/>
    <xsl:sequence select="$block-unreachable"/>
  </xsl:template>

  <!--
    Collects unreachable statements.
    Rule 13.
      Returns a closure:
        (
          $completes-normally as xs:boolean,
          $unreacable-statements as element()*
        ).
  -->
  <xsl:template
    mode="p:collect-unreachable"
    match="for"
    as="item()+">

    <xsl:variable name="statement" as="element()" select="."/>
    <xsl:variable name="initialize" as="element()*"
      select="var-decl | initialize"/>
    <xsl:variable name="condition" as="element()?"
      select="condition/t:get-java-element(.)"/>
    <xsl:variable name="update" as="element()*" select="update"/>
    <xsl:variable name="block" as="element()" select="block"/>

    <xsl:variable name="initialize-closure" as="item()*">
      <xsl:apply-templates mode="#current" select="$initialize"/>
    </xsl:variable>

    <xsl:variable name="initialize-unreachable" as="element()*"
      select="$initialize-closure[. instance of element()]"/>

    <xsl:variable name="condition-closure" as="item()*">
      <xsl:apply-templates mode="#current" select="$condition"/>
    </xsl:variable>

    <xsl:variable name="condition-unreachable" as="element()*"
      select="subsequence($condition-closure, 2)"/>

    <xsl:variable name="update-closure" as="item()*">
      <xsl:apply-templates mode="#current" select="$update"/>
    </xsl:variable>

    <xsl:variable name="update-unreachable" as="element()*"
      select="$update-closure[. instance of element()]"/>

    <xsl:variable name="block-closure" as="item()+">
      <xsl:apply-templates mode="#current" select="$block"/>
    </xsl:variable>

    <xsl:variable name="block-completes-normally" as="xs:boolean"
      select="$block-closure[1]"/>
    <xsl:variable name="block-unreachable" as="element()*"
      select="subsequence($block-closure, 2)"/>

    <xsl:variable name="label" as="xs:string?" select="@label"/>
    <xsl:variable name="label-id" as="xs:string?" select="@label-id"/>

    <xsl:variable name="descendant-statements" as="element()*"
      select="p:get-descendant-statements($block)"/>
    
    <xsl:variable name="breaks" as="element()*" select="
      $descendant-statements[self::break]
      [
        empty(@destination-label) and
        p:is-break-of($statement, .)
      ]"/>

    <xsl:variable name="continue" as="element()*" select="
      $descendant-statements[self::continue]
      [
        (
          if (exists($label-id)) then
            @label-ref = $label-id
          else
            (@destination-label = $label) and empty(@label-ref)
        )[exists($label)] or
        p:is-break-of($statement, .)
      ]"/>

    <xsl:sequence select="
      (exists($condition) and not(t:is-boolean-true-expression($condition))) or
      exists($breaks except $block-unreachable)"/>

    <xsl:sequence select="$initialize-unreachable"/>
    <xsl:sequence select="$condition-unreachable"/>
    
    <xsl:variable name="false-condition" as="xs:boolean" 
      select="($condition/t:is-boolean-false-expression(.), true())[1]"/>
    
    <xsl:choose>
      <xsl:when test="
        $false-condition or
        (
          not($block-completes-normally) and 
          not($continue except $block-unreachable)
        )">
        <xsl:sequence select="$update"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:sequence select="$update-unreachable"/>
      </xsl:otherwise>
    </xsl:choose>

    <xsl:choose>
      <xsl:when test="$false-condition">
        <xsl:sequence select="p:get-descendant-statements($block)"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:sequence select="$block-unreachable"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!--
    Collects unreachable statements.
    Rule 14.
      Returns a closure:
        (
          $completes-normally as xs:boolean,
          $unreacable-statements as element()*
        ).
  -->
  <xsl:template mode="p:collect-unreachable" match="break | continue"
    as="item()+">
    <xsl:sequence select="false()"/>
  </xsl:template>

  <!--
    Collects unreachable statements.
    Rule 14.
      Returns a closure:
        (
          $completes-normally as xs:boolean,
          $unreacable-statements as element()*
        ).
  -->
  <xsl:template mode="p:collect-unreachable" match="return | throw"
    as="item()+">
    <xsl:sequence select="false()"/>

    <xsl:for-each select="t:get-java-element(.)">
      <xsl:variable name="closure" as="item()+">
        <xsl:apply-templates mode="#current" select="."/>
      </xsl:variable>

      <xsl:variable name="unreachable" as="element()*"
        select="subsequence($closure, 2)"/>

      <xsl:sequence select="$unreachable"/>
    </xsl:for-each>
  </xsl:template>

  <!--
    Collects unreachable statements.
    Rule 15.
      Returns a closure:
        (
          $completes-normally as xs:boolean,
          $unreacable-statements as element()*
        ).
  -->
  <xsl:template mode="p:collect-unreachable" match="synchronized" as="item()+">
    <xsl:variable name="monitor" as="element()" select="monitor"/>
    <xsl:variable name="block" as="element()" select="block"/>

    <xsl:variable name="monitor-closure" as="item()+">
      <xsl:apply-templates mode="#current" select="$monitor"/>
    </xsl:variable>

    <xsl:variable name="monitor-unreachable" as="element()*"
      select="subsequence($monitor-closure, 2)"/>

    <xsl:variable name="block-closure" as="item()+">
      <xsl:apply-templates mode="#current" select="$block"/>
    </xsl:variable>

    <xsl:variable name="block-completes-normally" as="xs:boolean"
      select="$block-closure[1]"/>
    <xsl:variable name="block-unreachable" as="element()*"
      select="subsequence($block-closure, 2)"/>

    <xsl:sequence select="$block-completes-normally"/>
    <xsl:sequence select="$monitor-unreachable"/>
    <xsl:sequence select="$block-unreachable"/>
  </xsl:template>

  <!--
    Collects unreachable statements.
    Rule 16, 17.
      Returns a closure:
        (
          $completes-normally as xs:boolean,
          $unreacable-statements as element()*
        ).
  -->
  <xsl:template mode="p:collect-unreachable" match="try" as="item()+">
    <xsl:variable name="block" as="element()" select="block"/>
    <xsl:variable name="catch" as="element()*" select="catch"/>
    <xsl:variable name="finally" as="element()?" select="finally"/>

    <xsl:variable name="block-closure" as="item()+">
      <xsl:apply-templates mode="#current" select="$block"/>
    </xsl:variable>

    <xsl:variable name="block-completes-normally" as="xs:boolean"
      select="$block-closure[1]"/>
    <xsl:variable name="block-unreachable" as="element()*"
      select="subsequence($block-closure, 2)"/>

    <xsl:variable name="catch-closure" as="item()*">
      <xsl:apply-templates mode="#current" select="$catch/block"/>
    </xsl:variable>

    <xsl:variable name="catch-completes-normally" as="xs:boolean*"
      select="$catch-closure[. instance of xs:boolean]"/>
    <xsl:variable name="catch-unreachable" as="element()*"
      select="$catch-closure[not(. instance of xs:boolean)]"/>

    <xsl:variable name="finally-closure" as="item()*">
      <xsl:apply-templates mode="#current" select="$finally"/>
    </xsl:variable>

    <xsl:variable name="finally-completes-normally" as="xs:boolean?"
      select="$finally-closure[1]"/>
    <xsl:variable name="finally-unreachable" as="element()*"
      select="subsequence($finally-closure, 2)"/>

    <xsl:variable name="block-statements" as="element()*"
      select="p:get-descendant-statements($block)"/>

    <xsl:choose>
      <xsl:when test="
        empty(p:get-child-statements($block)) and
        empty($finally/t:get-java-element(.))">
        <xsl:sequence select="true()"/>
        <xsl:sequence select="
          ., 
          $block-statements, 
          $catch/p:get-descendant-statements(.)"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:sequence select="
          (
            $block-completes-normally or
            ($catch-completes-normally = true())
          ) and
          not($finally-completes-normally = false())"/>

        <xsl:sequence select="$block-unreachable"/>
        <xsl:sequence select="$catch-unreachable"/>
        <xsl:sequence select="$finally-unreachable"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!--
    Gets children statements for a statement.
      $param - statememt to get children statements for.
      Returns children statements.
  -->
  <xsl:function name="p:get-child-statements" as="element()*">
    <xsl:param name="statement" as="element()"/>

    <xsl:sequence select="
      t:get-java-element($statement)
      [
        self::var-decl or
        self::scope or
        self::snippet-statement or
        self::block or
        self::statement or
        self::assert or
        self::if or
        self::for or
        self::for-each or
        self::while or
        self::do-while or
        self::try or
        self::switch or
        self::synchronized or
        self::return or
        self::throw or
        self::break or
        self::continue or
        self::expression or

        self::snippet-decl or
        self::class or
        self::enum or
        self::interface or
        self::annotation-decl or

        self::then[parent::if] or
        self::else[parent::if] or
        self::catch[parent::try] or
        self::finally[parent::try] or
        self::case[parent::switch]
      ]"/>
  </xsl:function>

  <!--
    Gets descendant statements for a statement.
      $param - statememt to get descendant statements for.
      Returns descendant statements.
  -->
  <xsl:function name="p:get-descendant-statements" as="element()*">
    <xsl:param name="statement" as="element()"/>

    <xsl:sequence select="
      p:get-child-statements($statement)/
      (
        .,
        p:get-descendant-statements(.)
      )"/>
  </xsl:function>

  <!--
    Tests if a specified break is closest inner statement of
    a specified statement.
      $statement - a scope statement.
      $break - a break statement.
      Returns true if a specified break is closest inner statement of
      a specified statement.
  -->
  <xsl:function name="p:is-break-of" as="xs:boolean">
    <xsl:param name="statement" as="element()"/>
    <xsl:param name="break" as="element()"/>

    <xsl:sequence select="
      $break/ancestor::*
      [
        self::comment,
        self::meta,
        self::switch,
        self::for,
        self::for-each,
        self::while,
        self::do-while
      ][1] is $statement"/>
  </xsl:function>

  <!--
    Mode "p:optimize-unreachable-code".
    Optimizes unreachable code.
  -->
  <xsl:template mode="p:optimize-unreachable-code"
    match="@* | text() | statement">
    <xsl:sequence select="."/>
  </xsl:template>

  <!--
    Mode "p:optimize-unreachable-code".
    Optimizes unreachable code.
      $unreachable-statements - a list of unreachable statements.
      $remove - true to remove unreachable code, and false to comment it out.
      $comment - an optional comment text to put near unreachable code.
      Returns optimized element.
  -->
  <xsl:template mode="p:optimize-unreachable-code" match="*">
    <xsl:param name="unreachable-statements" tunnel="yes" as="element()+"/>
    <xsl:param name="remove" tunnel="yes" as="xs:boolean"/>
    <xsl:param name="comment" tunnel="yes" as="xs:string?"/>

    <xsl:variable name="statement" as="element()" select="."/>

    <xsl:choose>
      <xsl:when test="exists(. except $unreachable-statements)">
        <xsl:copy>
          <xsl:sequence select="@*"/>
          <xsl:apply-templates mode="p:optimize-unreachable-code"
            select="node()"/>
        </xsl:copy>
      </xsl:when>
      <xsl:when test="self::statement">
        <xsl:sequence select="."/>
      </xsl:when>
      <xsl:when test="self::scope">
        <xsl:copy>
          <xsl:sequence select="@*"/>
          <xsl:apply-templates mode="p:optimize-unreachable-code"
            select="node()"/>
        </xsl:copy>
      </xsl:when>
      <xsl:when test="self::update/parent::for">
        <!-- Remove unreachable for update. -->
      </xsl:when>
      <xsl:when test="not($remove)">
        <xsl:variable name="reported" as="xs:boolean" select="
          exists
          (
            (preceding-sibling::*[1] | parent::*) intersect
              $unreachable-statements
          )"/>

        <xsl:choose>
          <xsl:when test="empty($comment) and not($reported)">
            <scope>
              <comment>Error: the following is unreachable code.</comment>
              <meta>
                <bookmark>
                  <error message="Unreachable code."/>
                </bookmark>
              </meta>
            </scope>

            <xsl:sequence select="."/>
          </xsl:when>
          <xsl:when test="empty((self::break, self::continue, self::return))">
            <scope>
              <comment>
                <xsl:if test="$comment and not($reported)">
                  <para>
                    <xsl:sequence select="$comment"/>
                  </para>
                </xsl:if>
                <scope>
                  <xsl:if test="not($reported)">
                    <meta>
                      <bookmark>
                        <warning message="Unreachable code."/>
                      </bookmark>
                    </meta>
                  </xsl:if>

                  <xsl:sequence select="."/>
                </scope>
              </comment>
            </scope>
          </xsl:when>
        </xsl:choose>
      </xsl:when>
    </xsl:choose>
  </xsl:template>

</xsl:stylesheet>
