<?xml version="1.0" encoding="utf-8"?>
<!-- This stylesheet serializes xml as ASPX. -->
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:aspx="http://www.bphx.com/aspx/2010-06-20"
  xmlns:t="http://www.bphx.com/aspx/this"
  xmlns:p="http://www.bphx.com/aspx/private"
  exclude-result-prefixes="xs t p aspx">

  <!-- A line size. -->
  <xsl:param name="line-size" as="xs:string" select="'80'"/>

  <!-- A line size. -->
  <xsl:param name="p:line-size" as="xs:integer"
    select="xs:integer($line-size)"/>

  <!--
    Serializes nodes as ASPX.
      $nodes - nodes to serializes.
      $omit-xml-declaration - true to omit xml declaration, and
        false (default) to issue.
      $doctype-name - a DOCTYPE name.
      $doctype-public - a DOCTYPE PUBLIC .
      $doctype-system - a DOCTYPE SYSTEM.
      $encoding - an encoding in xml declaration.
      $standalone - true to issue standalone parameter in xml declaration, and
        false to omit.
      $version - xml version.
      $indent - true to indent output, and false otherwise.
      $indent-chars - indentation value.
  -->
  <xsl:template name="t:serialize" as="xs:string*">
    <xsl:param name="nodes" as="node()*"/>
    <xsl:param name="omit-xml-declaration" as="xs:boolean?" select="false()"/>
    <xsl:param name="doctype-name" as="xs:string?"/>
    <xsl:param name="doctype-public" as="xs:string?"/>
    <xsl:param name="doctype-system" as="xs:string?"/>
    <xsl:param name="encoding" as="xs:string?" select="'utf-8'"/>
    <xsl:param name="standalone" as="xs:boolean?"/>
    <xsl:param name="version" as="xs:string?" select="'1.0'"/>
    <xsl:param name="indent" as="xs:boolean?" select="true()"/>
    <xsl:param name="indent-chars" as="xs:string?" select="'  '"/>

    <xsl:if test="not($omit-xml-declaration = true())">
      <xsl:sequence select="'&lt;?xml version=&quot;'"/>
      <xsl:sequence select="($version, '1.0')[1]"/>
      <xsl:sequence select="'&quot;'"/>

      <xsl:if test="$encoding">
        <xsl:sequence select="' encoding=&quot;'"/>
        <xsl:sequence select="$encoding"/>
        <xsl:sequence select="'&quot;'"/>
      </xsl:if>

      <xsl:if test="exists($standalone)">
        <xsl:sequence select="' standalone=&quot;'"/>

        <xsl:sequence select="
          if ($standalone) then
            'yes'
          else
            'no'"/>

        <xsl:sequence select="'&quot;'"/>
      </xsl:if>

      <xsl:sequence select="'?>'"/>
      <xsl:sequence select="$p:new-line"/>
    </xsl:if>

    <xsl:if test="$doctype-name or $doctype-public or $doctype-system">
      <xsl:sequence select="'&lt;!DOCTYPE '"/>
      <xsl:sequence select="($doctype-name, 'html')[1]"/>

      <xsl:choose>
        <xsl:when test="$doctype-public">
          <xsl:sequence select="' PUBLIC '"/>
          <xsl:sequence select="$doctype-public"/>
          <xsl:sequence select="' '"/>
          <xsl:sequence select="$doctype-system"/>
        </xsl:when>
        <xsl:when test="$doctype-system">
          <xsl:sequence select="' SYSTEM '"/>
          <xsl:sequence select="$doctype-system"/>
        </xsl:when>
      </xsl:choose>

      <xsl:sequence select="'>'"/>
      <xsl:sequence select="$p:new-line"/>
    </xsl:if>

    <xsl:call-template name="p:serialize-content">
      <xsl:with-param name="indent" tunnel="yes" select="$indent"/>
      <xsl:with-param name="indent-chars" tunnel="yes" select="$indent-chars"/>
      <xsl:with-param name="current-indent" tunnel="yes" select="''"/>
      <xsl:with-param name="preserve-content-whitespace" select="false()"/>
      <xsl:with-param name="content" select="p:filter-content($nodes)"/>
    </xsl:call-template>
  </xsl:template>

  <!-- A new line. -->
  <xsl:variable name="p:new-line" as="xs:string" select="'&#13;&#10;'"/>

  <!-- An ASPX namespace. -->
  <xsl:variable name="aspx-namespace" as="xs:string"
    select="namespace-uri-from-QName(xs:QName('aspx:content'))"/>

  <!--
    Serializes a node as ASPX.
  -->
  <xsl:template mode="p:serialize" match="attribute()">
    <xsl:sequence select="error(xs:QName('unsupported-node'))"/>
  </xsl:template>

  <!--
    Serializes a node as ASPX.
  -->
  <xsl:template mode="p:serialize" match="aspx:*"/>

  <!--
    Serializes a node as ASPX.
  -->
  <xsl:template mode="p:serialize" match="document-node()">
    <xsl:call-template name="p:serialize-content">
      <xsl:with-param name="preserve-content-whitespace" select="false()"/>
      <xsl:with-param name="content" select="p:filter-content(node())"/>
    </xsl:call-template>
  </xsl:template>

  <!--
    Serializes a node as ASPX.
      $indent - true to indent output, and false otherwise.
      $indent-chars - indentation value.
      $current-indent - current indentation.
      $preserve-whitespace - true to preserve whitespace.
  -->
  <xsl:template mode="p:serialize" match="text()">
    <xsl:param name="indent" tunnel="yes" as="xs:boolean?"/>
    <xsl:param name="indent-chars" tunnel="yes" as="xs:string?"/>
    <xsl:param name="current-indent" tunnel="yes" as="xs:string?"/>
    <xsl:param name="preserve-whitespace" tunnel="yes" as="xs:boolean?"/>

    <xsl:choose>
      <xsl:when test="$preserve-whitespace">
        <xsl:sequence select="p:escape-text(.)"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:for-each select="p:split-lines(p:trim(.))">
          <xsl:if test="position() > 1">
            <xsl:sequence select="$p:new-line"/>
            <xsl:sequence select="$current-indent"/>
          </xsl:if>

          <xsl:sequence select="p:escape-text(.)"/>
        </xsl:for-each>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!--
    Serializes a node as ASPX.
      $indent - true to indent output, and false otherwise.
      $indent-chars - indentation value.
      $current-indent - current indentation.
  -->
  <xsl:template mode="p:serialize" match="comment()">
    <xsl:param name="indent" tunnel="yes" as="xs:boolean?"/>
    <xsl:param name="indent-chars" tunnel="yes" as="xs:string?"/>
    <xsl:param name="current-indent" tunnel="yes" as="xs:string?"/>

    <xsl:sequence select="'&lt;!--'"/>
    <xsl:sequence select="$p:new-line"/>
    <xsl:sequence select="."/>
    <xsl:sequence select="$p:new-line"/>
    <xsl:sequence select="'--&gt;'"/>
  </xsl:template>

  <!--
    Serializes a node as ASPX.
  -->
  <xsl:template mode="p:serialize" match="processing-instruction()">
    <xsl:sequence select="'&lt;?'"/>
    <xsl:sequence select="name()"/>
    <xsl:sequence select="' '"/>
    <xsl:sequence select="."/>
    <xsl:sequence select="'?>'"/>
  </xsl:template>

  <!--
    Serializes a node as ASPX.
      $indent - true to indent output, and false otherwise.
      $indent-chars - indentation value.
      $current-indent - current indentation.
      $preserve-whitespace - true to preserve whitespace.
  -->
  <xsl:template mode="p:serialize" match="element()">
    <xsl:param name="indent" tunnel="yes" as="xs:boolean?"/>
    <xsl:param name="indent-chars" tunnel="yes" as="xs:string?"/>
    <xsl:param name="current-indent" tunnel="yes" as="xs:string?"/>
    <xsl:param name="preserve-whitespace" tunnel="yes" as="xs:boolean?"/>

    <xsl:variable name="element" as="element()" select="."/>
    <xsl:variable name="name" as="xs:string" select="name()"/>

    <xsl:variable name="preserve-content-whitespace" as="xs:boolean" select="
      ($preserve-whitespace = true()) or
      ((@xml:space, @aspx:space)[1] = 'preserve')"/>

    <xsl:variable name="aspx-prefixes" as="element()*"
      select="ancestor-or-self::node()/aspx:declared-prefix"/>

    <xsl:variable name="in-scope-prefixes" as="xs:string*"
      select="in-scope-prefixes(.)"/>

    <xsl:variable name="declared-prefixes" as="xs:string*" select="
      $in-scope-prefixes
      [
        not(. = ('xml', 'xmlns')) and
        (
          $element/.. or
          not
          (
            namespace-uri-for-prefix(., $element/..) =
              namespace-uri-for-prefix(., $element)
          )
        ) and
        not($aspx-namespace = namespace-uri-for-prefix(., $element)) and
        not
        (
          some $aspx-prefix in $aspx-prefixes satisfies
            (string($aspx-prefix/@prefix) = .) and
            (
              string($aspx-prefix/@namespace) =
                string(namespace-uri-for-prefix(., $element))
            )
        )
      ]"/>

    <xsl:variable name="content" as="node()*"
      select="p:filter-content(node())"/>
    <xsl:variable name="has-content" as="xs:boolean"
      select="exists($content[not(self::text()[matches(., '^\s+$')])])"/>

    <xsl:variable name="aspx-attributes" as="element()*"
      select="aspx:attribute"/>

    <xsl:variable name="literal-attributes" as="attribute()*" select="
      (@* except @aspx:*)
      [
        not(node-name(.) = $aspx-attributes/resolve-QName(@name, .))
      ]"/>

    <xsl:variable name="content-indent" as="xs:string?" select="
      if ($indent = false()) then
        ''
      else
        concat($current-indent, $indent-chars)"/>

    <xsl:variable name="tag-attributes" as="xs:string*">
      <xsl:for-each select="$declared-prefixes">
        <xsl:variable name="parts" as="xs:string*">
          <xsl:sequence select="'xmlns'"/>

          <xsl:if test=".">
            <xsl:sequence select="':'"/>
            <xsl:sequence select="."/>
          </xsl:if>

          <xsl:sequence select="'=&quot;'"/>

          <xsl:sequence select="
            p:escape-attribute
            (
              namespace-uri-for-prefix(., $element),
              true()
            )"/>

          <xsl:sequence select="'&quot;'"/>
        </xsl:variable>

        <xsl:sequence select="string-join($parts, '')"/>
      </xsl:for-each>

      <xsl:for-each select="$literal-attributes">
        <xsl:variable name="parts" as="xs:string*">
          <xsl:sequence select="name()"/>
          <xsl:sequence select="'=&quot;'"/>
          <xsl:sequence select="p:escape-attribute(., true())"/>
          <xsl:sequence select="'&quot;'"/>
        </xsl:variable>

        <xsl:sequence select="string-join($parts, '')"/>
      </xsl:for-each>

      <xsl:for-each-group select="$aspx-attributes"
        group-by="resolve-QName(@name, .)">
        <xsl:variable name="attribute" as="element()"
          select="current-group()[last()]"/>
        <xsl:variable name="name" as="xs:QName"
          select="current-grouping-key()"/>
        <xsl:variable name="attribute-content" as="node()*"
          select="p:filter-literal-content($attribute/node())"/>

        <xsl:if test="
          prefix-from-QName($name) and
          (
            not(string(prefix-from-QName($name)) = $in-scope-prefixes) or
            not
            (
              namespace-uri-from-QName($name) =
                namespace-uri-for-prefix(prefix-from-QName($name), $element)
            )
          )">
          <xsl:sequence select="
            error(xs:QName('undeclared-prefix-in-attribute'), string($name))"/>
        </xsl:if>

        <xsl:variable name="parts" as="xs:string*">
          <xsl:variable name="escape-quotes" as="xs:boolean"
            select="true() (: exists($attribute-content[self::text()]) :)"/>

          <xsl:sequence select="string($name)"/>
          <xsl:sequence select="'='"/>

          <xsl:sequence select="
            if ($escape-quotes) then
              '&quot;'
            else
              ''''"/>

          <xsl:for-each select="$attribute-content">
            <xsl:choose>
              <xsl:when test="self::text()">
                <xsl:sequence select="p:escape-attribute(., $escape-quotes)"/>
              </xsl:when>
              <xsl:otherwise>
                <xsl:apply-templates mode="#current" select=".">
                  <xsl:with-param name="in-attribute" select="true()"/>
                  <xsl:with-param name="escape-quotes"
                   select="$escape-quotes"/>
                </xsl:apply-templates>
              </xsl:otherwise>
            </xsl:choose>
          </xsl:for-each>

          <xsl:sequence select="
            if ($escape-quotes) then
              '&quot;'
            else
              ''''"/>
        </xsl:variable>

        <xsl:sequence select="string-join($parts, '')"/>
      </xsl:for-each-group>
    </xsl:variable>

    <xsl:variable name="multiline-attributes" as="xs:boolean" select="
      (count($tag-attributes) > 3) or
      (
        some $attribute in $tag-attributes satisfies
          matches($attribute, '[\n\r]')
      ) or
      (
        sum
        (
          for $attribute in $tag-attributes return
            (string-length($attribute) + 1)
        ) + string-length($name) + string-length($indent-chars) + 2 >
          $p:line-size
      )"/>

    <xsl:sequence select="'&lt;'"/>
    <xsl:sequence select="$name"/>

    <xsl:for-each select="$tag-attributes">
      <xsl:choose>
        <xsl:when test="
          not($indent = false()) and
          $multiline-attributes and
          (
            (position() > 1) or
            (
              string-length($tag-attributes[1]) +
                string-length($name) + string-length($indent-chars) + 3 >
                $p:line-size
            )
          )">
          <xsl:sequence select="$p:new-line"/>
          <xsl:sequence select="$current-indent"/>
          <xsl:sequence select="$indent-chars"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:sequence select="' '"/>
        </xsl:otherwise>
      </xsl:choose>

      <xsl:sequence select="."/>
    </xsl:for-each>

    <xsl:choose>
      <xsl:when test="$has-content">
        <xsl:sequence select="'>'"/>

        <xsl:choose>
          <xsl:when
            test="(count($content) = 1) and $content[self::aspx:content]">
            <xsl:apply-templates mode="#current" select="$content">
              <xsl:with-param name="current-indent" tunnel="yes"
                select="$content-indent"/>
              <xsl:with-param name="preserve-whitespace" tunnel="yes"
                select="$preserve-content-whitespace"/>
            </xsl:apply-templates>
          </xsl:when>
          <xsl:otherwise>
            <xsl:variable name="insert-new-lines" as="xs:boolean" select="
              not($preserve-content-whitespace) and
              (count(p:filter-literal-content($content)) = 0)"/>

            <xsl:for-each select="$content">
              <xsl:variable name="index" as="xs:integer" select="position()"/>

              <xsl:if test="$insert-new-lines">
                <xsl:sequence select="$p:new-line"/>
                <xsl:sequence select="$content-indent"/>
              </xsl:if>

              <xsl:apply-templates mode="#current" select=".">
                <xsl:with-param name="current-indent" tunnel="yes"
                  select="$content-indent"/>
                <xsl:with-param name="preserve-whitespace" tunnel="yes"
                  select="$preserve-content-whitespace"/>
              </xsl:apply-templates>
            </xsl:for-each>

            <xsl:if test="$insert-new-lines">
              <xsl:sequence select="$p:new-line"/>
              <xsl:sequence select="$current-indent"/>
            </xsl:if>
          </xsl:otherwise>
        </xsl:choose>

        <xsl:sequence select="'&lt;/'"/>
        <xsl:sequence select="$name"/>
        <xsl:sequence select="'>'"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:sequence select="'/>'"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!--
    Serializes a node as ASPX.
      $indent - true to indent output, and false otherwise.
      $indent-chars - indentation value.
      $current-indent - current indentation.
      $preserve-whitespace - true to preserve whitespace.
      $preserve-content-whitespace - true to preserve whitespace
        of the content, and false otherwise.
      $content - a content to serialize.
  -->
  <xsl:template name="p:serialize-content" mode="p:serialize"
    match="aspx:content">
    <xsl:param name="indent" tunnel="yes" as="xs:boolean?"/>
    <xsl:param name="indent-chars" tunnel="yes" as="xs:string?"/>
    <xsl:param name="current-indent" tunnel="yes" as="xs:string?"/>
    <xsl:param name="preserve-whitespace" tunnel="yes" as="xs:boolean?"/>

    <xsl:param name="preserve-content-whitespace" as="xs:boolean" select="
      ($preserve-whitespace = true()) or
      ((@xml:space, @aspx:space)[1] = 'preserve')"/>

    <xsl:param name="content" as="node()*" select="p:filter-content(node())"/>

    <xsl:variable name="insert-new-lines" as="xs:boolean" select="
      not($preserve-content-whitespace) and
      (count(p:filter-literal-content($content)) = 0)"/>

    <xsl:for-each select="$content">
      <xsl:if test="$insert-new-lines and (position() > 1)">
        <xsl:sequence select="$p:new-line"/>
        <xsl:sequence select="$current-indent"/>
      </xsl:if>

      <xsl:apply-templates mode="p:serialize" select=".">
        <xsl:with-param name="current-indent" tunnel="yes"
          select="$current-indent"/>
        <xsl:with-param name="preserve-whitespace" tunnel="yes"
          select="$preserve-content-whitespace"/>
      </xsl:apply-templates>
    </xsl:for-each>

    <xsl:if test="$insert-new-lines and (count($content) > 1)">
      <xsl:sequence select="$p:new-line"/>
      <xsl:sequence select="$current-indent"/>
    </xsl:if>
  </xsl:template>

  <!--
    Serializes a node as ASPX.
      $indent - true to indent output, and false otherwise.
      $indent-chars - indentation value.
      $current-indent - current indentation.
      $preserve-whitespace - true to preserve whitespace.
  -->
  <xsl:template mode="p:serialize" match="aspx:directive">
    <xsl:param name="indent" tunnel="yes" as="xs:boolean?"/>
    <xsl:param name="indent-chars" tunnel="yes" as="xs:string?"/>
    <xsl:param name="current-indent" tunnel="yes" as="xs:string?"/>
    <xsl:param name="preserve-whitespace" tunnel="yes" as="xs:boolean?"/>

    <xsl:variable name="name" as="xs:string" select="@name"/>
    <xsl:variable name="attributes" as="attribute()*"
      select="@* except (@name, @aspx:*)"/>

    <xsl:variable name="tag-attributes" as="xs:string*">
      <xsl:for-each select="$attributes">
        <xsl:variable name="parts" as="xs:string*">
          <xsl:sequence select="name()"/>
          <xsl:sequence select="'=&quot;'"/>
          <xsl:sequence select="p:escape-attribute(., true())"/>
          <xsl:sequence select="'&quot;'"/>
        </xsl:variable>

        <xsl:sequence select="string-join($parts, '')"/>
      </xsl:for-each>
    </xsl:variable>

    <xsl:variable name="multiline-attributes" as="xs:boolean" select="
      (count($tag-attributes) > 3) or
      (
        some $attribute in $tag-attributes satisfies
          matches($attribute, '[\r\n]')
      )"/>

    <xsl:if test="not($preserve-whitespace)">
      <xsl:sequence select="$current-indent"/>
    </xsl:if>

    <xsl:sequence select="'&lt;%@'"/>
    <xsl:sequence select="$name"/>

    <xsl:for-each select="$tag-attributes">
      <xsl:choose>
        <xsl:when test="
          not($indent = false()) and
          $multiline-attributes and
          (position() > 1)">
          <xsl:sequence select="$p:new-line"/>
          <xsl:sequence select="$current-indent"/>
          <xsl:sequence select="$indent-chars"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:sequence select="' '"/>
        </xsl:otherwise>
      </xsl:choose>

      <xsl:sequence select="."/>
    </xsl:for-each>

    <xsl:sequence select="'%>'"/>
  </xsl:template>

  <!--
    Serializes a node as ASPX.
  -->
  <xsl:template mode="p:serialize" match="aspx:entity">
    <xsl:variable name="value" as="xs:string" select="@value"/>

    <xsl:sequence select="'&amp;'"/>
    <xsl:sequence select="$value"/>
    <xsl:sequence select="';'"/>
  </xsl:template>

  <!--
    Serializes a node as ASPX.
      $indent - true to indent output, and false otherwise.
      $indent-chars - indentation value.
      $current-indent - current indentation.
      $in-attribute - true when expression is part of attribute, and
        false otherwise.
      $escape-quotes - true to escape quotes in attributes, and
        false to escape apostrophes.
  -->
  <xsl:template mode="p:serialize" match="aspx:expression">
    <xsl:param name="indent" tunnel="yes" as="xs:boolean?"/>
    <xsl:param name="indent-chars" tunnel="yes" as="xs:string?"/>
    <xsl:param name="current-indent" tunnel="yes" as="xs:string?"/>
    <xsl:param name="in-attribute" as="xs:boolean?"/>
    <xsl:param name="escape-quotes" as="xs:boolean" select="true()"/>

    <xsl:variable name="type" as="xs:string" select="@type"/>
    <xsl:variable name="content" as="node()*"
      select="node()[self::text() or self::aspx:entity]"/>
    <xsl:variable name="comment" as="xs:boolean"
      select="not($in-attribute) and ($type = 'comment')"/>

    <xsl:sequence select="'&lt;%'"/>

    <xsl:sequence select="
      if ($type = 'data-binding') then
        '# '
      else if ($type = 'encoded-data-binding') then
        ': '
      else if ($type = 'declarative-expression') then
        '$ '
      else if ($type = 'output-expression') then
        '= '
      else if ($type = 'output-statement') then
        ' '
      else if ($type = 'comment') then
        '--'
      else
        error(xs:QName('invalid-expression-type'))"/>

    <xsl:for-each select="$content">
      <xsl:choose>
        <xsl:when test="self::text()">
          <xsl:choose>
            <xsl:when test="$in-attribute">
              <xsl:sequence select="
                p:escape-expression(p:escape-attribute(., $escape-quotes))"/>
            </xsl:when>
            <xsl:when test="$comment">
              <xsl:variable name="lines" as="xs:string*"
                select="p:split-lines(p:trim(.))"/>

              <xsl:choose>
                <xsl:when test="count($lines) > 1">
                  <xsl:for-each select="p:split-lines(p:trim(.))">
                    <xsl:sequence select="$p:new-line"/>
                    <xsl:sequence select="$current-indent"/>
                    <xsl:sequence select="$indent-chars"/>
                    <xsl:sequence
                      select="p:escape-expression(p:escape-text(.))"/>
                  </xsl:for-each>

                  <xsl:sequence select="$p:new-line"/>
                  <xsl:sequence select="$current-indent"/>
                </xsl:when>
                <xsl:otherwise>
                  <xsl:sequence select="' '"/>
                  <xsl:sequence
                    select="p:escape-expression(p:escape-text($lines))"/>
                  <xsl:sequence select="' '"/>
                </xsl:otherwise>
              </xsl:choose>
            </xsl:when>
            <xsl:otherwise>
              <xsl:sequence select="p:escape-expression(p:escape-text(.))"/>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:when>
        <xsl:otherwise>
          <xsl:apply-templates mode="#current" select="."/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:for-each>

    <xsl:sequence select="
      if ($type = 'comment') then
        '--'
      else
        ' '"/>

    <xsl:sequence select="'%>'"/>
  </xsl:template>

  <!--
    Filters content.
      $content - a content to filter.
      Returns filtered content.
  -->
  <xsl:function name="p:filter-content" as="node()*">
    <xsl:param name="content" as="node()*"/>

    <xsl:sequence select="
      $content
      [
        not
        (
          self::aspx:attribute or
          self::aspx:declared-prefix or
          self::aspx:meta
        )
      ]"/>
  </xsl:function>

  <!--
    Filters literal content.
      $content - a content to filter.
      Returns filtered content.
  -->
  <xsl:function name="p:filter-literal-content" as="node()*">
    <xsl:param name="content" as="node()*"/>

    <xsl:sequence select="
      $content
      [
        self::text()[not(matches(., '^\s+$'))] or
        self::aspx:expression[not(@type = 'comment')] or
        self::aspx:entity
      ]"/>
  </xsl:function>

  <!--
    Escapes xml text.
      $value - a text to escape.
      Return escaped text.
  -->
  <xsl:function name="p:escape-text" as="xs:string">
    <xsl:param name="value" as="xs:string?"/>

    <xsl:sequence select="
      replace(replace($value, '&amp;', '&amp;amp;'), '&lt;', '&amp;lt;')"/>
  </xsl:function>

  <!--
    Escapes xml attribute.
      $value - a text to escape.
      $escape-quotes - true to escape quotes, and false to escape apostrophes.
      Return escaped text.
  -->
  <xsl:function name="p:escape-attribute" as="xs:string">
    <xsl:param name="value" as="xs:string?"/>
    <xsl:param name="escape-quotes" as="xs:boolean"/>

    <xsl:sequence select="
      for $text in p:escape-text($value) return
        if ($escape-quotes) then
          replace($text, '&quot;', '&amp;quot;')
        else
          replace($text, '''', '&amp;apos;')"/>
  </xsl:function>

  <!--
    Escapes ASPX expression.
      $value - a text to escape.
      Return escaped text.
  -->
  <xsl:function name="p:escape-expression" as="xs:string">
    <xsl:param name="value" as="xs:string?"/>

    <xsl:sequence select="
      replace
      (
        $value,
        '%&gt;',
        '%&amp;gt;'
      )"/>
  </xsl:function>

  <!--
    Splits string into lines.
      $values - a value to split into lines.
      Returns sequence of lines.
  -->
  <xsl:function name="p:split-lines" as="xs:string*">
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
  <xsl:function name="p:left-trim" as="xs:string?">
    <xsl:param name="value" as="xs:string?"/>

    <xsl:sequence select="replace($value, '^\s+', '')"/>
  </xsl:function>

  <!--
    Removes trailing unimportant whitespace characters from the string.
      $value - a value to trim.
      Returns a value with trailing unimportant whitespace characters removed.
      If $value is empty sequence then result is empty sequence.
  -->
  <xsl:function name="p:right-trim" as="xs:string?">
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
  <xsl:function name="p:trim" as="xs:string?">
    <xsl:param name="value" as="xs:string?"/>

    <xsl:sequence select="replace($value, '^\s+|\s+$', '')"/>
  </xsl:function>

</xsl:stylesheet>