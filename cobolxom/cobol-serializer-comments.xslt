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
    Gets comments for a scope.
      $scope - a scope to get comments for.
  -->
  <xsl:function name="t:get-comments" as="item()*">
    <xsl:param name="scope" as="element()"/>

    <xsl:sequence select="$scope/comment/t:get-comment(.)"/>
  </xsl:function>

  <!--
    Gets a sequence of tokens for a comment.
      $comment - a comment element.
      Returns a sequence of tokens.
  -->
  <xsl:function name="t:get-comment" as="item()+">
    <xsl:param name="comment" as="element()"/>

    <xsl:variable name="tokens" as="item()*">
      <xsl:call-template name="t:get-comment">
        <xsl:with-param name="scope" select="$comment"/>
      </xsl:call-template>
    </xsl:variable>

    <xsl:variable name="indent" as="xs:integer"
      select="($comment/@indent, 1)[1]"/>

    <xsl:variable name="count" as="xs:integer" select="count($tokens)"/>

    <xsl:variable name="lines" as="xs:integer+" select="
      0,
      index-of($tokens, $t:new-line),
      (
        if (exists(index-of($tokens[$count], $t:new-line))) then
         ()
        else
          $count + 1
      )"/>

    <xsl:for-each select="$lines">
      <xsl:if test="position() != last()">
        <xsl:variable name="index" as="xs:integer" select="position()"/>
        <xsl:variable name="position" as="xs:integer" select=". + 1"/>
        <xsl:variable name="next" as="xs:integer" select="$lines[$index + 1]"/>
        <xsl:variable name="line" as="item()*"
          select="subsequence($tokens, $position, $next - $position)"/>

        <xsl:sequence select="$t:comment"/>

        <xsl:sequence select="
          for
            $i in
              (1 to $indent)
              [
                $line[1][. instance of xs:string]
                (:[
                  not(matches(., '^[*+=-]{2,}'))
                ]:)
              ]
          return
            ' '"/>

        <xsl:sequence select="$line"/>
        <xsl:sequence select="$t:new-line"/>
      </xsl:if>
    </xsl:for-each>
  </xsl:function>

  <!-- Mode "t:comment". Default match. -->
  <xsl:template mode="t:comment" match="*">
    <xsl:call-template name="t:get-comment"/>
  </xsl:template>

  <!-- Mode "t:comment". text. -->
  <xsl:template mode="t:comment" match="text()"/>

  <!--
    Gets a sequence of comment tokens for a scope.
      $scope - a comment scope (by default it's a context element).
      $leader - a number of leading spaces to skip.
      Returns a sequence of tokens.
  -->
  <xsl:template name="t:get-comment" as="item()*">
    <xsl:param name="scope" as="element()" select="."/>
    <xsl:param name="leader" tunnel="yes" as="xs:integer?"/>

    <xsl:variable name="is-code" as="xs:boolean"
      select="exists($scope[self::code])"/>
    <xsl:variable name="content" as="node()*"
      select="$scope/(node() except (meta, comment))"/>

    <xsl:variable name="empty-content" as="xs:boolean" select="
      empty($content) or
      (
        empty($content[self::element()]) and
        (
          every $node in $content satisfies
            matches($node, '^\s*$')
        )
      )"/>

    <xsl:if test="not($empty-content)">
      <xsl:variable name="items" as="item()*">
        <xsl:for-each select="$content">
          <xsl:variable name="value" as="xs:string?"
            select="self::text()"/>

          <xsl:choose>
            <xsl:when test="$value">
              <xsl:if test="
                not
                (
                  $is-code and
                  (position() = 1) and
                  matches(., '^\s+$')
                )">

                <xsl:sequence select="t:tokenize($value)"/>
              </xsl:if>
            </xsl:when>
            <xsl:otherwise>
              <xsl:sequence select="."/>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:for-each>
      </xsl:variable>

      <xsl:variable name="line-ends" as="xs:integer*"
        select="index-of($items, $t:new-line)"/>

      <xsl:variable name="line-leader" as="xs:integer?" select="
        if ($leader or empty($line-ends)) then
          $leader
        else
          min
          (
            for $i in (0, $line-ends) return
              t:get-count-of-leading-spaces($items, $i + 1, 0)
          )"/>

      <xsl:variable name="fixed-items" as="item()*">
        <xsl:choose>
          <xsl:when test="$line-leader > 0">
            <xsl:sequence select="
              for $i in (0, $line-ends) return
                t:get-remove-leading-spaces
                (
                  $items,
                  $i + 1,
                  $line-leader,
                  ()
                )"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:sequence select="$items"/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:variable>

      <xsl:for-each select="$fixed-items">
        <xsl:variable name="index" as="xs:integer" select="position()"/>

        <xsl:choose>
          <xsl:when test=". instance of xs:string">
            <xsl:sequence select="."/>
          </xsl:when>
          <xsl:when test=". instance of xs:QName">
            <xsl:sequence select="."/>
          </xsl:when>
          <xsl:when test="$is-code">
            <xsl:variable name="tokens" as="item()*"
              select="t:get-tokens-for-element(.)"/>

            <xsl:choose>
              <xsl:when test="exists($tokens)">
                <xsl:sequence select="
                  for $line in t:get-lines($tokens) return
                    t:tokenize
                    (
                      substring($line, string-length($t:marker-indent))
                    )"/>
              </xsl:when>
              <xsl:otherwise>
                <xsl:apply-templates mode="t:comment" select=".">
                  <xsl:with-param name="leader" tunnel="yes"
                    select="$line-leader"/>
                </xsl:apply-templates>
              </xsl:otherwise>
            </xsl:choose>
          </xsl:when>
          <xsl:otherwise>
            <xsl:apply-templates mode="t:comment" select=".">
              <xsl:with-param name="leader" tunnel="yes"
                select="$line-leader"/>
            </xsl:apply-templates>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:for-each>
    </xsl:if>
  </xsl:template>

  <!--
    Calculate number of leading spaces in the line.
      $items - an items to scan.
      $index - current item index.
      $result - collected result.
      Returns number of leading spaces in a line, if relevant.
  -->
  <xsl:function name="t:get-count-of-leading-spaces" as="xs:integer?">
    <xsl:param name="items" as="item()*"/>
    <xsl:param name="index" as="xs:integer"/>
    <xsl:param name="result" as="xs:integer"/>

    <xsl:variable name="item" as="item()?" select="$items[$index]"/>

    <xsl:choose>
      <xsl:when test="empty($item) or exists(index-of($item, $t:new-line))">
        <!-- Return empty sequence. -->
      </xsl:when>
      <xsl:when test="
        ($item instance of xs:string) and
        matches($item, '^\s+$')">
        <xsl:variable name="length" as="xs:integer" 
          select="string-length($item)"/>
        <xsl:variable name="next" as="xs:integer" select="$result + $length"/>

        <xsl:sequence
          select="t:get-count-of-leading-spaces($items, $index + 1, $next)"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:sequence select="$result"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:function>

  <!--
    Removes a specified number of leading spaces in the line.
      $items - an items to scan.
      $index - current item index.
      $leader - a number of leading spaces to remove.
      $result - collected result.
      Returns corrected line.
  -->
  <xsl:function name="t:get-remove-leading-spaces" as="item()*">
    <xsl:param name="items" as="item()*"/>
    <xsl:param name="index" as="xs:integer"/>
    <xsl:param name="leader" as="xs:integer?"/>
    <xsl:param name="result" as="item()*"/>

    <xsl:variable name="item" as="item()?" select="$items[$index]"/>

    <xsl:choose>
      <xsl:when test="empty($item)">
        <xsl:sequence select="$result"/>
      </xsl:when>
      <xsl:when test="exists(index-of($item, $t:new-line))">
        <xsl:sequence select="$result, $t:new-line"/>
      </xsl:when>
      <xsl:when test="
        $leader and
        ($item instance of xs:string) and
        matches($item, '^\s+$')">
        <xsl:variable name="next-leader" as="xs:integer"
          select="$leader - string-length($item)"/>

        <xsl:choose>
          <xsl:when test="$next-leader >= 0">
            <xsl:sequence select="
              t:get-remove-leading-spaces
              (
                $items,
                $index + 1,
                $next-leader,
                $result
              )"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:variable name="next" as="item()+"
              select="$result, substring($item, $leader)"/>

            <xsl:sequence select="
              t:get-remove-leading-spaces($items, $index + 1, (), $next)"/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:when>
      <xsl:otherwise>
        <xsl:variable name="next" as="item()+" select="$result, $item"/>

        <xsl:sequence
          select="t:get-remove-leading-spaces($items, $index + 1, (), $next)"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:function>

</xsl:stylesheet>