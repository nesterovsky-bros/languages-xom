<?xml version="1.0" encoding="utf-8"?>
<!--
  This stylesheet serializes ecmascript comments.
 -->
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns="http://www.nesterovsky-bros.com/ecmascript6/2015-02-20"
  xmlns:t="http://www.nesterovsky-bros.com/ecmascript"
  xpath-default-namespace="http://www.nesterovsky-bros.com/ecmascript6/2015-02-20"
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

    <xsl:variable name="doc" as="xs:boolean?" select="$comment/@doc"/>

    <xsl:variable name="tokens" as="item()*">
      <xsl:call-template name="t:get-comment">
        <xsl:with-param name="scope" select="$comment"/>
        <xsl:with-param name="process-content-only" select="true()"/>
        <xsl:with-param name="doc" tunnel="yes" select="$doc"/>
      </xsl:call-template>
    </xsl:variable>

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

        <xsl:choose>
          <xsl:when test="$doc">
            <xsl:sequence select="$t:doc"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:sequence select="$t:comment"/>
          </xsl:otherwise>
        </xsl:choose>

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
    Gets a sequence of comment tokens for.
      $scope - a comment scope (by default it's a context element).
      $process-content-only - true to process content only, and
        false to process $scope element itself.
      $doc - true for the documentation comment, and false
        for the regular comment.
      $leader - a number of leading spaces to skip.
      Returns a sequence of tokens.
  -->
  <xsl:template name="t:get-comment" as="item()*">
    <xsl:param name="scope" as="element()" select="."/>
    <xsl:param name="process-content-only" as="xs:boolean" select="false()"/>
    <xsl:param name="doc" tunnel="yes" as="xs:boolean?"/>
    <xsl:param name="leader" tunnel="yes" as="xs:integer?"/>

    <xsl:variable name="is-code" as="xs:boolean"
      select="exists($scope[self::code])"/>

    <xsl:variable name="content" as="node()*"
      select="$scope/(node() except (meta, comment))"/>

    <xsl:variable name="attributes" as="attribute()*" select="$scope/@*"/>

    <xsl:variable name="empty-content" as="xs:boolean" select="
      empty($content) or
      empty($content[self::element()]) and
      (
        every $node in $content satisfies
          matches($node, '^\s*$')
      )"/>

    <xsl:if test="not($process-content-only)">
      <xsl:choose>
        <xsl:when test="
          empty($attributes) and
          $empty-content">
          <xsl:sequence select="concat('&lt;', local-name($scope), '/>')"/>
        </xsl:when>
        <xsl:when test="empty($attributes)">
          <xsl:sequence select="concat('&lt;', local-name($scope), '>')"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:sequence select="concat('&lt;', local-name($scope))"/>

          <xsl:for-each select="$attributes">
            <xsl:sequence select="' '"/>
            <xsl:sequence select="
              concat(local-name(), '=&quot;', t:escape-xml(.), '&quot;')"/>
          </xsl:for-each>

          <xsl:choose>
            <xsl:when test="empty($content)">
              <xsl:sequence select="'/>'"/>
            </xsl:when>
            <xsl:otherwise>
              <xsl:sequence select="'>'"/>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:otherwise>
      </xsl:choose>

      <xsl:if test="$is-code and not($empty-content)">
        <xsl:sequence select="$t:new-line"/>
      </xsl:if>
    </xsl:if>

    <xsl:if test="not($empty-content)">
      <xsl:variable name="items" as="item()*">
        <xsl:for-each select="$content">
          <xsl:choose>
            <xsl:when test="self::text()">
              <xsl:if test="
                not
                (
                  $is-code and
                  (position() = 1) and
                  matches(., '^\s+$')
                )">
                <xsl:sequence select="t:tokenize(.)"/>
              </xsl:if>
            </xsl:when>
            <xsl:otherwise>
              <xsl:sequence select="."/>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:for-each>
      </xsl:variable>

      <xsl:variable name="line-leader" as="xs:integer?" select="
        if (exists($leader)) then
          $leader
        else
          max
          (
            for $i in (0, index-of($items, $t:new-line)) return
              t:get-count-of-leading-spaces($items, $i + 1, ())
          )"/>

      <xsl:variable name="fixed-items" as="item()*">
        <xsl:choose>
          <xsl:when test="$line-leader > 0">
            <xsl:sequence select="
              for $i in (0, index-of($items, $t:new-line)) return
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
            <xsl:sequence select="
              if ($doc) then
                t:escape-xml(.)
              else
                ."/>
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
                      if ($doc) then
                        t:escape-xml($line)
                      else
                        $line
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

      <xsl:if test="not($process-content-only)">
        <xsl:sequence select="concat('&lt;/', local-name($scope), '>')"/>
      </xsl:if>
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
    <xsl:param name="result" as="xs:integer?"/>

    <xsl:variable name="item" as="item()?" select="$items[$index]"/>

    <xsl:choose>
      <xsl:when test="empty($item) or exists(index-of($item, $t:new-line))">
        <!-- Return empty sequence. -->
      </xsl:when>
      <xsl:when test="
        ($item instance of xs:string) and
        matches($item, '^\s+$')">
        <xsl:variable name="length" as="xs:integer" select="string-length($item)"/>

        <xsl:variable name="next" as="xs:integer" select="
          if (exists($result)) then
            $result + $length
          else
            $length"/>

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

  <!--
    Escapes xml characters.
      $value - a to escape
      Returns escaped value.
  -->
  <xsl:function name="t:escape-xml" as="xs:string">
    <xsl:param name="value" as="xs:string?"/>

    <xsl:sequence select="
      replace
      (
        replace
        (
          replace($value, '&amp;', '&amp;amp;', 'm'),
          '&quot;',
          '&amp;quot;',
          'm'
        ),
        '&lt;',
        '&amp;lt;',
        'm'
      )"/>
  </xsl:function>

</xsl:stylesheet>