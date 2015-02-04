<?xml version="1.0" encoding="utf-8"?>
<!--
  This stylesheet generates basic sql.
-->
<xsl:stylesheet version="2.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:t="http://www.bphx.com/public/sql"
  xmlns:sql="http://www.bphx.com/basic-sql/2008-12-11"
  xmlns:tsql="http://www.bphx.com/basic-sql/2008-12-11/tsql"
  xmlns:p="http://www.bphx.com/private/tsql-serializer"
  exclude-result-prefixes="t xs p">
  
  <xsl:variable name="tsql:keywords">
    <!--T-SQL -->
    <keyword name="ADD"/>
    <keyword name="ALL"/>
    <keyword name="ALTER"/>
    <keyword name="AND"/>
    <keyword name="ANY"/>
    <keyword name="AS"/>
    <keyword name="ASC"/>
    <keyword name="AUTHORIZATION"/>
    <keyword name="BACKUP"/>
    <keyword name="BEGIN"/>
    <keyword name="BETWEEN"/>
    <keyword name="BREAK"/>
    <keyword name="BROWSE"/>
    <keyword name="BULK"/>
    <keyword name="BY"/>
    <keyword name="CASCADE"/>
    <keyword name="CASE"/>
    <keyword name="CHECK"/>
    <keyword name="CHECKPOINT"/>
    <keyword name="CLOSE"/>
    <keyword name="CLUSTERED"/>
    <keyword name="COALESCE"/>
    <keyword name="COLLATE"/>
    <keyword name="COLUMN"/>
    <keyword name="COMMIT"/>
    <keyword name="COMPUTE"/>
    <keyword name="CONSTRAINT"/>
    <keyword name="CONTAINS"/>
    <keyword name="CONTAINSTABLE"/>
    <keyword name="CONTINUE"/>
    <keyword name="CONVERT"/>
    <keyword name="CREATE"/>
    <keyword name="CROSS"/>
    <keyword name="CURRENT"/>
    <keyword name="CURRENT_DATE"/>
    <keyword name="CURRENT_TIME"/>
    <keyword name="CURRENT_TIMESTAMP"/>
    <keyword name="CURRENT_USER"/>
    <keyword name="CURSOR"/>
    <keyword name="DATABASE"/>
    <keyword name="DBCC"/>
    <keyword name="DEALLOCATE"/>
    <keyword name="DECLARE"/>
    <keyword name="DEFAULT"/>
    <keyword name="DELETE"/>
    <keyword name="DENY"/>
    <keyword name="DESC"/>
    <keyword name="DISK"/>
    <keyword name="DISTINCT"/>
    <keyword name="DISTRIBUTED"/>
    <keyword name="DOUBLE"/>
    <keyword name="DROP"/>
    <keyword name="DUMP"/>
    <keyword name="ELSE"/>
    <keyword name="END"/>
    <keyword name="ERRLVL"/>
    <keyword name="ESCAPE"/>
    <keyword name="EXCEPT"/>
    <keyword name="EXEC"/>
    <keyword name="EXECUTE"/>
    <keyword name="EXISTS"/>
    <keyword name="EXIT"/>
    <keyword name="EXTERNAL"/>
    <keyword name="FETCH"/>
    <keyword name="FILE"/>
    <keyword name="FILLFACTOR"/>
    <keyword name="FOR"/>
    <keyword name="FOREIGN"/>
    <keyword name="FREETEXT"/>
    <keyword name="FREETEXTTABLE"/>
    <keyword name="FROM"/>
    <keyword name="FULL"/>
    <keyword name="FUNCTION"/>
    <keyword name="GOTO"/>
    <keyword name="GRANT"/>
    <keyword name="GROUP"/>
    <keyword name="HAVING"/>
    <keyword name="HOLDLOCK"/>
    <keyword name="IDENTITY"/>
    <keyword name="IDENTITY_INSERT"/>
    <keyword name="IDENTITYCOL"/>
    <keyword name="IF"/>
    <keyword name="IN"/>
    <keyword name="INDEX"/>
    <keyword name="INNER"/>
    <keyword name="INSERT"/>
    <keyword name="INTERSECT"/>
    <keyword name="INTO"/>
    <keyword name="IS"/>
    <keyword name="JOIN"/>
    <keyword name="KEY"/>
    <keyword name="KILL"/>
    <keyword name="LEFT"/>
    <keyword name="LIKE"/>
    <keyword name="LINENO"/>
    <keyword name="LOAD"/>
    <keyword name="MERGE"/>
    <keyword name="NATIONAL"/>
    <keyword name="NOCHECK"/>
    <keyword name="NONCLUSTERED"/>
    <keyword name="NOT"/>
    <keyword name="NULL"/>
    <keyword name="NULLIF"/>
    <keyword name="OF"/>
    <keyword name="OFF"/>
    <keyword name="OFFSETS"/>
    <keyword name="ON"/>
    <keyword name="OPEN"/>
    <keyword name="OPENDATASOURCE"/>
    <keyword name="OPENQUERY"/>
    <keyword name="OPENROWSET"/>
    <keyword name="OPENXML"/>
    <keyword name="OPTION"/>
    <keyword name="OR"/>
    <keyword name="ORDER"/>
    <keyword name="OUTER"/>
    <keyword name="OVER"/>
    <keyword name="PERCENT"/>
    <keyword name="PIVOT"/>
    <keyword name="PLAN"/>
    <keyword name="PRECISION"/>
    <keyword name="PRIMARY"/>
    <keyword name="PRINT"/>
    <keyword name="PROC"/>
    <keyword name="PROCEDURE"/>
    <keyword name="PUBLIC"/>
    <keyword name="RAISERROR"/>
    <keyword name="READ"/>
    <keyword name="READTEXT"/>
    <keyword name="RECONFIGURE"/>
    <keyword name="REFERENCES"/>
    <keyword name="REPLICATION"/>
    <keyword name="RESTORE"/>
    <keyword name="RESTRICT"/>
    <keyword name="RETURN"/>
    <keyword name="REVERT"/>
    <keyword name="REVOKE"/>
    <keyword name="RIGHT"/>
    <keyword name="ROLLBACK"/>
    <keyword name="ROWCOUNT"/>
    <keyword name="ROWGUIDCOL"/>
    <keyword name="RULE"/>
    <keyword name="SAVE"/>
    <keyword name="SCHEMA"/>
    <keyword name="SECURITYAUDIT"/>
    <keyword name="SELECT"/>
    <keyword name="SEMANTICKEYPHRASETABLE"/>
    <keyword name="SEMANTICSIMILARITYDETAILSTABLE"/>
    <keyword name="SEMANTICSIMILARITYTABLE"/>
    <keyword name="SESSION_USER"/>
    <keyword name="SET"/>
    <keyword name="SETUSER"/>
    <keyword name="SHUTDOWN"/>
    <keyword name="SOME"/>
    <keyword name="STATISTICS"/>
    <keyword name="SYSTEM_USER"/>
    <keyword name="TABLE"/>
    <keyword name="TABLESAMPLE"/>
    <keyword name="TEXTSIZE"/>
    <keyword name="THEN"/>
    <keyword name="TO"/>
    <keyword name="TOP"/>
    <keyword name="TRAN"/>
    <keyword name="TRANSACTION"/>
    <keyword name="TRIGGER"/>
    <keyword name="TRUNCATE"/>
    <keyword name="TRY_CONVERT"/>
    <keyword name="TSEQUAL"/>
    <keyword name="UNION"/>
    <keyword name="UNIQUE"/>
    <keyword name="UNPIVOT"/>
    <keyword name="UPDATE"/>
    <keyword name="UPDATETEXT"/>
    <keyword name="USE"/>
    <keyword name="USER"/>
    <keyword name="VALUES"/>
    <keyword name="VARYING"/>
    <keyword name="VIEW"/>
    <keyword name="WAITFOR"/>
    <keyword name="WHEN"/>
    <keyword name="WHERE"/>
    <keyword name="WHILE"/>
    <keyword name="WITH"/>
    <keyword name="WITHIN"/>
    <keyword name="WITHIN_GROUP"/>
    <keyword name="WRITETEXT"/>
    
    <!--ODBC-->
    <keyword name="ABSOLUTE"/>
    <keyword name="ACTION"/>
    <keyword name="ADA"/>
    <keyword name="ADD"/>
    <keyword name="ALL"/>
    <keyword name="ALLOCATE"/>
    <keyword name="ALTER"/>
    <keyword name="AND"/>
    <keyword name="ANY"/>
    <keyword name="ARE"/>
    <keyword name="AS"/>
    <keyword name="ASC"/>
    <keyword name="ASSERTION"/>
    <keyword name="AT"/>
    <keyword name="AUTHORIZATION"/>
    <keyword name="AVG"/>
    <keyword name="BEGIN"/>
    <keyword name="BETWEEN"/>
    <keyword name="BIT"/>
    <keyword name="BIT_LENGTH"/>
    <keyword name="BOTH"/>
    <keyword name="BY"/>
    <keyword name="CASCADE"/>
    <keyword name="CASCADED"/>
    <keyword name="CASE"/>
    <keyword name="CAST"/>
    <keyword name="CATALOG"/>
    <keyword name="CHAR"/>
    <keyword name="CHAR_LENGTH"/>
    <keyword name="CHARACTER"/>
    <keyword name="CHARACTER_LENGTH"/>
    <keyword name="CHECK"/>
    <keyword name="CLOSE"/>
    <keyword name="COALESCE"/>
    <keyword name="COLLATE"/>
    <keyword name="COLLATION"/>
    <keyword name="COLUMN"/>
    <keyword name="COMMIT"/>
    <keyword name="CONNECT"/>
    <keyword name="CONNECTION"/>
    <keyword name="CONSTRAINT"/>
    <keyword name="CONSTRAINTS"/>
    <keyword name="CONTINUE"/>
    <keyword name="CONVERT"/>
    <keyword name="CORRESPONDING"/>
    <keyword name="COUNT"/>
    <keyword name="CREATE"/>
    <keyword name="CROSS"/>
    <keyword name="CURRENT"/>
    <keyword name="CURRENT_DATE"/>
    <keyword name="CURRENT_TIME"/>
    <keyword name="CURRENT_TIMESTAMP"/>
    <keyword name="CURRENT_USER"/>
    <keyword name="CURSOR"/>
    <keyword name="DATE"/>
    <keyword name="DAY"/>
    <keyword name="DEALLOCATE"/>
    <keyword name="DEC"/>
    <keyword name="DECIMAL"/>
    <keyword name="DECLARE"/>
    <keyword name="DEFAULT"/>
    <keyword name="DEFERRABLE"/>
    <keyword name="DEFERRED"/>
    <keyword name="DELETE"/>
    <keyword name="DESC"/>
    <keyword name="DESCRIBE"/>
    <keyword name="DESCRIPTOR"/>
    <keyword name="DIAGNOSTICS"/>
    <keyword name="DISCONNECT"/>
    <keyword name="DISTINCT"/>
    <keyword name="DOMAIN"/>
    <keyword name="DOUBLE"/>
    <keyword name="DROP"/>
    <keyword name="ELSE"/>
    <keyword name="END"/>
    <keyword name="END-EXEC"/>
    <keyword name="ESCAPE"/>
    <keyword name="EXCEPT"/>
    <keyword name="EXCEPTION"/>
    <keyword name="EXEC"/>
    <keyword name="EXECUTE"/>
    <keyword name="EXISTS"/>
    <keyword name="EXTERNAL"/>
    <keyword name="EXTRACT"/>
    <keyword name="FALSE"/>
    <keyword name="FETCH"/>
    <keyword name="FIRST"/>
    <keyword name="FLOAT"/>
    <keyword name="FOR"/>
    <keyword name="FOREIGN"/>
    <keyword name="FORTRAN"/>
    <keyword name="FOUND"/>
    <keyword name="FROM"/>
    <keyword name="FULL"/>
    <keyword name="GET"/>
    <keyword name="GLOBAL"/>
    <keyword name="GO"/>
    <keyword name="GOTO"/>
    <keyword name="GRANT"/>
    <keyword name="GROUP"/>
    <keyword name="HAVING"/>
    <keyword name="HOUR"/>
    <keyword name="IDENTITY"/>
    <keyword name="IMMEDIATE"/>
    <keyword name="IN"/>
    <keyword name="INCLUDE"/>
    <keyword name="INDEX"/>
    <keyword name="INDICATOR"/>
    <keyword name="INITIALLY"/>
    <keyword name="INNER"/>
    <keyword name="INPUT"/>
    <keyword name="INSENSITIVE"/>
    <keyword name="INSERT"/>
    <keyword name="INT"/>
    <keyword name="INTEGER"/>
    <keyword name="INTERSECT"/>
    <keyword name="INTERVAL"/>
    <keyword name="INTO"/>
    <keyword name="IS"/>
    <keyword name="ISOLATION"/>
    <keyword name="JOIN"/>
    <keyword name="KEY"/>
    <keyword name="LANGUAGE"/>
    <keyword name="LAST"/>
    <keyword name="LEADING"/>
    <keyword name="LEFT"/>
    <keyword name="LEVEL"/>
    <keyword name="LIKE"/>
    <keyword name="LOCAL"/>
    <keyword name="LOWER"/>
    <keyword name="MATCH"/>
    <keyword name="MAX"/>
    <keyword name="MIN"/>
    <keyword name="MINUTE"/>
    <keyword name="MODULE"/>
    <keyword name="MONTH"/>
    <keyword name="NAMES"/>
    <keyword name="NATIONAL"/>
    <keyword name="NATURAL"/>
    <keyword name="NCHAR"/>
    <keyword name="NEXT"/>
    <keyword name="NO"/>
    <keyword name="NONE"/>
    <keyword name="NOT"/>
    <keyword name="NULL"/>
    <keyword name="NULLIF"/>
    <keyword name="NUMERIC"/>
    <keyword name="OCTET_LENGTH"/>
    <keyword name="OF"/>
    <keyword name="ON"/>
    <keyword name="ONLY"/>
    <keyword name="OPEN"/>
    <keyword name="OPTION"/>
    <keyword name="OR"/>
    <keyword name="ORDER"/>
    <keyword name="OUTER"/>
    <keyword name="OUTPUT"/>
    <keyword name="OVERLAPS"/>
    <keyword name="PAD"/>
    <keyword name="PARTIAL"/>
    <keyword name="PASCAL"/>
    <keyword name="POSITION"/>
    <keyword name="PRECISION"/>
    <keyword name="PREPARE"/>
    <keyword name="PRESERVE"/>
    <keyword name="PRIMARY"/>
    <keyword name="PRIOR"/>
    <keyword name="PRIVILEGES"/>
    <keyword name="PROCEDURE"/>
    <keyword name="PUBLIC"/>
    <keyword name="READ"/>
    <keyword name="REAL"/>
    <keyword name="REFERENCES"/>
    <keyword name="RELATIVE"/>
    <keyword name="RESTRICT"/>
    <keyword name="REVOKE"/>
    <keyword name="RIGHT"/>
    <keyword name="ROLLBACK"/>
    <keyword name="ROWS"/>
    <keyword name="SCHEMA"/>
    <keyword name="SCROLL"/>
    <keyword name="SECOND"/>
    <keyword name="SECTION"/>
    <keyword name="SELECT"/>
    <keyword name="SESSION"/>
    <keyword name="SESSION_USER"/>
    <keyword name="SET"/>
    <keyword name="SIZE"/>
    <keyword name="SMALLINT"/>
    <keyword name="SOME"/>
    <keyword name="SPACE"/>
    <keyword name="SQL"/>
    <keyword name="SQLCA"/>
    <keyword name="SQLCODE"/>
    <keyword name="SQLERROR"/>
    <keyword name="SQLSTATE"/>
    <keyword name="SQLWARNING"/>
    <keyword name="SUBSTRING"/>
    <keyword name="SUM"/>
    <keyword name="SYSTEM_USER"/>
    <keyword name="TABLE"/>
    <keyword name="TEMPORARY"/>
    <keyword name="THEN"/>
    <keyword name="TIME"/>
    <keyword name="TIMESTAMP"/>
    <keyword name="TIMEZONE_HOUR"/>
    <keyword name="TIMEZONE_MINUTE"/>
    <keyword name="TO"/>
    <keyword name="TRAILING"/>
    <keyword name="TRANSACTION"/>
    <keyword name="TRANSLATE"/>
    <keyword name="TRANSLATION"/>
    <keyword name="TRIM"/>
    <keyword name="TRUE"/>
    <keyword name="UNION"/>
    <keyword name="UNIQUE"/>
    <keyword name="UNKNOWN"/>
    <keyword name="UPDATE"/>
    <keyword name="UPPER"/>
    <keyword name="USAGE"/>
    <keyword name="USER"/>
    <keyword name="USING"/>
    <keyword name="VALUE"/>
    <keyword name="VALUES"/>
    <keyword name="VARCHAR"/>
    <keyword name="VARYING"/>
    <keyword name="VIEW"/>
    <keyword name="WHEN"/>
    <keyword name="WHENEVER"/>
    <keyword name="WHERE"/>
    <keyword name="WITH"/>
    <keyword name="WORK"/>
    <keyword name="WRITE"/>
    <keyword name="YEAR"/>
    <keyword name="ZONE"/>

    <!--FUTURE-->
    <keyword name="ABSOLUTE"/>
    <keyword name="ACTION"/>
    <keyword name="ADMIN"/>
    <keyword name="AFTER"/>
    <keyword name="AGGREGATE"/>
    <keyword name="ALIAS"/>
    <keyword name="ALLOCATE"/>
    <keyword name="ARE"/>
    <keyword name="ARRAY"/>
    <keyword name="ASENSITIVE"/>
    <keyword name="ASSERTION"/>
    <keyword name="ASYMMETRIC"/>
    <keyword name="AT"/>
    <keyword name="ATOMIC"/>
    <keyword name="BEFORE"/>
    <keyword name="BINARY"/>
    <keyword name="BIT"/>
    <keyword name="BLOB"/>
    <keyword name="BOOLEAN"/>
    <keyword name="BOTH"/>
    <keyword name="BREADTH"/>
    <keyword name="CALL"/>
    <keyword name="CALLED"/>
    <keyword name="CARDINALITY"/>
    <keyword name="CASCADED"/>
    <keyword name="CAST"/>
    <keyword name="CATALOG"/>
    <keyword name="CHAR"/>
    <keyword name="CHARACTER"/>
    <keyword name="CLASS"/>
    <keyword name="CLOB"/>
    <keyword name="COLLATION"/>
    <keyword name="COLLECT"/>
    <keyword name="COMPLETION"/>
    <keyword name="CONDITION"/>
    <keyword name="CONNECT"/>
    <keyword name="CONNECTION"/>
    <keyword name="CONSTRAINTS"/>
    <keyword name="CONSTRUCTOR"/>
    <keyword name="CORR"/>
    <keyword name="CORRESPONDING"/>
    <keyword name="COVAR_POP"/>
    <keyword name="COVAR_SAMP"/>
    <keyword name="CUBE"/>
    <keyword name="CUME_DIST"/>
    <keyword name="CURRENT_CATALOG"/>
    <keyword name="CURRENT_DEFAULT_TRANSFORM_GROUP"/>
    <keyword name="CURRENT_PATH"/>
    <keyword name="CURRENT_ROLE"/>
    <keyword name="CURRENT_SCHEMA"/>
    <keyword name="CURRENT_TRANSFORM_GROUP_FOR_TYPE"/>
    <keyword name="CYCLE"/>
    <keyword name="DATA"/>
    <keyword name="DATE"/>
    <keyword name="DAY"/>
    <keyword name="DEC"/>
    <keyword name="DECIMAL"/>
    <keyword name="DEFERRABLE"/>
    <keyword name="DEFERRED"/>
    <keyword name="DEPTH"/>
    <keyword name="DEREF"/>
    <keyword name="DESCRIBE"/>
    <keyword name="DESCRIPTOR"/>
    <keyword name="DESTROY"/>
    <keyword name="DESTRUCTOR"/>
    <keyword name="DETERMINISTIC"/>
    <keyword name="DIAGNOSTICS"/>
    <keyword name="DICTIONARY"/>
    <keyword name="DISCONNECT"/>
    <keyword name="DOMAIN"/>
    <keyword name="DYNAMIC"/>
    <keyword name="EACH"/>
    <keyword name="ELEMENT"/>
    <keyword name="END-EXEC"/>
    <keyword name="EQUALS"/>
    <keyword name="EVERY"/>
    <keyword name="EXCEPTION"/>
    <keyword name="FALSE"/>
    <keyword name="FILTER"/>
    <keyword name="FIRST"/>
    <keyword name="FLOAT"/>
    <keyword name="FOUND"/>
    <keyword name="FREE"/>
    <keyword name="FULLTEXTTABLE"/>
    <keyword name="FUSION"/>
    <keyword name="GENERAL"/>
    <keyword name="GET"/>
    <keyword name="GLOBAL"/>
    <keyword name="GO"/>
    <keyword name="GROUPING"/>
    <keyword name="HOLD"/>
    <keyword name="HOST"/>
    <keyword name="HOUR"/>
    <keyword name="IGNORE"/>
    <keyword name="IMMEDIATE"/>
    <keyword name="INDICATOR"/>
    <keyword name="INITIALIZE"/>
    <keyword name="INITIALLY"/>
    <keyword name="INOUT"/>
    <keyword name="INPUT"/>
    <keyword name="INT"/>
    <keyword name="INTEGER"/>
    <keyword name="INTERSECTION"/>
    <keyword name="INTERVAL"/>
    <keyword name="ISOLATION"/>
    <keyword name="ITERATE"/>
    <keyword name="LANGUAGE"/>
    <keyword name="LARGE"/>
    <keyword name="LAST"/>
    <keyword name="LATERAL"/>
    <keyword name="LEADING"/>
    <keyword name="LESS"/>
    <keyword name="LEVEL"/>
    <keyword name="LIKE_REGEX"/>
    <keyword name="LIMIT"/>
    <keyword name="LN"/>
    <keyword name="LOCAL"/>
    <keyword name="LOCALTIME"/>
    <keyword name="LOCALTIMESTAMP"/>
    <keyword name="LOCATOR"/>
    <keyword name="MAP"/>
    <keyword name="MATCH"/>
    <keyword name="MEMBER"/>
    <keyword name="METHOD"/>
    <keyword name="MINUTE"/>
    <keyword name="MOD"/>
    <keyword name="MODIFIES"/>
    <keyword name="MODIFY"/>
    <keyword name="MODULE"/>
    <keyword name="MONTH"/>
    <keyword name="MULTISET"/>
    <keyword name="NAMES"/>
    <keyword name="NATURAL"/>
    <keyword name="NCHAR"/>
    <keyword name="NCLOB"/>
    <keyword name="NEW"/>
    <keyword name="NEXT"/>
    <keyword name="NO"/>
    <keyword name="NONE"/>
    <keyword name="NORMALIZE"/>
    <keyword name="NUMERIC"/>
    <keyword name="OBJECT"/>
    <keyword name="OCCURRENCES_REGEX"/>
    <keyword name="OLD"/>
    <keyword name="ONLY"/>
    <keyword name="OPERATION"/>
    <keyword name="ORDINALITY"/>
    <keyword name="OUT"/>
    <keyword name="OUTPUT"/>
    <keyword name="OVERLAY"/>
    <keyword name="PAD"/>
    <keyword name="PARAMETER"/>
    <keyword name="PARAMETERS"/>
    <keyword name="PARTIAL"/>
    <keyword name="PARTITION"/>
    <keyword name="PATH"/>
    <keyword name="PERCENT_RANK"/>
    <keyword name="PERCENTILE_CONT"/>
    <keyword name="PERCENTILE_DISC"/>
    <keyword name="POSITION_REGEX"/>
    <keyword name="POSTFIX"/>
    <keyword name="PREFIX"/>
    <keyword name="PREORDER"/>
    <keyword name="PREPARE"/>
    <keyword name="PRESERVE"/>
    <keyword name="PRIOR"/>
    <keyword name="PRIVILEGES"/>
    <keyword name="RANGE"/>
    <keyword name="READS"/>
    <keyword name="REAL"/>
    <keyword name="RECURSIVE"/>
    <keyword name="REF"/>
    <keyword name="REFERENCING"/>
    <keyword name="REGR_AVGX"/>
    <keyword name="REGR_AVGY"/>
    <keyword name="REGR_COUNT"/>
    <keyword name="REGR_INTERCEPT"/>
    <keyword name="REGR_R2"/>
    <keyword name="REGR_SLOPE"/>
    <keyword name="REGR_SXX"/>
    <keyword name="REGR_SXY"/>
    <keyword name="REGR_SYY"/>
    <keyword name="RELATIVE"/>
    <keyword name="RELEASE"/>
    <keyword name="RESULT"/>
    <keyword name="RETURNS"/>
    <keyword name="ROLE"/>
    <keyword name="ROLLUP"/>
    <keyword name="ROUTINE"/>
    <keyword name="ROW"/>
    <keyword name="ROWS"/>
    <keyword name="SAVEPOINT"/>
    <keyword name="SCOPE"/>
    <keyword name="SCROLL"/>
    <keyword name="SEARCH"/>
    <keyword name="SECOND"/>
    <keyword name="SECTION"/>
    <keyword name="SENSITIVE"/>
    <keyword name="SEQUENCE"/>
    <keyword name="SESSION"/>
    <keyword name="SETS"/>
    <keyword name="SIMILAR"/>
    <keyword name="SIZE"/>
    <keyword name="SMALLINT"/>
    <keyword name="SPACE"/>
    <keyword name="SPECIFIC"/>
    <keyword name="SPECIFICTYPE"/>
    <keyword name="SQL"/>
    <keyword name="SQLEXCEPTION"/>
    <keyword name="SQLSTATE"/>
    <keyword name="SQLWARNING"/>
    <keyword name="START"/>
    <keyword name="STATE"/>
    <keyword name="STATEMENT"/>
    <keyword name="STATIC"/>
    <keyword name="STDDEV_POP"/>
    <keyword name="STDDEV_SAMP"/>
    <keyword name="STRUCTURE"/>
    <keyword name="SUBMULTISET"/>
    <keyword name="SUBSTRING_REGEX"/>
    <keyword name="SYMMETRIC"/>
    <keyword name="SYSTEM"/>
    <keyword name="TEMPORARY"/>
    <keyword name="TERMINATE"/>
    <keyword name="THAN"/>
    <keyword name="TIME"/>
    <keyword name="TIMESTAMP"/>
    <keyword name="TIMEZONE_HOUR"/>
    <keyword name="TIMEZONE_MINUTE"/>
    <keyword name="TRAILING"/>
    <keyword name="TRANSLATE_REGEX"/>
    <keyword name="TRANSLATION"/>
    <keyword name="TREAT"/>
    <keyword name="TRUE"/>
    <keyword name="UESCAPE"/>
    <keyword name="UNDER"/>
    <keyword name="UNKNOWN"/>
    <keyword name="UNNEST"/>
    <keyword name="USAGE"/>
    <keyword name="USING"/>
    <keyword name="VALUE"/>
    <keyword name="VAR_POP"/>
    <keyword name="VAR_SAMP"/>
    <keyword name="VARCHAR"/>
    <keyword name="VARIABLE"/>
    <keyword name="WHENEVER"/>
    <keyword name="WIDTH_BUCKET"/>
    <keyword name="WINDOW"/>
    <keyword name="WITHIN"/>
    <keyword name="WITHOUT"/>
    <keyword name="WORK"/>
    <keyword name="WRITE"/>
    <keyword name="XMLAGG"/>
    <keyword name="XMLATTRIBUTES"/>
    <keyword name="XMLBINARY"/>
    <keyword name="XMLCAST"/>
    <keyword name="XMLCOMMENT"/>
    <keyword name="XMLCONCAT"/>
    <keyword name="XMLDOCUMENT"/>
    <keyword name="XMLELEMENT"/>
    <keyword name="XMLEXISTS"/>
    <keyword name="XMLFOREST"/>
    <keyword name="XMLITERATE"/>
    <keyword name="XMLNAMESPACES"/>
    <keyword name="XMLPARSE"/>
    <keyword name="XMLPI"/>
    <keyword name="XMLQUERY"/>
    <keyword name="XMLSERIALIZE"/>
    <keyword name="XMLTABLE"/>
    <keyword name="XMLTEXT"/>
    <keyword name="XMLVALIDATE"/>
    <keyword name="YEAR"/>
    <keyword name="ZONE"/>
  </xsl:variable>

  <!--
    Mode "t:get-sql-element". Gets sql element.
  -->
  <xsl:template mode="t:get-sql-element" match="tsql:*">
    <xsl:sequence select="."/>
  </xsl:template>

  <xsl:template match="*" 
    mode="t:get-var-or-name t:get-var-or-qualified-name"/>

  <xsl:template match="tsql:name"
    mode="t:get-var-or-name t:get-var-or-qualified-name">
    <xsl:sequence select="."/>
  </xsl:template>

  <!--
    Mode "t:var-or-name".
      $name - a name element (context by default).
  -->
  <xsl:template match="tsql:name" mode="t:expression-tokens t:var-or-name">
    <xsl:sequence select="string(@name)"/>
  </xsl:template>

  <!--
    Mode "t:var-or-qualified-name". name
  -->
  <xsl:template match="tsql:name" mode="t:var-or-qualified-name">
    <xsl:call-template name="t:qualified-name"/>
  </xsl:template>

  <!--
    Mode "t:expression-tokens". string.
  -->
  <xsl:template mode="t:expression-tokens" match="sql:string" priority="2">
    <xsl:variable name="value" as="xs:string" select="@value"/>
    
    <xsl:variable name="binary" as="xs:boolean?" select="@binary"/>

    <xsl:choose>
      <xsl:when test="not($binary)">
        <xsl:variable name="escaped-value" as="xs:string"
          select="replace($value, '''', '''''', 'm')"/>

        <xsl:sequence select="concat('N''', $escaped-value, '''')"/>
      </xsl:when>
      <xsl:when test="matches($value, '^[0-9a-f]+$', 'si')">
        <xsl:sequence select="concat('0x', $value)"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:sequence select="
          error
          (
            xs:QName('t:error'),
            concat('Invalid binary literal: ', $value)
          )"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!--
    Mode "t:expression-tokens". Default match.
  -->
  <xsl:template match="sql:var" priority="2" mode="
    t:expression-tokens
    t:var-or-name
    t:var-or-qualified-name
    t:var-or-host">
    <xsl:sequence select="p:get-var(@name)"/>
  </xsl:template>

  <!--
    Mode "t:expression-tokens". Default match.
  -->
  <xsl:template mode="t:expression-tokens" match="sql:system-var" priority="2">
    <xsl:sequence select="p:get-system-var(@name)"/>
  </xsl:template>

  <!-- top clause. -->
  <xsl:template priority="2" match="*[tsql:top]" mode="
    t:select-header-extensions
    t:insert-header-extensions
    t:update-header-extensions
    t:delete-header-extensions">
                
    <xsl:variable name="top" as="element()" select="tsql:top"/>
    <xsl:variable name="percent" as="xs:boolean?" select="$top/@percent"/>
    <xsl:variable name="with-ties" as="xs:boolean?" select="$top/@with-ties"/>
    <xsl:variable name="expression" as="element()"
      select="t:get-sql-element($top)"/>

    <xsl:sequence select="' '"/>
    <xsl:sequence select="'top'"/>
    <xsl:sequence select="'('"/>
    <xsl:apply-templates mode="t:expression-tokens" select="$expression"/>
    <xsl:sequence select="')'"/>

    <xsl:if test="$percent">
      <xsl:sequence select="' '"/>
      <xsl:sequence select="'percent'"/>
    </xsl:if>

    <xsl:if test="$with-ties">
      <xsl:sequence select="' '"/>
      <xsl:sequence select="'with'"/>
      <xsl:sequence select="' '"/>
      <xsl:sequence select="'ties'"/>
    </xsl:if>
  </xsl:template>

  <!--
    Mode "t:select-footer-extensions". for-browse clause.
  -->
  <xsl:template mode="t:select-footer-extensions" priority="2" 
    match="*[tsql:for-browse]">
    <xsl:sequence select="$t:new-line"/>
    <xsl:sequence select="'for'"/>
    <xsl:sequence select="' '"/>
    <xsl:sequence select="'browse'"/>
  </xsl:template>
  
  <!--
    Mode "t:select-footer-extensions". for-xml clause.
  -->
  <xsl:template mode="t:select-footer-extensions" priority="2" 
    match="*[tsql:for-xml]">

    <xsl:variable name="for-xml" as="element()?" select="tsql:for-xml"/>
    <xsl:variable name="mode" as="xs:string?" select="$for-xml/@mode"/>
    <xsl:variable name="element-name" as="xs:string?" 
      select="$for-xml/@element-name"/>
    <xsl:variable name="root" as="xs:string?" 
      select="$for-xml/@root"/>
    <xsl:variable name="xmlschema" as="xs:string?" 
      select="$for-xml/@xmlschema"/>
    <xsl:variable name="elements" as="xs:string?" 
      select="$for-xml/@elements"/>

    <xsl:sequence select="$t:new-line"/>
    <xsl:sequence select="'for'"/>
    <xsl:sequence select="' '"/>
    <xsl:sequence select="'xml'"/>
        
    <xsl:choose>
      <xsl:when test="$mode = 'raw'">
        <xsl:sequence select="' '"/>
        <xsl:sequence select="'raw'"/>
            
        <xsl:if test="$element-name">
          <xsl:sequence select="'('"/>
          <xsl:sequence select="$element-name"/>
          <xsl:sequence select="')'"/>
        </xsl:if>
      </xsl:when>
      <xsl:when test="$mode = 'auto'">
        <xsl:sequence select="' '"/>
        <xsl:sequence select="'auto'"/>
      </xsl:when>
      <xsl:when test="$mode = 'explicit'">
        <xsl:sequence select="' '"/>
        <xsl:sequence select="'explicit'"/>
      </xsl:when>
      <xsl:when test="$mode = 'path'">
        <xsl:sequence select="' '"/>
        <xsl:sequence select="'path'"/>

        <xsl:if test="$element-name">
          <xsl:sequence select="'('"/>
          <xsl:sequence select="$element-name"/>
          <xsl:sequence select="')'"/>
        </xsl:if>
      </xsl:when>
      <xsl:when test="empty($mode)">
        <!-- empty -->
      </xsl:when>
      <xsl:otherwise>
        <xsl:sequence select="
          error
          (
            xs:QName('t:error'),
            concat
            (
              'Invalid for xml mode ',
              $mode,
              '.'
            )
          )"/>
      </xsl:otherwise>
    </xsl:choose>
        
    <xsl:if test="$for-xml/xs:boolean(@binary-base64)">
      <xsl:sequence select="','"/>
      <xsl:sequence select="' '"/>
      <xsl:sequence select="'binary'"/>
      <xsl:sequence select="' '"/>
      <xsl:sequence select="'base64'"/>
    </xsl:if>
        
    <xsl:if test="$for-xml/xs:boolean(@type)">
      <xsl:sequence select="','"/>
      <xsl:sequence select="' '"/>
      <xsl:sequence select="'type'"/>
    </xsl:if>

    <xsl:if test="exists($root)">
      <xsl:sequence select="','"/>
      <xsl:sequence select="' '"/>
      <xsl:sequence select="'root'"/>
        
      <xsl:if test="$root">
        <xsl:sequence select="'('"/>
        <xsl:sequence select="$root"/>
        <xsl:sequence select="')'"/>
      </xsl:if>
    </xsl:if>
        
    <xsl:choose>
      <xsl:when test="$for-xml/xs:boolean(@xmldata)">
        <xsl:sequence select="','"/>
        <xsl:sequence select="' '"/>
        <xsl:sequence select="'xmldata'"/>
      </xsl:when>
      <xsl:when test="exists($xmlschema)">
        <xsl:sequence select="','"/>
        <xsl:sequence select="' '"/>
        <xsl:sequence select="'xmlschema'"/>

        <xsl:if test="$xmlschema">
          <xsl:sequence select="'('"/>
          <xsl:sequence select="$xmlschema"/>
          <xsl:sequence select="')'"/>
        </xsl:if>
      </xsl:when>
    </xsl:choose>
        
    <xsl:choose>
      <xsl:when test="$elements = 'xsnil'">
        <xsl:sequence select="','"/>
        <xsl:sequence select="' '"/>
        <xsl:sequence select="'elements'"/>
        <xsl:sequence select="' '"/>
        <xsl:sequence select="'xsnil'"/>
      </xsl:when>
      <xsl:when test="$elements = 'absent'">
        <xsl:sequence select="','"/>
        <xsl:sequence select="' '"/>
        <xsl:sequence select="'elements'"/>
      </xsl:when>
      <xsl:when test="empty($elements)">
        <!--empty-->
      </xsl:when>
      <xsl:otherwise>
        <xsl:sequence select="
          error
          (
            xs:QName('t:error'),
            concat
            (
              'Invalid for xml elements ',
              $elements,
              '.'
            )
          )"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!--
    query options.
  -->
  <xsl:template match="*[tsql:option]" priority="2" mode="
    t:select-footer-extensions
    t:insert-footer-extensions
    t:update-footer-extensions
    t:delete-footer-extensions">
    
    <xsl:variable name="tokens" as="item()*">
      <xsl:apply-templates mode="p:query-hint" 
        select="tsql:option/t:get-sql-element(.)"/>
    </xsl:variable>
    
    <xsl:if test="exists($tokens)">
      <xsl:sequence select="$t:new-line"/>
      <xsl:sequence select="'option'"/>
      <xsl:sequence select="'('"/>
      <xsl:sequence select="subsequence($tokens, 3)"/>
      <xsl:sequence select="')'"/>
    </xsl:if>
  </xsl:template>

  <!-- Mode "t:table-source". Generates table. -->
  <xsl:template mode="t:table-source" match="sql:table[tsql:with]">
    <xsl:variable name="tokens" as="item()+">
      <xsl:apply-templates mode="p:table-hint" 
        select="tsql:with/t:get-sql-element(.)"/>
    </xsl:variable>

    <xsl:next-match/>

    <xsl:if test="exists($tokens)">
      <xsl:sequence select="$t:new-line"/>
      <xsl:sequence select="'with'"/>
      <xsl:sequence select="'('"/>
      <xsl:sequence select="subsequence($tokens, 3)"/>
      <xsl:sequence select="')'"/>
    </xsl:if>
  </xsl:template>
      
  <!-- join hint. -->
  <xsl:template mode="t:table-source" 
    match="sql:join[@hint] | sql:inner-join[@hint]">
    <xsl:call-template name="t:join">
      <xsl:with-param name="type" 
        select="'inner', ' ', string(@hint), ' ', 'join'"/>
    </xsl:call-template>
  </xsl:template>

  <!-- join hint. -->
  <xsl:template mode="t:table-source" match="sql:left-join[@hint]">
    <xsl:call-template name="t:join">
      <xsl:with-param name="type"
        select="'left', ' ', string(@hint), ' ', 'join'"/>
    </xsl:call-template>
  </xsl:template>

  <!-- join hint. -->
  <xsl:template mode="t:table-source" match="sql:right-join[@hint]">
    <xsl:call-template name="t:join">
      <xsl:with-param name="type"
        select="'right', ' ', string(@hint), ' ', 'join'"/>
    </xsl:call-template>
  </xsl:template>

  <!-- join hint. -->
  <xsl:template mode="t:table-source" match="sql:full-join[@hint]">
    <xsl:call-template name="t:join">
      <xsl:with-param name="type"
        select="'full', ' ', string(@hint), ' ', 'join'"/>
    </xsl:call-template>
  </xsl:template>

  <!-- Hash group option. -->
  <xsl:template mode="p:query-hint" match="tsql:hash-group">
    <xsl:sequence select="','"/>
    <xsl:sequence select="' '"/>
    <xsl:sequence select="'hash'"/>
    <xsl:sequence select="' '"/>
    <xsl:sequence select="'group'"/>
  </xsl:template>
    
  <!-- Order group option. -->
  <xsl:template mode="p:query-hint" match="tsql:order-group">
    <xsl:sequence select="','"/>
    <xsl:sequence select="' '"/>
    <xsl:sequence select="'order'"/>
    <xsl:sequence select="' '"/>
    <xsl:sequence select="'group'"/>
  </xsl:template>
  
  <!-- Concat union option. -->
  <xsl:template mode="p:query-hint" match="tsql:concat-union">
    <xsl:sequence select="','"/>
    <xsl:sequence select="' '"/>
    <xsl:sequence select="'concat'"/>
    <xsl:sequence select="' '"/>
    <xsl:sequence select="'union'"/>
  </xsl:template>

  <!-- Hash union option. -->
  <xsl:template mode="p:query-hint" match="tsql:hash-union">
    <xsl:sequence select="','"/>
    <xsl:sequence select="' '"/>
    <xsl:sequence select="'hash'"/>
    <xsl:sequence select="' '"/>
    <xsl:sequence select="'union'"/>
  </xsl:template>

  <!-- Merge union option. -->
  <xsl:template mode="p:query-hint" match="tsql:merge-union">
    <xsl:sequence select="','"/>
    <xsl:sequence select="' '"/>
    <xsl:sequence select="'merge'"/>
    <xsl:sequence select="' '"/>
    <xsl:sequence select="'union'"/>
  </xsl:template>

  <!-- Loop join option. -->
  <xsl:template mode="p:query-hint" match="tsql:loop-join">
    <xsl:sequence select="','"/>
    <xsl:sequence select="' '"/>
    <xsl:sequence select="'loop'"/>
    <xsl:sequence select="' '"/>
    <xsl:sequence select="'join'"/>
  </xsl:template>

  <!-- Merge join option. -->
  <xsl:template mode="p:query-hint" match="tsql:merge-join">
    <xsl:sequence select="','"/>
    <xsl:sequence select="' '"/>
    <xsl:sequence select="'merge'"/>
    <xsl:sequence select="' '"/>
    <xsl:sequence select="'join'"/>
  </xsl:template>

  <!-- Hash join option. -->
  <xsl:template mode="p:query-hint" match="tsql:hash-join">
    <xsl:sequence select="','"/>
    <xsl:sequence select="' '"/>
    <xsl:sequence select="'hash'"/>
    <xsl:sequence select="' '"/>
    <xsl:sequence select="'join'"/>
  </xsl:template>

  <!-- expand views option. -->
  <xsl:template mode="p:query-hint" match="tsql:expand-views">
    <xsl:sequence select="','"/>
    <xsl:sequence select="' '"/>
    <xsl:sequence select="'expand'"/>
    <xsl:sequence select="' '"/>
    <xsl:sequence select="'views'"/>
  </xsl:template>

  <!-- for order option. -->
  <xsl:template mode="p:query-hint" match="tsql:force-order">
    <xsl:sequence select="','"/>
    <xsl:sequence select="' '"/>
    <xsl:sequence select="'force'"/>
    <xsl:sequence select="' '"/>
    <xsl:sequence select="'order'"/>
  </xsl:template>

  <!-- ignore_non_clustered_column_store_index option. -->
  <xsl:template mode="p:query-hint" match="tsql:force-order">
    <xsl:sequence select="','"/>
    <xsl:sequence select="' '"/>
    <xsl:sequence select="'ignore_non_clustered_column_store_index'"/>
  </xsl:template>

  <!-- keep plan option. -->
  <xsl:template mode="p:query-hint" match="tsql:keep-plan">
    <xsl:sequence select="','"/>
    <xsl:sequence select="' '"/>
    <xsl:sequence select="'keep'"/>
    <xsl:sequence select="' '"/>
    <xsl:sequence select="'plan'"/>
  </xsl:template>

  <!-- keepfixed plan option. -->
  <xsl:template mode="p:query-hint" match="tsql:keep-fixed-plan">
    <xsl:sequence select="','"/>
    <xsl:sequence select="' '"/>
    <xsl:sequence select="'keepfixed'"/>
    <xsl:sequence select="' '"/>
    <xsl:sequence select="'plan'"/>
  </xsl:template>

  <!-- parametrization simple option. -->
  <xsl:template mode="p:query-hint" match="tsql:simple-parametrization">
    <xsl:sequence select="','"/>
    <xsl:sequence select="' '"/>
    <xsl:sequence select="'parametrization'"/>
    <xsl:sequence select="' '"/>
    <xsl:sequence select="'simple'"/>
  </xsl:template>

  <!-- parametrization forced option. -->
  <xsl:template mode="p:query-hint" match="tsql:forced-parametrization">
    <xsl:sequence select="','"/>
    <xsl:sequence select="' '"/>
    <xsl:sequence select="'parametrization'"/>
    <xsl:sequence select="' '"/>
    <xsl:sequence select="'forced'"/>
  </xsl:template>

  <!-- recompile option. -->
  <xsl:template mode="p:query-hint" match="tsql:recompile">
    <xsl:sequence select="','"/>
    <xsl:sequence select="' '"/>
    <xsl:sequence select="'recompile'"/>
  </xsl:template>

  <!-- robust plan option. -->
  <xsl:template mode="p:query-hint" match="tsql:robust-plan">
    <xsl:sequence select="','"/>
    <xsl:sequence select="' '"/>
    <xsl:sequence select="'robust'"/>
    <xsl:sequence select="' '"/>
    <xsl:sequence select="'plan'"/>
  </xsl:template>

  <!-- fast rows option. -->
  <xsl:template mode="p:query-hint" match="tsql:fast-rows">
    <xsl:variable name="value" as="xs:integer" select="@value"/>
    
    <xsl:sequence select="','"/>
    <xsl:sequence select="' '"/>
    <xsl:sequence select="'fast'"/>
    <xsl:sequence select="' '"/>
    <xsl:sequence select="string($value)"/>
  </xsl:template>

  <!-- maxdop option. -->
  <xsl:template mode="p:query-hint" match="tsql:max-dop">
    <xsl:variable name="value" as="xs:integer" select="@value"/>
    
    <xsl:sequence select="','"/>
    <xsl:sequence select="' '"/>
    <xsl:sequence select="'maxdop'"/>
    <xsl:sequence select="' '"/>
    <xsl:sequence select="string($value)"/>
  </xsl:template>

  <!-- maxrecursion option. -->
  <xsl:template mode="p:query-hint" match="tsql:max-recursion">
    <xsl:variable name="value" as="xs:integer" select="@value"/>
    
    <xsl:sequence select="','"/>
    <xsl:sequence select="' '"/>
    <xsl:sequence select="'maxrecursion'"/>
    <xsl:sequence select="' '"/>
    <xsl:sequence select="string($value)"/>
  </xsl:template>

  <!-- use plan option. -->
  <xsl:template mode="p:query-hint" match="tsql:use-plan">
    <xsl:variable name="value" as="xs:string" select="@value"/>
    <xsl:variable name="escaped-value" as="xs:string"
      select="replace($value, '''', '''''', 'm')"/>
    
    <xsl:sequence select="','"/>
    <xsl:sequence select="' '"/>
    <xsl:sequence select="'use'"/>
    <xsl:sequence select="' '"/>
    <xsl:sequence select="'plan'"/>
    <xsl:sequence select="' '"/>
    <xsl:sequence select="concat('N''', $escaped-value, '''')"/>
  </xsl:template>

  <!-- optimize option. -->
  <xsl:template mode="p:query-hint" match="tsql:optimize">
    <xsl:sequence select="','"/>
    <xsl:sequence select="' '"/>
    <xsl:sequence select="'optimize'"/>
    <xsl:sequence select="' '"/>
    <xsl:sequence select="'for'"/>
    <xsl:sequence select="' '"/>
  
    <xsl:variable name="for" select="tsql:for" as="element()*"/>
  
    <xsl:choose>
      <xsl:when test="not($for)">
        <xsl:sequence select="'unknown'"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:sequence select="'('"/>
        
        <xsl:for-each select="$for">
          <xsl:if test="position() > 1">
            <xsl:sequence select="','"/>
            <xsl:sequence select="' '"/>
          </xsl:if>
        
          <xsl:variable name="items" as="element()+" 
            select="t:get-sql-element(.)"/>
          <xsl:variable name="var" as="element()" 
            select="$items[1][self::sql:var]"/>
          <xsl:variable name="value" as="element()?" select="$items[2]"/>
        
          <xsl:apply-templates mode="t:expression-tokens" select="$var"/>
          <xsl:sequence select="' '"/>
        
          <xsl:choose>
            <xsl:when test="$value">
              <xsl:apply-templates mode="t:expression-tokens" select="$value"/>
            </xsl:when>
            <xsl:otherwise>
              <xsl:sequence select="'unknown'"/>            
            </xsl:otherwise>
          </xsl:choose>
        </xsl:for-each>
    
        <xsl:sequence select="')'"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!-- table hint option. -->
  <xsl:template mode="p:query-hint" match="tsql:table-hint">
    <xsl:variable name="name" as="xs:string" select="@name"/>
    
    <xsl:sequence select="','"/>
    <xsl:sequence select="' '"/>
    <xsl:sequence select="'table'"/>
    <xsl:sequence select="' '"/>
    <xsl:sequence select="'hint'"/>
    <xsl:sequence select="' '"/>
    <xsl:sequence select="'('"/>
    <xsl:sequence select="$name"/>
    <xsl:apply-templates mode="p:table-hint" select="t:get-sql-element(.)"/>
    <xsl:sequence select="')'"/>
  </xsl:template>

  <!-- noexpand table hint. -->
  <xsl:template mode="p:table-hint" match="tsql:no-expand">
    <xsl:sequence select="','"/>
    <xsl:sequence select="' '"/>
    <xsl:sequence select="'noexpand'"/>
  </xsl:template>

  <!-- forcescan table hint. -->
  <xsl:template mode="p:table-hint" match="tsql:force-scan">
    <xsl:sequence select="','"/>
    <xsl:sequence select="' '"/>
    <xsl:sequence select="'forcescan'"/>
  </xsl:template>

  <!-- forceseek table hint. -->
  <xsl:template mode="p:table-hint" match="tsql:force-seek">
    <xsl:sequence select="','"/>
    <xsl:sequence select="' '"/>
    <xsl:sequence select="'forceseek'"/>
  </xsl:template>

  <!-- holdlock table hint. -->
  <xsl:template mode="p:table-hint" match="tsql:hold-lock">
    <xsl:sequence select="','"/>
    <xsl:sequence select="' '"/>
    <xsl:sequence select="'holdlock'"/>
  </xsl:template>

  <!-- nolock table hint. -->
  <xsl:template mode="p:table-hint" match="tsql:no-lock">
    <xsl:sequence select="','"/>
    <xsl:sequence select="' '"/>
    <xsl:sequence select="'nolock'"/>
  </xsl:template>

  <!-- nowait table hint. -->
  <xsl:template mode="p:table-hint" match="tsql:no-wait">
    <xsl:sequence select="','"/>
    <xsl:sequence select="' '"/>
    <xsl:sequence select="'nowait'"/>
  </xsl:template>

  <!-- pagelock table hint. -->
  <xsl:template mode="p:table-hint" match="tsql:page-lock">
    <xsl:sequence select="','"/>
    <xsl:sequence select="' '"/>
    <xsl:sequence select="'paglock'"/>
  </xsl:template>

  <!-- readcommitted table hint. -->
  <xsl:template mode="p:table-hint" match="tsql:read-committed">
    <xsl:sequence select="','"/>
    <xsl:sequence select="' '"/>
    <xsl:sequence select="'readcommitted'"/>
  </xsl:template>

  <!-- readcommittedlock table hint. -->
  <xsl:template mode="p:table-hint" match="tsql:read-committed-lock">
    <xsl:sequence select="','"/>
    <xsl:sequence select="' '"/>
    <xsl:sequence select="'readcommittedlock'"/>
  </xsl:template>

  <!-- readpast table hint. -->
  <xsl:template mode="p:table-hint" match="tsql:read-past">
    <xsl:sequence select="','"/>
    <xsl:sequence select="' '"/>
    <xsl:sequence select="'readpast'"/>
  </xsl:template>

  <!-- readuncommitted table hint. -->
  <xsl:template mode="p:table-hint" match="tsql:read-uncommitted">
    <xsl:sequence select="','"/>
    <xsl:sequence select="' '"/>
    <xsl:sequence select="'readuncommitted'"/>
  </xsl:template>

  <!-- repeatableread table hint. -->
  <xsl:template mode="p:table-hint" match="tsql:repeatable-read">
    <xsl:sequence select="','"/>
    <xsl:sequence select="' '"/>
    <xsl:sequence select="'repeatableread'"/>
  </xsl:template>

  <!-- rowlock table hint. -->
  <xsl:template mode="p:table-hint" match="tsql:row-lock">
    <xsl:sequence select="','"/>
    <xsl:sequence select="' '"/>
    <xsl:sequence select="'rowlock'"/>
  </xsl:template>

  <!-- serializable table hint. -->
  <xsl:template mode="p:table-hint" match="tsql:serializable">
    <xsl:sequence select="','"/>
    <xsl:sequence select="' '"/>
    <xsl:sequence select="'serializable'"/>
  </xsl:template>

  <!-- tablock table hint. -->
  <xsl:template mode="p:table-hint" match="tsql:table-lock">
    <xsl:sequence select="','"/>
    <xsl:sequence select="' '"/>
    <xsl:sequence select="'tablock'"/>
  </xsl:template>

  <!-- tablockx table hint. -->
  <xsl:template mode="p:table-hint" match="tsql:table-lock-x">
    <xsl:sequence select="','"/>
    <xsl:sequence select="' '"/>
    <xsl:sequence select="'tablockx'"/>
  </xsl:template>

  <!-- updlock table hint. -->
  <xsl:template mode="p:table-hint" match="tsql:update-lock">
    <xsl:sequence select="','"/>
    <xsl:sequence select="' '"/>
    <xsl:sequence select="'updlock'"/>
  </xsl:template>

  <!-- x-lock table hint. -->
  <xsl:template mode="p:table-hint" match="tsql:x-lock">
    <xsl:sequence select="','"/>
    <xsl:sequence select="' '"/>
    <xsl:sequence select="'xlock'"/>
  </xsl:template>

  <!-- keepidentity table hint. -->
  <xsl:template mode="p:table-hint" match="tsql:keep-identity">
    <xsl:sequence select="','"/>
    <xsl:sequence select="' '"/>
    <xsl:sequence select="'keepidentity'"/>
  </xsl:template>

  <!-- keepdefaults table hint. -->
  <xsl:template mode="p:table-hint" match="tsql:keep-defaults">
    <xsl:sequence select="','"/>
    <xsl:sequence select="' '"/>
    <xsl:sequence select="'keepdefaults'"/>
  </xsl:template>

  <!-- ignore_constraints table hint. -->
  <xsl:template mode="p:table-hint" match="tsql:ignore-constraints">
    <xsl:sequence select="','"/>
    <xsl:sequence select="' '"/>
    <xsl:sequence select="'ignore_constraints'"/>
  </xsl:template>

  <!-- ignore_triggers table hint. -->
  <xsl:template mode="p:table-hint" match="tsql:ignore-triggers">
    <xsl:sequence select="','"/>
    <xsl:sequence select="' '"/>
    <xsl:sequence select="'ignore_triggers'"/>
  </xsl:template>

  <!-- index (simplified) table hint. -->
  <xsl:template mode="p:table-hint" match="tsql:table-index">
    <xsl:variable name="name" as="xs:string" select="@name"/>
    
    <xsl:sequence select="','"/>
    <xsl:sequence select="' '"/>
    <xsl:sequence select="'index'"/>
    <xsl:sequence select="'('"/>
    <xsl:sequence select="$name"/>
    <xsl:sequence select="')'"/>
  </xsl:template>

  <!-- spatial_window_max_cells table hint. -->
  <xsl:template mode="p:table-hint" match="tsql:spatial-window-max-cells">
    <xsl:variable name="value" as="xs:integer" select="@value"/>
    
    <xsl:sequence select="','"/>
    <xsl:sequence select="' '"/>
    <xsl:sequence select="'spatial_window_max_cells'"/>
    <xsl:sequence select="' '"/>
    <xsl:sequence select="'='"/>
    <xsl:sequence select="' '"/>
    <xsl:sequence select="string($value)"/>
  </xsl:template>

  <!--
    Mode "t:get-table-sources". Gets table sources for the element.
  -->
  <xsl:template mode="t:get-table-sources" 
    match="tsql:table-var | tsql:execute-source">
    <xsl:sequence select="."/>
  </xsl:template>

  <!-- Mode "t:table-source". Generates derived table. -->
  <xsl:template mode="t:table-source" match="sql:function-source" priority="2">
    <xsl:variable name="function" as="element()" select="sql:function"/>

    <xsl:apply-templates mode="t:expression-tokens" select="$function"/>
    <xsl:call-template name="t:source-alias"/>
  </xsl:template>

  <!-- Mode "t:table-source". Generates table variable. -->
  <xsl:template mode="t:table-source" match="tsql:table-var">
    <xsl:variable name="var" as="element()" select="sql:var"/>

    <xsl:apply-templates mode="t:expression-tokens" select="$var"/>
    <xsl:call-template name="t:source-alias"/>
  </xsl:template>

  <!-- Mode "t:table-source". execute source. -->
  <xsl:template mode="t:table-source" match="tsql:execute-source">
    <xsl:variable name="execute" as="element()" select="tsql:execute"/>

    <xsl:apply-templates mode="t:statement-tokens" select="$execute"/>
    <xsl:call-template name="t:source-alias"/>
  </xsl:template>

  <!--
    Mode "t:get-update-set-statements". 
    Get update set statements.
  -->
  <xsl:template mode="t:get-update-set-statements" 
    match="tsql:set-var | tsql:set-property | tsql:set-method">
    <xsl:sequence select="."/>
  </xsl:template>


  <!--
    Mode "t:statement-tokens". Label statement.
  -->
  <xsl:template mode="t:statement-tokens" match="tsql:label">
    <xsl:variable name="label" as="xs:string" select="@label"/>
    <xsl:variable name="statement" as="element()"
      select="t:get-sql-element(.)"/>

    <xsl:sequence select="$t:unindent"/>
    <xsl:sequence select="$label"/>
    <xsl:sequence select="':'"/>
    <xsl:sequence select="$t:indent"/>
    <xsl:sequence select="$t:new-line"/>
    <xsl:apply-templates mode="t:statement-tokens" select="$statement"/>
    <xsl:sequence select="';'"/>
    <xsl:sequence select="$t:new-line"/>
  </xsl:template>
  
  <!--
    Mode "t:statement-tokens". Block statement.
  -->
  <xsl:template mode="t:statement-tokens" match="tsql:block">
    <xsl:variable name="logical-scope" as="xs:boolean?" 
      select="@logical-scope"/>
    <xsl:variable name="statements" as="element()+"
      select="t:get-sql-element(.)"/>

    <xsl:if test="not($logical-scope)">
      <xsl:sequence select="'begin'"/>
      <xsl:sequence select="$t:new-line"/>
      <xsl:sequence select="$t:indent"/>
    </xsl:if>

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
  </xsl:template>

  <!--
    Mode "t:statement-tokens". If statement.
  -->
  <xsl:template mode="t:statement-tokens" match="tsql:if">
    <xsl:variable name="condition" as="element()" select="tsql:condition"/>
    <xsl:variable name="then" as="element()" select="tsql:then"/>
    <xsl:variable name="else" as="element()?" select="tsql:else"/>
    <xsl:variable name="expression" as="element()"
      select="t:get-sql-element($condition)"/>
    <xsl:variable name="then-statements" as="element()+"
      select="t:get-sql-element($then)"/>
    <xsl:variable name="else-statements" as="element()*"
      select="$else/t:get-sql-element(.)"/>

    <xsl:variable name="then-block" as="xs:boolean"
      select="$then-statements[tsql:block] and not($then-statements[2])"/>
    <xsl:variable name="else-block" as="xs:boolean"
      select="$else-statements[tsql:block] and not($else-statements[2])"/>
    <xsl:variable name="else-if" as="xs:boolean"
      select="$else-statements[tsql:if] and not($else-statements[2])"/>

    <xsl:variable name="expression-tokens" as="item()*">
      <xsl:apply-templates mode="t:expression-tokens" select="$expression"/>
    </xsl:variable>

    <xsl:variable name="multiline" as="xs:boolean"
      select="t:is-multiline($expression-tokens)"/>

    <xsl:sequence select="'if'"/>
    <xsl:sequence select="' '"/>

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

    <xsl:choose>
      <xsl:when test="$then-block">
        <xsl:apply-templates mode="t:statement-tokens" 
          select="$then-statements"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:sequence select="'begin'"/>
        <xsl:sequence select="$t:new-line"/>
        <xsl:sequence select="$t:indent"/>

        <xsl:for-each select="$then-statements">
          <xsl:apply-templates mode="t:statement-tokens" select="."/>
          <xsl:sequence select="';'"/>
          <xsl:sequence select="$t:new-line"/>

          <xsl:if test="position() != last()">
            <xsl:sequence select="$t:new-line"/>
          </xsl:if>
        </xsl:for-each>

        <xsl:sequence select="$t:unindent"/>
        <xsl:sequence select="'end'"/>
      </xsl:otherwise>
    </xsl:choose>

    <xsl:if test="exists($else)">
      <xsl:sequence select="$t:new-line"/>
      <xsl:sequence select="'else'"/>

      <xsl:choose>
        <xsl:when test="$else-block">
          <xsl:sequence select="$t:new-line"/>
          <xsl:apply-templates mode="t:statement-tokens"
            select="$else-statements"/>
        </xsl:when>
        <xsl:when test="$else-if">
          <xsl:sequence select="' '"/>
          <xsl:apply-templates mode="t:statement-tokens"
            select="$else-statements"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:sequence select="$t:new-line"/>
          <xsl:sequence select="'begin'"/>
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
          <xsl:sequence select="'end'"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:if>
  </xsl:template>

  <!--
    Mode "t:statement-tokens". While statement.
  -->
  <xsl:template mode="t:statement-tokens" match="tsql:while">
    <xsl:variable name="condition" as="element()" select="tsql:condition"/>
    <xsl:variable name="body" as="element()" select="tsql:body"/>
    <xsl:variable name="expression" as="element()"
      select="t:get-sql-element($condition)"/>
    <xsl:variable name="statements" as="element()+"
      select="t:get-sql-element($body)"/>
    <xsl:variable name="block" as="xs:boolean"
      select="$statements[tsql:block] and not($statements[2])"/>

    <xsl:variable name="expression-tokens" as="item()*">
      <xsl:apply-templates mode="t:expression-tokens" select="$expression"/>
    </xsl:variable>

    <xsl:variable name="multiline" as="xs:boolean"
      select="t:is-multiline($expression-tokens)"/>

    <xsl:sequence select="'while'"/>

    <xsl:sequence select="
      if ($multiline) then
        ($t:new-line, '(', $t:new-line, $t:indent)
      else
        '('"/>

    <xsl:sequence select="$expression-tokens"/>

    <xsl:sequence select="
      if ($multiline) then
        ($t:unindent, $t:new-line, ')', $t:new-line)
      else
        (')')"/>
    
    <xsl:sequence select="$t:new-line"/>

    <xsl:choose>
      <xsl:when test="$block">
        <xsl:apply-templates mode="t:statement-tokens" select="$statements"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:sequence select="$t:indent"/>
        <xsl:sequence select="'begin'"/>
        <xsl:sequence select="$t:new-line"/>

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
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!--
    Mode "t:statement-tokens". break statement.
  -->
  <xsl:template mode="t:statement-tokens" match="tsql:break">
    <xsl:sequence select="'break'"/>
  </xsl:template>

  <!--
    Mode "t:statement-tokens". continue statement.
  -->
  <xsl:template mode="t:statement-tokens" match="tsql:continue">
    <xsl:sequence select="'continue'"/>
  </xsl:template>

  <!--
    Mode "t:statement-tokens". goto statement.
  -->
  <xsl:template mode="t:statement-tokens" match="tsql:goto">
    <xsl:variable name="label" as="xs:string" select="@destination-label"/>
    
    <xsl:sequence select="'goto'"/>
    <xsl:sequence select="' '"/>
    <xsl:sequence select="$label"/>
  </xsl:template>

  <!--
    Mode "t:statement-tokens". try statement.
  -->
  <xsl:template mode="t:statement-tokens" match="tsql:try">
    <xsl:variable name="block" as="element()" select="tsql:block"/>
    <xsl:variable name="catch" as="element()" select="tsql:catcg"/>
    <xsl:variable name="block-statements" as="element()+"
      select="t:get-sql-element($block)"/>
    <xsl:variable name="catch-statements" as="element()+"
      select="t:get-sql-element($block)"/>

    <xsl:sequence select="'begin'"/>
    <xsl:sequence select="' '"/>
    <xsl:sequence select="'try'"/>
    <xsl:sequence select="$t:new-line"/>

    <xsl:for-each select="$block-statements">
      <xsl:apply-templates mode="t:statement-tokens" select="."/>
      <xsl:sequence select="';'"/>
      <xsl:sequence select="$t:new-line"/>

      <xsl:if test="position() != last()">
        <xsl:sequence select="$t:new-line"/>
      </xsl:if>
    </xsl:for-each>

    <xsl:sequence select="'end'"/>
    <xsl:sequence select="' '"/>
    <xsl:sequence select="'try'"/>
    <xsl:sequence select="$t:new-line"/>
    <xsl:sequence select="'begin'"/>
    <xsl:sequence select="' '"/>
    <xsl:sequence select="'catch'"/>
    <xsl:sequence select="$t:new-line"/>

    <xsl:for-each select="$catch-statements">
      <xsl:apply-templates mode="t:statement-tokens" select="."/>
      <xsl:sequence select="';'"/>
      <xsl:sequence select="$t:new-line"/>

      <xsl:if test="position() != last()">
        <xsl:sequence select="$t:new-line"/>
      </xsl:if>
    </xsl:for-each>

    <xsl:sequence select="'end'"/>
    <xsl:sequence select="' '"/>
    <xsl:sequence select="'catch'"/>
  </xsl:template>

  <!--
    Mode "t:statement-tokens". declare-var statement.
  -->
  <xsl:template mode="t:statement-tokens" match="tsql:declare-var">
    <xsl:variable name="name" as="xs:string" select="@name"/>
    <xsl:variable name="type" as="element()" select="sql:type"/>
    <xsl:variable name="default" as="element()?" select="sql:default"/>

    <xsl:sequence select="'declare'"/>
    <xsl:sequence select="' '"/>
    <xsl:sequence select="p:get-var($name)"/>
    <xsl:sequence select="' '"/>

    <xsl:sequence select="t:get-sql-type($type)"/>

    <xsl:if test="exists($default)">
      <xsl:variable name="expression" as="element()"
        select="t:get-sql-element($default)"/>

      <xsl:sequence select="' '"/>
      <xsl:sequence select="'='"/>
      <xsl:sequence select="' '"/>

      <xsl:apply-templates mode="t:expression-tokens" select="$expression"/>
    </xsl:if>
  </xsl:template>

  <!--
    Mode "t:statement-tokens". set-var, set-property, set-method statements.
  -->
  <xsl:template mode="t:statement-tokens"
    match="tsql:set-var | tsql:set-property | tsql:set-method">
    <xsl:sequence select="'set'"/>
    <xsl:sequence select="' '"/>
    <xsl:apply-templates mode="t:update-set-statement" select="."/>
  </xsl:template>

  <!--
    Mode "t:update-set-statement" set of update.
  -->
  <xsl:template mode="t:update-set-statement" match="tsql:set-var">
    <xsl:variable name="name" as="xs:string" select="@name"/>
    <xsl:variable name="expression" as="element()"
      select="t:get-sql-element(.)"/>

    <xsl:sequence select="p:get-var($name)"/>
    <xsl:sequence select="' '"/>
    <xsl:sequence select="'='"/>
    <xsl:sequence select="' '"/>

    <xsl:apply-templates mode="t:expression-tokens" select="$expression"/>
  </xsl:template>

  <!--
    Mode "t:update-set-statement" set-property of update.
  -->
  <xsl:template mode="t:update-set-statement" match="tsql:set-property">
    <xsl:variable name="elements" as="element()+"
      select="t:get-sql-element(.)"/>
    <xsl:variable name="property" as="element()" 
      select="$elements[self::tsql:property]"/>
    <xsl:variable name="expression" as="element()"
      select="subsequence($elements, 2)"/>

    <xsl:apply-templates mode="t:expression-tokens" select="$property"/>
    <xsl:sequence select="' '"/>
    <xsl:sequence select="'='"/>
    <xsl:sequence select="' '"/>
    <xsl:apply-templates mode="t:expression-tokens" select="$expression"/>
  </xsl:template>

  <!--
    Mode "t:update-set-statement" set-method update.
  -->
  <xsl:template mode="t:update-set-statement" match="tsql:set-method">
    <xsl:variable name="element" as="element()"
      select="t:get-sql-element(.)"/>
    <xsl:variable name="method" as="element()"
      select="$element[self::tsql:method]"/>

    <xsl:apply-templates mode="t:expression-tokens" select="$method"/>
  </xsl:template>

  <!--
    Generates set-option tokens.
      $statement - a set-option statement.
      $tokens - leading tokens.
  -->
  <xsl:function name="p:get-set-options-tokens">
    <xsl:param name="statement" as="element()"/>
    <xsl:param name="tokens" as="item()*"/>

    <xsl:variable name="element" as="element()"
      select="t:get-sql-element($statement)"/>

    <xsl:sequence select="'set'"/>
    <xsl:sequence select="' '"/>
    <xsl:sequence select="$tokens"/>
    <xsl:sequence select="' '"/>

    <xsl:choose>
      <xsl:when test="$element[self::tsql:on]">
        <xsl:sequence select="'on'"/>
      </xsl:when>
      <xsl:when test="$element[self::tsql:off]">
        <xsl:sequence select="'off'"/>
      </xsl:when>
      
      <xsl:when test="$element[self::tsql:low]">
        <xsl:sequence select="'low'"/>
      </xsl:when>
      <xsl:when test="$element[self::tsql:normal]">
        <xsl:sequence select="'normal'"/>
      </xsl:when>
      <xsl:when test="$element[self::tsql:high]">
        <xsl:sequence select="'high'"/>
      </xsl:when>
      
      <xsl:when test="$element[self::tsql:read-uncommitted]">
        <xsl:sequence select="'read'"/>
        <xsl:sequence select="' '"/>
        <xsl:sequence select="'uncommitted'"/>
      </xsl:when>
      <xsl:when test="$element[self::tsql:read-committed]">
        <xsl:sequence select="'read'"/>
        <xsl:sequence select="' '"/>
        <xsl:sequence select="'committed'"/>
      </xsl:when>
      <xsl:when test="$element[self::tsql:repeatable-read]">
        <xsl:sequence select="'repeatable'"/>
        <xsl:sequence select="' '"/>
        <xsl:sequence select="'read'"/>
      </xsl:when>
      <xsl:when test="$element[self::tsql:snapshot]">
        <xsl:sequence select="'snapshot'"/>
      </xsl:when>
      <xsl:when test="$element[self::tsql:serializable]">
        <xsl:sequence select="'serializable'"/>
      </xsl:when>

      <xsl:when test="
        $element[self::tsql:var or self::tsql:number or self::tsql:string]">
        <xsl:apply-templates mode="t:expression-tokens" select="$element"/>
      </xsl:when>
    </xsl:choose>
  </xsl:function>

  <!--
    Mode "t:statement-tokens". set-option statement.
  -->
  <xsl:template mode="t:statement-tokens" match="tsql:set-ansi-defaults">
    <xsl:sequence select="p:get-set-options-tokens(., 'ansi_defaults')"/>
  </xsl:template>
 
  <!--
    Mode "t:statement-tokens". set-ansi-null-dflt-off statement.
  -->
  <xsl:template mode="t:statement-tokens" match="tsql:set-ansi-null-dflt-off">
    <xsl:sequence select="p:get-set-options-tokens(., 'ansi_null_dflt_off')"/>
  </xsl:template>
  
  <!--
    Mode "t:statement-tokens". set-ansi-null-dflt-on statement.
  -->
  <xsl:template mode="t:statement-tokens" match="tsql:set-ansi-null-dflt-on">
    <xsl:sequence select="p:get-set-options-tokens(., 'ansi_null_dflt_on')"/>
  </xsl:template>
  
  <!--
    Mode "t:statement-tokens". set-ansi-nulls statement.
  -->
  <xsl:template mode="t:statement-tokens" match="tsql:set-ansi-nulls">
    <xsl:sequence select="p:get-set-options-tokens(., 'ansi_nulls')"/>
  </xsl:template>
  
  <!--
    Mode "t:statement-tokens". set-ansi-padding statement.
  -->
  <xsl:template mode="t:statement-tokens" match="tsql:set-ansi-padding">
    <xsl:sequence select="p:get-set-options-tokens(., 'ansi_padding')"/>
  </xsl:template>
  
  <!--
    Mode "t:statement-tokens". set-ansi-warnings statement.
  -->
  <xsl:template mode="t:statement-tokens" match="tsql:set-ansi-warnings">
    <xsl:sequence select="p:get-set-options-tokens(., 'ansi_warnings')"/>
  </xsl:template>
  
  <!--
    Mode "t:statement-tokens". set-arithabort statement.
  -->
  <xsl:template mode="t:statement-tokens" match="tsql:set-arithabort">
    <xsl:sequence select="p:get-set-options-tokens(., 'arithabort')"/>
  </xsl:template>
  
  <!--
    Mode "t:statement-tokens". set-arithignore statement.
  -->
  <xsl:template mode="t:statement-tokens" match="tsql:set-arithignore">
    <xsl:sequence select="p:get-set-options-tokens(., 'arithignore')"/>
  </xsl:template>
  
  <!--
    Mode "t:statement-tokens". set-concat-null-yields-null statement.
  -->
  <xsl:template mode="t:statement-tokens" 
    match="tsql:set-concat-null-yields-null">
    <xsl:sequence 
      select="p:get-set-options-tokens(., 'concat_null_yields_null')"/>
  </xsl:template>
  
  <!--
    Mode "t:statement-tokens". set-context-info statement.
  -->
  <xsl:template mode="t:statement-tokens" match="tsql:set-context-info">
    <xsl:sequence select="p:get-set-options-tokens(., 'context_info')"/>
  </xsl:template>
  
  <!--
    Mode "t:statement-tokens". set-cursor-close-on-commit statement.
  -->
  <xsl:template mode="t:statement-tokens" 
    match="tsql:set-cursor-close-on-commit">
    <xsl:sequence 
      select="p:get-set-options-tokens(., 'cursor_close_on_commit')"/>
  </xsl:template>
  
  <!--
    Mode "t:statement-tokens". set-datefirst statement.
  -->
  <xsl:template mode="t:statement-tokens" match="tsql:set-datefirst">
    <xsl:sequence select="p:get-set-options-tokens(., 'datefirst')"/>
  </xsl:template>
  
  <!--
    Mode "t:statement-tokens". set-dateformat statement.
  -->
  <xsl:template mode="t:statement-tokens" match="tsql:set-dateformat">
    <xsl:sequence select="p:get-set-options-tokens(., 'dateformat')"/>
  </xsl:template>
  
  <!--
    Mode "t:statement-tokens". set-deadlock-priority statement.
  -->
  <xsl:template mode="t:statement-tokens" match="tsql:set-deadlock-priority">
    <xsl:sequence select="p:get-set-options-tokens(., 'deadlock_priority')"/>
  </xsl:template>
  
  <!--
    Mode "t:statement-tokens". set-fips-flagger statement.
  -->
  <xsl:template mode="t:statement-tokens" match="tsql:set-fips-flagger">
    <xsl:sequence select="p:get-set-options-tokens(., 'fips_flagger')"/>
  </xsl:template>
  
  <!--
    Mode "t:statement-tokens". set-fmtonly statement.
  -->
  <xsl:template mode="t:statement-tokens" match="tsql:set-fmtonly">
    <xsl:sequence select="p:get-set-options-tokens(., 'fmtonly')"/>
  </xsl:template>
  
  <!--
    Mode "t:statement-tokens". set-forceplan statement.
  -->
  <xsl:template mode="t:statement-tokens" match="tsql:set-forceplan">
    <xsl:sequence select="p:get-set-options-tokens(., 'forceplan')"/>
  </xsl:template>
  
  <!--
    Mode "t:statement-tokens". set-identity-insert statement.
  -->
  <xsl:template mode="t:statement-tokens" match="tsql:set-identity-insert">
    <xsl:sequence select="p:get-set-options-tokens(., 'identity_insert')"/>
  </xsl:template>
  
  <!--
    Mode "t:statement-tokens". set-implicit-transactions statement.
  -->
  <xsl:template mode="t:statement-tokens" 
    match="tsql:set-implicit-transactions">
    <xsl:sequence 
      select="p:get-set-options-tokens(., 'implicit_transactions')"/>
  </xsl:template>
  
  <!--
    Mode "t:statement-tokens". set-language statement.
  -->
  <xsl:template mode="t:statement-tokens" match="tsql:set-language">
    <xsl:sequence select="p:get-set-options-tokens(., 'language')"/>
  </xsl:template>
  
  <!--
    Mode "t:statement-tokens". set-lock-timeout statement.
  -->
  <xsl:template mode="t:statement-tokens" match="tsql:set-lock-timeout">
    <xsl:sequence select="p:get-set-options-tokens(., 'lock_timeout')"/>
  </xsl:template>
  
  <!--
    Mode "t:statement-tokens". set-nocount statement.
  -->
  <xsl:template mode="t:statement-tokens" match="tsql:set-nocount">
    <xsl:sequence select="p:get-set-options-tokens(., 'nocount')"/>
  </xsl:template>
  
  <!--
    Mode "t:statement-tokens". set-noexec statement.
  -->
  <xsl:template mode="t:statement-tokens" match="tsql:set-noexec">
    <xsl:sequence select="p:get-set-options-tokens(., 'noexec')"/>
  </xsl:template>
  
  <!--
    Mode "t:statement-tokens". set-numeric-roundabort statement.
  -->
  <xsl:template mode="t:statement-tokens" match="tsql:set-numeric-roundabort">
    <xsl:sequence select="p:get-set-options-tokens(., 'numeric_roundabort')"/>
  </xsl:template>
  
  <!--
    Mode "t:statement-tokens". set-offsets statement.
  -->
  <xsl:template mode="t:statement-tokens" match="tsql:set-offsets">
    <xsl:sequence select="p:get-set-options-tokens(., 'offsets')"/>
  </xsl:template>
  
  <!--
    Mode "t:statement-tokens". set-parseonly statement.
  -->
  <xsl:template mode="t:statement-tokens" match="tsql:set-parseonly">
    <xsl:sequence select="p:get-set-options-tokens(., 'parseonly')"/>
  </xsl:template>
  
  <!--
    Mode "t:statement-tokens". set-query-governor-cost-limit statement.
  -->
  <xsl:template mode="t:statement-tokens" 
    match="tsql:set-query-governor-cost-limit">
    <xsl:sequence 
      select="p:get-set-options-tokens(., 'query_governor_cost_limit')"/>
  </xsl:template>
  
  <!--
    Mode "t:statement-tokens". set-quoted-identifier statement.
  -->
  <xsl:template mode="t:statement-tokens" match="tsql:set-quoted-identifier">
    <xsl:sequence select="p:get-set-options-tokens(., 'quoted_identifier')"/>
  </xsl:template>
  
  <!--
    Mode "t:statement-tokens". set-remote-proc-transactions statement.
  -->
  <xsl:template mode="t:statement-tokens" 
    match="tsql:set-remote-proc-transactions">
    <xsl:sequence 
      select="p:get-set-options-tokens(., 'remote_proc_transactions')"/>
  </xsl:template>
  
  <!--
    Mode "t:statement-tokens". set-rowcount statement.
  -->
  <xsl:template mode="t:statement-tokens" match="tsql:set-rowcount">
    <xsl:sequence select="p:get-set-options-tokens(., 'rowcount')"/>
  </xsl:template>
  
  <!--
    Mode "t:statement-tokens". set-showplan-all statement.
  -->
  <xsl:template mode="t:statement-tokens" match="tsql:set-showplan-all">
    <xsl:sequence select="p:get-set-options-tokens(., 'showplan_all')"/>
  </xsl:template>
  
  <!--
    Mode "t:statement-tokens". set-showplan-text statement.
  -->
  <xsl:template mode="t:statement-tokens" match="tsql:set-showplan-text">
    <xsl:sequence select="p:get-set-options-tokens(., 'showplan_text')"/>
  </xsl:template>
  
  <!--
    Mode "t:statement-tokens". set-showplan-xml statement.
  -->
  <xsl:template mode="t:statement-tokens" match="tsql:set-showplan-xml">
    <xsl:sequence select="p:get-set-options-tokens(., 'showplan_xml')"/>
  </xsl:template>
  
  <!--
    Mode "t:statement-tokens". set-statistics-io statement.
  -->
  <xsl:template mode="t:statement-tokens" match="tsql:set-statistics-io">
    <xsl:sequence 
      select="p:get-set-options-tokens(., ('statistics', ' ', 'io'))"/>
  </xsl:template>
  
  <!--
    Mode "t:statement-tokens". set-statistics-profile statement.
  -->
  <xsl:template mode="t:statement-tokens" match="tsql:set-statistics-profile">
    <xsl:sequence 
      select="p:get-set-options-tokens(., ('statistics', ' ', 'profile'))"/>
  </xsl:template>
  
  <!--
    Mode "t:statement-tokens". set-statistics-time statement.
  -->
  <xsl:template mode="t:statement-tokens" match="tsql:set-statistics-time">
    <xsl:sequence 
      select="p:get-set-options-tokens(., ('statistics', ' ', 'time'))"/>
  </xsl:template>
  
  <!--
    Mode "t:statement-tokens". set-statistics-xml statement.
  -->
  <xsl:template mode="t:statement-tokens" match="tsql:set-statistics-xml">
    <xsl:sequence 
      select="p:get-set-options-tokens(., ('statistics', ' ', 'xml'))"/>
  </xsl:template>
  
  <!--
    Mode "t:statement-tokens". set-textsize statement.
  -->
  <xsl:template mode="t:statement-tokens" match="tsql:set-textsize">
    <xsl:sequence select="p:get-set-options-tokens(., 'textsize')"/>
  </xsl:template>
  
  <!--
    Mode "t:statement-tokens". set-transaction-isolation-level statement.
  -->
  <xsl:template mode="t:statement-tokens" 
    match="tsql:set-transaction-isolation-level">
    <xsl:sequence select="
      p:get-set-options-tokens
      (
        ., 
        ('transaction', ' ', 'isolation', ' ', 'level')
      )"/>
  </xsl:template>
  
  <!--
    Mode "t:statement-tokens". set-xact-abort statement.
  -->
  <xsl:template mode="t:statement-tokens" match="tsql:set-xact-abort">
    <xsl:sequence select="p:get-set-options-tokens(., 'xact_abort')"/>
  </xsl:template>

  <!--
    Mode "t:statement-tokens". print statement.
  -->
  <xsl:template mode="t:statement-tokens" match="tsql:print">
    <xsl:variable name="expression" as="element()"
      select="t:get-sql-element(.)"/>

    <xsl:sequence select="'print'"/>
    <xsl:sequence select="' '"/>
    <xsl:apply-templates mode="t:expression-tokens" select="$expression"/>
  </xsl:template>

  <!--
    Mode "t:statement-tokens". raiserror statement.
  -->
  <xsl:template mode="t:statement-tokens" match="tsql:raiserror">
    <xsl:variable name="expression" as="element()"
      select="t:get-sql-element(tsql:message)"/>
    <xsl:variable name="arguments" as="element()*"
      select="tsql:argument/t:get-sql-element(.)"/>
    <xsl:variable name="log" as="xs:boolean?" select="@log"/>
    <xsl:variable name="nowait" as="xs:boolean?" select="@nowait"/>
    <xsl:variable name="seterror" as="xs:boolean?" select="seterror"/>

    <xsl:sequence select="'raiserror'"/>
    <xsl:sequence select="'('"/>
    <xsl:apply-templates mode="t:expression-tokens" select="$expression"/>
    <xsl:sequence select="','"/>
    <xsl:sequence select="' '"/>
    <xsl:sequence select="string(xs:integer(@severity))"/>
    <xsl:sequence select="','"/>
    <xsl:sequence select="' '"/>
    <xsl:sequence select="string(xs:integer(@state))"/>

    <xsl:for-each select="$arguments">
      <xsl:sequence select="','"/>
      <xsl:sequence select="' '"/>
      <xsl:apply-templates mode="t:expression-tokens" select="."/>
    </xsl:for-each>
    
    <xsl:sequence select="')'"/>

    <xsl:if test="$log or $nowait or $seterror">
      <xsl:sequence select="' '"/>
      <xsl:sequence select="'with'"/>

      <xsl:if test="$log">
        <xsl:sequence select="' '"/>
        <xsl:sequence select="'log'"/>
      </xsl:if>

      <xsl:if test="$nowait">
        <xsl:sequence select="' '"/>
        <xsl:sequence select="'nowait'"/>
      </xsl:if>

      <xsl:if test="$seterror">
        <xsl:sequence select="' '"/>
        <xsl:sequence select="'seterror'"/>
      </xsl:if>
    </xsl:if>
  </xsl:template>

  <!--
    Mode "t:statement-tokens". throw statement.
  -->
  <xsl:template mode="t:statement-tokens" match="tsql:throw">
    <xsl:sequence select="'throw'"/>

    <xsl:if test="t:get-sql-element(.)">
      <xsl:variable name="error-number" as="element()"
        select="t:get-sql-element(tsql:error-number)"/>
      <xsl:variable name="message" as="element()"
        select="t:get-sql-element(tsql:message)"/>
      <xsl:variable name="state" as="element()"
        select="t:get-sql-element(tsql:state)"/>

      <xsl:sequence select="' '"/>
      <xsl:apply-templates mode="t:expression-tokens" select="$error-number"/>
      <xsl:sequence select="','"/>
      <xsl:sequence select="' '"/>
      <xsl:apply-templates mode="t:expression-tokens" select="$message"/>
      <xsl:sequence select="','"/>
      <xsl:sequence select="' '"/>
      <xsl:apply-templates mode="t:expression-tokens" select="$state"/>
    </xsl:if>
  </xsl:template>

  <!--
    Mode "t:statement-tokens". declare-cursor statement.
  -->
  <xsl:template mode="t:statement-tokens" match="tsql:declare-cursor">
    <xsl:variable name="name" as="xs:string" select="@name"/>
    <xsl:variable name="select" as="element()" select="t:get-select(.)"/>
    <xsl:variable name="iso" as="xs:boolean" select="@iso"/>
    <xsl:variable name="implementation" as="xs:string?"
      select="@implementation"/>
    <xsl:variable name="scroll" as="xs:boolean?" select="@scroll"/>
    <xsl:variable name="access" as="xs:string?" select="@access"/>
    <xsl:variable name="for-update" as="element()?" select="tsql:for-update"/>

    <xsl:sequence select="'declare'"/>
    <xsl:sequence select="' '"/>
    <xsl:sequence select="$name"/>
    <xsl:sequence select="' '"/>

    <xsl:choose>
      <xsl:when test="$iso">
        <xsl:if test="$implementation = 'intensive'">
          <xsl:sequence select="'intensive'"/>
          <xsl:sequence select="' '"/>
        </xsl:if>

        <xsl:if test="$scroll">
          <xsl:sequence select="'scroll'"/>
          <xsl:sequence select="' '"/>
        </xsl:if>

        <xsl:sequence select="'cursor'"/>
        <xsl:sequence select="' '"/>

        <xsl:sequence select="$t:new-line"/>
        <xsl:sequence select="$t:indent"/>
        <xsl:sequence select="'for'"/>
        <xsl:sequence select="' '"/>
        <xsl:apply-templates mode="t:statement-tokens" select="$select"/>
        
        <xsl:choose>
          <xsl:when test="$access = 'readonly'">
            <xsl:sequence select="$t:new-line"/>
            <xsl:sequence select="'for'"/>
            <xsl:sequence select="' '"/>
            <xsl:sequence select="'read only'"/>
          </xsl:when>
          <xsl:when test="$for-update">
            <xsl:sequence select="$t:new-line"/>
            <xsl:sequence select="'for'"/>
            <xsl:sequence select="' '"/>
            <xsl:sequence select="'update'"/>
            <xsl:sequence select="' '"/>
            <xsl:sequence select="'of'"/>
            <xsl:sequence select="$t:new-line"/>
            <xsl:sequence select="$t:indent"/>

            <xsl:for-each select="$for-update/sql:field">
              <xsl:if test="position() > 1">
                <xsl:sequence select="','"/>
                <xsl:sequence select="' '"/>
              </xsl:if>

              <xsl:apply-templates mode="t:expression-tokens" select="."/>
            </xsl:for-each>
            
            <xsl:sequence select="$t:unindent"/>
          </xsl:when>
        </xsl:choose>
      </xsl:when>
      <xsl:otherwise>
        <xsl:variable name="scope" as="xs:string?" select="@scope"/>

        <xsl:sequence select="'cursor'"/>
        
        <xsl:choose>
          <xsl:when test ="$scope = 'local'">
            <xsl:sequence select="' '"/>
            <xsl:sequence select="'local'"/>
          </xsl:when>
          <xsl:when test ="$scope = 'global'">
            <xsl:sequence select="' '"/>
            <xsl:sequence select="'global'"/>
          </xsl:when>
        </xsl:choose>

        <xsl:choose>
          <xsl:when test="xs:boolean(@forward-only)">
            <xsl:sequence select="' '"/>
            <xsl:sequence select="'forward_only'"/>
          </xsl:when>
          <xsl:when test="$scroll">
            <xsl:sequence select="' '"/>
            <xsl:sequence select="'scroll'"/>
          </xsl:when>
        </xsl:choose>

        <xsl:choose>
          <xsl:when test="$implementation = 'static'">
            <xsl:sequence select="' '"/>
            <xsl:sequence select="'static'"/>
          </xsl:when>
          <xsl:when test="$implementation = 'keyset'">
            <xsl:sequence select="' '"/>
            <xsl:sequence select="'keyset'"/>
          </xsl:when>
          <xsl:when test="$implementation = 'dynamic'">
            <xsl:sequence select="' '"/>
            <xsl:sequence select="'dynamic'"/>
          </xsl:when>
          <xsl:when test="$implementation = 'fast-forward'">
            <xsl:sequence select="' '"/>
            <xsl:sequence select="'fast_forward'"/>
          </xsl:when>
        </xsl:choose>

        <xsl:choose>
          <xsl:when test="$access = 'readonly'">
            <xsl:sequence select="' '"/>
            <xsl:sequence select="'read_only'"/>
          </xsl:when>
          <xsl:when test="$access = 'scroll-locks'">
            <xsl:sequence select="' '"/>
            <xsl:sequence select="'scroll_locks'"/>
          </xsl:when>
          <xsl:when test="$access = 'optimistic'">
            <xsl:sequence select="' '"/>
            <xsl:sequence select="'optimistic'"/>
          </xsl:when>
        </xsl:choose>
        
        <xsl:if test="xs:boolean(@type-warning)">
          <xsl:sequence select="' '"/>
          <xsl:sequence select="'type_warnings'"/>
        </xsl:if>

        <xsl:sequence select="$t:new-line"/>
        <xsl:sequence select="$t:indent"/>
        <xsl:sequence select="'for'"/>
        <xsl:sequence select="' '"/>
        <xsl:apply-templates mode="t:statement-tokens" select="$select"/>
        
        <xsl:sequence select="$t:new-line"/>
        <xsl:sequence select="'for'"/>
        <xsl:sequence select="' '"/>
        <xsl:sequence select="'update'"/>
        <xsl:sequence select="' '"/>
        <xsl:sequence select="'of'"/>
        <xsl:sequence select="$t:new-line"/>
        <xsl:sequence select="$t:indent"/>

        <xsl:for-each select="$for-update/sql:field">
          <xsl:if test="position() > 1">
            <xsl:sequence select="','"/>
            <xsl:sequence select="' '"/>
          </xsl:if>

          <xsl:apply-templates mode="t:expression-tokens" select="."/>
        </xsl:for-each>
            
        <xsl:sequence select="$t:unindent"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!--
    Mode "t:statement-tokens". deallocate statement.
  -->
  <xsl:template mode="t:statement-tokens" match="tsql:deallocate">
    <xsl:variable name="name" as="element()">
      <xsl:apply-templates mode="t:get-var-or-name"
        select="t:get-sql-element(.)"/>
    </xsl:variable>

    <xsl:sequence select="'deallocate'"/>
    <xsl:sequence select="' '"/>

    <xsl:if test="xs:boolean(@global)">
      <xsl:sequence select="'global'"/>
      <xsl:sequence select="' '"/>
    </xsl:if>

    <xsl:apply-templates mode="t:var-or-name" select="$name"/>
  </xsl:template>

  <!--
    Mode "t:statement-tokens". open statement.
  -->
  <xsl:template mode="t:statement-tokens" match="tsql:open">
    <xsl:variable name="name" as="element()">
      <xsl:apply-templates mode="t:get-var-or-name"
        select="t:get-sql-element(.)"/>
    </xsl:variable>

    <xsl:sequence select="'open'"/>
    <xsl:sequence select="' '"/>

    <xsl:if test="xs:boolean(@global)">
      <xsl:sequence select="'global'"/>
      <xsl:sequence select="' '"/>
    </xsl:if>

    <xsl:apply-templates mode="t:var-or-name" select="$name"/>
  </xsl:template>

  <!--
    Mode "t:statement-tokens". close statement.
  -->
  <xsl:template mode="t:statement-tokens" match="tsql:close">
    <xsl:variable name="name" as="element()">
      <xsl:apply-templates mode="t:get-var-or-name"
        select="t:get-sql-element(.)"/>
    </xsl:variable>

    <xsl:sequence select="'close'"/>
    <xsl:sequence select="' '"/>

    <xsl:if test="xs:boolean(@global)">
      <xsl:sequence select="'global'"/>
      <xsl:sequence select="' '"/>
    </xsl:if>

    <xsl:apply-templates mode="t:var-or-name" select="$name"/>
  </xsl:template>

  <!--
    Mode "t:statement-tokens". fetch statement.
  -->
  <xsl:template mode="t:statement-tokens" match="tsql:fetch">
    <xsl:variable name="into" as="element()" select="sql:into"/>
    <xsl:variable name="direction" as="xs:string?" select="@direction"/>

    <xsl:variable name="name" as="element()">
      <xsl:apply-templates mode="t:get-var-or-name"
        select="t:get-sql-element(.)"/>
    </xsl:variable>

    <xsl:sequence select="'fetch'"/>

    <xsl:choose>
      <xsl:when test="$direction = 'next'">
        <xsl:sequence select="' '"/>
        <xsl:sequence select="'next'"/>
      </xsl:when>
      <xsl:when test="$direction = 'prior'">
        <xsl:sequence select="' '"/>
        <xsl:sequence select="'prior'"/>
      </xsl:when>
      <xsl:when test="$direction = 'first'">
        <xsl:sequence select="' '"/>
        <xsl:sequence select="'first'"/>
      </xsl:when>
      <xsl:when test="$direction = 'last'">
        <xsl:sequence select="' '"/>
        <xsl:sequence select="'last'"/>
      </xsl:when>
      <xsl:when test="$direction = 'absolute'">
        <xsl:variable name="offset" as="element()"
          select="t:get-sql-element(tsql:offset)"/>

        <xsl:sequence select="' '"/>
        <xsl:sequence select="'absolute'"/>
        <xsl:apply-templates mode="t:expression-tokens" select="$offset"/>
      </xsl:when>
      <xsl:when test="$direction = 'relative'">
        <xsl:variable name="offset" as="element()"
          select="t:get-sql-element(tsql:offset)"/>

        <xsl:sequence select="' '"/>
        <xsl:sequence select="'relative'"/>
        <xsl:apply-templates mode="t:expression-tokens" select="$offset"/>
      </xsl:when>
    </xsl:choose>

    <xsl:sequence select="' '"/>
    <xsl:sequence select="'from'"/>
    <xsl:sequence select="' '"/>

    <xsl:if test="xs:boolean(@global)">
      <xsl:sequence select="'global'"/>
      <xsl:sequence select="' '"/>
    </xsl:if>

    <xsl:apply-templates mode="t:var-or-name" select="$name"/>

    <xsl:call-template name="t:generate-into-clause">
      <xsl:with-param name="into" select="$into"/>
    </xsl:call-template>
  </xsl:template>

  <!--
    Mode "t:statement-tokens". execute statement.
  -->
  <xsl:template mode="t:statement-tokens" match="tsql:execute">
    <xsl:variable name="return" as="element()?" select="tsql:return"/>
    <xsl:variable name="params" as="element()*" select="tsql:param"/>
    <xsl:variable name="recompile" as="xs:boolean?" select="@with-recompile"/>

    <xsl:variable name="name" as="element()">
      <xsl:apply-templates mode="t:get-var-or-qualified-name"
        select="t:get-sql-element(.)"/>
    </xsl:variable>

    <xsl:sequence select="'execute'"/>

    <xsl:if test="$return">
      <xsl:variable name="var" as="element()" select="$return/sql:var"/>

      <xsl:sequence select="' '"/>
      <xsl:apply-templates mode="t:expression-tokens" select="$var"/>
      <xsl:sequence select="' '"/>
      <xsl:sequence select="'='"/>
    </xsl:if>

    <xsl:sequence select="' '"/>
    <xsl:apply-templates mode="t:var-or-qualified-name" select="$name"/>

    <xsl:for-each select="$params">
      <xsl:variable name="param-name" as="xs:string?" select="@name"/>
      <xsl:variable name="param-output" as="xs:boolean?" select="@output"/>
      <xsl:variable name="expression" as="element()" 
        select="t:get-sql-element(.)"/>

      <xsl:if test="position() > 1">
        <xsl:sequence select="','"/>
      </xsl:if>
      
      <xsl:sequence select="$t:new-line"/>
      <xsl:sequence select="$t:indent"/>

      <xsl:if test="exists($param-name)">
        <xsl:sequence select="p:get-var($param-name)"/>
        <xsl:sequence select="' '"/>
        <xsl:sequence select="'='"/>
      </xsl:if>

      <xsl:apply-templates mode="t:expression-tokens" select="$expression"/>

      <xsl:if test="$param-output">
        <xsl:sequence select="' '"/>
        <xsl:sequence select="'output'"/>
      </xsl:if>

      <xsl:sequence select="$t:unindent"/>
    </xsl:for-each>

    <xsl:if test="$recompile">
      <xsl:sequence select="$t:new-line"/>
      <xsl:sequence select="$t:indent"/>
      <xsl:sequence select="'with'"/>
      <xsl:sequence select="' '"/>
      <xsl:sequence select="'recompile'"/>
      <xsl:sequence select="$t:unindent"/>
    </xsl:if>
  </xsl:template>

  <!--
    Mode "t:statement-tokens". begin transaction statement.
  -->
  <xsl:template mode="t:statement-tokens" match="tsql:begin-transaction">
    <xsl:variable name="distributed" as="xs:boolean?" select="@distributed"/>
    <xsl:variable name="description" as="xs:string?" select="@description"/>

    <xsl:variable name="name" as="element()?">
      <xsl:apply-templates mode="t:get-var-or-name"
        select="t:get-sql-element(.)"/>
    </xsl:variable>

    <xsl:sequence select="'begin'"/>

    <xsl:if test="$distributed">
      <xsl:sequence select="' '"/>
      <xsl:sequence select="'distributed'"/>
    </xsl:if>
    
    <xsl:sequence select="' '"/>
    <xsl:sequence select="'transaction'"/>

    <xsl:if test="$name">
      <xsl:sequence select="' '"/>
      <xsl:apply-templates mode="t:var-or-name" select="$name"/>
    </xsl:if>

    <xsl:if test="$description and not($distributed)">
      <xsl:sequence select="'with'"/>
      <xsl:sequence select="' '"/>
      <xsl:sequence select="'mark'"/>
      <xsl:sequence select="' '"/>

      <xsl:variable name="escaped-value" as="xs:string"
        select="replace($description, '''', '''''', 'm')"/>

      <xsl:sequence select="concat('''', $escaped-value, '''')"/>
    </xsl:if>
  </xsl:template>

  <!--
    Mode "t:statement-tokens". commit statement.
  -->
  <xsl:template mode="t:statement-tokens" match="tsql:commit">
    <xsl:variable name="name" as="element()?">
      <xsl:apply-templates mode="t:get-var-or-name"
        select="t:get-sql-element(.)"/>
    </xsl:variable>

    <xsl:sequence select="'commit'"/>
    <xsl:sequence select="' '"/>
    <xsl:sequence select="'transaction'"/>

    <xsl:if test="$name">
      <xsl:sequence select="' '"/>
      <xsl:apply-templates mode="t:var-or-name" select="$name"/>
    </xsl:if>
  </xsl:template>

  <!--
    Mode "t:statement-tokens". rollback statement.
  -->
  <xsl:template mode="t:statement-tokens" match="tsql:rollback">
    <xsl:variable name="name" as="element()?">
      <xsl:apply-templates mode="t:get-var-or-name"
        select="t:get-sql-element(.)"/>
    </xsl:variable>

    <xsl:sequence select="'rollback'"/>
    <xsl:sequence select="' '"/>
    <xsl:sequence select="'transaction'"/>

    <xsl:if test="$name">
      <xsl:sequence select="' '"/>
      <xsl:apply-templates mode="t:var-or-name" select="$name"/>
    </xsl:if>
  </xsl:template>

  <!--
    Mode "t:statement-tokens". save transaction statement.
  -->
  <xsl:template mode="t:statement-tokens" match="tsql:save-transaction">
    <xsl:variable name="name" as="element()">
      <xsl:apply-templates mode="t:get-var-or-name"
        select="t:get-sql-element(.)"/>
    </xsl:variable>

    <xsl:sequence select="'save'"/>
    <xsl:sequence select="' '"/>
    <xsl:sequence select="'transaction'"/>
    <xsl:sequence select="' '"/>
    <xsl:apply-templates mode="t:var-or-name" select="$name"/>
  </xsl:template>

  <!--
    Mode "t:expression-tokens". next-value-for.
  -->
  <xsl:template mode="t:expression-tokens" match="tsql:next-value-for">
    <xsl:variable name="over" as="element()?" select="sql:over"/>

    <xsl:sequence select="'next'"/>
    <xsl:sequence select="' '"/>
    <xsl:sequence select="'value'"/>
    <xsl:sequence select="' '"/>
    <xsl:sequence select="'for'"/>
    <xsl:sequence select="' '"/>

    <xsl:call-template name="t:qualified-name"/>
    <xsl:apply-templates mode="t:get-over-clause" select="$over"/>
  </xsl:template>

  <!--
    Mode "t:expression-tokens". convert or try_convert.
  -->
  <xsl:template mode="t:expression-tokens" 
    match="tsql:convert | tsql:try-convert">
    <xsl:variable name="value" as="element()"
      select="t:get-sql-element(tsql:value)"/>
    <xsl:variable name="style" as="element()?"
      select="tsql:style/t:get-sql-element(.)"/>
    <xsl:variable name="type" as="element()" select="sql:type"/>

    <xsl:sequence select="
      if (self::tsql:convert) then
        'convert'
      else
        'try_convert'"/>
    
    <xsl:sequence select="'('"/>

    <xsl:sequence select="t:get-sql-type($type)"/>
    <xsl:sequence select="','"/>
    <xsl:sequence select="' '"/>
    <xsl:apply-templates mode="t:expression-tokens" select="$value"/>

    <xsl:if test="$style">
      <xsl:sequence select="','"/>
      <xsl:sequence select="' '"/>
      <xsl:apply-templates mode="t:expression-tokens" select="$style"/>
    </xsl:if>

    <xsl:sequence select="')'"/>
  </xsl:template>

  <!--
    Mode "t:expression-tokens". try_cast.
  -->
  <xsl:template mode="t:expression-tokens" match="tsql:try-cast">
    <xsl:variable name="tokens" as="item()+">
      <xsl:call-template name="t:cast"/>
    </xsl:variable>

    <xsl:sequence select="'try_cast'"/>
    <xsl:sequence select="subsequence($tokens, 2)"/>
  </xsl:template>

  <!--
    Mode "t:expression-tokens". parse or try_parse.
  -->
  <xsl:template mode="t:expression-tokens" match="tsql:parse | tsql:try-parse">
    <xsl:variable name="value" as="element()"
      select="t:get-sql-element(tsql:value)"/>
    <xsl:variable name="culture" as="element()?"
      select="tsql:culture/t:get-sql-element(.)"/>
    <xsl:variable name="type" as="element()" select="sql:type"/>

    <xsl:sequence select="
      if (self::tsql:parse) then
        'parse'
      else
        'try_parse'"/>

    <xsl:sequence select="'('"/>
    <xsl:apply-templates mode="t:expression-tokens" select="$value"/>
    <xsl:sequence select="' '"/>
    <xsl:sequence select="'as'"/>
    <xsl:sequence select="' '"/>
    <xsl:sequence select="t:get-sql-type($type)"/>

    <xsl:if test="$culture">
      <xsl:sequence select="' '"/>
      <xsl:sequence select="'using'"/>
      <xsl:sequence select="' '"/>
      <xsl:apply-templates mode="t:expression-tokens" select="$culture"/>
    </xsl:if>

    <xsl:sequence select="')'"/>
  </xsl:template>

  <!--
    Mode "t:expression-tokens". collation.
  -->
  <xsl:template mode="t:expression-tokens" match="tsql:collation">
    <xsl:variable name="expression" as="element()"
      select="t:get-sql-element(.)"/>
    <xsl:variable name="name" as="xs:string" select="@name"/>

    <xsl:apply-templates mode="t:expression-tokens" select="$expression"/>
    <xsl:sequence select="' '"/>
    <xsl:sequence select="'collate'"/>
    <xsl:sequence select="' '"/>
    <xsl:sequence select="$name"/>
  </xsl:template>

  <!--
    Mode "t:expression-tokens". property.
  -->
  <xsl:template mode="t:expression-tokens" match="tsql:property">
    <xsl:variable name="expression" as="element()"
      select="t:get-sql-element(.)"/>
    <xsl:variable name="name" as="xs:string" select="@name"/>

    <xsl:apply-templates mode="t:expression-tokens" select="$expression"/>
    <xsl:sequence select="'.'"/>
    <xsl:sequence select="$name"/>
  </xsl:template>

  <!--
    Mode "t:expression-tokens". method.
  -->
  <xsl:template mode="t:expression-tokens" match="tsql:method">
    <xsl:variable name="instance" as="element()?" select="tsql:instance"/>
    <xsl:variable name="name" as="xs:string" select="@name"/>
    <xsl:variable name="arguments" as="element()?" 
      select="tsql:arguments/t:get-sql-element(.)"/>
    

    <xsl:choose>
      <xsl:when test="$instance">
        <xsl:variable name="expression" as="element()"
          select="t:get-sql-element($instance)"/>
        
        <xsl:apply-templates mode="t:expression-tokens" select="$expression"/>
        <xsl:sequence select="'.'"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:sequence select="t:get-sql-type(sql:type)"/>
        <xsl:sequence select="'::'"/>
      </xsl:otherwise>
    </xsl:choose>
    
    <xsl:sequence select="$name"/>
    <xsl:sequence select="'('"/>

    <xsl:for-each select="$arguments">
      <xsl:if test="position() > 1">
        <xsl:sequence select="','"/>
        <xsl:sequence select="' '"/>
      </xsl:if>

      <xsl:apply-templates mode="t:expression-tokens" select="."/>
    </xsl:for-each>
    
    <xsl:sequence select="')'"/>
  </xsl:template>

  <!--
    Mode "t:expression-tokens". simple-case.
  -->
  <xsl:template mode="t:expression-tokens" match="tsql:simple-case">
    <xsl:variable name="value" as="element()"
      select="t:get-sql-element(tsql:value)"/>
    <xsl:variable name="when" as="element()+" select="tsql:when"/>
    <xsl:variable name="else" as="element()?" select="else"/>

    <xsl:sequence select="'case'"/>
    <xsl:sequence select="' '"/>

    <xsl:apply-templates mode="t:expression-tokens" select="$value"/>

    <xsl:sequence select="$t:indent"/>

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
  <xsl:template mode="t:expression-tokens" match="tsql:search-case">
    <xsl:variable name="when" as="element()+" select="tsql:when"/>
    <xsl:variable name="else" as="element()?" select="else"/>

    <xsl:sequence select="'case'"/>
    <xsl:sequence select="$t:indent"/>

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
    Mode "t:expression-tokens". iif expression.
  -->
  <xsl:template mode="t:expression-tokens" match="tsql:search-case">
    <xsl:variable name="condition" as="element()"
      select="t:get-sql-element(tsql:condition)"/>
    <xsl:variable name="then" as="element()"
      select="t:get-sql-element(tsql:then)"/>
    <xsl:variable name="else" as="element()"
      select="t:get-sql-element(tsql:else)"/>

    <xsl:variable name="condition-tokens" as="item()*">
      <xsl:apply-templates mode="t:expression-tokens" select="$condition"/>
    </xsl:variable>

    <xsl:variable name="then-tokens" as="item()*">
      <xsl:apply-templates mode="t:expression-tokens" select="$then"/>
    </xsl:variable>
    
    <xsl:variable name="else-tokens" as="item()*">
      <xsl:apply-templates mode="t:expression-tokens" select="$else"/>
    </xsl:variable>

    <xsl:variable name="multiline" as="xs:boolean" select="
      t:is-multiline($condition-tokens) or
      t:is-multiline($then-tokens) or
      t:is-multiline($else-tokens)"/>
    
    <xsl:sequence select="'iif'"/>

    <xsl:sequence select="
      if ($multiline) then
        ($t:new-line, '(', $t:new-line, $t:indent)
      else
        '('"/>

    <xsl:sequence select="$condition-tokens"/>
    <xsl:sequence select="','"/>

    <xsl:sequence select="
      if ($multiline) then
        $t:new-line
      else
        ' '"/>

    <xsl:sequence select="$then-tokens"/>
    <xsl:sequence select="','"/>

    <xsl:sequence select="
      if ($multiline) then
        $t:new-line
      else
        ' '"/>

    <xsl:sequence select="$else-tokens"/>

    <xsl:sequence select="
      if ($multiline) then
        ($t:unindent, $t:new-line, ')', $t:new-line)
      else
        ')'"/>
  </xsl:template>

  <!--
    Mode "t:expression-tokens". function.
  -->
  <xsl:template mode="t:expression-tokens"
    match="sql:function[@name = 'concat']">

    <xsl:variable name="arguments" as="element()+"
      select="t:get-sql-element(.)"/>

    <xsl:for-each select="$arguments">
      <xsl:if test="position() > 1">
        <xsl:sequence select="' '"/>
        <xsl:sequence select="'+'"/>
        <xsl:sequence select="' '"/>
      </xsl:if>

      <xsl:apply-templates mode="t:expression-tokens" select="."/>
    </xsl:for-each>
  </xsl:template>

  <!-- Collects keywords. -->
  <xsl:template mode="t:collect-keywords" match="t:keywords">
    <xsl:sequence select="$tsql:keywords"/>
  </xsl:template>

  <!-- Mode "t:quote-name". Gets quoted name. -->
  <xsl:template mode="t:quote-name" match="t:quote-name" as="xs:string" 
    priority="2">
    <xsl:param name="value" as="xs:string"/>

    <xsl:choose>
      <xsl:when test="
        matches($value, '^[A-Za-z_][A-Za-z0-9_]*$') and
        not($t:keywords/key('t:keyword', $value))">
        <xsl:sequence select="$value"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:sequence select="concat('[', $value, ']')"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!--
    Gets variable name prefixed with "@" if required.
  -->
  <xsl:function name="p:get-var" as="xs:string">
    <xsl:param name="name" as="xs:string"/>

    <xsl:sequence select="
      if (starts-with($name, '@')) then
        $name
      else
        concat('@', $name)"/>
  </xsl:function>

  <!--
    Gets system variable name prefixed with "@@" if required.
  -->
  <xsl:function name="p:get-system-var" as="xs:string">
    <xsl:param name="name" as="xs:string"/>

    <xsl:sequence select="$name"/>
  </xsl:function>

</xsl:stylesheet>