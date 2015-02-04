<?xml version="1.0" encoding="utf-8"?>
<!--
  This stylesheet serializes COBOL xml object model document down to
  the COBOL text.

  $Id$
 -->
<xsl:stylesheet version="2.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:t="http://www.bphx.com/cobol"
  xmlns="http://www.bphx.com/cobol/2009-12-15"
  xmlns:cobol="http://www.bphx.com/cobol/2009-12-15"
  xpath-default-namespace="http://www.bphx.com/cobol/2009-12-15"
  exclude-result-prefixes="xs t cobol">

  <xsl:include href="cobol-common.xslt"/>
  <xsl:include href="cobol-streamer.xslt"/>
  <xsl:include href="cobol-serializer-comments.xslt"/>
  <xsl:include href="cobol-serializer-expressions.xslt"/>
  <xsl:include href="cobol-serializer-statements.xslt"/>

  <!--
    Gets a sequence of tokens for a program.
      $program - a program.
      Returns a sequence of tokens.
  -->
  <xsl:function name="t:get-program" as="item()*">
    <xsl:param name="program" as="element()"/>

    <xsl:sequence select="t:get-program($program, false())"/>
  </xsl:function>

  <!--
    Gets a sequence of tokens for a program.
      $program - a program.
      $nested - true for a nested program, and false otherwise.
      Returns a sequence of tokens.
  -->
  <xsl:function name="t:get-program" as="item()*">
    <xsl:param name="program" as="element()"/>
    <xsl:param name="nested" as="xs:boolean?"/>

    <xsl:variable name="name" as="xs:string" select="$program/@name"/>
    <xsl:variable name="initial" as="xs:boolean?" select="$program/@initial"/>
    <xsl:variable name="recursive" as="xs:boolean?"
      select="$program/@recursive"/>
    <xsl:variable name="author" as="xs:string?" select="$program/@author"/>
    <xsl:variable name="installation" as="xs:string?"
      select="$program/@installation"/>
    <xsl:variable name="date-written" as="xs:string?"
      select="$program/@date-written"/>
    <xsl:variable name="date-compiled" as="xs:string?"
      select="$program/@date-compiled"/>
    <xsl:variable name="security" as="xs:string?"
      select="$program/@security"/>

    <xsl:sequence select="'IDENTIFICATION'"/>
    <xsl:sequence select="' '"/>
    <xsl:sequence select="'DIVISION'"/>
    <xsl:sequence select="'.'"/>
    <xsl:sequence select="$t:new-line"/>
    <xsl:sequence select="'PROGRAM-ID'"/>
    <xsl:sequence select="'.'"/>
    <xsl:sequence select="' '"/>
    <xsl:sequence select="$name"/>

    <xsl:if test="$recursive">
      <xsl:sequence select="' '"/>
      <xsl:sequence select="'RECURSIVE'"/>
    </xsl:if>

    <xsl:sequence select="'.'"/>
    <xsl:sequence select="$t:new-line"/>

    <xsl:if test="$initial">
      <xsl:sequence select="'INITIAL'"/>
      <xsl:sequence select="'.'"/>
    </xsl:if>

    <xsl:if test="$author">
      <xsl:sequence select="'AUTHOR'"/>
      <xsl:sequence select="'.'"/>
      <xsl:sequence select="' '"/>
      <xsl:sequence select="$author"/>
    </xsl:if>

    <xsl:if test="$installation">
      <xsl:sequence select="'INSTALLATION'"/>
      <xsl:sequence select="'.'"/>
      <xsl:sequence select="' '"/>
      <xsl:sequence select="$installation"/>
    </xsl:if>

    <xsl:if test="$date-written">
      <xsl:sequence select="'DATE-WRITTEN'"/>
      <xsl:sequence select="'.'"/>
      <xsl:sequence select="' '"/>
      <xsl:sequence select="$date-written"/>
    </xsl:if>

    <xsl:if test="$date-compiled">
      <xsl:sequence select="'DATE-COMPILED'"/>
      <xsl:sequence select="'.'"/>
      <xsl:sequence select="' '"/>
      <xsl:sequence select="$date-compiled"/>
    </xsl:if>

    <xsl:if test="$security">
      <xsl:sequence select="'SECURITY'"/>
      <xsl:sequence select="'.'"/>
      <xsl:sequence select="' '"/>
      <xsl:sequence select="$security"/>
    </xsl:if>

    <xsl:sequence select="t:get-comments($program)"/>

    <xsl:sequence
      select="$program/environment-division/t:get-environment-division(.)"/>
    <xsl:sequence
      select="$program/data-division/t:get-data-division(.)"/>
    <xsl:sequence
      select="$program/procedure-division/t:get-procedure-division(.)"/>

    <xsl:variable name="nested-programs" as="element()*"
      select="$program/program"/>

    <xsl:if test="$nested-programs">
      <xsl:sequence select="$t:indent"/>

      <xsl:for-each select="$nested-programs">
        <xsl:if test="position() != 1">
          <xsl:sequence select="$t:new-line"/>
        </xsl:if>

        <xsl:sequence select="t:get-program(., true())"/>
      </xsl:for-each>

      <xsl:sequence select="$t:unindent"/>
    </xsl:if>

    <xsl:if test="$nested or $nested-programs">
      <xsl:sequence select="'END'"/>
      <xsl:sequence select="' '"/>
      <xsl:sequence select="'PROGRAM'"/>
      <xsl:sequence select="' '"/>
      <xsl:sequence select="$name"/>
      <xsl:sequence select="'.'"/>
      <xsl:sequence select="$t:new-line"/>
    </xsl:if>
  </xsl:function>

  <!--
    Gets a sequence of tokens for an environment division.
      $environment-division - an environment-division.
      Returns a sequence of tokens.
  -->
  <xsl:function name="t:get-environment-division" as="item()*">
    <xsl:param name="environment-division" as="element()"/>

    <xsl:sequence select="t:get-comments($environment-division)"/>

    <xsl:sequence select="$t:new-line"/>
    <xsl:sequence select="'ENVIRONMENT'"/>
    <xsl:sequence select="' '"/>
    <xsl:sequence select="'DIVISION'"/>
    <xsl:sequence select="'.'"/>
    <xsl:sequence select="$t:new-line"/>

    <xsl:sequence select="
      $environment-division/configuration-section/
        t:get-configuration-section(.)"/>
    <xsl:sequence select="
      $environment-division/input-output-section/
        t:get-input-output-section(.)"/>
  </xsl:function>

  <!--
    Gets a sequence of tokens for a configuration-section.
      $configuration-section - a configuration section.
      Returns a sequence of tokens.
  -->
  <xsl:function name="t:get-configuration-section" as="item()*">
    <xsl:param name="configuration-section" as="element()"/>

    <xsl:variable name="source-computer" as="element()?"
      select="$configuration-section/source-computer"/>
    <xsl:variable name="object-computer" as="element()?"
      select="$configuration-section/object-computer"/>
    <xsl:variable name="special-names" as="element()?"
      select="$configuration-section/special-names"/>

    <xsl:sequence select="t:get-comments($configuration-section)"/>

    <xsl:sequence select="'CONFIGURATION'"/>
    <xsl:sequence select="' '"/>
    <xsl:sequence select="'SECTION'"/>
    <xsl:sequence select="'.'"/>
    <xsl:sequence select="$t:new-line"/>

    <xsl:if test="$source-computer">
      <xsl:variable name="name" as="xs:string?"
        select="$source-computer/@name"/>
      <xsl:variable name="debugging" as="xs:boolean?"
        select="$source-computer/@debugging"/>

      <xsl:sequence select="t:get-comments($source-computer)"/>

      <xsl:sequence select="'SOURCE-COMPUTER'"/>
      <xsl:sequence select="'.'"/>

      <xsl:if test="$name">
        <xsl:sequence select="$t:new-line"/>
        <xsl:sequence select="$t:indent"/>

        <xsl:sequence select="$name"/>

        <xsl:if test="$debugging">
          <xsl:sequence select="' '"/>
          <xsl:sequence select="'WITH'"/>
          <xsl:sequence select="' '"/>
          <xsl:sequence select="'DEBUGGING'"/>
          <xsl:sequence select="' '"/>
          <xsl:sequence select="'MODE'"/>
        </xsl:if>

        <xsl:sequence select="'.'"/>
        <xsl:sequence select="$t:unindent"/>
      </xsl:if>

      <xsl:sequence select="$t:new-line"/>
    </xsl:if>

    <xsl:if test="$object-computer">
      <xsl:variable name="name" as="xs:string?"
        select="$object-computer/@name"/>
      <xsl:variable name="memory-size" as="xs:integer?"
        select="$object-computer/@memory-size"/>
      <xsl:variable name="memory-dimension" as="xs:string?"
        select="$object-computer/@memory-dimension"/>
      <xsl:variable name="collation" as="xs:string?"
        select="$object-computer/@memory-dimension"/>
      <xsl:variable name="segment-limit" as="xs:integer?"
        select="$object-computer/@segment-limit"/>

      <xsl:sequence select="t:get-comments($object-computer)"/>

      <xsl:sequence select="'OBJECT-COMPUTER'"/>
      <xsl:sequence select="'.'"/>

      <xsl:if test="$name">
        <xsl:sequence select="$t:new-line"/>
        <xsl:sequence select="$t:indent"/>

        <xsl:sequence select="$name"/>

        <xsl:if test="exists($memory-size)">
          <xsl:sequence select="$t:new-line"/>

          <xsl:sequence select="' '"/>
          <xsl:sequence select="'MEMORY'"/>
          <xsl:sequence select="' '"/>
          <xsl:sequence select="'SIZE'"/>
          <xsl:sequence select="' '"/>
          <xsl:sequence select="xs:string($memory-size)"/>

          <xsl:sequence select="
            if ($memory-dimension = 'words') then
              'WORDS'
            else if ($memory-dimension = 'characters') then
              'CHARACTERS'
            else if ($memory-dimension = 'modules') then
              'MODULES'
            else
              error(xs:QName('invalid-memory-dimension'), $memory-dimension)"/>
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

        <xsl:if test="exists($segment-limit)">
          <xsl:sequence select="$t:new-line"/>

          <xsl:sequence select="'SEGMENT-LIMIT'"/>
          <xsl:sequence select="' '"/>
          <xsl:sequence select="'IS'"/>
          <xsl:sequence select="' '"/>
          <xsl:sequence select="xs:string($segment-limit)"/>
        </xsl:if>

        <xsl:sequence select="'.'"/>

        <xsl:sequence select="$t:unindent"/>
      </xsl:if>

      <xsl:sequence select="$t:new-line"/>
    </xsl:if>

    <xsl:if test="$special-names">
      <xsl:sequence select="t:get-comments($special-names)"/>

      <xsl:sequence select="'SPECIAL-NAMES'"/>
      <xsl:sequence select="'.'"/>

      <xsl:sequence select="$t:indent"/>

      <xsl:for-each select="$special-names/environment">
        <xsl:sequence select="$t:new-line"/>

        <xsl:variable name="name" as="xs:string" select="@name"/>
        <xsl:variable name="mnemonic" as="xs:string?" select="@mnemonic"/>
        <xsl:variable name="on-status" as="element()?" select="on-status"/>
        <xsl:variable name="off-status" as="element()?" select="off-status"/>

        <xsl:sequence select="$name"/>

        <xsl:if test="$mnemonic">
          <xsl:sequence select="' '"/>
          <xsl:sequence select="'IS'"/>
          <xsl:sequence select="' '"/>
          <xsl:sequence select="$mnemonic"/>
        </xsl:if>

        <xsl:if test="$on-status">
          <xsl:sequence select="' '"/>
          <xsl:sequence select="'ON'"/>
          <xsl:sequence select="' '"/>
          <xsl:sequence select="'STATUS'"/>
          <xsl:sequence select="' '"/>
          <xsl:sequence select="'IS'"/>
          <xsl:sequence select="' '"/>
          <xsl:sequence
            select="t:get-condition(t:get-elements($on-status))"/>

          <xsl:sequence select="' '"/>
          <xsl:sequence select="$t:soft-line-break"/>
        </xsl:if>

        <xsl:if test="$off-status">
          <xsl:sequence select="' '"/>
          <xsl:sequence select="'OFF'"/>
          <xsl:sequence select="' '"/>
          <xsl:sequence select="'STATUS'"/>
          <xsl:sequence select="' '"/>
          <xsl:sequence select="'IS'"/>
          <xsl:sequence select="' '"/>
          <xsl:sequence
            select="t:get-condition(t:get-elements($off-status))"/>
        </xsl:if>

        <xsl:sequence select="'.'"/>
      </xsl:for-each>

      <xsl:for-each select="$special-names/alphabet">
        <xsl:variable name="name" as="xs:string" select="@name"/>
        <xsl:variable name="type" as="xs:string?" select="@type"/>

        <xsl:sequence select="$t:new-line"/>

        <xsl:sequence select="'ALPHABET'"/>
        <xsl:sequence select="' '"/>
        <xsl:sequence select="$name"/>
        <xsl:sequence select="' '"/>
        <xsl:sequence select="'IS'"/>
        <xsl:sequence select="' '"/>

        <xsl:choose>
          <xsl:when test="empty($type) or ($type = 'literals')">
            <xsl:variable name="literals" as="element()+"
              select="t:get-elements(.)"/>

            <xsl:for-each select="$literals">
              <xsl:variable name="index" as="xs:integer" select="position()"/>
              
              <xsl:if test="$index gt 1">
                <xsl:sequence select="' '"/>

                <xsl:if test="not($literals[$index - 1]/self::literal-range)">
                  <xsl:sequence select="'ALSO'"/>
                  <xsl:sequence select="' '"/>
                </xsl:if>

                <xsl:sequence select="$t:soft-line-break"/>
              </xsl:if>

              <xsl:choose>
                <xsl:when test="self::literal-range">
                  <xsl:variable name="nested-literals" as="element()+"
                    select="t:get-elements(.)"/>

                  <xsl:sequence select="t:get-literal($nested-literals[1])"/>

                  <xsl:sequence select="' '"/>
                  <xsl:sequence select="'THROUGH'"/>
                  <xsl:sequence select="' '"/>

                  <xsl:sequence select="t:get-literal($nested-literals[2])"/>
                </xsl:when>
                <xsl:otherwise>
                  <xsl:sequence select="t:get-literal(.)"/>
                </xsl:otherwise>
              </xsl:choose>
            </xsl:for-each>
          </xsl:when>
          <xsl:otherwise>
            <xsl:sequence select="
              if ($type = 'standard-1') then
                'STANDARD-1'
              else if ($type = 'standard-2') then
                'STANDARD-2'
              else if ($type = 'native') then
                'NATIVE'
              else if ($type = 'ebcdic') then
                'EBCDIC'
              else
                error(xs:QName('invalid-aphabet-type'), $type)"/>
          </xsl:otherwise>
        </xsl:choose>

        <xsl:sequence select="'.'"/>
      </xsl:for-each>

      <xsl:for-each select="$special-names/symbolic-characters">
        <xsl:variable name="alphabet" as="xs:string?" select="@alphabet"/>

        <xsl:sequence select="$t:new-line"/>

        <xsl:sequence select="'SYMBOLIC'"/>
        <xsl:sequence select="' '"/>
        <xsl:sequence select="'CHARACTERS'"/>

        <xsl:for-each select="character">
          <xsl:variable name="name" as="xs:string" select="@name"/>

          <xsl:sequence select="' '"/>
          <xsl:sequence select="$name"/>
        </xsl:for-each>

        <xsl:sequence select="' '"/>

        <xsl:sequence select="
          if (count(character) > 1) then
            'ARE'
          else
            'IS'"/>

        <xsl:for-each select="character">
          <xsl:variable name="integer" as="element()" select="integer"/>

          <xsl:sequence select="' '"/>
          <xsl:sequence select="t:get-integer($integer)"/>
        </xsl:for-each>

        <xsl:if test="$alphabet">
          <xsl:sequence select="' '"/>
          <xsl:sequence select="'IN'"/>
          <xsl:sequence select="' '"/>
          <xsl:sequence select="$alphabet"/>
        </xsl:if>

        <xsl:sequence select="'.'"/>
      </xsl:for-each>

      <xsl:for-each select="$special-names/class">
        <xsl:variable name="name" as="xs:string" select="@name"/>

        <xsl:sequence select="$t:new-line"/>

        <xsl:sequence select="'CLASS'"/>
        <xsl:sequence select="' '"/>
        <xsl:sequence select="$name"/>

        <xsl:variable name="literals" as="element()+"
          select="t:get-elements(.)"/>

        <xsl:for-each select="$literals">
          <xsl:sequence select="' '"/>

          <xsl:choose>
            <xsl:when test="self::literal-range">
              <xsl:variable name="nested-literals" as="element()+"
                select="t:get-elements($literals)"/>

              <xsl:sequence select="t:get-literal($nested-literals[1])"/>

              <xsl:sequence select="' '"/>
              <xsl:sequence select="'THROUGH'"/>
              <xsl:sequence select="' '"/>

              <xsl:sequence select="t:get-literal($nested-literals[2])"/>
            </xsl:when>
            <xsl:otherwise>
              <xsl:sequence select="t:get-literal(.)"/>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:for-each>

        <xsl:sequence select="'.'"/>
      </xsl:for-each>

      <xsl:variable name="currency-sign" as="element()?"
        select="$special-names/currency-sign"/>

      <xsl:if test="$currency-sign">
        <xsl:sequence select="$t:new-line"/>

        <xsl:sequence select="'CURRENCY'"/>
        <xsl:sequence select="' '"/>
        <xsl:sequence select="'SIGN'"/>
        <xsl:sequence select="' '"/>
        <xsl:sequence select="'IS'"/>
        <xsl:sequence select="' '"/>
        <xsl:sequence select="t:get-literal(t:get-elements($currency-sign))"/>
        <xsl:sequence select="'.'"/>
      </xsl:if>

      <xsl:variable name="decimal-point" as="element()?"
        select="$special-names/decimal-point"/>

      <xsl:if test="$decimal-point">
        <xsl:variable name="comma" as="element()"
          select="$decimal-point/comma"/>

        <xsl:sequence select="$t:new-line"/>

        <xsl:sequence select="'DECIMAL-POINT'"/>
        <xsl:sequence select="' '"/>
        <xsl:sequence select="'IS'"/>
        <xsl:sequence select="' '"/>

        <!-- $comma/'COMMA' is to assert element existance. -->
        <xsl:sequence select="$comma/'COMMA'"/>

        <xsl:sequence select="'.'"/>
      </xsl:if>

      <xsl:sequence select="$t:unindent"/>
      <xsl:sequence select="$t:new-line"/>
    </xsl:if>
  </xsl:function>

  <!--
    Gets a sequence of tokens for a input-output-section.
      $input-output-section - a data division.
      Returns a sequence of tokens.
  -->
  <xsl:function name="t:get-input-output-section" as="item()*">
    <xsl:param name="input-output-section" as="element()"/>

    <xsl:variable name="file-control" as="element()*"
      select="$input-output-section/file-control"/>
    <xsl:variable name="io-control" as="element()*"
      select="$input-output-section/io-control"/>

    <xsl:sequence select="t:get-comments($input-output-section)"/>

    <xsl:sequence select="'INPUT-OUTPUT'"/>
    <xsl:sequence select="' '"/>
    <xsl:sequence select="'SECTION'"/>
    <xsl:sequence select="'.'"/>
    <xsl:sequence select="$t:new-line"/>

    <xsl:if test="$file-control">
      <xsl:sequence select="'FILE-CONTROL'"/>
      <xsl:sequence select="'.'"/>
      <xsl:sequence select="$t:new-line"/>

      <xsl:sequence select="$t:indent"/>

      <xsl:sequence select="$file-control/t:get-file-control(.)"/>

      <xsl:sequence select="$t:unindent"/>
    </xsl:if>

    <xsl:if test="$io-control">
      <xsl:sequence select="'IO-CONTROL'"/>
      <xsl:sequence select="'.'"/>
      <xsl:sequence select="$t:new-line"/>

      <xsl:sequence select="$t:indent"/>

      <xsl:sequence select="$io-control/t:get-io-control(.)"/>

      <xsl:sequence select="$t:unindent"/>
    </xsl:if>
  </xsl:function>

  <!--
    Gets a sequence of tokens for a file-control.
      $file-control - a file-control element.
      Returns a sequence of tokens.
  -->
  <xsl:function name="t:get-file-control" as="item()*">
    <xsl:param name="file-control" as="element()"/>

    <xsl:variable name="select" as="element()"
      select="$file-control/select"/>
    <xsl:variable name="assign" as="element()+"
      select="$file-control/assign"/>
    <xsl:variable name="select-optional" as="xs:boolean?"
      select="$select/@optional"/>
    <xsl:variable name="reserve-area" as="element()?"
      select="$file-control/reserve-area"/>
    <xsl:variable name="organization" as="xs:string?"
      select="$file-control/@sequential-organization"/>
    <xsl:variable name="padding-character" as="element()?"
      select="$file-control/padding-character"/>
    <xsl:variable name="record-delimiter-type" as="xs:string?"
      select="$file-control/@record-delimiter-type"/>
    <xsl:variable name="record-delimiter" as="xs:string?"
      select="$file-control/@record-delimiter"/>
    <xsl:variable name="access-mode" as="xs:string?"
      select="$file-control/@access-mode"/>
    <xsl:variable name="relative-key" as="element()?"
      select="$file-control/relative-key"/>
    <xsl:variable name="record-key" as="element()*"
      select="$file-control/record-key"/>
    <xsl:variable name="password" as="element()?"
      select="$file-control/password"/>
    <xsl:variable name="file-status" as="element()?"
      select="$file-control/file-status"/>

    <xsl:sequence select="t:get-comments($file-control)"/>

    <xsl:sequence select="'SELECT'"/>

    <xsl:if test="$select-optional">
      <xsl:sequence select="' '"/>
      <xsl:sequence select="'OPTIONAL'"/>
    </xsl:if>

    <xsl:sequence select="' '"/>
    <xsl:sequence select="t:get-file-ref(t:get-elements($select))"/>

    <xsl:sequence select="$t:indent"/>

    <xsl:for-each select="$assign">
      <xsl:variable name="assignment" as="xs:string" select="@assignment"/>

      <xsl:sequence select="$t:new-line"/>
      <xsl:sequence select="'ASSIGN'"/>
      <xsl:sequence select="' '"/>
      <xsl:sequence select="'TO'"/>
      <xsl:sequence select="' '"/>

      <xsl:choose>
        <xsl:when test="$assignment">
          <xsl:sequence select="$assignment"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:sequence select="t:get-literal(t:get-elements(.))"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:for-each>

    <xsl:if test="$reserve-area">
      <xsl:variable name="integer" as="element()"
        select="$reserve-area/integer"/>

      <xsl:sequence select="$t:new-line"/>
      <xsl:sequence select="'RESERVE'"/>
      <xsl:sequence select="' '"/>
      <xsl:sequence select="t:get-integer($integer)"/>
      <xsl:sequence select="' '"/>

      <xsl:sequence select="
        if (xs:integer($integer/@value) = 1) then
          'AREA'
        else
          'AREAS'"/>
    </xsl:if>

    <xsl:if test="$organization">
      <xsl:sequence select="$t:new-line"/>
      <xsl:sequence select="'ORGANIZATION'"/>
      <xsl:sequence select="' '"/>
      <xsl:sequence select="'IS'"/>
      <xsl:sequence select="' '"/>

      <xsl:sequence select="
        if ($organization = 'sequential') then
          'SEQUENTIAL'
        else if ($organization = 'relative') then
          'RELATIVE'
        else if ($organization = 'indexed') then
          'INDEXED'
        else
          error(xs:QName('invalid-file-organization'), $organization)"/>
    </xsl:if>

    <xsl:if test="$padding-character">
      <xsl:sequence select="$t:new-line"/>
      <xsl:sequence select="'PADDING'"/>
      <xsl:sequence select="' '"/>
      <xsl:sequence select="'CHARACTER'"/>
      <xsl:sequence select="' '"/>
      <xsl:sequence select="'IS'"/>
      <xsl:sequence select="' '"/>

      <xsl:sequence select="
        t:get-qualified-data-name-or-literal
        (
          t:get-elements($padding-character)
        )"/>
    </xsl:if>

    <xsl:if test="exists($record-delimiter-type) or $record-delimiter">
      <xsl:sequence select="$t:new-line"/>
      <xsl:sequence select="'RECORD'"/>
      <xsl:sequence select="' '"/>
      <xsl:sequence select="'DELIMITER'"/>
      <xsl:sequence select="' '"/>
      <xsl:sequence select="'IS'"/>
      <xsl:sequence select="' '"/>

      <xsl:sequence select="
        if
        (
          not($record-delimiter) and
          ($record-delimiter-type = 'standard-1')
        )
        then
          'STANDARD-1'
        else if
        (
          $record-delimiter and
          (
            empty($record-delimiter-type) or
            ($record-delimiter-type = 'assignment')
          )
        )
        then
          $record-delimiter
        else
          error(xs:QName('invalid-record-delimiter'), $record-delimiter)"/>
    </xsl:if>

    <xsl:if test="exists($access-mode)">
      <xsl:sequence select="$t:new-line"/>
      <xsl:sequence select="'ACCESS'"/>
      <xsl:sequence select="' '"/>
      <xsl:sequence select="'MODE'"/>
      <xsl:sequence select="' '"/>
      <xsl:sequence select="'IS'"/>
      <xsl:sequence select="' '"/>

      <xsl:sequence select="
        if ($access-mode = 'sequential') then
          'SEQUENTIAL'
        else if ($access-mode = 'random') then
          'RANDOM'
        else if ($access-mode = 'dynamic') then
          'DYNAMIC'
        else
          error(xs:QName('invalid-access-mode'), $access-mode)"/>

      <xsl:if test="$relative-key">
        <xsl:sequence select="' '"/>
        <xsl:sequence select="
          t:get-qualified-data-name(t:get-elements($relative-key))"/>
      </xsl:if>
    </xsl:if>

    <xsl:for-each select="$record-key">
      <xsl:variable name="record-password" as="element()?" select="password"/>
      <xsl:variable name="duplicates" as="xs:boolean?"
        select="@duplicates"/>

      <xsl:sequence select="$t:new-line"/>

      <xsl:if test="position() > 1">
        <xsl:sequence select="'ALTERNATE'"/>
        <xsl:sequence select="' '"/>
      </xsl:if>

      <xsl:sequence select="'RECORD'"/>
      <xsl:sequence select="' '"/>
      <xsl:sequence select="'KEY'"/>
      <xsl:sequence select="' '"/>
      <xsl:sequence select="'IS'"/>
      <xsl:sequence select="' '"/>

      <xsl:sequence select="
        t:get-qualified-data-name(t:get-elements($relative-key))"/>

      <xsl:if test="$record-password">
        <xsl:sequence select="' '"/>
        <xsl:sequence select="'PASSWORD'"/>
        <xsl:sequence select="' '"/>
        <xsl:sequence select="'IS'"/>
        <xsl:sequence select="' '"/>
        <xsl:sequence
          select="t:get-data-ref(t:get-elements($record-password))"/>
      </xsl:if>

      <xsl:if test="$duplicates">
        <xsl:if test="position() = 1">
          <xsl:sequence
            select="error(xs:QName('no-dublicates-on-first-record-key'))"/>
        </xsl:if>

        <xsl:sequence select="' '"/>
        <xsl:sequence select="'WITH'"/>
        <xsl:sequence select="' '"/>
        <xsl:sequence select="'DUPLICATES'"/>
      </xsl:if>
    </xsl:for-each>

    <xsl:if test="$password">
      <xsl:if test="$record-key">
        <xsl:sequence select="
          error(xs:QName('record-key-and-password-data-mutually-exclusive'))"/>
      </xsl:if>

      <xsl:sequence select="$t:new-line"/>

      <xsl:sequence select="'PASSWORD'"/>
      <xsl:sequence select="' '"/>
      <xsl:sequence select="'IS'"/>
      <xsl:sequence select="' '"/>
      <xsl:sequence select="t:get-data-ref(t:get-elements($password))"/>
    </xsl:if>

    <xsl:if test="$file-status">
      <xsl:variable name="names" as="element()+"
        select="t:get-elements($file-status)"/>
      <xsl:variable name="first-name" as="element()"
        select="$names[1]"/>
      <xsl:variable name="second-name" as="element()?"
        select="subsequence($names, 2)"/>

      <xsl:sequence select="$t:new-line"/>

      <xsl:sequence select="'FILE'"/>
      <xsl:sequence select="' '"/>
      <xsl:sequence select="'STATUS'"/>
      <xsl:sequence select="' '"/>

      <xsl:sequence select="t:get-qualified-data-name($first-name)"/>

      <xsl:if test="$second-name">
        <xsl:sequence select="t:get-qualified-data-name($second-name)"/>
      </xsl:if>
    </xsl:if>

    <xsl:sequence select="'.'"/>
    <xsl:sequence select="$t:new-line"/>

    <xsl:sequence select="$t:unindent"/>
  </xsl:function>

  <!--
    Gets a sequence of tokens for a io-control.
      $io-control - a io-control element.
      Returns a sequence of tokens.
  -->
  <xsl:function name="t:get-io-control" as="item()*">
    <xsl:param name="io-control" as="element()"/>

    <xsl:variable name="rerun-on" as="element()?"
      select="$io-control/rerun-on"/>
    <xsl:variable name="same" as="element()?"
      select="$io-control/same"/>
    <xsl:variable name="multiple-file-contains" as="element()?"
      select="$io-control/multiple-file-contains"/>
    <xsl:variable name="apply-write-only" as="element()?"
      select="$io-control/apply-write-only"/>

    <xsl:sequence select="t:get-comments($io-control)"/>

    <xsl:if test="$rerun-on">
      <xsl:variable name="assignment" as="xs:string?"
        select="$rerun-on/@assignment"/>
      <xsl:variable name="file-ref" as="element()?"
        select="$rerun-on/file-ref"/>
      <xsl:variable name="every" as="element()?"
        select="$rerun-on/every"/>

      <xsl:sequence select="'RERUN'"/>
      <xsl:sequence select="' '"/>
      <xsl:sequence select="'ON'"/>
      <xsl:sequence select="' '"/>

      <xsl:sequence select="
        if ($assignment) then
          $assignment
        else if ($file-ref) then
          t:get-file-ref($file-ref)
        else
          error(xs:QName('assignment-or-file-expected'), $rerun-on)"/>

      <xsl:sequence select="' '"/>

      <xsl:if test="$every">
        <xsl:variable name="records" as="element()?" select="$every/records"/>

        <xsl:sequence select="'EVERY'"/>
        <xsl:sequence select="' '"/>

        <xsl:choose>
          <xsl:when test="$records">
            <xsl:sequence
              select="t:get-integer(t:get-elements($records))"/>
            <xsl:sequence select="' '"/>
            <xsl:sequence select="'RECORDS'"/>
          </xsl:when>
          <xsl:when test="exists($every/end-of-reel)">
            <xsl:sequence select="'END'"/>
            <xsl:sequence select="' '"/>
            <xsl:sequence select="'OF'"/>
            <xsl:sequence select="' '"/>
            <xsl:sequence select="'REEL'"/>
          </xsl:when>
          <xsl:when test="exists($every/end-of-unit)">
            <xsl:sequence select="'END'"/>
            <xsl:sequence select="' '"/>
            <xsl:sequence select="'OF'"/>
            <xsl:sequence select="' '"/>
            <xsl:sequence select="'UNIT'"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:sequence select="error(xs:QName('rerun'), $rerun-on)"/>
          </xsl:otherwise>
        </xsl:choose>

        <xsl:sequence select="' '"/>
        <xsl:sequence select="'OF'"/>
        <xsl:sequence select="' '"/>
        <xsl:sequence select="t:get-file-ref($every/file-ref)"/>
        <xsl:sequence select="' '"/>
      </xsl:if>
    </xsl:if>

    <xsl:if test="$same">
      <xsl:variable name="type" as="xs:string" select="$same/@type"/>
      <xsl:variable name="file-refs" as="element()+" select="$same/file-ref"/>

      <xsl:sequence select="'SAME'"/>
      <xsl:sequence select="' '"/>

      <xsl:sequence select="
        if ($type = 'record') then
          'RECORD'
        else if ($type = 'sort') then
          'SORT'
        else if ($type = 'sort-merge') then
          'SORT-MERGE'
        else
          error(xs:QName('invalid-same-type'), $same)"/>

      <xsl:sequence select="' '"/>
      <xsl:sequence select="'AREA'"/>
      <xsl:sequence select="' '"/>
      <xsl:sequence select="'FOR'"/>

      <xsl:for-each select="$file-refs">
        <xsl:sequence select="' '"/>
        <xsl:sequence select="t:get-file-ref(.)"/>
      </xsl:for-each>

      <xsl:sequence select="' '"/>
    </xsl:if>

    <xsl:if test="$multiple-file-contains">
      <xsl:variable name="file-ref" as="element()" 
        select="$multiple-file-contains/position"/>
      <xsl:variable name="position" as="element()?" 
        select="$multiple-file-contains/position"/>

      <xsl:sequence select="'MULTIPLE'"/>
      <xsl:sequence select="' '"/>
      <xsl:sequence select="'FILE'"/>
      <xsl:sequence select="' '"/>
      <xsl:sequence select="'TAPE'"/>
      <xsl:sequence select="' '"/>
      <xsl:sequence select="'CONTAINS'"/>
      <xsl:sequence select="' '"/>

      <xsl:sequence select="t:get-file-ref($file-ref)"/>

      <xsl:if test="$position">
        <xsl:sequence select="' '"/>
        <xsl:sequence select="'POSITION'"/>
        <xsl:sequence select="' '"/>
        <xsl:sequence select="t:get-integer(t:get-elements($position))"/>
      </xsl:if>

      <xsl:sequence select="' '"/>
    </xsl:if>

    <xsl:if test="$apply-write-only">
      <xsl:variable name="file-ref" as="element()+"
        select="$apply-write-only/file-ref"/>

      <xsl:sequence select="'APPLY'"/>
      <xsl:sequence select="' '"/>
      <xsl:sequence select="'WRITE-ONLY'"/>
      <xsl:sequence select="' '"/>
      <xsl:sequence select="'ON'"/>
      <xsl:sequence select="' '"/>
      <xsl:sequence select="t:get-file-ref($file-ref)"/>
    </xsl:if>

    <xsl:sequence select="$t:new-line"/>
  </xsl:function>

  <!--
    Gets a sequence of tokens for a data-division.
      $data-division - a data division.
      Returns a sequence of tokens.
  -->
  <xsl:function name="t:get-data-division" as="item()*">
    <xsl:param name="data-division" as="element()"/>

    <xsl:variable name="file-section" as="element()?"
      select="$data-division/file-section"/>
    <xsl:variable name="working-storage-section" as="element()?"
      select="$data-division/working-storage-section"/>
    <xsl:variable name="local-storage-section" as="element()?"
      select="$data-division/local-storage-section"/>
    <xsl:variable name="linkage-section" as="element()?"
      select="$data-division/linkage-section"/>

    <xsl:sequence select="t:get-comments($data-division)"/>

    <xsl:sequence select="$t:new-line"/>
    <xsl:sequence select="'DATA'"/>
    <xsl:sequence select="' '"/>
    <xsl:sequence select="'DIVISION'"/>
    <xsl:sequence select="'.'"/>
    <xsl:sequence select="$t:new-line"/>

    <xsl:sequence select="$file-section/t:get-file-section(.)"/>
    <xsl:sequence
      select="$working-storage-section/t:get-working-storage-section(.)"/>
    <xsl:sequence
      select="$local-storage-section/t:get-local-storage-section(.)"/>
    <xsl:sequence select="$linkage-section/t:get-linkage-section(.)"/>
  </xsl:function>

  <!--
    Gets a sequence of tokens for a file-section.
      $file-section - a file section.
      Returns a sequence of tokens.
  -->
  <xsl:function name="t:get-file-section" as="item()*">
    <xsl:param name="file-section" as="element()"/>

    <xsl:sequence select="t:get-comments($file-section)"/>

    <xsl:sequence select="'FILE'"/>
    <xsl:sequence select="' '"/>
    <xsl:sequence select="'SECTION'"/>
    <xsl:sequence select="'.'"/>
    <xsl:sequence select="$t:new-line"/>

    <xsl:for-each select="$file-section/entry">
      <xsl:variable name="elements" as="element()+"
        select="t:get-elements(.)"/>

      <xsl:apply-templates
        mode="t:file-and-sort-description-entry"
        select="elements"/>

      <xsl:sequence select="t:get-data-content($elements)"/>
    </xsl:for-each>

    <xsl:sequence select="$t:new-line"/>
  </xsl:function>

  <!--
    Gets a sequence of tokens for a working-storage-section.
      $working-storage-section - a working storage section.
      Returns a sequence of tokens.
  -->
  <xsl:function name="t:get-working-storage-section" as="item()*">
    <xsl:param name="working-storage-section" as="element()"/>

    <xsl:sequence select="t:get-comments($working-storage-section)"/>

    <xsl:sequence select="'WORKING-STORAGE'"/>
    <xsl:sequence select="' '"/>
    <xsl:sequence select="'SECTION'"/>
    <xsl:sequence select="'.'"/>
    <xsl:sequence select="$t:new-line"/>
    <xsl:sequence
      select="t:get-data-content(t:get-elements($working-storage-section))"/>
    <xsl:sequence select="$t:new-line"/>
  </xsl:function>

  <!--
    Gets a sequence of tokens for a local-storage-section.
      $local-storage-section - a local storage section.
      Returns a sequence of tokens.
  -->
  <xsl:function name="t:get-local-storage-section" as="item()*">
    <xsl:param name="local-storage-section" as="element()"/>

    <xsl:sequence select="t:get-comments($local-storage-section)"/>

    <xsl:sequence select="'LOCAL-STORAGE'"/>
    <xsl:sequence select="' '"/>
    <xsl:sequence select="'SECTION'"/>
    <xsl:sequence select="'.'"/>
    <xsl:sequence select="$t:new-line"/>
    <xsl:sequence
      select="t:get-data-content(t:get-elements($local-storage-section))"/>
    <xsl:sequence select="$t:new-line"/>
  </xsl:function>

  <!--
    Gets a sequence of tokens for a linkage-section.
      $linkage-section - a linkage section.
      Returns a sequence of tokens.
  -->
  <xsl:function name="t:get-linkage-section" as="item()*">
    <xsl:param name="linkage-section" as="element()"/>

    <xsl:sequence select="t:get-comments($linkage-section)"/>

    <xsl:sequence select="'LINKAGE'"/>
    <xsl:sequence select="' '"/>
    <xsl:sequence select="'SECTION'"/>
    <xsl:sequence select="'.'"/>
    <xsl:sequence select="$t:new-line"/>
    <xsl:sequence
      select="t:get-data-content(t:get-elements($linkage-section))"/>
    <xsl:sequence select="$t:new-line"/>
  </xsl:function>

  <!--
    Gets a sequence of tokens for a data content.
      $element - a data content.
      Returns a sequence of tokens.
  -->
  <xsl:function name="t:get-data-content" as="item()*">
    <xsl:param name="elements" as="element()*"/>

    <xsl:apply-templates mode="t:data-content" select="$elements">
      <xsl:with-param name="parent-data-level" tunnel="yes" select="()"/>
    </xsl:apply-templates>
  </xsl:function>

  <!--
    Gets a sequence of tokens for a program.
      $program - a program.
      Returns a sequence of tokens.
  -->
  <xsl:template match="program" mode="
    t:program
    t:element">
    <xsl:sequence select="t:get-program(.)"/>
  </xsl:template>

  <!--
    file-description, sort-description file-and-sort-description-entry.
  -->
  <xsl:template match="file-description | sort-description" mode="
    t:file-and-sort-description-entry
    t:element">

    <xsl:variable name="name" as="xs:string" select="@name"/>
    <xsl:variable name="external" as="xs:boolean?" select="@external"/>
    <xsl:variable name="global" as="xs:boolean?" select="@global"/>
    <xsl:variable name="data-records" as="element()?" select="data-records"/>
    <xsl:variable name="mode" as="xs:string?"
      select="@mode"/>
    <xsl:variable name="code-set" as="xs:string?" select="@code-set"/>
    <xsl:variable name="block-contains" as="element()?"
      select="block-contains"/>
    <xsl:variable name="record-contains" as="element()?"
      select="record-contains"/>
    <xsl:variable name="record-varying" as="element()?"
      select="record-varying"/>
    <xsl:variable name="label-record" as="element()?" select="label-record"/>
    <xsl:variable name="value-of" as="element()*" select="value-of"/>
    <xsl:variable name="linage" as="element()?" select="linage"/>
    <xsl:variable name="record-description" as="element()"
      select="record-description"/>

    <xsl:sequence select="t:get-comments(.)"/>

    <xsl:sequence select="
      if (self::file-description) then
        'FD'
      else
        'SD'"/>

    <xsl:sequence select="' '"/>
    <xsl:sequence select="$name"/>

    <xsl:sequence select="$t:indent"/>

    <xsl:if test="$external">
      <xsl:sequence select="' '"/>
      <xsl:sequence select="'IS'"/>
      <xsl:sequence select="' '"/>
      <xsl:sequence select="'EXTERNAL'"/>
    </xsl:if>

    <xsl:if test="$global">
      <xsl:sequence select="' '"/>
      <xsl:sequence select="'IS'"/>
      <xsl:sequence select="' '"/>
      <xsl:sequence select="'GLOBAL'"/>
    </xsl:if>

    <xsl:if test="$block-contains">
      <xsl:variable name="values" as="element()+"
        select="t:get-elements($block-contains)"/>
      <xsl:variable name="item-type" as="xs:string?"
        select="$block-contains/@item-type"/>

      <xsl:sequence select="$t:new-line"/>
      <xsl:sequence select="'BLOCK'"/>
      <xsl:sequence select="' '"/>
      <xsl:sequence select="'CONTAINS'"/>
      <xsl:sequence select="' '"/>
      <xsl:sequence select="t:get-integer($values[1])"/>

      <xsl:if test="$values[2]">
        <xsl:sequence select="' '"/>
        <xsl:sequence select="'TO'"/>
        <xsl:sequence select="' '"/>
        <xsl:sequence select="t:get-integer($values[2])"/>
      </xsl:if>

      <xsl:if test="exists($item-type)">
        <xsl:sequence select="' '"/>

        <xsl:sequence select="
          if ($item-type = 'character') then
            'CHARACTERS'
          else if ($item-type = 'record') then
            'RECORDS'
          else
            error(xs:QName('invalid-item-type'), $item-type)"/>
      </xsl:if>
    </xsl:if>

    <xsl:if test="$record-contains">
      <xsl:variable name="values" as="element()+"
        select="t:get-elements($record-contains)"/>

      <xsl:sequence select="$t:new-line"/>
      <xsl:sequence select="'RECORD'"/>
      <xsl:sequence select="' '"/>
      <xsl:sequence select="'CONTAINS'"/>
      <xsl:sequence select="' '"/>
      <xsl:sequence select="t:get-integer($values[1])"/>

      <xsl:if test="$values[2]">
        <xsl:sequence select="' '"/>
        <xsl:sequence select="'TO'"/>
        <xsl:sequence select="' '"/>
        <xsl:sequence select="t:get-integer($values[2])"/>
      </xsl:if>

      <xsl:sequence select="' '"/>
      <xsl:sequence select="'CHARACTERS'"/>
    </xsl:if>

    <xsl:if test="$record-varying">
      <xsl:variable name="values" as="element()+"
        select="t:get-elements($record-varying)"/>
      <xsl:variable name="depending-on" as="element()?"
        select="$record-varying/depending-on"/>

      <xsl:sequence select="$t:new-line"/>
      <xsl:sequence select="'RECORD'"/>
      <xsl:sequence select="' '"/>
      <xsl:sequence select="'IS'"/>
      <xsl:sequence select="' '"/>
      <xsl:sequence select="'VARYING'"/>
      <xsl:sequence select="' '"/>
      <xsl:sequence select="'SIZE'"/>
      <xsl:sequence select="' '"/>

      <xsl:choose>
        <xsl:when test="$values[2]">
          <xsl:sequence select="'FROM'"/>
          <xsl:sequence select="' '"/>
          <xsl:sequence select="t:get-integer($values[1])"/>
          <xsl:sequence select="' '"/>
          <xsl:sequence select="'TO'"/>
          <xsl:sequence select="' '"/>
          <xsl:sequence select="t:get-integer($values[2])"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:sequence select="'TO'"/>
          <xsl:sequence select="' '"/>
          <xsl:sequence select="t:get-integer($values[1])"/>
        </xsl:otherwise>
      </xsl:choose>

      <xsl:sequence select="' '"/>
      <xsl:sequence select="'CHARACTERS'"/>

      <xsl:if test="$depending-on">
        <xsl:sequence select="' '"/>
        <xsl:sequence select="'DEPENDING'"/>
        <xsl:sequence select="' '"/>
        <xsl:sequence select="'ON'"/>
        <xsl:sequence select="' '"/>
        <xsl:sequence select="t:get-data-ref(t:get-elements($depending-on))"/>
      </xsl:if>
    </xsl:if>

    <xsl:if test="$label-record">
      <xsl:variable name="type" as="xs:string?" select="$label-record/@type"/>

      <xsl:sequence select="$t:new-line"/>

      <xsl:sequence select="'LABEL'"/>
      <xsl:sequence select="' '"/>

      <xsl:choose>
        <xsl:when test="empty($type) or ($type = 'data-ref')">
          <xsl:variable name="data-refs" as="element()+"
            select="$label-record/data-ref"/>

          <xsl:sequence select="
            if (count($data-refs) = 1) then
              ('RECORD', ' ', 'IS')
            else
              ('RECORDS', ' ', 'ARE')"/>

          <xsl:for-each select="$data-refs">
            <xsl:sequence select="' '"/>
            <xsl:sequence select="t:get-data-ref(.)"/>
          </xsl:for-each>
        </xsl:when>
        <xsl:otherwise>
          <xsl:sequence select="'RECORDS'"/>
          <xsl:sequence select="' '"/>
          <xsl:sequence select="'ARE'"/>
          <xsl:sequence select="' '"/>

          <xsl:sequence select="
            if ($type = 'standard') then
              'STANDARD'
            else if ($type = 'omitted') then
              'OMITTED'
            else
              error(xs:QName('invalid-label-record'), $type)"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:if>

    <xsl:if test="$value-of">
      <xsl:sequence select="$t:new-line"/>

      <xsl:sequence select="'VALUE'"/>
      <xsl:sequence select="' '"/>
      <xsl:sequence select="'OF'"/>

      <xsl:sequence select="$t:new-line"/>
      <xsl:sequence select="$t:indent"/>

      <xsl:for-each select="$value-of">
        <xsl:variable name="value-name" as="xs:string" select="@name"/>

        <xsl:sequence select="$value-name"/>
        <xsl:sequence select="' '"/>
        <xsl:sequence select="'IS'"/>
        <xsl:sequence select="' '"/>
        <xsl:sequence
          select="t:get-qualified-data-name-or-literal(t:get-elements(.))"/>
        <xsl:sequence select="$t:new-line"/>
      </xsl:for-each>

      <xsl:sequence select="$t:unindent"/>
    </xsl:if>

    <xsl:if test="$data-records">
      <xsl:sequence select="$t:new-line"/>

      <xsl:sequence select="'DATA'"/>
      <xsl:sequence select="' '"/>

      <xsl:sequence select="
        if (count($data-records) = 1) then
          ('RECORD', ' ', 'IS')
        else
          ('RECORDS', ' ', 'ARE')"/>

      <xsl:for-each select="$data-records">
        <xsl:sequence select="' '"/>
        <xsl:sequence select="t:get-data-ref(.)"/>
      </xsl:for-each>
    </xsl:if>

    <xsl:if test="$linage">
      <xsl:variable name="value" as="element()" select="$linage/value"/>
      <xsl:variable name="footing" as="element()?" select="$linage/footing"/>
      <xsl:variable name="top" as="element()?" select="$linage/top"/>
      <xsl:variable name="bottom" as="element()?" select="$linage/bottom"/>

      <xsl:sequence select="$t:new-line"/>

      <xsl:sequence select="'LINAGE'"/>
      <xsl:sequence select="' '"/>
      <xsl:sequence select="'IS'"/>
      <xsl:sequence select="' '"/>
      <xsl:sequence select="
        t:get-qualified-data-name-or-integer(t:get-elements($value))"/>
      <xsl:sequence select="' '"/>
      <xsl:sequence select="'LINES'"/>

      <xsl:if test="$footing">
        <xsl:sequence select="' '"/>
        <xsl:sequence select="'WITH'"/>
        <xsl:sequence select="' '"/>
        <xsl:sequence select="'FOOTING'"/>
        <xsl:sequence select="' '"/>
        <xsl:sequence select="'AT'"/>
        <xsl:sequence select="' '"/>
        <xsl:sequence select="
          t:get-qualified-data-name-or-integer(t:get-elements($footing))"/>
      </xsl:if>

      <xsl:if test="$top">
        <xsl:sequence select="' '"/>
        <xsl:sequence select="'LINES'"/>
        <xsl:sequence select="' '"/>
        <xsl:sequence select="'AT'"/>
        <xsl:sequence select="' '"/>
        <xsl:sequence select="'TOP'"/>
        <xsl:sequence select="' '"/>
        <xsl:sequence select="
          t:get-qualified-data-name-or-integer(t:get-elements($top))"/>
      </xsl:if>

      <xsl:if test="$bottom">
        <xsl:sequence select="' '"/>
        <xsl:sequence select="'LINES'"/>
        <xsl:sequence select="' '"/>
        <xsl:sequence select="'AT'"/>
        <xsl:sequence select="' '"/>
        <xsl:sequence select="'BOTTOM'"/>
        <xsl:sequence select="' '"/>
        <xsl:sequence select="
          t:get-qualified-data-name-or-integer(t:get-elements($bottom))"/>
      </xsl:if>
    </xsl:if>

    <xsl:if test="exists($mode)">
      <xsl:sequence select="$t:new-line"/>

      <xsl:sequence select="'RECORDING'"/>
      <xsl:sequence select="' '"/>
      <xsl:sequence select="'MODE'"/>
      <xsl:sequence select="' '"/>
      <xsl:sequence select="'IS'"/>
      <xsl:sequence select="' '"/>

      <xsl:sequence select="
        if ($mode = ('F', 'V', 'U', 'S')) then
          $mode
        else
          error(xs:QName('invalid-mode'), $mode)"/>
    </xsl:if>

    <xsl:if test="$code-set">
      <xsl:sequence select="$t:new-line"/>

      <xsl:sequence select="'CODE-SET'"/>
      <xsl:sequence select="' '"/>
      <xsl:sequence select="'IS'"/>
      <xsl:sequence select="' '"/>
      <xsl:sequence select="$code-set"/>
    </xsl:if>

    <xsl:sequence select="'.'"/>
    <xsl:sequence select="$t:new-line"/>

    <xsl:sequence select="$t:unindent"/>
  </xsl:template>

  <!--
    data-scope data-content.
      $parent-data-level - optional parent data level (tunneling).
  -->
  <xsl:template match="data-scope" mode="
    t:data-content
    t:element">
    <xsl:param name="parent-data-level" as="xs:integer?" tunnel="yes"/>

    <xsl:variable name="level" as="xs:integer?" select="@level"/>
    <xsl:variable name="level-increment" as="xs:integer?"
      select="@level-increment"/>

    <xsl:variable name="data-level" as="xs:integer?" select="
      if (exists($level)) then
        $level
      else if (exists($parent-data-level) and exists($level-increment)) then
        $parent-data-level + $level-increment
      else
        $parent-data-level"/>

    <xsl:if test="$level-increment lt 1">
      <xsl:sequence select="error(xs:QName('invalid-data-level-increment'))"/>
    </xsl:if>

    <xsl:if test="(1 > $data-level) or ($data-level > 49)">
      <xsl:sequence select="error(xs:QName('invalid-data-level'))"/>
    </xsl:if>

    <xsl:sequence select="t:get-comments(.)"/>

    <xsl:apply-templates mode="t:data-content">
      <xsl:with-param name="parent-data-level" tunnel="yes"
        select="$data-level"/>
    </xsl:apply-templates>
  </xsl:template>

  <!--
    exec-sql-declare-section data-content.
  -->
  <xsl:template match="exec-sql-declare-section" mode="
    t:data-content
    t:element">

    <xsl:sequence select="t:get-comments(.)"/>

    <xsl:sequence select="$t:new-line"/>
    <xsl:sequence select="$t:indent"/>
    <xsl:sequence select="$t:indent"/>
    <xsl:sequence select="'EXEC'"/>
    <xsl:sequence select="' '"/>
    <xsl:sequence select="'SQL'"/>
    <xsl:sequence select="' '"/>
    <xsl:sequence select="'BEGIN'"/>
    <xsl:sequence select="' '"/>
    <xsl:sequence select="'DECLARE'"/>
    <xsl:sequence select="' '"/>
    <xsl:sequence select="'SECTION'"/>
    <xsl:sequence select="' '"/>
    <xsl:sequence select="'END-EXEC'"/>
    <xsl:sequence select="'.'"/>
    <xsl:sequence select="$t:new-line"/>
    <xsl:sequence select="$t:unindent"/>
    <xsl:sequence select="$t:unindent"/>
    <xsl:sequence select="$t:new-line"/>

    <xsl:apply-templates mode="t:data-content"/>

    <xsl:sequence select="$t:new-line"/>
    <xsl:sequence select="$t:indent"/>
    <xsl:sequence select="$t:indent"/>
    <xsl:sequence select="'EXEC'"/>
    <xsl:sequence select="' '"/>
    <xsl:sequence select="'SQL'"/>
    <xsl:sequence select="' '"/>
    <xsl:sequence select="'END'"/>
    <xsl:sequence select="' '"/>
    <xsl:sequence select="'DECLARE'"/>
    <xsl:sequence select="' '"/>
    <xsl:sequence select="'SECTION'"/>
    <xsl:sequence select="' '"/>
    <xsl:sequence select="'END-EXEC'"/>
    <xsl:sequence select="'.'"/>
    <xsl:sequence select="$t:new-line"/>
    <xsl:sequence select="$t:unindent"/>
    <xsl:sequence select="$t:unindent"/>
    <xsl:sequence select="$t:new-line"/>
  </xsl:template>

  <!--
    snippet-data-scope data-content.
  -->
  <xsl:template match="snippet-data-scope" mode="
    t:data-content
    t:element">

    <xsl:sequence select="t:get-comments(.)"/>

    <xsl:sequence select="t:tokenize(@text)"/>
  </xsl:template>

  <!--
    data data-content.
      $parent-data-level - optional parent data level (tunneling).
  -->
  <xsl:template match="data | data-filler" mode="
    t:data-content
    t:element">
    <xsl:param name="parent-data-level" as="xs:integer?" tunnel="yes"/>

    <xsl:variable name="level" as="xs:integer?" select="@level"/>
    <xsl:variable name="level-increment" as="xs:integer?"
      select="@level-increment"/>
    <xsl:variable name="redefines" as="element()?" select="redefines"/>
    <xsl:variable name="blank-when-zero" as="xs:boolean?"
      select="@blank-when-zero"/>
    <xsl:variable name="external" as="xs:boolean?" select="@external"/>
    <xsl:variable name="global" as="xs:boolean?" select="@global"/>
    <xsl:variable name="justified" as="xs:string?" select="@justified"/>
    <xsl:variable name="min-occurs" as="xs:integer?" select="@min-occurs"/>
    <xsl:variable name="max-occurs" as="xs:integer?" select="@max-occurs"/>
    <xsl:variable name="sign" as="xs:string?" select="@sign"/>
    <xsl:variable name="synchronized" as="xs:string?" select="@synchronized"/>
    <xsl:variable name="usage" as="xs:string?" select="@usage"/>

    <xsl:variable name="picture" as="element()?" select="picture"/>
    <xsl:variable name="value" as="element()?" select="value"/>
    <xsl:variable name="depending-on" as="element()?" select="depending-on"/>
    <xsl:variable name="order-by" as="element()*" select="order-by"/>
    <xsl:variable name="indexed-by" as="element()?" select="indexed-by"/>

    <xsl:variable name="data-content" as="element()*" select="
      t:get-elements(.) except
        ($picture, $value, $depending-on, $order-by, $indexed-by)"/>

    <xsl:sequence select="t:get-comments(.)"/>

    <xsl:variable name="data-level" as="xs:integer" select="
      if (exists($level)) then
        $level
      else if (exists($parent-data-level)) then
        $parent-data-level + ($level-increment, 2)[1]
      else
        1"/>

    <xsl:if test="$level-increment lt 1">
      <xsl:sequence select="error(xs:QName('invalid-data-level-increment'))"/>
    </xsl:if>

    <xsl:if test="
      ((1 > $data-level) or ($data-level > 49)) and
      not(($data-level = 77) and empty($parent-data-level))">
      <xsl:sequence select="error(xs:QName('invalid-data-level'))"/>
    </xsl:if>

    <xsl:sequence select="
      if ($data-level lt 10) then
        concat('0', $data-level)
      else
        xs:string($data-level)"/>

    <xsl:sequence select="' '"/>

    <xsl:choose>
      <xsl:when test="self::data">
        <xsl:variable name="name" as="xs:string" select="@name"/>

        <xsl:if test="upper-case($name) = 'FILLER'">
          <xsl:sequence select="error(xs:QName('invalid-data-name'))"/>
        </xsl:if>

        <xsl:sequence select="$name"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:sequence select="'FILLER'"/>
      </xsl:otherwise>
    </xsl:choose>

    <xsl:if test="$picture">
      <xsl:variable name="parts" as="element()+" select="$picture/part"/>

      <xsl:variable name="picture-parts" as="xs:string+">
        <xsl:for-each select="$parts">
          <xsl:variable name="char" as="xs:string" select="@char"/>
          <xsl:variable name="occurs" as="xs:integer?" select="@occurs"/>
          <xsl:variable name="punctuation" as="xs:string?" 
            select="@punctuation"/>

          <xsl:sequence select="$char"/>

          <xsl:if test="exists($occurs)">
            <xsl:sequence select="'('"/>
            <xsl:sequence select="xs:string($occurs)"/>
            <xsl:sequence select="')'"/>
          </xsl:if>

          <xsl:sequence select="$punctuation"/>
        </xsl:for-each>
      </xsl:variable>

      <xsl:sequence select="' '"/>
      <xsl:sequence select="'PIC'"/>
      <xsl:sequence select="' '"/>
      <xsl:sequence select="string-join($picture-parts, '')"/>
    </xsl:if>

    <xsl:if test="exists($sign)">
      <xsl:sequence select="' '"/>
      <xsl:sequence select="'SIGN'"/>
      <xsl:sequence select="' '"/>
      <xsl:sequence select="'IS'"/>
      <xsl:sequence select="' '"/>

      <xsl:sequence select="
        if ($sign = 'leading') then
          'LEADING'
        else if ($sign = 'trailing') then
          'TRAILING'
        else if ($sign = 'separate-leading') then
          ('LEADING', ' ', 'SEPARATE')
        else if ($sign = 'separate-trailing') then
          ('TRAILING', ' ', 'SEPARATE')
        else
          error(xs:QName('invalid-sign'), $sign)"/>
    </xsl:if>

    <xsl:if test="exists($usage)">
      <xsl:sequence select="' '"/>
      <xsl:sequence select="'USAGE'"/>
      <xsl:sequence select="' '"/>
      <xsl:sequence select="'IS'"/>
      <xsl:sequence select="' '"/>

      <xsl:sequence select="
        if ($usage = 'binary') then
          'BINARY'
        else if ($usage = 'comp') then
          'COMP'
        else if ($usage = 'comp-1') then
          'COMP-1'
        else if ($usage = 'comp-2') then
          'COMP-2'
        else if ($usage = 'comp-3') then
          'COMP-3'
        else if ($usage = 'comp-4') then
          'COMP-4'
        else if ($usage = 'comp-5') then
          'COMP-5'
        else if ($usage = 'display') then
          'DISPLAY'
        else if ($usage = 'display-1') then
          'DISPLAY-1'
        else if ($usage = 'index') then
          'INDEX'
        else if ($usage = 'packed-decimal') then
          'PACKED-DECIMAL'
        else if ($usage = 'pointer') then
          'POINTER'
        else
          error(xs:QName('invalid-usage'), $usage)"/>
    </xsl:if>

    <xsl:if test="$blank-when-zero">
      <xsl:sequence select="$t:new-line"/>
      <xsl:sequence select="$t:indent"/>
      <xsl:sequence select="$t:indent"/>

      <xsl:sequence select="'BLANK'"/>
      <xsl:sequence select="' '"/>
      <xsl:sequence select="'WHEN'"/>
      <xsl:sequence select="' '"/>
      <xsl:sequence select="'ZERO'"/>

      <xsl:sequence select="$t:unindent"/>
      <xsl:sequence select="$t:unindent"/>
    </xsl:if>

    <xsl:if test="$external">
      <xsl:sequence select="' '"/>
      <xsl:sequence select="$t:terminator"/>

      <xsl:sequence select="$t:indent"/>
      <xsl:sequence select="$t:indent"/>

      <xsl:sequence select="'IS'"/>
      <xsl:sequence select="' '"/>
      <xsl:sequence select="'EXTERNAL'"/>

      <xsl:sequence select="$t:unindent"/>
      <xsl:sequence select="$t:unindent"/>
    </xsl:if>

    <xsl:if test="$global">
      <xsl:sequence select="' '"/>
      <xsl:sequence select="$t:terminator"/>

      <xsl:sequence select="$t:indent"/>
      <xsl:sequence select="$t:indent"/>

      <xsl:sequence select="'IS'"/>
      <xsl:sequence select="' '"/>
      <xsl:sequence select="'GLOBAL'"/>

      <xsl:sequence select="$t:unindent"/>
      <xsl:sequence select="$t:unindent"/>
    </xsl:if>

    <xsl:if test="exists($justified) and ($justified != 'left')">
      <xsl:sequence select="' '"/>
      <xsl:sequence select="$t:terminator"/>

      <xsl:sequence select="$t:indent"/>
      <xsl:sequence select="$t:indent"/>

      <xsl:sequence select="'JUSTIFIED'"/>
      <xsl:sequence select="' '"/>

      <xsl:sequence select="
        if ($justified = 'right') then
          'RIGHT'
        else
          error(xs:QName('invalid-justified'), $justified)"/>

      <xsl:sequence select="$t:unindent"/>
      <xsl:sequence select="$t:unindent"/>
    </xsl:if>

    <xsl:if test="exists($synchronized) and ($synchronized != 'default')">
      <xsl:sequence select="' '"/>
      <xsl:sequence select="$t:terminator"/>

      <xsl:sequence select="$t:indent"/>
      <xsl:sequence select="$t:indent"/>

      <xsl:sequence select="'SYNCHRONIZED'"/>
      <xsl:sequence select="' '"/>

      <xsl:sequence select="
        if ($synchronized = 'left') then
          'LEFT'
        else if ($synchronized = 'right') then
          'RIGHT'
        else
          error(xs:QName('invalid-synchronized'), $synchronized)"/>

      <xsl:sequence select="$t:unindent"/>
      <xsl:sequence select="$t:unindent"/>
    </xsl:if>

    <xsl:if test="$value">
      <xsl:sequence select="' '"/>
      <xsl:sequence select="$t:terminator"/>

      <xsl:sequence select="$t:indent"/>
      <xsl:sequence select="$t:indent"/>

      <xsl:sequence select="'VALUE'"/>
      <xsl:sequence select="' '"/>
      <xsl:sequence select="'IS'"/>
      <xsl:sequence select="' '"/>
      <xsl:sequence select="t:get-literal(t:get-elements($value))"/>

      <xsl:sequence select="$t:unindent"/>
      <xsl:sequence select="$t:unindent"/>
    </xsl:if>

    <xsl:if test="exists($max-occurs)">
      <xsl:sequence select="' '"/>
      <xsl:sequence select="$t:terminator"/>

      <xsl:sequence select="$t:indent"/>
      <xsl:sequence select="$t:indent"/>

      <xsl:sequence select="'OCCURS'"/>

      <xsl:if test="exists($min-occurs)">
        <xsl:sequence select="' '"/>
        <xsl:sequence select="xs:string($min-occurs)"/>
        <xsl:sequence select="' '"/>
        <xsl:sequence select="'TO'"/>
      </xsl:if>

      <xsl:sequence select="' '"/>
      <xsl:sequence select="xs:string($max-occurs)"/>

      <xsl:if test="$depending-on">
        <xsl:sequence select="$t:new-line"/>
        <xsl:sequence select="'DEPENDING'"/>
        <xsl:sequence select="' '"/>
        <xsl:sequence select="'ON'"/>
        <xsl:sequence select="' '"/>
        <xsl:sequence select="
          t:get-qualified-data-name(t:get-elements($depending-on))"/>
      </xsl:if>

      <xsl:for-each select="$order-by">
        <xsl:variable name="direction" as="xs:string" select="@direction"/>

        <xsl:sequence select="' '"/>
        <xsl:sequence select="$t:terminator"/>

        <xsl:sequence select="
          if ($direction = 'ascending') then
            'ASCENDING'
          else if ($direction = 'descending') then
            'DESCENDING'
          else
            error(xs:QName('invalid-order-direction'), $direction)"/>

        <xsl:for-each select="t:get-elements(.)">
          <xsl:sequence select="' '"/>
          <xsl:sequence select="t:get-qualified-data-name(.)"/>
        </xsl:for-each>
      </xsl:for-each>

      <xsl:if test="$indexed-by">
        <xsl:variable name="index-refs" as="element()+"
          select="$indexed-by/index-ref"/>

        <xsl:sequence select="' '"/>
        <xsl:sequence select="$t:terminator"/>

        <xsl:sequence select="'INDEXED'"/>
        <xsl:sequence select="' '"/>
        <xsl:sequence select="'BY'"/>

        <xsl:for-each select="$index-refs">
          <xsl:sequence select="' '"/>
          <xsl:sequence select="t:get-index-ref(.)"/>
        </xsl:for-each>
      </xsl:if>

      <xsl:sequence select="$t:unindent"/>
      <xsl:sequence select="$t:unindent"/>
    </xsl:if>

    <xsl:if test="$redefines">
      <xsl:sequence select="$t:new-line"/>
      <xsl:sequence select="$t:indent"/>
      <xsl:sequence select="$t:indent"/>

      <xsl:sequence select="'REDEFINES'"/>
      <xsl:sequence select="' '"/>
      <xsl:sequence select="t:get-data-name-ref(t:get-elements($redefines))"/>

      <xsl:sequence select="$t:unindent"/>
      <xsl:sequence select="$t:unindent"/>
    </xsl:if>

    <xsl:sequence select="'.'"/>
    <xsl:sequence select="$t:new-line"/>

    <xsl:if test="$data-content">
      <xsl:sequence select="$t:indent"/>

      <xsl:apply-templates mode="t:data-content" select="$data-content">
        <xsl:with-param name="parent-data-level" tunnel="yes" 
          select="$data-level"/>
      </xsl:apply-templates>

      <xsl:sequence select="$t:unindent"/>
    </xsl:if>
  </xsl:template>

  <!--
    data-rename data-content.
  -->
  <xsl:template match="data-rename" mode="
    t:data-content
    t:element">

    <xsl:variable name="name" as="xs:string" select="@name"/>
    <xsl:variable name="elements" as="element()+" select="t:get-elements(.)"/>
    <xsl:variable name="from" as="element()" select="$elements[1]"/>
    <xsl:variable name="to" as="element()?"
      select="subsequence($elements, 2)"/>

    <xsl:sequence select="t:get-comments(.)"/>

    <xsl:sequence select="'66'"/>
    <xsl:sequence select="' '"/>
    <xsl:sequence select="$name"/>
    <xsl:sequence select="' '"/>
    <xsl:sequence select="t:get-qualified-data-name($from)"/>

    <xsl:if test="$to">
      <xsl:sequence select="' '"/>
      <xsl:sequence select="t:get-qualified-data-name($to)"/>
      <xsl:sequence select="' '"/>
    </xsl:if>

    <xsl:sequence select="'.'"/>
    <xsl:sequence select="$t:new-line"/>
  </xsl:template>

  <!--
    data-condition data-content.
  -->
  <xsl:template match="data-condition" mode="
    t:data-content
    t:element">

    <xsl:variable name="name" as="xs:string" select="@name"/>
    <xsl:variable name="values" as="element()+" select="value"/>

    <xsl:sequence select="t:get-comments(.)"/>

    <xsl:sequence select="'88'"/>
    <xsl:sequence select="' '"/>
    <xsl:sequence select="$name"/>
    <xsl:sequence select="' '"/>

    <xsl:variable name="single-value" as="xs:boolean"
      select="(count($values) = 1) and empty($values/literal-range)"/>

    <xsl:sequence select="
      if ($single-value) then
        ('VALUE', ' ', 'IS')
      else
        ('VALUES', ' ', 'ARE')"/>

    <xsl:sequence select="' '"/>
    <xsl:sequence select="$t:terminator"/>

    <xsl:choose>
      <xsl:when test="$single-value">
        <xsl:variable name="literals" as="element()+"
          select="t:get-elements($values)"/>
        
        <xsl:sequence select="t:get-literal($literals[1])"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:sequence select="$t:indent"/>

        <xsl:for-each select="$values">
          <xsl:variable name="range" as="element()?" select="literal-range"/>
          <xsl:variable name="literals" as="element()*" 
            select="$range/t:get-elements(.)"/>
          
          <xsl:variable name="from" as="element()" select="
            if ($range) then
              $literals[1]
            else
              t:get-elements(.)"/>
          
          <xsl:variable name="to" as="element()?"
            select="subsequence($literals, 2)"/>

          <xsl:if test="position() gt 1">
            <xsl:sequence select="' '"/>
            <xsl:sequence select="$t:terminator"/>
          </xsl:if>

          <xsl:sequence select="t:get-literal($from)"/>

          <xsl:if test="$to">
            <xsl:sequence select="' '"/>
            <xsl:sequence select="'THROUGH'"/>
            <xsl:sequence select="' '"/>
            <xsl:sequence select="t:get-literal($to)"/>
          </xsl:if>
        </xsl:for-each>

        <xsl:sequence select="$t:unindent"/>
      </xsl:otherwise>
    </xsl:choose>

    <xsl:sequence select="'.'"/>
    <xsl:sequence select="$t:new-line"/>
  </xsl:template>

  <!--
    copy.
  -->
  <xsl:template match="copy" mode="
    t:data-content
    t:element">
    <xsl:apply-templates mode="t:statement" select="."/>
  </xsl:template>

  <!--
    copy statement.
  -->
  <xsl:template match="copy" mode="t:statement">
    <xsl:variable name="name" as="xs:string?" select="@name"/>
    <xsl:variable name="in" as="element()?" select="in"/>

    <xsl:sequence select="t:get-comments(.)"/>

    <xsl:sequence select="'COPY'"/>
    <xsl:sequence select="' '"/>

    <xsl:sequence select="
      if ($name) then
        $name
      else
        t:get-literal(t:get-elements(. except $in))"/>

    <xsl:if test="$in">
      <xsl:variable name="library" as="xs:string?" select="$in/@name"/>

      <xsl:sequence select="' '"/>
      <xsl:sequence select="'IN'"/>
      <xsl:sequence select="' '"/>

      <xsl:sequence select="
        if ($library) then
          $library
        else
          t:get-literal(t:get-elements($in))"/>
    </xsl:if>

    <xsl:sequence select="'.'"/>
    <xsl:sequence select="$t:new-line"/>
  </xsl:template>

  <!--
    exec-sql.
  -->
  <xsl:template match="exec-sql" mode="
    t:data-content
    t:element">

    <xsl:apply-templates mode="t:statement" select="."/>
  </xsl:template>

  <!--
    exec-sql.
  -->
  <xsl:template match="exec-sql" mode="t:statement">
    <xsl:variable name="include" as="element()?" select="include"/>
    <xsl:variable name="value" as="element()?" select="value"/>

    <xsl:sequence select="t:get-comments(.)"/>

    <xsl:choose>
      <xsl:when test="$include">
        <xsl:sequence select="$t:indent"/>
        <xsl:sequence select="$t:indent"/>
        <xsl:sequence select="'EXEC'"/>
        <xsl:sequence select="' '"/>
        <xsl:sequence select="'SQL'"/>

        <xsl:variable name="name" as="xs:string?" select="$include/@name"/>
        <xsl:variable name="in" as="element()?" select="$include/in"/>

        <xsl:sequence select="' '"/>
        <xsl:sequence select="'INCLUDE'"/>
        <xsl:sequence select="' '"/>

        <xsl:sequence select="
          if ($name) then
            $name
          else
            t:get-literal(t:get-elements(. except $in))"/>

        <xsl:if test="$in">
          <xsl:variable name="library" as="xs:string?" select="$in/@name"/>

          <xsl:sequence select="' '"/>
          <xsl:sequence select="'IN'"/>
          <xsl:sequence select="' '"/>

          <xsl:sequence select="
            if ($library) then
              $library
            else
              t:get-literal(t:get-elements($in))"/>
        </xsl:if>

        <xsl:sequence select="' '"/>
        <xsl:sequence select="'END-EXEC'"/>
        <xsl:sequence select="'.'"/>
        <xsl:sequence select="$t:unindent"/>
        <xsl:sequence select="$t:unindent"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:sequence select="'EXEC'"/>
        <xsl:sequence select="' '"/>
        <xsl:sequence select="'SQL'"/>

        <xsl:sequence select="$t:new-line"/>

        <xsl:for-each select="$value/(text() | node())">
          <xsl:choose>
            <xsl:when test="self::text()">
              <xsl:for-each select="t:split-lines(.)">
                <xsl:analyze-string
                  regex="\s|'.*?'|&quot;.*?&quot;"
                  flags="m"
                  select=".">
                  <xsl:matching-substring>
                    <xsl:sequence select="."/>
                  </xsl:matching-substring>
                  <xsl:non-matching-substring>
                    <xsl:sequence select="."/>
                  </xsl:non-matching-substring>
                </xsl:analyze-string>

                <xsl:if test="position() != last()">
                  <xsl:sequence select="$t:new-line"/>
                </xsl:if>
              </xsl:for-each>
            </xsl:when>
            <xsl:otherwise>
              <xsl:variable name="tokens" as="item()+">
                <xsl:apply-templates mode="t:exec-sql-data-ref" select="."/>
              </xsl:variable>

              <xsl:sequence select="':'"/>
              <xsl:sequence select="$tokens"/>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:for-each>

        <xsl:sequence select="$t:new-line"/>

        <xsl:sequence select="'END-EXEC'"/>
        <xsl:sequence select="'.'"/>
      </xsl:otherwise>
    </xsl:choose>

    <xsl:sequence select="$t:new-line"/>
  </xsl:template>

  <!--
    data-ref t:exec-sql-data-ref
  -->
  <xsl:template match="data-ref" mode="t:exec-sql-data-ref">
    <xsl:variable name="name" as="xs:string" select="@name"/>
    <xsl:variable name="parent" as="element()?" select="t:get-elements(.)"/>

    <xsl:if test="exists($parent)">
      <xsl:variable name="tokens" as="item()+">
        <xsl:apply-templates mode="t:exec-sql-data-ref" select="$parent"/>
      </xsl:variable>

      <xsl:sequence select="$tokens"/>
      <xsl:sequence select="'.'"/>
    </xsl:if>

    <xsl:sequence select="$name"/>
  </xsl:template>

  <xsl:template match="node()" mode="
    t:program
    t:element
    t:file-and-sort-description-entry
    t:data-content"/>

  <!--
    Gets tokens for an element.
      $element - an element to get tokens for.
  -->
  <xsl:function name="t:get-tokens-for-element" as="item()*">
    <xsl:param name="element" as="element()"/>

    <xsl:apply-templates mode="t:element" select="$element"/>
  </xsl:function>

  <!--
TODO:

basis-statement
cbl-process-statement
compiler-directing-statement
control-cbl-statement
copy-operand
copy-statement
delete-compiler-directing-statement
eject-statement
enter-statement
insert-statement
options-list
quoted-pseudo-text
ready-or-reset-trace-statement
replace-statement
sequence-number-field
service-label-statement
service-reload-statement
skip1-2-3-statement
title-statement

-->

</xsl:stylesheet>