<?xml version="1.0" encoding="utf-8"?>
<!--
  This stylesheet generates basic sql.

  $Id$
-->
<xsl:stylesheet version="2.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:t="http://www.bphx.com/public/sql"
  xmlns:sql="http://www.bphx.com/basic-sql/2008-12-11"
  xmlns:db2="http://www.bphx.com/basic-sql/2008-12-11/db2"
  exclude-result-prefixes="t xs">

  <xsl:variable name="db2:keywords">
    <keyword name="ADD"/>
    <keyword name="AFTER"/>
    <keyword name="ALL"/>
    <keyword name="ALLOCATE"/>
    <keyword name="ALLOW"/>
    <keyword name="ALTER"/>
    <keyword name="AND"/>
    <keyword name="ANY"/>
    <keyword name="AS"/>

    <keyword name="ASENSITIVE"/>
    <keyword name="ASSOCIATE"/>
    <keyword name="ASUTIME"/>
    <keyword name="AT"/>
    <keyword name="AUDIT"/>
    <keyword name="AUX"/>
    <keyword name="AUXILIARY"/>

    <keyword name="BEFORE"/>
    <keyword name="BEGIN"/>
    <keyword name="BETWEEN"/>
    <keyword name="BUFFERPOOL"/>
    <keyword name="BY"/>

    <keyword name="CALL"/>
    <keyword name="CAPTURE"/>
    <keyword name="CASCADED"/>
    <keyword name="CASE"/>
    <keyword name="CAST"/>
    <keyword name="CCSID"/>
    <keyword name="CHAR"/>
    <keyword name="CHARACTER"/>
    <keyword name="CHECK"/>
    <keyword name="CLONE"/>
    <keyword name="CLOSE"/>
    <keyword name="CLUSTER"/>
    <keyword name="COLLECTION"/>
    <keyword name="COLLID"/>
    <keyword name="COLUMN"/>
    <keyword name="COMMENT"/>
    <keyword name="COMMIT"/>
    <keyword name="CONCAT"/>
    <keyword name="CONDITION"/>
    <keyword name="CONNECT"/>
    <keyword name="CONNECTION"/>
    <keyword name="CONSTRAINT"/>
    <keyword name="CONTAINS"/>
    <keyword name="CONTENT"/>
    <keyword name="CONTINUE"/>
    <keyword name="CREATE"/>
    <keyword name="CURRENT"/>
    <keyword name="CURRENT_DATE"/>
    <keyword name="CURRENT_LC_CTYPE"/>
    <keyword name="CURRENT_PATH"/>
    <keyword name="CURRENT_SCHEMA"/>
    <keyword name="CURRENT_TIME"/>
    <keyword name="CURRENT_TIMESTAMP"/>
    <keyword name="CURSOR"/>

    <keyword name="DATA"/>
    <keyword name="DATABASE"/>
    <keyword name="DAY"/>
    <keyword name="DAYS"/>
    <keyword name="DBINFO"/>
    <keyword name="DECLARE"/>
    <keyword name="DEFAULT"/>
    <keyword name="DELETE"/>
    <keyword name="DESCRIPTOR"/>
    <keyword name="DETERMINISTIC"/>
    <keyword name="DISABLE"/>
    <keyword name="DISALLOW"/>
    <keyword name="DISTINCT"/>
    <keyword name="DO"/>
    <keyword name="DOCUMENT"/>
    <keyword name="DOUBLE"/>
    <keyword name="DROP"/>
    <keyword name="DSSIZE"/>
    <keyword name="DYNAMIC"/>

    <keyword name="EDITPROC"/>
    <keyword name="ELSE"/>
    <keyword name="ELSEIF"/>
    <keyword name="ENCODING"/>
    <keyword name="ENCRYPTION"/>
    <keyword name="END"/>
    <keyword name="ENDING"/>
    <keyword name="END-EXEC2"/>
    <keyword name="ERASE"/>
    <keyword name="ESCAPE"/>
    <keyword name="EXCEPT"/>
    <keyword name="EXCEPTION"/>
    <keyword name="EXECUTE"/>
    <keyword name="EXISTS"/>
    <keyword name="EXIT"/>
    <keyword name="EXPLAIN"/>
    <keyword name="EXTERNAL"/>

    <keyword name="FENCED"/>
    <keyword name="FETCH"/>
    <keyword name="FIELDPROC"/>
    <keyword name="FINAL"/>
    <keyword name="FIRST1"/>
    <keyword name="FOR"/>
    <keyword name="FREE"/>
    <keyword name="FROM"/>
    <keyword name="FULL"/>
    <keyword name="FUNCTION"/>

    <keyword name="GENERATED"/>
    <keyword name="GET"/>
    <keyword name="GLOBAL"/>
    <keyword name="GO"/>
    <keyword name="GOTO"/>
    <keyword name="GRANT"/>
    <keyword name="GROUP"/>

    <keyword name="HANDLER"/>
    <keyword name="HAVING"/>
    <keyword name="HOLD"/>
    <keyword name="HOUR"/>
    <keyword name="HOURS"/>

    <keyword name="IF"/>
    <keyword name="IMMEDIATE"/>
    <keyword name="IN"/>
    <keyword name="INCLUSIVE"/>
    <keyword name="INDEX"/>
    <keyword name="INHERIT"/>
    <keyword name="INNER"/>
    <keyword name="INOUT"/>
    <keyword name="INSENSITIVE"/>
    <keyword name="INSERT"/>
    <keyword name="INTERSECT"/>
    <keyword name="INTO"/>
    <keyword name="IS"/>
    <keyword name="ISOBID"/>
    <keyword name="ITERATE"/>

    <keyword name="JAR"/>
    <keyword name="JOIN"/>

    <keyword name="KEEP"/>
    <keyword name="KEY"/>

    <keyword name="LABEL"/>
    <keyword name="LANGUAGE"/>
    <keyword name="LAST1"/>
    <keyword name="LC_CTYPE"/>
    <keyword name="LEAVE"/>
    <keyword name="LEFT"/>
    <keyword name="LIKE"/>
    <keyword name="LOCAL"/>
    <keyword name="LOCALE"/>
    <keyword name="LOCATOR"/>
    <keyword name="LOCATORS"/>
    <keyword name="LOCK"/>
    <keyword name="LOCKMAX"/>
    <keyword name="LOCKSIZE"/>
    <keyword name="LONG"/>
    <keyword name="LOOP"/>

    <keyword name="MAINTAINED"/>
    <keyword name="MATERIALIZED"/>
    <keyword name="MICROSECOND"/>
    <keyword name="MICROSECONDS"/>
    <keyword name="MINUTE"/>
    <keyword name="MINUTES"/>
    <keyword name="MODIFIES"/>
    <keyword name="MONTH"/>
    <keyword name="MONTHS"/>

    <keyword name="NEXT1"/>
    <keyword name="NEXTVAL"/>
    <keyword name="NO"/>
    <keyword name="NONE"/>
    <keyword name="NOT"/>
    <keyword name="NULL"/>
    <keyword name="NULLS"/>
    <keyword name="NUMPARTS"/>

    <keyword name="OBID"/>
    <keyword name="OF"/>
    <keyword name="OLD1"/>
    <keyword name="ON"/>
    <keyword name="OPEN"/>
    <keyword name="OPTIMIZATION"/>
    <keyword name="OPTIMIZE"/>
    <keyword name="OR"/>
    <keyword name="ORDER"/>
    <keyword name="ORGANIZATION1"/>
    <keyword name="OUT"/>
    <keyword name="OUTER"/>

    <keyword name="PACKAGE"/>
    <keyword name="PARAMETER"/>
    <keyword name="PART"/>
    <keyword name="PADDED"/>
    <keyword name="PARTITION"/>
    <keyword name="PARTITIONED"/>
    <keyword name="PARTITIONING"/>
    <keyword name="PATH"/>
    <keyword name="PIECESIZE"/>
    <keyword name="PERIOD1"/>
    <keyword name="PLAN"/>
    <keyword name="PRECISION"/>
    <keyword name="PREPARE"/>
    <keyword name="PREVVAL"/>
    <keyword name="PRIOR1"/>
    <keyword name="PRIQTY"/>
    <keyword name="PRIVILEGES"/>
    <keyword name="PROCEDURE"/>
    <keyword name="PROGRAM"/>
    <keyword name="PSID"/>
    <keyword name="PUBLIC"/>

    <keyword name="QUERY"/>
    <keyword name="QUERYNO"/>

    <keyword name="READS"/>
    <keyword name="REFERENCES"/>
    <keyword name="REFRESH"/>
    <keyword name="RESIGNAL"/>
    <keyword name="RELEASE"/>
    <keyword name="RENAME"/>
    <keyword name="REPEAT"/>
    <keyword name="RESTRICT"/>
    <keyword name="RESULT"/>
    <keyword name="RESULT_SET_LOCATOR"/>
    <keyword name="RETURN"/>
    <keyword name="RETURNS"/>
    <keyword name="REVOKE"/>
    <keyword name="RIGHT"/>
    <keyword name="ROLE"/>
    <keyword name="ROLLBACK"/>
    <keyword name="ROUND_CEILING"/>
    <keyword name="ROUND_DOWN"/>
    <keyword name="ROUND_FLOOR"/>
    <keyword name="ROUND_HALF_DOWN"/>
    <keyword name="ROUND_HALF_EVEN"/>
    <keyword name="ROUND_HALF_UP"/>
    <keyword name="ROUND_UP"/>
    <keyword name="ROW"/>
    <keyword name="ROWSET"/>
    <keyword name="RUN"/>

    <keyword name="SAVEPOINT"/>
    <keyword name="SCHEMA"/>
    <keyword name="SCRATCHPAD"/>
    <keyword name="SECOND"/>
    <keyword name="SECONDS"/>
    <keyword name="SECQTY"/>
    <keyword name="SECURITY"/>
    <keyword name="SEQUENCE"/>
    <keyword name="SELECT"/>
    <keyword name="SENSITIVE"/>
    <keyword name="SESSION_USER"/>
    <keyword name="SET"/>
    <keyword name="SIGNAL"/>
    <keyword name="SIMPLE"/>

    <keyword name="SOME"/>
    <keyword name="SOURCE"/>
    <keyword name="SPECIFIC"/>
    <keyword name="STANDARD"/>
    <keyword name="STATIC"/>
    <keyword name="STATEMENT"/>
    <keyword name="STAY"/>
    <keyword name="STOGROUP"/>
    <keyword name="STORES"/>
    <keyword name="STYLE"/>
    <keyword name="SUMMARY"/>
    <keyword name="SYNONYM"/>
    <keyword name="SYSFUN"/>
    <keyword name="SYSIBM"/>
    <keyword name="SYSPROC"/>
    <keyword name="SYSTEM"/>

    <keyword name="TABLE"/>
    <keyword name="TABLESPACE"/>
    <keyword name="THEN"/>
    <keyword name="TO"/>
    <keyword name="TRIGGER"/>
    <keyword name="TRUNCATE"/>
    <keyword name="TYPE"/>

    <keyword name="UNDO"/>
    <keyword name="UNION"/>
    <keyword name="UNIQUE"/>
    <keyword name="UNTIL"/>
    <keyword name="UPDATE"/>
    <keyword name="USER"/>
    <keyword name="USING"/>

    <keyword name="VALIDPROC"/>
    <keyword name="VALUE"/>
    <keyword name="VALUES"/>
    <keyword name="VARIABLE"/>
    <keyword name="VARIANT"/>
    <keyword name="VCAT"/>

    <keyword name="VIEW"/>
    <keyword name="VOLATILE"/>
    <keyword name="VOLUMES"/>

    <keyword name="WHEN"/>
    <keyword name="WHENEVER"/>
    <keyword name="WHERE"/>
    <keyword name="WHILE"/>
    <keyword name="WITH"/>
    <keyword name="WLM"/>

    <keyword name="XMLEXISTS"/>
    <keyword name="XMLNAMESPACES"/>
    <keyword name="XMLCAST"/>

    <keyword name="YEAR"/>
    <keyword name="YEARS"/>

    <keyword name="ZONE1"/>
  </xsl:variable>

  <!--
    Mode "t:get-sql-element". Gets sql element.
  -->
  <xsl:template mode="t:get-sql-element" match="db2:*">
    <xsl:sequence select="."/>
  </xsl:template>

  <!--
    Mode "t:statement-tokens". Select statement.
  -->
  <xsl:template mode="t:select-footer-extensions" match="sql:select[db2:fetch-first]" priority="2">
    <xsl:variable name="fetch-first" as="element()" select="db2:fetch-first"/>

    <xsl:variable name="rows" as="xs:integer" select="$fetch-first/@rows"/>

    <xsl:sequence select="$t:new-line"/>
    <xsl:sequence select="'fetch'"/>
    <xsl:sequence select="' '"/>
    <xsl:sequence select="'first'"/>
    <xsl:sequence select="' '"/>

    <xsl:choose>
      <xsl:when test="$rows = 1">
        <xsl:sequence select="'row'"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:sequence select="string($rows)"/>
        <xsl:sequence select="' '"/>

        <xsl:choose>
          <xsl:when test="(($rows mod 10) != 1) or (($rows mod 100) = 11)">
            <xsl:sequence select="'rows'"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:sequence select="'row'"/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:otherwise>
    </xsl:choose>

    <xsl:sequence select="' '"/>
    <xsl:sequence select="'only'"/>
  </xsl:template>

  <!--
    Mode "t:statement-tokens". Scope statement.
  -->
  <xsl:template mode="t:statement-tokens" match="db2:scope">
    <xsl:variable name="label" as="xs:string?" select="@label"/>
    <xsl:variable name="atomic" as="xs:boolean?" select="@atomic"/>
    <xsl:variable name="compound" as="xs:boolean?" select="@compound"/>
    <xsl:variable name="static" as="xs:boolean?" select="@static"/>

    <xsl:variable name="logical-scope" as="xs:boolean?" select="
      (xs:boolean(@logical-scope) = true()) and
      empty(@atomic) and
      empty($compound) and
      empty($static)"/>

    <xsl:if test="not($logical-scope)">
      <xsl:if test="exists($label)">
        <xsl:sequence select="$t:unindent"/>
        <xsl:sequence select="$label"/>
        <xsl:sequence select="':'"/>
        <xsl:sequence select="$t:indent"/>
        <xsl:sequence select="$t:new-line"/>
      </xsl:if>

      <xsl:sequence select="'begin'"/>

      <xsl:if test="$compound">
        <xsl:sequence select="' '"/>
        <xsl:sequence select="'compound'"/>
      </xsl:if>

      <xsl:choose>
        <xsl:when test="$atomic = true()">
          <xsl:sequence select="' '"/>
          <xsl:sequence select="'atomic'"/>
        </xsl:when>
        <xsl:when test="$atomic = false()">
          <xsl:sequence select="' '"/>
          <xsl:sequence select="'not'"/>
          <xsl:sequence select="' '"/>
          <xsl:sequence select="'atomic'"/>
        </xsl:when>
      </xsl:choose>

      <xsl:if test="$static">
        <xsl:sequence select="' '"/>
        <xsl:sequence select="'static'"/>
      </xsl:if>

      <xsl:sequence select="$t:new-line"/>
      <xsl:sequence select="$t:indent"/>
    </xsl:if>

    <xsl:variable name="statements" as="element()+"
      select="t:get-sql-element(.)"/>

    <xsl:for-each select="$statements">
      <xsl:apply-templates mode="t:statement-tokens" select="."/>
      <xsl:sequence select="';'"/>
      <xsl:sequence select="$t:new-line"/>

      <xsl:if test="position() != last()">
        <xsl:sequence select="$t:new-line"/>
      </xsl:if>
    </xsl:for-each>

    <xsl:if test="not($logical-scope)">
      <xsl:sequence select="$t:unindent"/>
      <xsl:sequence select="'end'"/>
    </xsl:if>

    <xsl:if test="$compound">
      <xsl:sequence select="' '"/>
      <xsl:sequence select="'compound'"/>
    </xsl:if>
  </xsl:template>

  <!--
    Mode "t:statement-tokens". If statement.
      $nested-if - true if nested if, and false otherwise.
  -->
  <xsl:template mode="t:statement-tokens" match="db2:if">
    <xsl:param name="nested-if" as="xs:boolean" select="false()"/>

    <xsl:variable name="condition" as="element()" select="db2:condition"/>
    <xsl:variable name="then" as="element()" select="db2:then"/>
    <xsl:variable name="else" as="element()?" select="db2:else"/>
    <xsl:variable name="expression" as="element()"
      select="t:get-sql-element($condition)"/>

    <xsl:sequence select="
      if ($nested-if) then
        'elseif'
      else
        'if'"/>

    <xsl:sequence select="' '"/>

    <xsl:variable name="expression-tokens" as="item()*">
      <xsl:apply-templates mode="t:expression-tokens" select="$expression"/>
    </xsl:variable>

    <xsl:variable name="multiline" as="xs:boolean"
      select="t:is-multiline($expression-tokens)"/>

    <xsl:sequence select="
      if ($multiline) then
        ($t:new-line, '(', $t:new-line, $t:indent)
      else
        (' ', '(')"/>

    <xsl:sequence select="$expression-tokens"/>

    <xsl:sequence select="
      if ($multiline) then
        ($t:unindent, $t:new-line, ')', $t:new-line)
      else
        (')', ' ')"/>

    <xsl:sequence select="'then'"/>
    <xsl:sequence select="$t:new-line"/>
    <xsl:sequence select="$t:indent"/>

    <xsl:variable name="then-statements" as="element()+"
      select="t:get-sql-element($then)"/>

    <xsl:for-each select="$then-statements">
      <xsl:apply-templates mode="t:statement-tokens" select="."/>
      <xsl:sequence select="';'"/>
      <xsl:sequence select="$t:new-line"/>

      <xsl:if test="position() != last()">
        <xsl:sequence select="$t:new-line"/>
      </xsl:if>
    </xsl:for-each>

    <xsl:sequence select="$t:unindent"/>

    <xsl:if test="exists($else)">
      <xsl:variable name="else-statements" as="element()+"
        select="t:get-sql-element($else)"/>

      <xsl:choose>
        <xsl:when test="
         (count($else-statements) = 1) and
         exists($else-statements[self::db2:if])">

          <xsl:apply-templates mode="t:statement-tokens"
            select="$else-statements">
            <xsl:with-param name="nested-if" select="true()"/>
          </xsl:apply-templates>
        </xsl:when>
        <xsl:otherwise>
          <xsl:sequence select="'else'"/>
          <xsl:sequence select="$t:new-line"/>
          <xsl:sequence select="$t:indent"/>

          <xsl:for-each select="$else-statements">
            <xsl:apply-templates mode="t:statement-tokens" select="."/>
            <xsl:sequence select="';'"/>
            <xsl:sequence select="$t:new-line"/>

            <xsl:if test="position() != last()">
              <xsl:sequence select="$t:new-line"/>
            </xsl:if>
          </xsl:for-each>

          <xsl:sequence select="$t:unindent"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:if>

    <xsl:if test="not($nested-if)">
      <xsl:sequence select="'end'"/>
      <xsl:sequence select="' '"/>
      <xsl:sequence select="'if'"/>
    </xsl:if>
  </xsl:template>

  <!--
    Mode "t:statement-tokens". While statement.
  -->
  <xsl:template mode="t:statement-tokens" match="db2:while">
    <xsl:variable name="label" as="xs:string?" select="@label"/>
    <xsl:variable name="condition" as="element()" select="db2:condition"/>
    <xsl:variable name="body" as="element()" select="db2:body"/>
    <xsl:variable name="expression" as="element()"
      select="t:get-sql-element($condition)"/>
    <xsl:variable name="statements" as="element()+"
      select="t:get-sql-element($body)"/>

    <xsl:if test="exists($label)">
      <xsl:sequence select="$t:unindent"/>
      <xsl:sequence select="$label"/>
      <xsl:sequence select="':'"/>
      <xsl:sequence select="$t:indent"/>
      <xsl:sequence select="$t:new-line"/>
    </xsl:if>

    <xsl:sequence select="'while'"/>
    <xsl:sequence select="' '"/>

    <xsl:apply-templates mode="t:expression-tokens" select="$expression"/>

    <xsl:sequence select="' '"/>
    <xsl:sequence select="'do'"/>
    <xsl:sequence select="$t:new-line"/>
    <xsl:sequence select="$t:indent"/>

    <xsl:for-each select="$statements">
      <xsl:apply-templates mode="t:statement-tokens" select="."/>
      <xsl:sequence select="';'"/>
      <xsl:sequence select="$t:new-line"/>

      <xsl:if test="position() != last()">
        <xsl:sequence select="$t:new-line"/>
      </xsl:if>
    </xsl:for-each>

    <xsl:sequence select="$t:unindent"/>

    <xsl:sequence select="'end'"/>
    <xsl:sequence select="' '"/>
    <xsl:sequence select="'while'"/>
  </xsl:template>

  <!--
    Mode "t:statement-tokens". For statement.
  -->
  <xsl:template mode="t:statement-tokens" match="db2:for">
    <xsl:variable name="label" as="xs:string?" select="@label"/>
    <xsl:variable name="name" as="xs:string" select="@name"/>
    <xsl:variable name="body" as="element()" select="db2:body"/>
    <xsl:variable name="select" as="element()" select="t:get-select(.)"/>
    <xsl:variable name="statements" as="element()+"
      select="t:get-sql-element($body)"/>

    <xsl:if test="exists($label)">
      <xsl:sequence select="$t:unindent"/>
      <xsl:sequence select="$label"/>
      <xsl:sequence select="':'"/>
      <xsl:sequence select="$t:indent"/>
      <xsl:sequence select="$t:new-line"/>
    </xsl:if>

    <xsl:sequence select="'for'"/>
    <xsl:sequence select="' '"/>
    <xsl:sequence select="$name"/>
    <xsl:sequence select="' '"/>
    <xsl:sequence select="'as'"/>
    <xsl:sequence select="$t:new-line"/>
    <xsl:sequence select="$t:indent"/>

    <xsl:apply-templates mode="t:statement-tokens" select="$select"/>

    <xsl:sequence select="$t:unindent"/>
    <xsl:sequence select="$t:new-line"/>
    <xsl:sequence select="'do'"/>
    <xsl:sequence select="$t:new-line"/>
    <xsl:sequence select="$t:indent"/>

    <xsl:for-each select="$statements">
      <xsl:apply-templates mode="t:statement-tokens" select="."/>
      <xsl:sequence select="';'"/>
      <xsl:sequence select="$t:new-line"/>

      <xsl:if test="position() != last()">
        <xsl:sequence select="$t:new-line"/>
      </xsl:if>
    </xsl:for-each>

    <xsl:sequence select="$t:unindent"/>

    <xsl:sequence select="'end'"/>
    <xsl:sequence select="' '"/>
    <xsl:sequence select="'for'"/>
  </xsl:template>

  <!--
    Mode "t:statement-tokens". Signal statement.
  -->
  <xsl:template mode="t:statement-tokens" match="db2:signal">
    <xsl:variable name="sqlstate" as="element()"
      select="t:get-sql-element(db2:sqlstate)"/>
    <xsl:variable name="message" as="element()?"
      select="t:get-sql-element(db2:message)"/>

    <xsl:sequence select="'signal'"/>
    <xsl:sequence select="' '"/>
    <xsl:sequence select="'sqlstate'"/>
    <xsl:sequence select="' '"/>

    <xsl:apply-templates mode="t:expression-tokens" select="$sqlstate"/>

    <xsl:if test="$message">
      <xsl:sequence select="$t:new-line"/>
      <xsl:sequence select="'set'"/>
      <xsl:sequence select="' '"/>
      <xsl:sequence select="'message_text'"/>
      <xsl:sequence select="' '"/>
      <xsl:sequence select="'='"/>
      <xsl:sequence select="' '"/>

      <xsl:apply-templates mode="t:expression-tokens" select="$message"/>
    </xsl:if>
  </xsl:template>

  <!--
    Mode "t:statement-tokens". Goto statement.
  -->
  <xsl:template mode="t:statement-tokens" match="db2:goto">
    <xsl:variable name="label" as="xs:string" select="@destination-label"/>

    <xsl:sequence select="'goto'"/>
    <xsl:sequence select="' '"/>
    <xsl:sequence select="$label"/>
  </xsl:template>

  <!--
    Mode "t:statement-tokens". Leave statement.
  -->
  <xsl:template mode="t:statement-tokens" match="db2:leave">
    <xsl:variable name="label" as="xs:string" select="@destination-label"/>

    <xsl:sequence select="'leave'"/>
    <xsl:sequence select="' '"/>
    <xsl:sequence select="$label"/>
  </xsl:template>

  <!--
    Mode "t:statement-tokens". declare-var statement.
  -->
  <xsl:template mode="t:statement-tokens" match="db2:declare-var">
    <xsl:variable name="name" as="xs:string" select="@name"/>
    <xsl:variable name="type" as="element()" select="sql:type"/>
    <xsl:variable name="default" as="element()?" select="sql:default"/>

    <xsl:sequence select="'declare'"/>
    <xsl:sequence select="' '"/>
    <xsl:sequence select="$name"/>
    <xsl:sequence select="' '"/>

    <xsl:sequence select="t:get-sql-type($type)"/>

    <xsl:if test="exists($default)">
      <xsl:variable name="expression" as="element()"
        select="t:get-sql-element($default)"/>

      <xsl:sequence select="' '"/>
      <xsl:sequence select="'default'"/>
      <xsl:sequence select="' '"/>

      <xsl:apply-templates mode="t:expression-tokens" select="$expression"/>
    </xsl:if>
  </xsl:template>

  <!--
    Mode "t:statement-tokens". set-var statement.
  -->
  <xsl:template mode="t:statement-tokens" match="db2:set-var">
    <xsl:variable name="name" as="xs:string" select="@name"/>
    <xsl:variable name="expression" as="element()"
      select="t:get-sql-element(.)"/>

    <xsl:sequence select="'set'"/>
    <xsl:sequence select="' '"/>
    <xsl:sequence select="$name"/>
    <xsl:sequence select="' '"/>
    <xsl:sequence select="'='"/>
    <xsl:sequence select="' '"/>

    <xsl:apply-templates mode="t:expression-tokens" select="$expression"/>
  </xsl:template>

  <!--
    Mode "t:statement-tokens". get-diagnostics statement.
  -->
  <xsl:template mode="t:statement-tokens" match="db2:get-diagnostics">
    <xsl:variable name="name" as="xs:string" select="@name"/>

    <xsl:sequence select="'get'"/>
    <xsl:sequence select="' '"/>
    <xsl:sequence select="'diagnostics'"/>
    <xsl:sequence select="' '"/>
    <xsl:sequence select="$name"/>
    <xsl:sequence select="' '"/>
    <xsl:sequence select="'='"/>
    <xsl:sequence select="' '"/>
    <xsl:sequence select="'row_count'"/>
  </xsl:template>

  <!--
    Mode "t:statement-tokens". declare-cursor statement.
  -->
  <xsl:template mode="t:statement-tokens" match="db2:declare-cursor">
    <xsl:variable name="name" as="xs:string" select="@name"/>
    <xsl:variable name="with-return" as="xs:boolean?" select="@with-return"/>
    <xsl:variable name="select" as="element()" select="t:get-select(.)"/>

    <xsl:sequence select="'declare'"/>
    <xsl:sequence select="' '"/>
    <xsl:sequence select="$name"/>
    <xsl:sequence select="' '"/>
    <xsl:sequence select="'cursor'"/>

    <xsl:if test="$with-return">
      <xsl:sequence select="' '"/>
      <xsl:sequence select="'with'"/>
      <xsl:sequence select="' '"/>
      <xsl:sequence select="'return'"/>
    </xsl:if>

    <xsl:sequence select="' '"/>
    <xsl:sequence select="'for'"/>
    <xsl:sequence select="$t:new-line"/>

    <xsl:apply-templates mode="t:statement-tokens" select="$select"/>
  </xsl:template>

  <!--
    Mode "t:statement-tokens". open statement.
  -->
  <xsl:template mode="t:statement-tokens" match="db2:open">
    <xsl:variable name="name" as="xs:string" select="@name"/>

    <xsl:sequence select="'open'"/>
    <xsl:sequence select="' '"/>
    <xsl:sequence select="$name"/>
  </xsl:template>

  <!--
    Mode "t:statement-tokens". close statement.
  -->
  <xsl:template mode="t:statement-tokens" match="db2:close">
    <xsl:variable name="name" as="xs:string" select="@name"/>

    <xsl:sequence select="'close'"/>
    <xsl:sequence select="' '"/>
    <xsl:sequence select="$name"/>
  </xsl:template>

  <!--
    Mode "t:statement-tokens". fetch statement.
  -->
  <xsl:template mode="t:statement-tokens" match="db2:fetch">
    <xsl:variable name="name" as="xs:string" select="@name"/>
    <xsl:variable name="into" as="element()" select="sql:into"/>

    <xsl:sequence select="'fetch'"/>
    <xsl:sequence select="' '"/>
    <xsl:sequence select="'from'"/>
    <xsl:sequence select="' '"/>
    <xsl:sequence select="$name"/>

    <xsl:call-template name="t:generate-into-clause">
      <xsl:with-param name="into" select="$into"/>
    </xsl:call-template>
  </xsl:template>

  <!--
    Mode "t:statement-tokens". create-procedure statement.
  -->
  <xsl:template mode="t:statement-tokens" match="db2:create-procedure">
    <xsl:variable name="name" as="xs:string" select="@name"/>
    <xsl:variable name="called-on-null-input" as="xs:boolean?"
      select="@called-on-null-input"/>
    <xsl:variable name="result-sets" as="xs:integer?" select="@result-sets"/>
    <xsl:variable name="parameter" as="element()*" select="db2:parameter"/>
    <xsl:variable name="scope" as="element()" select="db2:scope"/>

    <xsl:apply-templates mode="#current" select="sql:comment"/>

    <xsl:sequence select="'create'"/>
    <xsl:sequence select="' '"/>
    <xsl:sequence select="'procedure'"/>
    <xsl:sequence select="' '"/>
    <xsl:sequence select="$name"/>

    <xsl:if test="exists($parameter)">
      <xsl:sequence select="$t:new-line"/>
      <xsl:sequence select="'('"/>
      <xsl:sequence select="$t:new-line"/>
      <xsl:sequence select="$t:indent"/>

      <xsl:for-each select="$parameter">
        <xsl:variable name="parameter-name" as="xs:string" select="@name"/>
        <xsl:variable name="parameter-direction" as="xs:string?"
          select="@direction"/>
        <xsl:variable name="parameter-type" as="element()" select="sql:type"/>

        <xsl:apply-templates mode="#current" select="sql:comment"/>

        <xsl:if test="exists($parameter-direction)">
          <xsl:choose>
            <xsl:when test="$parameter-direction = 'in'">
              <xsl:sequence select="'in'"/>
            </xsl:when>
            <xsl:when test="$parameter-direction = 'out'">
              <xsl:sequence select="'out'"/>
            </xsl:when>
            <xsl:when test="$parameter-direction = 'in-out'">
              <xsl:sequence select="'inout'"/>
            </xsl:when>
            <xsl:otherwise>
              <xsl:sequence select="
                error
                (
                  xs:QName('t:error'),
                  concat
                  (
                    'Invalid parameter direction ',
                    $parameter-direction,
                    '.'
                  )
                )"/>
            </xsl:otherwise>
          </xsl:choose>

          <xsl:sequence select="' '"/>
        </xsl:if>

        <xsl:sequence select="$parameter-name"/>
        <xsl:sequence select="' '"/>
        <xsl:sequence select="t:get-sql-type($parameter-type)"/>

        <xsl:if test="position() lt last()">
          <xsl:sequence select="','"/>
          <xsl:sequence select="$t:new-line"/>
        </xsl:if>
      </xsl:for-each>

      <xsl:sequence select="$t:new-line"/>
      <xsl:sequence select="$t:unindent"/>
      <xsl:sequence select="')'"/>
    </xsl:if>

    <xsl:if test="$result-sets > 0">
      <xsl:sequence select="$t:new-line"/>
      <xsl:sequence select="$t:indent"/>

      <xsl:sequence select="'dynamic'"/>
      <xsl:sequence select="' '"/>
      <xsl:sequence select="'result'"/>
      <xsl:sequence select="' '"/>
      <xsl:sequence select="'sets'"/>
      <xsl:sequence select="' '"/>
      <xsl:sequence select="xs:string($result-sets)"/>

      <xsl:sequence select="$t:unindent"/>
    </xsl:if>

    <xsl:if test="not($called-on-null-input = false())">
      <xsl:sequence select="$t:new-line"/>
      <xsl:sequence select="$t:indent"/>

      <xsl:sequence select="'called'"/>
      <xsl:sequence select="' '"/>
      <xsl:sequence select="'on'"/>
      <xsl:sequence select="' '"/>
      <xsl:sequence select="'null'"/>
      <xsl:sequence select="' '"/>
      <xsl:sequence select="'input'"/>

      <xsl:sequence select="$t:unindent"/>
    </xsl:if>

    <xsl:sequence select="$t:new-line"/>
    <xsl:sequence select="$t:indent"/>

    <xsl:sequence select="'language'"/>
    <xsl:sequence select="' '"/>
    <xsl:sequence select="'sql'"/>

    <xsl:sequence select="$t:new-line"/>
    <xsl:sequence select="$t:unindent"/>

    <xsl:apply-templates mode="#current" select="$scope"/>
    <xsl:sequence select="$t:new-line"/>
  </xsl:template>

  <!--
    Mode "t:statement-tokens". call statement.
  -->
  <xsl:template mode="t:statement-tokens" match="db2:call">
    <xsl:variable name="name" as="xs:string" select="@name"/>
    <xsl:variable name="arguments" as="element()*"
      select="t:get-sql-element(.)"/>

    <xsl:apply-templates mode="#current" select="sql:comment"/>

    <xsl:sequence select="'call'"/>
    <xsl:sequence select="' '"/>
    <xsl:sequence select="$name"/>

    <xsl:if test="exists($arguments)">
      <xsl:choose>
        <xsl:when test="empty($arguments[not(self::sql:host-expression)])">
          <xsl:sequence select="'('"/>

          <xsl:for-each select="$arguments">
            <xsl:sequence select="."/>

            <xsl:if test="position() lt last()">
              <xsl:sequence select="','"/>
              <xsl:sequence select="' '"/>
            </xsl:if>
          </xsl:for-each>

          <xsl:sequence select="')'"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:sequence select="$t:new-line"/>
          <xsl:sequence select="'('"/>
          <xsl:sequence select="$t:new-line"/>
          <xsl:sequence select="$t:indent"/>

          <xsl:for-each select="$arguments">
            <xsl:apply-templates mode="t:expression-tokens" select="."/>

            <xsl:if test="position() lt last()">
              <xsl:sequence select="','"/>
              <xsl:sequence select="$t:new-line"/>
            </xsl:if>
          </xsl:for-each>

          <xsl:sequence select="$t:new-line"/>
          <xsl:sequence select="$t:unindent"/>
          <xsl:sequence select="')'"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:if>
  </xsl:template>

  <!--
    Mode "t:expression-tokens". days.
  -->
  <xsl:template mode="t:expression-tokens" match="db2:days">
    <xsl:call-template name="t:get-unary-expression">
      <xsl:with-param name="operator" select="'days'"/>
      <xsl:with-param name="prefix" select="false()"/>
    </xsl:call-template>
  </xsl:template>

  <!--
    Mode "t:expression-tokens". months.
  -->
  <xsl:template mode="t:expression-tokens" match="db2:months">
    <xsl:call-template name="t:get-unary-expression">
      <xsl:with-param name="operator" select="'months'"/>
      <xsl:with-param name="prefix" select="false()"/>
    </xsl:call-template>
  </xsl:template>

  <!--
    Mode "t:expression-tokens". years.
  -->
  <xsl:template mode="t:expression-tokens" match="db2:years">
    <xsl:call-template name="t:get-unary-expression">
      <xsl:with-param name="operator" select="'years'"/>
      <xsl:with-param name="prefix" select="false()"/>
    </xsl:call-template>
  </xsl:template>

  <!--
    Mode "t:expression-tokens". hours.
  -->
  <xsl:template mode="t:expression-tokens" match="db2:hours">
    <xsl:call-template name="t:get-unary-expression">
      <xsl:with-param name="operator" select="'hours'"/>
      <xsl:with-param name="prefix" select="false()"/>
    </xsl:call-template>
  </xsl:template>

  <!--
    Mode "t:expression-tokens". minutes.
  -->
  <xsl:template mode="t:expression-tokens" match="db2:minutes">
    <xsl:call-template name="t:get-unary-expression">
      <xsl:with-param name="operator" select="'minutes'"/>
      <xsl:with-param name="prefix" select="false()"/>
    </xsl:call-template>
  </xsl:template>

  <!--
    Mode "t:expression-tokens". seconds.
  -->
  <xsl:template mode="t:expression-tokens" match="db2:seconds">
    <xsl:call-template name="t:get-unary-expression">
      <xsl:with-param name="operator" select="'seconds'"/>
      <xsl:with-param name="prefix" select="false()"/>
    </xsl:call-template>
  </xsl:template>

  <!--
    Mode "t:expression-tokens". microseconds.
  -->
  <xsl:template mode="t:expression-tokens" match="db2:microseconds">
    <xsl:call-template name="t:get-unary-expression">
      <xsl:with-param name="operator" select="'microseconds'"/>
      <xsl:with-param name="prefix" select="false()"/>
    </xsl:call-template>
  </xsl:template>

  <!--
    Mode "t:expression-tokens". simple-case.
  -->
  <xsl:template mode="t:expression-tokens" match="db2:simple-case">
    <xsl:variable name="value" as="element()"
      select="t:get-sql-element(db2:value)"/>

    <xsl:sequence select="'case'"/>
    <xsl:sequence select="' '"/>

    <xsl:apply-templates mode="t:expression-tokens" select="$value"/>

    <xsl:sequence select="$t:indent"/>

    <xsl:variable name="when" as="element()+" select="db2:when"/>

    <xsl:for-each select="$when">
      <xsl:variable name="arguments" as="element()+"
        select="t:get-sql-element(.)"/>
      <xsl:variable name="test" as="element()" select="$arguments[1]"/>
      <xsl:variable name="result" as="element()" select="$arguments[2]"/>

      <xsl:sequence select="$t:new-line"/>
      <xsl:sequence select="'when'"/>
      <xsl:sequence select="' '"/>

      <xsl:apply-templates mode="t:expression-tokens" select="$test"/>

      <xsl:sequence select="' '"/>
      <xsl:sequence select="'then'"/>
      <xsl:sequence select="' '"/>

      <xsl:apply-templates mode="t:expression-tokens" select="$result"/>
    </xsl:for-each>

    <xsl:variable name="else" as="element()?" select="else"/>

    <xsl:if test="exists($else)">
      <xsl:variable name="result" as="element()"
        select="t:get-sql-element(.)"/>

      <xsl:sequence select="$t:new-line"/>
      <xsl:sequence select="'else'"/>
      <xsl:sequence select="' '"/>

      <xsl:apply-templates mode="t:expression-tokens" select="$result"/>
    </xsl:if>

    <xsl:sequence select="$t:unindent"/>
    <xsl:sequence select="$t:new-line"/>
    <xsl:sequence select="'end'"/>
    <xsl:sequence select="' '"/>
    <xsl:sequence select="'case'"/>
  </xsl:template>

  <!--
    Mode "t:expression-tokens". search-case.
  -->
  <xsl:template mode="t:expression-tokens" match="db2:search-case">
    <xsl:sequence select="'case'"/>
    <xsl:sequence select="$t:indent"/>

    <xsl:variable name="when" as="element()+" select="db2:when"/>

    <xsl:for-each select="$when">
      <xsl:variable name="arguments" as="element()+"
        select="t:get-sql-element(.)"/>
      <xsl:variable name="test" as="element()" select="$arguments[1]"/>
      <xsl:variable name="result" as="element()" select="$arguments[2]"/>

      <xsl:sequence select="$t:new-line"/>
      <xsl:sequence select="'when'"/>
      <xsl:sequence select="' '"/>

      <xsl:apply-templates mode="t:expression-tokens" select="$test"/>

      <xsl:sequence select="' '"/>
      <xsl:sequence select="'then'"/>
      <xsl:sequence select="' '"/>

      <xsl:apply-templates mode="t:expression-tokens" select="$result"/>
    </xsl:for-each>

    <xsl:variable name="else" as="element()?" select="else"/>

    <xsl:if test="exists($else)">
      <xsl:variable name="result" as="element()"
        select="t:get-sql-element(.)"/>

      <xsl:sequence select="$t:new-line"/>
      <xsl:sequence select="'else'"/>
      <xsl:sequence select="' '"/>

      <xsl:apply-templates mode="t:expression-tokens" select="$result"/>
    </xsl:if>

    <xsl:sequence select="$t:unindent"/>
    <xsl:sequence select="$t:new-line"/>
    <xsl:sequence select="'end'"/>
    <xsl:sequence select="' '"/>
    <xsl:sequence select="'case'"/>
  </xsl:template>

  <!--
    Mode "t:expression-tokens". string.
  -->
  <xsl:template mode="t:expression-tokens" match="sql:string[xs:boolean(@binary)]">
    <xsl:variable name="value" as="xs:string" select="@value"/>

    <xsl:sequence select="concat('X''', $value, '''')"/>
  </xsl:template>

  <!--
    Mode "t:expression-tokens". function.
  -->
  <xsl:template mode="t:expression-tokens"
    match="sql:function[@name = 'concat']">

    <xsl:variable name="arguments" as="element()+"
      select="t:get-sql-element(.)"/>

    <xsl:apply-templates mode="t:expression-tokens" select="$arguments[1]"/>

    <xsl:sequence select="' '"/>
    <xsl:sequence select="'||'"/>
    <xsl:sequence select="' '"/>

    <xsl:apply-templates mode="t:expression-tokens" select="$arguments[2]"/>
  </xsl:template>

  <!-- Mode "t:get-sql-type". Get sql type. -->
  <xsl:template mode="t:get-sql-type" match="sql:type" priority="2">
    <xsl:next-match/>

    <xsl:variable name="for" as="xs:string?" select="@for"/>

    <xsl:if test="(@name = ('varchar', 'char')) and exists($for)">
      <xsl:sequence select="' '"/>
      <xsl:sequence select="'for'"/>
      <xsl:sequence select="' '"/>

      <xsl:sequence select="
        if ($for = 'bit-data') then
          'bit'
        else if ($for = 'sbcs-data') then
          'sbcs'
        else if ($for = 'mixed-data') then
          'mixed'
        else 
          error
          (
            xs:QName('t:error'),
            concat('Invalid for type ', $for, '.')
          )"/>

      <xsl:sequence select="' '"/>
      <xsl:sequence select="'data'"/>
    </xsl:if>
  </xsl:template>

  <!-- Collects keywords. -->
  <xsl:template mode="t:collect-keywords" match="t:keywords">
    <xsl:sequence select="$db2:keywords"/>
  </xsl:template>

</xsl:stylesheet>