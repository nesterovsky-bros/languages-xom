<?xml version="1.0" encoding="utf-8"?>
<!--
  This stylesheet serializes COBOL xml object model document down to
  the COBOL text.
 -->
<xsl:stylesheet version="2.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:t="http://www.bphx.com/cobol"
  xmlns="http://www.bphx.com/cobol/2009-12-15"
  xpath-default-namespace="http://www.bphx.com/cobol/2009-12-15"
  exclude-result-prefixes="xs t">

  <!--
    Gets a sequence of tokens for a procedure-division.
      $procedure-division - a procedure-division.
      Returns a sequence of tokens.
  -->
  <xsl:function name="t:get-procedure-division" as="item()*">
    <xsl:param name="procedure-division" as="element()"/>

    <xsl:variable name="using" as="element()?"
      select="$procedure-division/using"/>
    <xsl:variable name="returning" as="element()?"
      select="$procedure-division/returning"/>
    <xsl:variable name="declaratives" as="element()*"
      select="$procedure-division/declarative"/>

    <xsl:sequence select="t:get-comments($procedure-division)"/>

    <xsl:sequence select="'PROCEDURE'"/>
    <xsl:sequence select="' '"/>
    <xsl:sequence select="'DIVISION'"/>

    <xsl:if test="$using">
      <xsl:variable name="data-refs" as="element()+"
        select="t:get-elements($using)"/>
      <xsl:variable name="default-passing" as="xs:boolean" select="
        not($data-refs[self::by-ref or self::by-value])"/>

      <xsl:sequence select="$t:new-line"/>
      <xsl:sequence select="$t:indent"/>
      <xsl:sequence select="$t:indent"/>
      <xsl:sequence select="'USING'"/>

      <xsl:sequence select="$t:indent"/>

      <xsl:for-each select="$data-refs">
        <xsl:sequence select="$t:new-line"/>

        <xsl:choose>
          <xsl:when test="self::by-content">
            <xsl:sequence select="'BY'"/>
            <xsl:sequence select="' '"/>
            <xsl:sequence select="'VALUE'"/>
            <xsl:sequence select="' '"/>
            <xsl:sequence select="t:get-data-ref(t:get-elements(.))"/>
          </xsl:when>
          <xsl:when test="self::by-ref">
            <xsl:sequence select="'BY'"/>
            <xsl:sequence select="' '"/>
            <xsl:sequence select="'REFERENCE'"/>
            <xsl:sequence select="' '"/>
            <xsl:sequence select="t:get-data-ref(t:get-elements(.))"/>
          </xsl:when>
          <xsl:when test="not($default-passing)">
            <xsl:sequence select="'BY'"/>
            <xsl:sequence select="' '"/>
            <xsl:sequence select="'REFERENCE'"/>
            <xsl:sequence select="' '"/>
            <xsl:sequence select="t:get-data-ref(.)"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:sequence select="t:get-data-ref(.)"/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:for-each>

      <xsl:sequence select="$t:unindent"/>
      <xsl:sequence select="$t:unindent"/>
      <xsl:sequence select="$t:unindent"/>
    </xsl:if>

    <xsl:if test="$returning">
      <xsl:sequence select="$t:new-line"/>
      <xsl:sequence select="$t:indent"/>
      <xsl:sequence select="$t:indent"/>
      <xsl:sequence select="'RETURNING'"/>
      <xsl:sequence select="' '"/>
      <xsl:sequence select="t:get-data-ref(t:get-elements($returning))"/>
      <xsl:sequence select="$t:unindent"/>
      <xsl:sequence select="$t:unindent"/>
    </xsl:if>

    <xsl:sequence select="'.'"/>
    <xsl:sequence select="$t:new-line"/>

    <xsl:if test="$declaratives">
      <xsl:sequence select="$t:new-line"/>

      <xsl:sequence select="'DECLARATIVES'"/>
      <xsl:sequence select="'.'"/>
      <xsl:sequence select="$t:new-line"/>

      <xsl:for-each select="$declaratives">
        <xsl:variable name="use-statement" as="element()" select="
          after-error |
          after-beginning |
          after-ending |
          for-debugging"/>

        <xsl:if test="position() != 1">
          <xsl:sequence select="$t:new-line"/>
        </xsl:if>

        <xsl:sequence select="t:get-section(section, $use-statement)"/>
      </xsl:for-each>

      <xsl:sequence select="$t:new-line"/>
      <xsl:sequence select="'END'"/>
      <xsl:sequence select="' '"/>
      <xsl:sequence select="'DECLARATIVES'"/>
      <xsl:sequence select="'.'"/>
      <xsl:sequence select="$t:new-line"/>
    </xsl:if>

    <xsl:sequence select="$procedure-division/section/t:get-section(., ())"/>
  </xsl:function>

  <!--
    Gets a sequence of tokens for a section.
      $section - a section element.
      Returns a sequence of tokens.
  -->
  <xsl:function name="t:get-section" as="item()*">
    <xsl:param name="section" as="element()"/>
    <xsl:param name="use-statement" as="element()?"/>

    <xsl:variable name="name" as="xs:string?"
      select="$section/@name"/>
    <xsl:variable name="priority" as="xs:integer?"
      select="$section/@priority"/>

    <xsl:sequence select="$t:new-line"/>

    <xsl:sequence select="t:get-comments($section)"/>

    <xsl:if test="$name">
      <xsl:sequence select="$name"/>
      <xsl:sequence select="' '"/>
      <xsl:sequence select="'SECTION'"/>

      <xsl:if test="exists($priority)">
        <xsl:sequence select="' '"/>
        <xsl:sequence select="$priority"/>
      </xsl:if>

      <xsl:sequence select="'.'"/>
      <xsl:sequence select="$t:new-line"/>
    </xsl:if>

    <xsl:if test="exists($use-statement)">
      <xsl:sequence select="'USE'"/>
      <xsl:sequence select="' '"/>

      <xsl:choose>
        <xsl:when test="$use-statement[self::after-error]">
          <xsl:variable name="operation" as="xs:string?"
            select="$use-statement/@operation"/>

          <xsl:sequence select="'GLOBAL'"/>
          <xsl:sequence select="' '"/>
          <xsl:sequence select="'AFTER'"/>
          <xsl:sequence select="' '"/>
          <xsl:sequence select="'STADARD'"/>
          <xsl:sequence select="' '"/>
          <xsl:sequence select="'ERROR'"/>
          <xsl:sequence select="' '"/>
          <xsl:sequence select="'PROCEDURE'"/>
          <xsl:sequence select="' '"/>
          <xsl:sequence select="'ON'"/>
          <xsl:sequence select="' '"/>

          <xsl:choose>
            <xsl:when test="empty($operation) or ($operation = 'default')">
              <xsl:variable name="file-refs" as="element()+"
                select="$use-statement/file-ref"/>

              <xsl:for-each select="$file-refs">
                <xsl:sequence select="' '"/>
                <xsl:sequence select="t:get-file-ref(.)"/>
              </xsl:for-each>
            </xsl:when>
            <xsl:otherwise>
              <xsl:sequence select="
                if ($operation = 'input') then
                  'INPUT'
                else if ($operation = 'output') then
                  'OUTPUT'
                else if ($operation = 'io') then
                  'I-O'
                else if ($operation = 'extend') then
                  'EXTEND'
                else
                  error
                  (
                    xs:QName('invalid-use-statement-operation'),
                    $operation
                  )"/>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:when>
        <xsl:when test="
          $use-statement[self::after-beginning or self::after-ending]">
          <xsl:variable name="operation" as="xs:string?"
            select="$use-statement/@operation"/>
          <xsl:variable name="source" as="xs:string?"
            select="$use-statement/@source"/>

          <xsl:sequence select="'GLOBAL'"/>
          <xsl:sequence select="' '"/>
          <xsl:sequence select="'AFTER'"/>
          <xsl:sequence select="' '"/>
          <xsl:sequence select="'STADARD'"/>
          <xsl:sequence select="' '"/>

          <xsl:sequence select="
            if ($use-statement) then
              'BEGINNING'
            else
              'ENDING'"/>

          <xsl:if test="exists($source)">
            <xsl:sequence select="' '"/>

            <xsl:sequence select="
              if ($source = 'file') then
                'FILE'
              else  if ($source = 'reel') then
                'REEL'
              else  if ($source = 'unit') then
                'UNIT'
              else
                error(xs:QName('invalid-use-statement-source'), $source)"/>
          </xsl:if>

          <xsl:sequence select="' '"/>
          <xsl:sequence select="'LABEL'"/>
          <xsl:sequence select="' '"/>
          <xsl:sequence select="'PROCEDURE'"/>
          <xsl:sequence select="' '"/>
          <xsl:sequence select="'ON'"/>
          <xsl:sequence select="' '"/>

          <xsl:choose>
            <xsl:when test="empty($operation) or ($operation = 'default')">
              <xsl:variable name="file-refs" as="element()+"
                select="$use-statement/file-ref"/>

              <xsl:for-each select="$file-refs">
                <xsl:sequence select="' '"/>
                <xsl:sequence select="t:get-file-ref(.)"/>
              </xsl:for-each>
            </xsl:when>
            <xsl:otherwise>
              <xsl:sequence select="
                if ($operation = 'input') then
                  'INPUT'
                else if ($operation = 'output') then
                  'OUTPUT'
                else if ($operation = 'io') then
                  'I-O'
                else if ($operation = 'extend') then
                  'EXTEND'
                else
                  error
                  (
                    xs:QName('invalid-use-statement-operation'),
                    $operation
                  )"/>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:when>
        <xsl:when test="$use-statement[self::use-for-debugging]">
          <xsl:variable name="all" as="xs:boolean?"
            select="$use-statement/@all"/>

          <xsl:sequence select="'FOR'"/>
          <xsl:sequence select="' '"/>
          <xsl:sequence select="'DEBUGGING'"/>
          <xsl:sequence select="' '"/>
          <xsl:sequence select="'ON'"/>
          <xsl:sequence select="' '"/>

          <xsl:choose>
            <xsl:when test="$all">
              <xsl:sequence select="'ALL'"/>
              <xsl:sequence select="' '"/>
              <xsl:sequence select="'PROCEDURES'"/>
            </xsl:when>
            <xsl:otherwise>
              <xsl:variable name="procedure-refs" as="element()+"
                select="t:get-procedure-ref-elements($use-statement)"/>

              <xsl:for-each select="$procedure-refs">
                <xsl:sequence select="' '"/>
                <xsl:sequence select="t:get-procedure-ref(.)"/>
              </xsl:for-each>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:when>
        <xsl:otherwise>
          <xsl:sequence select="error(xs:QName('invalid-use-statement'))"/>
        </xsl:otherwise>
      </xsl:choose>

      <xsl:sequence select="$t:new-line"/>
    </xsl:if>

    <xsl:sequence select="$section/paragraph/t:get-paragraph(.)"/>
  </xsl:function>

  <!--
    Gets a sequence of tokens for a paragraph.
      $paragraph - a paragraph element.
      Returns a sequence of tokens.
  -->
  <xsl:function name="t:get-paragraph" as="item()*">
    <xsl:param name="paragraph" as="element()"/>

    <xsl:variable name="paragraph-name" as="xs:string?"
      select="$paragraph/@name"/>

    <xsl:sequence select="t:get-comments($paragraph)"/>

    <xsl:if test="$paragraph-name">
      <xsl:sequence select="$t:new-line"/>
      <xsl:sequence select="$paragraph-name"/>
      <xsl:sequence select="'.'"/>
      <xsl:sequence select="$t:new-line"/>
    </xsl:if>

    <xsl:sequence select="$t:indent"/>
    <xsl:sequence select="$t:indent"/>
    
    <xsl:variable name="elements" as="element()*"
      select="t:get-elements($paragraph)"/>

    <xsl:variable name="sentences" as="element()*"
      select="$elements/self::sentence"/>

    <xsl:choose>
      <xsl:when test="empty($sentences)">
        <xsl:sequence
          select="t:get-statements(t:get-elements($paragraph), 'sentence')"/>
      </xsl:when>
      <xsl:when test="empty($elements except $sentences)">
        <xsl:sequence select="
          $sentences/
          (
            t:get-statements(t:get-elements($paragraph), 'sentence'),
            $t:new-line
          )"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:sequence select="error(xs:QName('invalid-paragraph'), $paragraph)"/>
      </xsl:otherwise>
    </xsl:choose>

    <xsl:sequence select="$t:unindent"/>
    <xsl:sequence select="$t:unindent"/>
  </xsl:function>

  <!--
    Gets a sequence of tokens for a procedure-ref.
      $value - an element of procedure-ref group.
      Returns a sequence of tokens.
  -->
  <xsl:function name="t:get-procedure-ref" as="item()*">
    <xsl:param name="value" as="element()"/>

    <xsl:variable name="section-ref" as="element()?"
      select="$value[self::section-ref]"/>
    <xsl:variable name="paragraph-ref" as="element()?"
      select="$value[self::paragraph-ref]"/>

    <xsl:sequence select="$t:soft-line-break"/>

    <xsl:choose>
      <xsl:when test="$section-ref">
        <xsl:variable name="section-name" as="xs:string"
          select="$section-ref/@name"/>

        <xsl:sequence select="$section-name"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:variable name="paragraph-name" as="xs:string"
          select="$paragraph-ref/@name"/>
        <xsl:variable name="section" as="element()"
          select="$paragraph-ref/section-ref"/>

        <xsl:sequence select="$paragraph-name"/>

        <xsl:if test="$section">
          <xsl:variable name="section-name" as="xs:string"
            select="$section/@name"/>

          <xsl:sequence select="' '"/>
          <xsl:sequence select="'IN'"/>
          <xsl:sequence select="' '"/>
          <xsl:sequence select="$section-name"/>
        </xsl:if>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:function>

  <!--
    Gets a sequence of tokens for a range-ref.
      $value - a element of range-ref group.
      $allow-through - true to allow "through" clause, and false otherwise.
      Returns a sequence of tokens.
  -->
  <xsl:function name="t:get-range-ref" as="item()*">
    <xsl:param name="value" as="element()"/>

    <xsl:choose>
      <xsl:when test="$value[self::range-ref]">
        <xsl:variable name="elements" as="element()+"
          select="t:get-elements($value)"/>
        <xsl:variable name="through-ref" as="xs:boolean?"
          select="$value/@through-ref"/>

        <xsl:sequence select="t:get-procedure-ref($elements[1])"/>

        <xsl:if test="not($through-ref = false())">
          <xsl:sequence select="' '"/>
          <xsl:sequence select="$t:soft-line-break"/>
          <xsl:sequence select="'THROUGH'"/>
          <xsl:sequence select="' '"/>
          <xsl:sequence select="t:get-procedure-ref(subsequence($elements, 2))"/>
        </xsl:if>
      </xsl:when>
      <xsl:otherwise>
        <xsl:sequence select="t:get-procedure-ref($value)"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:function>

  <!--
    Gets a sequence of tokens for a list of statements.
      $statements - a list of statement elements.
      $options - generation options; values are:
        'sentence' - to add period at the end;
        'scope' - content of scope statement;
        other - adds CONTINUE if there are no statements.
      Returns a sequence of tokens.
  -->
  <xsl:function name="t:get-statements" as="item()*">
    <xsl:param name="statements" as="element()*"/>
    <xsl:param name="options" as="xs:string?"/>

    <xsl:sequence select="
      t:get-statements
      (
        $statements,
        1,
        $options,
        true(),
        false(),
        ()
      )"/>
  </xsl:function>

  <!--
    Gets a sequence of tokens for a list of statements.
      $statement - a list of statement elements.
      $index - current index.
      $options - generation options; values are:
        'sentence' - to add period at the end;
        'scope' - content of scope statement;
        other - adds CONTINUE if there are no statements.
      $empty-line-before - true if there is an empty line
        before current statement, and false otherwise.
      $result-contains-statements - true if result already
        contains statement, and false otherwise.
      $result - collected result.
      Returns a sequence of tokens.
  -->
  <xsl:function name="t:get-statements" as="item()*">
    <xsl:param name="statements" as="element()*"/>
    <xsl:param name="index" as="xs:integer"/>
    <xsl:param name="options" as="xs:string?"/>
    <xsl:param name="empty-line-before" as="xs:boolean"/>
    <xsl:param name="result-contains-statements" as="xs:boolean"/>
    <xsl:param name="result" as="item()*"/>

    <xsl:variable name="statement" as="element()?"
      select="$statements[$index]"/>

    <xsl:choose>
      <xsl:when test="empty($statement)">
        <xsl:sequence select="$result"/>

        <xsl:choose>
          <xsl:when test="$options = 'sentence'">
            <xsl:sequence select="'.'"/>
            <xsl:sequence select="$t:new-line"/>
          </xsl:when>
          <xsl:when test="$options = 'scope'">
            <!-- Nothing to do. -->
          </xsl:when>
          <xsl:when test="not($result-contains-statements)">
            <xsl:sequence select="'CONTINUE'"/>
            <xsl:sequence select="$t:new-line"/>
          </xsl:when>
          <xsl:when test="exists($result)">
            <xsl:sequence select="$t:new-line"/>
          </xsl:when>
        </xsl:choose>
      </xsl:when>
      <xsl:otherwise>
        <xsl:variable name="tokens" as="item()*"
          select="t:get-statement($statement)"/>
        <xsl:variable name="multiline" as="xs:boolean"
          select="t:is-multiline($tokens)"/>
        <xsl:variable name="info" as="element()"
          select="t:get-statement-info(node-name($statement))"/>
        <xsl:variable name="has-short-form" as="xs:boolean?"
          select="$info/@has-short-form"/>
        <xsl:variable name="line-before" as="xs:boolean?"
          select="$info/@line-before"/>
        <xsl:variable name="line-after" as="xs:boolean?"
          select="$info/@line-after"/>
        <xsl:variable name="has-line-before" as="xs:boolean" select="
          $line-before and ($multiline or not($has-short-form = true()))"/>
        <xsl:variable name="has-line-after" as="xs:boolean" select="
          $line-after and ($multiline or not($has-short-form = true()))"/>

        <xsl:variable name="next-result" as="item()*">
          <xsl:sequence select="$result"/>

          <xsl:if test="exists($result)">
            <xsl:sequence select="$t:new-line"/>
          </xsl:if>

          <xsl:if test="not($empty-line-before) and $has-line-before">
            <xsl:sequence select="$t:new-line"/>
          </xsl:if>

          <xsl:sequence select="$tokens"/>

          <xsl:if test="$has-line-after and exists($statements[$index + 1])">
            <xsl:sequence select="$t:new-line"/>
          </xsl:if>
        </xsl:variable>

        <xsl:variable name="next-result-contains-statements" as="xs:boolean"
          select="
            $result-contains-statements or t:has-statements($statement)"/>

        <xsl:sequence select="
          t:get-statements
          (
            $statements,
            $index + 1,
            $options,
            $has-line-after,
            $next-result-contains-statements,
            $next-result
          )"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:function>

  <!--
    Gets a sequence of tokens for a handler, if any.
      $handler - a handler element.
      $header - a handler header.
  -->
  <xsl:function name="t:get-handler" as="item()*">
    <xsl:param name="handler" as="element()?"/>
    <xsl:param name="header" as="xs:string*"/>

    <xsl:if test="$handler">
      <xsl:if test="exists($header)">
        <xsl:sequence select="t:tokenize($header)"/>
        <xsl:sequence select="$t:new-line"/>
      </xsl:if>

      <xsl:sequence select="$t:indent"/>
      <xsl:sequence select="t:get-statements(t:get-elements($handler), ())"/>
      <xsl:sequence select="$t:unindent"/>
    </xsl:if>
  </xsl:function>

  <!--
    Gets a sequence of tokens for a statement.
      $statement - a statement element.
      Returns a sequence of tokens.
  -->
  <xsl:function name="t:get-statement" as="item()*">
    <xsl:param name="statement" as="element()"/>

    <xsl:variable name="info" as="element()"
      select="t:get-statement-info(node-name($statement))"/>

    <xsl:if test="not($info/xs:boolean(@comments) = false())">
      <xsl:sequence select="t:get-comments($statement)"/>
    </xsl:if>

    <xsl:apply-templates mode="t:statement" select="$statement"/>
  </xsl:function>

  <!-- Default template. -->
  <xsl:template mode="t:statement" match="node()"/>

  <!--
    scope-statement statement.
  -->
  <xsl:template match="scope-statement" mode="t:statement">
    <xsl:sequence select="t:get-statements(t:get-elements(.), 'scope')"/>
  </xsl:template>

  <!--
    snippet-statement statement.
  -->
  <xsl:template match="snippet-statement" mode="t:statement">
    <xsl:sequence select="t:tokenize(@value)"/>
  </xsl:template>

  <!--
    expression-statement statement.
  -->
  <xsl:template match="expression-statement" mode="t:statement"/>

  <!--
    next-sentence statement.
  -->
  <xsl:template match="next-sentence" mode="t:statement">
    <xsl:sequence select="'NEXT'"/>
    <xsl:sequence select="' '"/>
    <xsl:sequence select="'SENTENCE'"/>
  </xsl:template>

  <!--
    accept-statement statement.
  -->
  <xsl:template match="accept-statement" mode="t:statement">
    <xsl:variable name="mnemonic-or-environment" as="xs:string?"
      select="@mnemonic, @environment"/>
    <xsl:variable name="source" as="xs:string?" select="@source"/>
    <xsl:variable name="value" as="element()" select="t:get-elements(.)"/>

    <xsl:sequence select="'ACCEPT'"/>
    <xsl:sequence select="' '"/>
    <xsl:sequence select="t:get-identifier($value)"/>

    <xsl:choose>
      <xsl:when test="$mnemonic-or-environment">
        <xsl:sequence select="' '"/>
        <xsl:sequence select="$t:terminator"/>
        <xsl:sequence select="$t:unindent"/>
        <xsl:sequence select="'FROM'"/>
        <xsl:sequence select="$t:indent"/>
        <xsl:sequence select="' '"/>
        <xsl:sequence select="$mnemonic-or-environment"/>
      </xsl:when>
      <xsl:when test="exists($source)">
        <xsl:sequence select="' '"/>
        <xsl:sequence select="$t:terminator"/>
        <xsl:sequence select="$t:unindent"/>
        <xsl:sequence select="'FROM'"/>
        <xsl:sequence select="$t:indent"/>
        <xsl:sequence select="' '"/>

        <xsl:sequence select="
          if ($source = 'date') then
            'DATE'
          else if ($source = 'date-yyyymmdd') then
            ('DATE', ' ', 'YYYYMMDD')
          else if ($source = 'day') then
            'DAY'
          else if ($source = 'day-yyyyddd') then
            ('DAY', ' ', 'YYYYDDD')
          else if ($source = 'day-of-week') then
            'DAY-OF-WEEK'
          else if ($source = 'time') then
            'TIME'
          else
            error(xs:QName('invalid-accept-source'), $source)"/>
      </xsl:when>
    </xsl:choose>
  </xsl:template>

  <!--
    add-statement statement.
  -->
  <xsl:template match="add-statement" mode="t:statement">
    <xsl:variable name="corresponding" as="xs:boolean?"
      select="@corresponding"/>
    <xsl:variable name="to" as="element()+" select="to"/>
    <xsl:variable name="giving" as="element()*" select="giving"/>
    <xsl:variable name="on-size-error" as="element()?" select="on-size-error"/>
    <xsl:variable name="on-succeed" as="element()?" select="on-succeed"/>
    <xsl:variable name="values" as="element()+" select="
      t:get-elements(.) except ($to, $giving, $on-size-error, $on-succeed)"/>

    <xsl:sequence select="'ADD'"/>

    <xsl:if test="$corresponding">
      <xsl:sequence select="' '"/>
      <xsl:sequence select="'CORRESPONDING'"/>
    </xsl:if>

    <xsl:for-each select="$values">
      <xsl:sequence select="' '"/>
      <xsl:sequence select="$t:terminator"/>
      <xsl:sequence select="t:get-identifier-or-literal(.)"/>
    </xsl:for-each>

    <xsl:sequence select="' '"/>
    <xsl:sequence select="$t:terminator"/>

    <xsl:sequence select="$t:unindent"/>
    <xsl:sequence select="'TO'"/>
    <xsl:sequence select="$t:indent"/>

    <xsl:for-each select="$to">
      <xsl:variable name="rounded" as="xs:boolean?" select="@rounded"/>

      <xsl:sequence select="' '"/>
      <xsl:sequence select="$t:terminator"/>
      <xsl:sequence
        select="t:get-identifier-or-literal(t:get-elements(.))"/>

      <xsl:if test="$rounded">
        <xsl:sequence select="' '"/>
        <xsl:sequence select="'ROUNDED'"/>
      </xsl:if>
    </xsl:for-each>

    <xsl:if test="$giving">
      <xsl:sequence select="' '"/>
      <xsl:sequence select="$t:terminator"/>

      <xsl:sequence select="$t:unindent"/>
      <xsl:sequence select="'GIVING'"/>
      <xsl:sequence select="$t:indent"/>

      <xsl:for-each select="$giving">
        <xsl:variable name="rounded" as="xs:boolean?" select="@rounded"/>

        <xsl:sequence select="' '"/>
        <xsl:sequence select="$t:terminator"/>

        <xsl:sequence select="t:get-identifier(t:get-elements(.))"/>

        <xsl:if test="$rounded">
          <xsl:sequence select="' '"/>
          <xsl:sequence select="'ROUNDED'"/>
        </xsl:if>
      </xsl:for-each>
    </xsl:if>

    <xsl:if test="$on-size-error or $on-succeed">
      <xsl:sequence select="$t:new-line"/>

      <xsl:sequence select="t:get-handler($on-size-error, 'ON SIZE ERROR')"/>
      <xsl:sequence
        select="t:get-handler($on-size-error, 'NOT ON SIZE ERROR')"/>

      <xsl:sequence select="'END-ADD'"/>
    </xsl:if>
  </xsl:template>

  <!--
    alter-statement statement.
  -->
  <xsl:template match="alter-statement" mode="t:statement">
    <xsl:variable name="procedure-refs" as="element()+"
      select="t:get-procedure-ref-elements(.)"/>
    <xsl:variable name="to" as="element()+" select="to"/>

    <xsl:sequence select="'ALTER'"/>

    <xsl:sequence select="$t:indent"/>

    <xsl:for-each select="$procedure-refs">
      <xsl:variable name="index" as="xs:integer" select="position()"/>

      <xsl:sequence select="$t:new-line"/>
      <xsl:sequence select="t:get-procedure-ref(.)"/>
      <xsl:sequence select="' '"/>
      <xsl:sequence select="'TO'"/>
      <xsl:sequence select="' '"/>
      <xsl:sequence select="
        t:get-procedure-ref(t:get-procedure-ref-elements($to[$index]))"/>
    </xsl:for-each>

    <xsl:sequence select="$t:unindent"/>
  </xsl:template>

  <!--
    call-statement statement.
  -->
  <xsl:template match="call-statement" mode="t:statement">
    <xsl:variable name="using" as="element()?" select="using"/>
    <xsl:variable name="on-overflow" as="element()?" select="on-overflow"/>
    <xsl:variable name="on-exception" as="element()?" select="on-exception"/>
    <xsl:variable name="on-succeed" as="element()?" select="on-succeed"/>

    <xsl:variable name="name" as="element()" select="
      t:get-elements(.) except
        ($using, $on-overflow, $on-exception, $on-succeed)"/>

    <xsl:sequence select="'CALL'"/>
    <xsl:sequence select="' '"/>
    <xsl:sequence select="t:get-identifier-or-literal($name)"/>

    <xsl:if test="$using">
      <xsl:variable name="parameters" as="element()+"
        select="t:get-elements($using)"/>
      <xsl:variable name="default-passing" as="xs:boolean" select="
        not($parameters[self::by-ref or self::by-content or self::by-value])"/>

      <xsl:sequence select="$t:new-line"/>
      <xsl:sequence select="'USING'"/>

      <xsl:sequence select="$t:indent"/>

      <xsl:for-each select="$parameters">
        <xsl:sequence select="$t:new-line"/>

        <xsl:choose>
          <xsl:when test="self::by-content">
            <xsl:variable name="parameter" as="element()"
              select="t:get-elements(.)"/>

            <xsl:sequence select="'BY'"/>
            <xsl:sequence select="' '"/>
            <xsl:sequence select="'CONTENT'"/>
            <xsl:sequence select="' '"/>

            <xsl:sequence select="
              if ($parameter[self::file-ref]) then
                t:get-file-ref($parameter)
              else
                t:get-identifier-or-literal($parameter)"/>
          </xsl:when>
          <xsl:when test="self::by-value">
            <xsl:variable name="parameter" as="element()"
              select="t:get-elements(.)"/>

            <xsl:sequence select="'BY'"/>
            <xsl:sequence select="' '"/>
            <xsl:sequence select="'VALUE'"/>
            <xsl:sequence select="' '"/>

            <xsl:sequence select="
              if ($parameter[self::file-ref]) then
                t:get-file-ref($parameter)
              else
                t:get-identifier-or-literal($parameter)"/>
          </xsl:when>
          <xsl:when test="self::by-ref">
            <xsl:variable name="parameter" as="element()"
              select="t:get-elements(.)"/>

            <xsl:sequence select="'BY'"/>
            <xsl:sequence select="' '"/>
            <xsl:sequence select="'REFERENCE'"/>
            <xsl:sequence select="' '"/>

            <xsl:sequence select="
              if ($parameter[self::file-ref]) then
                t:get-file-ref($parameter)
              else
                t:get-identifier-or-literal($parameter)"/>
          </xsl:when>
          <xsl:when test="not($default-passing)">
            <xsl:sequence select="'BY'"/>
            <xsl:sequence select="' '"/>
            <xsl:sequence select="'REFERENCE'"/>
            <xsl:sequence select="' '"/>

            <xsl:sequence select="
              if (self::file-ref) then
                t:get-file-ref(.)
              else
                t:get-identifier-or-literal(.)"/>
          </xsl:when>
          <xsl:when test="self::file-ref">
            <xsl:sequence select="t:get-file-ref(.)"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:sequence select="t:get-identifier-or-literal(.)"/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:for-each>

      <xsl:sequence select="$t:unindent"/>
    </xsl:if>

    <xsl:if test="$on-overflow or $on-exception or $on-succeed">
      <xsl:sequence select="$t:new-line"/>

      <xsl:sequence select="t:get-handler($on-overflow, 'ON OVERFLOW')"/>
      <xsl:sequence select="t:get-handler($on-exception, 'ON EXCEPTION')"/>
      <xsl:sequence select="t:get-handler($on-succeed, 'NOT ON EXCEPTION')"/>

      <xsl:sequence select="'END-CALL'"/>
    </xsl:if>
  </xsl:template>

  <!--
    cancel-statement statement.
  -->
  <xsl:template match="cancel-statement" mode="t:statement">
    <xsl:variable name="values" as="element()+" select="t:get-elements(.)"/>

    <xsl:sequence select="'CANCEL'"/>

    <xsl:for-each select="$values">
      <xsl:sequence select="' '"/>
      <xsl:sequence select="$t:terminator"/>

      <xsl:sequence select="t:get-identifier-or-literal(.)"/>
    </xsl:for-each>
  </xsl:template>

  <!--
    close-statement statement.
  -->
  <xsl:template match="close-statement" mode="t:statement">
    <xsl:variable name="files" as="element()+" select="file"/>

    <xsl:sequence select="'CLOSE'"/>

    <xsl:for-each select="$files">
      <xsl:variable name="file-ref" as="element()" select="file-ref"/>
      <xsl:variable name="option" as="xs:string?" select="@option"/>
      <xsl:variable name="type" as="xs:string" select="@type"/>

      <xsl:sequence select="' '"/>
      <xsl:sequence select="$t:terminator"/>

      <xsl:sequence select="t:get-file-ref($file-ref)"/>

      <xsl:if test="exists($type)">
        <xsl:sequence select="' '"/>

        <xsl:sequence select="
          if ($type = 'reel') then
            'REEL'
          else if ($type = 'unit') then
            'UNIT'
          else
            error(xs:QName('invalid-file-type'), $type)"/>

        <xsl:sequence select="' '"/>

        <xsl:sequence select="
          if ($option = 'for-removal') then
            ('FOR', ' ', 'REMOVAL')
          else if ($option = 'no-rewind') then
            ('WITH', ' ', 'NO', ' ', 'REWIND')
          else if ($option = 'lock') then
            ('WITH', ' ', 'LOCK')
          else
            error(xs:QName('invalid-close-option'), $option)"/>
      </xsl:if>
    </xsl:for-each>
  </xsl:template>

  <!--
    compute-statement statement.
  -->
  <xsl:template match="compute-statement" mode="t:statement">
    <xsl:variable name="to" as="element()+" select="to"/>
    <xsl:variable name="value" as="element()" select="value"/>
    <xsl:variable name="on-size-error" as="element()?" select="on-size-error"/>
    <xsl:variable name="on-succeed" as="element()?" select="on-succeed"/>
    <xsl:variable name="identifier" as="element()"
      select="t:get-elements(.) except ($value, $on-size-error, $on-succeed)"/>

    <xsl:sequence select="'COMPUTE'"/>
    <xsl:sequence select="' '"/>

    <xsl:for-each select="$to">
      <xsl:variable name="rounded" as="xs:boolean?" select="@rounded"/>

      <xsl:if test="position() gt 1">
        <xsl:sequence select="','"/>
        <xsl:sequence select="' '"/>
        <xsl:sequence select="$t:terminator"/>
      </xsl:if>

      <xsl:sequence select="t:get-identifier(t:get-elements($identifier))"/>

      <xsl:if test="$rounded">
        <xsl:sequence select="'ROUNDED'"/>
        <xsl:sequence select="' '"/>
      </xsl:if>
    </xsl:for-each>

    <xsl:sequence select="' '"/>

    <xsl:sequence select="'='"/>
    <xsl:sequence select="' '"/>
    <xsl:sequence select="$t:terminator"/>
    <xsl:sequence
      select="t:get-arithmetic-expression(t:get-elements($value))"/>

    <xsl:if test="$on-size-error or $on-succeed">
      <xsl:sequence select="$t:new-line"/>

      <xsl:sequence select="t:get-handler($on-size-error, 'ON SIZE ERROR')"/>
      <xsl:sequence select="t:get-handler($on-succeed, 'NOT ON SIZE ERROR')"/>

      <xsl:sequence select="'END-COMPUTE'"/>
    </xsl:if>
  </xsl:template>

  <!--
    continue-statement statement.
  -->
  <xsl:template match="continue-statement" mode="t:statement">
    <xsl:sequence select="'CONTINUE'"/>
  </xsl:template>

  <!--
    delete-statement statement.
  -->
  <xsl:template match="delete-statement" mode="t:statement">
    <xsl:variable name="file-ref" as="element()" select="file-ref"/>
    <xsl:variable name="on-invalid-key" as="element()?"
      select="on-invalid-key"/>
    <xsl:variable name="on-valid-key" as="element()?"
      select="on-valid-key"/>

    <xsl:sequence select="'DELETE'"/>
    <xsl:sequence select="' '"/>
    <xsl:sequence select="t:get-file-ref($file-ref)"/>
    <xsl:sequence select="' '"/>
    <xsl:sequence select="'RECORD'"/>

    <xsl:if test="$on-invalid-key or $on-valid-key">
      <xsl:sequence select="$t:new-line"/>

      <xsl:sequence select="t:get-handler($on-invalid-key, 'INVALID KEY')"/>
      <xsl:sequence select="t:get-handler($on-valid-key, 'NOT INVALID KEY')"/>

      <xsl:sequence select="'END-DELETE'"/>
    </xsl:if>
  </xsl:template>

  <!--
    display-statement statement.
  -->
  <xsl:template match="display-statement" mode="t:statement">
    <xsl:variable name="mnemonic-or-environment" as="xs:string?"
      select="@mnemonic, @environment"/>
    <xsl:variable name="advancing" as="xs:boolean?" select="@advancing"/>
    <xsl:variable name="values" as="element()+" select="t:get-elements(.)"/>

    <xsl:sequence select="'DISPLAY'"/>

    <xsl:for-each select="$values">
      <xsl:sequence select="' '"/>
      <xsl:sequence select="$t:terminator"/>
      <xsl:sequence select="t:get-identifier-or-literal(.)"/>
    </xsl:for-each>

    <xsl:if test="$mnemonic-or-environment">
      <xsl:sequence select="$t:new-line"/>

      <xsl:sequence select="'UPON'"/>
      <xsl:sequence select="' '"/>
      <xsl:sequence select="$mnemonic-or-environment"/>
    </xsl:if>

    <xsl:if test="$advancing = false()">
      <xsl:sequence select="$t:new-line"/>

      <xsl:sequence select="'WITH'"/>
      <xsl:sequence select="' '"/>
      <xsl:sequence select="'NO'"/>
      <xsl:sequence select="' '"/>
      <xsl:sequence select="'ADVANCING'"/>
    </xsl:if>
  </xsl:template>

  <!--
    divide-statement statement.
  -->
  <xsl:template match="divide-statement" mode="t:statement">
    <xsl:variable name="by" as="element()?" select="by"/>
    <xsl:variable name="into" as="element()*" select="into"/>
    <xsl:variable name="giving" as="element()*" select="giving"/>
    <xsl:variable name="remainder" as="element()?" select="remainder"/>
    <xsl:variable name="on-size-error" as="element()?" select="on-size-error"/>
    <xsl:variable name="on-succeed" as="element()?" select="on-succeed"/>

    <xsl:variable name="value" as="element()" select="
      t:get-elements(.) except
        ($by, $into, $giving, $remainder, $on-size-error, $on-succeed)"/>

    <xsl:sequence select="'DIVIDE'"/>
    <xsl:sequence select="' '"/>
    <xsl:sequence select="t:get-identifier-or-literal($value)"/>

    <xsl:choose>
      <xsl:when test="$by">
        <xsl:sequence select="' '"/>
        <xsl:sequence select="$t:terminator"/>

        <xsl:sequence select="$t:unindent"/>
        <xsl:sequence select="'BY'"/>
        <xsl:sequence select="$t:indent"/>

        <xsl:sequence select="' '"/>
        <xsl:sequence
          select="t:get-identifier-or-literal(t:get-elements($by))"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:variable name="into-values" as="element()+" select="$into"/>

        <xsl:sequence select="' '"/>
        <xsl:sequence select="$t:terminator"/>

        <xsl:sequence select="$t:unindent"/>
        <xsl:sequence select="'INTO'"/>
        <xsl:sequence select="$t:indent"/>

        <xsl:for-each select="$into-values">
          <xsl:variable name="rounded" as="xs:boolean?" select="@rounded"/>

          <xsl:sequence select="' '"/>
          <xsl:sequence select="$t:terminator"/>

          <xsl:sequence
            select="t:get-identifier-or-literal(t:get-elements(.))"/>

          <xsl:if test="$rounded">
            <xsl:sequence select="' '"/>
            <xsl:sequence select="'ROUNDED'"/>
          </xsl:if>
        </xsl:for-each>
      </xsl:otherwise>
    </xsl:choose>

    <xsl:if test="$giving">
      <xsl:sequence select="' '"/>
      <xsl:sequence select="$t:terminator"/>

      <xsl:sequence select="'GIVING'"/>

      <xsl:for-each select="$giving">
        <xsl:variable name="rounded" as="xs:boolean?" select="@rounded"/>

        <xsl:sequence select="' '"/>
        <xsl:sequence select="$t:terminator"/>

        <xsl:sequence select="t:get-identifier(t:get-elements(.))"/>

        <xsl:if test="$rounded">
          <xsl:sequence select="' '"/>
          <xsl:sequence select="'ROUNDED'"/>
        </xsl:if>
      </xsl:for-each>
    </xsl:if>

    <xsl:if test="$remainder">
      <xsl:variable name="rounded" as="xs:boolean?"
        select="$giving/@rounded"/>

      <xsl:sequence select="' '"/>
      <xsl:sequence select="$t:terminator"/>

      <xsl:sequence select="'REMAINDER'"/>
      <xsl:sequence select="' '"/>
      <xsl:sequence select="t:get-identifier(t:get-elements($remainder))"/>

      <xsl:if test="$rounded">
        <xsl:sequence select="' '"/>
        <xsl:sequence select="'ROUNDED'"/>
      </xsl:if>
    </xsl:if>

    <xsl:if test="$on-size-error or $on-succeed">
      <xsl:sequence select="$t:new-line"/>

      <xsl:sequence select="t:get-handler($on-size-error, 'ON SIZE ERROR')"/>
      <xsl:sequence select="t:get-handler($on-succeed, 'NOT ON SIZE ERROR')"/>

      <xsl:sequence select="'END-DIVIDE'"/>
    </xsl:if>
  </xsl:template>

  <!--
    entry-statement statement.
  -->
  <xsl:template match="entry-statement" mode="t:statement">
    <xsl:variable name="using" as="element()?" select="using"/>
    <xsl:variable name="value" as="element()"
      select="t:get-elements(.) except $using"/>

    <xsl:sequence select="'ENTRY'"/>
    <xsl:sequence select="' '"/>
    <xsl:sequence select="t:get-literal($value)"/>

    <xsl:if test="$using">
      <xsl:variable name="data-refs" as="element()+"
        select="t:get-elements($using)"/>
      <xsl:variable name="default-passing" as="xs:boolean" select="
        not($data-refs[self::by-ref or self::by-value])"/>

      <xsl:sequence select="$t:new-line"/>

      <xsl:sequence select="'USING'"/>

      <xsl:sequence select="$t:indent"/>

      <xsl:for-each select="$data-refs">
        <xsl:sequence select="$t:new-line"/>

        <xsl:choose>
          <xsl:when test="self::by-value">
            <xsl:sequence select="'BY'"/>
            <xsl:sequence select="' '"/>
            <xsl:sequence select="'VALUE'"/>
            <xsl:sequence select="' '"/>
            <xsl:sequence select="t:get-data-ref(t:get-elements(.))"/>
          </xsl:when>
          <xsl:when test="self::by-ref">
            <xsl:sequence select="'BY'"/>
            <xsl:sequence select="' '"/>
            <xsl:sequence select="'REFERENCE'"/>
            <xsl:sequence select="' '"/>
            <xsl:sequence select="t:get-data-ref(t:get-elements(.))"/>
          </xsl:when>
          <xsl:when test="not($default-passing)">
            <xsl:sequence select="'BY'"/>
            <xsl:sequence select="' '"/>
            <xsl:sequence select="'REFERENCE'"/>
            <xsl:sequence select="' '"/>
            <xsl:sequence select="t:get-data-ref(.)"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:sequence select="t:get-data-ref(.)"/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:for-each>

      <xsl:sequence select="$t:unindent"/>
    </xsl:if>
  </xsl:template>

  <!--
    evaluate-statement statement.
  -->
  <xsl:template match="evaluate-statement" mode="t:statement">
    <xsl:variable name="tests" as="element()+" select="test"/>
    <xsl:variable name="when" as="element()+" select="when"/>
    <xsl:variable name="when-other" as="element()?" select="when-other"/>

    <xsl:sequence select="'EVALUATE'"/>

    <xsl:for-each select="$tests">
      <xsl:variable name="test-value" as="element()"
        select="t:get-elements(.)"/>

      <xsl:sequence select="' '"/>
      <xsl:sequence select="$t:terminator"/>

      <xsl:if test="position() gt 1">
        <xsl:sequence select="'ALSO'"/>
        <xsl:sequence select="' '"/>
      </xsl:if>

      <xsl:sequence select="
        if ($test-value[self::true]) then
          'TRUE'
        else if ($test-value[self::false]) then
          'FALSE'
        else
          t:get-arithmetic-expression-or-condition($test-value)"/>
    </xsl:for-each>

    <xsl:sequence select="$t:new-line"/>

    <xsl:for-each select="$when">
      <xsl:variable name="values" as="element()+" select="value"/>
      <xsl:variable name="then" as="element()" select="then"/>
      <xsl:variable name="statements" as="element()*"
        select="t:get-elements($then)"/>

      <xsl:sequence select="'WHEN'"/>

      <xsl:for-each select="$values">
        <xsl:variable name="test-value" as="element()"
          select="t:get-elements(.)"/>

        <xsl:sequence select="' '"/>
        <xsl:sequence select="$t:terminator"/>

        <xsl:if test="position() gt 1">
          <xsl:sequence select="'ALSO'"/>
          <xsl:sequence select="' '"/>
        </xsl:if>

        <xsl:sequence select="
          if ($test-value[self::any]) then
            'ANY'
          else if ($test-value[self::true]) then
            'TRUE'
          else if ($test-value[self::false]) then
            'FALSE'
          else if ($test-value[self::in-range]) then
            t:get-in-range($test-value)
          else if ($test-value[self::is-not]) then
            t:get-is-not($test-value)
          else
            t:get-arithmetic-expression-or-condition($test-value)"/>
      </xsl:for-each>
      
      <xsl:sequence select="$t:new-line"/>

      <xsl:sequence select="$t:indent"/>

      <xsl:sequence select="t:get-statements($statements, ())"/>

      <xsl:sequence select="$t:unindent"/>
    </xsl:for-each>

    <xsl:if test="$when-other">
      <xsl:variable name="statements" as="element()*"
        select="t:get-elements($when-other)"/>

      <xsl:sequence select="'WHEN'"/>
      <xsl:sequence select="' '"/>
      <xsl:sequence select="'OTHER'"/>
      <xsl:sequence select="$t:new-line"/>

      <xsl:sequence select="$t:indent"/>

      <xsl:sequence select="t:get-statements($statements, ())"/>

      <xsl:sequence select="$t:unindent"/>
    </xsl:if>

    <xsl:sequence select="'END-EVALUATE'"/>
  </xsl:template>

  <!--
    Gets a sequence of tokens for an is-not expression.
      $value - an is-not element.
      Returns a sequence of tokens.
  -->
  <xsl:function name="t:get-is-not" as="item()*">
    <xsl:param name="value" as="element()"/>

    <xsl:sequence select="'NOT'"/>
    <xsl:sequence select="' '"/>

    <xsl:variable name="element" as="element()"
      select="t:get-elements($value)"/>

    <xsl:choose>
      <xsl:when test="$element[self::in-range]">
        <xsl:sequence select="t:get-in-range($element)"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:sequence select="t:get-arithmetic-expression($element)"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:function>

  <!--
    Gets a sequence of tokens for a in-range/not in-range expression.
      $value - an in-range element.
      Returns a sequence of tokens.
  -->
  <xsl:function name="t:get-in-range" as="item()*">
    <xsl:param name="value" as="element()"/>

    <xsl:variable name="elements" as="element()+"
      select="t:get-elements($value)"/>
    <xsl:variable name="from" as="element()"
      select="$elements[1]"/>
    <xsl:variable name="to" as="element()"
      select="subsequence($elements, 2)"/>

    <xsl:sequence select="t:get-arithmetic-expression($from)"/>
    <xsl:sequence select="' '"/>
    <xsl:sequence select="'THROUGH'"/>
    <xsl:sequence select="' '"/>
    <xsl:sequence select="t:get-arithmetic-expression($to)"/>
  </xsl:function>

  <!--
    exit-statement statement.
  -->
  <xsl:template match="exit-statement" mode="t:statement">
    <xsl:sequence select="'EXIT'"/>
  </xsl:template>

  <!--
    exit-program-statement statement.
  -->
  <xsl:template match="exit-program-statement" mode="t:statement">
    <xsl:sequence select="'EXIT'"/>
    <xsl:sequence select="' '"/>
    <xsl:sequence select="'PROGRAM'"/>
  </xsl:template>

  <!--
    goback-statement statement.
  -->
  <xsl:template match="goback-statement" mode="t:statement">
    <xsl:sequence select="'GOBACK'"/>
  </xsl:template>

  <!--
    go-to-statement statement.
  -->
  <xsl:template match="go-to-statement" mode="t:statement">
    <xsl:variable name="more" as="xs:boolean?" select="@more"/>
    <xsl:variable name="procedure-refs" as="element()*"
      select="t:get-procedure-ref-elements(.)"/>
    <xsl:variable name="depending-on" as="element()?"
      select="depending-on"/>

    <xsl:sequence select="'GO'"/>
    <xsl:sequence select="' '"/>
    <xsl:sequence select="'TO'"/>

    <xsl:choose>
      <xsl:when test="$more">
        <xsl:sequence select="' '"/>
        <xsl:sequence select="'MORE-LABELS'"/>
      </xsl:when>
      <xsl:when test="$depending-on">
        <xsl:variable name="names" as="element()+" select="$procedure-refs"/>

        <xsl:sequence select="$t:indent"/>

        <xsl:for-each select="$names">
          <xsl:sequence select="' '"/>
          <xsl:sequence select="$t:terminator"/>
          <xsl:sequence select="t:get-procedure-ref(.)"/>
        </xsl:for-each>

        <xsl:sequence select="$t:new-line"/>
        <xsl:sequence select="'DEPENDING'"/>
        <xsl:sequence select="' '"/>
        <xsl:sequence select="'ON'"/>
        <xsl:sequence select="' '"/>
        <xsl:sequence
          select="t:get-identifier(t:get-elements($depending-on))"/>

        <xsl:sequence select="$t:unindent"/>
      </xsl:when>
      <xsl:when test="$procedure-refs">
        <xsl:variable name="name" as="element()" select="$procedure-refs"/>

        <xsl:sequence select="' '"/>
        <xsl:sequence select="t:get-procedure-ref($name)"/>
      </xsl:when>
    </xsl:choose>
  </xsl:template>

  <!--
    if-statement statement.
      $else-if - true when this statement is only
        statement in outer else clause of if statement.
  -->
  <xsl:template match="if-statement" mode="t:statement">
    <xsl:param name="else-if" as="xs:boolean?" select="false()"/>

    <xsl:variable name="condition" as="element()" select="condition"/>
    <xsl:variable name="then" as="element()" select="then"/>
    <xsl:variable name="else" as="element()?" select="else"/>

    <xsl:if test="$else-if">
      <xsl:sequence select="' '"/>
    </xsl:if>

    <xsl:sequence select="'IF'"/>
    <xsl:sequence select="' '"/>
    <xsl:sequence select="t:get-condition(t:get-elements($condition))"/>
    <xsl:sequence select="' '"/>
    <xsl:sequence select="$t:terminator"/>

    <xsl:sequence select="$t:unindent"/>
      <xsl:sequence select="'THEN'"/>
    <xsl:sequence select="$t:indent"/>
    <xsl:sequence select="$t:new-line"/>

    <xsl:sequence select="$t:indent"/>

    <xsl:sequence select="t:get-statements(t:get-elements($then), ())"/>

    <xsl:sequence select="$t:unindent"/>

    <xsl:if test="$else">
      <xsl:variable name="else-statements" as="element()*"
        select="t:get-elements($else)"/>

      <xsl:variable name="else-if-statement" as="xs:boolean" select="
        (count($else-statements) = 1) and
        $else-statements[self::if-statement] and
        empty($else-statements/comment)"/>

      <xsl:sequence select="'ELSE'"/>

      <xsl:if test="not($else-if-statement)">
        <xsl:sequence select="$t:new-line"/>
        <xsl:sequence select="$t:indent"/>
      </xsl:if>

      <xsl:choose>
        <xsl:when test="$else-if-statement">
          <xsl:apply-templates mode="t:statement" select="$else-statements">
            <xsl:with-param name="else-if" select="true()"/>
          </xsl:apply-templates>
        </xsl:when>
        <xsl:otherwise>
          <xsl:sequence select="t:get-statements($else-statements, ())"/>
        </xsl:otherwise>
      </xsl:choose>

      <xsl:if test="not($else-if-statement)">
        <xsl:sequence select="$t:unindent"/>
      </xsl:if>
    </xsl:if>

    <xsl:if test="not($else-if)">
      <xsl:sequence select="'END-IF'"/>
    </xsl:if>
  </xsl:template>

  <!--
    initialize-statement statement.
  -->
  <xsl:template match="initialize-statement" mode="t:statement">
    <xsl:variable name="replace-by" as="element()*" select="replace-by"/>
    <xsl:variable name="identifiers" as="element()+"
      select="t:get-elements(.) except $replace-by"/>

    <xsl:sequence select="'INITIALIZE'"/>

    <xsl:for-each select="$identifiers">
      <xsl:sequence select="' '"/>
      <xsl:sequence select="$t:terminator"/>
      <xsl:sequence select="t:get-identifier(.)"/>
    </xsl:for-each>

    <xsl:if test="$replace-by">
      <xsl:sequence select="$t:new-line"/>
      <xsl:sequence select="'REPLACING'"/>
      <xsl:sequence select="$t:new-line"/>

      <xsl:sequence select="$t:indent"/>

      <xsl:for-each select="$replace-by">
        <xsl:variable name="source" as="xs:string" select="@source"/>
        <xsl:variable name="values" as="element()+"
          select="t:get-elements(.)"/>

        <xsl:sequence select="
          if ($source = 'alphabetic') then
            'ALPHABETIC'
          else if ($source = 'alphanumeric') then
            'ALPHANUMERIC'
          else if ($source = 'numeric') then
            'NUMERIC'
          else if ($source = 'alphanumeric-edited') then
            'ALPHANUMERIC-EDITED'
          else if ($source = 'numeric-edited') then
            'NUMERIC-EDITED'
          else if ($source = 'dbcs') then
            'DBCS'
          else if ($source = 'egcs') then
            'EGCS'
          else
            error(xs:QName('invalid-replace-by-source'), $source)"/>

        <xsl:sequence select="' '"/>
        <xsl:sequence select="'BY'"/>

        <xsl:for-each select="$values">
          <xsl:sequence select="' '"/>
          <xsl:sequence select="$t:terminator"/>
          <xsl:sequence select="t:get-identifier(.)"/>
        </xsl:for-each>
      </xsl:for-each>

      <xsl:sequence select="$t:unindent"/>
    </xsl:if>
  </xsl:template>

  <!--
    inspect-statement statement.
  -->
  <xsl:template match="inspect-statement" mode="t:statement">
    <xsl:variable name="tallying" as="element()*" select="tallying"/>
    <xsl:variable name="converting" as="element()?" select="converting"/>
    <xsl:variable name="replacing" as="element()*" select="replacing"/>
    <xsl:variable name="value" as="element()"
      select="t:get-elements(.) except ($tallying, $converting, $replacing)"/>

    <xsl:sequence select="'INSPECT'"/>
    <xsl:sequence select="' '"/>
    <xsl:sequence select="t:get-identifier($value)"/>

    <xsl:choose>
      <xsl:when test="$converting">
        <xsl:variable name="before-after" as="element()*"
          select="$converting/(before | after)"/>
        <xsl:variable name="values" as="element()+"
         select="t:get-elements($converting) except $before-after"/>
        <xsl:variable name="from" as="element()" select="$values[1]"/>
        <xsl:variable name="to" as="element()"
          select="subsequence($values, 2)"/>

        <xsl:sequence select="$t:new-line"/>

        <xsl:sequence select="'CONVERTING'"/>
        <xsl:sequence select="' '"/>
        <xsl:sequence select="t:get-identifier-or-literal($from)"/>
        <xsl:sequence select="' '"/>
        <xsl:sequence select="$t:terminator"/>

        <xsl:sequence select="$t:unindent"/>
        <xsl:sequence select="'TO'"/>
        <xsl:sequence select="$t:indent"/>

        <xsl:sequence select="' '"/>
        <xsl:sequence select="t:get-identifier-or-literal($to)"/>

        <xsl:for-each select="$before-after">
          <xsl:sequence select="' '"/>
          <xsl:sequence select="$t:terminator"/>

          <xsl:sequence select="t:get-before-after-phrase(.)"/>
        </xsl:for-each>
      </xsl:when>
      <xsl:otherwise>
        <xsl:if test="$tallying">
          <xsl:sequence select="$t:new-line"/>

          <xsl:sequence select="'TALLYING'"/>

          <xsl:for-each select="$tallying">
            <xsl:variable name="operation" as="xs:string" select="@operation"/>
            <xsl:variable name="before-after" as="element()*"
              select="before | after"/>
            <xsl:variable name="tallying-values" as="element()+"
              select="t:get-elements(.) except $before-after"/>
            <xsl:variable name="first-value" as="element()"
              select="$tallying-values[1]"/>
            <xsl:variable name="second-value" as="element()?"
              select="subsequence($tallying-values, 2)"/>

            <xsl:sequence select="' '"/>
            <xsl:sequence select="$t:terminator"/>

            <xsl:sequence select="t:get-identifier($first-value)"/>

            <xsl:sequence select="' '"/>

            <xsl:sequence select="$t:unindent"/>
            <xsl:sequence select="'FOR'"/>
            <xsl:sequence select="$t:indent"/>

            <xsl:sequence select="' '"/>

            <xsl:choose>
              <xsl:when test="($operation = 'characters') and empty($second-value)">
                <xsl:sequence select="'CHARACTERS'"/>
              </xsl:when>
              <xsl:when test="$operation = 'all'">
                <xsl:sequence select="'ALL'"/>
                <xsl:sequence select="' '"/>
                <xsl:sequence
                  select="t:get-identifier-or-literal($second-value)"/>
              </xsl:when>
              <xsl:when test="$operation = 'leading'">
                <xsl:sequence select="'LEADING'"/>
                <xsl:sequence select="' '"/>
                <xsl:sequence
                  select="t:get-identifier-or-literal($second-value)"/>
              </xsl:when>
              <xsl:otherwise>
                <xsl:sequence
                  select="error(xs:QName('invalid-tallying-option'))"/>
              </xsl:otherwise>
            </xsl:choose>

            <xsl:for-each select="$before-after">
              <xsl:sequence select="' '"/>
              <xsl:sequence select="$t:terminator"/>

              <xsl:sequence select="t:get-before-after-phrase(.)"/>
            </xsl:for-each>
          </xsl:for-each>
        </xsl:if>

        <xsl:if test="$replacing">
          <xsl:sequence select="$t:new-line"/>

          <xsl:sequence select="'REPLACING'"/>

          <xsl:for-each select="$replacing">
            <xsl:variable name="operation" as="xs:string" select="@operation"/>
            <xsl:variable name="before-after" as="element()*"
              select="before | after"/>
            <xsl:variable name="by" as="element()" select="by"/>
            <xsl:variable name="replacing-value" as="element()?"
              select="t:get-elements(.) except ($before-after, $by)"/>

            <xsl:sequence select="' '"/>
            <xsl:sequence select="$t:terminator"/>

            <xsl:choose>
              <xsl:when 
                test="($operation = 'characters') and empty($replacing-value)">
                <xsl:sequence select="'CHARACTERS'"/>
              </xsl:when>
              <xsl:when test="$operation = 'all'">
                <xsl:sequence select="'ALL'"/>
                <xsl:sequence select="' '"/>
                <xsl:sequence
                  select="t:get-identifier-or-literal($replacing-value)"/>
              </xsl:when>
              <xsl:when test="$operation = 'leading'">
                <xsl:sequence select="'LEADING'"/>
                <xsl:sequence select="' '"/>
                <xsl:sequence
                  select="t:get-identifier-or-literal($replacing-value)"/>
              </xsl:when>
              <xsl:when test="$operation = 'first'">
                <xsl:sequence select="'FIRST'"/>
                <xsl:sequence select="' '"/>
                <xsl:sequence
                  select="t:get-identifier-or-literal($replacing-value)"/>
              </xsl:when>
              <xsl:otherwise>
                <xsl:sequence
                  select="error(xs:QName('invalid-replacing-option'))"/>
              </xsl:otherwise>
            </xsl:choose>

            <xsl:sequence select="' '"/>
            <xsl:sequence select="'BY'"/>
            <xsl:sequence select="' '"/>
            <xsl:sequence 
              select="t:get-identifier-or-literal(t:get-elements($by))"/>

            <xsl:for-each select="$before-after">
              <xsl:sequence select="' '"/>
              <xsl:sequence select="$t:terminator"/>

              <xsl:sequence select="t:get-before-after-phrase(.)"/>
            </xsl:for-each>
          </xsl:for-each>
        </xsl:if>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!--
    Gets tokens for a before-after-phrase type.
      $value - an element of before-after-phrase type.
      Returns a sequence of tokens.
  -->
  <xsl:function name="t:get-before-after-phrase" as="item()*">
    <xsl:param name="value" as="element()"/>

    <xsl:sequence select="
      if ($value[self::before]) then
        'BEFORE'
      else if ($value[self::after]) then
        'AFTER'
      else
        error(xs:QName('invalid-before-after-element'), local-name($value))"/>

    <xsl:sequence select="' '"/>
    <xsl:sequence
      select="t:get-identifier-or-literal(t:get-elements($value))"/>
  </xsl:function>

  <!--
    merge-statement statement.
  -->
  <xsl:template match="merge-statement" mode="t:statement">
    <xsl:variable name="file-ref" as="element()" select="file-ref"/>
    <xsl:variable name="collation" as="xs:string?" select="@collation"/>
    <xsl:variable name="order-by" as="element()+" select="order-by"/>
    <xsl:variable name="using" as="element()" select="using"/>
    <xsl:variable name="output" as="element()?" select="output"/>
    <xsl:variable name="giving" as="element()*" select="giving"/>

    <xsl:sequence select="'MERGE'"/>
    <xsl:sequence select="' '"/>
    <xsl:sequence select="t:get-file-ref($file-ref)"/>

    <xsl:for-each select="$order-by">
      <xsl:variable name="direction" as="xs:string" select="@direction"/>

      <xsl:sequence select="$t:new-line"/>

      <xsl:sequence select="'ON'"/>
      <xsl:sequence select="' '"/>

      <xsl:sequence select="
        if ($direction = 'ascending') then
          'ASCENDING'
        else if ($direction = 'descending') then
          'DESCENDING'
        else
          error(xs:QName('invalid-order-direction'), $direction)"/>

      <xsl:sequence select="' '"/>
      <xsl:sequence select="'KEY'"/>
      <xsl:sequence select="' '"/>
      <xsl:sequence select="t:get-qualified-data-name(t:get-elements(.))"/>
    </xsl:for-each>

    <xsl:if test="$collation">
      <xsl:sequence select="$t:new-line"/>

      <xsl:sequence select="'COLLATING'"/>
      <xsl:sequence select="' '"/>
      <xsl:sequence select="'SEQUENCE'"/>
      <xsl:sequence select="' '"/>
      <xsl:sequence select="'IS'"/>
      <xsl:sequence select="' '"/>
      <xsl:sequence select="$collation"/>
    </xsl:if>

    <xsl:if test="$using">
      <xsl:variable name="using-file-refs" as="element()+"
        select="$using/file-ref"/>

      <xsl:sequence select="$t:new-line"/>

      <xsl:sequence select="'USING'"/>

      <xsl:sequence select="$t:indent"/>

      <xsl:for-each select="$using-file-refs">
        <xsl:sequence select="$t:new-line"/>
        <xsl:sequence select="t:get-file-ref(.)"/>
      </xsl:for-each>

      <xsl:sequence select="$t:unindent"/>
    </xsl:if>

    <xsl:choose>
      <xsl:when test="$output">
        <xsl:sequence select="'OUTPUT'"/>
        <xsl:sequence select="' '"/>
        <xsl:sequence select="'PROCEDURE'"/>
        <xsl:sequence select="' '"/>
        <xsl:sequence select="'IS'"/>
        <xsl:sequence select="' '"/>
        <xsl:sequence
          select="t:get-range-ref(t:get-range-ref-elements($output))"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:variable name="giving-files" as="element()+" select="$giving"/>

        <xsl:sequence select="'GIVING'"/>

        <xsl:sequence select="$t:indent"/>

        <xsl:for-each select="$giving">
          <xsl:variable name="giving-name" as="xs:string" select="@name"/>

          <xsl:sequence select="$t:new-line"/>
          <xsl:sequence select="$giving-name"/>
        </xsl:for-each>

        <xsl:sequence select="$t:unindent"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!--
    move-statement statement.
  -->
  <xsl:template match="move-statement" mode="t:statement">
    <xsl:variable name="corresponding" as="xs:boolean?"
      select="@corresponding"/>
    <xsl:variable name="to" as="element()+" select="to"/>
    <xsl:variable name="from" as="element()"
      select="t:get-elements(.) except $to"/>

    <xsl:sequence select="'MOVE'"/>

    <xsl:if test="$corresponding">
      <xsl:sequence select="' '"/>
      <xsl:sequence select="'CORRESPONDING'"/>
    </xsl:if>

    <xsl:sequence select="' '"/>
    <xsl:sequence select="t:get-identifier-or-literal($from)"/>
    <xsl:sequence select="' '"/>
    <xsl:sequence select="$t:terminator"/>

    <xsl:sequence select="'TO'"/>

    <xsl:for-each select="$to">
      <xsl:sequence select="' '"/>
      <xsl:sequence select="t:get-identifier(t:get-elements(.))"/>

      <xsl:if test="position() != last()">
        <xsl:sequence select="$t:terminator"/>
      </xsl:if>
    </xsl:for-each>
  </xsl:template>

  <!--
    multiply-statement statement.
  -->
  <xsl:template match="multiply-statement" mode="t:statement">
    <xsl:variable name="by" as="element()+" select="by"/>
    <xsl:variable name="giving" as="element()*" select="giving"/>
    <xsl:variable name="on-size-error" as="element()?" select="on-size-error"/>
    <xsl:variable name="on-succeed" as="element()?" select="on-succeed"/>
    <xsl:variable name="value" as="element()" select="
      t:get-elements(.) except ($by, $giving, $on-size-error, $on-succeed)"/>

    <xsl:sequence select="'MULTIPLY'"/>
    <xsl:sequence select="' '"/>
    <xsl:sequence select="t:get-identifier-or-literal($value)"/>

    <xsl:sequence select="' '"/>
    <xsl:sequence select="$t:terminator"/>

    <xsl:sequence select="'BY'"/>

    <xsl:for-each select="$by">
      <xsl:variable name="rounded" as="xs:boolean?" select="@rounded"/>

      <xsl:sequence select="' '"/>
      <xsl:sequence select="$t:terminator"/>

      <xsl:sequence
        select="t:get-identifier-or-literal(t:get-elements(.))"/>

      <xsl:if test="$rounded">
        <xsl:sequence select="' '"/>
        <xsl:sequence select="'ROUNDED'"/>
      </xsl:if>
    </xsl:for-each>


    <xsl:if test="$giving">
      <xsl:sequence select="$t:terminator"/>

      <xsl:sequence select="$t:unindent"/>
      <xsl:sequence select="'GIVING'"/>
      <xsl:sequence select="$t:indent"/>

      <xsl:for-each select="$giving">
        <xsl:variable name="rounded" as="xs:boolean?" select="@rounded"/>

        <xsl:sequence select="' '"/>
        <xsl:sequence select="$t:terminator"/>

        <xsl:sequence select="t:get-identifier(t:get-elements(.))"/>

        <xsl:if test="$rounded">
          <xsl:sequence select="' '"/>
          <xsl:sequence select="'ROUNDED'"/>
        </xsl:if>
      </xsl:for-each>
    </xsl:if>

    <xsl:if test="$on-size-error or $on-succeed">
      <xsl:sequence select="$t:new-line"/>

      <xsl:sequence select="t:get-handler($on-size-error, 'ON SIZE ERROR')"/>
      <xsl:sequence select="t:get-handler($on-succeed, 'NOT ON SIZE ERROR')"/>

      <xsl:sequence select="'END-MULTIPLY'"/>
    </xsl:if>
  </xsl:template>

  <!--
    open-statement statement.
  -->
  <xsl:template match="open-statement" mode="t:statement">
    <xsl:variable name="files" as="element()+" select="t:get-elements(.)"/>

    <xsl:sequence select="'OPEN'"/>

    <xsl:for-each select="$files">
      <xsl:variable name="option" as="xs:string?" select="@option"/>

      <xsl:sequence select="' '"/>
      <xsl:sequence select="$t:terminator"/>

      <xsl:choose>
        <xsl:when test="self::input">
          <xsl:sequence select="'INPUT'"/>
          <xsl:sequence select="' '"/>
          <xsl:sequence select="t:get-file-ref(file-ref)"/>

          <xsl:if test="exists($option)">
            <xsl:sequence select="' '"/>

            <xsl:sequence select="
              if ($option = 'reversed') then
                'REVERSED'
              else if ($option = 'no-rewind') then
                ('WITH', ' ', 'NO', ' ', 'REWIND')
              else
                error(xs:QName('invalid-open-option'), $option)"/>
          </xsl:if>
        </xsl:when>
        <xsl:when test="self::output">
          <xsl:sequence select="'OUTPUT'"/>
          <xsl:sequence select="' '"/>
          <xsl:sequence select="t:get-file-ref(file-ref)"/>

          <xsl:if test="exists($option)">
            <xsl:sequence select="' '"/>

            <xsl:sequence select="
              if ($option = 'no-rewind') then
                ('WITH', ' ', 'NO', ' ', 'REWIND')
              else
                error(xs:QName('invalid-open-option'), $option)"/>
          </xsl:if>
        </xsl:when>
        <xsl:when test="self::io">
          <xsl:sequence select="'I-O'"/>
          <xsl:sequence select="' '"/>
          <xsl:sequence select="t:get-file-ref(file-ref)"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:sequence select="'EXTEND'"/>
          <xsl:sequence select="' '"/>

          <!-- self::extend/file-ref is to assert element type. -->
          <xsl:sequence select="t:get-file-ref(self::extend/file-ref)"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:for-each>
  </xsl:template>

  <!--
    perform-statement statement.
  -->
  <xsl:template match="perform-statement" mode="t:statement">
    <xsl:variable name="range-ref" as="element()?"
      select="t:get-range-ref-elements(.)"/>
    <xsl:variable name="body" as="element()?" select="body"/>
    <xsl:variable name="times" as="element()?" select="times"/>
    <xsl:variable name="until" as="element()?" select="until"/>
    <xsl:variable name="varying" as="element()*" select="varying"/>

    <xsl:if test="exists($range-ref) = exists($body)">
      <xsl:sequence
        select="error(xs:QName('range-ref-or-body-expected'))"/>
    </xsl:if>

    <xsl:sequence select="'PERFORM'"/>

    <xsl:if test="$range-ref">
      <xsl:sequence select="' '"/>
      <xsl:sequence select="t:get-range-ref($range-ref)"/>
    </xsl:if>

    <xsl:choose>
      <xsl:when test="$times">
        <xsl:variable name="value" as="element()"
          select="t:get-elements($times)"/>

        <xsl:sequence select="' '"/>
        <xsl:sequence select="$t:terminator"/>

        <xsl:if test="not($range-ref)">
          <xsl:sequence select="$t:indent"/>
        </xsl:if>

        <xsl:sequence select="$t:indent"/>

        <xsl:sequence select="
          if ($value[self::integer]) then
            t:get-integer($value)
          else
            t:get-identifier($value)"/>

        <xsl:sequence select="' '"/>
        <xsl:sequence select="$times"/>

        <xsl:sequence select="$t:unindent"/>

        <xsl:if test="not($range-ref)">
          <xsl:sequence select="$t:unindent"/>
        </xsl:if>
      </xsl:when>
      <xsl:when test="$until">
        <xsl:variable name="test" as="xs:string?" select="$until/@test"/>

        <xsl:sequence select="' '"/>
        <xsl:sequence select="$t:terminator"/>

        <xsl:if test="not($range-ref)">
          <xsl:sequence select="$t:indent"/>
        </xsl:if>

        <xsl:sequence select="$t:indent"/>

        <xsl:if test="$test">
          <xsl:sequence select="'WITH'"/>
          <xsl:sequence select="' '"/>
          <xsl:sequence select="'TEST'"/>
          <xsl:sequence select="' '"/>

          <xsl:sequence select="
            if ($test = 'before') then
              'BEFORE'
            else if ($test = 'after') then
              'AFTER'
            else
              error(xs:QName('invalid-until-test'), $test)"/>

          <xsl:sequence select="' '"/>
        </xsl:if>

        <xsl:sequence select="'UNTIL'"/>
        <xsl:sequence select="' '"/>
        <xsl:sequence select="t:get-condition(t:get-elements($until))"/>

        <xsl:sequence select="$t:unindent"/>

        <xsl:if test="not($range-ref)">
          <xsl:sequence select="$t:unindent"/>
        </xsl:if>
      </xsl:when>
      <xsl:when test="$varying">
        <xsl:variable name="test" as="xs:string?" select="$varying[1]/@test"/>

        <xsl:sequence select="' '"/>
        <xsl:sequence select="$t:terminator"/>

        <xsl:if test="not($range-ref)">
          <xsl:sequence select="$t:indent"/>
        </xsl:if>

        <xsl:sequence select="$t:indent"/>

        <xsl:if test="$test">
          <xsl:sequence select="'WITH'"/>
          <xsl:sequence select="' '"/>
          <xsl:sequence select="'TEST'"/>
          <xsl:sequence select="' '"/>

          <xsl:sequence select="
            if ($test = 'before') then
              'BEFORE'
            else if ($test = 'after') then
              'AFTER'
            else
              error(xs:QName('invalid-until-test'), $test)"/>

          <xsl:sequence select="' '"/>
        </xsl:if>

        <xsl:sequence select="'VARYING'"/>

        <xsl:for-each select="$varying">
          <xsl:variable name="varying-from" as="element()" select="from"/>
          <xsl:variable name="varying-by" as="element()" select="by"/>
          <xsl:variable name="varying-until" as="element()" select="until"/>

          <xsl:variable name="varying-value" as="element()" select="
            t:get-elements(.) except
              ($varying-from, $varying-by, $varying-until)"/>

          <xsl:variable name="from-elements" as="element()"
            select="t:get-elements($varying-from)"/>
          <xsl:variable name="by-elements" as="element()"
            select="t:get-elements($varying-by)"/>
          <xsl:variable name="until-elements" as="element()"
            select="t:get-elements($varying-until)"/>

          <xsl:sequence select="' '"/>

          <xsl:if test="position() != 1">
            <xsl:sequence select="'AFTER'"/>
            <xsl:sequence select="' '"/>
          </xsl:if>

          <xsl:sequence
            select="t:get-identifier-or-index-ref($varying-value)"/>

          <xsl:sequence select="' '"/>
          <xsl:sequence select="$t:terminator"/>

          <xsl:sequence select="'FROM'"/>
          <xsl:sequence select="' '"/>

          <xsl:sequence select="
            if ($from-elements[self::index-ref]) then
              t:get-index-ref($from-elements)
            else
              t:get-identifier-or-literal($from-elements)"/>

          <xsl:sequence select="' '"/>
          <xsl:sequence select="$t:terminator"/>

          <xsl:sequence select="'BY'"/>
          <xsl:sequence select="' '"/>
          <xsl:sequence select="t:get-identifier-or-literal($by-elements)"/>

          <xsl:sequence select="' '"/>
          <xsl:sequence select="$t:terminator"/>

          <xsl:sequence select="'UNTIL'"/>
          <xsl:sequence select="' '"/>
          <xsl:sequence select="t:get-condition($until-elements)"/>
        </xsl:for-each>

        <xsl:sequence select="$t:unindent"/>

        <xsl:if test="not($range-ref)">
          <xsl:sequence select="$t:unindent"/>
        </xsl:if>
      </xsl:when>
    </xsl:choose>

    <xsl:if test="empty($range-ref)">
      <xsl:sequence select="$t:new-line"/>

      <xsl:if test="$body">
        <xsl:variable name="statements" as="element()*"
          select="t:get-elements($body)"/>

        <xsl:sequence select="$t:indent"/>

        <xsl:sequence select="t:get-statements($statements, ())"/>

        <xsl:sequence select="$t:unindent"/>
      </xsl:if>

      <xsl:sequence select="'END-PERFORM'"/>
    </xsl:if>
  </xsl:template>

  <!--
    read-statement statement.
  -->
  <xsl:template match="read-statement" mode="t:statement">
    <xsl:variable name="file-ref" as="element()" select="file-ref"/>
    <xsl:variable name="key" as="element()?" select="key"/>
    <xsl:variable name="at-end" as="element()?" select="at-end"/>
    <xsl:variable name="not-at-end" as="element()?" select="not-at-end"/>
    <xsl:variable name="on-invalid-key" as="element()?"
      select="on-invalid-key"/>
    <xsl:variable name="on-valid-key" as="element()?" select="on-valid-key"/>

    <xsl:variable name="into" as="element()?" select="into"/>

    <xsl:sequence select="'READ'"/>
    <xsl:sequence select="' '"/>
    <xsl:sequence select="t:get-file-ref($file-ref)"/>
    <xsl:sequence select="' '"/>
    <xsl:sequence select="'RECORD'"/>

    <xsl:if test="$into">
      <xsl:sequence select="' '"/>
      <xsl:sequence select="'INTO'"/>
      <xsl:sequence select="' '"/>
      <xsl:sequence select="t:get-identifier(t:get-elements($into))"/>
    </xsl:if>

    <xsl:choose>
      <xsl:when test="$key">
        <xsl:sequence select="' '"/>
        <xsl:sequence select="$t:terminator"/>

        <xsl:sequence select="'KEY'"/>
        <xsl:sequence select="' '"/>
        <xsl:sequence select="'IS'"/>
        <xsl:sequence select="' '"/>
        <xsl:sequence
          select="t:get-qualified-data-name(t:get-elements($key))"/>

        <xsl:if test="$on-invalid-key or $on-valid-key">
          <xsl:sequence select="$t:new-line"/>

          <xsl:sequence
            select="t:get-handler($on-invalid-key, 'INVALID KEY')"/>
          <xsl:sequence
            select="t:get-handler($on-valid-key, 'NOT INVALID KEY')"/>

          <xsl:sequence select="'END-READ'"/>
        </xsl:if>
      </xsl:when>
      <xsl:otherwise>
        <xsl:if test="$at-end or $not-at-end">
          <xsl:sequence select="$t:new-line"/>

          <xsl:sequence select="t:get-handler($at-end, 'AT END')"/>
          <xsl:sequence select="t:get-handler($not-at-end, 'NOT AT END')"/>

          <xsl:sequence select="'END-READ'"/>
        </xsl:if>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!--
    release-statement statement.
  -->
  <xsl:template match="release-statement" mode="t:statement">
    <xsl:variable name="from" as="element()?" select="from"/>
    <xsl:variable name="record" as="element()"
      select="t:get-elements(.) except $from"/>

    <xsl:sequence select="'RELEASE'"/>
    <xsl:sequence select="' '"/>
    <xsl:sequence select="t:get-qualified-data-name($record)"/>

    <xsl:if test="$from">
      <xsl:sequence select="' '"/>
      <xsl:sequence select="$t:terminator"/>

      <xsl:sequence select="'FROM'"/>
      <xsl:sequence select="' '"/>
      <xsl:sequence select="t:get-identifier(t:get-elements($from))"/>
    </xsl:if>
  </xsl:template>

  <!--
    return-statement statement.
  -->
  <xsl:template match="return-statement" mode="t:statement">
    <xsl:variable name="file-ref" as="element()" select="file-ref"/>
    <xsl:variable name="at-end" as="element()?" select="at-end"/>
    <xsl:variable name="not-at-end" as="element()?" select="not-at-end"/>
    <xsl:variable name="into" as="element()?" select="into"/>

    <xsl:sequence select="'RETURN'"/>
    <xsl:sequence select="' '"/>
    <xsl:sequence select="t:get-file-ref($file-ref)"/>
    <xsl:sequence select="' '"/>
    <xsl:sequence select="'RECORD'"/>

    <xsl:if test="$into">
      <xsl:sequence select="' '"/>
      <xsl:sequence select="'INTO'"/>
      <xsl:sequence select="' '"/>
      <xsl:sequence select="t:get-identifier(t:get-elements($into))"/>
    </xsl:if>

    <xsl:if test="$at-end or $not-at-end">
      <xsl:sequence select="$t:new-line"/>

      <xsl:sequence select="t:get-handler($at-end, 'AT END')"/>
      <xsl:sequence select="t:get-handler($not-at-end, 'NOT AT END')"/>

      <xsl:sequence select="'END-RETURN'"/>
    </xsl:if>
  </xsl:template>

  <!--
    rewrite-statement statement.
  -->
  <xsl:template match="rewrite-statement" mode="t:statement">
    <xsl:variable name="from" as="element()?" select="from"/>
    <xsl:variable name="on-invalid-key" as="element()?"
      select="on-invalid-key"/>
    <xsl:variable name="on-valid-key" as="element()?"
      select="on-valid-key"/>
    <xsl:variable name="record" as="element()" select="
      t:get-elements(.) except ($from, $on-invalid-key, $on-valid-key)"/>

    <xsl:sequence select="'REWRITE'"/>
    <xsl:sequence select="' '"/>
    <xsl:sequence select="t:get-qualified-data-name($record)"/>

    <xsl:if test="$from">
      <xsl:sequence select="' '"/>
      <xsl:sequence select="$t:terminator"/>

      <xsl:sequence select="'FROM'"/>
      <xsl:sequence select="' '"/>
      <xsl:sequence select="t:get-identifier(t:get-elements($from))"/>
    </xsl:if>

    <xsl:if test="$on-invalid-key or $on-valid-key">
      <xsl:sequence select="$t:new-line"/>

      <xsl:sequence select="t:get-handler($on-invalid-key, 'INVALID KEY')"/>
      <xsl:sequence select="t:get-handler($on-valid-key, 'NOT INVALID KEY')"/>

      <xsl:sequence select="'END-DELETE'"/>
    </xsl:if>
  </xsl:template>

  <!--
    search-statement statement.
  -->
  <xsl:template match="search-statement" mode="t:statement">
    <xsl:variable name="all" as="xs:boolean?" select="@all"/>
    <xsl:variable name="varying" as="element()?" select="varying"/>
    <xsl:variable name="when" as="element()+" select="when"/>
    <xsl:variable name="at-end" as="element()?" select="at-end"/>
    <xsl:variable name="value" as="element()"
      select="t:get-elements(.) except ($varying, $when, $at-end)"/>

    <xsl:sequence select="'SEARCH'"/>

    <xsl:if test="$all">
      <xsl:sequence select="' '"/>
      <xsl:sequence select="'ALL'"/>
    </xsl:if>

    <xsl:sequence select="' '"/>
    <xsl:sequence select="t:get-identifier($value)"/>

    <xsl:if test="$varying">
      <xsl:sequence select="' '"/>
      <xsl:sequence select="$t:terminator"/>

      <xsl:sequence select="'VARYING'"/>
      <xsl:sequence select="' '"/>
      <xsl:sequence
        select="t:get-identifier-or-index-ref(t:get-elements($varying))"/>
    </xsl:if>

    <xsl:sequence select="$t:new-line"/>

    <xsl:if test="$at-end">
      <xsl:sequence select="t:get-handler($at-end, 'AT END')"/>
    </xsl:if>

    <xsl:for-each select="$when">
      <xsl:variable name="condition" as="element()" select="condition"/>
      <xsl:variable name="body" as="element()?" select="body"/>
      <xsl:variable name="statements" as="element()*"
        select="t:get-elements($body)"/>

      <xsl:sequence select="'WHEN'"/>
      <xsl:sequence select="' '"/>
      <xsl:sequence select="t:get-condition(t:get-elements($condition))"/>
      <xsl:sequence select="$t:new-line"/>

      <xsl:sequence select="$t:indent"/>

      <xsl:sequence select="t:get-statements($statements, ())"/>

      <xsl:sequence select="$t:unindent"/>
    </xsl:for-each>

    <xsl:sequence select="'END-SEARCH'"/>
  </xsl:template>

  <!--
    set-statement statement.
  -->
  <xsl:template match="set-statement" mode="t:statement">
    <xsl:variable name="condition-ref" as="element()*" select="condition-ref"/>
    <xsl:variable name="mnemonic" as="element()*" select="mnemonic"/>

    <xsl:sequence select="'SET'"/>

    <xsl:choose>
      <xsl:when test="$condition-ref">
        <xsl:for-each select="$condition-ref">
          <xsl:sequence select="' '"/>
          <xsl:sequence select="t:get-condition($condition-ref)"/>

          <xsl:if test="position() != last()">
            <xsl:sequence select="$t:terminator"/>
          </xsl:if>
        </xsl:for-each>

        <xsl:sequence select="' '"/>
        <xsl:sequence select="'TO'"/>
        <xsl:sequence select="' '"/>
        <xsl:sequence select="'TRUE'"/>
      </xsl:when>
      <xsl:when test="exists($mnemonic)">
        <xsl:for-each select="$mnemonic">
          <xsl:variable name="name" as="xs:string" select="@name"/>
          <xsl:variable name="value" as="xs:string" select="@value"/>

          <xsl:sequence select="' '"/>
          <xsl:sequence select="$name"/>
          <xsl:sequence select="' '"/>

          <xsl:sequence select="
            if ($value = 'on') then
              'ON'
            else if ($value = 'off') then
              'OFF'
            else
              error(xs:QName('invalid-mnemonic-value'), $value)"/>
        </xsl:for-each>
      </xsl:when>
      <xsl:otherwise>
        <xsl:variable name="to" as="element()?" select="to"/>
        <xsl:variable name="up-by" as="element()?" select="up-by"/>
        <xsl:variable name="down-by" as="element()?" select="down-by"/>
        <xsl:variable name="other" as="element()"
          select="$to, $up-by, $down-by"/>
        <xsl:variable name="target" as="element()+"
          select="t:get-elements(.) except $other"/>

        <xsl:for-each select="$target">
          <xsl:sequence select="' '"/>
          <xsl:sequence select="t:get-identifier-or-index-ref(.)"/>

          <xsl:if test="position() != last()">
            <xsl:sequence select="$t:terminator"/>
          </xsl:if>
        </xsl:for-each>

        <xsl:choose>
          <xsl:when test="$to">
            <xsl:variable name="value" as="element()"
              select="t:get-elements($to)"/>

            <xsl:sequence select="' '"/>
            <xsl:sequence select="$t:terminator"/>

            <xsl:sequence select="'TO'"/>
            <xsl:sequence select="' '"/>

            <xsl:sequence select="
              if (exists($value[self::integer, self::null])) then
                t:get-literal($value)
              else
                t:get-identifier-or-index-ref($value)"/>
          </xsl:when>
          <xsl:when test="$up-by">
            <xsl:variable name="value" as="element()"
              select="t:get-elements($up-by)"/>

            <xsl:sequence select="' '"/>
            <xsl:sequence select="'UP'"/>
            <xsl:sequence select="' '"/>
            <xsl:sequence select="'BY'"/>
            <xsl:sequence select="' '"/>

            <xsl:sequence select="
              if ($value[self::integer]) then
                t:get-integer($value)
              else
                t:get-identifier($value)"/>
          </xsl:when>
          <xsl:when test="$down-by">
            <xsl:variable name="value" as="element()"
              select="t:get-elements($down-by)"/>

            <xsl:sequence select="' '"/>
            <xsl:sequence select="'DOWN'"/>
            <xsl:sequence select="' '"/>
            <xsl:sequence select="'BY'"/>
            <xsl:sequence select="' '"/>

            <xsl:sequence select="
              if ($value[self::integer]) then
                t:get-integer($value)
              else
                t:get-identifier($value)"/>
          </xsl:when>
        </xsl:choose>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!--
    sort-statement statement.
  -->
  <xsl:template match="sort-statement" mode="t:statement">
    <xsl:variable name="file-ref" as="element()" select="file-ref"/>
    <xsl:variable name="duplicates-in-order" as="xs:boolean?"
      select="@duplicates-in-order"/>
    <xsl:variable name="collation" as="xs:string?" select="@collation"/>
    <xsl:variable name="order-by" as="element()*" select="order-by"/>
    <xsl:variable name="using" as="element()?" select="using"/>
    <xsl:variable name="input" as="element()?" select="input"/>
    <xsl:variable name="giving" as="element()?" select="giving"/>
    <xsl:variable name="output" as="element()?" select="output"/>

    <xsl:sequence select="'SORT'"/>
    <xsl:sequence select="' '"/>
    <xsl:sequence select="t:get-file-ref($file-ref)"/>

    <xsl:for-each select="$order-by">
      <xsl:variable name="direction" as="xs:string" select="@direction"/>

      <xsl:sequence select="$t:new-line"/>

      <xsl:sequence select="ON"/>
      <xsl:sequence select="' '"/>

      <xsl:sequence select="
        if ($direction = 'ascending') then
          'ASCENDING'
        else if ($direction = 'descending') then
          'DESCENDING'
        else
          error(xs:QName('invalid-order-direction'), $direction)"/>

      <xsl:sequence select="' '"/>
      <xsl:sequence select="'KEY'"/>
      <xsl:sequence select="' '"/>
      <xsl:sequence select="t:get-qualified-data-name(t:get-elements(.))"/>
    </xsl:for-each>

    <xsl:if test="$duplicates-in-order">
      <xsl:sequence select="$t:new-line"/>

      <xsl:sequence select="'WITH'"/>
      <xsl:sequence select="' '"/>
      <xsl:sequence select="'DUPLICATES'"/>
      <xsl:sequence select="' '"/>
      <xsl:sequence select="'IN'"/>
      <xsl:sequence select="' '"/>
      <xsl:sequence select="'ORDER'"/>
    </xsl:if>

    <xsl:if test="$collation">
      <xsl:sequence select="$t:new-line"/>

      <xsl:sequence select="'COLLATING'"/>
      <xsl:sequence select="' '"/>
      <xsl:sequence select="'SEQUENCE'"/>
      <xsl:sequence select="' '"/>
      <xsl:sequence select="'IS'"/>
      <xsl:sequence select="' '"/>
      <xsl:sequence select="$collation"/>
    </xsl:if>

    <xsl:choose>
      <xsl:when test="$using">
        <xsl:variable name="using-file-refs" as="element()+"
          select="$using/file-ref"/>

        <xsl:sequence select="$t:new-line"/>

        <xsl:sequence select="'USING'"/>

        <xsl:sequence select="$t:indent"/>

        <xsl:for-each select="$using-file-refs">
          <xsl:sequence select="$t:new-line"/>

          <xsl:sequence select="t:get-file-ref(.)"/>
        </xsl:for-each>

        <xsl:sequence select="$t:unindent"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:sequence select="$t:new-line"/>

        <xsl:sequence select="'INPUT'"/>
        <xsl:sequence select="' '"/>
        <xsl:sequence select="'PROCEDURE'"/>
        <xsl:sequence select="' '"/>
        <xsl:sequence select="'IS'"/>
        <xsl:sequence select="' '"/>
        <xsl:sequence
          select="t:get-range-ref(t:get-range-ref-elements($input))"/>
      </xsl:otherwise>
    </xsl:choose>

    <xsl:choose>
      <xsl:when test="$giving">
        <xsl:variable name="giving-file-refs" as="element()"
          select="$giving/file-ref"/>

        <xsl:sequence select="$t:new-line"/>

        <xsl:sequence select="'GIVING'"/>

        <xsl:for-each select="$giving-file-refs">
          <xsl:sequence select="' '"/>
          <xsl:sequence select="$t:terminator"/>

          <xsl:sequence select="t:get-file-ref(.)"/>
        </xsl:for-each>
      </xsl:when>
      <xsl:otherwise>
        <xsl:sequence select="$t:new-line"/>

        <xsl:sequence select="'OUTPUT'"/>
        <xsl:sequence select="' '"/>
        <xsl:sequence select="'PROCEDURE'"/>
        <xsl:sequence select="' '"/>
        <xsl:sequence select="'IS'"/>
        <xsl:sequence select="' '"/>
        <xsl:sequence
          select="t:get-range-ref(t:get-range-ref-elements($output))"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!--
    start-statement statement.
  -->
  <xsl:template match="start-statement" mode="t:statement">
    <xsl:variable name="file-ref" as="element()" select="file-ref"/>
    <xsl:variable name="key" as="element()?" select="key"/>
    <xsl:variable name="on-invalid-key" as="element()?"
      select="on-invalid-key"/>
    <xsl:variable name="on-valid-key" as="element()?"
      select="on-valid-key"/>

    <xsl:sequence select="'START'"/>
    <xsl:sequence select="' '"/>
    <xsl:sequence select="t:get-file-ref($file-ref)"/>

    <xsl:if test="$key">
      <xsl:variable name="condition" as="xs:string" select="$key/@condition"/>
      <xsl:variable name="data-name" as="element()" select="t:get-elements($key)"/>

      <xsl:sequence select="' '"/>
      <xsl:sequence select="$t:terminator"/>

      <xsl:sequence select="'KEY'"/>
      <xsl:sequence select="' '"/>
      <xsl:sequence select="'IS'"/>
      <xsl:sequence select="' '"/>

      <xsl:sequence select="
        if ($condition = 'eq') then
          '='
        else if ($condition = 'gt') then
          '>'
        else if ($condition = 'ge') then
          '>='
        else
          error(xs:QName('invalid-start-condition'), $condition)"/>

      <xsl:sequence select="' '"/>
      <xsl:sequence select="t:get-qualified-data-name($data-name)"/>
    </xsl:if>

    <xsl:if test="$on-invalid-key or $on-valid-key">
      <xsl:sequence select="$t:new-line"/>

      <xsl:sequence select="t:get-handler($on-invalid-key, 'INVALID KEY')"/>
      <xsl:sequence select="t:get-handler($on-valid-key, 'NOT INVALID KEY')"/>

      <xsl:sequence select="'END-ADD'"/>
    </xsl:if>
  </xsl:template>

  <!--
    stop-statement statement.
  -->
  <xsl:template match="stop-statement" mode="t:statement">
    <xsl:sequence select="'STOP'"/>
    <xsl:sequence select="' '"/>

    <xsl:sequence select="
      if (exists(run)) then
        'RUN'
      else
        t:get-literal(t:get-elements(.))"/>
  </xsl:template>

  <!--
    string-statement statement.
  -->
  <xsl:template match="string-statement" mode="t:statement">
    <xsl:variable name="into" as="element()" select="into"/>
    <xsl:variable name="pointer" as="element()?" select="pointer"/>
    <xsl:variable name="on-overflow" as="element()?" select="on-overflow"/>
    <xsl:variable name="on-succeed" as="element()?" select="on-succeed"/>
    <xsl:variable name="values" as="element()+" select="values"/>

    <xsl:sequence select="'STRING'"/>

    <xsl:for-each select="$values">
      <xsl:variable name="delimited-by" as="element()" select="delimited-by"/>
      <xsl:variable name="expressions" as="element()+" 
        select="t:get-elements(.) except $delimited-by"/>

      <xsl:for-each select="$expressions">
        <xsl:sequence select="' '"/>
        <xsl:sequence select="$t:terminator"/>

        <xsl:sequence select="t:get-identifier-or-literal(.)"/>
      </xsl:for-each>

      <xsl:sequence select="' '"/>
      <xsl:sequence select="$t:terminator"/>

      <xsl:sequence select="'DELIMITED'"/>
      <xsl:sequence select="' '"/>
      <xsl:sequence select="'BY'"/>
      <xsl:sequence select="' '"/>

      <xsl:sequence select="
        if ($delimited-by/size) then
          'SIZE'
        else
          t:get-identifier-or-literal(t:get-elements($delimited-by))"/>
    </xsl:for-each>

    <xsl:sequence select="' '"/>
    <xsl:sequence select="'INTO'"/>
    <xsl:sequence select="$t:indent"/>

    <xsl:sequence select="' '"/>
    <xsl:sequence select="$t:terminator"/>
    <xsl:sequence select="t:get-identifier(t:get-elements($into))"/>

    <xsl:if test="$pointer">
      <xsl:sequence select="' '"/>
      <xsl:sequence select="$t:terminator"/>

      <xsl:sequence select="$t:unindent"/>
      <xsl:sequence select="'WITH'"/>
      <xsl:sequence select="' '"/>
      <xsl:sequence select="'POINTER'"/>
      <xsl:sequence select="$t:indent"/>

      <xsl:sequence select="' '"/>
      <xsl:sequence select="$t:terminator"/>
      <xsl:sequence select="t:get-identifier(t:get-elements($pointer))"/>
    </xsl:if>

    <xsl:sequence select="$t:unindent"/>

    <xsl:if test="$on-overflow or $on-succeed">
      <xsl:sequence select="$t:new-line"/>

      <xsl:sequence select="t:get-handler($on-overflow, 'ON OVERFLOW')"/>
      <xsl:sequence select="t:get-handler($on-succeed, 'NOT ON OVERFLOW')"/>

      <xsl:sequence select="'END-STRING'"/>
    </xsl:if>
  </xsl:template>

  <!--
    subtract-statement statement.
  -->
  <xsl:template match="subtract-statement" mode="t:statement">
    <xsl:variable name="corresponding" as="xs:boolean?"
      select="@corresponding"/>
    <xsl:variable name="from" as="element()+" select="from"/>
    <xsl:variable name="giving" as="element()*" select="giving"/>
    <xsl:variable name="on-size-error" as="element()?" select="on-size-error"/>
    <xsl:variable name="on-succeed" as="element()?" select="on-succeed"/>
    <xsl:variable name="values" as="element()+" select="
      t:get-elements(.) except ($from, $giving, $on-size-error, $on-succeed)"/>

    <xsl:sequence select="'SUBTRACT'"/>

    <xsl:if test="$corresponding">
      <xsl:sequence select="' '"/>
      <xsl:sequence select="'CORRESPONDING'"/>
    </xsl:if>

    <xsl:for-each select="$values">
      <xsl:sequence select="' '"/>
      <xsl:sequence select="$t:terminator"/>

      <xsl:sequence select="t:get-identifier-or-literal(.)"/>
    </xsl:for-each>

    <xsl:sequence select="' '"/>
    <xsl:sequence select="$t:terminator"/>

    <xsl:sequence select="$t:unindent"/>
    <xsl:sequence select="'FROM'"/>
    <xsl:sequence select="$t:indent"/>

    <xsl:for-each select="$from">
      <xsl:variable name="rounded" as="xs:boolean?" select="@rounded"/>

      <xsl:sequence select="' '"/>
      <xsl:sequence select="$t:terminator"/>

      <xsl:sequence
        select="t:get-identifier-or-literal(t:get-elements(.))"/>

      <xsl:if test="$rounded">
        <xsl:sequence select="' '"/>
        <xsl:sequence select="'ROUNDED'"/>
      </xsl:if>
    </xsl:for-each>

    <xsl:if test="$giving">
      <xsl:sequence select="' '"/>
      <xsl:sequence select="$t:terminator"/>

      <xsl:sequence select="'GIVING'"/>

      <xsl:for-each select="$giving">
        <xsl:variable name="rounded" as="xs:boolean?" select="@rounded"/>

        <xsl:sequence select="' '"/>
        <xsl:sequence select="$t:terminator"/>

        <xsl:sequence select="t:get-identifier(t:get-elements(.))"/>

        <xsl:if test="$rounded">
          <xsl:sequence select="' '"/>
          <xsl:sequence select="'ROUNDED'"/>
        </xsl:if>
      </xsl:for-each>
    </xsl:if>

    <xsl:if test="$on-size-error or $on-succeed">
      <xsl:sequence select="$t:new-line"/>

      <xsl:sequence select="t:get-handler($on-size-error, 'ON SIZE ERROR')"/>
      <xsl:sequence select="t:get-handler($on-succeed, 'NOT ON SIZE ERROR')"/>

      <xsl:sequence select="'END-SUBTRACT'"/>
    </xsl:if>
  </xsl:template>

  <!--
    unstring-statement statement.
  -->
  <xsl:template match="unstring-statement" mode="t:statement">
    <xsl:variable name="delimited-by" as="element()*" select="delimited-by"/>
    <xsl:variable name="into" as="element()+" select="into"/>
    <xsl:variable name="pointer" as="element()?" select="pointer"/>
    <xsl:variable name="tallying" as="element()?" select="tallying"/>
    <xsl:variable name="on-overflow" as="element()?" select="on-overflow"/>
    <xsl:variable name="on-succeed" as="element()?" select="on-succeed"/>

    <xsl:variable name="value" as="element()" select="
      t:get-elements(.) except
        (
          $delimited-by,
          $into,
          $pointer,
          $tallying,
          $on-overflow,
          $on-succeed
        )"/>

    <xsl:sequence select="'UNSTRING'"/>
    <xsl:sequence select="' '"/>
    <xsl:sequence select="t:get-identifier($value)"/>

    <xsl:if test="$delimited-by">
      <xsl:sequence select="' '"/>
      <xsl:sequence select="$t:terminator"/>

      <xsl:sequence select="$t:unindent"/>
      <xsl:sequence select="'DELIMITED'"/>
      <xsl:sequence select="' '"/>
      <xsl:sequence select="'BY'"/>
      <xsl:sequence select="$t:indent"/>

      <xsl:for-each select="$delimited-by">
        <xsl:variable name="all" as="xs:boolean?" select="@all"/>

        <xsl:sequence select="' '"/>
        <xsl:sequence select="$t:terminator"/>

        <xsl:if test="position() gt 1">
          <xsl:sequence select="'OR'"/>
          <xsl:sequence select="' '"/>
        </xsl:if>

        <xsl:if test="$all">
          <xsl:sequence select="'ALL'"/>
          <xsl:sequence select="' '"/>
        </xsl:if>

        <xsl:sequence
          select="t:get-identifier-or-literal(t:get-elements(.))"/>
      </xsl:for-each>
    </xsl:if>

    <xsl:sequence select="' '"/>
    <xsl:sequence select="$t:terminator"/>

    <xsl:sequence select="$t:unindent"/>
    <xsl:sequence select="'INTO'"/>
    <xsl:sequence select="$t:indent"/>

    <xsl:for-each select="$into">
      <xsl:variable name="delimiter" as="element()?" select="delimiter"/>
      <xsl:variable name="count" as="element()?" select="count"/>
      <xsl:variable name="into-value" as="element()"
        select="t:get-elements(.) except ($delimiter, $count)"/>

      <xsl:sequence select="' '"/>
      <xsl:sequence select="$t:terminator"/>

      <xsl:sequence select="t:get-identifier($into-value)"/>

      <xsl:if test="$delimiter">
        <xsl:sequence select="' '"/>
        <xsl:sequence select="$t:terminator"/>

        <xsl:sequence select="$t:unindent"/>
        <xsl:sequence select="'DELIMITER'"/>
        <xsl:sequence select="' '"/>
        <xsl:sequence select="'IN'"/>
        <xsl:sequence select="$t:indent"/>

        <xsl:sequence select="' '"/>
        <xsl:sequence
          select="t:get-identifier(t:get-elements($delimiter))"/>
        <xsl:sequence select="$t:new-line"/>
      </xsl:if>

      <xsl:if test="$count">
        <xsl:sequence select="' '"/>
        <xsl:sequence select="$t:terminator"/>

        <xsl:sequence select="$t:unindent"/>
        <xsl:sequence select="'COUNT'"/>
        <xsl:sequence select="' '"/>
        <xsl:sequence select="'IN'"/>
        <xsl:sequence select="$t:indent"/>

        <xsl:sequence select="' '"/>
        <xsl:sequence
          select="t:get-identifier(t:get-elements($count))"/>
      </xsl:if>
    </xsl:for-each>

    <xsl:if test="$pointer">
      <xsl:sequence select="' '"/>
      <xsl:sequence select="$t:terminator"/>

      <xsl:sequence select="$t:unindent"/>
      <xsl:sequence select="'WITH'"/>
      <xsl:sequence select="' '"/>
      <xsl:sequence select="'POINTER'"/>
      <xsl:sequence select="$t:indent"/>

      <xsl:sequence select="' '"/>
      <xsl:sequence select="t:get-identifier(t:get-elements($pointer))"/>
    </xsl:if>

    <xsl:if test="$tallying">
      <xsl:sequence select="' '"/>
      <xsl:sequence select="$t:terminator"/>

      <xsl:sequence select="$t:unindent"/>
      <xsl:sequence select="'TALLYING'"/>
      <xsl:sequence select="' '"/>
      <xsl:sequence select="'IN'"/>
      <xsl:sequence select="$t:indent"/>

      <xsl:sequence select="' '"/>
      <xsl:sequence select="t:get-identifier(t:get-elements($tallying))"/>
    </xsl:if>

    <xsl:if test="$on-overflow or $on-succeed">
      <xsl:sequence select="$t:new-line"/>

      <xsl:sequence select="t:get-handler($on-overflow, 'ON OVERFLOW')"/>
      <xsl:sequence select="t:get-handler($on-succeed, 'NOT ON OVERFLOW')"/>

      <xsl:sequence select="'END-STRING'"/>
    </xsl:if>
  </xsl:template>

  <!--
    write-statement statement.
  -->
  <xsl:template match="write-statement" mode="t:statement">
    <xsl:variable name="from" as="element()" select="from"/>
    <xsl:variable name="advancing" as="element()?"
      select="before-advancing, after-advancing"/>
    <xsl:variable name="at-end-of-page" as="element()?"
      select="at-end-of-page"/>
    <xsl:variable name="not-at-end-of-page" as="element()?"
      select="not-at-end-of-page"/>
    <xsl:variable name="on-invalid-key" as="element()?"
      select="on-invalid-key"/>
    <xsl:variable name="on-valid-key" as="element()?"
      select="on-valid-key"/>

    <xsl:variable name="record" as="element()?" select="
      t:get-elements(.) except
        (
          $from,
          $advancing,
          $advancing,
          $at-end-of-page,
          $not-at-end-of-page,
          $on-invalid-key,
          $on-valid-key
        )"/>

    <xsl:sequence select="'WRITE'"/>
    <xsl:sequence select="' '"/>
    <xsl:sequence select="t:get-qualified-data-name($record)"/>

    <xsl:if test="$from">
      <xsl:sequence select="' '"/>
      <xsl:sequence select="$t:terminator"/>

      <xsl:sequence select="'FROM'"/>
      <xsl:sequence select="' '"/>
      <xsl:sequence select="t:get-identifier(t:get-elements($from))"/>
    </xsl:if>

    <xsl:if test="$advancing">
      <xsl:variable name="mnemonic" as="xs:string?" select="@name"/>
      <xsl:variable name="step" as="element()?" select="t:get-elements(.)"/>

      <xsl:sequence select="' '"/>
      <xsl:sequence select="$t:terminator"/>

      <xsl:sequence select="
        if ($advancing[self::before-advancing]) then
          'BEFORE'
        else
          'AFTER'"/>

      <xsl:sequence select="' '"/>
      <xsl:sequence select="'ADVANCING'"/>
      <xsl:sequence select="' '"/>

      <xsl:choose>
        <xsl:when test="$mnemonic">
          <xsl:sequence select="$mnemonic"/>
        </xsl:when>
        <xsl:when test="$step[self::page]">
          <xsl:sequence select="'PAGE'"/>
        </xsl:when>
        <xsl:when test="$step[self::integer]">
          <xsl:sequence select="t:get-integer($step)"/>
          <xsl:sequence select="' '"/>

          <xsl:sequence select="
            if ($step/xs:integer(@value) = 1) then
              'LINE'
            else
              'LINES'"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:sequence select="t:get-identifier($step)"/>
          <xsl:sequence select="' '"/>
          <xsl:sequence select="'LINES'"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:if>

    <xsl:if test="
      $at-end-of-page or
      $not-at-end-of-page or
      $on-invalid-key or
      $on-valid-key">
      <xsl:sequence select="$t:new-line"/>

      <xsl:sequence
        select="t:get-handler($at-end-of-page, 'AT END-OF-PAGE')"/>
      <xsl:sequence
        select="t:get-handler($not-at-end-of-page, 'NOT AT END-OF-PAGE')"/>

      <xsl:sequence select="t:get-handler($on-invalid-key, 'INVALID KEY')"/>
      <xsl:sequence select="t:get-handler($on-valid-key, 'NOT INVALID KEY')"/>

      <xsl:sequence select="'END-WRITE'"/>
    </xsl:if>
  </xsl:template>

  <!--
    section element.
  -->
  <xsl:template match="section" mode="t:element">
    <xsl:sequence select="t:get-section(., ())"/>
  </xsl:template>

  <!--
    paragraph element.
  -->
  <xsl:template match="paragraph" mode="t:element">
    <xsl:sequence select="t:get-paragraph(.)"/>
  </xsl:template>

  <!--
    Tests whether this statement is or contains statements
    other than scope-statements.
      $statement - a statement to test.
      Returns true if this statement is or contains statements
      other than scope-statements, and false otherwise.
  -->
  <xsl:function name="t:has-statements" as="xs:boolean">
    <xsl:param name="statement" as="element()"/>

    <xsl:sequence select="
      not($statement/(self::scope-statement or self::expression-statement)) or
      (t:get-elements($statement)/t:has-statements(.) = true())"/>
  </xsl:function>

</xsl:stylesheet>