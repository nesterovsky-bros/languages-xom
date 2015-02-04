<?xml version="1.0" encoding="utf-8"?>
<!--
  This stylesheet provides functions resolve identifier namesto normalize
  qualified data names.

  $Id$
-->
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:t="http://www.bphx.com/cobol"
  xmlns:p="http://www.bphx.com/cobol/private/cobol-qualified-name-normalizer"
  xmlns="http://www.bphx.com/cobol/2009-12-15"
  xpath-default-namespace="http://www.bphx.com/cobol/2009-12-15"
  exclude-result-prefixes="xs t p">

  <!--
    We implement the following algorithm.
    Suppose there is a qualified name in the form:
      A OF B OF C OF D;

    Before the fallback to the original qualified name we shall try:
      A;
      A OF D;
      A OF C OF D;

    If data-ref contains attribute anchor="true" then that data ref
    is not removed.
  -->

  <!--
    A key to get data element by name.
  -->
  <xsl:key name="t:data-content" match="
    data | data-rename | data-condition | file-description | sort-description"
    use="xs:string(@name)"/>

  <!--
    Normalizes a data-ref element eliminating levels of qualification.
      $scope - a scope element.
      $value - a data-ref element to normalize.
      Returns normalized data-ref.
  -->
  <xsl:function name="t:normalize-data-ref" as="element()">
    <xsl:param name="scope" as="element()"/>
    <xsl:param name="value" as="element()"/>

    <xsl:variable name="match-set" as="element()*"
      select="key('t:data-content', $value/@name, $scope)"/>

    <xsl:choose>
      <xsl:when test="empty($match-set)">
        <xsl:sequence select="$value"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:variable name="names" as="element()+" select="
          $value/
          (
            descendant-or-self::data-ref |
            descendant-or-self::condition-ref |
            descendant-or-self::file-ref
          )"/>

        <xsl:variable name="count" as="xs:integer" select="count($names)"/>

        <xsl:variable name="unique" as="xs:integer?" select="
          reverse(2 to $count)
          [
            p:is-unique(p:filter-names($names, .), 2, $match-set)
          ][1]"/>

        <xsl:choose>
          <xsl:when test="($count = 1) or empty($unique)">
            <xsl:sequence select="$value"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:variable name="filtered-names" as="element()+"
              select="p:filter-names($names, $unique[1])"/>

            <xsl:sequence select="
              p:compose-names($filtered-names, count($filtered-names), ())"/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:function>

  <!--
    Normalizes data-refs in a scope.
      $scope - a scope for the normalization.
      Returns normalized scope.
  -->
  <xsl:function name="t:normalize-data-refs" as="element()">
    <xsl:param name="scope" as="element()"/>

    <xsl:apply-templates mode="p:normalize-data-refs" select="$scope">
      <xsl:with-param name="scope" tunnel="yes" select="$scope"/>
    </xsl:apply-templates>
  </xsl:function>

  <!--
    Tests whether the name is unique.
      $names - names list.
      $index - a current index.
      $match-set - a name match set.
  -->
  <xsl:function name="p:is-unique" as="xs:boolean">
    <xsl:param name="names" as="element()+"/>
    <xsl:param name="index" as="xs:integer"/>
    <xsl:param name="match-set" as="element()+"/>

    <xsl:variable name="name" as="xs:string?" select="$names[$index]/@name"/>

    <xsl:variable name="next-match-set" as="element()*" select="
      for $item in $match-set return
        $item/
        (
          ancestor::data |
          ancestor::data-rename |
          ancestor::file-description |
          ancestor::sort-description
        )[@name = $name]"/>

    <xsl:sequence select="
      if (empty($name)) then
        count($match-set) = 1
      else if (empty($next-match-set)) then
        false()
      else
        p:is-unique($names, $index + 1, $next-match-set)"/>
  </xsl:function>

  <!--
    Filters names according with cut index.
      $names - a names to filter.
      $index - a cut index.
      Returns filtered names.
  -->
  <xsl:function name="p:filter-names" as="element()+">
    <xsl:param name="names" as="element()+"/>
    <xsl:param name="index" as="xs:integer"/>

    <xsl:sequence select="
      for $i in 1 to count($names) return
        $names[$i]
        [
          ($i > $index) or
          ($i = 1) or
          xs:boolean(@anchor) or
          self::file-description or
          self::sort-description
       ]"/>
  </xsl:function>

  <!--
    Composes names.
      $names - names to compose.
      $index - current index.
      $result - a collected result.
      Return composed names.
  -->
  <xsl:function name="p:compose-names" as="element()">
    <xsl:param name="names" as="element()+"/>
    <xsl:param name="index" as="xs:integer"/>
    <xsl:param name="result" as="element()?"/>

    <xsl:variable name="name" as="element()?" select="$names[$index]"/>

    <xsl:choose>
      <xsl:when test="empty($name)">
        <xsl:sequence select="$result"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:variable name="next-result" as="element()">
          <xsl:for-each select="$name">
            <xsl:copy>
              <xsl:sequence select="@*"/>
              <xsl:sequence select="comment | meta"/>
              <xsl:sequence select="$result"/>
            </xsl:copy>
          </xsl:for-each>
        </xsl:variable>

        <xsl:sequence
          select="p:compose-names($names, $index - 1, $next-result)"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:function>

  <!--
    Normalizes data-refs in the scope.
  -->
  <xsl:template mode="p:normalize-data-refs" match="text()">
    <xsl:sequence select="."/>
  </xsl:template>

  <!--
    Normalizes data-refs in the scope. Default template.
  -->
  <xsl:template mode="p:normalize-data-refs" match="*">
    <xsl:copy>
      <xsl:sequence select="@*"/>
      <xsl:apply-templates mode="#current"/>
    </xsl:copy>
  </xsl:template>

  <!--
    Normalizes data-refs in the scope. Default template.
      $scope - a normalization scope.
  -->
  <xsl:template mode="p:normalize-data-refs" match="data-ref | condition-ref">
    <xsl:param name="scope" tunnel="yes" as="element()"/>

    <xsl:sequence select="t:normalize-data-ref($scope, .)"/>
  </xsl:template>

</xsl:stylesheet>