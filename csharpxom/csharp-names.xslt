<?xml version="1.0" encoding="utf-8"?>
<!--
  This stylesheet provides functions to generate valid C# identifiers.
-->
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:t="http://www.bphx.com/csharp"
  xmlns:p="http://www.bphx.com/csharp/private/csharp-names"
  xmlns="http://www.bphx.com/csharp-3.0/2009-05-23"
  xpath-default-namespace="http://www.bphx.com/csharp-3.0/2009-05-23"
  exclude-result-prefixes="xs t p">

  <!-- C# reserved keywords. -->
  <xsl:variable name="t:csharp-reserved-words" as="xs:string+" select="
    'abstract', 'as',       'base',       'bool',      'break',
    'byte',     'case',     'catch',      'char',      'checked',
    'class',    'const',    'continue',   'decimal',   'default',
    'delegate', 'do',       'double',     'else',      'enum',
    'event',    'explicit', 'extern',     'false',     'finally',
    'fixed',    'float',    'for',        'foreach',   'goto',
    'if',       'implicit', 'in',         'int',       'interface',
    'internal', 'is',       'lock',       'long',      'namespace',
    'new',      'null',     'object',     'operator',  'out',
    'override', 'params',   'private',    'protected', 'public',
    'readonly', 'ref',      'return',     'sbyte',     'sealed',
    'short',    'sizeof',   'stackalloc', 'static',    'string',
    'struct',   'switch',   'this',       'throw',     'true',
    'try',      'typeof',   'uint',       'ulong',     'unchecked',
    'unsafe',   'ushort',   'using',      'virtual',   'void',
    'volatile', 'while'"/>

  <!-- Extended reserved names. -->
  <xsl:variable name="t:reserved-names" as="xs:string*">
    <xsl:apply-templates mode="t:call" select="$t:reserved-names-handler"/>
  </xsl:variable>

  <!-- A total set of reserved words. -->
  <xsl:variable name="t:reserved-words" as="xs:string*"
    select="$t:csharp-reserved-words, $t:reserved-names"/>

  <!-- A handler to collect reserved names. -->
  <xsl:variable name="t:reserved-names-handler" as="element()">
    <t:reserved-names/>
  </xsl:variable>

  <!-- A default handler for the reserved names. -->
  <xsl:template mode="t:call" match="t:reserved-names"/>

  <!--
    Tests whether a specified value is a reserved word.
      $value - a value to test.
      Returns true if value is a reserved word, and false otherwise.
  -->
  <xsl:function name="t:is-reserved-word" as="xs:boolean">
    <xsl:param name="value" as="xs:string"/>

    <xsl:sequence select="exists(key('p:id', $value, $p:reserved-words))"/>
  </xsl:function>


  <!--
    Capitalizes a name.
    @value - a string to be capitalized.
    Returns a capitalized version of the string.
  -->
  <xsl:function name="t:capitalize" as="xs:string">
    <xsl:param name="value" as="xs:string?"/>

    <xsl:sequence select="
      concat
      (
        upper-case(substring($value, 1, 1)),
        substring($value, 2)
      )"/>
  </xsl:function>

  <!--
    Note: though this function is borrowed from java, nevertheless
    it works good in C# world.

    Utility function to take a string and convert it to normal Java variable
    name capitalization. This normally means converting the first
    character from upper case to lower case, but in the (unusual) special
    case when there is more than one character and both the first and
    second characters are upper case, we leave it alone.

    Thus "FooBah" becomes "fooBah" and "X" becomes "x", but "URL" stays
    as "URL".

    @value - a string to be decapitalized.
    Returns a decapitalized version of the string.
  -->
  <xsl:function name="t:decapitalize" as="xs:string">
    <xsl:param name="value" as="xs:string?"/>

    <xsl:variable name="c" as="xs:string"
      select="substring($value, 2, 1)"/>

    <xsl:sequence select="
      if ($c != lower-case($c)) then
        $value
      else
        concat
        (
          lower-case(substring($value, 1, 1)),
          substring($value, 2)
        )"/>
  </xsl:function>

  <!--
    Gets a C# name for a specified name components.
      $name - a name to generate C# name for.
      $default-name - a default name in case a name cannot be built.
      Returns C# name (upper case first).
  -->
  <xsl:function name="t:create-name" as="xs:string?">
    <xsl:param name="name" as="xs:string*"/>
    <xsl:param name="default-name" as="xs:string?"/>

    <xsl:variable name="components" as="xs:string*">
      <xsl:for-each select="$name">
        <xsl:analyze-string
          regex="[\p{{L}}\d]+"
          flags="imx"
          select=".">
          <xsl:matching-substring>
            <xsl:sequence select="upper-case(substring(., 1, 1))"/>
            <xsl:sequence select="lower-case(substring(., 2))"/>
          </xsl:matching-substring>
        </xsl:analyze-string>
      </xsl:for-each>
    </xsl:variable>

    <xsl:sequence select="
      if (empty($components)) then
        $default-name
      else
        string-join
        (
          (
            if ($components[1][(. le '9') and  (. ge '0')]) then
              (($default-name, 'N')[1], $components)
            else
              $components
          ),
          ''
        )"/>
  </xsl:function>

  <!--
    Allocates unique names in the form $prefix{number}?.
    Note: that prefixes may coincide.
    Note: that result names shall be different not only using case.
      $prefixes - a name prefixes.
      $names - allocated names pool.
      Returns unique names.
  -->
  <xsl:function name="t:allocate-names" as="xs:string*">
    <xsl:param name="prefixes" as="xs:string*"/>
    <xsl:param name="names" as="xs:string*"/>

    <xsl:variable name="count" as="xs:integer" select="count($prefixes)"/>

    <xsl:variable name="name-closures" as="item()*">
      <xsl:for-each select="$prefixes">
        <xsl:sequence select="position() * 2 - 1"/>
        <xsl:sequence select="."/>
      </xsl:for-each>

      <xsl:for-each select="$names">
        <xsl:sequence select="1 -($count + position()) * 2"/>
        <xsl:sequence select="."/>
      </xsl:for-each>
    </xsl:variable>

    <xsl:variable name="result-closures" as="item()*"
      select="p:allocate-names($name-closures)"/>

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
      Returns name closures with unique names.
  -->
  <xsl:function name="p:allocate-names" as="item()*">
    <xsl:param name="name-closures" as="item()*"/>

    <xsl:variable name="indices" as="xs:integer*"
      select="(1 to count($name-closures) - 1)[(position() mod 2) = 1]"/>

    <xsl:variable name="ordered-indices" as="xs:integer*">
      <xsl:perform-sort select="$indices">
        <xsl:sort select="
          for $index in . return
            upper-case($name-closures[$index + 1])"/>
      </xsl:perform-sort>
    </xsl:variable>

    <xsl:variable name="new-name-closures" as="item()*">
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

            <xsl:sequence select="
              if
              (
                ($name-closures[$prefix-group] lt 0) or
                not(t:is-reserved-word($name))
              )
              then
              (
                $prefix-group,
                $name
              )
              else
              (
                $prefix-group,
                p:compose-name($name, '1')
              )"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:variable name="prefix" as="xs:string" select="
              for $index in . return
                p:get-prefix($name-closures[$index + 1])"/>

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

              <xsl:variable name="name" as="xs:string" select="
                for
                  $i in .,
                  $index in $prefix-group[$i]
                return
                  $name-closures[$index + 1]"/>

              <xsl:sequence select="
                if ((count($group) = 1) and not(t:is-reserved-word($name))) then
                (
                  $prefix-group[$group],
                  $name
                )
                else
                  for
                    $index in $group,
                    $group-index in $prefix-group[$index]
                  return
                    if ($name-closures[$group-index] lt 0) then
                    (
                      $group-index,
                      $name
                    )
                    else
                    (
                      $group-index,
                      p:compose-name($prefix, xs:string($max-suffix + $index))
                    )"/>
            </xsl:for-each-group>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:for-each-group>
    </xsl:variable>

    <xsl:sequence select="
      for
        $index in $indices,
        $name-index in $new-name-closures[$index]
      return
      (
        -abs($name-closures[$name-index]),
        $new-name-closures[$index + 1]
      )"/>
  </xsl:function>

  <!--
    Composes a name in the form $prefix and $suffix.
      $prefix - a name prefix.
      $suffix - a suffix to test.
      Returns a name.
  -->
  <xsl:function name="p:compose-name" as="xs:string">
    <xsl:param name="prefix" as="xs:string"/>
    <xsl:param name="suffix" as="xs:string"/>

    <xsl:sequence select="concat($prefix, $suffix)"/>
  </xsl:function>

  <!--
    Gets a name without numeric suffix.
      $name - a name to get prefix for.
      Returns a name prefix.
  -->
  <xsl:function name="p:get-prefix" as="xs:string?">
    <xsl:param name="name" as="xs:string"/>

    <xsl:analyze-string select="$name" regex="\d+$">
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

</xsl:stylesheet>