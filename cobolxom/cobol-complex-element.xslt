<?xml version="1.0" encoding="utf-8"?>
<!--
  This stylesheet provides a refactoring functions for "complex" elements.
-->
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:t="http://www.bphx.com/cobol"
  xmlns:p="http://www.bphx.com/cobol/private/cobol-complex-element"
  xmlns="http://www.bphx.com/cobol/2009-12-15"
  xpath-default-namespace="http://www.bphx.com/cobol/2009-12-15"
  exclude-result-prefixes="xs t p">

  <!--
    1. This API is to refactor complex statements and expressions.
    To support this we recognize following patterns
    (see meta/complex in cobol.xsd):

    <snippet-statement>
      <meta>
        <complex>
          <data-division>
            ...
          </data-division>
          <scope-statement>
            ...
          </scope-statement>
        </complex>
      </meta>
    </snippet-statement>

    and

    <snippet-expression>
      <meta>
        <complex>
          <data-division>
            ...
          </data-division>
          <scope-statement>
            ...
          </scope-statement>
          <result>
            ...
          </result>
        </complex>
      </meta>
    </snippet-expression>

    In both cases content of element "complex" is transformed as following:
      "data-division" is merged into the program data division;
      "scope-statement" is elevated to a statement level.
      content of "result" is used instead of snippet-expression.

    During merge of "data-division" data element with the same 
    @name and @merge-id are subject of merge procedure. 
    Data from the same complex scope are not merged. xs:boolean(@sort) 
    controls whether to sort merged definitions.


    2. This API refactors an ESCAPE pseudo statement into a control flow.

    The following pseudo statement is introduced (ESCAPE label)
    (see meta/escape in cobol.xsd):

    <snippet-statement>
      <meta>
        <escape name="label" name-ref="label-id"/>
      </meta>
    </snippet-statement>

    The following construct is used to mark the scope:

    <scope-statement>
      <meta>
        <label name="label" name-id="label-id"/>
      </meta>

      ...
    </scope-statement>
    
    The following construct is used to mark a finally scope.
    
    <scope-statement>
      <meta>
        <finally/>
      </meta>

      ...
    </scope-statement>

    Logic is following.

    When "ESCAPE label" occurs, an escape condition is set:
      SET label of ESCAPE-LABEL TO TRUE

    Following statements are wrapped into checks unless it's marked 
    as a finally scope:
      IF EMPTY OF ESCAPE-LABEL THEN
        ...
      END-IF
      
    If ESCAPE is inside of PERFORM then it's "until" condition is adjusted:
      UNTIL condition or NOT EMPTY-EL OF ESCAPE-LABEL

    When escape point is reached, an escape condition is reset:
      IF LABEL OF ESCAPE-LABEL THEN
        SET EMPTY-EL OF ESCAPE-LABEL TO TRUE
      END-IF

    The refactoring may introduce variables into WORKING STORAGE SECTION:
      77 ESCAPE-LABEL PIC S(9).
        88 EMPTY-EL VALUE 0.
        88 LABEL1 VALUE 1.
        ...

    and counters for the refactored perform statements.
      77 COUNTER-xxx PIC S(9).
      
    and condition results for refactored conditions.
      77 CONDITION-xxx PIC S(9).

    3. This API supports section refactoring.

    The following construct is used to mark a block to refactor
    (see meta/block in cobol.xsd):

    <scope-statement>
      <meta>
        <block
          name="optional block name"
          priority="optional section priority"
          position="
            optional section relative position:
              default|top|bottom|above|below"
          position-priority="optional position priority"
          statement-count-threshold="optional integer">
          <section name="name" name-ref="name-id"/>
        </block>
      </meta>

      ...
    </scope-statement>

    4. This API supports section import.

    The following construct is recognized:

    <section-ref name="SECTION-NAME">
      <meta>
        <import-section/>
      </meta>
    </section-ref>

    An import section handler is called for section-ref elements
    with import-section. It should return a section and, optionally,
    a  data-division element. These elements are integrated into the program.

    Import handler is called the following way:

    <xsl:apply-templates mode="t:call" select="$import-section-handler">
      <xsl:with-param name="program" select="$program"/>
      <xsl:with-param name="section-ref" select="$section-ref"/>
    </xsl:apply-templates>

    Tunnel parameters are passed to the handler.
  -->

  <!--
    Gets complex elements in a scope.
      $scope - a scope to inspect.
      Returns complex elements in a scope.
  -->
  <xsl:function name="t:get-complex-elements" as="element()*">
    <xsl:param name="scope" as="element()"/>

    <xsl:sequence select="
      $scope/
        (
          descendant-or-self::snippet-statement,
          descendant-or-self::snippet-expression
        )/meta/complex[not(ancestor::comment[. >> $scope])]"/>
  </xsl:function>

  <!--
    Gets complex expressions in a scope.
      $scope - scopes to inspect.
      Returns complex expressions in a scope.
  -->
  <xsl:function name="t:get-complex-expressions" as="element()*">
    <xsl:param name="scope" as="element()*"/>

    <xsl:sequence select="
      $scope/descendant-or-self::snippet-expression/meta/complex
      [
        not(ancestor::comment[every $item in $scope satisfies . >> $item])
      ]"/>
  </xsl:function>

  <!--
    Gets all escape pseudo statements in a scope.
      $scope - a scope to inspect.
      Return escape pseudo statements.
  -->
  <xsl:function name="t:get-escapes" as="element()*">
    <xsl:param name="scope" as="element()?"/>

    <xsl:sequence select="
      $scope//snippet-statement[not(ancestor::comment[. >> $scope])]/meta/
        escape[t:has-next-statement(.)]"/>
  </xsl:function>

  <!--
    Tests whether an escape is the last statement in the scope.
      $scope - a escape statement.
  -->
  <xsl:function name="t:has-next-statement" as="xs:boolean">
    <xsl:param name="escape" as="element()"/>

    <xsl:variable name="statement" as="element()"
      select="$escape/parent::meta/parent::snippet-statement"/>

    <xsl:variable name="scope" as="element()?" select="
      $statement/ancestor::*[t:get-statement-info(node-name(.))]
      [
        meta/label/@name-id = $escape/@name-ref
      ]"/>

    <xsl:if test="empty($scope)">
      <xsl:sequence select="
        error
        (
          xs:QName('no-label-is-found'),
          t:get-path($escape)
        )"/>
    </xsl:if>

    <xsl:sequence select="p:has-statement-after-escape($scope, $statement)"/>
  </xsl:function>

  <!--
    Gets all refactoring blocks in a scope.
      $scope - a scope to inspect.
      Return refactoring blocks.
  -->
  <xsl:function name="t:get-blocks" as="element()*">
    <xsl:param name="scope" as="element()*"/>

    <xsl:sequence select="
      $scope/descendant-or-self::scope-statement/meta/
        block
        [
          not(ancestor::comment[every $item in $scope satisfies . >> $item])
        ]"/>
  </xsl:function>

  <!--
    Gets escape pseudo statements from a specified scope.
      $scope - a scope to inspect.
      Return escape pseudo statements.
  -->
  <xsl:function name="t:get-escapes-from-scope" as="element()*">
    <xsl:param name="scope" as="element()?"/>

    <xsl:sequence select="
      t:get-escapes($scope)
      [
        xs:string(@name-ref) =
          $scope/ancestor-or-self::*[t:get-statement-info(node-name(.))]/
            meta/label/xs:string(@name-id)
      ]"/>
  </xsl:function>

  <!--
    Gets a section imports in a scope.
      $scope - a scope to inspect.
      Return section imports in a scope.
  -->
  <xsl:function name="t:get-section-refs-with-imports" as="element()*">
    <xsl:param name="scope" as="element()?"/>

    <xsl:sequence select="
      $scope/descendant-or-self::section-ref
      [
        meta/import-section and
        not(ancestor::comment[. >> $scope])
      ]"/>
  </xsl:function>

  <!--
    Normalizes complex elements.
      $program - a program to normalize.
      $section-import-handler - optional handler to resolve section imports.
      Return normalize program.
  -->
  <xsl:template name="t:normalize-complex-elements" as="element()">
    <xsl:param name="program" as="element()"/>
    <xsl:param name="section-import-handler" as="element()?"/>

    <xsl:variable name="section-imports" as="element()*"
      select="t:get-section-refs-with-imports($program)"/>
    <xsl:variable name="has-escapes" as="xs:boolean" 
      select="exists(t:get-escapes($program))"/>

    <xsl:choose>
      <xsl:when test="
        empty(t:get-complex-elements($program)) and
        not($has-escapes) and
        empty(t:get-blocks($program)) and
        empty($section-imports)">
        <xsl:sequence select="$program"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:variable name="procedure-division" as="element()?"
          select="$program/procedure-division"/>

        <xsl:variable name="imported-sections" as="element()*">
          <xsl:for-each-group select="
            $section-imports
            [
              ($procedure-division intersect ancestor::procedure-division) and
              not(@name = $procedure-division/section/@name)
            ]"
            group-by="xs:string(@name)">

            <xsl:variable name="name" as="xs:string?" select="@name"/>

            <xsl:variable name="closure" as="element()+">
              <xsl:apply-templates mode="t:call"
                select="$section-import-handler">
                <xsl:with-param name="program" select="$program"/>
                <xsl:with-param name="section-ref" select="."/>
              </xsl:apply-templates>
            </xsl:variable>

            <xsl:variable name="data-division" as="element()?"
              select="$closure/self::data-division"/>
            <xsl:variable name="section" as="element()"
              select="$closure/self::section[@name = $name]"/>

            <xsl:sequence select="$data-division"/>
            <xsl:sequence select="$section"/>
          </xsl:for-each-group>
        </xsl:variable>

        <program>
          <xsl:sequence select="$program/@*"/>
          <xsl:sequence
            select="$program/(comment | meta | environment-division)"/>

          <xsl:sequence select="
            p:get-merged-data-division
            (
              $program,
              $imported-sections/self::data-division
            )"/>

          <xsl:for-each select="$procedure-division">
            <xsl:copy>
              <xsl:sequence select="@*"/>
              <xsl:sequence select="comment | meta | using | returning"/>

              <xsl:for-each select="declarative">
                <xsl:copy>
                  <xsl:sequence select="@*"/>
                  <xsl:sequence select="comment | meta | use-statement"/>

                  <xsl:for-each select="section">
                    <xsl:copy>
                      <xsl:sequence select="@*"/>
                      <xsl:sequence select="comment | meta"/>

                      <xsl:variable name="paragraph" as="element()*"
                        select="paragraph"/>

                      <xsl:variable name="declarative-content" as="element()*">
                        <xsl:apply-templates
                          mode="p:normalize-procedure-division"
                          select="$paragraph"/>
                      </xsl:variable>

                      <xsl:sequence select="
                        if (t:get-blocks($paragraph)) then
                          p:refactor-sections($declarative-content)
                        else
                          $declarative-content"/>
                    </xsl:copy>
                  </xsl:for-each>
                </xsl:copy>
              </xsl:for-each>

              <xsl:variable name="section" as="element()*"
                select="section, $imported-sections/self::section"/>

              <xsl:variable name="content" as="element()*">
                <xsl:apply-templates mode="p:normalize-procedure-division"
                  select="$section"/>
              </xsl:variable>

              <xsl:if test="$has-escapes">
                <section>
                  <paragraph>
                    <!--
                      SET EMPTY-EL of ESCAPE-LABEL TO TRUE
                    -->
                    <set-statement escape="true">
                      <condition-ref name="EMPTY-EL">
                        <data-ref name="ESCAPE-LABEL"
                          name-ref="ESCAPE-{generate-id()}"/>
                      </condition-ref>
                    </set-statement>
                  </paragraph>
                </section>
              </xsl:if>

              <xsl:sequence select="
                if (t:get-blocks($section)) then
                  p:refactor-sections($content)
                else
                  $content"/>
            </xsl:copy>
          </xsl:for-each>

          <xsl:for-each select="$program/program">
            <xsl:call-template name="t:normalize-complex-elements">
              <xsl:with-param name="program" select="."/>
              <xsl:with-param name="section-import-handler"
                select="$section-import-handler"/>
            </xsl:call-template>
          </xsl:for-each>
        </program>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!--
    Gets merged data division for a specified program element.
      $program - a program element.
      $data-divisions - an additional list of data divisions to merge.
      Returns merged data division.
  -->
  <xsl:function name="p:get-merged-data-division" as="element()?">
    <xsl:param name="program" as="element()"/>
    <xsl:param name="data-divisions" as="element()*"/>

    <xsl:variable name="escape-data-division" as="element()?">
      <xsl:variable name="escapes" as="element()*"
        select="t:get-escapes($program/procedure-division)"/>

      <xsl:if test="exists($escapes)">
        <xsl:variable name="performs" as="element()*" select="
          for
            $perform in
              $program/procedure-division//perform-statement[exists(times)]
          return
            $perform[not(ancestor::comment[. >> $perform])]
            [
              . intersect $escapes/ancestor::perform-statement
            ]"/>

        <data-division>
          <working-storage-section>
            <data
              level="77"
              name="ESCAPE-LABEL"
              name-id="ESCAPE-{generate-id($program/procedure-division)}">
              <comment>Escape labels</comment>
              <picture>
                <part char="S9" occurs="9"/>
              </picture>
              <value>
                <zero/>
              </value>

              <data-condition name="EMPTY-EL">
                <value>
                  <zero/>
                </value>
              </data-condition>

              <xsl:for-each-group select="$escapes"
                group-by="xs:string(exactly-one(@name-ref))">

                <xsl:variable name="name-ref" as="xs:string"
                  select="@name-ref"/>

                <xsl:variable name="name" as="xs:string" select="
                  ancestor-or-self::*[t:get-statement-info(node-name(.))]/
                    meta/label[xs:string(@name-id) = $name-ref]/@name"/>

                <data-condition name="{$name}" name-id="{$name-ref}">
                  <value>
                    <integer value="{position()}"/>
                  </value>
                </data-condition>
              </xsl:for-each-group>
            </data>

            <xsl:for-each select="$performs">
              <data
                level="77"
                name="COUNTER-{position()}"
                name-id="PERFORM-COUNTER-{generate-id(.)}">
                <picture>
                  <part char="S" occurs="9"/>
                </picture>
              </data>
            </xsl:for-each>
          </working-storage-section>
        </data-division>
      </xsl:if>
    </xsl:variable>

    <xsl:variable name="conditions-division" as="element()?">
      <xsl:variable name="conditions" as="element()*" select="
        for
          $condition in
            $program/procedure-division//*[self::and or self::or]
            [
              t:get-complex-expressions(.)
            ]
        return
          $condition[not(ancestor::comment[. >> $condition])]"/>

      <xsl:if test="$conditions">
        <data-division>
          <working-storage-section>
            <data-scope>
              <comment>Conditions</comment>

              <xsl:for-each select="$conditions">
                <data
                  level="77"
                  name="CONDITION"
                  name-id="CONDITION-{generate-id(.)}:complex-elements">
                  <picture>
                    <part char="S9" occurs="1"/>
                  </picture>
                </data>
              </xsl:for-each>
            </data-scope>
          </working-storage-section>
        </data-division>
      </xsl:if>
    </xsl:variable>
    
    <xsl:variable name="total-data-divisions" as="element()*" select="
      $program/self::program/
      (
        data-division,
        procedure-division/t:get-complex-elements(.)/data-division
      ),
      $conditions-division,
      $escape-data-division,
      $data-divisions"/>

    <xsl:if test="exists($total-data-divisions)">
      <xsl:sequence select="
        p:merge-data-divisions
        (
          $total-data-divisions,
          2,
          $total-data-divisions[1]
        )"/>
    </xsl:if>
  </xsl:function>

  <!--
    Gets merged data division for a sequence of data divisions.
      $data-divisions - a sequence of data divisions to merge.
      $index - current index.
      $result - collected results.
      Returns merged data division.
  -->
  <xsl:function name="p:merge-data-divisions" as="element()">
    <xsl:param name="data-divisions" as="element()*"/>
    <xsl:param name="index" as="xs:integer"/>
    <xsl:param name="result" as="element()"/>

    <xsl:variable name="next" as="element()?"
      select="$data-divisions[$index]"/>
    
    <xsl:sequence select="
      if (empty($next)) then
        $result
      else
        p:merge-data-divisions
        (
          $data-divisions,
          $index + 1,
          p:merge-data-divisions($result, $next)
        )"/>
  </xsl:function>

  <!--
    Gets merged data division from two others.
      $primary-data-division - a primary data division.
      $secondary-data-division - a primary data division.
      Returns merged data division.
  -->
  <xsl:function name="p:merge-data-divisions" as="element()">
    <xsl:param name="primary-data-division" as="element()"/>
    <xsl:param name="secondary-data-division" as="element()"/>

    <xsl:apply-templates mode="p:merge-data-division"
      select="$primary-data-division">
      <xsl:with-param name="secondary" tunnel="yes"
        select="$secondary-data-division"/>
    </xsl:apply-templates>
  </xsl:function>

  <!--
    Mode "p:merge-data-division". Default match.
  -->
  <xsl:template mode="p:merge-data-division" match="text()">
    <xsl:sequence select="."/>
  </xsl:template>

  <!--
    Mode "p:merge-data-division". comment or meta.
  -->
  <xsl:template mode="p:merge-data-division" match="comment | meta">
    <xsl:sequence select="."/>
  </xsl:template>

  <!--
    Mode "p:merge-data-division". exec-sql
  -->
  <xsl:template mode="p:merge-data-division" match="exec-sql">
    <xsl:sequence select="."/>
  </xsl:template>

  <!--
    Mode "p:merge-data-division". a data division element.
      $secondary - a tunnelling parameter for an element to merge.
  -->
  <xsl:template mode="p:merge-data-division" match="*">
    <xsl:param name="secondary" tunnel="yes" as="element()?"/>

    <xsl:variable name="primary-children" as="element()*"
      select="t:get-elements(.)"/>
    <xsl:variable name="primary-comment" as="element()*"
      select="comment"/>
    <xsl:variable name="primary-meta" as="element()*"
      select="meta"/>

    <xsl:variable name="secondary-children" as="element()*"
      select="$secondary/t:get-elements(.)"/>
    <xsl:variable name="secondary-comment" as="element()*"
      select="$secondary/comment"/>
    <xsl:variable name="secondary-meta" as="element()*"
      select="$secondary/meta"/>
    
    <xsl:variable name="null" as="element()">
      <null/>
    </xsl:variable>

    <xsl:variable name="merge-base" as="element()*" select="
      for $primary-child in $primary-children return
        (
          $secondary-children[node-name(.) = node-name($primary-child)]
          [
            not(p:is-mergeable-data(.)) or
            (
              (@name = $primary-child/@name) and
              (@merge-id = $primary-child/@merge-id) and
              (
                (t:ids(@name-id) = t:ids($primary-child/@name-id)) or
                not
                (
                  p:get-division-scope-ids(.) =
                    p:get-division-scope-ids($primary-child)
                )
              )
            )
          ],
          $null
        )[1]"/>

    <xsl:variable name="merge" as="element()*">
      <xsl:for-each select="$merge-base">
        <xsl:sequence select="
          if 
          (
            self::null or 
            not(subsequence($merge-base, 1, position() - 1) intersect .)
          ) then 
            .
          else
            $null"/>
      </xsl:for-each>
    </xsl:variable>

    <xsl:variable name="scope-ids" as="xs:string*" select="
      distinct-values
      (
        (p:get-division-scope-ids(.), p:get-division-scope-ids($secondary))
      )"/>

    <xsl:variable name="name-ids" as="xs:string*"
      select="distinct-values((t:ids(@name-id), t:ids($secondary/@name-id)))"/>

    <xsl:variable name="elements" as="element()*">
      <xsl:for-each select="$primary-children">
        <xsl:variable name="index" as="xs:integer" select="position()"/>
        <xsl:variable name="merge-secondary" as="element()?"
          select="$merge[$index][not(self::null)]"/>

        <xsl:apply-templates mode="#current" select=".">
          <xsl:with-param name="secondary" tunnel="yes"
            select="$merge-secondary"/>
        </xsl:apply-templates>
      </xsl:for-each>

      <xsl:apply-templates mode="#current" 
        select="$secondary-children except $merge">
        <xsl:with-param name="secondary" tunnel="yes" select="()"/>
      </xsl:apply-templates>
    </xsl:variable>

    <xsl:copy>
      <xsl:sequence select="$secondary/@*, @*"/>

      <xsl:if test="exists($name-ids)">
        <xsl:if test="@merge-id and exists($scope-ids)">
          <xsl:attribute name="merge-scope-ids" select="$scope-ids"/>
        </xsl:if>

        <xsl:attribute name="name-id" select="$name-ids"/>
      </xsl:if>

      <xsl:sequence select="
        if ($primary-comment) then
          $primary-comment
        else
          $secondary-comment"/>

      <xsl:sequence select="
        if ($primary-meta) then
          $primary-meta
        else
          $secondary-meta"/>

      <xsl:choose>
        <xsl:when test="xs:boolean(@sort) and $secondary/xs:boolean(@sort)">
          <xsl:perform-sort select="$elements">
            <xsl:sort select="xs:string(@name)"/>
          </xsl:perform-sort>
        </xsl:when>
        <xsl:otherwise>
          <xsl:sequence select="$elements"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:copy>
  </xsl:template>

  <!--
    Tests whether the element is mergeable.
      $element - an element to test.
      Return true if element is mergable, and false otherwise.
  -->
  <xsl:function name="p:is-mergeable-data" as="xs:boolean">
    <xsl:param name="element" as="element()?"/>

    <xsl:sequence select="
      exists
      (
        $element
        [
          self::data-scope or
          self::snippet-data-scope or
          self::data or
          self::data-filler or
          self::data-rename or
          self::data-condition or
          self::copy or
          self::exec-sql or
          self::exec-sql-declare-section
        ]
      )"/>
  </xsl:function>

  <!--
    Normalize complex expressions.
      $complex - a sequence of complex expressions.
      Returns a sequence of normalized statements.
  -->
  <xsl:function name="p:normalize-complex-expressions" as="element()*">
    <xsl:param name="complex" as="element()*"/>

    <xsl:variable name="top" as="element()*" select="
      $complex
      [
        empty(ancestor::scope-statement/parent::complex intersect $complex)
      ]"/>

    <xsl:variable name="in-condition" as="element()*" 
      select="$top[ancestor::and or ancestor::or]"/>

    <xsl:for-each select="
      ($top except $in-condition) | 
      $in-condition/(ancestor::and | ancestor::or)[1]">

      <xsl:variable name="arguments" as="element()+"
        select="t:get-elements(.)"/>

      <xsl:variable name="data-ref" as="element()">
        <data-ref
          name="CONDITION"
          name-id="CONDITION-{generate-id(.)}:complex-elements"/>
      </xsl:variable>
      
      <xsl:variable name="statement" as="element()*">
        <xsl:choose>
          <xsl:when test="self::and">
            <if-statement>
              <condition>
                <xsl:sequence select="$arguments[1]"/>
              </condition>
              <then>
                <if-statement>
                  <condition>
                    <xsl:sequence select="subsequence($arguments, 2)"/>
                  </condition>
                  <then>
                    <move-statement>
                      <integer value="1"/>
                      <to>
                        <xsl:sequence select="$data-ref"/>
                      </to>
                    </move-statement>
                  </then>
                  <else>
                    <move-statement>
                      <zero/>
                      <to>
                        <xsl:sequence select="$data-ref"/>
                      </to>
                    </move-statement>
                  </else>
                </if-statement>
              </then>
              <else>
                <move-statement>
                  <zero/>
                  <to>
                    <xsl:sequence select="$data-ref"/>
                  </to>
                </move-statement>
              </else>
            </if-statement>
          </xsl:when>
          <xsl:when test="self::or">
            <if-statement>
              <condition>
                <xsl:sequence select="$arguments[1]"/>
              </condition>
              <then>
                <move-statement>
                  <integer value="1"/>
                  <to>
                    <xsl:sequence select="$data-ref"/>
                  </to>
                </move-statement>
              </then>
              <else>
                <if-statement>
                  <condition>
                    <xsl:sequence select="subsequence($arguments, 2)"/>
                  </condition>
                  <then>
                    <move-statement>
                      <integer value="1"/>
                      <to>
                        <xsl:sequence select="$data-ref"/>
                      </to>
                    </move-statement>
                  </then>
                  <else>
                    <move-statement>
                      <zero/>
                      <to>
                        <xsl:sequence select="$data-ref"/>
                      </to>
                    </move-statement>
                  </else>
                </if-statement>
              </else>
            </if-statement>
          </xsl:when>
          <xsl:otherwise>
            <xsl:sequence select="
              scope-statement/
              (
                if (empty(@*) and empty(comment) and empty(meta)) then
                  t:get-elements(.)
                else
                  .
              )"/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:variable>

      <xsl:apply-templates mode="p:normalize-procedure-division"
        select="$statement"/>
    </xsl:for-each>
  </xsl:function>

  <!--
    Mode "p:normalize-procedure-division". Default template.
  -->
  <xsl:template mode="p:normalize-procedure-division" match="text()">
    <xsl:sequence select="."/>
  </xsl:template>

  <!--
    Mode "p:normalize-procedure-division". An element.
  -->
  <xsl:template mode="p:normalize-procedure-division" match="*">
    <xsl:copy>
      <xsl:sequence select="@*"/>
      <xsl:apply-templates mode="#current"/>
    </xsl:copy>
  </xsl:template>

  <!--
    Mode "p:normalize-procedure-division". Remove meta/label.
  -->
  <xsl:template mode="p:normalize-procedure-division" match="meta/label"/>

  <!--
    Mode "p:normalize-procedure-division". section-ref with import instruction.
  -->
  <xsl:template mode="p:normalize-procedure-division"
    match="section-ref[meta/import-section]">

    <xsl:copy>
      <xsl:sequence select="@*"/>
      <xsl:sequence select="copy"/>

      <xsl:variable name="meta-content" as="element()*"
        select="meta[* except import-section]"/>

      <xsl:if test="exists($meta-content)">
        <meta>
          <xsl:sequence select="meta/@*"/>
          <xsl:sequence select="$meta-content"/>
        </meta>
      </xsl:if>
    </xsl:copy>
  </xsl:template>

  <!--
    Mode "p:normalize-procedure-division".
    Refactor ESCAPE pseudo statement.
  -->
  <xsl:template mode="p:normalize-procedure-division" match="
    paragraph |
    sentence |
    scope-statement |
    add-statement/on-size-error |
    add-statement/on-succeed |
    call-statement/on-overflow |
    call-statement/on-exception |
    call-statement/on-succeed |
    compute-statement/on-size-error |
    compute-statement/on-succeed |
    divide-statement/on-size-error |
    divide-statement/on-succeed |
    multiply-statement/on-size-error |
    multiply-statement/on-succeed |
    read-statement/at-end |
    read-statement/not-at-end |
    read-statement/on-invalid-key |
    read-statement/on-valid-key |
    return-statement/at-end |
    return-statement/not-at-end |
    rewrite-statement/on-invalid-key |
    rewrite-statement/on-valid-key |
    start-statement/on-invalid-key |
    start-statement/on-valid-key |
    string-statement/on-overflow |
    string-statement/on-succeed |
    subtract-statement/on-size-error |
    subtract-statement/on-succeed |
    unstring-statement/on-overflow |
    unstring-statement/on-succeed |
    write-statement/at-end |
    write-statement/not-at-end |
    write-statement/on-invalid-key |
    write-statement/on-valid-key |
    evaluate-statement/when/then |
    evaluate-statement/when-other |
    if-statement/then |
    if-statement/else |
    perform-statement/body |
    search-statement/at-end |
    search-statement/when/body">

    <xsl:copy>
      <xsl:sequence select="@*"/>
      <xsl:apply-templates mode="#current" select="comment | meta"/>

      <xsl:sequence select="p:normalize-escapes(t:get-elements(.), (), ())"/>
    </xsl:copy>
  </xsl:template>

  <!--
    Mode "p:normalize-procedure-division". complex statement.
  -->
  <xsl:template mode="p:normalize-procedure-division" match="
    if-statement[then and not(else)] |
    evaluate-statement/when">

    <xsl:variable name="then" as="element()" select="then"/>

    <xsl:variable name="normalized-then" as="element()">
      <xsl:apply-templates mode="#current" select="$then"/>
    </xsl:variable>

    <xsl:if test="t:get-elements($normalized-then)">
      <xsl:sequence select="
        p:normalize-complex-expressions
        (
          t:get-complex-expressions((value, condition))
        )"/>

      <xsl:copy>
        <xsl:sequence select="@*"/>
        <xsl:apply-templates mode="#current" select="* except $then"/>
        <xsl:sequence select="$normalized-then"/>
      </xsl:copy>
    </xsl:if>
  </xsl:template>

  <!--
    Mode "p:normalize-procedure-division". complex statement.
  -->
  <xsl:template mode="p:normalize-procedure-division"
    match="snippet-statement[meta/complex]">
    <xsl:apply-templates mode="#current" select="
      meta/complex/scope-statement/
      (
        if (empty(@*) and empty(comment) and empty(meta)) then
          t:get-elements(.)
        else
          .
      )"/>
  </xsl:template>

  <!--
    Mode "p:normalize-procedure-division". complex expression.
  -->
  <xsl:template mode="p:normalize-procedure-division"
    match="snippet-expression[meta/complex]">

    <xsl:variable name="result" as="element()"
      select="t:get-elements(meta/complex/result)"/>

    <xsl:apply-templates mode="#current" select="$result"/>
  </xsl:template>

  <!--
    Mode "p:normalize-procedure-division". expression-statement.
  -->
  <xsl:template mode="p:normalize-procedure-division" match="
    expression-statement">

    <xsl:sequence select="
      p:normalize-complex-expressions
      (
        t:get-complex-expressions
        (
          t:get-elements(.)
        )
      )"/>
  </xsl:template>

  <!--
    Mode "p:normalize-procedure-division". and, or expressions.
  -->
  <xsl:template mode="p:normalize-procedure-division" match="
    and[t:get-complex-expressions(.)] |
    or[t:get-complex-expressions(.)]">

    <not>
      <eq>
        <data-ref 
          name="CONDITION"
          name-id="CONDITION-{generate-id(.)}:complex-elements"/>
        <zero/>
      </eq>
    </not>
  </xsl:template>


  <!--
    Mode "p:normalize-procedure-division".
    Statements with default processing.
  -->
  <xsl:template mode="p:normalize-procedure-division" match="
    accept-statement |
    cancel-statement |
    display-statement |
    entry-statement |
    go-to-statement |
    initialize-statement |
    inspect-statement |
    merge-statement |
    move-statement |
    release-statement |
    set-statement |
    sort-statement |
    stop-statement |
    exec-sql">

    <xsl:sequence select="
      p:normalize-complex-expressions
      (
        t:get-complex-expressions
        (
          t:get-elements(.)
        )
      )"/>

    <xsl:next-match/>
  </xsl:template>

  <!--
    Mode "p:normalize-procedure-division".
    Statements with handlers.
  -->
  <xsl:template mode="p:normalize-procedure-division" match="
    add-statement |
    call-statement |
    compute-statement |
    divide-statement |
    multiply-statement |
    read-statement |
    return-statement |
    rewrite-statement |
    start-statement |
    string-statement |
    subtract-statement |
    unstring-statement |
    write-statement">

    <xsl:sequence select="
      p:normalize-complex-expressions
      (
        t:get-complex-expressions
        (
          t:get-elements(.) except
            (
              on-size-error |
              on-succeed |
              on-overflow |
              on-exception |
              at-end |
              not-at-end |
              on-invalid-key |
              on-valid-key
            )
        )
      )"/>

    <xsl:next-match/>
  </xsl:template>

  <!--
    Mode "p:normalize-procedure-division". evaluate-statement.
  -->
  <xsl:template mode="p:normalize-procedure-division"
    match="evaluate-statement">

    <!-- Note that this may change the order of expression evaluation. -->
    <xsl:sequence select="
      p:normalize-complex-expressions
      (
        t:get-complex-expressions(test | when/value)
      )"/>

    <xsl:next-match/>
  </xsl:template>

  <!--
    Mode "p:normalize-procedure-division". if-statement.
  -->
  <xsl:template mode="p:normalize-procedure-division"
    match="if-statement">

    <xsl:sequence select="
      p:normalize-complex-expressions
      (
        t:get-complex-expressions
        (
          condition
        )
      )"/>

    <xsl:next-match/>
  </xsl:template>

  <!--
    Mode "p:normalize-procedure-division". perform-statement.
  -->
  <xsl:template mode="p:normalize-procedure-division"
    match="perform-statement">

    <xsl:variable name="body" as="element()?" select="body"/>
    <xsl:variable name="range-ref" as="element()?"
      select="t:get-range-ref-elements(.)"/>

    <xsl:variable name="complex-until" as="element()*" select="
      t:get-complex-expressions
      (
        varying/until | until
      )"/>

    <xsl:variable name="complex-until-after" as="element()*" select="
      t:get-complex-expressions
      (
        varying/until[@test = 'after'] | until[@test = 'after']
      )"/>

    <xsl:sequence select="
      p:normalize-complex-expressions
      (
        t:get-complex-expressions
        (
          t:get-elements(.) except $body
        ) except $complex-until-after
      )"/>

    <xsl:copy>
      <xsl:sequence select="@*"/>
      <xsl:apply-templates mode="#current" select="comment | meta"/>

      <xsl:choose>
        <xsl:when test="empty($complex-until)">
          <xsl:apply-templates mode="#current" select="t:get-elements(.)"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:apply-templates mode="#current"
            select="t:get-elements(.) except ($body, $range-ref)"/>

          <body>
            <xsl:choose>
              <xsl:when test="exists($body)">
                <xsl:apply-templates mode="#current"
                  select="t:get-elements($body)"/>
              </xsl:when>
              <xsl:otherwise>
                <perform-statement>
                  <xsl:sequence select="$range-ref"/>
                </perform-statement>
              </xsl:otherwise>
            </xsl:choose>

            <xsl:sequence
              select="p:normalize-complex-expressions($complex-until)"/>
          </body>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:copy>
  </xsl:template>

  <!--
    Mode "p:normalize-procedure-division".
    Adjusts break condition.
  -->
  <xsl:template mode="p:normalize-procedure-division" match="
    perform-statement/until |
    perform-statement/varying/until">

    <xsl:variable name="escape-data-ref" as="element()">
      <data-ref name="ESCAPE-LABEL">
        <xsl:attribute name="name-ref">
          <xsl:text>ESCAPE-</xsl:text>
          <xsl:value-of select="generate-id(ancestor::procedure-division)"/>
        </xsl:attribute>
      </data-ref>
    </xsl:variable>

    <xsl:copy>
      <xsl:sequence select="@*"/>
      <xsl:apply-templates mode="#current" select="comment | meta"/>

      <xsl:variable name="condition" as="element()"
        select="t:get-elements(.)"/>

      <xsl:variable name="body" as="element()?"
        select="ancestor::perform-statement[1]"/>

      <xsl:choose>
        <xsl:when test="not(t:get-escapes-from-scope($body))">
          <xsl:apply-templates mode="#current" select="$condition"/>
        </xsl:when>
        <xsl:when test="
          $condition/self::not/eq/
          (
            every $argument in t:get-elements(.) satisfies
              $argument/self::integer/xs:integer(@value) = 1
          )">
          <!-- Special case of true condition. -->
          <not>
            <condition-ref name="EMPTY-EL">
              <xsl:sequence select="$escape-data-ref"/>
            </condition-ref>
          </not>
        </xsl:when>
        <xsl:otherwise>
          <or>
            <not>
              <condition-ref name="EMPTY-EL">
                <xsl:sequence select="$escape-data-ref"/>
              </condition-ref>
            </not>

            <xsl:apply-templates mode="#current" select="$condition"/>
          </or>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:copy>
  </xsl:template>

  <!--
    Mode "p:normalize-procedure-division". perform-statement with times clause.
  -->
  <xsl:template mode="p:normalize-procedure-division"
    match="perform-statement[times and t:get-escapes-from-scope(body)]">

    <xsl:variable name="times" as="element()?" select="times"/>
    <xsl:variable name="body" as="element()?" select="body"/>

    <xsl:variable name="escape-data-ref" as="element()">
      <data-ref name="ESCAPE-LABEL">
        <xsl:attribute name="name-ref">
          <xsl:text>ESCAPE-</xsl:text>
          <xsl:value-of select="generate-id(ancestor::procedure-division)"/>
        </xsl:attribute>
      </data-ref>
    </xsl:variable>

    <xsl:variable name="counter-ref" as="element()">
      <data-ref
        name="COUNTER"
        name-ref="PERFORM-COUNTER-{generate-id(.)}"/>
    </xsl:variable>

    <xsl:sequence select="
      p:normalize-complex-expressions
      (
        t:get-complex-expressions
        (
          $times
        )
      )"/>

    <xsl:copy>
      <xsl:sequence select="@*"/>
      <xsl:apply-templates mode="#current" select="comment | meta"/>

      <varying>
        <xsl:sequence select="$counter-ref"/>

        <from>
          <zero/>
        </from>
        <by>
          <integer value="1"/>
        </by>
        <until>
          <or>
            <not>
              <condition-ref name="EMPTY-EL">
                <xsl:sequence select="$escape-data-ref"/>
              </condition-ref>
            </not>
            <ge>
              <xsl:sequence select="$counter-ref"/>
              <xsl:apply-templates mode="#current"
                select="t:get-elements($times)"/>
            </ge>
          </or>
        </until>
      </varying>

      <xsl:apply-templates mode="#current"
        select="t:get-elements(.) except $times"/>
    </xsl:copy>
  </xsl:template>

  <!--
    Mode "p:normalize-procedure-division". search-statement.
  -->
  <xsl:template mode="p:normalize-procedure-division"
    match="search-statement">

    <xsl:sequence select="
      p:normalize-complex-expressions
      (
        t:get-complex-expressions
        (
          t:get-elements(.) except (at-end | when) | when/condition
        )
      )"/>

    <xsl:next-match/>
  </xsl:template>

  <!--
    Normalizes escape statemetns.
      $statements - a sequence of statements.
      $index - current statement index.
      $result - collected result.
      Returns normalized statements.
  -->
  <xsl:function name="p:normalize-escapes" as="element()*">
    <xsl:param name="statements" as="element()*"/>
    <xsl:param name="index" as="xs:integer?"/>
    <xsl:param name="result" as="element()*"/>

    <xsl:variable name="current-index" as="xs:integer" select="
      if (empty($index)) then
        count($statements)
      else
        $index"/>

    <xsl:variable name="statement" as="element()?"
      select="$statements[$current-index]"/>

    <xsl:choose>
      <xsl:when test="empty($statement)">
        <xsl:sequence select="$result"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:variable name="escape" as="element()?"
          select="$statement/self::snippet-statement/meta/escape"/>

        <xsl:variable name="escape-data-ref" as="element()">
          <data-ref name="ESCAPE-LABEL">
            <xsl:attribute name="name-ref">
              <xsl:text>ESCAPE-</xsl:text>
              <xsl:value-of
                select="generate-id($statement/ancestor::procedure-division)"/>
            </xsl:attribute>
          </data-ref>
        </xsl:variable>

        <xsl:variable name="empty-escape-ref" as="element()">
          <condition-ref name="EMPTY-EL">
            <xsl:sequence select="$escape-data-ref"/>
          </condition-ref>
        </xsl:variable>

        <xsl:variable name="next-result" as="element()*">
          <xsl:variable name="scope-escapes" as="element()*"
            select="t:get-escapes-from-scope($statement)"/>

          <xsl:choose>
            <xsl:when test="$escape">
              <xsl:if test="t:has-next-statement($escape)">
                <!--
                  SET label of ESCAPE-LABEL TO TRUE
                -->
                <set-statement escape="true">
                  <xsl:sequence select="$statement/comment"/>

                  <condition-ref
                    name="{$escape/@name}"
                    name-ref="{$escape/@name-ref}">
                    <xsl:sequence select="$escape-data-ref"/>
                  </condition-ref>
                </set-statement>
              </xsl:if>
            </xsl:when>
            <xsl:when test="$scope-escapes">
              <xsl:variable name="scope" as="element()*" select="
                $statement/meta/label
                [
                  xs:string(@name-id) = $scope-escapes/xs:string(@name-ref)
                ]"/>

              <xsl:variable name="parent-escapes" as="element()*" select="
                $scope-escapes
                [
                  not
                  (
                    xs:string(@name-ref) =
                      $statement/meta/label/xs:string(@name-id)
                  )
                ]"/>

              <xsl:variable name="next-statements" as="element()*">
                <xsl:choose>
                  <xsl:when test="$scope">
                    <xsl:apply-templates
                      mode="p:normalize-procedure-division"
                      select="$statement"/>

                    <xsl:if test="$result">
                      <!--
                        IF LABEL OF ESCAPE-LABEL THEN
                          SET EMPTY OF ESCAPE-LABEL TO TRUE
                        END-IF
                      -->
                      <xsl:choose>
                        <xsl:when test="$parent-escapes">
                          <if-statement>
                            <condition>
                              <xsl:variable name="conditions" as="element()+">
                                <xsl:for-each select="$scope">
                                  <condition-ref
                                    name="{@name}"
                                    name-ref="{@name-id}">
                                    <xsl:sequence select="$escape-data-ref"/>
                                  </condition-ref>
                                </xsl:for-each>
                              </xsl:variable>

                              <xsl:sequence select="
                                t:combine-expression('or', $conditions)"/>
                            </condition>
                            <then>
                              <set-statement escape="false">
                                <xsl:sequence select="$empty-escape-ref"/>
                              </set-statement>
                            </then>
                          </if-statement>
                        </xsl:when>
                        <xsl:otherwise>
                          <set-statement escape="false">
                            <xsl:sequence select="$empty-escape-ref"/>
                          </set-statement>
                        </xsl:otherwise>
                      </xsl:choose>
                    </xsl:if>
                  </xsl:when>
                  <xsl:otherwise>
                    <xsl:apply-templates
                      mode="p:normalize-procedure-division"
                      select="$statement"/>
                  </xsl:otherwise>
                </xsl:choose>
              </xsl:variable>

              <xsl:choose>
                <xsl:when test="
                  $result and
                  $parent-escapes and
                  $next-statements[last()]/self::if-statement[empty(else)]/
                    t:get-elements(then)[last()]/
                      self::set-statement/xs:boolean(@escape)">
                  <xsl:sequence select="$next-statements[last() > position()]"/>

                  <xsl:for-each select="$next-statements[last()]">
                    <xsl:copy>
                      <xsl:sequence select="@*"/>
                      <xsl:sequence select="*"/>

                      <else>
                        <xsl:sequence select="$result"/>
                      </else>
                    </xsl:copy>
                  </xsl:for-each>
                </xsl:when>
                <xsl:otherwise>
                  <xsl:sequence select="$next-statements"/>

                  <!--
                    IF EMPTY OF ESCAPE-LABEL THEN
                    ...
                    END-IF
                  -->
                  <xsl:if test="$result">
                    <xsl:choose>
                      <xsl:when test="$parent-escapes">
                        <xsl:for-each-group select="$result" 
                          group-adjacent="boolean(self::scope-statement/meta/finally)">
                          <xsl:choose>
                            <xsl:when test="current-grouping-key()">
                              <xsl:sequence select="current-group()/t:get-elements(.)"/>
                            </xsl:when>
                            <xsl:when test="
                              (count(current-group()) = 1) and
                              deep-equal
                              (
                                $empty-escape-ref, 
                                current-group()/
                                  self::if-statement/condition/
                                    t:get-elements(.)
                              )">
                              <xsl:sequence select="current-group()"/>
                            </xsl:when>
                            <xsl:otherwise>
                              <if-statement>
                                <condition>
                                  <xsl:sequence select="$empty-escape-ref"/>
                                </condition>
                                <then>
                                  <xsl:sequence select="current-group()"/>
                                </then>
                              </if-statement>
                            </xsl:otherwise>
                          </xsl:choose>
                        </xsl:for-each-group>
                      </xsl:when>
                      <xsl:otherwise>
                        <xsl:sequence select="$result"/>
                      </xsl:otherwise>
                    </xsl:choose>
                  </xsl:if>
                </xsl:otherwise>
              </xsl:choose>
            </xsl:when>
            <xsl:otherwise>
              <xsl:apply-templates
                mode="p:normalize-procedure-division"
                select="$statement"/>

              <xsl:sequence select="$result"/>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:variable>

        <xsl:sequence select="
          p:normalize-escapes
          (
            $statements,
            $current-index - 1,
            $next-result
          )"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:function>

  <!--
    Refactors blocks.
      $content - a program division content to refactor.
      Returns refactored blocks.
  -->
  <xsl:function name="p:refactor-sections" as="element()*">
    <xsl:param name="content" as="element()*"/>

    <xsl:variable name="section" as="xs:boolean"
      select="exists($content[1][self::section])"/>

    <xsl:variable name="closures" as="item()*">
      <xsl:for-each select="$content">
        <xsl:variable name="index" as="xs:decimal" select="position()"/>

        <xsl:sequence select="''"/>
        <xsl:sequence select="$index"/>
        <xsl:sequence select="."/>

        <xsl:for-each select="p:collect-refactored-blocks(.)">
          <xsl:variable name="block" as="element()" select="meta/block"/>
          <xsl:variable name="position" as="xs:string?"
            select="$block/@position"/>
          <xsl:variable name="priority" as="xs:decimal"
            select="($block/@position-priority, 0.5)[1]"/>

          <xsl:sequence select="string($block/@name)"/>

          <xsl:sequence select="
            if (empty($position) or ($position = ('default', 'below'))) then
              $index + $priority
            else if ($position = 'top') then
             -$priority
            else if ($position = 'bottom') then
              count($content) + $priority
            else if ($position = 'above') then
              $index - $priority
            else
              error(xs:QName('invalid-block-position'))"/>

          <xsl:sequence select="."/>
        </xsl:for-each>
      </xsl:for-each>
    </xsl:variable>

    <xsl:variable name="indices" as="xs:integer*">
      <xsl:perform-sort select="(1 to count($closures))[(. mod 3) = 1]">
        <xsl:sort select="xs:string(subsequence($closures, ., 1))"
          stable="yes"/>
        <xsl:sort select="xs:decimal(subsequence($closures, . + 1, 1))"/>
      </xsl:perform-sort>
    </xsl:variable>

    <xsl:for-each select="$indices">
      <xsl:variable name="position" as="xs:integer" select="position()"/>
      <xsl:variable name="index" as="xs:integer" select="."/>

      <xsl:if test="
        not($closures[$index]) or
        not($closures[$index] = $closures[$indices[$position - 1]])">
        <xsl:variable name="component" as="element()"
          select="$closures[$index + 2]"/>

        <xsl:choose>
          <xsl:when test="$component[self::section or self::paragraph]">
            <xsl:apply-templates mode="p:refactor-blocks" select="$component">
              <xsl:with-param name="section" tunnel="yes" select="$section"/>
              <xsl:with-param name="closures" tunnel="yes" select="$closures"/>
            </xsl:apply-templates>
          </xsl:when>
          <xsl:otherwise>
            <xsl:variable name="block" as="element()"
              select="$component/meta/block"/>
            <xsl:variable name="range-ref" as="element()"
              select="t:get-range-ref-elements($block)"/>

            <xsl:variable name="name-ref" as="element()" select="
              if ($range-ref/self::range-ref) then
                t:get-procedure-ref-elements($range-ref)[1]
              else
                $range-ref"/>

            <xsl:variable name="through-name-ref" as="element()?" select="
              $range-ref/self::range-ref/t:get-procedure-ref-elements(.)[2]"/>

            <xsl:variable name="name" as="xs:string" select="$name-ref/@name"/>
            <xsl:variable name="name-id" as="xs:string"
              select="$name-ref/@name-ref"/>
            <xsl:variable name="priority" as="xs:integer?"
              select="$block/@priority"/>

            <xsl:choose>
              <xsl:when test="$section">
                <section name="{$name}" name-id="{$name-id}">
                  <xsl:if test="exists($priority)">
                    <xsl:attribute name="priority" select="$priority"/>
                  </xsl:if>

                  <xsl:sequence select="$component/comment"/>

                  <xsl:variable name="meta-content" as="element()*"
                    select="$component/meta/(* except block)"/>

                  <xsl:if test="$meta-content">
                    <meta>
                      <xsl:sequence select="$meta-content"/>
                    </meta>
                  </xsl:if>

                  <paragraph>
                    <xsl:apply-templates mode="p:refactor-blocks"
                      select="t:get-elements($component)">
                      <xsl:with-param name="section" tunnel="yes"
                        select="$section"/>
                      <xsl:with-param name="closures" tunnel="yes"
                        select="$closures"/>
                    </xsl:apply-templates>
                  </paragraph>

                  <paragraph>
                    <xsl:if test="$through-name-ref">
                      <xsl:variable name="through-name" as="xs:string"
                        select="$through-name-ref/@name"/>
                      <xsl:variable name="through-name-id" as="xs:string"
                        select="$through-name-ref/@name-ref"/>

                      <xsl:attribute name="name" select="$through-name"/>
                      <xsl:attribute name="name-id" select="$through-name-id"/>
                    </xsl:if>

                    <exit-statement/>
                  </paragraph>
                </section>
              </xsl:when>
              <xsl:otherwise>
                <paragraph name="{$name}" name-id="{$name-id}">
                  <xsl:sequence select="$component/(comment | meta)"/>

                  <xsl:apply-templates mode="p:refactor-blocks"
                    select="t:get-elements($component)">
                    <xsl:with-param name="section" tunnel="yes"
                      select="$section"/>
                    <xsl:with-param name="closures" tunnel="yes"
                      select="$closures"/>
                  </xsl:apply-templates>
                </paragraph>

                <paragraph>
                  <xsl:if test="$through-name-ref">
                    <xsl:variable name="through-name" as="xs:string"
                      select="$through-name-ref/@name"/>
                    <xsl:variable name="through-name-id" as="xs:string"
                      select="$through-name-ref/@name-id"/>

                    <xsl:attribute name="name" select="$through-name"/>
                    <xsl:attribute name="name-id" select="$through-name-id"/>
                  </xsl:if>

                  <exit-statement/>
                </paragraph>
              </xsl:otherwise>
            </xsl:choose>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:if>
    </xsl:for-each>
  </xsl:function>

  <!--
    Collects blocks to refactor.
      $content - a content to get refactored blocks for.
      A list of blocks to refactor.
  -->
  <xsl:function name="p:collect-refactored-blocks" as="element()*">
    <xsl:param name="content" as="element()"/>

    <xsl:apply-templates mode="p:collect-refactored-blocks" select="$content"/>
  </xsl:function>

  <!--
    Mode "p:collect-refactored-blocks". Default match.
  -->
  <xsl:template mode="p:collect-refactored-blocks" match="*">
    <xsl:variable name="statement" as="element()" select="."/>
    <xsl:variable name="block" as="element()?"
      select="self::scope-statement/meta/block"/>

    <xsl:variable name="name" as="xs:string?" select="$block/@name"/>
    <xsl:variable name="statement-count-threshold" as="xs:integer?"
      select="$block/@statement-count-threshold"/>

    <xsl:variable name="blocks" as="element()*">
      <xsl:apply-templates mode="#current" select="t:get-elements(.)"/>
    </xsl:variable>

    <xsl:variable name="nested-statements" as="element()*" select="
      .//*[t:get-statement-info(node-name(.))]
      [
        not(ancestor::comment[. >> $statement]) and
        not(ancestor::* intersect $blocks)
      ]"/>

    <xsl:sequence select="$blocks"/>

    <xsl:if test="
      t:get-statement-info(node-name(.)) and
      $block and
      (
        $name or
        (
          exists($statement-count-threshold) and
          (count($nested-statements) > $statement-count-threshold)
        )
      )">
      <xsl:sequence select="."/>
    </xsl:if>
  </xsl:template>

  <!--
    Mode "p:refactor-blocks". Default match.
  -->
  <xsl:template mode="p:refactor-blocks" match="*">
    <xsl:copy>
      <xsl:sequence select="@*"/>
      <xsl:apply-templates mode="#current"/>
    </xsl:copy>
  </xsl:template>

  <!--
    Mode "p:refactor-blocks". comment and meta.
  -->
  <xsl:template mode="p:refactor-blocks" match="comment | meta">
    <xsl:sequence select="."/>
  </xsl:template>

  <!--
    Mode "p:refactor-blocks". Default match.
      $section - true to form section, and false to form paragraph.
      $closures - a closures of refactored statements.
        Each closure has following structure:
          (
            $name as xs:string,
            $priority as xs:decimal,
            $component as element()
          )
  -->
  <xsl:template mode="p:refactor-blocks" match="scope-statement[meta/block]">
    <xsl:param name="section" as="xs:boolean?" tunnel="yes"/>
    <xsl:param name="closures" as="item()*" tunnel="yes"/>

    <xsl:variable name="statement" as="element()" select="."/>
    <xsl:variable name="block" as="element()" select="meta/block"/>

    <xsl:variable name="index" as="xs:integer?" select="
      (1 to count($closures))[(. mod 3) = 1]
      [
        (subsequence($closures, ., 1) = $block/xs:string(@name)) or
        (subsequence($closures, . + 2, 1) is $statement)
      ][1]"/>

    <xsl:choose>
      <xsl:when test="exists($index)">
        <xsl:variable name="range-ref" as="element()"
          select="t:get-range-ref-elements($closures[$index + 2]/meta/block)"/>

        <perform-statement>
          <xsl:sequence select="$range-ref"/>
        </perform-statement>
      </xsl:when>
      <xsl:otherwise>
        <xsl:variable name="meta-content" as="element()*"
          select="meta/(* except block)"/>

        <xsl:copy>
          <xsl:sequence select="@*"/>
          <xsl:sequence select="comment"/>

          <xsl:if test="$meta-content">
            <meta>
              <xsl:sequence select="$meta-content"/>
            </meta>
          </xsl:if>

          <xsl:apply-templates mode="#current" select="t:get-elements(.)"/>
        </xsl:copy>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!--
    Mode "p:refactor-blocks". perform-statement with body.
  -->
  <xsl:template mode="p:refactor-blocks" match="perform-statement[body]">
    <xsl:variable name="body" as="element()" select="body"/>

    <xsl:copy>
      <xsl:sequence select="@*"/>
      <xsl:sequence select="comment | meta"/>

      <xsl:apply-templates mode="#current"
        select="t:get-elements(.) except $body"/>

      <xsl:variable name="refactored-body" as="element()">
        <xsl:apply-templates mode="#current" select="$body"/>
      </xsl:variable>

      <xsl:variable name="range-ref" as="element()?" select="
        t:get-elements($refactored-body)[last() = 1]/
          self::perform-statement[not(until or varying or times or body)]/
           t:get-range-ref-elements(.)"/>

      <xsl:choose>
        <xsl:when test="$range-ref">
          <xsl:sequence select="$range-ref"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:sequence select="$refactored-body"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:copy>
  </xsl:template>

  <!--
    Tests whether there is a statement after an escape.
      $scope - a scope.
      $statement - a statement to test.
      Return true if there is a statement after the escape, and
      false otherwise.
  -->
  <xsl:function name="p:has-statement-after-escape" as="xs:boolean">
    <xsl:param name="scope" as="element()"/>
    <xsl:param name="statement" as="element()"/>

    <xsl:variable name="sibling" as="element()*" select="
      $statement/following-sibling::*[t:get-statement-info(node-name(.))]/
        p:expand-scope-statements(.)"/>

    <xsl:variable name="ancestor" as="element()?" select="
      $statement/ancestor::*[t:get-statement-info(node-name(.))]
      [
        . >> $scope
      ][1]"/>

    <xsl:sequence select="
      $sibling or
      not
      (
        $ancestor
        [
          self::scope-statement or
          self::if-statement or
          self::evaluate-statement
        ]
      ) or
      p:has-statement-after-escape($scope, $ancestor)"/>
  </xsl:function>

  <!--
    Expands scope-statement.
      $statement - a statement.
      Returns statement or nested statements in case of scope-statement.
  -->
  <xsl:function name="p:expand-scope-statements" as="element()*">
    <xsl:param name="statement" as="element()"/>

    <xsl:sequence select="
      if ($statement/self::scope-statement) then
        t:get-elements($statement)/p:expand-scope-statements(.)
      else
        $statement"/>
  </xsl:function>

  <!--
    Gets a scope of data division.
      $data - a data element.
      Returns a scope for a division.
  -->
  <xsl:function name="p:get-division-scope-ids" as="xs:string*">
    <xsl:param name="data" as="element()?"/>

    <xsl:if test="p:is-mergeable-data($data)">
      <xsl:variable name="scope-ids" as="xs:string*"
        select="t:ids($data/@merge-scope-ids)"/>
      <xsl:variable name="statement" as="element()?" 
        select="$data/ancestor::*[t:get-statement-info(node-name(.))][1]"/>

      <xsl:sequence select="
        if (exists($scope-ids)) then
          $scope-ids
        else
          $statement/generate-id()"/>
    </xsl:if>
  </xsl:function>

</xsl:stylesheet>