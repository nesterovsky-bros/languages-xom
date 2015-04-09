<?xml version="1.0" encoding="utf-8"?>
<!--
  This stylesheet streams a sequence of tokens into text.
-->
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:t="http://www.bphx.com/cobol"
  xmlns="http://www.bphx.com/cobol/2009-12-15"
  xpath-default-namespace="http://www.bphx.com/cobol/2009-12-15"
  exclude-result-prefixes="xs t">

  <!-- New line text. -->
  <xsl:param name="t:new-line-text" as="xs:string" select="'&#13;&#10;'"/>

  <!-- A line marker indentation. -->
  <xsl:param name="t:marker-indent" as="xs:string" select="'      '"/>

  <!-- A default indentation step. -->
  <xsl:param name="t:default-indent" as="xs:string" select="'  '"/>

  <!-- Indentation for a continuation line. -->
  <xsl:param name="t:continuation-indent" as="xs:string" select="'    '"/>

  <!-- A default indentation step. -->
  <xsl:param name="t:max-indent-level" as="xs:integer" select="14"/>

  <!-- Preferrable number of characters per line. -->
  <xsl:param name="t:chars-per-line" as="xs:integer" select="64"/>

  <!-- Indent control word. -->
  <xsl:variable name="t:indent" as="xs:QName" select="xs:QName('t:indent')"/>

  <!-- Unindent control word. -->
  <xsl:variable name="t:unindent" as="xs:QName"
    select="xs:QName('t:unindent')"/>

  <!-- Resets indentation for one line. -->
  <xsl:variable name="t:line-indent" as="xs:QName"
    select="xs:QName('t:line-indent')"/>

  <!-- Generates a line without line wrapping. -->
  <xsl:variable name="t:noformat" as="xs:QName"
    select="xs:QName('t:noformat')"/>

  <!-- New line control word. -->
  <xsl:variable name="t:new-line" as="xs:QName"
    select="xs:QName('t:new-line')"/>

  <!-- A line break hint. -->
  <xsl:variable name="t:soft-line-break" as="xs:QName"
    select="xs:QName('t:soft-line-break')"/>

  <!--
    Terminator control word.
    When a line is to long, it's split into parts separated with terminator.
  -->
  <xsl:variable name="t:terminator" as="xs:QName"
    select="xs:QName('t:terminator')"/>

  <!-- Regular line control word. -->
  <xsl:variable name="t:code" as="xs:QName" select="xs:QName('t:code')"/>

  <!-- Comment line control word. -->
  <xsl:variable name="t:comment" as="xs:QName" select="xs:QName('t:comment')"/>

  <!--
    Gets sequence of lines from sequence of tokens and control words.
      $tokens - input sequence of tokens.
      Returns a sequence of line strings.
  -->
  <xsl:function name="t:get-lines" as="xs:string*">
    <xsl:param name="tokens" as="item()*"/>

    <xsl:sequence
      select="t:get-lines($tokens, index-of($tokens, $t:new-line), 0, 0, ())"/>
  </xsl:function>

  <!--
    Gets sequence of lines from sequence of tokens and control words.
      $tokens - input sequence of tokens.
      $line-breaks - a sequence of line breaks.
      $line-index - an index of current line (zero based).
      $indent - current indentation.
      $result - collected result.
      Returns a sequence of line strings.
  -->
  <xsl:function name="t:get-lines" as="xs:string*">
    <xsl:param name="tokens" as="item()*"/>
    <xsl:param name="line-breaks" as="xs:integer*"/>
    <xsl:param name="line-index" as="xs:integer"/>
    <xsl:param name="indent" as="xs:integer"/>
    <xsl:param name="result" as="xs:string*"/>

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

    <xsl:sequence select="
      if (empty($line-break) and empty($line[. instance of xs:string])) then
        $result
      else
        t:get-lines
        (
          $tokens,
          $line-breaks,
          $line-index + 1,
          $indent + t:get-indentation($line),
          ($result, t:format-line($line, $indent))
        )"/>
  </xsl:function>

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

    <xsl:sequence select="
      count(index-of($tokens, $t:indent)) -
        count(index-of($tokens, $t:unindent))"/>
  </xsl:function>

  <!--
    Gets an indentation for a specified element type.
      $indent - an element type.
      $type - optional indentation type.
      Returns indentation text.
  -->
  <xsl:function name="t:get-indentation" as="xs:string?">
    <xsl:param name="indent" as="xs:integer"/>
    <xsl:param name="type" as="xs:string?"/>

    <xsl:sequence select="
      string-join
      (
        (
          for $i in 1 to min(($indent, $t:max-indent-level)) return
            $t:default-indent
        ),
        ''
      )"/>
  </xsl:function>

  <!--
    Formats a line.
      $tokens - input sequence of tokens.
      $indent - current level of indentation.
      Returns formatted line as sequence of strings.
  -->
  <xsl:function name="t:format-line" as="xs:string*">
    <xsl:param name="tokens" as="item()*"/>
    <xsl:param name="indent" as="xs:integer"/>

    <xsl:variable name="literals" as="xs:string*"
      select="$tokens[not(. instance of xs:QName)]"/>

    <xsl:variable name="control-tokens" as="xs:QName*" select="
      if (exists($literals)) then
        subsequence
        (
          $tokens,
          1,
          (
            for $i in 1 to count($tokens) return
              if ($tokens[$i] instance of xs:QName) then
                ()
              else
                $i - 1
          )[1]
        )
      else
        $tokens"/>

    <xsl:variable name="indent-value" as="xs:integer">
      <xsl:variable name="line-indent" as="xs:integer?"
        select="index-of($control-tokens, $t:line-indent)[last()]"/>

      <xsl:choose>
        <xsl:when test="exists($line-indent)">
          <xsl:variable name="next-tokens" as="xs:QName*"
            select="subsequence($control-tokens, $line-indent + 1)"/>

          <xsl:sequence select="count(index-of($next-tokens, $t:indent))"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:sequence select="
            $indent +
              count(index-of($control-tokens, $t:indent)) -
              count(index-of($control-tokens, $t:unindent))"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>

    <xsl:variable name="indentation" as="xs:string?"
      select="t:get-indentation($indent-value, $literals[1])"/>

    <xsl:variable name="type" as="xs:QName?" select="
      $control-tokens[. = ($t:noformat, $t:code, $t:comment)][last()]"/>

    <xsl:choose>
      <xsl:when test="$type = $t:noformat">
        <xsl:sequence select="
          string-join
          (
            ($t:marker-indent, ' ', $literals, $t:new-line-text),
            ''
          )"/>
      </xsl:when>
      <xsl:when test="empty($type) or ($type = $t:code)">
        <!-- Code line. -->
        <xsl:variable name="line" as="xs:string"
          select="t:right-trim(string-join(($indentation, $literals), ''))"/>

        <xsl:choose>
          <xsl:when test="$t:chars-per-line >= string-length($line)">
            <xsl:sequence select="
              if ($line) then
                concat
                (
                  $t:marker-indent,
                  ' ',
                  $line,
                  $t:new-line-text
                )
              else
                $t:new-line-text"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:variable name="reformatted-tokens" as="item()*" select="
              t:reformat-tokens
              (
                $tokens,
                2,
                (),
                $t:new-line,
                false(),
                true()
              )"/>

            <xsl:choose>
              <xsl:when test="t:is-multiline($reformatted-tokens)">
                <xsl:sequence select="
                  t:get-lines
                  (
                    $reformatted-tokens,
                    index-of($reformatted-tokens, $t:new-line),
                    0,
                    $indent,
                    ()
                  )"/>
              </xsl:when>
              <xsl:otherwise>
                <xsl:sequence select="
                  t:format-long-code-line
                  (
                    $indentation,
                    $reformatted-tokens,
                    true(),
                    false(),
                    ()
                  )"/>
              </xsl:otherwise>
            </xsl:choose>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:when>
      <xsl:when test="$type = $t:comment">
        <!-- Comment line. -->
        <xsl:sequence select="t:format-comment($literals, ())"/>
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
    Formats a long regular line.
      $indentation - an indentation string.
      $tokens - a line tokens.
      $leader - true indicate leader line.
      $continuation - true in case of token continuation, and
        false otherwise.
      $result - collected result.
      Returns formatted lines.
  -->
  <xsl:function name="t:format-long-code-line" as="xs:string*">
    <xsl:param name="indentation" as="xs:string?"/>
    <xsl:param name="tokens" as="item()*"/>
    <xsl:param name="leader" as="xs:boolean"/>
    <xsl:param name="continuation" as="xs:boolean"/>
    <xsl:param name="result" as="xs:string*"/>

    <xsl:variable name="line-width" as="xs:integer" select="
      if ($continuation) then
        $t:chars-per-line - string-length($t:continuation-indent)
      else
        $t:chars-per-line - string-length($indentation)"/>

    <xsl:variable name="breaker" as="xs:integer?"
      select="t:get-breaker($tokens, $line-width, 1, (), ())"/>

    <xsl:if test="exists($breaker)">
      <xsl:variable name="previous-tokens" as="item()*"
        select="subsequence($tokens, 1, $breaker)"/>

      <xsl:variable name="previous-string-tokens" as="xs:string*" select="
        $previous-tokens[. instance of xs:string]
        [
          $leader or
          (position() gt 1) or
          not(matches(., '^\s+$'))
        ]"/>

      <xsl:variable name="last-string-token" as="xs:string?"
        select="$previous-string-tokens[last()]"/>

      <xsl:variable name="string-continuation" as="xs:string?">
        <xsl:if test="$last-string-token">
          <xsl:analyze-string regex="^[HNGZ]?X?(['&quot;])" flags="i"
            select="$last-string-token">
            <xsl:matching-substring>
              <xsl:sequence select="regex-group(1)"/>
            </xsl:matching-substring>
          </xsl:analyze-string>
        </xsl:if>
      </xsl:variable>
      
      <xsl:variable name="previous-line-before-last" as="xs:string" select="
        string-join($previous-string-tokens[position() lt last()], '')"/>

      <xsl:variable name="previous-line" as="xs:string" select="
        if 
        (
          exists($string-continuation) and
          (
            string-length($previous-line-before-last) + 
              string-length($last-string-token) = 
              $line-width + 1
          )
        )
        then
          concat($previous-line-before-last, ' ', $last-string-token)
        else
          t:right-trim(concat($previous-line-before-last, $last-string-token))"/>
                    
      <xsl:variable name="line" as="xs:string"
        select="t:right-trim(substring($previous-line, 1, $line-width))"/>
      <xsl:variable name="line-continuation" as="xs:string"
        select="t:right-trim(substring($previous-line, $line-width + 1))"/>
      <xsl:variable name="next-continuation" as="xs:boolean"
        select="boolean($line-continuation)"/>

      <xsl:variable name="next-tokens" as="item()*" select="
        (
          if ($next-continuation) then
            concat($string-continuation, $line-continuation)
          else
            ()
        ),
        subsequence($tokens, $breaker + 1)"/>

      <xsl:variable name="next-indentation" as="xs:string?" select="
        if ($leader and $line) then
          concat($indentation, $t:default-indent)
        else
          $indentation"/>

      <xsl:variable name="next-result" as="xs:string*" select="
        if ($line) then
        (
          $result,
          string-join
          (
            (
              $t:marker-indent,
              (
                if ($continuation) then
                  ('-', $t:continuation-indent)
                else
                  (' ', $indentation)
              ),
              $line,
              $t:new-line-text
            ),
            ''
          )
        )
        else
          $result"/>

      <xsl:sequence select="
        if (empty($next-tokens)) then
          $next-result
        else
          t:format-long-code-line
          (
            $next-indentation,
            $next-tokens,
            $leader and not($line),
            $next-continuation,
            $next-result
          )"/>
    </xsl:if>
  </xsl:function>

  <!--
    Gets a position of code line breaker.
      $values - a sequence of tokens.
      $width - available width of total sequence of tokens.
      $index - current index.
      $breaker-index - a breaker index.
      $breaker-priority - a braker priority.
      Returns a position of code line breaker.
  -->
  <xsl:function name="t:get-breaker" as="xs:integer?">
    <xsl:param name="values" as="item()*"/>
    <xsl:param name="width" as="xs:integer"/>
    <xsl:param name="index" as="xs:integer"/>
    <xsl:param name="breaker-index" as="xs:integer?"/>
    <xsl:param name="breaker-priority" as="xs:integer?"/>

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
      <xsl:when test="$value instance of xs:string">
        <xsl:choose>
          <xsl:when test="$width - string-length($value) lt 0">
            <xsl:sequence select="
              if (exists($breaker-index)) then
                $breaker-index
              else if ($index > 1) then
                $index - 1
              else
                1"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:sequence select="
              t:get-breaker
              (
                $values,
                $width - string-length($value),
                $index + 1,
                (
                  if($breaker-priority gt 1) then
                    $breaker-index
                  else
                    $index
                ),
                max(($breaker-priority, 1))
              )"/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:when>
      <xsl:when test="$value = $t:soft-line-break">
        <xsl:sequence select="
          t:get-breaker
          (
            $values,
            $width,
            $index + 1,
            $index,
            2
          )"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:sequence select="
          t:get-breaker
          (
            $values,
            $width,
            $index + 1,
            $breaker-index,
            $breaker-priority
          )"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:function>

  <!--
    Formats comment line.
      $prefix - comment prefix.
      $literals - literal tokens.
      $preferrable-width - preferrable width.
      $result - collected result.
      Return comment lines.
  -->
  <xsl:function name="t:format-comment" as="xs:string*">
    <xsl:param name="literals" as="xs:string*"/>
    <xsl:param name="result" as="xs:string*"/>

    <xsl:variable name="line-width" as="xs:integer"
      select="$t:chars-per-line"/>

    <xsl:variable name="breaker" as="xs:integer?"
      select="t:get-comment-breaker($literals, $line-width, 1)"/>

    <xsl:if test="exists($breaker)">
      <xsl:variable name="previous-literals" as="xs:string*"
        select="subsequence($literals, 1, $breaker)"/>
      <xsl:variable name="previous-line" as="xs:string"
        select="string-join($previous-literals[. instance of xs:string], '')"/>
      <xsl:variable name="line" as="xs:string"
        select="substring($previous-line, 1, $line-width)"/>
      <xsl:variable name="line-continuation" as="xs:string" select="
        t:right-trim(substring($previous-line, $line-width + 1))"/>
      
      <xsl:variable name="next-literals-base" as="xs:string*" select="
        (
          if ($line-continuation) then
            $line-continuation
          else
            ()
        ),
        subsequence($literals, $breaker + 1)"/>

      <xsl:variable name="next-literals" as="xs:string*" select="
        ' '
        [
          exists($next-literals-base) and
          starts-with($literals[1], ' ') and
          not(starts-with($next-literals-base[1], ' ')) and
          (string-length($next-literals-base[1]) + 1 lt $line-width)
        ],
        $next-literals-base"/>

      <xsl:variable name="next-result" as="xs:string*" select="
        $result,
        concat
        (
          $t:marker-indent,
          '*',
          $line,
          $t:new-line-text
        )"/>

      <xsl:sequence select="
        if (empty($next-literals)) then
          $next-result
        else
          t:format-comment($next-literals, $next-result)"/>
    </xsl:if>
  </xsl:function>

  <!--
    Gets a position of comment line breaker.
      $values - a sequence of values.
      $width - available width of total sequence of tokens.
      $index - current index.
      Returns a position of comment line breaker.
  -->
  <xsl:function name="t:get-comment-breaker" as="xs:integer?">
    <xsl:param name="values" as="xs:string*"/>
    <xsl:param name="width" as="xs:integer"/>
    <xsl:param name="index" as="xs:integer"/>

    <xsl:variable name="value" as="xs:string?" select="$values[$index]"/>

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
          <xsl:when
            test="($value = ('.', ',', '!', '&quot;', '''')) and ($index > 2)">
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
          <xsl:when test="
            exists($token) and
            empty(index-of(($t:indent, '{'), $token))">
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
      Returns formatted tokens.
  -->
  <xsl:function name="t:reformat-tokens" as="item()*">
    <xsl:param name="tokens" as="item()*"/>
    <xsl:param name="verbose-threshold" as="xs:integer?"/>
    <xsl:param name="separator" as="item()*"/>
    <xsl:param name="verbose-separator" as="item()*"/>
    <xsl:param name="put-separator-at-the-end" as="xs:boolean?"/>
    <xsl:param name="indent-from-second-line" as="xs:boolean?"/>

    <xsl:variable name="length" as="xs:integer" select="count($tokens)"/>

    <xsl:variable name="terminators" as="xs:integer*" select="
      0,
      index-of($tokens, $t:terminator),
      (
        for $token in $tokens[$length] return
          if (($token instance of xs:QName) and ($token = $t:terminator)) then
            ()
          else
            $length + 1
      )"/>

    <xsl:variable name="count" as="xs:integer"
      select="count($terminators) - 1"/>
    <xsl:variable name="verbose" as="xs:boolean" select="
      ($count >= $verbose-threshold) or t:is-multiline($tokens)"/>

    <xsl:if test="$verbose and not($indent-from-second-line)">
      <xsl:sequence select="$verbose-separator"/>

      <xsl:if test="exists($verbose-separator)">
        <xsl:sequence select="$t:indent"/>
      </xsl:if>
    </xsl:if>

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
        else if ($verbose) then
          $verbose-separator
        else
          $separator
      )"/>

    <xsl:sequence select="
      if ($indent-from-second-line) then
        t:indent-from-second-line($formatted-tokens)
      else
      (
        $formatted-tokens,
        (
          if ($verbose and exists($verbose-separator)) then
            $t:unindent
          else
            ()
        )
      )"/>
  </xsl:function>

  <!--
    Splits string into tokens.
      $value - a value to split into tokens.
      Returns tokens sequence.
  -->
  <xsl:function name="t:tokenize" as="item()*">
    <xsl:param name="value" as="xs:string*"/>

    <xsl:sequence select="t:tokenize($value, $t:new-line)"/>
  </xsl:function>

  <!--
    Splits string into tokens.
      $value - a value to split into tokens.
      $line-separator - defines a line separator.
      Returns tokens sequence.
  -->
  <xsl:function name="t:tokenize" as="item()*">
    <xsl:param name="value" as="xs:string*"/>
    <xsl:param name="line-separator" as="item()*"/>

    <xsl:for-each select="t:split-lines($value)">
      <xsl:analyze-string regex="[!|@#$^&amp;.*=\\/]{{5,}}|\W" flags="m"
        select=".">
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
      $values - a value to split into lines.
      Returns sequence of lines.
  -->
  <xsl:function name="t:split-lines" as="xs:string*">
    <xsl:param name="values" as="xs:string*"/>

    <xsl:sequence select="
      for $value in $values return
        tokenize($value, '\r\n|\n\r|\n|\r|&#133;', 'm')"/>
  </xsl:function>

  <!--
    Removes leading unimportant whitespace characters from the string.
      $value - a value to trim.
      Returns a value with leading unimportant whitespace characters removed.
      If $value is empty sequence then result is empty sequence.
  -->
  <xsl:function name="t:left-trim" as="xs:string?">
    <xsl:param name="value" as="xs:string?"/>

    <xsl:sequence select="replace($value, '^\s+', '')"/>
  </xsl:function>

  <!--
    Removes trailing unimportant whitespace characters from the string.
      $value - a value to trim.
      Returns a value with trailing unimportant whitespace characters removed.
      If $value is empty sequence then result is empty sequence.
  -->
  <xsl:function name="t:right-trim" as="xs:string?">
    <xsl:param name="value" as="xs:string?"/>

    <xsl:sequence select="replace($value, '\s+$', '')"/>
  </xsl:function>

  <!--
    Removes leading and trailing unimportant whitespace
    characters from the string.
      $value - a value to trim.
      Returns a value with leading and trailing unimportant whitespace
      characters removed. If $value is empty sequence then result
      is empty sequence.
  -->
  <xsl:function name="t:trim" as="xs:string?">
    <xsl:param name="value" as="xs:string?"/>

    <xsl:sequence select="replace($value, '^\s+|\s+$', '')"/>
  </xsl:function>

</xsl:stylesheet>