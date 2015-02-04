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
  xmlns:oracle="http://www.bphx.com/basic-sql/2008-12-11/oracle"
  exclude-result-prefixes="t xs">

  <xsl:variable name="oracle:keywords">
    <keyword name="ACCESS"/>
    <keyword name="ELSE"/>
    <keyword name="MODIFY"/>
    <keyword name="START"/>
    <keyword name="ADD"/>
    <keyword name="EXCLUSIVE"/>
    <keyword name="NOAUDIT"/>
    <keyword name="SELECT"/>
    <keyword name="ALL"/>
    <keyword name="EXISTS"/>
    <keyword name="NOCOMPRESS"/>
    <keyword name="SESSION"/>
    <keyword name="ALTER"/>
    <keyword name="FILE"/>
    <keyword name="NOT"/>
    <keyword name="SET"/>
    <keyword name="AND"/>
    <keyword name="FLOAT"/>
    <keyword name="NOTFOUND"/>
    <keyword name="SHARE"/>
    <keyword name="ANY"/>
    <keyword name="FOR"/>
    <keyword name="NOWAIT"/>
    <keyword name="SIZE"/>
    <keyword name="ARRAYLEN"/>
    <keyword name="FROM"/>
    <keyword name="NULL"/>
    <keyword name="SMALLINT"/>
    <keyword name="AS"/>
    <keyword name="GRANT"/>
    <keyword name="NUMBER"/>
    <keyword name="SQLBUF"/>
    <keyword name="ASC"/>
    <keyword name="GROUP"/>
    <keyword name="OF"/>
    <keyword name="SUCCESSFUL"/>
    <keyword name="AUDIT"/>
    <keyword name="HAVING"/>
    <keyword name="OFFLINE"/>
    <keyword name="SYNONYM"/>
    <keyword name="BETWEEN"/>
    <keyword name="IDENTIFIED"/>
    <keyword name="ON"/>
    <keyword name="SYSDATE"/>
    <keyword name="BY"/>
    <keyword name="IMMEDIATE"/>
    <keyword name="ONLINE"/>
    <keyword name="TABLE"/>
    <keyword name="CHAR"/>
    <keyword name="IN"/>
    <keyword name="OPTION"/>
    <keyword name="THEN"/>
    <keyword name="CHECK"/>
    <keyword name="INCREMENT"/>
    <keyword name="OR"/>
    <keyword name="TO"/>
    <keyword name="CLUSTER"/>
    <keyword name="INDEX"/>
    <keyword name="ORDER"/>
    <keyword name="TRIGGER"/>
    <keyword name="COLUMN"/>
    <keyword name="INITIAL"/>
    <keyword name="PCTFREE"/>
    <keyword name="UID"/>
    <keyword name="COMMENT"/>
    <keyword name="INSERT"/>
    <keyword name="PRIOR"/>
    <keyword name="UNION"/>
    <keyword name="COMPRESS"/>
    <keyword name="INTEGER"/>
    <keyword name="PRIVILEGES"/>
    <keyword name="UNIQUE"/>
    <keyword name="CONNECT"/>
    <keyword name="INTERSECT"/>
    <keyword name="PUBLIC"/>
    <keyword name="UPDATE"/>
    <keyword name="CREATE"/>
    <keyword name="INTO"/>
    <keyword name="RAW"/>
    <keyword name="USER"/>
    <keyword name="CURRENT"/>
    <keyword name="IS"/>
    <keyword name="RENAME"/>
    <keyword name="VALIDATE"/>
    <keyword name="DATE"/>
    <keyword name="LEVEL"/>
    <keyword name="RESOURCE"/>
    <keyword name="VALUES"/>
    <keyword name="DECIMAL"/>
    <keyword name="LIKE"/>
    <keyword name="REVOKE"/>
    <keyword name="VARCHAR"/>
    <keyword name="DEFAULT"/>
    <keyword name="LOCK"/>
    <keyword name="ROW"/>
    <keyword name="VARCHAR2"/>
    <keyword name="DELETE"/>
    <keyword name="LONG"/>
    <keyword name="ROWID"/>
    <keyword name="VIEW"/>
    <keyword name="DESC"/>
    <keyword name="MAXEXTENTS"/>
    <keyword name="ROWLABEL"/>
    <keyword name="WHENEVER"/>
    <keyword name="DISTINCT"/>
    <keyword name="MINUS"/>
    <keyword name="ROWNUM"/>
    <keyword name="WHERE"/>
    <keyword name="DROP"/>
    <keyword name="MODE"/>
    <keyword name="ROWS"/>
    <keyword name="WITH"/>

    <keyword name="ADMIN"/>
    <keyword name="CURSOR"/>
    <keyword name="FOUND"/>
    <keyword name="MOUNT"/>
    <keyword name="AFTER"/>
    <keyword name="CYCLE"/>
    <keyword name="FUNCTION"/>
    <keyword name="NEXT"/>
    <keyword name="ALLOCATE"/>
    <keyword name="DATABASE"/>
    <keyword name="GO"/>
    <keyword name="NEW"/>
    <keyword name="ANALYZE"/>
    <keyword name="DATAFILE"/>
    <keyword name="GOTO"/>
    <keyword name="NOARCHIVELOG"/>
    <keyword name="ARCHIVE"/>
    <keyword name="DBA"/>
    <keyword name="GROUPS"/>
    <keyword name="NOCACHE"/>
    <keyword name="ARCHIVELOG"/>
    <keyword name="DEC"/>
    <keyword name="INCLUDING"/>
    <keyword name="NOCYCLE"/>
    <keyword name="AUTHORIZATION"/>
    <keyword name="DECLARE"/>
    <keyword name="INDICATOR"/>
    <keyword name="NOMAXVALUE"/>
    <keyword name="AVG"/>
    <keyword name="DISABLE"/>
    <keyword name="INITRANS"/>
    <keyword name="NOMINVALUE"/>
    <keyword name="BACKUP"/>
    <keyword name="DISMOUNT"/>
    <keyword name="INSTANCE"/>
    <keyword name="NONE"/>
    <keyword name="BEGIN"/>
    <keyword name="DOUBLE"/>
    <keyword name="INT"/>
    <keyword name="NOORDER"/>
    <keyword name="BECOME"/>
    <keyword name="DUMP"/>
    <keyword name="KEY"/>
    <keyword name="NORESETLOGS"/>
    <keyword name="BEFORE"/>
    <keyword name="EACH"/>
    <keyword name="LANGUAGE"/>
    <keyword name="NORMAL"/>
    <keyword name="BLOCK"/>
    <keyword name="ENABLE"/>
    <keyword name="LAYER"/>
    <keyword name="NOSORT"/>
    <keyword name="BODY"/>
    <keyword name="END"/>
    <keyword name="LINK"/>
    <keyword name="NUMERIC"/>
    <keyword name="CACHE"/>
    <keyword name="ESCAPE"/>
    <keyword name="LISTS"/>
    <keyword name="OFF"/>
    <keyword name="CANCEL"/>
    <keyword name="EVENTS"/>
    <keyword name="LOGFILE"/>
    <keyword name="OLD"/>
    <keyword name="CASCADE"/>
    <keyword name="EXCEPT"/>
    <keyword name="MANAGE"/>
    <keyword name="ONLY"/>
    <keyword name="CHANGE"/>
    <keyword name="EXCEPTIONS"/>
    <keyword name="MANUAL"/>
    <keyword name="OPEN"/>
    <keyword name="CHARACTER"/>
    <keyword name="EXEC"/>
    <keyword name="MAX"/>
    <keyword name="OPTIMAL"/>
    <keyword name="CHECKPOINT"/>
    <keyword name="EXPLAIN"/>
    <keyword name="MAXDATAFILES"/>
    <keyword name="OWN"/>
    <keyword name="CLOSE"/>
    <keyword name="EXECUTE"/>
    <keyword name="MAXINSTANCES"/>
    <keyword name="PACKAGE"/>
    <keyword name="COBOL"/>
    <keyword name="EXTENT"/>
    <keyword name="MAXLOGFILES"/>
    <keyword name="PARALLEL"/>
    <keyword name="COMMIT"/>
    <keyword name="EXTERNALLY"/>
    <keyword name="MAXLOGHISTORY"/>
    <keyword name="PCTINCREASE"/>
    <keyword name="COMPILE"/>
    <keyword name="FETCH"/>
    <keyword name="MAXLOGMEMBERS"/>
    <keyword name="PCTUSED"/>
    <keyword name="CONSTRAINT"/>
    <keyword name="FLUSH"/>
    <keyword name="MAXTRANS"/>
    <keyword name="PLAN"/>
    <keyword name="CONSTRAINTS"/>
    <keyword name="FREELIST"/>
    <keyword name="MAXVALUE"/>
    <keyword name="PLI"/>
    <keyword name="CONTENTS"/>
    <keyword name="FREELISTS"/>
    <keyword name="MIN"/>
    <keyword name="PRECISION"/>
    <keyword name="CONTINUE"/>
    <keyword name="FORCE"/>
    <keyword name="MINEXTENTS"/>
    <keyword name="PRIMARY"/>
    <keyword name="CONTROLFILE"/>
    <keyword name="FOREIGN"/>
    <keyword name="MINVALUE"/>
    <keyword name="PRIVATE"/>
    <keyword name="COUNT"/>
    <keyword name="FORTRAN"/>
    <keyword name="MODULE"/>
    <keyword name="PROCEDURE"/>
    <keyword name="PROFILE"/>
    <keyword name="SAVEPOINT"/>
    <keyword name="SQLSTATE"/>
    <keyword name="TRACING"/>
    <keyword name="QUOTA"/>
    <keyword name="SCHEMA"/>
    <keyword name="STATEMENT_ID"/>
    <keyword name="TRANSACTION"/>
    <keyword name="READ"/>
    <keyword name="SCN"/>
    <keyword name="STATISTICS"/>
    <keyword name="TRIGGERS"/>
    <keyword name="REAL"/>
    <keyword name="SECTION"/>
    <keyword name="STOP"/>
    <keyword name="TRUNCATE"/>
    <keyword name="RECOVER"/>
    <keyword name="SEGMENT"/>
    <keyword name="STORAGE"/>
    <keyword name="UNDER"/>
    <keyword name="REFERENCES"/>
    <keyword name="SEQUENCE"/>
    <keyword name="SUM"/>
    <keyword name="UNLIMITED"/>
    <keyword name="REFERENCING"/>
    <keyword name="SHARED"/>
    <keyword name="SWITCH"/>
    <keyword name="UNTIL"/>
    <keyword name="RESETLOGS"/>
    <keyword name="SNAPSHOT"/>
    <keyword name="SYSTEM"/>
    <keyword name="USE"/>
    <keyword name="RESTRICTED"/>
    <keyword name="SOME"/>
    <keyword name="TABLES"/>
    <keyword name="USING"/>
    <keyword name="REUSE"/>
    <keyword name="SORT"/>
    <keyword name="TABLESPACE"/>
    <keyword name="WHEN"/>
    <keyword name="ROLE"/>
    <keyword name="SQL"/>
    <keyword name="TEMPORARY"/>
    <keyword name="WRITE"/>
    <keyword name="ROLES"/>
    <keyword name="SQLCODE"/>
    <keyword name="THREAD"/>
    <keyword name="WORK"/>
    <keyword name="ROLLBACK"/>
    <keyword name="SQLERROR"/>
    <keyword name="TIME"/>

    <keyword name="ABORT"/>
    <keyword name="BETWEEN"/>
    <keyword name="CRASH"/>
    <keyword name="DIGITS"/>
    <keyword name="ACCEPT"/>
    <keyword name="BINARY_INTEGER"/>
    <keyword name="CREATE"/>
    <keyword name="DISPOSE"/>
    <keyword name="ACCESS"/>
    <keyword name="BODY"/>
    <keyword name="CURRENT"/>
    <keyword name="DISTINCT"/>
    <keyword name="ADD"/>
    <keyword name="BOOLEAN"/>
    <keyword name="CURRVAL"/>
    <keyword name="DO"/>
    <keyword name="ALL"/>
    <keyword name="BY"/>
    <keyword name="CURSOR"/>
    <keyword name="DROP"/>
    <keyword name="ALTER"/>
    <keyword name="CASE"/>
    <keyword name="DATABASE"/>
    <keyword name="ELSE"/>
    <keyword name="AND"/>
    <keyword name="CHAR"/>
    <keyword name="DATA_BASE"/>
    <keyword name="ELSIF"/>
    <keyword name="ANY"/>
    <keyword name="CHAR_BASE"/>
    <keyword name="DATE"/>
    <keyword name="END"/>
    <keyword name="ARRAY"/>
    <keyword name="CHECK"/>
    <keyword name="DBA"/>
    <keyword name="ENTRY"/>
    <keyword name="ARRAYLEN"/>
    <keyword name="CLOSE"/>
    <keyword name="DEBUGOFF"/>
    <keyword name="EXCEPTION"/>
    <keyword name="AS"/>
    <keyword name="CLUSTER"/>
    <keyword name="DEBUGON"/>
    <keyword name="EXCEPTION_INIT"/>
    <keyword name="ASC"/>
    <keyword name="CLUSTERS"/>
    <keyword name="DECLARE"/>
    <keyword name="EXISTS"/>
    <keyword name="ASSERT"/>
    <keyword name="COLAUTH"/>
    <keyword name="DECIMAL"/>
    <keyword name="EXIT"/>
    <keyword name="ASSIGN"/>
    <keyword name="COLUMNS"/>
    <keyword name="DEFAULT"/>
    <keyword name="FALSE"/>
    <keyword name="AT"/>
    <keyword name="COMMIT"/>
    <keyword name="DEFINITION"/>
    <keyword name="FETCH"/>
    <keyword name="AUTHORIZATION"/>
    <keyword name="COMPRESS"/>
    <keyword name="DELAY"/>
    <keyword name="FLOAT"/>
    <keyword name="AVG"/>
    <keyword name="CONNECT"/>
    <keyword name="DELETE"/>
    <keyword name="FOR"/>
    <keyword name="BASE_TABLE"/>
    <keyword name="CONSTANT"/>
    <keyword name="DELTA"/>
    <keyword name="FORM"/>
    <keyword name="BEGIN"/>
    <keyword name="COUNT"/>
    <keyword name="DESC"/>
    <keyword name="FROM"/>
    <keyword name="FUNCTION"/>
    <keyword name="NEW"/>
    <keyword name="RELEASE"/>
    <keyword name="SUM"/>
    <keyword name="GENERIC"/>
    <keyword name="NEXTVAL"/>
    <keyword name="REMR"/>
    <keyword name="TABAUTH"/>
    <keyword name="GOTO"/>
    <keyword name="NOCOMPRESS"/>
    <keyword name="RENAME"/>
    <keyword name="TABLE"/>
    <keyword name="GRANT"/>
    <keyword name="NOT"/>
    <keyword name="RESOURCE"/>
    <keyword name="TABLES"/>
    <keyword name="GROUP"/>
    <keyword name="NULL"/>
    <keyword name="RETURN"/>
    <keyword name="TASK"/>
    <keyword name="HAVING"/>
    <keyword name="NUMBER"/>
    <keyword name="REVERSE"/>
    <keyword name="TERMINATE"/>
    <keyword name="IDENTIFIED"/>
    <keyword name="NUMBER_BASE"/>
    <keyword name="REVOKE"/>
    <keyword name="THEN"/>
    <keyword name="IF"/>
    <keyword name="OF"/>
    <keyword name="ROLLBACK"/>
    <keyword name="TO"/>
    <keyword name="IN"/>
    <keyword name="ON"/>
    <keyword name="ROWID"/>
    <keyword name="TRUE"/>
    <keyword name="INDEX"/>
    <keyword name="OPEN"/>
    <keyword name="ROWLABEL"/>
    <keyword name="TYPE"/>
    <keyword name="INDEXES"/>
    <keyword name="OPTION"/>
    <keyword name="ROWNUM"/>
    <keyword name="UNION"/>
    <keyword name="INDICATOR"/>
    <keyword name="OR"/>
    <keyword name="ROWTYPE"/>
    <keyword name="UNIQUE"/>
    <keyword name="INSERT"/>
    <keyword name="ORDER"/>
    <keyword name="RUN"/>
    <keyword name="UPDATE"/>
    <keyword name="INTEGER"/>
    <keyword name="OTHERS"/>
    <keyword name="SAVEPOINT"/>
    <keyword name="USE"/>
    <keyword name="INTERSECT"/>
    <keyword name="OUT"/>
    <keyword name="SCHEMA"/>
    <keyword name="VALUES"/>
    <keyword name="INTO"/>
    <keyword name="PACKAGE"/>
    <keyword name="SELECT"/>
    <keyword name="VARCHAR"/>
    <keyword name="IS"/>
    <keyword name="PARTITION"/>
    <keyword name="SEPARATE"/>
    <keyword name="VARCHAR2"/>
    <keyword name="LEVEL"/>
    <keyword name="PCTFREE"/>
    <keyword name="SET"/>
    <keyword name="VARIANCE"/>
    <keyword name="LIKE"/>
    <keyword name="POSITIVE"/>
    <keyword name="SIZE"/>
    <keyword name="VIEW"/>
    <keyword name="LIMITED"/>
    <keyword name="PRAGMA"/>
    <keyword name="SMALLINT"/>
    <keyword name="VIEWS"/>
    <keyword name="LOOP"/>
    <keyword name="PRIOR"/>
    <keyword name="SPACE"/>
    <keyword name="WHEN"/>
    <keyword name="MAX"/>
    <keyword name="PRIVATE"/>
    <keyword name="SQL"/>
    <keyword name="WHERE"/>
    <keyword name="MIN"/>
    <keyword name="PROCEDURE"/>
    <keyword name="SQLCODE"/>
    <keyword name="WHILE"/>
    <keyword name="MINUS"/>
    <keyword name="PUBLIC"/>
    <keyword name="SQLERRM"/>
    <keyword name="WITH"/>
    <keyword name="MLSLABEL"/>
    <keyword name="RAISE"/>
    <keyword name="START"/>
    <keyword name="WORK"/>
    <keyword name="MOD"/>
    <keyword name="RANGE"/>
    <keyword name="STATEMENT"/>
    <keyword name="XOR"/>
    <keyword name="MODE"/>
    <keyword name="REAL"/>
    <keyword name="STDDEV"/>

    <keyword name="NATURAL"/>
    <keyword name="RECORD"/>
    <keyword name="SUBTYPE"/>
  </xsl:variable>

  <!--
    Mode "t:get-sql-element". Gets sql element.
  -->
  <xsl:template mode="t:get-sql-element" match="oracle:*">
    <xsl:sequence select="."/>
  </xsl:template>

  <!-- Generates statement label. -->
  <xsl:template name="t:generate-label">
    <xsl:variable name="label" as="xs:string?" select="@label"/>

    <xsl:apply-templates mode="#current" select="sql:comment"/>

    <xsl:if test="exists($label)">
      <xsl:sequence select="$t:unindent"/>
      <xsl:sequence select="concat('&lt;&lt;', $label, '>>')"/>
      <xsl:sequence select="$t:indent"/>
      <xsl:sequence select="$t:new-line"/>
    </xsl:if>
  </xsl:template>

  <!--
    Mode "t:statement-tokens". null-statement.
  -->
  <xsl:template mode="t:statement-tokens" match="oracle:null-statement">
    <xsl:call-template name="t:generate-label"/>

    <xsl:sequence select="'null'"/>
  </xsl:template>

  <!--
    Mode "t:statement-tokens". block.
  -->
  <xsl:template mode="t:statement-tokens" match="oracle:block">
    <xsl:variable name="declare" as="element()*"
      select="t:get-block-declarations(.)"/>
    <xsl:variable name="exception" as="element()*" select="oracle:exception"/>
    <xsl:variable name="autonomous" as="xs:boolean?" select="@autonomous"/>
    <xsl:variable name="statements" as="element()+"
      select="t:get-sql-element(.) except ($declare, $exception)"/>

    <xsl:call-template name="t:generate-label"/>

    <xsl:if test="exists($declare)">
      <xsl:sequence select="'declare'"/>
      <xsl:sequence select="$t:new-line"/>
      <xsl:sequence select="$t:indent"/>

      <xsl:if test="$autonomous">
        <xsl:sequence select="'pragma'"/>
        <xsl:sequence select="' '"/>
        <xsl:sequence select="'autonomous_transaction'"/>
        <xsl:sequence select="';'"/>
        <xsl:sequence select="$t:new-line"/>
      </xsl:if>

      <xsl:apply-templates mode="#current" select="$declare"/>

      <xsl:sequence select="$t:unindent"/>
    </xsl:if>

    <xsl:sequence select="'begin'"/>
    <xsl:sequence select="$t:new-line"/>
    <xsl:sequence select="$t:indent"/>

    <xsl:for-each select="$statements">
      <xsl:variable name="tokens" as="item()*">
        <xsl:apply-templates mode="#current" select="."/>
      </xsl:variable>

      <xsl:variable name="last" as="item()?" select="$tokens[last()]"/>

      <xsl:sequence select="$tokens"/>

      <xsl:if
        test="empty($last) or empty(index-of((';', $t:new-line), $last))">
        <xsl:sequence select="';'"/>
        <xsl:sequence select="$t:new-line"/>
      </xsl:if>

      <xsl:if test="position() != last()">
        <xsl:sequence select="$t:new-line"/>
      </xsl:if>
    </xsl:for-each>

    <xsl:sequence select="$t:unindent"/>

    <xsl:if test="exists($exception)">
      <xsl:sequence select="'exception'"/>
      <xsl:sequence select="$t:new-line"/>
      <xsl:sequence select="$t:indent"/>

      <xsl:for-each select="$exception">
        <xsl:variable name="types" as="xs:string*"
          select="tokenize(@types, '\s+')"/>
        <xsl:variable name="handler" as="element()+"
          select="t:get-sql-element(.)"/>

        <xsl:sequence select="'when'"/>
        <xsl:sequence select="' '"/>

        <xsl:choose>
          <xsl:when test="empty($types)">
            <xsl:sequence select="'others'"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:sequence select="string-join($types, ' or ')"/>
          </xsl:otherwise>
        </xsl:choose>

        <xsl:sequence select="' '"/>
        <xsl:sequence select="'then'"/>
        <xsl:sequence select="$t:new-line"/>

        <xsl:variable name="is-block" as="xs:boolean"
          select="$handler[self::oracle:block] and (count($handler) = 1)"/>

        <xsl:if test="not($is-block)">
          <xsl:sequence select="$t:indent"/>
        </xsl:if>

        <xsl:for-each select="$handler">
          <xsl:apply-templates mode="#current" select="."/>

          <xsl:sequence select="';'"/>
          <xsl:sequence select="$t:new-line"/>

          <xsl:if test="position() != last()">
            <xsl:sequence select="$t:new-line"/>
          </xsl:if>
        </xsl:for-each>

        <xsl:if test="not($is-block)">
          <xsl:sequence select="$t:unindent"/>
        </xsl:if>
      </xsl:for-each>

      <xsl:sequence select="$t:unindent"/>
    </xsl:if>

    <xsl:sequence select="'end'"/>
    <xsl:sequence select="';'"/>
  </xsl:template>

  <!--
    Gets block declarations.
      $block - a block element.
      Returns block declarations.
  -->
  <xsl:function name="t:get-block-declarations" as="element()*">
    <xsl:param name="block" as="element()"/>

    <xsl:apply-templates mode="t:get-block-declarations" select="$block/*"/>
  </xsl:function>

  <!-- Mode "t:get-block-declarations". Gets block declarations. -->
  <xsl:template mode="t:get-block-declarations" match="*"/>

  <!-- Mode "t:get-block-declarations". Gets block declarations. -->
  <xsl:template mode="t:get-block-declarations" match="
    oracle:declare-var | oracle:declare-cursor | oracle:declare-exception">
    <xsl:sequence select="."/>
  </xsl:template>

  <!--
    Mode "t:statement-tokens". declare-var.
  -->
  <xsl:template mode="t:statement-tokens" match="oracle:declare-var">
    <xsl:variable name="name" as="xs:string" select="@name"/>
    <xsl:variable name="not-null" as="xs:boolean?" select="@not-null"/>
    <xsl:variable name="type" as="element()" select="sql:type"/>
    <xsl:variable name="default" as="element()?" select="oracle:default"/>

    <xsl:sequence select="$name"/>
    <xsl:sequence select="' '"/>
    <xsl:sequence select="t:get-sql-type($type)"/>

    <xsl:if test="$not-null">
      <xsl:sequence select="' '"/>
      <xsl:sequence select="'not'"/>
      <xsl:sequence select="' '"/>
      <xsl:sequence select="'null'"/>
    </xsl:if>

    <xsl:if test="exists($default)">
      <xsl:sequence select="' '"/>
      <xsl:sequence select="':='"/>
      <xsl:sequence select="' '"/>

      <xsl:variable name="expression" as="element()"
        select="t:get-sql-element($default)"/>

      <xsl:apply-templates mode="t:expression-tokens" select="$expression"/>
    </xsl:if>

    <xsl:sequence select="';'"/>
    <xsl:sequence select="$t:new-line"/>
  </xsl:template>

  <!--
    Mode "t:statement-tokens". declare-cursor.
  -->
  <xsl:template mode="t:statement-tokens" match="oracle:declare-cursor">
    <xsl:variable name="cursor-name" as="xs:string" select="@name"/>
    <xsl:variable name="parameter" as="element()*" select="oracle:parameter"/>
    <xsl:variable name="select" as="element()" select="t:get-select(.)"/>

    <xsl:sequence select="'cursor'"/>
    <xsl:sequence select="' '"/>
    <xsl:sequence select="$cursor-name"/>
    <xsl:sequence select="' '"/>

    <xsl:if test="exists($parameter)">
      <xsl:sequence select="$t:new-line"/>
      <xsl:sequence select="'('"/>
      <xsl:sequence select="$t:new-line"/>
      <xsl:sequence select="$t:indent"/>

      <xsl:for-each select="$parameter">
        <xsl:variable name="name" as="xs:string" select="@name"/>
        <xsl:variable name="not-null" as="xs:boolean?" select="@not-null"/>
        <xsl:variable name="type" as="element()" select="sql:type"/>
        <xsl:variable name="default" as="element()?" select="oracle:default"/>

        <xsl:sequence select="$name"/>
        <xsl:sequence select="' '"/>
        <xsl:sequence select="t:get-sql-type($type)"/>

        <xsl:if test="$not-null">
          <xsl:sequence select="' '"/>
          <xsl:sequence select="'not'"/>
          <xsl:sequence select="' '"/>
          <xsl:sequence select="'null'"/>
        </xsl:if>

        <xsl:if test="exists($default)">
          <xsl:sequence select="' '"/>
          <xsl:sequence select="':='"/>
          <xsl:sequence select="' '"/>

          <xsl:variable name="expression" as="element()"
            select="t:get-sql-element($default)"/>

          <xsl:apply-templates mode="t:expression-tokens" select="$expression"/>
        </xsl:if>

        <xsl:if test="position() != last()">
          <xsl:sequence select="','"/>
        </xsl:if>

        <xsl:sequence select="$t:new-line"/>
      </xsl:for-each>

      <xsl:sequence select="$t:unindent"/>
      <xsl:sequence select="')'"/>
      <xsl:sequence select="$t:new-line"/>
    </xsl:if>

    <xsl:sequence select="' '"/>
    <xsl:sequence select="'is'"/>
    <xsl:sequence select="$t:new-line"/>
    <xsl:sequence select="$t:indent"/>

    <xsl:apply-templates mode="t:statement-tokens" select="$select"/>

    <xsl:sequence select="$t:unindent"/>
    <xsl:sequence select="';'"/>
    <xsl:sequence select="$t:new-line"/>
  </xsl:template>

  <!--
    Mode "t:statement-tokens". declare-exception.
  -->
  <xsl:template mode="t:statement-tokens" match="oracle:declare-exception">
    <xsl:variable name="name" as="xs:string" select="@name"/>

    <xsl:sequence select="$name"/>
    <xsl:sequence select="' '"/>
    <xsl:sequence select="'exception'"/>
    <xsl:sequence select="';'"/>
    <xsl:sequence select="$t:new-line"/>
  </xsl:template>

  <!--
    Mode "t:statement-tokens". If statement.
      $nested-if - true if nested if, and false otherwise.
  -->
  <xsl:template mode="t:statement-tokens" match="oracle:if">
    <xsl:param name="nested-if" as="xs:boolean" select="false()"/>

    <xsl:variable name="condition" as="element()" select="oracle:condition"/>
    <xsl:variable name="then" as="element()" select="oracle:then"/>
    <xsl:variable name="else" as="element()?" select="oracle:else"/>
    <xsl:variable name="expression" as="element()"
      select="t:get-sql-element($condition)"/>

    <xsl:call-template name="t:generate-label"/>

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

    <xsl:variable name="then-statements" as="element()+"
      select="t:get-sql-element($then)"/>

    <xsl:sequence select="'then'"/>
    <xsl:sequence select="$t:new-line"/>
    <xsl:sequence select="$t:indent"/>

    <xsl:for-each select="$then-statements">
      <xsl:apply-templates mode="#current" select="."/>

      <xsl:sequence select="';'"/>
      <xsl:sequence select="$t:new-line"/>
    </xsl:for-each>

    <xsl:sequence select="$t:unindent"/>

    <xsl:if test="exists($else)">
      <xsl:variable name="else-statements" as="element()+"
        select="t:get-sql-element($else)"/>

      <xsl:variable name="is-else-if" as="xs:boolean" select="
        $else-statements[self::oracle:if[not(@label)]] and
        (count($else-statements) = 1)"/>

      <xsl:choose>
        <xsl:when test="$is-else-if">
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
  <xsl:template mode="t:statement-tokens" match="oracle:while">
    <xsl:variable name="condition" as="element()" select="oracle:condition"/>
    <xsl:variable name="body" as="element()" select="oracle:body"/>
    <xsl:variable name="expression" as="element()"
      select="t:get-sql-element($condition)"/>
    <xsl:variable name="statements" as="element()+"
      select="t:get-sql-element($body)"/>
    <xsl:variable name="is-block" as="xs:boolean"
      select="$statements[self::oracle:block] and (count($statements) = 1)"/>

    <xsl:call-template name="t:generate-label"/>

    <xsl:sequence select="'while'"/>
    <xsl:sequence select="' '"/>

    <xsl:apply-templates mode="t:expression-tokens" select="$expression"/>

    <xsl:sequence select="' '"/>
    <xsl:sequence select="'loop'"/>
    <xsl:sequence select="$t:new-line"/>

    <xsl:if test="not($is-block)">
      <xsl:sequence select="$t:indent"/>
    </xsl:if>

    <xsl:for-each select="$statements">
      <xsl:apply-templates mode="#current" select="."/>

      <xsl:sequence select="';'"/>
      <xsl:sequence select="$t:new-line"/>
    </xsl:for-each>

    <xsl:if test="not($is-block)">
      <xsl:sequence select="$t:unindent"/>
    </xsl:if>

    <xsl:sequence select="'end'"/>
    <xsl:sequence select="' '"/>
    <xsl:sequence select="'loop'"/>
  </xsl:template>

  <!--
    Mode "t:statement-tokens". For statement.
  -->
  <xsl:template mode="t:statement-tokens" match="oracle:for">
    <xsl:variable name="name" as="xs:string" select="@name"/>
    <xsl:variable name="cursor" as="element()" select="oracle:cursor"/>
    <xsl:variable name="body" as="element()" select="oracle:body"/>
    <xsl:variable name="statements" as="element()+"
      select="t:get-sql-element($body)"/>
    <xsl:variable name="is-block" as="xs:boolean"
      select="$statements[self::oracle:block] and (count($statements) = 1)"/>

    <xsl:variable name="cursor-name" as="xs:string" select="$cursor/@name"/>
    <xsl:variable name="cursor-arguments" as="element()*"
      select="t:get-sql-element($cursor)"/>

    <xsl:call-template name="t:generate-label"/>

    <xsl:sequence select="'for'"/>
    <xsl:sequence select="' '"/>
    <xsl:sequence select="$name"/>
    <xsl:sequence select="' '"/>
    <xsl:sequence select="'in'"/>
    <xsl:sequence select="' '"/>

    <xsl:sequence select="$cursor-name"/>

    <xsl:if test="exists($cursor-arguments)">
      <xsl:sequence select="'('"/>

      <xsl:for-each select="$cursor-arguments">
        <xsl:apply-templates mode="t:expression-tokens" select="."/>

        <xsl:if test="position() != last()">
          <xsl:sequence select="','"/>
          <xsl:sequence select="' '"/>
        </xsl:if>
      </xsl:for-each>

      <xsl:sequence select="')'"/>
    </xsl:if>

    <xsl:sequence select="' '"/>
    <xsl:sequence select="'loop'"/>
    <xsl:sequence select="$t:new-line"/>

    <xsl:if test="not($is-block)">
      <xsl:sequence select="$t:indent"/>
    </xsl:if>

    <xsl:for-each select="$statements">
      <xsl:apply-templates mode="#current" select="."/>

      <xsl:sequence select="';'"/>
      <xsl:sequence select="$t:new-line"/>
    </xsl:for-each>

    <xsl:if test="not($is-block)">
      <xsl:sequence select="$t:unindent"/>
    </xsl:if>

    <xsl:sequence select="'end '"/>
    <xsl:sequence select="' '"/>
    <xsl:sequence select="'loop'"/>
  </xsl:template>

  <!--
    Mode "t:statement-tokens". goto statement.
  -->
  <xsl:template mode="t:statement-tokens" match="oracle:goto">
    <xsl:variable name="label" as="xs:string" select="@destination-label"/>

    <xsl:call-template name="t:generate-label"/>

    <xsl:sequence select="'goto'"/>
    <xsl:sequence select="' '"/>
    <xsl:sequence select="$label"/>
  </xsl:template>

  <!--
    Mode "t:statement-tokens". exit statement.
  -->
  <xsl:template mode="t:statement-tokens" match="oracle:exit">
    <xsl:variable name="label" as="xs:string?" select="@destination-label"/>

    <xsl:call-template name="t:generate-label"/>

    <xsl:sequence select="'exit'"/>

    <xsl:if test="exists($label)">
      <xsl:sequence select="' '"/>
      <xsl:sequence select="$label"/>
    </xsl:if>
  </xsl:template>

  <!--
    Mode "t:statement-tokens". continue statement.
  -->
  <xsl:template mode="t:statement-tokens" match="oracle:continue">
    <xsl:variable name="label" as="xs:string?" select="@destination-label"/>

    <xsl:call-template name="t:generate-label"/>

    <xsl:sequence select="'continue'"/>

    <xsl:if test="exists($label)">
      <xsl:sequence select="' '"/>
      <xsl:sequence select="$label"/>
    </xsl:if>
  </xsl:template>

  <!--
    Mode "t:statement-tokens". return statement.
  -->
  <xsl:template mode="t:statement-tokens" match="oracle:return">
    <xsl:variable name="expression" as="element()?"
      select="t:get-sql-element(.)"/>

    <xsl:call-template name="t:generate-label"/>

    <xsl:sequence select="'return'"/>

    <xsl:if test="exists($expression)">
      <xsl:sequence select="' '"/>

      <xsl:apply-templates mode="t:expression-tokens" select="$expression"/>
    </xsl:if>
  </xsl:template>

  <!--
    Mode "t:statement-tokens". set-var statement.
  -->
  <xsl:template mode="t:statement-tokens" match="oracle:set-var">
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
    Mode "t:statement-tokens". open statement.
  -->
  <xsl:template mode="t:statement-tokens" match="oracle:open">
    <xsl:variable name="name" as="xs:string" select="@name"/>
    <xsl:variable name="arguments" as="element()*"
      select="t:get-sql-element(.)"/>

    <xsl:call-template name="t:generate-label"/>

    <xsl:sequence select="'open'"/>
    <xsl:sequence select="' '"/>
    <xsl:sequence select="$name"/>

    <xsl:if test="exists($arguments)">
      <xsl:sequence select="'('"/>

      <xsl:for-each select="$arguments">
        <xsl:apply-templates mode="t:expression-tokens" select="."/>

        <xsl:if test="position() != last()">
          <xsl:sequence select="','"/>
          <xsl:sequence select="' '"/>
        </xsl:if>
      </xsl:for-each>

      <xsl:sequence select="')'"/>
    </xsl:if>
  </xsl:template>

  <!--
    Mode "t:statement-tokens". close statement.
  -->
  <xsl:template mode="t:statement-tokens" match="oracle:close">
    <xsl:variable name="name" as="xs:string" select="@name"/>

    <xsl:call-template name="t:generate-label"/>

    <xsl:sequence select="'close'"/>
    <xsl:sequence select="' '"/>
    <xsl:sequence select="$name"/>
  </xsl:template>

  <!--
    Mode "t:statement-tokens". fetch statement.
  -->
  <xsl:template mode="t:statement-tokens" match="oracle:fetch">
    <xsl:variable name="name" as="xs:string" select="@name"/>
    <xsl:variable name="into" as="element()" select="sql:into"/>

    <xsl:call-template name="t:generate-label"/>

    <xsl:sequence select="'fetch'"/>
    <xsl:sequence select="' '"/>
    <xsl:sequence select="$name"/>

    <xsl:call-template name="t:generate-into-clause">
      <xsl:with-param name="into" select="$into"/>
    </xsl:call-template>
  </xsl:template>

  <!--
    Mode "t:statement-tokens". savepoint statement.
  -->
  <xsl:template mode="t:statement-tokens" match="oracle:savepoint">
    <xsl:variable name="name" as="xs:string" select="@name"/>

    <xsl:call-template name="t:generate-label"/>

    <xsl:sequence select="'savepoint'"/>
    <xsl:sequence select="' '"/>
    <xsl:sequence select="$name"/>
  </xsl:template>

  <!--
    Mode "t:statement-tokens". commit statement.
  -->
  <xsl:template mode="t:statement-tokens" match="oracle:commit">
    <xsl:variable name="name" as="xs:string" select="@name"/>

    <xsl:call-template name="t:generate-label"/>

    <xsl:sequence select="'commit'"/>
  </xsl:template>

  <!--
    Mode "t:statement-tokens". rollback statement.
  -->
  <xsl:template mode="t:statement-tokens" match="oracle:rollback">
    <xsl:variable name="name" as="xs:string?" select="@name"/>

    <xsl:call-template name="t:generate-label"/>

    <xsl:sequence select="'rollback'"/>

    <xsl:if test="exists($name)">
      <xsl:sequence select="' '"/>
      <xsl:sequence select="'to'"/>
      <xsl:sequence select="' '"/>
      <xsl:sequence select="$name"/>
    </xsl:if>
  </xsl:template>

  <!--
    Mode "t:statement-tokens". raise statement.
  -->
  <xsl:template mode="t:statement-tokens" match="oracle:raise">
    <xsl:variable name="name" as="xs:string?" select="@name"/>

    <xsl:call-template name="t:generate-label"/>

    <xsl:sequence select="'raise'"/>

    <xsl:if test="exists($name)">
      <xsl:sequence select="' '"/>
      <xsl:sequence select="$name"/>
    </xsl:if>
  </xsl:template>

  <!--
    Mode "t:statement-tokens". create-procedure statement.
  -->
  <xsl:template mode="t:statement-tokens" match="oracle:create-procedure">
    <xsl:variable name="name" as="xs:string" select="@name"/>
    <xsl:variable name="parameter" as="element()*" select="oracle:parameter"/>
    <xsl:variable name="block" as="element()" select="oracle:block"/>

    <xsl:apply-templates mode="#current" select="sql:comment"/>

    <xsl:sequence select="'create'"/>
    <xsl:sequence select="' '"/>
    <xsl:sequence select="'or'"/>
    <xsl:sequence select="' '"/>
    <xsl:sequence select="'replace'"/>
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

    <xsl:sequence select="' '"/>
    <xsl:sequence select="'as'"/>

    <xsl:sequence select="$t:new-line"/>

    <xsl:apply-templates mode="#current" select="$block"/>

    <xsl:sequence select="$t:new-line"/>
    <xsl:sequence select="';'"/>
  </xsl:template>

  <!--
    Mode "t:statement-tokens". create-function statement.
  -->
  <xsl:template mode="t:statement-tokens" match="oracle:create-function">
    <xsl:variable name="name" as="xs:string" select="@name"/>
    <xsl:variable name="parameter" as="element()?" select="oracle:parameter"/>
    <xsl:variable name="return" as="element()" select="oracle:return"/>
    <xsl:variable name="block" as="element()" select="oracle:block"/>

    <xsl:apply-templates mode="#current" select="sql:comment"/>

    <xsl:sequence select="'create'"/>
    <xsl:sequence select="' '"/>
    <xsl:sequence select="'or'"/>
    <xsl:sequence select="' '"/>
    <xsl:sequence select="'replace'"/>
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

    <xsl:sequence select="' '"/>
    <xsl:sequence select="'return'"/>
    <xsl:sequence select="' '"/>

    <xsl:variable name="return-type" as="element()"
      select="$return/sql:type"/>

    <xsl:sequence select="t:get-sql-type($return-type)"/>

    <xsl:sequence select="' '"/>
    <xsl:sequence select="'as'"/>

    <xsl:sequence select="$t:new-line"/>

    <xsl:apply-templates mode="#current" select="$block"/>

    <xsl:sequence select="$t:new-line"/>
    <xsl:sequence select="';'"/>
  </xsl:template>


  <!--
    Mode "t:statement-tokens". call statement.
  -->
  <xsl:template mode="t:statement-tokens" match="oracle:call">
    <xsl:variable name="name" as="xs:string" select="@name"/>
    <xsl:variable name="arguments" as="element()?"
      select="t:get-sql-element(.)"/>

    <xsl:sequence select="$name"/>
    <xsl:sequence select="'('"/>

    <xsl:choose>
      <xsl:when test="empty($arguments[not(self::sql:host-expression)])">
        <xsl:for-each select="$arguments">
          <xsl:sequence select="."/>

          <xsl:if test="position() lt last()">
            <xsl:sequence select="','"/>
            <xsl:sequence select="' '"/>
          </xsl:if>
        </xsl:for-each>
      </xsl:when>
      <xsl:otherwise>
        <xsl:sequence select="$t:new-line"/>
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
      </xsl:otherwise>
    </xsl:choose>

    <xsl:sequence select="')'"/>
  </xsl:template>

  <!--
    Mode "t:expression-tokens". false.
  -->
  <xsl:template mode="t:expression-tokens" match="oracle:false">
    <xsl:sequence select="'false'"/>
  </xsl:template>

  <!--
    Mode "t:expression-tokens". true.
  -->
  <xsl:template mode="t:expression-tokens" match="oracle:true">
    <xsl:sequence select="'true'"/>
  </xsl:template>

  <!--
    Mode "t:expression-tokens". simple-case.
  -->
  <xsl:template mode="t:expression-tokens" match="oracle:simple-case">
    <xsl:variable name="value" as="element()"
      select="t:get-sql-element(oracle:value)"/>

    <xsl:sequence select="'case'"/>
    <xsl:sequence select="' '"/>

    <xsl:apply-templates mode="t:expression-tokens" select="$value"/>

    <xsl:sequence select="$t:indent"/>

    <xsl:variable name="when" as="element()+" select="oracle:when"/>

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
  <xsl:template mode="t:expression-tokens" match="oracle:search-case">
    <xsl:sequence select="'case'"/>
    <xsl:sequence select="$t:indent"/>

    <xsl:variable name="when" as="element()+" select="oracle:when"/>

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
    Mode "t:expression-tokens". concat function.
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

  <!--
    Mode "t:expression-tokens". extract function.
  -->
  <xsl:template mode="t:expression-tokens"
    match="sql:function[@name = 'extract']">

    <xsl:variable name="arguments" as="element()+"
      select="t:get-sql-element(.)"/>

    <xsl:variable name="datetime-field" as="xs:string" select="
      $arguments[1][self::sql:string]/lower-case(@value)"/>

    <xsl:if test="
      not
      (
        $datetime-field =
          (
            'year',
            'month',
            'day',
            'hour',
            'minute',
            'second',
            'timezone_hour',
            'timezone_minute',
            'timezone_region',
            'timezone_abbr'
          )
      )">
      <xsl:sequence select="
        error
        (
          xs:QName('t:error'),
          concat('Invalid datetime field: ', $datetime-field, '.')
        )"/>
    </xsl:if>

    <xsl:sequence select="'extract'"/>
    <xsl:sequence select="'('"/>
    <xsl:sequence select="$datetime-field"/>
    <xsl:sequence select="' '"/>
    <xsl:sequence select="'from'"/>
    <xsl:sequence select="' '"/>

    <xsl:apply-templates mode="t:expression-tokens" select="$arguments[2]"/>
    <xsl:sequence select="')'"/>
  </xsl:template>

  <!-- Mode "t:get-sql-type". Get sql type. -->
  <xsl:template mode="t:get-sql-type" match="sql:type" priority="2">
    <xsl:variable name="name" as="xs:string" select="@name"/>
    <xsl:variable name="precision" as="xs:integer?" select="@precision"/>
    <xsl:variable name="scale" as="xs:integer?" select="@scale"/>

    <xsl:choose>
      <xsl:when test="$name = ('binary', 'varbinary')">
        <xsl:sequence select="'raw'"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:next-match/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!-- Collects keywords. -->
  <xsl:template mode="t:collect-keywords" match="t:keywords">
    <xsl:sequence select="$oracle:keywords"/>
  </xsl:template>

</xsl:stylesheet>