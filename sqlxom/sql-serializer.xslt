<?xml version="1.0" encoding="utf-8"?>
<!-- This stylesheet generates basic sql. -->
<xsl:stylesheet version="2.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:t="http://www.bphx.com/public/sql"
  xmlns:sql="http://www.bphx.com/basic-sql/2008-12-11"
  exclude-result-prefixes="t xs">

  <!--
    Gets sql statement tokens.
      $statement - a statement to get tokens for.
      Return statement tokens.
  -->
  <xsl:function name="t:get-sql-statement-tokens" as="item()*">
    <xsl:param name="statement" as="element()+"/>

    <xsl:apply-templates mode="t:statement-tokens" select="$statement"/>
  </xsl:function>

  <!--
    Gets sql elements except meta and comment element.
      $parent - a parent to get elements for.
      Returns children elements.
  -->
  <xsl:function name="t:get-sql-element" as="element()*">
    <xsl:param name="parent" as="element()"/>

    <xsl:apply-templates mode="t:get-sql-element" select="$parent/*"/>
  </xsl:function>

  <!--
    Mode "t:get-sql-element". No text.
  -->
  <xsl:template mode="t:get-sql-element" match="text()"/>

  <!--
    Mode "t:get-sql-element". Gets sql element.
  -->
  <xsl:template mode="t:get-sql-element" match="sql:*">
    <xsl:sequence select="."/>
  </xsl:template>

  <!--
    Mode "t:get-sql-element". meta and comment.
  -->
  <xsl:template mode="t:get-sql-element" match="sql:meta | sql:comment"/>

  <!--
    Gets table sources for the element.
      $element - an element to get table sources for.
      Returns table sources.
  -->
  <xsl:function name="t:get-table-sources" as="element()*">
    <xsl:param name="element" as="element()"/>

    <xsl:apply-templates mode="t:get-table-sources" select="$element/*"/>
  </xsl:function>

  <!--
    Get update set statements.
      $element - an element to get set statements for an update.
      Returns set statements.
  -->
  <xsl:function name="t:get-update-set-statements" as="element()*">
    <xsl:param name="element" as="element()"/>

    <xsl:apply-templates mode="t:get-update-set-statements" 
      select="$element/*"/>
  </xsl:function>

  <!--
    Mode "t:get-table-sources". Gets table sources for the element.
  -->
  <xsl:template mode="t:get-table-sources" match="*"/>

  <!--
    Mode "t:get-table-sources". Gets table sources for the element.
  -->
  <xsl:template mode="t:get-table-sources"
    match="sql:table | sql:derived | sql:function-source">
    <xsl:sequence select="."/>
  </xsl:template>

  <!--
    Mode "t:get-table-sources". Gets table sources for the element.
  -->
  <xsl:template mode="t:get-table-sources" match="
    sql:join | 
    sql:inner-join |
    sql:left-join |
    sql:right-join |
    sql:full-join |
    sql:cross-join |
    sql:cross-apply |
    sql:outer-apply">
    <xsl:sequence select="."/>
  </xsl:template>

  <!--
    Mode "t:get-update-set-statements". 
    Get update set statements.
  -->
  <xsl:template mode="t:get-update-set-statements" match="*"/>

  <!--
    Mode "t:get-update-set-statements". 
    Get update set statements.
  -->
  <xsl:template mode="t:get-update-set-statements" match="sql:set">
    <xsl:sequence select="."/>
  </xsl:template>

  <xsl:template match="*" mode="t:get-var-or-host"/>

  <xsl:template match="sql:host-expression | sql:var" mode="t:get-var-or-host">
    <xsl:sequence select="."/>
  </xsl:template>

  <!--
    Tests whether a specified element is a select statement.
      $element - an element to test.
      Returns true if element is a select, or false otherwise.
  -->
  <xsl:function name="t:is-select" as="xs:boolean">
    <xsl:param name="element" as="element()"/>

    <xsl:variable name="select" as="element()?">
      <xsl:apply-templates mode="t:get-select" select="$element"/>
    </xsl:variable>

    <xsl:sequence select="exists($select)"/>
  </xsl:function>

  <!--
    Gets child select element.
      $element - an element to get select element for.
      Returns a select element.
  -->
  <xsl:function name="t:get-select" as="element()*">
    <xsl:param name="element" as="element()"/>

    <xsl:apply-templates mode="t:get-select" select="$element/*"/>
  </xsl:function>

  <!--
    Mode "t:get-select". Gets select element.
  -->
  <xsl:template mode="t:get-select" match="*"/>

  <!--
    Mode "t:get-select". Gets select element.
  -->
  <xsl:template mode="t:get-select" match="
    sql:select |
    sql:values |
    sql:union |
    sql:intersect |
    sql:except">
    <xsl:sequence select="."/>
  </xsl:template>

  <!--
    Gets Common Table Expressions (CTE) for a specified element.
      $element - an element to get CTE for.
      Returns a list of CTE elements.
  -->
  <xsl:function name="t:get-cte" as="element()*">
    <xsl:param name="element" as="element()"/>

    <xsl:apply-templates mode="t:get-cte" select="$element/*"/>
  </xsl:function>

  <!--
    Mode "t:get-cte". Gets Common Table Expressions (CTE).
  -->
  <xsl:template mode="t:get-cte" match="*"/>

  <!--
    Mode "t:get-cte". Gets Common Table Expressions (CTE).
  -->
  <xsl:template mode="t:get-cte" match="sql:with">
    <xsl:sequence select="."/>
  </xsl:template>

  <!--
    Mode "t:generate-cte". Generate Common Table Expressions (CTE).
  -->
  <xsl:template mode="t:generate-cte" match="*"/>

  <!--
    Mode "t:generate-cte". Generate Common Table Expressions (CTE).
  -->
  <xsl:template mode="t:generate-cte" match="sql:with">
    <xsl:sequence select="."/>
  </xsl:template>

  <!--
    Generates CTE for a specified element.
      $cte - a list of CTE.
  -->
  <xsl:template name="t:generate-cte">
    <xsl:param name="cte" as="element()*" select="t:get-cte(.)"/>

    <xsl:if test="exists($cte)">
      <xsl:sequence select="'with'"/>

      <xsl:for-each select="$cte">
        <xsl:variable name="select" as="element()" select="t:get-select(.)"/>

        <xsl:call-template name="t:source-alias">
          <xsl:with-param name="source" select="sql:source"/>
        </xsl:call-template>

        <xsl:sequence select="' '"/>
        <xsl:sequence select="'as'"/>
        <xsl:sequence select="$t:new-line"/>
        <xsl:sequence select="'('"/>
        <xsl:sequence select="$t:new-line"/>
        <xsl:sequence select="$t:indent"/>

        <xsl:apply-templates mode="t:statement-tokens" select="$select"/>

        <xsl:sequence select="$t:unindent"/>
        <xsl:sequence select="$t:new-line"/>
        <xsl:sequence select="')'"/>

        <xsl:if test="position() lt last()">
          <xsl:sequence select="','"/>
        </xsl:if>

        <xsl:sequence select="$t:new-line"/>
      </xsl:for-each>
    </xsl:if>
  </xsl:template>

  <!--
    Mode "t:generate-tokens". Default match.
  -->
  <xsl:template mode="t:statement-tokens" match="*">
    <xsl:sequence select="
      error
      (
        xs:QName('t:error'),
        concat('Invalid statement ', name(), '.')
      )"/>
  </xsl:template>

  <!--
    Mode "t:statement-tokens". Comment.
  -->
  <xsl:template mode="t:statement-tokens" match="sql:statement | sql:comment">
    <xsl:sequence select="$t:comment"/>
    <xsl:sequence select="xs:string(text())"/>
  </xsl:template>

  <!--
    Mode "t:statement-tokens". Set operators.
  -->
  <xsl:template mode="t:statement-tokens"
    match="sql:union | sql:intersect | sql:except">
    <xsl:variable name="all" as="xs:boolean?" select="@all"/>
    <xsl:variable name="selects" as="element()+" select="t:get-select(.)"/>
    <xsl:variable name="first-select" as="element()" select="$selects[1]"/>
    <xsl:variable name="second-select" as="element()" select="$selects[2]"/>

    <xsl:if test="exists($selects[3])">
      <xsl:sequence
        select="error(xs:QName('t:error'), 'Invalid set operator.')"/>
    </xsl:if>

    <xsl:call-template name="t:generate-cte"/>

    <xsl:apply-templates mode="t:statement-tokens" select="$first-select"/>

    <xsl:sequence select="$t:new-line"/>

    <xsl:sequence select="
      if (self::sql:union) then
        'union'
      else if (self::sql:intersect) then
        'intersect'
      else (: if (self::sql:except) then :)
        'except'"/>

    <xsl:if test="$all">
      <xsl:sequence select="' '"/>
      <xsl:sequence select="'all'"/>
    </xsl:if>

    <xsl:sequence select="$t:new-line"/>

    <xsl:apply-templates mode="t:statement-tokens" select="$second-select"/>
  </xsl:template>

  <!--
    Mode "t:statement-tokens". values.
  -->
  <xsl:template mode="t:statement-tokens" match="sql:values">
    <xsl:variable name="rows" as="element()*" select="sql:row"/>

    <xsl:sequence select="'values'"/>
    <xsl:sequence select="$t:new-line"/>

    <xsl:choose>
      <xsl:when test="$rows">
        <xsl:sequence select="$t:indent"/>

        <xsl:for-each select="$rows">
          <xsl:sequence select="'('"/>
          <xsl:sequence select="$t:indent"/>

          <xsl:variable name="expressions" as="element()+"
            select="t:get-sql-element(.)"/>

          <xsl:for-each select="$expressions">
            <xsl:sequence select="$t:new-line"/>

            <xsl:apply-templates mode="t:expression-tokens" select="."/>

            <xsl:if test="position() != last()">
              <xsl:sequence select="','"/>
            </xsl:if>
          </xsl:for-each>

          <xsl:sequence select="$t:unindent"/>
          <xsl:sequence select="$t:new-line"/>
          <xsl:sequence select="')'"/>

          <xsl:if test="position() != last()">
            <xsl:sequence select="','"/>
          </xsl:if>
        </xsl:for-each>

        <xsl:sequence select="$t:unindent"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:sequence select="'('"/>
        <xsl:sequence select="$t:indent"/>

        <xsl:variable name="expressions" as="element()+"
          select="t:get-sql-element(.)"/>

        <xsl:for-each select="$expressions">
          <xsl:sequence select="$t:new-line"/>

          <xsl:apply-templates mode="t:expression-tokens" select="."/>

          <xsl:if test="position() != last()">
            <xsl:sequence select="','"/>
          </xsl:if>
        </xsl:for-each>

        <xsl:sequence select="$t:unindent"/>
        <xsl:sequence select="$t:new-line"/>
        <xsl:sequence select="')'"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!--
    Mode "t:statement-tokens". Select statement.
  -->
  <xsl:template mode="t:statement-tokens" match="sql:select">
    <xsl:variable name="columns" as="element()+" select="sql:column"/>
    <xsl:variable name="into" as="element()?" select="sql:into"/>
    <xsl:variable name="from" as="element()" select="sql:from"/>
    <xsl:variable name="where" as="element()?" select="sql:where"/>
    <xsl:variable name="group-by" as="element()?" select="sql:group-by"/>
    <xsl:variable name="having" as="element()?" select="sql:having"/>
    <xsl:variable name="order-by" as="element()?" select="sql:order-by"/>
    <xsl:variable name="sources" as="element()+"
      select="t:get-table-sources($from)"/>

    <xsl:call-template name="t:generate-cte"/>

    <xsl:sequence select="'select'"/>

    <xsl:if test="@specification = 'distinct'">
      <xsl:sequence select="' '"/>
      <xsl:sequence select="'distinct'"/>
    </xsl:if>

    <xsl:apply-templates mode="t:select-header-extensions" select="."/>
    
    <xsl:sequence select="$t:indent"/>

    <xsl:for-each select="$columns">
      <xsl:variable name="wildcard" as="xs:boolean?" select="@wildcard"/>
      <xsl:variable name="alias" as="xs:string" select="string(@alias)"/>

      <xsl:sequence select="$t:new-line"/>

      <xsl:choose>
        <xsl:when test="$wildcard">
          <xsl:if test="$alias">
            <xsl:sequence select="t:quote-name($alias)"/>
            <xsl:sequence select="'.'"/>
          </xsl:if>

          <xsl:sequence select="'*'"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:variable name="expression" as="element()"
            select="t:get-sql-element(.)"/>

          <xsl:apply-templates mode="t:expression-tokens"
            select="$expression"/>

          <xsl:if test="$alias">
            <xsl:sequence select="' '"/>
            <xsl:sequence select="t:quote-name($alias)"/>
          </xsl:if>
        </xsl:otherwise>
      </xsl:choose>

      <xsl:if test="position() != last()">
        <xsl:sequence select="','"/>
      </xsl:if>
    </xsl:for-each>

    <xsl:sequence select="$t:unindent"/>

    <xsl:if test="exists($into)">
      <xsl:call-template name="t:generate-into-clause">
        <xsl:with-param name="into" select="$into"/>
      </xsl:call-template>
    </xsl:if>

    <xsl:sequence select="$t:new-line"/>
    <xsl:sequence select="'from'"/>
    <xsl:sequence select="$t:indent"/>

    <xsl:for-each select="$sources">
      <xsl:sequence select="$t:new-line"/>

      <xsl:apply-templates mode="t:table-source" select="."/>

      <xsl:if test="position() != last()">
        <xsl:sequence select="','"/>
      </xsl:if>
    </xsl:for-each>

    <xsl:sequence select="$t:unindent"/>
    
    <xsl:if test="exists($where)">
      <xsl:sequence select="$t:new-line"/>
      <xsl:sequence select="'where'"/>
      <xsl:sequence select="$t:indent"/>
      <xsl:sequence select="$t:new-line"/>

      <xsl:variable name="expression" as="element()"
        select="t:get-sql-element($where)"/>

      <xsl:apply-templates mode="t:expression-tokens" select="$expression"/>

      <xsl:sequence select="$t:unindent"/>
    </xsl:if>

    <xsl:if test="exists($group-by)">
      <xsl:sequence select="$t:new-line"/>
      <xsl:sequence select="'group'"/>
      <xsl:sequence select="' '"/>
      <xsl:sequence select="'by'"/>
      <xsl:sequence select="$t:indent"/>

      <xsl:variable name="elements" as="element()+"
        select="t:get-sql-element($group-by)"/>

      <xsl:for-each select="$elements">
        <xsl:sequence select="$t:new-line"/>

        <xsl:apply-templates mode="t:expression-tokens" select="."/>

        <xsl:if test="position() != last()">
          <xsl:sequence select="','"/>
        </xsl:if>
      </xsl:for-each>

      <xsl:sequence select="$t:unindent"/>
    </xsl:if>

    <xsl:if test="exists($having)">
      <xsl:sequence select="$t:new-line"/>
      <xsl:sequence select="'having'"/>
      <xsl:sequence select="$t:new-line"/>
      <xsl:sequence select="$t:indent"/>

      <xsl:variable name="expression" as="element()"
        select="t:get-sql-element($having)"/>

      <xsl:apply-templates mode="t:expression-tokens" select="$expression"/>

      <xsl:sequence select="$t:unindent"/>
    </xsl:if>

    <xsl:call-template name="t:generate-order-by">
      <xsl:with-param name="order-by" select="$order-by"/>
    </xsl:call-template>

    <xsl:apply-templates mode="t:select-footer-extensions" select="."/>
  </xsl:template>

  <!--
    Generates into clause.
      $into - an into clause.
  -->
  <xsl:template name="t:generate-into-clause">
    <xsl:param name="into" as="element()"/>

    <xsl:variable name="vars" as="element()+">
      <xsl:apply-templates mode="t:get-var-or-host" 
        select="t:get-sql-element($into)"/>
    </xsl:variable>

    <xsl:sequence select="$t:new-line"/>
    <xsl:sequence select="'into'"/>
    <xsl:sequence select="$t:new-line"/>
    <xsl:sequence select="$t:indent"/>

    <xsl:for-each select="$vars">
      <xsl:apply-templates mode="t:var-or-host" select="."/>

      <xsl:if test="position() lt last()">
        <xsl:sequence select="','"/>
        <xsl:sequence select="$t:new-line"/>
      </xsl:if>
    </xsl:for-each>

    <xsl:sequence select="$t:unindent"/>
  </xsl:template>

  <!--
    Generates order by clause.
      $order-by - an order by clause.
  -->
  <xsl:template name="t:generate-order-by">
    <xsl:param name="order-by" as="element()?"/>

    <xsl:if test="exists($order-by)">
      <xsl:sequence select="$t:new-line"/>
      <xsl:sequence select="'order'"/>
      <xsl:sequence select="' '"/>
      <xsl:sequence select="'by'"/>
      <xsl:sequence select="$t:indent"/>

      <xsl:variable name="predicate" as="element()+"
        select="t:get-sql-element($order-by)"/>

      <xsl:for-each select="$predicate">
        <xsl:variable name="expression" as="element()"
          select="t:get-sql-element(.)"/>

        <xsl:sequence select="$t:new-line"/>

        <xsl:apply-templates mode="t:expression-tokens" select="$expression"/>

        <xsl:if test="self::sql:descending">
          <xsl:sequence select="' '"/>
          <xsl:sequence select="'desc'"/>
        </xsl:if>

        <xsl:if test="position() != last()">
          <xsl:sequence select="','"/>
        </xsl:if>
      </xsl:for-each>

      <xsl:sequence select="$t:unindent"/>

      <xsl:variable name="offset" as="element()?" select="$order-by/sql:offset"/>
      <xsl:variable name="fetch" as="element()?" select="$order-by/sql:fetch"/>

      <xsl:if test="$offset">
        <xsl:sequence select="$t:new-line"/>
        <xsl:sequence select="'offset'"/>
        <xsl:sequence select="' '"/>

        <xsl:variable name="offset-expression" as="element()"
          select="t:get-sql-element($offset)"/>

        <xsl:apply-templates mode="t:expression-tokens" select="$offset-expression"/>

        <xsl:sequence select="' '"/>

        <xsl:sequence select="
          if ($offset-expression[self::sql:number/@value = 1]) then
            'row'
          else
            'rows'"/>

        <xsl:if test="$fetch">
          <xsl:variable name="fetch-expression" as="element()"
            select="t:get-sql-element($fetch)"/>

          <xsl:sequence select="$t:new-line"/>
          <xsl:sequence select="'fetch'"/>
          <xsl:sequence select="' '"/>

          <xsl:sequence select="
            if ($offset-expression[self::sql:number/@value = 0]) then
              'first'
            else
              'next'"/>

          <xsl:sequence select="' '"/>

          <xsl:apply-templates mode="t:expression-tokens" select="fetch-expression"/>

          <xsl:sequence select="' '"/>

          <xsl:sequence select="
            if ($fetch-expression[self::sql:number/@value = 1]) then
              'row'
            else
              'rows'"/>

          <xsl:sequence select="' '"/>
          <xsl:sequence select="'only'"/>
        </xsl:if>
      </xsl:if>
    </xsl:if>
  </xsl:template>

  <!--
    Mode "t:statement-tokens". Insert statement.
  -->
  <xsl:template mode="t:statement-tokens" match="sql:insert">
    <xsl:variable name="source" as="element()"
      select="t:get-table-sources(.)"/>
    <xsl:variable name="values" as="element()" select="t:get-select(.)"/>

    <xsl:variable name="source-tokens" as="item()*">
      <xsl:apply-templates mode="t:table-source" select="$source"/>
    </xsl:variable>

    <xsl:call-template name="t:generate-cte"/>
    <xsl:sequence select="'insert'"/>
    <xsl:sequence select="' '"/>
    <xsl:apply-templates mode="t:insert-header-extensions" select="."/>
    <xsl:sequence select="'into'"/>
    <xsl:sequence select="' '"/>
    <xsl:sequence select="$source-tokens"/>
    <xsl:apply-templates mode="t:insert-values-extensions" select="."/>
    <xsl:sequence select="$t:new-line"/>
    <xsl:apply-templates mode="t:statement-tokens" select="$values"/>
    <xsl:apply-templates mode="t:insert-footer-extensions" select="."/>
  </xsl:template>

  <!--
    Mode "t:statement-tokens". Update statement.
  -->
  <xsl:template mode="t:statement-tokens" match="sql:update">
    <xsl:variable name="source" as="element()"
      select="t:get-table-sources(.)"/>
    <xsl:variable name="set" as="element()+" 
      select="t:get-update-set-statements(.)"/>
    <xsl:variable name="where" as="element()?" select="sql:where"/>

    <xsl:call-template name="t:generate-cte"/>

    <xsl:sequence select="'update'"/>
    <xsl:sequence select="' '"/>
    <xsl:apply-templates mode="t:update-header-extensions" select="."/>

    <xsl:variable name="source-tokens" as="item()*">
      <xsl:apply-templates mode="t:table-source" select="$source"/>
    </xsl:variable>

    <xsl:if test="t:is-multiline($source-tokens)">
    <xsl:sequence select="$t:new-line"/>
    </xsl:if>

    <xsl:sequence select="$source-tokens"/>

    <xsl:sequence select="$t:new-line"/>
    <xsl:sequence select="'set'"/>
    <xsl:sequence select="$t:indent"/>

    <xsl:for-each select="$set">
      <xsl:apply-templates mode="t:update-set-statement" select="."/>

      <xsl:if test="position() != last()">
        <xsl:sequence select="','"/>
      </xsl:if>
    </xsl:for-each>

    <xsl:sequence select="$t:unindent"/>

    <xsl:apply-templates mode="t:update-where-extensions" select="."/>

    <xsl:if test="exists($where)">
      <xsl:sequence select="$t:new-line"/>
      <xsl:sequence select="'where'"/>
      <xsl:sequence select="$t:indent"/>

      <xsl:variable name="expression" as="element()"
        select="t:get-sql-element($where)"/>

      <xsl:sequence select="$t:new-line"/>

      <xsl:apply-templates mode="t:expression-tokens" select="$expression"/>

      <xsl:sequence select="$t:unindent"/>
    </xsl:if>

    <xsl:apply-templates mode="t:update-footer-extensions" select="."/>
  </xsl:template>

  <!--
    Mode "t:update-set-statement" set of update.
  -->
  <xsl:template mode="t:update-set-statement" match="sql:set">
    <xsl:variable name="arguments" as="element()+"
      select="t:get-sql-element(.)"/>
    <xsl:variable name="field" as="element()"
      select="$arguments[1][self::sql:field]"/>
    <xsl:variable name="expression" as="element()"
      select="$arguments[2]"/>

    <xsl:sequence select="$t:new-line"/>

    <xsl:apply-templates mode="t:expression-tokens" select="$field"/>

    <xsl:sequence select="' '"/>
    <xsl:sequence select="'='"/>
    <xsl:sequence select="' '"/>

    <xsl:apply-templates mode="t:expression-tokens" select="$expression"/>
  </xsl:template>

  <!--
    Mode "t:statement-tokens". Delete statement.
  -->
  <xsl:template mode="t:statement-tokens" match="sql:delete">
    <xsl:variable name="source" as="element()"
      select="t:get-table-sources(.)"/>
    <xsl:variable name="where" as="element()?" select="sql:where"/>

    <xsl:call-template name="t:generate-cte"/>

    <xsl:sequence select="'delete'"/>
    <xsl:sequence select="' '"/>
    <xsl:apply-templates mode="t:delete-header-extensions" select="."/>
    <xsl:sequence select="'from'"/>

    <xsl:variable name="source-tokens" as="item()*">
      <xsl:apply-templates mode="t:table-source" select="$source"/>
    </xsl:variable>

    <xsl:choose>
      <xsl:when test="t:is-multiline($source-tokens)">
        <xsl:sequence select="$t:new-line"/>
        <xsl:sequence select="$t:indent"/>
        <xsl:sequence select="$source-tokens"/>
        <xsl:sequence select="$t:unindent"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:sequence select="' '"/>
        <xsl:sequence select="$source-tokens"/>
      </xsl:otherwise>
    </xsl:choose>
    
    <xsl:apply-templates mode="t:delete-where-extensions" select="."/>

    <xsl:if test="exists($where)">
      <xsl:sequence select="$t:new-line"/>
      <xsl:sequence select="'where'"/>
      <xsl:sequence select="$t:indent"/>

      <xsl:variable name="expression" as="element()"
        select="t:get-sql-element($where)"/>

      <xsl:sequence select="$t:new-line"/>

      <xsl:apply-templates mode="t:expression-tokens" select="$expression"/>

      <xsl:sequence select="$t:unindent"/>
    </xsl:if>

    <xsl:apply-templates mode="t:delete-footer-extensions" select="."/>
  </xsl:template>

  <!--
    Key to get keywords.
  -->
  <xsl:key name="t:keyword" match="*" use="xs:string(@name)"/>

  <xsl:variable name="t:keywords" as="document-node()*">
    <xsl:variable name="handler" as="element()">
      <t:keywords/>
    </xsl:variable>
    
    <xsl:apply-templates mode="t:collect-keywords" select="$handler"/>
  </xsl:variable>

  <!--
    Key to get operator precedence.
  -->
  <xsl:key name="t:operator-precedence" match="t:operator"
    use="xs:string(@name)"/>

  <!--
    Operator precedence list.
  -->
  <xsl:variable name="t:operators-precedence">
    <xsl:variable name="handler" as="element()">
      <t:operators/>
    </xsl:variable>

    <xsl:apply-templates mode="t:collect-operators" select="$handler"/>
  </xsl:variable>

  <!--
    Collects operator infos.
  -->
  <xsl:template match="t:operators" mode="t:collect-operators">
    <t:operator name="div" precedence="1"/>
    <t:operator name="mul" precedence="1"/>

    <t:operator name="add" precedence="2"/>
    <t:operator name="sub" precedence="2"/>

    <t:operator name="eq" precedence="3"/>
    <t:operator name="ne" precedence="3"/>
    <t:operator name="gt" precedence="3"/>
    <t:operator name="lt" precedence="3"/>
    <t:operator name="le" precedence="3"/>
    <t:operator name="ge" precedence="3"/>

    <t:operator name="not" precedence="4"/>

    <t:operator name="and" precedence="-2"/>
    <t:operator name="or" precedence="-1"/>

    <t:operator name="between" precedence="6"/>
    <t:operator name="in" precedence="6"/>
    <t:operator name="like" precedence="6"/>
  </xsl:template>
  
  <!--
    Gets precedence of the operator.
      $operator - an operator to get precedence for.
      Return operator precedence.
  -->
  <xsl:function name="t:get-precedence" as="xs:integer?">
    <xsl:param name="operator" as="element()"/>

    <xsl:variable name="precedence" as="element()">
      <t:precedence/>
    </xsl:variable>

    <xsl:apply-templates mode="t:get-precedence" select="$precedence">
      <xsl:with-param name="operator" select="$operator"/>
    </xsl:apply-templates>
  </xsl:function>

  <!--
    Mode "t:get-precedence". Get precedence implementation.
      $operator - an operator to get precedence for.
  -->
  <xsl:template mode="t:get-precedence" match="t:precedence" as="xs:integer?">
    <xsl:param name="operator" as="element()"/>

    <xsl:sequence select="
      key
      (
        't:operator-precedence',
        local-name($operator),
        $t:operators-precedence
      )/@precedence"/>
  </xsl:template>

  <!--
    Gets expressions tokens, taking into account operator precedence.
      $expression - an expression to get tokens for.
      $parent - parent expression.
      $second-argument - true for a second argument in binary expression.
      Returns expression tokens.
  -->
  <xsl:template name="t:get-parenthesis-expression" as="item()*">
    <xsl:param name="expression" as="element()"/>
    <xsl:param name="parent" as="element()"/>
    <xsl:param name="second-argument" as="xs:boolean?"/>

    <xsl:variable name="parent-precedence" as="xs:integer?"
      select="t:get-precedence($parent)"/>
    <xsl:variable name="expression-precedence" as="xs:integer?"
      select="t:get-precedence($expression)"/>

    <xsl:choose>
      <xsl:when test="
        (
          if ($second-argument) then
            $parent-precedence le $expression-precedence
          else
            $parent-precedence lt $expression-precedence
        ) or
        ($parent-precedence lt 0) and
        exists($expression-precedence) and
        ($parent-precedence ne $expression-precedence)">
        <xsl:variable name="tokens" as="item()*">
          <xsl:apply-templates mode="t:expression-tokens" select="$expression"/>
        </xsl:variable>

        <xsl:variable name="multiline" as="xs:boolean"
          select="t:is-multiline($tokens)"/>

        <xsl:sequence select="'('"/>

        <xsl:choose>
          <xsl:when test="$multiline">
            <xsl:sequence select="$t:new-line"/>
            <xsl:sequence select="$t:indent"/>
            <xsl:sequence select="$tokens"/>
            <xsl:sequence select="$t:unindent"/>
            <xsl:sequence select="$t:new-line"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:sequence select="$tokens"/>
          </xsl:otherwise>
        </xsl:choose>

        <xsl:sequence select="')'"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:apply-templates mode="t:expression-tokens" select="$expression"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!--
    Gets binary expression tokens.
      $operator - an operator tokens.
      Return expression tokens.
  -->
  <xsl:template name="t:get-binary-expression" as="item()*">
    <xsl:param name="operator" as="item()*"/>

    <xsl:variable name="arguments" as="element()+"
      select="t:get-sql-element(.)"/>
    <xsl:variable name="argument1" as="element()" select="$arguments[1]"/>
    <xsl:variable name="argument2" as="element()" select="$arguments[2]"/>

    <xsl:call-template name="t:get-parenthesis-expression">
      <xsl:with-param name="expression" select="$argument1"/>
      <xsl:with-param name="parent" select="."/>
    </xsl:call-template>

    <xsl:if test="empty(index-of((' ', $t:new-line), $operator[1]))">
      <xsl:sequence select="' '"/>
    </xsl:if>

    <xsl:sequence select="$operator"/>

    <xsl:if test="empty(index-of((' ', $t:new-line), $operator[last()]))">
      <xsl:sequence select="' '"/>
    </xsl:if>

    <xsl:call-template name="t:get-parenthesis-expression">
      <xsl:with-param name="expression" select="$argument2"/>
      <xsl:with-param name="parent" select="."/>
      <xsl:with-param name="second-argument" select="true()"/>
    </xsl:call-template>
  </xsl:template>

  <!--
    Gets unary expression tokens.
      $operator - an operator tokens.
      $prefix - true for prefix, and false for the postfix expression.
      Return expression tokens.
  -->
  <xsl:template name="t:get-unary-expression" as="item()*">
    <xsl:param name="operator" as="item()*"/>
    <xsl:param name="prefix" as="xs:boolean"/>

    <xsl:variable name="argument" as="element()"
      select="t:get-sql-element(.)"/>

    <xsl:choose>
      <xsl:when test="$prefix">
        <xsl:sequence select="$operator"/>
        <xsl:sequence select="' '"/>

        <xsl:call-template name="t:get-parenthesis-expression">
          <xsl:with-param name="expression" select="$argument"/>
          <xsl:with-param name="parent" select="."/>
        </xsl:call-template>
      </xsl:when>
      <xsl:otherwise>
        <xsl:call-template name="t:get-parenthesis-expression">
          <xsl:with-param name="expression" select="$argument"/>
          <xsl:with-param name="parent" select="."/>
        </xsl:call-template>

        <xsl:sequence select="' '"/>
        <xsl:sequence select="$operator"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!--
    Gets aggregate expression tokens.
      $name - aggregate function name.
      Returns aggregate expression tokens.
  -->
  <xsl:template name="t:get-aggregate-expresion" as="item()*">
    <xsl:param name="name" as="xs:string"/>

    <xsl:variable name="over" as="element()?" select="sql:over"/>

    <xsl:sequence select="$name"/>
    <xsl:sequence select="'('"/>

    <xsl:if test="@specification = 'distinct'">
      <xsl:sequence select="'distinct'"/>
      <xsl:sequence select="' '"/>
    </xsl:if>

    <xsl:choose>
      <xsl:when test="xs:boolean(@wildcard)">
        <xsl:sequence select="'*'"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:variable name="expressions" as="element()*"
          select="t:get-sql-element(.) except $over"/>

        <xsl:for-each select="$expressions">
          <xsl:if test="last() != 1">
            <xsl:sequence select="$t:new-line"/>
          </xsl:if>

          <xsl:apply-templates mode="t:expression-tokens" select="."/>

          <xsl:if test="position() != last()">
            <xsl:sequence select="','"/>
          </xsl:if>
        </xsl:for-each>
      </xsl:otherwise>
    </xsl:choose>

    <xsl:sequence select="')'"/>

    <xsl:apply-templates mode="t:get-over-clause" select="$over"/>
  </xsl:template>

  <xsl:template mode="t:get-over-clause" match="sql:over" as="item()*">
    <xsl:variable name="partition-by" as="element()?"
      select="sql:partition-by"/>
    <xsl:variable name="order-by" as="element()?"
      select="sql:order-by"/>
    <xsl:variable name="window" as="element()?" select="sql:rows, sql:range"/>

    <xsl:choose>
      <xsl:when test="empty($partition-by) and empty($order-by)">
        <xsl:sequence select="' '"/>
        <xsl:sequence select="'over'"/>
        <xsl:sequence select="'('"/>
        <xsl:sequence select="')'"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:sequence select="$t:new-line"/>
        <xsl:sequence select="$t:indent"/>
        <xsl:sequence select="'over'"/>
        <xsl:sequence select="$t:new-line"/>
        <xsl:sequence select="'('"/>
        <xsl:sequence select="$t:indent"/>

        <xsl:if test="exists($partition-by)">
          <xsl:sequence select="$t:new-line"/>
          <xsl:sequence select="'partition'"/>
          <xsl:sequence select="' '"/>
          <xsl:sequence select="'by'"/>
          <xsl:sequence select="$t:indent"/>

          <xsl:variable name="elements" as="element()+"
            select="t:get-sql-element($partition-by)"/>

          <xsl:for-each select="$elements">
            <xsl:sequence select="$t:new-line"/>

            <xsl:apply-templates mode="t:expression-tokens" select="."/>

            <xsl:if test="position() != last()">
              <xsl:sequence select="','"/>
            </xsl:if>
          </xsl:for-each>

          <xsl:sequence select="$t:unindent"/>
        </xsl:if>

        <xsl:call-template name="t:generate-order-by">
          <xsl:with-param name="order-by" select="$order-by"/>
        </xsl:call-template>

        <xsl:if test="$window">
          <xsl:sequence select="$t:new-line"/>

          <xsl:sequence select="
            if ($window[self::sql:rows]) then
              'rows'
            else
              'range'"/>

          <xsl:sequence select="' '"/>
          <xsl:sequence select="$t:indent"/>
          <xsl:apply-templates mode="t:window-frame"
            select="t:get-sql-element($window)"/>
          <xsl:sequence select="$t:unindent"/>
        </xsl:if>

        <xsl:sequence select="$t:unindent"/>
        <xsl:sequence select="$t:new-line"/>
        <xsl:sequence select="')'"/>
        <xsl:sequence select="$t:unindent"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!--
    Mode "t:window-frame". Default match.
  -->
  <xsl:template mode="t:window-frame t:window-frame-bound" match="*">
    <xsl:sequence select="
      error
      (
        xs:QName('t:error'),
        concat('Invalid window frame ', name(), '.')
      )"/>
  </xsl:template>

  <!--
    Mode "t:window-frame". between window frame.
  -->
  <xsl:template mode="t:window-frame" match="sql:between">
    <xsl:variable name="range" as="element()+"
      select="t:get-sql-element(.)"/>
    <xsl:variable name="from" as="element()" select="$range[1]"/>
    <xsl:variable name="to" as="element()" select="$range[2]"/>

    <xsl:sequence select="'between'"/>
    <xsl:sequence select="' '"/>
    <xsl:apply-templates mode="t:window-frame-bound" select="$from"/>
    <xsl:sequence select="' '"/>
    <xsl:sequence select="'and'"/>
    <xsl:sequence select="' '"/>
    <xsl:apply-templates mode="t:window-frame-bound" select="to"/>
  </xsl:template>

  <!--
    Mode "t:window-frame". UNBOUNDED PRECEDING.
  -->
  <xsl:template mode="t:window-frame t:window-frame-bound" match="preceding[unbounded]">
    <xsl:sequence select="'unbounded'"/>
    <xsl:sequence select="' '"/>
    <xsl:sequence select="'preceding'"/>
  </xsl:template>

  <!--
    Mode "t:window-frame". UNBOUNDED FOLLOWING.
  -->
  <xsl:template mode="t:window-frame t:window-frame-bound" match="following[unbounded]">
    <xsl:sequence select="'unbounded'"/>
    <xsl:sequence select="' '"/>
    <xsl:sequence select="'following'"/>
  </xsl:template>

  <!--
    Mode "t:window-frame". current row.
  -->
  <xsl:template mode="t:window-frame t:window-frame-bound" 
    match="preceding[current-row] | following[current-row]">
    <xsl:sequence select="'current'"/>
    <xsl:sequence select="' '"/>
    <xsl:sequence select="'row'"/>
  </xsl:template>

  <!--
    Mode "t:window-frame". <unsigned_value_specification> PRECEDING.
  -->
  <xsl:template mode="t:window-frame t:window-frame-bound" match="preceding[number]">
    <xsl:variable name="value" as="xs:string" select="xs:string(xs:integer(@value))"/>

    <xsl:sequence select="$value"/>
    <xsl:sequence select="' '"/>
    <xsl:sequence select="'preceding'"/>
  </xsl:template>

  <!--
    Mode "t:window-frame". <unsigned_value_specification> FOLLOWING.
  -->
  <xsl:template mode="t:window-frame t:window-frame-bound" match="following[number]">
    <xsl:variable name="value" as="xs:string" select="xs:string(xs:integer(@value))"/>

    <xsl:sequence select="$value"/>
    <xsl:sequence select="' '"/>
    <xsl:sequence select="'following'"/>
  </xsl:template>

  <!--
    Mode "t:expression-tokens". Default match.
  -->
  <xsl:template mode="t:expression-tokens" match="*">
    <xsl:sequence select="
      error
      (
        xs:QName('t:error'),
        concat('Invalid expression ', name(), '.')
      )"/>
  </xsl:template>

  <!--
    Mode "t:expression-tokens". add.
  -->
  <xsl:template mode="t:expression-tokens" match="sql:add">
    <xsl:call-template name="t:get-binary-expression">
      <xsl:with-param name="operator" select="'+'"/>
    </xsl:call-template>
  </xsl:template>

  <!--
    Mode "t:expression-tokens". sub.
  -->
  <xsl:template mode="t:expression-tokens" match="sql:sub">
    <xsl:call-template name="t:get-binary-expression">
      <xsl:with-param name="operator" select="'-'"/>
    </xsl:call-template>
  </xsl:template>

  <!--
    Mode "t:expression-tokens". mul.
  -->
  <xsl:template mode="t:expression-tokens" match="sql:mul">
    <xsl:call-template name="t:get-binary-expression">
      <xsl:with-param name="operator" select="'*'"/>
    </xsl:call-template>
  </xsl:template>

  <!--
    Mode "t:expression-tokens". div.
  -->
  <xsl:template mode="t:expression-tokens" match="sql:div">
    <xsl:call-template name="t:get-binary-expression">
      <xsl:with-param name="operator" select="'/'"/>
    </xsl:call-template>
  </xsl:template>

  <!--
    Mode "t:expression-tokens". neg.
  -->
  <xsl:template mode="t:expression-tokens" match="sql:neg">
    <xsl:call-template name="t:get-unary-expression">
      <xsl:with-param name="operator" select="'-'"/>
      <xsl:with-param name="prefix" select="true()"/>
    </xsl:call-template>
  </xsl:template>

  <!--
    Mode "t:expression-tokens". parens.
  -->
  <xsl:template mode="t:expression-tokens" match="sql:parens">
    <xsl:variable name="expression" as="element()"
      select="t:get-sql-element(.)"/>

    <xsl:sequence select="'('"/>

    <xsl:apply-templates mode="t:expression-tokens" select="$expression"/>

    <xsl:sequence select="')'"/>
  </xsl:template>

  <!--
    Mode "t:expression-tokens". null.
  -->
  <xsl:template mode="t:expression-tokens" match="sql:null">
    <xsl:sequence select="'null'"/>
  </xsl:template>

  <!--
    Mode "t:expression-tokens". default.
  -->
  <xsl:template mode="t:expression-tokens" match="sql:default">
    <xsl:sequence select="'default'"/>
  </xsl:template>

  <!--
    Mode "t:expression-tokens". Default match.
  -->
  <xsl:template match="sql:host-expression"
     mode="t:expression-tokens t:var-or-host">
    <xsl:sequence select="."/>
  </xsl:template>

  <!--
    Mode "t:expression-tokens". string.
  -->
  <xsl:template mode="t:expression-tokens" match="sql:string">
    <xsl:variable name="value" as="xs:string" select="@value"/>

    <xsl:variable name="escaped-value" as="xs:string"
      select="replace($value, '''', '''''', 'm')"/>

    <xsl:sequence select="concat('''', $escaped-value, '''')"/>
  </xsl:template>

  <!--
    Mode "t:expression-tokens". number.
  -->
  <xsl:template mode="t:expression-tokens" match="sql:number">
    <xsl:variable name="value" as="xs:string" select="@value"/>

    <xsl:sequence select="$value"/>
  </xsl:template>

  <!--
    Mode "t:expression-tokens". var
  -->
  <xsl:template match="sql:var" mode="t:expression-tokens t:var-or-host" >
    <xsl:sequence select="string(@name)"/>
  </xsl:template>

  <!--
    Build a qualified name.
      $name - a name element (context by default).
  -->
  <xsl:template name="t:qualified-name">
    <xsl:param name="name" as="element()" select="."/>

    <xsl:variable name="database" as="xs:string?" select="$name/@database"/>
    <xsl:variable name="schema" as="xs:string?" select="$name/@schema"/>
    <xsl:variable name="owner" as="xs:string?" select="$name/@owner"/>
    <xsl:variable name="name-name" as="xs:string" select="$name/@name"/>

    <xsl:if test="$database">
      <xsl:sequence select="t:quote-name($database)"/>
      <xsl:sequence select="'.'"/>
    </xsl:if>

    <xsl:if test="$database or $schema or $owner">
      <xsl:sequence select="t:quote-name(string(($schema, $owner)[1]))"/>
      <xsl:sequence select="'.'"/>
    </xsl:if>

    <xsl:sequence select="t:quote-name($name-name)"/>
  </xsl:template>

  <!--
    Mode "t:expression-tokens". field.
  -->
  <xsl:template mode="t:expression-tokens" match="sql:field">
    <xsl:variable name="source-tokens" as="item()*">
      <xsl:apply-templates mode="t:source-ref" select="t:get-sql-element(.)"/> 
    </xsl:variable>
  
    <xsl:if test="exists($source-tokens)">
      <xsl:sequence select="$source-tokens"/>
      <xsl:sequence select="'.'"/>
    </xsl:if>

    <xsl:sequence select="t:quote-name(@name)"/>
  </xsl:template>

  <!--
    Mode "t:expression-tokens". analytic-function.
  -->
  <xsl:template mode="t:expression-tokens" match="sql:analytic-function">
    <xsl:call-template name="t:get-aggregate-expresion">
      <xsl:with-param name="name" select="@name"/>
    </xsl:call-template>
  </xsl:template>

  <!--
    Mode "t:expression-tokens". ranking-function.
  -->
  <xsl:template mode="t:expression-tokens" match="sql:ranking-function">
    <xsl:call-template name="t:get-aggregate-expresion">
      <xsl:with-param name="name" select="@name"/>
    </xsl:call-template>
  </xsl:template>

  <!--
    Mode "t:expression-tokens". min.
  -->
  <xsl:template mode="t:expression-tokens" match="sql:min">
    <xsl:call-template name="t:get-aggregate-expresion">
      <xsl:with-param name="name" select="'min'"/>
    </xsl:call-template>
  </xsl:template>

  <!--
    Mode "t:expression-tokens". max.
  -->
  <xsl:template mode="t:expression-tokens" match="sql:max">
    <xsl:call-template name="t:get-aggregate-expresion">
      <xsl:with-param name="name" select="'max'"/>
    </xsl:call-template>
  </xsl:template>

  <!--
    Mode "t:expression-tokens". avg.
  -->
  <xsl:template mode="t:expression-tokens" match="sql:avg">
    <xsl:call-template name="t:get-aggregate-expresion">
      <xsl:with-param name="name" select="'avg'"/>
    </xsl:call-template>
  </xsl:template>

  <!--
    Mode "t:expression-tokens". count.
  -->
  <xsl:template mode="t:expression-tokens" match="sql:count">
    <xsl:call-template name="t:get-aggregate-expresion">
      <xsl:with-param name="name" select="'count'"/>
    </xsl:call-template>
  </xsl:template>

  <!--
    Mode "t:expression-tokens". sum.
  -->
  <xsl:template mode="t:expression-tokens" match="sql:sum">
    <xsl:call-template name="t:get-aggregate-expresion">
      <xsl:with-param name="name" select="'sum'"/>
    </xsl:call-template>
  </xsl:template>

  <!--
    Mode "t:expression-tokens". sum.
  -->
  <xsl:template mode="t:expression-tokens" match="sql:aggregate-function">
    <xsl:call-template name="t:get-aggregate-expresion">
      <xsl:with-param name="name" select="@name"/>
    </xsl:call-template>
  </xsl:template>

  <!--
    Mode "t:expression-tokens". function.
  -->
  <xsl:template mode="t:expression-tokens" match="sql:function">
    <xsl:variable name="name" as="xs:string" select="@name"/>

    <xsl:sequence select="$name"/>
    <xsl:sequence select="'('"/>

    <xsl:variable name="arguments" as="element()*"
      select="t:get-sql-element(.)"/>

    <xsl:for-each select="$arguments">
      <xsl:apply-templates mode="t:expression-tokens" select="."/>

      <xsl:if test="position() != last()">
        <xsl:sequence select="','"/>
        <xsl:sequence select="' '"/>
      </xsl:if>
    </xsl:for-each>

    <xsl:sequence select="')'"/>
  </xsl:template>

  <!--
    Mode "t:expression-tokens". cast.
  -->
  <xsl:template mode="t:expression-tokens" match="sql:cast" name="t:cast">
    <xsl:variable name="value" as="element()"
      select="t:get-sql-element(sql:value)"/>
    <xsl:variable name="type" as="element()" select="sql:type"/>

    <xsl:sequence select="'cast'"/>
    <xsl:sequence select="'('"/>

    <xsl:apply-templates mode="t:expression-tokens" select="$value"/>

    <xsl:sequence select="' '"/>
    <xsl:sequence select="'as'"/>
    <xsl:sequence select="' '"/>
    <xsl:sequence select="t:get-sql-type($type)"/>
    <xsl:sequence select="')'"/>
  </xsl:template>

  <!--
    Mode "t:expression-tokens". or.
  -->
  <xsl:template mode="t:expression-tokens" match="sql:or">
    <xsl:call-template name="t:get-binary-expression">
      <xsl:with-param name="operator" select="'or', $t:new-line"/>
    </xsl:call-template>
  </xsl:template>

  <!--
    Mode "t:expression-tokens". and.
  -->
  <xsl:template mode="t:expression-tokens" match="sql:and">
    <xsl:call-template name="t:get-binary-expression">
      <xsl:with-param name="operator" select="'and', $t:new-line"/>
    </xsl:call-template>
  </xsl:template>

  <!--
    Mode "t:expression-tokens". not.
  -->
  <xsl:template mode="t:expression-tokens" match="sql:not">
    <xsl:call-template name="t:get-unary-expression">
      <xsl:with-param name="operator" select="'not'"/>
      <xsl:with-param name="prefix" select="true()"/>
    </xsl:call-template>
  </xsl:template>

  <!--
    Mode "t:expression-tokens". eq.
  -->
  <xsl:template mode="t:expression-tokens" match="sql:eq">
    <xsl:call-template name="t:get-binary-expression">
      <xsl:with-param name="operator" select="'='"/>
    </xsl:call-template>
  </xsl:template>

  <!--
    Mode "t:expression-tokens". ne.
  -->
  <xsl:template mode="t:expression-tokens" match="sql:ne">
    <xsl:call-template name="t:get-binary-expression">
      <xsl:with-param name="operator" select="'&lt;>'"/>
    </xsl:call-template>
  </xsl:template>

  <!--
    Mode "t:expression-tokens". lt.
  -->
  <xsl:template mode="t:expression-tokens" match="sql:lt">
    <xsl:call-template name="t:get-binary-expression">
      <xsl:with-param name="operator" select="'&lt;'"/>
    </xsl:call-template>
  </xsl:template>

  <!--
    Mode "t:expression-tokens". gt.
  -->
  <xsl:template mode="t:expression-tokens" match="sql:gt">
    <xsl:call-template name="t:get-binary-expression">
      <xsl:with-param name="operator" select="'>'"/>
    </xsl:call-template>
  </xsl:template>

  <!--
    Mode "t:expression-tokens". le.
  -->
  <xsl:template mode="t:expression-tokens" match="sql:le">
    <xsl:call-template name="t:get-binary-expression">
      <xsl:with-param name="operator" select="'&lt;='"/>
    </xsl:call-template>
  </xsl:template>

  <!--
    Mode "t:expression-tokens". ge.
  -->
  <xsl:template mode="t:expression-tokens" match="sql:ge">
    <xsl:call-template name="t:get-binary-expression">
      <xsl:with-param name="operator" select="'>='"/>
    </xsl:call-template>
  </xsl:template>

  <!--
    Mode "t:expression-tokens". like.
      $operator - an operator tokens.
  -->
  <xsl:template mode="t:expression-tokens" match="sql:like">
    <xsl:param name="operator" as="xs:string+" select="'like'"/>

    <xsl:call-template name="t:get-binary-expression">
      <xsl:with-param name="operator" select="$operator"/>
    </xsl:call-template>
  </xsl:template>

  <!--
    Mode "t:expression-tokens". not-like.
  -->
  <xsl:template mode="t:expression-tokens" match="sql:not[sql:like]">
    <xsl:apply-templates mode="t:expression-tokens" select="sql:like">
      <xsl:with-param name="operator" select="'not', ' ', 'like'"/>
    </xsl:apply-templates>
  </xsl:template>

  <!--
    Mode "t:expression-tokens". between.
      $operator - an operator tokens.
  -->
  <xsl:template mode="t:expression-tokens" match="sql:between">
    <xsl:param name="operator" as="xs:string+" select="'between'"/>

    <xsl:variable name="value" as="element()"
      select="t:get-sql-element(sql:value)"/>
    <xsl:variable name="range" as="element()+"
      select="t:get-sql-element(sql:range)"/>
    <xsl:variable name="from" as="element()" select="$range[1]"/>
    <xsl:variable name="to" as="element()" select="$range[2]"/>

    <xsl:call-template name="t:get-parenthesis-expression">
      <xsl:with-param name="expression" select="$value"/>
      <xsl:with-param name="parent" select="."/>
    </xsl:call-template>

    <xsl:sequence select="' '"/>
    <xsl:sequence select="$operator"/>
    <xsl:sequence select="' '"/>

    <xsl:call-template name="t:get-parenthesis-expression">
      <xsl:with-param name="expression" select="$from"/>
      <xsl:with-param name="parent" select="."/>
    </xsl:call-template>

    <xsl:sequence select="' '"/>
    <xsl:sequence select="'and'"/>
    <xsl:sequence select="' '"/>

    <xsl:call-template name="t:get-parenthesis-expression">
      <xsl:with-param name="expression" select="$to"/>
      <xsl:with-param name="parent" select="."/>
    </xsl:call-template>
  </xsl:template>

  <!--
    Mode "t:expression-tokens". not between.
  -->
  <xsl:template mode="t:expression-tokens" match="sql:not[sql:between]">
    <xsl:apply-templates mode="t:expression-tokens" select="sql:between">
      <xsl:with-param name="operator" select="'not', ' ', 'between'"/>
    </xsl:apply-templates>
  </xsl:template>

  <!--
    Mode "t:expression-tokens". in.
      $operator - an operator tokens.
  -->
  <xsl:template mode="t:expression-tokens" match="sql:in">
    <xsl:param name="operator" as="xs:string+" select="'in'"/>

    <xsl:variable name="value" as="element()"
      select="t:get-sql-element(sql:value)"/>
    <xsl:variable name="range" as="element()?" select="sql:range"/>
    <xsl:variable name="select" as="element()?" select="t:get-select(.)"/>

    <xsl:call-template name="t:get-parenthesis-expression">
      <xsl:with-param name="expression" select="$value"/>
      <xsl:with-param name="parent" select="."/>
    </xsl:call-template>

    <xsl:sequence select="' '"/>
    <xsl:sequence select="$operator"/>
    <xsl:sequence select="' '"/>
    <xsl:sequence select="'('"/>

    <xsl:choose>
      <xsl:when test="exists($range) and exactly-one(($range, $select))">
        <xsl:variable name="values" as="element()+"
          select="t:get-sql-element($range)"/>

        <xsl:for-each select="$values">
          <xsl:apply-templates mode="t:expression-tokens" select="."/>

          <xsl:choose>
            <xsl:when test="position() != last()">
              <xsl:sequence select="','"/>

              <xsl:if test="position() = 3">
                <xsl:sequence select="$t:indent"/>
              </xsl:if>

              <xsl:sequence select="
                if ((position() mod 3) = 0) then
                  $t:new-line
                else
                  ' '"/>
            </xsl:when>
            <xsl:when test="last() gt 3">
              <xsl:sequence select="$t:unindent"/>
            </xsl:when>
          </xsl:choose>
        </xsl:for-each>
      </xsl:when>
      <xsl:otherwise>
        <xsl:sequence select="$t:new-line"/>
        <xsl:sequence select="$t:indent"/>

        <xsl:apply-templates mode="t:statement-tokens"
          select="exactly-one($select)"/>

        <xsl:sequence select="$t:unindent"/>
        <xsl:sequence select="$t:new-line"/>
      </xsl:otherwise>
    </xsl:choose>

    <xsl:sequence select="')'"/>
   </xsl:template>

  <!--
    Mode "t:expression-tokens". not in.
  -->
  <xsl:template mode="t:expression-tokens" match="sql:not[sql:in]">
    <xsl:apply-templates mode="t:expression-tokens" select="sql:in">
      <xsl:with-param name="operator" select="'not', ' ', 'in'"/>
    </xsl:apply-templates>
  </xsl:template>

  <!--
    Mode "t:expression-tokens". exists.
      $operator - an operator tokens.
  -->
  <xsl:template mode="t:expression-tokens" match="sql:exists">
    <xsl:param name="operator" as="xs:string+" select="'exists'"/>

    <xsl:sequence select="$operator"/>
    <xsl:sequence select="$t:new-line"/>
    <xsl:sequence select="'('"/>
    <xsl:sequence select="$t:new-line"/>
    <xsl:sequence select="$t:indent"/>

    <xsl:variable name="select" as="element()" select="t:get-select(.)"/>

    <xsl:apply-templates mode="t:statement-tokens" select="$select"/>

    <xsl:sequence select="$t:unindent"/>
    <xsl:sequence select="$t:new-line"/>
    <xsl:sequence select="')'"/>
  </xsl:template>

  <!--
    Mode "t:expression-tokens". not exists.
  -->
  <xsl:template mode="t:expression-tokens" match="sql:not[sql:exists]">
    <xsl:apply-templates mode="t:expression-tokens" select="sql:exists">
      <xsl:with-param name="operator" select="'not', ' ', 'exists'"/>
    </xsl:apply-templates>
  </xsl:template>

  <!--
    Mode "t:expression-tokens". is null.
      $operator - an operator tokens.
  -->
  <xsl:template mode="t:expression-tokens" match="sql:is-null">
    <xsl:param name="operator" as="xs:string+" select="'is', ' ', 'null'"/>

    <xsl:call-template name="t:get-unary-expression">
      <xsl:with-param name="operator" select="$operator"/>
      <xsl:with-param name="prefix" select="false()"/>
    </xsl:call-template>
  </xsl:template>

  <!--
    Mode "t:expression-tokens". is not null.
  -->
  <xsl:template mode="t:expression-tokens" match="sql:not[sql:is-null]">
    <xsl:apply-templates mode="t:expression-tokens" select="sql:is-null">
      <xsl:with-param name="operator" select="'is', ' ', 'not', ' ', 'null'"/>
    </xsl:apply-templates>
  </xsl:template>
  
  <!-- Mode "t:source-ref". Default match. -->
  <xsl:template mode="t:source-ref" match="*"/>

  <!-- Mode "t:source-ref". source. -->
  <xsl:template mode="t:source-ref" match="sql:source">
    <xsl:sequence select="@alias/t:quote-name(.)"/>
  </xsl:template>

  <!-- Mode "t:source-ref". qualified source. -->
  <xsl:template mode="t:source-ref" match="sql:qualified-source">
    <xsl:call-template name="t:qualified-name"/>
  </xsl:template>

  <!-- 
    Generates an alias for a table source. 
      $source - optional source (default is a context element).
  -->
  <xsl:template name="t:source-alias">
    <xsl:param name="source" as="element()" select="."/>

    <xsl:variable name="alias" as="xs:string?" select="$source/@alias"/>
    <xsl:variable name="columns" as="element()*" select="$source/sql:column"/>
    
    <xsl:if test="$alias">
      <xsl:sequence select="' '"/>
      <xsl:sequence select="t:quote-name($alias)"/>
    </xsl:if>

    <xsl:choose>
      <xsl:when test="count($columns) gt 3">
        <xsl:sequence select="$t:new-line"/>
        <xsl:sequence select="'('"/>
        <xsl:sequence select="$t:new-line"/>
        <xsl:sequence select="$t:indent"/>

        <xsl:for-each select="$columns">
          <xsl:variable name="name" as="xs:string" select="@name"/>

          <xsl:if test="position() > 1">
            <xsl:sequence select="','"/>
            <xsl:sequence select="$t:new-line"/>
          </xsl:if>

          <xsl:sequence select="$name"/>
        </xsl:for-each>

        <xsl:sequence select="$t:new-line"/>
        <xsl:sequence select="$t:unindent"/>
        <xsl:sequence select="')'"/>
      </xsl:when>
      <xsl:when test="$columns">
        <xsl:sequence select="'('"/>

        <xsl:for-each select="$columns">
          <xsl:variable name="name" as="xs:string" select="@name"/>

          <xsl:if test="position() > 1">
            <xsl:sequence select="','"/>
            <xsl:sequence select="$t:new-line"/>
          </xsl:if>

          <xsl:sequence select="$name"/>
        </xsl:for-each>

        <xsl:sequence select="')'"/>
      </xsl:when>
    </xsl:choose>
  </xsl:template>

  <!-- Mode "t:table-source". Generates table source. -->
  <xsl:template mode="t:table-source" match="*">
    <xsl:sequence select="
      error
      (
        xs:QName('t:error'),
        concat('Invalid table source', name(), '.')
      )"/>
  </xsl:template>

  <!-- Mode "t:table-source". Generates table. -->
  <xsl:template mode="t:table-source" match="sql:table">
    <xsl:call-template name="t:qualified-name"/>
    <xsl:call-template name="t:source-alias"/>
  </xsl:template>

  <!-- Mode "t:table-source". Generates derived table. -->
  <xsl:template mode="t:table-source" match="sql:derived">
    <xsl:sequence select="'('"/>
    <xsl:sequence select="$t:new-line"/>
    <xsl:sequence select="$t:indent"/>

    <xsl:variable name="select" as="element()" select="t:get-select(.)"/>

    <xsl:apply-templates mode="t:statement-tokens" select="$select"/>

    <xsl:sequence select="$t:new-line"/>
    <xsl:sequence select="$t:unindent"/>
    <xsl:sequence select="')'"/>
    <xsl:call-template name="t:source-alias"/>
  </xsl:template>

  <xsl:template mode="t:table-source" match="sql:join">
    <xsl:call-template name="t:join">
      <xsl:with-param name="type" select="'join'"/>
    </xsl:call-template>
  </xsl:template>

  <xsl:template mode="t:table-source" match="sql:inner-join">
    <xsl:call-template name="t:join">
      <xsl:with-param name="type" select="'inner', ' ', 'join'"/>
    </xsl:call-template>
  </xsl:template>

  <xsl:template mode="t:table-source" match="sql:left-join">
    <xsl:call-template name="t:join">
      <xsl:with-param name="type" select="'left', ' ', 'join'"/>
    </xsl:call-template>
  </xsl:template>

  <xsl:template mode="t:table-source" match="sql:right-join">
    <xsl:call-template name="t:join">
      <xsl:with-param name="type" select="'right', ' ', 'join'"/>
    </xsl:call-template>
  </xsl:template>

  <xsl:template mode="t:table-source" match="sql:full-join">
    <xsl:call-template name="t:join">
      <xsl:with-param name="type" select="'full', ' ', 'join'"/>
    </xsl:call-template>
  </xsl:template>

  <xsl:template mode="t:table-source" match="sql:cross-join">
    <xsl:call-template name="t:join">
      <xsl:with-param name="type" select="'cross', ' ', 'join'"/>
      <xsl:with-param name="has-on" select="false()"/>
    </xsl:call-template>
  </xsl:template>

  <xsl:template mode="t:table-source" match="sql:cross-apply">
    <xsl:call-template name="t:join">
      <xsl:with-param name="type" select="'cross', ' ', 'apply'"/>
      <xsl:with-param name="has-on" select="false()"/>
    </xsl:call-template>
  </xsl:template>

  <xsl:template mode="t:table-source" match="sql:outer-apply">
    <xsl:call-template name="t:join">
      <xsl:with-param name="type" select="'outer', ' ', 'apply'"/>
      <xsl:with-param name="has-on" select="false()"/>
    </xsl:call-template>
  </xsl:template>

  <!-- 
    Mode "t:table-source". Generates join.
      $context - join element (defaults to the context element.)
      $type - join type tokens.
      $has-on - indicates whether on clause is required (default is true).
  -->
  <xsl:template name="t:join">
    <xsl:param name="context" as="element()" select="."/>
    <xsl:param name="type" as="item()+"/>
    <xsl:param name="has-on" as="xs:boolean" select="true()"/>

    <xsl:variable name="sources" as="element()+" 
      select="t:get-table-sources($context)"/>
    <xsl:variable name="source1" as="element()" select="$sources[1]"/>
    <xsl:variable name="source2" as="element()" select="$sources[2]"/>

    <xsl:apply-templates mode="t:table-source" select="$source1"/>
    <xsl:sequence select="$t:new-line"/>
    <xsl:sequence select="$type"/>
    <xsl:sequence select="$t:new-line"/>
    <xsl:apply-templates mode="t:table-source" select="$source2"/>

    <xsl:if test="$has-on">
      <xsl:variable name="on" as="element()" select="$context/sql:on"/>

      <xsl:sequence select="$t:new-line"/>
      <xsl:sequence select="'on'"/>
      <xsl:sequence select="$t:new-line"/>
      <xsl:sequence select="$t:indent"/>

      <xsl:variable name="expression" as="element()"
        select="t:get-sql-element($on)"/>

      <xsl:apply-templates mode="t:expression-tokens" select="$expression"/>

      <xsl:sequence select="$t:unindent"/>
    </xsl:if>
  </xsl:template>

  <!-- Mode "t:table-source". Generates derived table. -->
  <xsl:template mode="t:table-source" match="sql:function-source">
    <xsl:variable name="function" as="element()" select="sql:function"/>

    <xsl:sequence select="'table'"/>
    <xsl:sequence select="'('"/>

    <xsl:apply-templates mode="t:expression-tokens" select="$function"/>

    <xsl:sequence select="')'"/>
    <xsl:call-template name="t:source-alias"/>
  </xsl:template>

  <!--
    Gets sql type.
      $type - type element.
      Returns type tokens.
  -->
  <xsl:function name="t:get-sql-type" as="item()*">
    <xsl:param name="type" as="element()"/>

    <xsl:apply-templates mode="t:get-sql-type" select="$type"/>
  </xsl:function>

  <!-- Mode "t:get-sql-type". Get sql type. -->
  <xsl:template mode="t:get-sql-type" match="*"/>

  <!-- Mode "t:get-sql-type". Get sql type. -->
  <xsl:template mode="t:get-sql-type" match="sql:type">
    <xsl:variable name="name" as="xs:string" select="@name"/>
    <xsl:variable name="precision" as="xs:integer?" select="@precision"/>
    <xsl:variable name="scale" as="xs:integer?" select="@scale"/>

    <xsl:sequence select="$name"/>

    <xsl:if test="exists($precision)">
      <xsl:sequence select="'('"/>
      <xsl:sequence select="xs:string($precision)"/>

      <xsl:if test="exists($scale)">
        <xsl:sequence select="','"/>
        <xsl:sequence select="' '"/>
        <xsl:sequence select="xs:string($scale)"/>
      </xsl:if>

      <xsl:sequence select="')'"/>
    </xsl:if>
  </xsl:template>

  <!--
    Gets quoted name.
      $value - a name to quote.
      Returns a quoted name.
  -->
  <xsl:function name="t:quote-name" as="xs:string">
    <xsl:param name="value" as="xs:string"/>

    <xsl:apply-templates mode="t:quote-name" select="$t:quote-name-handler">
      <xsl:with-param name="value" select="$value"/>
    </xsl:apply-templates>
  </xsl:function>

  <xsl:variable name="t:quote-name-handler" as="element()">
    <t:quote-name/>
  </xsl:variable>

  <!-- Mode "t:quote-name". Gets quoted name. -->
  <xsl:template mode="t:quote-name" match="t:quote-name" as="xs:string">
    <xsl:param name="value" as="xs:string"/>

    <xsl:choose>
      <xsl:when test="
        matches($value, '^[A-Z_][A-Z0-9_]*$', 'i') and
        not($t:keywords/key('t:keyword', $value))">
        <xsl:sequence select="$value"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:sequence select="concat('&quot;', $value, '&quot;')"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
  <!-- Extensions handlers. -->
  <xsl:template match="* | text()" mode="
    t:select-header-extensions
    t:select-footer-extensions
    t:insert-header-extensions
    t:insert-values-extensions
    t:insert-footer-extensions
    t:update-header-extensions
    t:update-where-extensions
    t:update-footer-extensions
    t:delete-header-extensions
    t:delete-where-extensions
    t:delete-footer-extensions"/>

</xsl:stylesheet>