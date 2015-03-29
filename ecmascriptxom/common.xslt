<?xml version="1.0" encoding="utf-8"?>
<!--
  This stylesheet provides common functions used during serialization.
-->
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns="http://www.nesterovsky-bros.com/ecmascript6/2015-02-20"
  xmlns:t="http://www.nesterovsky-bros.com/ecmascript"
  xpath-default-namespace="http://www.nesterovsky-bros.com/ecmascript6/2015-02-20"
  exclude-result-prefixes="xs t">

  <!--
    Key to get element infos.
  -->
  <xsl:key name="t:name" match="*" use="xs:string(@name)"/>

  <!--
    Tokenizes a value, where split is a space.
      $value - a value to tokenize.
      Returns a sequence of tokens.
  -->
  <xsl:function name="t:tokenize" as="xs:string+">
    <xsl:param name="value" as="xs:string"/>

    <xsl:sequence select="tokenize($value, '\s+')"/>
  </xsl:function>
  
  <!--
    Gets content elements except comments and meta information
      $element - an element to get content element for.
      Returns content elements.
  -->
  <xsl:function name="t:get-elements" as="element()*">
    <xsl:param name="element" as="element()"/>

    <xsl:sequence select="$element/(* except (comment, meta))"/>
  </xsl:function>

  <!--
    Get elements in a scope.
      $scope - a scope to get elements from comments and meta are not counted.
      Returns elements in a scope.
  -->
  <xsl:function name="t:get-scope-elements" as="element()*">
    <xsl:param name="scope" as="element()*"/>

    <xsl:sequence select="t:get-scope-elements($scope, false())"/>
  </xsl:function>

  <!--
    Get elements in a scope.
      $scope - a scope to get elements from
      $include-comments-and-meta - true to include comments and meta, and
        false otherwise.
      Returns elements in a scope.
  -->
  <xsl:function name="t:get-scope-elements" as="element()*">
    <xsl:param name="scope" as="element()*"/>
    <xsl:param name="include-comments-and-meta" as="xs:boolean"/>

    <xsl:sequence select="
      for $element in $scope/* return
        if ($element/self::scope)) then
          t:get-scope-elements($element, $include-comments-and-meta)
        else if ($include-comments-and-meta) 
          $element[not(self::comment or self::meta)]
        else
          $element"/>
  </xsl:function>

  <!--
    Gets statements that are children of a specified scope.
      $scope - a scope to get children statements for.
      Returns children statements in scope.
  -->
  <xsl:function name="t:get-scope-statements" as="element()*">
    <xsl:param name="scope" as="element()*"/>

    <xsl:apply-templates mode="t:get-children-statements"
      select="$scope"/>
  </xsl:function>

  <!--
    Mode "t:get-children-statements". Default match.
  -->
  <xsl:template mode="t:get-children-statements" match="*"/>

  <!--
    Mode "t:get-children-statements".
  -->
  <xsl:template mode="t:get-children-statements" match="
    script | 
    module |
    function | 
    generator-function |
    while | 
    do-while | 
    for | 
    for-in | 
    for-of | 
    with |
    if |
    switch |
    switch/case |
    try |
    try/catch">
    <xsl:apply-templates/>
  </xsl:template>

  <!--
    Mode "t:get-children-statements".
  -->
  <xsl:template mode="t:get-children-statements" match="
    scope |
    block | 
    label | 
    body | 
    switch/default |
    if/then |
    if/else |
    try/finally">
    <xsl:sequence select="t:get-elements(.)"/>
  </xsl:template>

  <!--
    Converts unsigned integer to a sequence of digits.
      $value - a value to convert.
      $base - a digit base. $base should be between 2 and 36.
      $result - collected result.
      Returns a sequence of digits.
  -->
  <xsl:function name="t:integer-to-digits" as="xs:integer+">
    <xsl:param name="value" as="xs:integer"/>
    <xsl:param name="base" as="xs:integer"/>
    <xsl:param name="result" as="xs:integer*"/>

    <xsl:sequence select="
      if ($value lt $base) then
        ($value, $result)
      else
        t:integer-to-digits($value idiv $base, ($value mod $base, $result))"/>
  </xsl:function>

  <!--
    Converts a sequence of digits into an integer.
      $digits - a sequence of digits.
      $base - a digit base. $base should be between 2 and 36.
      $index - current index.
      $result - collected result.
      Returns an integer.
  -->
  <xsl:function name="t:digits-to-integer" as="xs:integer">
    <xsl:param name="digits" as="xs:integer+"/>
    <xsl:param name="base" as="xs:integer"/>
    <xsl:param name="index" as="xs:integer"/>
    <xsl:param name="result" as="xs:integer"/>

    <xsl:variable name="digit" as="xs:integer?" select="$digits[$index]"/>

    <xsl:sequence select="
      if (empty($digit)) then
        $result
      else
        t:digits-to-integer
        (
          $digits, 
          $base, 
          $index + 1, 
          $result * $base + $digit
        )"/>
  </xsl:function>

  <!-- 
    Converts unsigned integer to a string using a specified base.
      $value - a value to convert.
      $base - a digit base. $base should be between 2 and 36.
      Returns a string value.
  -->
  <xsl:function name="t:integer-to-string" as="xs:string">
    <xsl:param name="value" as="xs:integer"/>
    <xsl:param name="base" as="xs:integer"/>

    <xsl:sequence select="
      string-join
      (
        (
          for $d in t:integer-to-digits($value, $base, ()) return
            substring('0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ', $d + 1, 1)
        ),
        ''
      )"/>
  </xsl:function>

  <!--
    Converts integer string value into integer.
      $value - a value to convert.
      $base - a digit base. $base should be between 2 and 36.
      Returns an integer value.
  -->
  <xsl:function name="t:string-to-integer" as="xs:integer">
    <xsl:param name="value" as="xs:string"/>
    <xsl:param name="base" as="xs:integer"/>

    <xsl:variable name="zero-point" as="xs:integer" 
      select="string-to-codepoints('0')"/>

    <xsl:sequence select="
      t:digits-to-integer
      (
        (for $p in string-to-codepoints($value) return $p - $zero-point),
        $base,
        1,
        0
      )"/>
  </xsl:function>

  <xsl:function name="t:escape-string" as="xs:string">
    <xsl:param name="value" as="xs:string"/>

    <xsl:sequence select="
      replace
      (
        replace
        (
          replace
          (
            replace
            (
              replace($value, '\', '\\'),
              '&quot;',
              '\&quot;'
            ),
            '&#9;',
            '\t'
          ),
          '&#10;',
          '\n'
        ),
        '&#13;',
        '\r'
      )"/>
  </xsl:function>

  <xsl:function name="t:unescape-string" as="xs:string">
    <xsl:param name="value" as="xs:string"/>

    <xsl:variable name="parts" as="xs:string+">
      <xsl:analyze-string regex="\[\&quot;tnr]" select="$value">
        <xsl:matching-substring>
          <xsl:sequence select="
            if (. = '\\') then
              '\'
            else if (. = '\&quot;') then
              '&quot;'
            else if (. = '\t') then
              '&#9;'
            else if (. = '\n') then
              '&#10;'
            else if (. = '\r') then
              '&#13;'
            else
              ."/>
        </xsl:matching-substring>
        <xsl:non-matching-substring>
          <xsl:sequence select="."/>
        </xsl:non-matching-substring>
      </xsl:analyze-string>
    </xsl:variable>

    <xsl:sequence select="string-join($parts, '')"/>
  </xsl:function>

</xsl:stylesheet>