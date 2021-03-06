<?xml version="1.0" encoding="utf-8"?>
<!--
  This stylesheet streams a sequence of tokens into text.
  This version of streamer builds output lines as items.
-->
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:t="http://www.bphx.com/public/sql"
  xmlns:p="http://www.bphx.com/private/sql-streamer2"
  exclude-result-prefixes="t p xs">

  <!-- New line text. -->
  <xsl:param name="t:new-line-text" as="xs:string" select="'&#10;'"/>

  <!-- Indentation text. -->
  <xsl:param name="t:indent-text" as="xs:string" select="'  '"/>

  <!-- Preferrable number of characters per line. -->
  <xsl:param name="t:chars-per-line" as="xs:integer" select="1000"/>

  <!-- Indent control word. -->
  <xsl:variable name="t:indent" as="xs:QName" select="xs:QName('t:indent')"/>

  <!-- Unindent control word. -->
  <xsl:variable name="t:unindent" as="xs:QName"
    select="xs:QName('t:unindent')"/>

  <!-- Resets indentation for one line. -->
  <xsl:variable name="t:line-indent" as="xs:QName"
    select="xs:QName('t:line-indent')"/>

  <!-- New line control word. -->
  <xsl:variable name="t:new-line" as="xs:QName"
    select="xs:QName('t:new-line')"/>

  <!-- Terminator control word. -->
  <xsl:variable name="t:terminator" as="xs:QName"
    select="xs:QName('t:terminator')"/>

  <!-- Regular line control word. -->
  <xsl:variable name="t:code" as="xs:QName" select="xs:QName('t:code')"/>

  <!-- Documentation line control word. -->
  <xsl:variable name="t:doc" as="xs:QName" select="xs:QName('t:doc')"/>

  <!-- Begin documentation line control word. -->
  <xsl:variable name="t:begin-doc" as="xs:QName"
    select="xs:QName('t:begin-doc')"/>

  <!-- End documentation line control word. -->
  <xsl:variable name="t:end-doc" as="xs:QName" select="xs:QName('t:end-doc')"/>

  <!-- Comment line control word. -->
  <xsl:variable name="t:comment" as="xs:QName" select="xs:QName('t:comment')"/>

  <!-- Control word defining description comment line. -->
  <xsl:variable name="t:doc-description" as="xs:QName"
    select="xs:QName('t:doc-description')"/>

  <!--
    Gets sequence of lines from sequence of tokens and control words.
      $tokens - input sequence of tokens.
      Returns a sequence of line strings.
  -->
  <xsl:function name="t:get-lines" as="item()*">
    <xsl:param name="tokens" as="item()*"/>

    <xsl:call-template name="t:get-lines">
      <xsl:with-param name="tokens" select="$tokens"/>
    </xsl:call-template>
  </xsl:function>

  <!--
    Gets sequence of lines from sequence of tokens and control words.
      $tokens - input sequence of tokens.
      $line-breaks - a sequence of line breaks.
      $line-index - an index of current line (zero based).
      $indent - current indentation.
      Returns a sequence of line strings.
  -->
  <xsl:template name="t:get-lines" as="item()*">
    <xsl:param name="tokens" as="item()*"/>
    <xsl:param name="line-breaks" as="xs:integer*" 
      select="index-of($tokens, $t:new-line)"/>
    <xsl:param name="line-index" as="xs:integer" select="0"/>
    <xsl:param name="indent" as="xs:integer" select="0"/>

    <xsl:variable name="index" as="xs:integer?" select="
      if ($line-index = 0) then
        1
      else
        $line-breaks[$line-index] + 1"/>

    <xsl:variable name="line-break" as="xs:integer?"
      select="$line-breaks[$line-index + 1]"/>

    <xsl:variable name="line" as="item()*" select="
      if (empty($index)) then
        ()
      else if (exists($line-break)) then
        subsequence($tokens, $index, $line-break - $index)
      else
        subsequence($tokens, $index)"/>

    <xsl:sequence select="t:format-line($line, $indent)"/>

    <xsl:if 
      test="exists($line-break) or exists($line[not(. instance of xs:QName)])">
      <xsl:call-template name="t:get-lines">
        <xsl:with-param name="tokens" select="$tokens"/>
        <xsl:with-param name="line-breaks" select="$line-breaks"/>
        <xsl:with-param name="line-index" select="$line-index + 1"/>
        <xsl:with-param name="indent" 
          select="$indent + t:get-indentation($line)"/>
      </xsl:call-template>
    </xsl:if>
  </xsl:template>

  <!--
    Gets subset of tokens for the token sequence.
      $tokens - input sequence of tokens.
      $start - position of line start.
      $end - position of t:new-line token.
      Returns
  -->
  <xsl:function name="t:get-sub-tokens" as="item()*">
    <xsl:param name="tokens" as="item()*"/>
    <xsl:param name="start" as="xs:integer"/>
    <xsl:param name="end" as="xs:integer"/>

    <xsl:sequence select="subsequence($tokens, $start, $end - $start)"/>
  </xsl:function>

  <!--
    Gets indentation for the sequence of tokens.
      $tokens - input sequence of tokens.
      Returns total indentation for the sequence of tokens.
  -->
  <xsl:function name="t:get-indentation" as="xs:integer">
    <xsl:param name="tokens" as="item()*"/>

    <xsl:variable name="controls" as="xs:QName*"
      select="$tokens[. instance of xs:QName]"/>

    <xsl:sequence select="
      if ($controls = $t:line-indent) then
        0
      else
        sum
        (
          for $token in $controls return
            if ($token eq $t:indent) then
              1
            else if ($token eq $t:unindent) then
              -1
            else
              ()
        )"/>
  </xsl:function>

  <!--
    Formats a line.
      $tokens - input sequence of tokens.
      $indent - current level of indentation.
      Returns formatted line as sequence of items.
  -->
  <xsl:function name="t:format-line" as="item()*">
    <xsl:param name="tokens" as="item()*"/>
    <xsl:param name="indent" as="xs:integer"/>

    <xsl:variable name="literals" as="item()*"
      select="$tokens[not(. instance of xs:QName)]"/>

    <xsl:variable name="control-tokens" as="xs:QName*" select="
      subsequence
      (
        $tokens,
        1,
        (
          for $i in 1 to count($tokens) return
          (
            if ($tokens[$i] instance of xs:QName) then
              ()
            else
              $i - 1
          ),
          count($tokens)
        )[1]
      )"/>

    <xsl:variable name="line-indent" as="xs:integer?"
      select="index-of($control-tokens, $t:line-indent)[last()]"/>
    <xsl:variable name="next-tokens" as="xs:QName*"
      select="subsequence($control-tokens, $line-indent + 1)"/>

    <xsl:variable name="indent-value" as="xs:integer" select="
      if (exists($line-indent)) then
        count($next-tokens[. eq $t:indent])
      else
        $indent + t:get-indentation($control-tokens)"/>

    <xsl:variable name="indentation" as="xs:string" select="
      string-join
      (
        for $i in 1 to $indent-value return $t:indent-text,
        ''
      )"/>

    <xsl:variable name="type" as="xs:QName?" select="
      $control-tokens
      [
        . =
          (
            $t:code,
            $t:comment,
            $t:doc,
            $t:doc-description,
            $t:begin-doc,
            $t:end-doc
          )
      ][last()]"/>

    <xsl:choose>
      <xsl:when test="empty($type) or ($type = $t:code)">
        <!-- Code line. -->
        <xsl:variable name="length" as="xs:integer" 
          select="sum(for $s in $literals return string-length($s))"/>

        <xsl:choose>
          <xsl:when
            test="$t:chars-per-line >= string-length($indentation) + $length">
            <xsl:sequence select="
              if (exists($literals)) then
                t:string-join(($indentation, $literals, $t:new-line-text))
              else
                $t:new-line-text"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:call-template name="t:format-long-code-line">
              <xsl:with-param name="indentation" select="$indentation"/>
              <xsl:with-param name="literals" select="$literals"/>
              <xsl:with-param name="leader" select="true()"/>
            </xsl:call-template>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:when>
      <xsl:when test="$type = $t:comment">
        <!-- Comment line. -->
        <xsl:call-template name="t:format-comment">
          <xsl:with-param name="prefix" select="concat($indentation, '-- ')"/>
          <xsl:with-param name="literals" select="$literals"/>
          <xsl:with-param name="leader" select="false()"/>
        </xsl:call-template>
      </xsl:when>
      <xsl:when test="$type = $t:doc">
        <!-- Documentation comment line. -->
        <xsl:call-template name="t:format-comment">
          <xsl:with-param name="prefix" select="concat($indentation, ' * ')"/>
          <xsl:with-param name="literals" select="$literals"/>
          <xsl:with-param name="leader" select="false()"/>
        </xsl:call-template>
      </xsl:when>
      <xsl:when test="$type = $t:doc-description">
        <!-- Documentation comment line. -->
        <xsl:call-template name="t:format-comment">
          <xsl:with-param name="prefix" select="concat($indentation, ' * ')"/>
          <xsl:with-param name="literals" select="$literals"/>
          <xsl:with-param name="leader" select="true()"/>
        </xsl:call-template>
      </xsl:when>
      <xsl:when test="$type = $t:begin-doc">
        <!-- Start documentation comment line. -->
        <xsl:if test="$literals">
          <xsl:sequence select="
            error
            (
              xs:QName('invalid-line'),
              concat
              (
                'Line content ''',
                string-join($literals, ''),
                ''' is not expected on ''begin-doc'' token.'
              )
            )"/>
        </xsl:if>

        <xsl:sequence
          select="string-join(($indentation, '/*', $t:new-line-text), '')"/>
      </xsl:when>
      <xsl:when test="$type = $t:end-doc">
        <!-- End documentation comment line. -->
        <xsl:if test="$literals">
          <xsl:sequence select="
            error
            (
              xs:QName('invalid-line'),
              concat
              (
                'Line content ''',
                string-join($literals, ''),
                ''' is not expected on ''end-doc'' token.'
              )
            )"/>
        </xsl:if>

        <xsl:sequence
          select="string-join(($indentation, '*/', $t:new-line-text), '')"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:sequence select="
          error
          (
            xs:QName('invalid-line-type'),
            concat
            (
              'Type: ',
              string($type),
              ' line ''',
              string-join($literals, ''),
              ''''
            )
          )"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:function>

  <!--
    Formats long regular line.
      $indentation - indentation string.
      $literals - literal tokens.
      $leader - true indicate leader line.
      Returns formatted lines.
  -->
  <xsl:template name="t:format-long-code-line" as="item()*">
    <xsl:param name="indentation" as="xs:string"/>
    <xsl:param name="literals" as="item()+"/>
    <xsl:param name="leader" as="xs:boolean"/>

    <xsl:variable name="breaker" as="xs:integer?" select="
      t:get-breaker
      (
        $literals,
        $t:chars-per-line - string-length($indentation),
        1,
        (),
        ()
      )"/>

    <xsl:if test="exists($breaker)">
      <xsl:variable name="previous-literals" as="xs:string*"
        select="subsequence($literals, 1, $breaker)"/>
      <xsl:variable name="next-literals" as="xs:string*"
        select="subsequence($literals, $breaker + 1)"/>

      <xsl:variable name="next-indentation" as="xs:string" select="
        if ($leader) then
          concat($indentation, $t:indent-text)
        else
          $indentation"/>

      <xsl:variable name="line" as="item()*"
        select="t:string-join($previous-literals)"/>

      <xsl:sequence select="concat($indentation, $line, $t:new-line-text)"/>

      <xsl:if test="exists($next-literals)">
        <xsl:call-template name="t:format-long-code-line">
          <xsl:with-param name="indentation" select="$next-indentation"/>
          <xsl:with-param name="literals" select="$next-literals"/>
          <xsl:with-param name="leader" select="false()"/>
        </xsl:call-template>
      </xsl:if>
    </xsl:if>
  </xsl:template>

  <!-- Line breakers, used in t:get-breaker function. -->
  <xsl:variable name="t:line-breakers" as="xs:string*"
    select="'=', ')', '.', ' ', ','"/>

  <!-- Line breaker priorities, used in t:get-breaker function. -->
  <xsl:variable name="t:line-breaker-priorities" as="xs:integer*"
    select="3,   5,   0,   0,   12"/>

  <!--
    Gets a position of code line breaker.
      $values - a sequence of values.
      $index - current index.
      $width - available width of total sequence of tokens.
      $breaker-priority - a breaker priority.
      $breaker-index - a breaker index.
      Returns a position of code line breaker.
  -->
  <xsl:function name="t:get-breaker" as="xs:integer?">
    <xsl:param name="values" as="item()*"/>
    <xsl:param name="width" as="xs:integer"/>
    <xsl:param name="index" as="xs:integer"/>
    <xsl:param name="breaker-priority" as="xs:integer?"/>
    <xsl:param name="breaker-index" as="xs:integer?"/>

    <xsl:variable name="value" as="item()?" select="$values[$index]"/>

    <xsl:choose>
      <xsl:when test="empty($value)">
        <xsl:sequence select="
          if ($index > 1) then
            $index - 1
          else
            ()"/>
      </xsl:when>
      <xsl:when test="$width le 0">
        <xsl:sequence select="
          if (exists($breaker-index)) then
            $breaker-index
          else if ($index > 1) then
            $index - 1
          else
            1"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:variable name="position" as="xs:integer?"
          select="index-of($t:line-breakers, $value)"/>

        <xsl:choose>
          <xsl:when test="
            exists($position) and
            ($width - string-length($t:line-breakers[$position]) ge 0) and
            (
              empty($breaker-priority) or
              ($t:line-breaker-priorities[$position] ge $breaker-priority) or
              ($breaker-index + $breaker-priority le $index)
            )">
            <xsl:sequence select="
              t:get-breaker
              (
                $values,
                $width - string-length($value),
                $index + 1,
                $t:line-breaker-priorities[$position],
                $index
              )"/>
          </xsl:when>
          <xsl:when test="$width - string-length($value) lt 0">
            <xsl:sequence select="if ($index > 1) then $index - 1 else 1"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:sequence select="
              t:get-breaker
              (
                $values,
                $width - string-length($value),
                $index + 1,
                $breaker-priority,
                $breaker-index
              )"/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:function>

  <!--
    Formats comment line.
      $prefix - comment prefix.
      $literals - literal tokens.
      $leader - true indicate leader line.
      Return comment lines.
  -->
  <xsl:template name="t:format-comment" as="item()*">
    <xsl:param name="prefix" as="xs:string?"/>
    <xsl:param name="literals" as="item()*"/>
    <xsl:param name="leader" as="xs:boolean"/>

    <xsl:variable name="breaker" as="xs:integer?" select="
      t:get-comment-breaker
      (
        $literals,
        $t:chars-per-line - string-length($prefix),
        1
      )"/>

    <xsl:if test="exists($breaker)">
      <xsl:variable name="previous-literals" as="item()*"
        select="subsequence($literals, 1, $breaker)"/>
      <xsl:variable name="next-literals" as="xs:string*"
        select="subsequence($literals, $breaker + 1)"/>

      <xsl:variable name="next-prefix" as="xs:string" select="
        if ($leader) then
          concat($prefix, $t:indent-text)
        else
          $prefix"/>

      <xsl:variable name="line" as="item()*"
        select="t:string-join($previous-literals)"/>

      <xsl:sequence select="concat($prefix, $line, $t:new-line-text)"/>

      <xsl:if test="exists($next-literals)">
        <xsl:call-template name="t:format-comment">
          <xsl:with-param name="prefix" select="$next-prefix"/>
          <xsl:with-param name="literals" select="$next-literals"/>
          <xsl:with-param name="leader" select="false()"/>
        </xsl:call-template>
      </xsl:if>
    </xsl:if>
  </xsl:template>

  <!--
    Gets a position of comment line breaker.
      $values - a sequence of values.
      $index - current index.
      $width - available width of total sequence of tokens.
      $breaker-priority - a breaker priority.
      $breaker-index - a breaker index.
      Returns a position of comment line breaker.
  -->
  <xsl:function name="t:get-comment-breaker" as="xs:integer?">
    <xsl:param name="values" as="item()*"/>
    <xsl:param name="width" as="xs:integer"/>
    <xsl:param name="index" as="xs:integer"/>

    <xsl:variable name="value" as="item()?" select="$values[$index]"/>

    <xsl:choose>
      <xsl:when test="empty($value)">
        <xsl:sequence select="
          if ($index > 1) then
            $index - 1
          else
            ()"/>
      </xsl:when>
      <xsl:when test="($width le 0) or ($width - string-length($value) lt 0)">
        <xsl:choose>
          <xsl:when test="
            (string($value) = ('.', ',', '!', '&quot;', '''')) and
            ($index > 2)">
            <xsl:sequence select="$index - 2"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:sequence select="
              if ($index > 1) then
                $index - 1
              else
                1"/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:when>
      <xsl:otherwise>
        <xsl:sequence select="
          t:get-comment-breaker
          (
            $values,
            $width - string-length($value),
            $index + 1
          )"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:function>

  <!--
    Indicates whether tokens sequence is multiline.
      $tokens - token sequence.
      Returns true if tokens contain $t:new-line control word, and
      false otherwise.
  -->
  <xsl:function name="t:is-multiline" as="xs:boolean">
    <xsl:param name="tokens" as="item()*"/>

    <xsl:variable name="position" as="xs:integer?"
      select="index-of($tokens, $t:new-line)[1]"/>

    <xsl:sequence select="
      exists($position) and
      exists
      (
        subsequence($tokens, $position + 1)[not(. instance of xs:QName)]
      )"/>
  </xsl:function>

  <!--
    Indents all lines starting from second line.
      $tokens - token sequence.
      Returns modified token sequence.
  -->
  <xsl:function name="t:indent-from-second-line" as="item()*">
    <xsl:param name="tokens" as="item()*"/>

    <xsl:variable name="position" as="xs:integer?"
      select="index-of($tokens, $t:new-line)[1]"/>

    <xsl:choose>
      <xsl:when test="exists($position)">
        <xsl:variable name="token" as="item()?"
          select="$tokens[$position + 1]"/>

        <xsl:choose>
          <xsl:when test="exists($token) and empty(index-of($token, '{'))">
            <xsl:sequence
              select="insert-before($tokens, $position + 1, $t:indent)"/>
            <xsl:sequence select="$t:unindent"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:sequence select="$tokens"/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:when>
      <xsl:otherwise>
        <xsl:sequence select="$tokens"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:function>

  <!--
    Reformats $t:terminator separated token sequence.
      $tokens - token sequence to format.
      $verbose-threshold - threshold value of number of terminators
        that indicates whether to treat tokens as verbose.
      $separator - regular separator.
      $verbose-separator - verbose separator.
      $put-separator-at-the-end - indicates whether to put separator as
        last token of formatted token sequence.
      $indent-from-second-line - indicates whether to indent tokens from
        second line.
  -->
  <xsl:function name="t:reformat-tokens" as="item()*">
    <xsl:param name="tokens" as="item()*"/>
    <xsl:param name="verbose-threshold" as="xs:integer?"/>
    <xsl:param name="separator" as="item()*"/>
    <xsl:param name="verbose-separator" as="item()*"/>
    <xsl:param name="put-separator-at-the-end" as="xs:boolean?"/>
    <xsl:param name="indent-from-second-line" as="xs:boolean?"/>

    <xsl:variable name="terminators" as="xs:integer*"
      select="0, index-of($tokens, $t:terminator)"/>
    <xsl:variable name="count" as="xs:integer"
      select="count($terminators) - 1"/>

    <xsl:variable name="verbose" as="xs:boolean" select="
      ($count >= $verbose-threshold) or t:is-multiline($tokens)"/>

    <xsl:variable name="formatted-tokens" as="item()*" select="
      for $i in 1 to $count return
      (
        t:get-sub-tokens
        (
          $tokens,
          $terminators[$i] + 1,
          $terminators[$i + 1]
        ),
        if (($i = $count) and not($put-separator-at-the-end)) then
          ()
        else
          if ($verbose) then $verbose-separator else $separator
      )"/>

    <xsl:sequence select="
      if ($indent-from-second-line) then
        t:indent-from-second-line($formatted-tokens)
      else
        $formatted-tokens"/>
  </xsl:function>

  <!--
    Splits string into tokens.
      $value - a value to split into tokens.
      Returns tokens sequence.
  -->
  <xsl:function name="t:tokenize" as="item()*">
    <xsl:param name="value" as="xs:string?"/>

    <xsl:sequence select="t:tokenize($value, $t:new-line)"/>
  </xsl:function>

  <!--
    Splits string into tokens.
      $value - a value to split into tokens.
      $line-separator - defines a line separator.
      Returns tokens sequence.
  -->
  <xsl:function name="t:tokenize" as="item()*">
    <xsl:param name="value" as="xs:string?"/>
    <xsl:param name="line-separator" as="item()*"/>

    <xsl:for-each select="t:split-lines($value)">
      <xsl:analyze-string regex="[^\w_]" flags="m" select=".">
        <xsl:matching-substring>
          <xsl:sequence select="."/>
        </xsl:matching-substring>
        <xsl:non-matching-substring>
          <xsl:sequence select="."/>
        </xsl:non-matching-substring>
      </xsl:analyze-string>

      <xsl:if test="position() != last()">
        <xsl:sequence select="$line-separator"/>
      </xsl:if>
    </xsl:for-each>
  </xsl:function>

  <!--
    Splits string into lines.
      $value - a value to split into lines.
      Returns sequence of lines.
  -->
  <xsl:function name="t:split-lines" as="xs:string*">
    <xsl:param name="value" as="xs:string?"/>

    <xsl:sequence select="tokenize($value, '\r\n|\n\r|\n|\r', 'm')"/>
  </xsl:function>

  <!--
    Joins adjacent string items.
     $items - items to join.
     Returns joined items.
  -->
  <xsl:function name="t:string-join" as="item()*">
    <xsl:param name="items" as="item()*"/>

    <xsl:variable name="indices" as="xs:integer*" select="
      0,
      index-of
      (
        (
          for $item in $items return
            $item instance of xs:string
        ),
        false()
      ),
      count($items) + 1"/>

    <xsl:sequence select="
      for 
        $i in 1 to count($indices) - 1,
        $s in $indices[$i], 
        $e in $indices[$i + 1]
      return
      (
        $items[$s],
        string-join(subsequence($items, $s + 1, $e - $s - 1), '')
      )"/>
  </xsl:function>

</xsl:stylesheet>
