<?xml version="1.0" encoding="utf-8"?>
<!--
  This stylesheet provides functions to generate valid COBOL names.

  $Id$
-->
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:t="http://www.bphx.com/cobol"
  xmlns:p="http://www.bphx.com/cobol/private/cobol-optimizer"
  xmlns="http://www.bphx.com/cobol/2009-12-15"
  xpath-default-namespace="http://www.bphx.com/cobol/2009-12-15"
  exclude-result-prefixes="xs t p">

  <!-- Cobol reserved keywords. -->
  <xsl:variable name="t:cobol-reserved-words" as="xs:string+" select="
    'ACCEPT', 'ACCESS', 'ADD', 'ADDRESS',
    'ADVANCING', 'AFTER', 'ALL', 'ALPHABET',
    'ALPHABETIC', 'ALPHABETIC-LOWER', 'ALPHABETIC-UPPER', 'ALPHANUMERIC',
    'ALPHANUMERIC-EDITED', 'ALSO', 'ALTER', 'ALTERNATE',
    'AND', 'ANY', 'APPLY', 'ARE',
    'AREA', 'AREAS', 'ASCENDING', 'ASSIGN',
    'AT', 'AUTHOR', 'BASIS', 'BEFORE',
    'BEGINNING', 'BINARY', 'BLANK', 'BLOCK',
    'BOTTOM', 'BY', 'CALL', 'CANCEL',
    'CBL', 'CHARACTER', 'CHARACTERS', 'CLASS',
    'CLOSE', 'CODE', 'CODE-SET', 'COLLATING',
    'COMMA', 'COMMON', 'COMP', 'COMP-1', 
    'COMP-2', 'COMP-3', 'COMP-4', 'COMPUTATIONAL', 
    'COMPUTATIONAL-1', 'COMPUTATIONAL-2', 'COMPUTATIONAL-3', 'COMPUTATIONAL-4', 
    'COMPUTE', 'CONFIGURATION', 'CONTAINS', 'CONTENT', 
    'CONTINUE', 'CONVERTING', 'COPY', 'CORR', 
    'CORRESPONDING', 'COUNT', 'CURRENCY', 'DATA', 
    'DATE', 'DATE-COMPILED', 'DATE-WRITTEN', 'DAY', 
    'DAY-OF-WEEK', 'DBCS', 'DEBUG-ITEM', 'DEBUGGING', 
    'DECIMAL-POINT', 'DECLARATIVES', 'DEGUGGING', 'DELETE',
    'DELIMITED', 'DELIMITER', 'DEPENDING', 'DESCENDING', 
    'DISPLAY', 'DISPLAY-1', 'DIVIDE', 'DIVISION',
    'DOWN', 'DUPLICATES', 'DYNAMIC', 'EBCDIC',
    'EGCS', 'EJECT', 'ELSE', 'END',
    'END-ADD', 'END-CALL', 'END-COMPUTE', 'END-DELETE', 
    'END-DIVIDE', 'END-EVALUATE', 'END-IF', 'END-MULTIPLY', 
    'END-OF-PAGE', 'END-PERFORM', 'END-READ', 'END-RETURN', 
    'END-REWRITE', 'END-SEARCH', 'END-START', 'END-STRING', 
    'END-SUBTRACT', 'END-UNSTRING', 'END-WRITE', 'ENDING', 
    'ENTER', 'ENTRY', 'ENVIRONMENT', 'EOP', 
    'EQUAL', 'ERROR', 'EVALUATE', 'EVERY', 
    'EXCEPTION', 'EXIT', 'EXTEND', 'EXTERNAL', 
    (: 'F', :) 'FALSE', 'FD', 'FILE', 
    'FILE-CONTROL', 'FILLER', 'FIRST', 'FOOTING', 
    'FOR', 'FROM', 'GIVING', 'GLOBAL', 
    'GO', 'GOBACK', 'GREATER', 'HIGH-VALUE', 
    'HIGH-VALUES', 'I-O', 'I-O-CONTROL', 'ID', 
    'IDENTIFICATION', 'IF', 'IN', 'INDEX', 
    'INDEXED', 'INITIAL', 'INITIALIZE', 'INPUT', 
    'INPUT-OUTPUT', 'INSERT', 'INSPECT', 'INSTALLATION', 
    'INTO', 'INVALID', 'IS', 'JUST', 
    'JUSTIFIED', 'KANJI', 'KEY', 'LABEL', 
    'LEADING', 'LEFT', 'LENGTH', 'LESS', 
    'LINAGE', 'LINAGE-COUNTER', 'LINE', 'LINES', 
    'LINKAGE', 'LIST', 'LOCK', 'LOW-VALUE', 
    'LOW-VALUES', 'MAP', 'MEMORY', 'MERGE', 
    'MODE', 'MODULES', 'MORE-LABELS', 'MOVE', 
    'MULTIPLE', 'MULTIPLY', 'NATIVE', 'NEGATIVE', 
    'NEXT', 'NO', 'NOLIST', 'NOMAP', 
    'NOSOURCE', 'NOT', 'NULL', 'NULLS', 
    'NUMERIC', 'NUMERIC-EDITED', 'OBJECT-COMPUTER', 'OCCURS', 
    'OF', 'OFF', 'OMITTED', 'ON', 
    'OPEN', 'OPTIONAL', 'OR', 'ORDER', 
    'ORGANIZATION', 'OTHER', 'OUTPUT', 'OVERFLOW', 
    'PACKED-DECIMAL', 'PADDING', 'PAGE', 'PASSWORD', 
    'PERFORM', 'PIC', 'PICTURE', 'POINTER', 
    'POSITION', 'POSITIVE', 'PROCEDURE', 'PROCEDURES', 
    'PROCEED', 'PROCESS', 'PROGRAM', 'PROGRAM-ID', 
    'QUOTE', 'QUOTES', 'RANDOM', 'READ', 
    'READY', 'RECORD', 'RECORDING', 'RECORDS', 
    'REDEFINES', 'REEL', 'REFERENCE', 'RELATIVE', 
    'RELEASE', 'RELOAD', 'REMAINDER', 'REMOVAL', 
    'RENAMES', 'REPLACE', 'REPLACING', 'RERUN', 
    'RESERVE', 'RESET', 'RETURN', 'RETURN-CODE', 
    'REVERSED', 'REWIND', 'REWRITE', 'RIGHT', 
    'ROUNDED', 'RUN', (: 'S', :) 'SAME', 
    'SD', 'SEARCH', 'SECTION', 'SECURITY', 
    'SEGMENT-LIMIT', 'SELECT', 'SENTENCE', 'SEPARATE', 
    'SEQUENCE', 'SEQUENTIAL', 'SERVICE', 'SET', 
    'SHIFT-IN', 'SHIFT-OUT', 'SIGN', 'SIZE', 
    'SKIP1', 'SKIP2', 'SKIP3', 'SORT', 
    'SORT-CONTROL', 'SORT-CORE-SIZE', 'SORT-FILE-SIZE', 'SORT-MERGE', 
    'SORT-MESSAGE', 'SORT-MODE-SIZE', 'SORT-RETURN', 'SOURCE', 
    'SOURCE-COMPUTER', 'SPACE', 'SPACES', 'SPECIAL-NAMES',
    'STANDARD', 'STANDARD-1', 'STANDARD-2', 'START',
    'STATUS', 'STOP', 'STRING', 'SUBTRACT',
    'SUPPRESS', 'SYMBOLIC', 'SYNC', 'SYNCHRONIZED',
    'TALLY', 'TALLYING', 'TAPE', 'TEST',
    'THAN', 'THEN', 'THROUGH', 'THRU',
    'TIME', 'TIMES', 'TITLE', 'TO',
    'TOP', 'TRACE', 'TRAILING', 'TRUE',
    'U', 'UNIT', 'UNSTRING', 'UNTIL',
    'UP', 'UPON', 'USAGE', 'USE',
    'USING', (: 'V', :) 'VALUE', 'VALUES',
    'VARYING', 'WHEN', 'WHEN-COMPILED', 'WITH',
    'WORDS', 'WORKING-STORAGE', 'WRITE', 'WRITE-ONLY',
    'ZERO', 'ZEROES', 'ZEROS'"/>

  <!-- Extended reserved names. -->
  <xsl:variable name="t:reserved-names" as="xs:string*">
    <xsl:apply-templates mode="t:call" select="$t:reserved-names-handler"/>
  </xsl:variable>

  <!-- A total set of reserved words. -->
  <xsl:variable name="t:reserved-words" as="xs:string*"
    select="$t:cobol-reserved-words, $t:reserved-names"/>

  <!-- A handler to collect reserved names. -->
  <xsl:variable name="t:reserved-names-handler" as="element()">
    <t:reserved-names/>
  </xsl:variable>

  <!-- A default handler for the reserved names. -->
  <xsl:template mode="t:call" match="t:reserved-names"/>

  <!--
    Creates a normalized name for a specified name components.
      $component - name components to generate normalized name for.
      $default-name - a default name in case a name cannot be built.
      Returns a normalized name.
  -->
  <xsl:function name="t:create-name" as="xs:string?">
    <xsl:param name="components" as="xs:string*"/>
    <xsl:param name="default-name" as="xs:string?"/>

    <xsl:variable name="parts" as="xs:string*">
      <xsl:for-each select="$components">
        <xsl:variable name="component" as="xs:string" select="
          if (matches(., '[^\p{IsBasicLatin}]')) then
            (:
              Replace umlauts:
                Ä -> AE
                Ü -> UE
                Ö -> OE
            :)                      
            replace
            (
              replace
              (
                replace
                (
                  replace
                  (
                    normalize-unicode(upper-case(.), 'NFD'),
                    '[\p{Sk}\p{Mc}\p{Me}\p{Mn}]',
                    ''
                  ),
                  'Ä',
                  'AE'
                ),
                'Ö',
                'OE'
              ),
              'Ü',
              'UE'
            )
          else
            upper-case(.)"/>

        <xsl:analyze-string regex="[A-Z0-9]+" flags="imx" select="$component">
          <xsl:matching-substring>
            <xsl:sequence select="."/>
          </xsl:matching-substring>
        </xsl:analyze-string>
      </xsl:for-each>
    </xsl:variable>

    <xsl:variable name="name" as="xs:string"
      select="string-join($parts, '-')"/>

    <xsl:sequence select="
      if (not($name)) then
        $default-name
      else if (number($name)) then
        concat(($default-name, 'N')[1], '-', $name)
      else
        $name"/>
  </xsl:function>

  <!--
    Allocates unique names in the form $prefix{number}?.
    Note: that prefixes may coincide.
    Note: that result names shall be different not only using case.
      $prefixes - a name prefixes.
      $names - allocated names pool.
      $name-max-length - a longest allowable name length.
      Returns unique names.
  -->
  <xsl:function name="t:allocate-names" as="xs:string*">
    <xsl:param name="prefixes" as="xs:string*"/>
    <xsl:param name="names" as="xs:string*"/>
    <xsl:param name="name-max-length" as="xs:integer?"/>

    <xsl:variable name="count" as="xs:integer" select="count($prefixes)"/>

    <xsl:variable name="name-closures" as="item()*">
      <xsl:for-each select="$prefixes">
        <xsl:sequence select="position() * 2 - 1"/>

        <xsl:sequence select="
          if ($name-max-length) then
            p:trim-name(replace(., '-+$', ''), $name-max-length)
          else
            ."/>
      </xsl:for-each>

      <xsl:for-each select="$names">
        <xsl:sequence select="1 - ($count + position()) * 2"/>
        <xsl:sequence select="."/>
      </xsl:for-each>
    </xsl:variable>

    <xsl:variable name="result-closures" as="item()*" select="
      if (exists($name-closures)) then
        p:allocate-names($name-closures, $name-max-length)
      else
        ()"/>

    <!--<xsl:message select="'$result-closures: ', count($result-closures)"/>
    <xsl:message select="'$result-closures: ', $result-closures"/>-->

    <xsl:for-each select="
      (1 to count($result-closures) - 1)
      [
        for $index in . return
          (($index mod 2) = 1) and
          ($result-closures[$index] >= -$count * 2)
      ]">
      <xsl:sort
        select="
          for $index in . return
            $result-closures[$index]"
        order="descending"/>

      <xsl:sequence select="
        for $index in . return
          $result-closures[$index + 1]"/>
    </xsl:for-each>
  </xsl:function>

  <!--
    Allocates unique names in the form $prefix{number}?.
    Note: that prefixes may coincide.
    Note: that result names shall be different not only using case.
      $name-closures - a sequence of name closures:
        ($index as xs:integer, $name as xs:string).

        unique names are allocated closures where $index > 0.
      $name-max-length - a longest allowable name length.
      Returns name closures with unique names.
  -->
  <xsl:function name="p:allocate-names" as="item()+">
    <xsl:param name="name-closures" as="item()+"/>
    <xsl:param name="name-max-length" as="xs:integer?"/>

    <xsl:variable name="indices" as="xs:integer+"
      select="(1 to count($name-closures) - 1)[(position() mod 2) = 1]"/>

    <xsl:variable name="ordered-indices" as="xs:integer+">
      <xsl:perform-sort select="$indices">
        <xsl:sort select="
          for $index in . return
            upper-case($name-closures[$index + 1])"/>
      </xsl:perform-sort>
    </xsl:variable>

    <!--
    <xsl:message
      select="'name-closures: ', count($name-closures) idiv 2"/>
    <xsl:message
      select="'$names: ', $name-closures[(position() mod 2) = 0]"/>
    <xsl:message
      select="'$name-closures: ', $name-closures"/>
    -->

    <xsl:variable name="new-name-closures" as="item()+">
      <xsl:for-each-group select="$ordered-indices"
        group-by="
          for $index in . return
            upper-case(p:get-prefix($name-closures[$index + 1]))">

        <xsl:variable name="prefix-group" as="xs:integer+"
          select="current-group()"/>

        <xsl:choose>
          <xsl:when test="count($prefix-group) = 1">
            <xsl:variable name="name" as="xs:string"
              select="$name-closures[$prefix-group + 1]"/>
            <xsl:variable name="is-reserved-word" as="xs:boolean"
              select="p:is-reserved-word($name)"/>

            <xsl:sequence select="
              if
              (
                ($name-closures[$prefix-group] lt 0) or
                not($is-reserved-word)
              )
              then
              (
                -$prefix-group,
                $name
              )
              else
              (
                $prefix-group,
                p:get-alternative-name
                (
                  $name, 
                  $is-reserved-word, 
                  '1', 
                  $name-max-length
                )
              )"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:variable name="prefix" as="xs:string" select="
              for $index in . return
                string(p:get-prefix($name-closures[$index + 1]))"/>

            <xsl:variable name="max-suffix" as="xs:integer" select="
              (
                max
                (
                  for
                    $index in $prefix-group,
                    $name in $name-closures[$index + 1],
                    $suffix in substring($name, string-length($prefix) + 1)
                  return
                    if ($suffix) then
                      abs(xs:integer($suffix))
                    else
                      ()
                ),
                0
              )[1]"/>

            <xsl:for-each-group select="1 to count($prefix-group)"
              group-adjacent="
                for
                  $i in .,
                  $index in $prefix-group[$i]
                return
                  upper-case($name-closures[$index + 1])">

              <xsl:variable name="group" as="xs:integer+"
               select="current-group()"/>
              <xsl:variable name="name" as="xs:string"
                select="current-grouping-key()"/>
              <xsl:variable name="is-reserved-word" as="xs:boolean"
                select="p:is-reserved-word($name)"/>

              <xsl:sequence select="
                if ((count($group) = 1) and not($is-reserved-word)) then
                (
                  -$prefix-group[$group],
                  $name
                )
                else
                  for
                    $index in $group,
                    $group-index in $prefix-group[$index]
                  return
                    if ($name-closures[$group-index] lt 0) then
                    (
                      -$group-index,
                      $name
                    )
                    else
                    (
                      $group-index,

                      if ($is-reserved-word) then
                        p:get-alternative-name
                        (
                          $name,
                          true(),
                          string($index),
                          $name-max-length
                        )
                      else
                        for $suffix in xs:string($max-suffix + $index) return
                          p:compose-name
                          (
                            (
                              if
                              (
                                string-length($prefix) + string-length($suffix) >
                                  $name-max-length
                              )
                              then
                                string-join
                                (
                                  (
                                    $prefix,
                                    (
                                      for
                                        $i in string-length($prefix) to
                                          string-length($name)
                                      return
                                        '0'
                                    )
                                  ),
                                  ''
                                )
                              else
                                $prefix
                            ),
                            $suffix,
                            $name-max-length
                          )
                    )"/>
            </xsl:for-each-group>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:for-each-group>
    </xsl:variable>

    <xsl:variable name="unresolved" as="xs:integer+">
      <xsl:for-each-group select="$ordered-indices"
        group-by="
          for $index in . return
            upper-case($new-name-closures[$index + 1])">

        <xsl:variable name="group" as="xs:integer+" select="current-group()"/>

        <xsl:sequence select="
          if (count($group) = 1) then
            -$group
          else
            for $index in $group return
              if ($new-name-closures[$index] lt 0) then
                -$index
              else
                $index"/>
      </xsl:for-each-group>
    </xsl:variable>

    <!--<xsl:message select="'$unresolved: ', count($unresolved[. > 0])"/>-->
    <!--<xsl:message select="'$unresolved: ', $unresolved"/>-->

    <xsl:sequence select="
      if (not($unresolved > 0)) then
        for
          $index in $unresolved,
          $name-index in abs($new-name-closures[-$index])
        return
        (
          -abs($name-closures[$name-index]),
          $new-name-closures[1 - $index]
        )
      else
        p:allocate-names
        (
          (
            for
              $index in $unresolved,
              $name-index in abs($new-name-closures[abs($index)])
            return
            (
              if ($index > 0) then
              (
                abs($name-closures[$name-index]),
                string(p:get-prefix($new-name-closures[$index + 1]))
              )
              else
              (
                -abs($name-closures[$name-index]),
                $new-name-closures[1 - $index]
              )
            )
          ),
          $name-max-length
        )"/>
  </xsl:function>

  <!--
    Composes a name in the form $prefix and $suffix.
      $prefix - a name prefix.
      $suffix - a suffix to test.
      $name-max-length - a longest allowable name length.
      Returns a name.
  -->
  <xsl:function name="p:compose-name" as="xs:string">
    <xsl:param name="prefix" as="xs:string"/>
    <xsl:param name="suffix" as="xs:string"/>
    <xsl:param name="name-max-length" as="xs:integer?"/>

    <xsl:variable name="prefix-length" as="xs:integer"
      select="string-length($prefix)"/>
    <xsl:variable name="suffix-length" as="xs:integer"
      select="string-length($suffix)"/>

    <xsl:variable name="prefix-start" as="xs:string"
      select="replace($prefix, '-[A-Z0-9]+-*$', '', 'i')"/>
    <xsl:variable name="prefix-start-length" as="xs:integer"
      select="string-length($prefix-start)"/>
    <xsl:variable name="prefix-end" as="xs:string"
      select="substring($prefix, $prefix-start-length + 1)"/>
    <xsl:variable name="delta" as="xs:integer"
      select="$prefix-length + $suffix-length - $name-max-length"/>

    <xsl:choose>
      <xsl:when test="
        ($prefix-length + $suffix-length + 1 le $name-max-length) and
        matches($prefix-start, '\d$') and
        matches($suffix, '^\d')">
        <xsl:sequence 
          select="concat($prefix-start, '-', $suffix, $prefix-end)"/>
      </xsl:when>
      <xsl:when test="$prefix-length + $suffix-length le $name-max-length">
        <xsl:sequence select="concat($prefix-start, $suffix, $prefix-end)"/>
      </xsl:when>
      <xsl:when test="$suffix-length gt $name-max-length">
        <xsl:message>
          <xsl:text>Unable to find a name for a prefix: "</xsl:text>
          <xsl:value-of select="$prefix"/>
          <xsl:text>", suffix: "</xsl:text>
          <xsl:value-of select="$suffix"/>
          <xsl:text>", max-length: </xsl:text>
          <xsl:value-of select="$name-max-length"/>
          <xsl:text>. A fallback name is used.</xsl:text>
        </xsl:message>

        <xsl:sequence select="'A'"/>
      </xsl:when>
      <xsl:when test="$prefix-start-length > $delta">
        <xsl:sequence select="
          concat
          (
            substring
            (
              $prefix-start, 
              1,
              $prefix-start-length - $delta
            ),
            $prefix-end,
            $suffix
          )"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:sequence select="
          concat
          (
            substring($prefix-start, 1, 1),
            substring($prefix-end, $delta - $prefix-start-length),
            $suffix
          )"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:function>

  <!--
    Trims a name to a specified length.
      $name - a name prefix.
      $name-max-length - a longest allowable name length.
      Returns a trimmed name.
  -->
  <xsl:function name="p:trim-name" as="xs:string">
    <xsl:param name="name" as="xs:string"/>
    <xsl:param name="name-max-length" as="xs:integer?"/>

    <xsl:variable name="length" as="xs:integer"
      select="string-length($name)"/>

    <xsl:choose>
      <xsl:when test="$length le $name-max-length">
        <xsl:sequence select="$name"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:variable name="delta" as="xs:integer" 
          select="$length - $name-max-length"/>
        <xsl:variable name="start" as="xs:string"
          select="replace($name, '-[A-Z0-9]+-*$', '', 'i')"/>
        <xsl:variable name="start-length" as="xs:integer"
          select="string-length($start)"/>
        <xsl:variable name="end" as="xs:string"
          select="substring($name, $start-length + 1)"/>

        <xsl:choose>
          <xsl:when test="$start-length > $delta">
            <xsl:sequence select="
              concat(substring($start, 1, $start-length - $delta), $end)"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:sequence select="
              concat
              (
                substring($start, 1, 1),
                substring($end, $delta - $start-length)
              )"/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:function>

  <!--
    Gets a name without numeric suffix.
      $name - a name to get prefix for.
      Returns a name prefix.
  -->
  <xsl:function name="p:get-prefix" as="xs:string?">
    <xsl:param name="name" as="xs:string"/>

    <xsl:analyze-string select="$name" regex="-?\d+$">
      <xsl:non-matching-substring>
        <xsl:sequence select="."/>
      </xsl:non-matching-substring>
    </xsl:analyze-string>
  </xsl:function>

  <!--
    A key to to lookup reserved words.
  -->
  <xsl:key name="p:id" match="*" use="xs:string(@name)"/>

  <!-- Reserved words lookup document. -->
  <xsl:variable name="p:reserved-words">
    <xsl:for-each select="$t:reserved-words">
      <word name="{.}"/>
    </xsl:for-each>
  </xsl:variable>

  <!--
    Tests whether a specified value is a reserved word.
      $value - a value to test.
      Returns true if value is a reserved word, and false otherwise.
  -->
  <xsl:function name="p:is-reserved-word" as="xs:boolean">
    <xsl:param name="value" as="xs:string"/>

    <xsl:sequence select="exists(key('p:id', $value, $p:reserved-words))"/>
  </xsl:function>

  <!--
    Gets alternative word for a name.
      $name - a name.
      $is-reserved-word - indicates whether the name is reserved word.
      $suffix - a suffix to test.
      $name-max-length - a longest allowable name length.
  -->
  <xsl:function name="p:get-alternative-name" as="xs:string">
    <xsl:param name="name" as="xs:string"/>
    <xsl:param name="is-reserved-word" as="xs:boolean"/>
    <xsl:param name="suffix" as="xs:string"/>
    <xsl:param name="name-max-length" as="xs:integer?"/>

    <xsl:sequence select="
      if (not($is-reserved-word)) then
        p:compose-name($name, $suffix, $name-max-length)        
      else if ($name = 'COUNT') then
        p:compose-name('CNT', '', $name-max-length)
      else if ($name = 'CURRENCY') then
        p:compose-name('CUR', '', $name-max-length)
      else if ($name = 'LENGTH') then
        p:compose-name('LEN', '', $name-max-length)
      else if ($name = ('LOW-VALUE', 'LOW-VALUES')) then
        p:compose-name('LOW', '', $name-max-length)
      else if ($name = ('HIGH-VALUE', 'HIGH-VALUES')) then
        p:compose-name('HIGH', '', $name-max-length)
      else if ($name = 'PROCEDURE') then
        p:compose-name('PROC', '', $name-max-length)
      else if ($name = 'PROGRAM') then
        p:compose-name('PROG', '', $name-max-length)
      else if ($name = ('VALUE', 'VALUES')) then
        p:compose-name($name, $suffix, $name-max-length)
      else
        p:compose-name($name, 'VALUE', $name-max-length)"/>
  </xsl:function>

</xsl:stylesheet>