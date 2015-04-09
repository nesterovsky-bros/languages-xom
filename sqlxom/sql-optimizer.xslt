<?xml version="1.0" encoding="utf-8"?>
<!--
  This stylesheet generates sql statement tree from the program tree elements
-->
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:t="http://www.bphx.com/public/sql"
  xmlns:p="http://www.bphx.com/private/sql-optimizer"
  xmlns:sql="http://www.bphx.com/basic-sql/2008-12-11"
  exclude-result-prefixes="t p xs">

  <!--
    Combines field joins.
      $joins - a sequence of joins to combine.
      Returns "and" combined field joins
  -->
  <xsl:function name="t:combine-joins" as="element()?">
    <xsl:param name="joins" as="element()*"/>

    <xsl:sequence
      select="p:create-operator(xs:QName('sql:and'), $joins, 1, ())"/>
  </xsl:function>

  <!--
    For a given operator returns all its arguments.
      $name - an operator name.
      $operator - an operator element.
  -->
  <xsl:function name="t:get-operator-arguments" as="element()+">
    <xsl:param name="name" as="xs:QName"/>
    <xsl:param name="operator" as="element()"/>

    <xsl:variable name="arguments" as="element()+" select="$operator/*"/>

    <xsl:sequence select="
      for $argument in $arguments return
        if (node-name($argument) eq $name) then
          t:get-operator-arguments($name, $argument)
        else
          $argument"/>
  </xsl:function>

  <!--
    Combines a set of arguments into an operator.
      $name - an operator name.
      $arguments - a sequence of joins to combine.
      Returns an operator element, with arguments provided with $arguments.
  -->
  <xsl:function name="t:create-operator" as="element()">
    <xsl:param name="name" as="xs:QName"/>
    <xsl:param name="arguments" as="element()+"/>

    <xsl:sequence select="p:create-operator($name, $arguments, 1, ())"/>
  </xsl:function>

  <!--
    Collects odds tables and join expressions.

    Common optimization.
    Sometimes a join is used to access foreign keys only.
    In this case we can eliminate join altogether.
      $columns - select columns.
      $tables - tables in scope.
      $expression - expressions to optimize.
      Returns a set of odd elements, which includes odd tables, and
        odd join sql:eq operators.
  -->
  <xsl:function name="t:collect-odd-elements" as="element()*">
    <xsl:param name="columns" as="element()*"/>
    <xsl:param name="tables" as="element()*"/>
    <xsl:param name="expression" as="element()*"/>

    <xsl:variable name="joins" as="element()*" select="
      for $item in $expression return
        $item/descendant-or-self::sql:eq[xs:boolean(@join)]
        [
          t:get-sql-element(.)[1][self::sql:field]
        ]
        [
          every $operator in ancestor::*[not($item >> .)] satisfies
            $operator[self::sql:and or self::sql:parens]
        ]"/>

    <xsl:variable name="join-tables-list" as="element()*">
      <xsl:if test="
        every $item in $columns/self::sql:column satisfies
          $item[not(xs:boolean(@wildcard))]">

        <xsl:variable name="aliases" as="xs:string*" select="
          distinct-values
          (
            $columns/self::sql:column//sql:field
            [
              every $field in $joins/sql:field[1] satisfies
                (@field-id != $field/@field-id) or
                (string(sql:source/@alias) != $field/string(sql:source/@alias))
            ]/string(sql:source/@alias)
          )"/>

        <xsl:sequence select="$tables[not(string(@alias) = $aliases)]"/>
      </xsl:if>
    </xsl:variable>

    <!--
      We should leave at least one table if we see that
      all tables can be eliminated.

      Consider an example:
        select id from table where id = ?

      If we knew that such row exists then we could
      eliminate select altogether. Thus, this select
      verifies a row existence.
    -->
    <xsl:variable name="full-optimization" as="xs:boolean" select="
      exists($columns) and (count($join-tables-list) = count($tables))"/>

    <xsl:variable name="join-tables" as="element()*" select="
      if ($full-optimization) then
        subsequence($tables, 2)
      else
        $join-tables-list"/>

    <xsl:variable name="fields" as="element()*"
      select="$expression//descendant-or-self::sql:field"/>

    <!-- Issue duplicate comparisions. -->
    <xsl:for-each-group select="$joins"
      group-by="string(sql:field[1]/@field-id)">
      <xsl:for-each-group select="current-group()"
        group-by="string(sql:field[1]/sql:source/@alias)">
        <xsl:for-each-group select="current-group()"
          group-by="string(sql:field[2]/@field-id)">
          <xsl:for-each-group select="current-group()"
            group-by="string(sql:field[2]/sql:source/@alias)">
            <xsl:sequence select="subsequence(current-group(), 2)"/>
          </xsl:for-each-group>
        </xsl:for-each-group>
      </xsl:for-each-group>
    </xsl:for-each-group>

    <!-- Issue odd tables and fields. -->
    <xsl:if test="exists($fields)">
      <xsl:for-each select="$join-tables">
        <xsl:variable name="table" as="element()" select="."/>
        <xsl:variable name="table-fields" as="element()*"
          select="$fields[string(sql:source/@alias) = $table/string(@alias)]"/>

        <xsl:variable name="join-fields" as="element()*">
          <xsl:for-each-group 
            select="
              $joins/
                sql:field[1][string(sql:source/@alias) = $table/string(@alias)]"
            group-by="@field-id">
            <xsl:sequence select="current-group()[1]"/>
          </xsl:for-each-group>
        </xsl:variable>

        <xsl:if test="
          exists($table-fields) and
          (
            every $field in $table-fields satisfies
              $field/@field-id = $join-fields/@field-id
          )">
          <xsl:sequence select="$table"/>
          <xsl:sequence select="$join-fields/.."/>
        </xsl:if>
      </xsl:for-each>
    </xsl:if>
  </xsl:function>

  <!--
    Removes odd joins from expression.
      $expression - expressions to optimize.
      $odds - odd joins.
      Returns optimized expressions.
  -->
  <xsl:function name="t:optimize-joins" as="element()*">
    <xsl:param name="expression" as="element()*"/>
    <xsl:param name="odds" as="element()*"/>

    <xsl:choose>
      <xsl:when test="empty($odds)">
        <xsl:sequence select="$expression"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:variable name="count" as="xs:integer" select="count($odds)"/>
        <xsl:variable name="index" as="xs:integer" select="
          (
            (
              for
                $i in 1 to $count,
                $item in $odds[$i][self::sql:table]
              return
                $i
            ),
            $count + 1
          )[1]"/>

        <xsl:variable name="duplicate-joins" as="element()*"
          select="subsequence($odds, 1, $index - 1)"/>
        <xsl:variable name="odd-joins" as="element()*"
          select="subsequence($odds, $index + 1)[self::sql:eq]"/>

        <xsl:sequence select="
          p:optimize-joins($expression, $odd-joins, $duplicate-joins)"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:function>

  <!--
    Merges duplicate columns in column list.
      $columns-closure - a closure of sql:column, and sql:into elements.
      Returns optimized column list.
  -->
  <xsl:function name="t:optimize-duplicate-columns" as="element()*">
    <xsl:param name="columns-closure" as="element()*"/>

    <xsl:variable name="columns" as="element()*"
      select="$columns-closure/self::sql:column"/>
    <xsl:variable name="host-expressions" as="element()*"
      select="$columns-closure[self::sql:into]/sql:host-expression"/>

    <xsl:variable name="duplicate-columns" as="element()*">
      <xsl:for-each select="$columns">
        <xsl:variable name="column" as="element()" select="."/>
        <xsl:variable name="prev" as="element()*"
          select="subsequence($columns, 1, position() - 1)"/>

        <xsl:sequence select="
          $column
          [
            sql:field
            [
              for
                $field-id in xs:string(@field-id),
                $alias in string(sql:source/@alias)
              return
                $prev/sql:field[@field-id = $field-id]
                [
                  string(sql:source/@alias) = $alias
                ]
            ] or
            ($prev/deep-equal($column, .) = true())
          ]"/>
      </xsl:for-each>
    </xsl:variable>

    <xsl:choose>
      <xsl:when test="empty($duplicate-columns)">
        <xsl:sequence select="$columns-closure"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:sequence select="$columns except $duplicate-columns"/>

        <sql:into>          
          <xsl:for-each select="$columns">
            <xsl:if test=". except $duplicate-columns">
              <xsl:variable name="index" as="xs:integer" select="position()"/>                            
              <xsl:variable name="column" as="element()" select="."/>

              <xsl:variable name="duplicate-host-expressions" as="element()*"
                select="
                  for 
                    $i in $index + 1 to count($columns),
                    $next in $columns[$i]
                  return
                    $host-expressions[$i]
                    [
                      $column/sql:field
                      [
                        for
                          $field-id in xs:string(@field-id),
                          $alias in string(sql:source/@alias)
                        return
                          $next/sql:field[@field-id = $field-id]
                          [
                            string(sql:source/@alias) = $alias
                          ]
                      ] or
                      deep-equal($column, $next)
                    ]"/>

              <xsl:choose>
                <xsl:when test="$duplicate-host-expressions">
                  <!-- Merge duplicates. -->
                  <sql:host-expression>
                    <xsl:sequence select="$host-expressions[$index]/*"/>
                    <xsl:sequence select="$duplicate-host-expressions/*"/>
                  </sql:host-expression>
                </xsl:when>
                <xsl:otherwise>
                  <xsl:sequence select="$host-expressions[$index]"/>
                </xsl:otherwise>
              </xsl:choose>
            </xsl:if>
          </xsl:for-each>
        </sql:into>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:function>

  <!-- Designates an absance of expression. -->
  <xsl:variable name="t:null-expression" as="element()">
    <p:null/>
  </xsl:variable>

  <!--
    Constructs sql joins for a set of sources and "where" condition.
      $sources - sources to consider to join.
      $condition - a "where" condition.
      Returns a closure of reminder condition and joined sources:
      ($condition as element(), $joined-source as element()+).
      If reminder condition is empty then $t:null-expression is returned.
  -->
  <xsl:function name="t:create-sql-joins" as="element()+">
    <xsl:param name="sources" as="element()*"/>
    <xsl:param name="condition" as="element()"/>

    <xsl:variable name="join-candidates" as="element()*" select="
      $condition/descendant-or-self::sql:*
      [
        not(self::sql:and or self::sql:parens)
      ]
      [
        every $operator in ancestor::*[not($condition >> .)] satisfies
          exists($operator[self::sql:and or self::sql:parens])
      ]"/>

    <xsl:choose>
      <xsl:when test="exists($join-candidates)">
        <xsl:sequence
          select="p:create-sql-joins($sources, $join-candidates)"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:sequence select="$condition, $sources"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:function>

  <!--
    Reduces aliases in the sql statements.
      $statements - statements to process.
  -->
  <xsl:function name="t:reduce-aliases" as="element()*">
    <xsl:param name="statements" as="element()*"/>

    <xsl:choose>
      <xsl:when test="
        count
        (
          distinct-values
          (
            $statements//
              (sql:table/string(@alias), sql:field/string(sql:source/@alias))
          )
        ) = 1">
        <xsl:apply-templates mode="p:reduce-aliases" select="$statements"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:sequence select="$statements"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:function>

  <!--
    Creates an operator from its arguments and operator name..
      $name - an operator name.
      $arguments - a sequence of argumnents to combine.
      $index - current index.
      $result - a collected result.
      Returns "and" combined field joins
  -->
  <xsl:function name="p:create-operator" as="element()?">
    <xsl:param name="name" as="xs:QName"/>
    <xsl:param name="arguments" as="element()*"/>
    <xsl:param name="index" as="xs:integer"/>
    <xsl:param name="result" as="element()?"/>

    <xsl:variable name="argument" as="element()?"
      select="$arguments[$index]"/>

    <xsl:choose>
      <xsl:when test="empty($argument)">
        <xsl:sequence select="$result"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:variable name="next-result" as="element()">
          <xsl:choose>
            <xsl:when test="empty($result)">
              <xsl:sequence select="$argument"/>
            </xsl:when>
            <xsl:otherwise>
              <xsl:element name="{$name}">
                <xsl:sequence select="$result"/>
                <xsl:sequence select="$argument"/>
              </xsl:element>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:variable>

        <xsl:sequence select="
          p:create-operator($name, $arguments, $index + 1, $next-result)"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:function>

  <!--
    Removes odd joins from expression.
      $expression - expressions to optimize.
      $odds - odd joins.
      $duplicates - duplicate joins.
      Returns optimized expressions.
  -->
  <xsl:function name="p:optimize-joins" as="element()*">
    <xsl:param name="expression" as="element()*"/>
    <xsl:param name="odds" as="element()*"/>
    <xsl:param name="duplicates" as="element()*"/>

    <xsl:choose>
      <xsl:when test="empty($odds) and empty($duplicates)">
        <xsl:sequence select="$expression"/>
      </xsl:when>
      <xsl:when test="
        exists($duplicates) or
        (
          some
            $field in $expression/descendant-or-self::sql:field,
            $odd-field in $odds/sql:field[1]
          satisfies
            ($field/@field-id = $odd-field/@field-id) and
            (
              $field/string(sql:source/@alias) = 
                $odd-field/string(sql:source/@alias)
            )
        )">

        <xsl:variable name="optimized-expression" as="element()*">
          <xsl:apply-templates mode="p:remove-odd-fields"
            select="$expression">
            <xsl:with-param name="odds" tunnel="yes" select="$odds"/>
            <xsl:with-param name="duplicates" tunnel="yes"
              select="$duplicates"/>
          </xsl:apply-templates>
        </xsl:variable>

        <xsl:sequence
          select="p:optimize-joins($optimized-expression, $odds, ())"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:sequence select="$expression"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:function>

  <!--
    Mode p:remove-odd-fields. Default mode.
  -->
  <xsl:template mode="p:remove-odd-fields" match="@* | node()">
    <xsl:copy>
      <xsl:apply-templates mode="p:remove-odd-fields" select="@* | node()"/>
    </xsl:copy>
  </xsl:template>

  <!--
    Mode p:remove-odd-fields. Remove odd join.
      $odds - odd joins.
      $duplicates - duplicate joins.
  -->
  <xsl:template mode="p:remove-odd-fields" match="sql:eq[xs:boolean(@join)]">
    <xsl:param name="odds" as="element()*" tunnel="yes"/>
    <xsl:param name="duplicates" as="element()*" tunnel="yes"/>

    <xsl:if test="empty(. intersect $odds) and empty(. intersect $duplicates)">
      <xsl:next-match/>
    </xsl:if>
  </xsl:template>

  <!--
    Mode p:remove-odd-fields. Replace parent field with child field.
      $odds - odd joins.
  -->
  <xsl:template mode="p:remove-odd-fields" match="sql:field">
    <xsl:param name="odds" as="element()*" tunnel="yes"/>

    <xsl:variable name="field" as="element()" select="."/>

    <xsl:variable name="substitution" as="element()?" select="
      $odds
      [
        sql:field[1]
        [
          (@field-id = $field/@field-id) and
          (string(sql:source/@alias) = $field/string(sql:source/@alias))
        ]
      ][1]/t:get-sql-element(.)[2]"/>

    <xsl:choose>
      <xsl:when test="exists($substitution)">
        <xsl:sequence select="$substitution"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:next-match/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!--
    Mode p:remove-odd-fields. Eliminate and operators.
  -->
  <xsl:template mode="p:remove-odd-fields" match="sql:and">
    <xsl:variable name="content" as="element()*">
      <xsl:next-match/>
    </xsl:variable>

    <xsl:variable name="elements" as="element()*"
      select="t:get-sql-element($content)"/>

    <xsl:choose>
      <xsl:when test="count($elements) lt 2">
        <xsl:sequence select="$elements"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:sequence select="$content"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!--
    Mode p:remove-odd-fields. Eliminate empty parenthesis.
  -->
  <xsl:template mode="p:remove-odd-fields" match="sql:parens">
    <xsl:variable name="content" as="element()*">
      <xsl:next-match/>
    </xsl:variable>

    <xsl:if test="exists(t:get-sql-element($content))">
      <xsl:sequence select="$content"/>
    </xsl:if>
  </xsl:template>

  <!--
    Constructs sql joins for a set of sources and "where" condition.
      $sources - sources to consider to join.
      $join-candidates - a join candidates.
      Returns a closure of reminder condition and joined sources:
      ($condition as element(), $joined-source as element()+).
      If reminder condition is empty then $t:null-expression is returned.
  -->
  <xsl:function name="p:create-sql-joins" as="element()+">
    <xsl:param name="sources" as="element()*"/>
    <xsl:param name="join-candidates" as="element()*"/>

    <xsl:variable name="join-sources" as="element()*">
      <xsl:for-each select="$join-candidates">
        <xsl:variable name="operands" as="element()*" select="
          (
            self::sql:eq,
            self::sql:ne,
            self::sql:lt,
            self::sql:gt,
            self::sql:le,
            self::sql:ge
          )/
            t:get-sql-element(.)"/>

        <xsl:variable name="join" as="element()?" select="
          for
            $left in $operands[1][self::sql:field],
            $right in $operands[2][self::sql:field]
          return
            .
            [
              $left/string(sql:source/@alias) != 
                $right/string(sql:source/@alias)
            ]"/>
            
        <xsl:if test="$join">
          <xsl:variable name="aliases" as="xs:string+"
            select="$join/sql:field/string(sql:source/@alias)"/>
  
          <xsl:variable name="first-source" as="element()?" select="
            $sources
            [
              descendant-or-self::sql:table/string(@alias) = $aliases[1]
            ]"/>
  
          <xsl:variable name="second-source" as="element()?" select="
            $sources
            [
              descendant-or-self::sql:table/string(@alias) = $aliases[2]
            ]"/>
            
          <xsl:if test="$first-source and $second-source">
            <xsl:sequence select="$first-source, $second-source"/>
          </xsl:if>
        </xsl:if>
      </xsl:for-each>
    </xsl:variable>

    <xsl:choose>
      <xsl:when test="exists($join-sources)">
        <xsl:variable name="first-source" as="element()" 
          select="$join-sources[1]"/>
        <xsl:variable name="second-source" as="element()" 
          select="$join-sources[2]"/>

        <xsl:variable name="source-aliases" as="xs:string+" select="
          ($first-source, $second-source)/
            descendant-or-self::sql:table/string(@alias)"/>

        <xsl:variable name="join" as="element()+" select="
          $join-candidates
          [
            every $alias in .//sql:field/string(sql:source/@alias) satisfies
              $alias = $source-aliases
          ]"/>

        <xsl:variable name="new-source" as="element()">
          <xsl:choose>
            <xsl:when test="$first-source is $second-source">
              <xsl:variable name="on" as="element()"
                select="$first-source/sql:on"/>

              <sql:join>
                <xsl:sequence select="$first-source/* except $on"/>

                <sql:on>
                  <xsl:sequence
                    select="t:combine-joins((t:get-sql-element($on), $join))"/>
                </sql:on>
              </sql:join>
            </xsl:when>
            <xsl:otherwise>
              <sql:join>
                <xsl:sequence select="$first-source, $second-source"/>

                <sql:on>
                  <xsl:sequence select="t:combine-joins($join)"/>
                </sql:on>
              </sql:join>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:variable>

        <xsl:sequence select="
          p:create-sql-joins
          (
            ($sources except ($first-source, $second-source), $new-source),
            ($join-candidates except $join)
          )"/>
      </xsl:when>
      <xsl:when test="empty($join-candidates)">
        <xsl:sequence select="$t:null-expression, $sources"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:sequence select="t:combine-joins($join-candidates), $sources"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:function>

  <!--
    Mode p:reduce-aliases. Default mode.
  -->
  <xsl:template mode="p:reduce-aliases" match="@* | node()">
    <xsl:copy>
      <xsl:apply-templates mode="p:reduce-aliases" select="@* | node()"/>
    </xsl:copy>
  </xsl:template>

  <!--
    Mode p:reduce-aliases. Remove alias.
  -->
  <xsl:template mode="p:reduce-aliases"
    match="sql:table/@alias | sql:field/sql:source/@alias"/>

</xsl:stylesheet>