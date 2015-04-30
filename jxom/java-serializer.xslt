<?xml version="1.0" encoding="utf-8"?>
<!--
  This stylesheet serializes java xml object model document down to
  the java text.
 -->
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:t="http://www.bphx.com/jxom"
  xmlns:j="http://www.bphx.com/java-1.5/2008-02-07"
  xmlns="http://www.bphx.com/java-1.5/2008-02-07"
  xpath-default-namespace="http://www.bphx.com/java-1.5/2008-02-07"
  exclude-result-prefixes="xs t j">

  <xsl:include href="java-streamer.xslt"/>
  <xsl:include href="java-serializer-statements.xslt"/>
  <xsl:include href="java-serializer-expressions.xslt"/>

  <!--
    Get java unit.
      $unit - unit element to genereate java for.
      Returns getd unit as sequence of tokens.
  -->
  <xsl:function name="t:get-unit" as="item()*">
    <xsl:param name="unit" as="element()"/>

    <xsl:sequence select="t:get-comments($unit)"/>
    <xsl:sequence select="t:get-annotations($unit, false())"/>

    <xsl:variable name="package" as="xs:string?" select="$unit/@package"/>

    <xsl:if test="$package">
      <xsl:sequence select="'package'"/>
      <xsl:sequence select="' '"/>
      <xsl:sequence select="t:tokenize($package)"/>
      <xsl:sequence select="';'"/>
      <xsl:sequence select="$t:new-line"/>
      <xsl:sequence select="$t:new-line"/>
    </xsl:if>

    <xsl:variable name="imports" as="element()?" select="$unit/imports"/>

    <xsl:if test="$imports">
      <xsl:variable name="imports" as="element()+">
        <xsl:perform-sort select="$imports/import">
          <xsl:sort select="xs:boolean(@static) = true()"/>
          <xsl:sort 
            select="not(starts-with(t:get-import-package(.), 'java'))"/>
          <xsl:sort select="string-join(t:get-import-type(.), '.')"/>
          <xsl:sort select="xs:string(@name)"/>
        </xsl:perform-sort>
      </xsl:variable>

      <xsl:for-each select="$imports">
        <xsl:variable name="position" as="xs:integer" select="position()"/>

        <xsl:if test="$position != 1">
          <xsl:variable name="static" as="xs:boolean"
            select="xs:boolean(@static) = true()"/>
          <xsl:variable name="previous" as="element()?"
            select="$imports[$position - 1]"/>
          <xsl:variable name="previous-static" as="xs:boolean"
            select="$previous/xs:boolean(@static) = true()"/>

          <xsl:if test="
            ($static != $previous-static) or
            (t:get-import-package(.) != t:get-import-package($previous))">
            <xsl:sequence select="$t:new-line"/>
          </xsl:if>
        </xsl:if>

        <xsl:sequence select="t:get-import(.)"/>
      </xsl:for-each>

      <xsl:sequence select="$t:new-line"/>
    </xsl:if>

    <xsl:variable name="type-declarations" as="element()*"
      select="t:get-type-declarations($unit)"/>

    <xsl:for-each select="$type-declarations">
      <xsl:if test="position() > 1">
        <xsl:sequence select="$t:new-line"/>
      </xsl:if>

      <xsl:apply-templates mode="t:typeDeclaration" select="."/>
    </xsl:for-each>
  </xsl:function>

  <!--
    Gets type declarations of an element.
      $element - an element to get type declarations for.
      Retuns type declarations of an element.
  -->
  <xsl:function name="t:get-type-declarations" as="element()*">
    <xsl:param name="element" as="element()"/>

    <xsl:sequence select="
      $element/(snippet-decl | class | enum | interface | annotation-decl)"/>
  </xsl:function>

  <!--
    Tests whether a specified element is a type declaration.
      $element - an element to test.
      Retuns true if element is a type declaration, and false otherwise.
  -->
  <xsl:function name="t:is-type-declaration" as="xs:boolean">
    <xsl:param name="element" as="element()"/>

    <xsl:sequence select="
      exists
      (
        $element
        [
          self::snippet-decl |
          self::class |
          self::enum |
          self::interface |
          self::annotation-decl
        ]
      )"/>
  </xsl:function>

  <!--
    Gets annotations for an element.
      $element - an element to get annotations for.
      $inline - true when a inline form of annotation is asked.
      Returns annotations, if any, as sequence of tokens.
  -->
  <xsl:function name="t:get-annotations" as="item()*">
    <xsl:param name="element" as="element()"/>
    <xsl:param name="inline" as="xs:boolean"/>

    <xsl:variable name="annotations" as="element()?"
      select="$element/annotations"/>

    <xsl:if test="$annotations">
      <xsl:variable name="annotation" as="element()+"
        select="$annotations/annotation"/>

      <xsl:sequence select="t:get-annotation($annotation, $inline)"/>
    </xsl:if>
  </xsl:function>

  <!--
    Gets annotations for an element.
      $annotation - an element to get annotations for.
      $inline - true when a inline form of annotation is asked.
      Returns annotations, if any, as sequence of tokens.
  -->
  <xsl:function name="t:get-annotation" as="item()*">
    <xsl:param name="annotation" as="element()+"/>
    <xsl:param name="inline" as="xs:boolean"/>

    <xsl:for-each select="$annotation">
      <xsl:variable name="type" as="element()" select="type"/>
      <xsl:variable name="parameters" as="element()*" select="parameter"/>

      <xsl:variable name="type-tokens" as="item()+"
        select="t:get-type($type)"/>

      <xsl:sequence
        select="concat('@', $type-tokens[1]), subsequence($type-tokens, 2)"/>

      <xsl:if test="$parameters">
        <xsl:sequence select="'('"/>
        <xsl:sequence select="t:get-annotation-parameters($parameters)"/>
        <xsl:sequence select="')'"/>
      </xsl:if>

      <xsl:choose>
        <xsl:when test="
          $inline and (count($annotation) = 1) and (count($parameters) ge 1)">
          <xsl:sequence select="' '"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:sequence select="$t:new-line"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:for-each>
  </xsl:function>

  <!--
    Gets annotation parameter list.
      $elements - expression element.
      Returns annotation parameters tokens.
  -->
  <xsl:function name="t:get-annotation-parameters" as="item()*">
    <xsl:param name="elements" as="element()+"/>

    <xsl:for-each select="$elements">
      <xsl:sequence select="t:get-annotation-parameter(.)"/>

      <xsl:if test="position() != last()">
        <xsl:sequence select="','"/>
        <xsl:sequence select="' '"/>
        <xsl:sequence select="$t:soft-line-break"/>
      </xsl:if>
    </xsl:for-each>
  </xsl:function>

  <!--
    Gets annotation parameter.
      $parameter - an annotation parameter element.
      Returns annotation parameter as token sequence.
  -->
  <xsl:function name="t:get-annotation-parameter" as="item()+">
    <xsl:param name="parameter" as="element()"/>

    <xsl:variable name="name" as="xs:string?" select="$parameter/@name"/>

    <xsl:if test="$name">
      <xsl:sequence select="$name"/>
      <xsl:sequence select="' '"/>
      <xsl:sequence select="'='"/>
      <xsl:sequence select="' '"/>
    </xsl:if>

    <xsl:sequence
      select="t:get-annotation-value(t:get-java-element($parameter))"/>
  </xsl:function>

  <!--
    Gets annotation value.
      $element - an annotation value element.
      Returns annotation value as token sequence.
  -->
  <xsl:function name="t:get-annotation-value" as="item()+">
    <xsl:param name="element" as="element()"/>

    <xsl:variable name="array" as="element()?"
      select="$element[self::array, self::annotation-array]"/>

    <xsl:choose>
      <xsl:when test="exists($array)">
        <xsl:variable name="arguments" as="element()*"
          select="t:get-java-element($element)"/>

        <xsl:sequence select="$t:new-line"/>
        <xsl:sequence select="'{'"/>
        <xsl:sequence select="$t:indent"/>
        <xsl:sequence select="$t:new-line"/>

        <xsl:for-each select="$arguments">
          <xsl:variable name="value" as="item()*"
            select="t:get-annotation-value(.)"/>

          <xsl:choose>
            <xsl:when test="exists(index-of($value[last()], $t:new-line))">
              <xsl:sequence select="$value[position() lt last()]"/>
            </xsl:when>
            <xsl:otherwise>
              <xsl:sequence select="$value"/>
            </xsl:otherwise>
          </xsl:choose>

          <xsl:if test="position() != last()">
            <xsl:sequence select="','"/>
          </xsl:if>

          <xsl:sequence select="$t:new-line"/>
        </xsl:for-each>

        <xsl:sequence select="$t:unindent"/>
        <xsl:sequence select="'}'"/>
      </xsl:when>
      <xsl:when test="exists($element[self::annotation])">
        <xsl:sequence select="t:get-annotation($element, false())"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:sequence select="t:get-expression($element)"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:function>

  <!--
    Gets import.
      $import - an import element.
      Returns import declaration as sequence of tokens.
  -->
  <xsl:function name="t:get-import" as="item()*">
    <xsl:param name="import" as="element()"/>

    <xsl:variable name="member-name" as="xs:string?" select="$import/@name"/>
    <xsl:variable name="static" as="xs:boolean?" select="$import/@static"/>
    <xsl:variable name="type" as="element()" select="$import/type"/>
    
    <xsl:sequence select="'import'"/>
    <xsl:sequence select="' '"/>

    <xsl:if test="$static">
      <xsl:sequence select="'static'"/>
      <xsl:sequence select="' '"/>
    </xsl:if>

    <xsl:sequence select="t:get-import-type($type)"/>
    
    <xsl:choose>
      <xsl:when test="empty($type/@name) or ($static and not($member-name))">
        <xsl:sequence select="'.'"/>
        <xsl:sequence select="'*'"/>
      </xsl:when>
      <xsl:when test="$static and $member-name">
        <xsl:sequence select="'.'"/>
        <xsl:sequence select="$member-name"/>
      </xsl:when>
    </xsl:choose>
    
    <xsl:sequence select="';'"/>
    <xsl:sequence select="$t:new-line"/>
  </xsl:function>

  <!--
    Gets tokens for import type.
      $type - an import type element.
  -->
  <xsl:function name="t:get-import-type" as="item()*">
    <xsl:param name="type" as="element()"/>

    <xsl:variable name="container" as="element()?" select="$type/type"/>
    <xsl:variable name="package" as="xs:string?" select="$type/@package"/>
    <xsl:variable name="name" as="xs:string?" select="$type/@name"/>

    <xsl:choose>
      <xsl:when test="$container">
        <xsl:sequence select="t:get-import-type($container)"/>
      </xsl:when>
      <xsl:when test="$package">
        <xsl:sequence select="t:tokenize($package)"/>
      </xsl:when>
    </xsl:choose>

    <xsl:if test="$name">
      <xsl:if test="$container or $package">
        <xsl:sequence select="'.'"/>
      </xsl:if>

      <xsl:sequence select="$name"/>
    </xsl:if>
  </xsl:function>

  <!--
    Gets tokens for import type.
      $type - an import type element.
  -->
  <xsl:function name="t:get-import-package" as="xs:string?">
    <xsl:param name="type" as="element()"/>

    <xsl:variable name="container" as="element()?" select="$type/type"/>
    <xsl:variable name="package" as="xs:string?" select="$type/@package"/>

    <xsl:choose>
      <xsl:when test="$container">
        <xsl:sequence select="t:get-import-package($container)"/>
      </xsl:when>
      <xsl:when test="$package">
        <xsl:sequence select="$package"/>
      </xsl:when>
    </xsl:choose>
  </xsl:function>

  <!-- Mode "t:typeDeclaration". Empty match. -->
  <xsl:template mode="t:typeDeclaration" match="@*|node()"/>

  <!--
    Mode "t:typeDeclaration". Snippet declaration.
  -->
  <xsl:template mode="t:typeDeclaration" match="snippet-decl">
    <xsl:variable name="value" as="xs:string" select="@value"/>

    <xsl:sequence select="t:get-comments(.)"/>
    <xsl:sequence select="t:tokenize($value)"/>
  </xsl:template>

  <!--
    Mode "t:typeDeclaration". Class declaration.
  -->
  <xsl:template mode="t:typeDeclaration" match="class">
    <xsl:sequence select="t:get-comments(.)"/>
    <xsl:sequence select="t:get-annotations(., false())"/>

    <xsl:variable name="name" as="xs:string" select="@name"/>
    <xsl:variable name="extends" as="item()*"
      select="t:get-class-extends(.)"/>
    <xsl:variable name="implements" as="item()*"
      select="t:get-class-implements(.)"/>

    <xsl:sequence select="t:get-modifiers(.)"/>
    <xsl:sequence select="'class'"/>
    <xsl:sequence select="' '"/>
    <xsl:sequence select="$name"/>

    <xsl:sequence select="t:get-type-parameters(.)"/>

    <xsl:if test="exists($extends)">
      <xsl:sequence select="' '"/>
      <xsl:sequence select="$extends"/>
    </xsl:if>

    <xsl:if test="exists($implements)">
      <xsl:sequence select="' '"/>
      <xsl:sequence select="$implements"/>
    </xsl:if>

    <xsl:sequence select="$t:new-line"/>
    <xsl:sequence select="'{'"/>
    <xsl:sequence select="$t:new-line"/>
    <xsl:sequence select="$t:indent"/>
    <xsl:sequence select="t:get-class-members(.)"/>
    <xsl:sequence select="$t:unindent"/>
    <xsl:sequence select="'}'"/>
    <xsl:sequence select="$t:new-line"/>
  </xsl:template>

  <!--
    Generates class members.
      $scope - members scope.
      Returns class member declarations.
  -->
  <xsl:function name="t:get-class-members" as="item()*">
    <xsl:param name="scope" as="element()"/>

    <xsl:variable name="declarations" as="element()*"
      select="t:get-class-declarations($scope)"/>

    <xsl:for-each select="$declarations">
      <xsl:variable name="position" as="xs:integer" select="position()"/>
      <xsl:variable name="previous" as="element()?"
        select="$declarations[$position - 1]"/>

      <xsl:if test="
        ($position > 1) and
        (
          comment or
          self::class-members or $previous/self::class-members or
          not
          (
            (self::field or self::class-field) and
            $previous[self::field or self::class-field] and
            (string(@access) = string($previous/@access))
          )
         )">
        <xsl:sequence select="$t:new-line"/>
      </xsl:if>

      <xsl:apply-templates mode="t:classBodyDeclaration" select="."/>
    </xsl:for-each>
  </xsl:function>

  <!--
    Gets class declarations of an element.
      $element - an element to get class declarations for.
      Retuns class declarations of an element.
  -->
  <xsl:function name="t:get-class-declarations" as="element()*">
    <xsl:param name="element" as="element()"/>

    <xsl:sequence select="
      $element/
      (
        snippet-member |
        static |
        method |
        class-method |
        constructor |
        field |
        class-field |
        class-members
      ) |
      t:get-type-declarations($element)"/>
  </xsl:function>

  <!--
    Mode "t:typeDeclaration". Enum declaration.
  -->
  <xsl:template mode="t:typeDeclaration" match="enum">
    <xsl:sequence select="t:get-comments(.)"/>
    <xsl:sequence select="t:get-annotations(., false())"/>

    <xsl:variable name="name" as="xs:string" select="@name"/>
    <xsl:variable name="implements" as="item()*"
      select="t:get-class-implements(.)"/>

    <xsl:sequence select="t:get-modifiers(.)"/>
    <xsl:sequence select="'enum'"/>
    <xsl:sequence select="' '"/>
    <xsl:sequence select="$name"/>

    <xsl:if test="exists($implements)">
      <xsl:sequence select="' '"/>
      <xsl:sequence select="$implements"/>
    </xsl:if>

    <xsl:sequence select="$t:new-line"/>

    <xsl:sequence select="'{'"/>
    <xsl:sequence select="$t:new-line"/>

    <xsl:sequence select="$t:indent"/>

    <xsl:variable name="constants" as="element()*" select="constant"/>

    <xsl:for-each select="$constants">
      <xsl:sequence select="t:get-comments(.)"/>
      <xsl:sequence select="t:get-annotations(., false())"/>

      <xsl:variable name="value" as="xs:string" select="@value"/>
      <xsl:variable name="arguments" as="element()?" select="arguments"/>
      <xsl:variable name="class-declarations" as="element()*"
        select="t:get-class-declarations(.)"/>

      <xsl:variable name="tokens" as="item()*">
        <xsl:sequence select="$value"/>

        <xsl:if test="exists($arguments)">
          <xsl:sequence select="'('"/>
          <xsl:sequence select="t:get-expression-list($arguments)"/>
          <xsl:sequence select="')'"/>
        </xsl:if>

        <xsl:if test="(position() != last()) and empty($class-declarations)">
          <xsl:sequence select="','"/>
        </xsl:if>

        <xsl:sequence select="$t:new-line"/>
      </xsl:variable>

      <xsl:sequence select="t:indent-from-second-line($tokens)"/>

      <xsl:if test="$class-declarations">
        <xsl:sequence select="'{'"/>
        <xsl:sequence select="$t:new-line"/>

        <xsl:sequence select="$t:indent"/>

        <xsl:for-each select="$class-declarations">
          <xsl:if test="position() > 1">
            <xsl:sequence select="$t:new-line"/>
          </xsl:if>

          <xsl:apply-templates mode="t:classBodyDeclaration" select="."/>
        </xsl:for-each>

        <xsl:sequence select="$t:unindent"/>

        <xsl:sequence select="'}'"/>

        <xsl:if test="position() != last()">
          <xsl:sequence select="','"/>
        </xsl:if>

        <xsl:sequence select="$t:new-line"/>
      </xsl:if>
    </xsl:for-each>

    <xsl:if test="exists($constants) and exists(t:get-class-declarations(.))">
      <xsl:sequence select="$t:new-line"/>
    </xsl:if>

    <xsl:sequence select="t:get-class-members(.)"/>
    <xsl:sequence select="$t:unindent"/>
    <xsl:sequence select="'}'"/>
    <xsl:sequence select="$t:new-line"/>
  </xsl:template>

  <!--
    Mode "t:typeDeclaration". Interface declaration.
  -->
  <xsl:template mode="t:typeDeclaration" match="interface">
    <xsl:sequence select="t:get-comments(.)"/>
    <xsl:sequence select="t:get-annotations(., false())"/>

    <xsl:variable name="name" as="xs:string" select="@name"/>
    <xsl:variable name="extends" as="item()*"
      select="t:get-interface-extends(.)"/>

    <xsl:sequence select="t:get-modifiers(.)"/>
    <xsl:sequence select="'interface'"/>
    <xsl:sequence select="' '"/>
    <xsl:sequence select="$name"/>

    <xsl:sequence select="t:get-type-parameters(.)"/>

    <xsl:if test="exists($extends)">
      <xsl:sequence select="' '"/>
      <xsl:sequence select="$extends"/>
    </xsl:if>

    <xsl:sequence select="$t:new-line"/>
    <xsl:sequence select="'{'"/>
    <xsl:sequence select="$t:new-line"/>
    <xsl:sequence select="$t:indent"/>
    <xsl:sequence select="t:get-interface-members(.)"/>
    <xsl:sequence select="$t:unindent"/>
    <xsl:sequence select="'}'"/>
    <xsl:sequence select="$t:new-line"/>
  </xsl:template>

  <!--
    Generates interface members.
      $scope - members scope.
      Returns interface member declarations.
  -->
  <xsl:function name="t:get-interface-members" as="item()*">
    <xsl:param name="scope" as="element()"/>

    <xsl:variable name="declarations" as="element()*"
      select="t:get-interface-declarations($scope)"/>

    <xsl:for-each select="$declarations">
      <xsl:variable name="position" as="xs:integer" select="position()"/>
      <xsl:variable name="previous" as="element()?"
        select="$declarations[$position - 1]"/>

      <xsl:if test="
        ($position > 1) and
        (
          comment or
          self::interface-members or $previous/self::interface-members or
          self::method/block or self::interface-method/block or
          $previous/self::method/block or $previous/self::interface-method/block or
          not
          (
            (self::field or self::class-field) and
            $previous[self::field or self::interface-field] and
            (@access = $previous/@access) or
            empty(@access) and empty($previous/@access)
          )
         )">
        <xsl:sequence select="$t:new-line"/>
      </xsl:if>

      <xsl:apply-templates mode="t:interfaceBodyDeclaration" select="."/>
    </xsl:for-each>
  </xsl:function>

  <!--
    Gets interface declarations of an element.
      $element - an element to get interface declarations for.
      Retuns interface declarations of an element.
  -->
  <xsl:function name="t:get-interface-declarations">
    <xsl:param name="element" as="element()"/>

    <xsl:sequence select="
      $element/
      (
        snippet-member |
        interface-snippet-member |
        method |
        interface-method |
        field |
        interface-field |
        interface-members
      ) |
      t:get-type-declarations($element)"/>
  </xsl:function>

  <!--
    Mode "t:typeDeclaration". Annotation declaration.
  -->
  <xsl:template mode="t:typeDeclaration" match="annotation-decl">
    <xsl:sequence select="t:get-comments(.)"/>
    <xsl:sequence select="t:get-annotations(., false())"/>

    <xsl:variable name="name" as="xs:string" select="@name"/>

    <xsl:sequence select="t:get-modifiers(.)"/>
    <xsl:sequence select="'@interface'"/>
    <xsl:sequence select="' '"/>
    <xsl:sequence select="$name"/>
    <xsl:sequence select="$t:new-line"/>
    <xsl:sequence select="'{'"/>
    <xsl:sequence select="$t:new-line"/>
    <xsl:sequence select="$t:indent"/>
    <xsl:sequence select="t:get-annotation-members(.)"/>
    <xsl:sequence select="$t:unindent"/>
    <xsl:sequence select="'}'"/>
    <xsl:sequence select="$t:new-line"/>
  </xsl:template>

  <!--
    Generates annotation members.
      $scope - members scope.
      Returns annotation member declarations.
  -->
  <xsl:function name="t:get-annotation-members" as="item()*">
    <xsl:param name="scope" as="element()"/>

    <xsl:variable name="declarations" as="element()*"
      select="t:get-annotation-declarations($scope)"/>

    <xsl:for-each select="$declarations">
      <xsl:if test="position() > 1">
        <xsl:sequence select="$t:new-line"/>
      </xsl:if>

      <xsl:apply-templates mode="t:annotationTypeElementDeclaration" 
        select="."/>
    </xsl:for-each>
  </xsl:function>

  <!--
    Gets interface declarations of an element.
      $element - an element to get interface declarations for.
      Retuns interface declarations of an element.
  -->
  <xsl:function name="t:get-annotation-declarations" as="element()*">
    <xsl:param name="element" as="element()"/>

    <xsl:sequence select="
      $element/
      (
        snippet-member |
        method |
        annotation-method |
        field |
        annotation-field |
        annotation-members
      ) |
      t:get-type-declarations($element)"/>
  </xsl:function>

  <!--
    Gest modifiers for a specified element.
      $element - an element to get modifiers for.
      Returns a token sequence that defines element's modifiers.
  -->
  <xsl:function name="t:get-modifiers" as="item()*">
    <xsl:param name="element" as="element()"/>

    <xsl:variable name="access" as="xs:string?"
      select="$element/@access"/>
    <xsl:variable name="static" as="xs:boolean?"
      select="$element/@static"/>
    <xsl:variable name="override" as="xs:string?"
      select="$element/@override"/>
    <xsl:variable name="native" as="xs:boolean?"
      select="$element/@native"/>
    <xsl:variable name="synchronized" as="xs:boolean?"
      select="$element/@synchronized"/>
    <xsl:variable name="transient" as="xs:boolean?"
      select="$element/@transient"/>
    <xsl:variable name="volatile" as="xs:boolean?"
      select="$element/@volatile"/>
    <xsl:variable name="strictfp" as="xs:boolean?"
      select="$element/@strictfp"/>

    <xsl:if test="exists($access) and ($access != 'package')">
      <xsl:sequence select="string($access)"/>
      <xsl:sequence select="' '"/>
    </xsl:if>

    <xsl:if test="$static">
      <xsl:sequence select="'static'"/>
      <xsl:sequence select="' '"/>
    </xsl:if>

    <xsl:if test="exists($override) and ($override != 'virtual')">
      <xsl:sequence select="string($override)"/>
      <xsl:sequence select="' '"/>
    </xsl:if>

    <xsl:if test="$native">
      <xsl:sequence select="'native'"/>
      <xsl:sequence select="' '"/>
    </xsl:if>

    <xsl:if test="$synchronized">
      <xsl:sequence select="'synchronized'"/>
      <xsl:sequence select="' '"/>
    </xsl:if>

    <xsl:if test="$transient">
      <xsl:sequence select="'transient'"/>
      <xsl:sequence select="' '"/>
    </xsl:if>

    <xsl:if test="$volatile">
      <xsl:sequence select="'volatile'"/>
      <xsl:sequence select="' '"/>
    </xsl:if>

    <xsl:if test="$strictfp">
      <xsl:sequence select="'strictfp'"/>
      <xsl:sequence select="' '"/>
    </xsl:if>
  </xsl:function>

  <!--
    Gets optional type parameter for the element.
      $element - an element to get type parameters for.
      Returns parameter tokens.
  -->
  <xsl:function name="t:get-type-parameters" as="item()*">
    <xsl:param name="element" as="element()"/>

    <xsl:variable name="type-parameters" as="element()?"
      select="$element/type-parameters"/>
    <xsl:variable name="parameters" as="element()*"
      select="$type-parameters/parameter"/>

    <xsl:if test="$parameters">
      <xsl:sequence select="'&lt;'"/>

      <xsl:for-each select="$parameters">
        <xsl:sequence select="t:get-type-parameter(.)"/>

        <xsl:if test="position() != last()">
          <xsl:sequence select="','"/>
          <xsl:sequence select="' '"/>
        </xsl:if>
      </xsl:for-each>

      <xsl:sequence select="'>'"/>
    </xsl:if>
  </xsl:function>

  <!--
    Gets type parameter.
      $parameter - a type parameter
      Returns type parameter tokens.
  -->
  <xsl:function name="t:get-type-parameter" as="item()*">
    <xsl:param name="parameter" as="element()"/>

    <xsl:variable name="name" as="xs:string" select="$parameter/@name"/>
    <xsl:variable name="types" as="element()*" select="$parameter/type"/>

    <xsl:sequence select="t:tokenize($name)"/>

    <xsl:if test="$types">
      <xsl:sequence select="' '"/>
      <xsl:sequence select="'extends'"/>
      <xsl:sequence select="' '"/>

      <xsl:for-each select="$types">
        <xsl:sequence select="t:get-type(.)"/>

        <xsl:if test="position() != last()">
          <xsl:sequence select="' '"/>
          <xsl:sequence select="'&amp;'"/>
          <xsl:sequence select="' '"/>
        </xsl:if>
      </xsl:for-each>
    </xsl:if>
  </xsl:function>

  <!--
    Gets a comma separated type list.
      $types - a sequence of types.
      Returns a comma separated type list of tokens.
  -->
  <xsl:function name="t:get-type-list" as="item()+">
    <xsl:param name="types" as="element()+"/>

    <xsl:for-each select="$types">
      <xsl:sequence select="t:get-type(.)"/>

      <xsl:if test="position() != last()">
        <xsl:sequence select="','"/>
        <xsl:sequence select="' '"/>
      </xsl:if>
    </xsl:for-each>
  </xsl:function>

  <!--
    Gets type name for the type element.
      $type - a type element.
      Returns type name as sequence of tokens.
  -->
  <xsl:function name="t:get-type" as="item()*">
    <xsl:param name="type" as="element()"/>

    <xsl:sequence select="t:get-type($type, ())"/>
  </xsl:function>

  <!--
    Gets type name for the type element.
      $type - a type element.
      $arity-override - defines arity override.
      Returns type name as sequence of tokens.
  -->
  <xsl:function name="t:get-type" as="item()*">
    <xsl:param name="type" as="element()"/>
    <xsl:param name="arity-override" as="xs:integer?"/>

    <xsl:variable name="package" as="xs:string?" select="$type/@package"/>
    <xsl:variable name="name" as="xs:string" select="$type/@name"/>
    <xsl:variable name="container" as="element()?" select="$type/type"/>
    <xsl:variable name="arguments" as="element()*" select="$type/argument"/>

    <xsl:variable name="arity" as="xs:integer?" select="
      if (exists($arity-override)) then
        $arity-override
      else
        $type/@arity"/>

    <xsl:if test="$arity lt 0">
      <xsl:sequence select="error(xs:QName('invalid-type-arity'))"/>
    </xsl:if>

    <xsl:choose>
      <xsl:when test="$container">
        <xsl:sequence select="t:get-type($container, 0)"/>
        <xsl:sequence select="'.'"/>
      </xsl:when>
      <xsl:when test="exists($package)">
        <xsl:sequence select="t:tokenize($package)"/>
        <xsl:sequence select="'.'"/>
      </xsl:when>
    </xsl:choose>

    <xsl:sequence select="$name"/>

    <xsl:if test="$arguments">
      <xsl:sequence select="'&lt;'"/>

      <xsl:choose>
        <xsl:when test="
          (count($arguments) = 1) and 
          empty($arguments/type) and 
          empty($arguments/@match)">
          <!-- Diamond syntax. -->
        </xsl:when>
        <xsl:otherwise>
          <xsl:for-each select="$arguments">
            <xsl:sequence select="t:get-type-argument(.)"/>

            <xsl:if test="position() != last()">
              <xsl:sequence select="','"/>
              <xsl:sequence select="' '"/>
            </xsl:if>
          </xsl:for-each>
        </xsl:otherwise>
      </xsl:choose>

      <xsl:sequence select="'>'"/>
    </xsl:if>

    <xsl:if test="exists($arity)">
      <xsl:for-each select="1 to $arity">
        <xsl:sequence select="'['"/>
        <xsl:sequence select="']'"/>
      </xsl:for-each>
    </xsl:if>
  </xsl:function>

  <!--
    Gets type argument.
      $argument - a type argument.
      Returns type argument tokens.
  -->
  <xsl:function name="t:get-type-argument" as="item()*">
    <xsl:param name="argument" as="element()"/>

    <xsl:variable name="type" as="element()?" select="$argument/type"/>
    <xsl:variable name="match" as="xs:string?" select="$argument/@match"/>

    <xsl:choose>
      <xsl:when test="not($match) or $match = 'precise'">
        <xsl:sequence select="t:get-type($type)"/>
      </xsl:when>
      <xsl:when test="$match = 'any'">
        <xsl:sequence select="exactly-one(($type, '?'))"/>
      </xsl:when>
      <xsl:when test="$match = 'extends'">
        <xsl:sequence select="'?'"/>
        <xsl:sequence select="' '"/>
        <xsl:sequence select="'extends'"/>
        <xsl:sequence select="' '"/>
        <xsl:sequence select="t:get-type($type)"/>
      </xsl:when>
      <xsl:when test="$match = 'super'">
        <xsl:sequence select="'?'"/>
        <xsl:sequence select="' '"/>
        <xsl:sequence select="'super'"/>
        <xsl:sequence select="' '"/>
        <xsl:sequence select="t:get-type($type)"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:sequence select="error(xs:QName('invalid-match-value'), $match)"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:function>

  <!--
    Gets classe's 'extends' clause.
      $element - an element to get 'extends' clause for.
      Returns 'extends' clause tokens.
  -->
  <xsl:function name="t:get-class-extends" as="item()*">
    <xsl:param name="element" as="element()"/>

    <xsl:variable name="extends" as="element()?" select="$element/extends"/>

    <xsl:if test="$extends">
      <xsl:sequence select="'extends'"/>
      <xsl:sequence select="' '"/>
      <xsl:sequence select="t:get-type($extends/type)"/>
    </xsl:if>
  </xsl:function>

  <!--
    Gets classe's 'implements' clause.
      $element - an element to get 'implements' clause for.
      Returns 'implements' clause tokens.
  -->
  <xsl:function name="t:get-class-implements" as="item()*">
    <xsl:param name="element" as="element()"/>

    <xsl:variable name="implements" as="element()?"
      select="$element/implements"/>

    <xsl:if test="$implements">
      <xsl:sequence select="'implements'"/>
      <xsl:sequence select="' '"/>
      <xsl:sequence select="t:get-type-list($implements/type)"/>
    </xsl:if>
  </xsl:function>

  <!--
    Gets interface's 'extends' clause.
      $element - an element to get 'extends' clause for.
      Returns 'extends' clause tokens.
  -->
  <xsl:function name="t:get-interface-extends" as="item()*">
    <xsl:param name="element" as="element()"/>

    <xsl:variable name="extends" as="element()?"
      select="$element/extends"/>

    <xsl:if test="$extends">
      <xsl:sequence select="'extends'"/>
      <xsl:sequence select="' '"/>
      <xsl:sequence select="t:get-type-list($extends/type)"/>
    </xsl:if>
  </xsl:function>

  <!--
    Mode "interfaceBodyDeclaration".
  -->
  <xsl:template mode="t:interfaceBodyDeclaration" match="@*|node()">
    <xsl:apply-templates mode="t:typeDeclaration" select="."/>
  </xsl:template>

  <!--
    Mode "interfaceBodyDeclaration". Interface declaration scope.
  -->
  <xsl:template mode="t:interfaceBodyDeclaration" match="interface-members">
    <xsl:variable name="comments" as="item()*" select="t:get-comments(.)"/>

    <xsl:if test="exists($comments)">
      <xsl:sequence select="$comments"/>
      <xsl:sequence select="$t:new-line"/>
    </xsl:if>

    <xsl:sequence select="t:get-interface-members(.)"/>
  </xsl:template>

  <!--
    Mode "interfaceBodyDeclaration". Snippet class member.
  -->
  <xsl:template mode="t:interfaceBodyDeclaration"
    match="snippet-member | interface-snippet-member">
    <xsl:variable name="value" as="xs:string" select="@value"/>

    <xsl:sequence select="t:get-comments(.)"/>
    <xsl:sequence select="t:tokenize($value)"/>
  </xsl:template>

  <!--
    Mode "interfaceBodyDeclaration". Interface method.
  -->
  <xsl:template mode="t:interfaceBodyDeclaration"
    match="method | interface-method">
    <xsl:sequence select="t:get-comments(.)"/>
    <xsl:sequence select="t:get-annotations(., false())"/>

    <xsl:variable name="static" as="xs:boolean?" select="@static"/>
    <xsl:variable name="body" as="element()?" 
      select="(block, $t:empty-block[$static])[1]"/>
    <xsl:variable name="throws" as="item()*" select="t:get-throws(.)"/>

    <xsl:variable name="name" as="xs:string" select="@name"/>
    <xsl:variable name="type-parameters" as="item()*"
      select="t:get-type-parameters(.)"/>

    <xsl:if test="$body and not($static)">
      <xsl:sequence select="'default'"/>
      <xsl:sequence select="' '"/>
    </xsl:if>

    <xsl:sequence select="t:get-modifiers(.)"/>

    <xsl:if test="$type-parameters">
      <xsl:sequence select="$type-parameters"/>
      <xsl:sequence select="' '"/>
    </xsl:if>

    <xsl:sequence select="t:get-returns(.)"/>
    <xsl:sequence select="' '"/>

    <xsl:sequence select="$name"/>
    <xsl:sequence select="'('"/>

    <xsl:variable name="tokens" as="item()*">
      <xsl:sequence select="t:get-method-parameters(.)"/>
      <xsl:sequence select="')'"/>

      <xsl:if test="empty($throws) and empty($body)">
        <xsl:sequence select="';'"/>
      </xsl:if>
    </xsl:variable>

    <xsl:choose>
      <xsl:when test="t:is-multiline($tokens)">
        <xsl:sequence select="$t:indent"/>
        <xsl:sequence select="$tokens"/>
        <xsl:sequence select="$t:new-line"/>
        <xsl:sequence select="$t:unindent"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:sequence select="$tokens"/>
        <xsl:sequence select="$t:new-line"/>
      </xsl:otherwise>
    </xsl:choose>

    <xsl:if test="exists($throws)">
      <xsl:sequence select="$t:indent"/>

      <xsl:sequence select="$throws"/>

      <xsl:if test="empty($body)">
        <xsl:sequence select="';'"/>
      </xsl:if>

      <xsl:sequence select="$t:new-line"/>

      <xsl:sequence select="$t:unindent"/>
    </xsl:if>

    <xsl:sequence select="$body/t:get-block(.)"/>
  </xsl:template>

  <!--
    Mode "interfaceBodyDeclaration". Interface field.
  -->
  <xsl:template mode="t:interfaceBodyDeclaration"
    match="field | interface-field">
    <xsl:sequence select="t:get-comments(.)"/>
    <xsl:sequence select="t:get-annotations(., false())"/>

    <xsl:variable name="name" as="xs:string" select="@name"/>
    <xsl:variable name="initializer" as="item()*"
      select="t:get-initializer(., false())"/>

    <xsl:sequence select="t:get-modifiers(.)"/>
    <xsl:sequence select="t:get-type(type)"/>
    <xsl:sequence select="' '"/>
    <xsl:sequence select="$name"/>

    <xsl:if test="exists($initializer)">
      <xsl:variable name="tokens" as="item()*">
        <xsl:sequence select="' '"/>
        <xsl:sequence select="'='"/>
        <xsl:sequence select="' '"/>
        <xsl:sequence select="$initializer"/>
      </xsl:variable>

      <xsl:sequence select="t:indent-from-second-line($tokens)"/>
    </xsl:if>

    <xsl:sequence select="';'"/>
    <xsl:sequence select="$t:new-line"/>
  </xsl:template>

  <!--
    Mode "annotationTypeElementDeclaration".
  -->
  <xsl:template mode="t:annotationTypeElementDeclaration" match="@*|node()">
    <xsl:apply-templates mode="t:interfaceBodyDeclaration" select="."/>
  </xsl:template>

  <!--
    Mode "annotationTypeElementDeclaration". Annotation members.
  -->
  <xsl:template mode="t:annotationTypeElementDeclaration"
    match="annotation-members">
    <xsl:variable name="comments" as="item()*" select="t:get-comments(.)"/>

    <xsl:if test="exists($comments)">
      <xsl:sequence select="$comments"/>
      <xsl:sequence select="$t:new-line"/>
    </xsl:if>

    <xsl:sequence select="t:get-annotation-members(.)"/>
  </xsl:template>

  <!--
    Mode "annotationTypeElementDeclaration". Annotation method.
  -->
  <xsl:template mode="t:annotationTypeElementDeclaration"
    match="method | annotation-method">
    <xsl:sequence select="t:get-comments(.)"/>
    <xsl:sequence select="t:get-annotations(., false())"/>

    <xsl:variable name="tokens" as="item()*">
      <xsl:variable name="name" as="xs:string" select="@name"/>
      <xsl:variable name="type" as="element()" select="type"/>
      <xsl:variable name="default" as="element()?" select="default"/>

      <xsl:sequence select="t:get-modifiers(.)"/>
      <xsl:sequence select="t:get-type($type)"/>
      <xsl:sequence select="' '"/>
      <xsl:sequence select="$name"/>
      <xsl:sequence select="'('"/>
      <xsl:sequence select="')'"/>

      <xsl:if test="exists($default)">
        <xsl:if test="exists($default/@name)">
          <xsl:sequence select="error(xs:QName('invalid-default'))"/>
        </xsl:if>

        <xsl:sequence select="' '"/>
        <xsl:sequence select="'default'"/>
        <xsl:sequence select="' '"/>
        <xsl:sequence select="t:get-annotation-parameter($default)"/>
      </xsl:if>

      <xsl:sequence select="';'"/>
    </xsl:variable>

    <xsl:sequence select="t:indent-from-second-line($tokens)"/>
    <xsl:sequence select="$t:new-line"/>
  </xsl:template>

  <!--
    Mode "t:classBodyDeclaration".
  -->
  <xsl:template mode="t:classBodyDeclaration" match="@*|node()">
    <xsl:apply-templates mode="t:typeDeclaration" select="."/>
  </xsl:template>

  <!--
    Mode "t:classBodyDeclaration". Class declaration members.
  -->
  <xsl:template mode="t:classBodyDeclaration" match="class-members">
    <xsl:variable name="comments" as="item()*" select="t:get-comments(.)"/>

    <xsl:if test="exists($comments)">
      <xsl:sequence select="$comments"/>
      <xsl:sequence select="$t:new-line"/>
    </xsl:if>

    <xsl:sequence select="t:get-class-members(.)"/>
  </xsl:template>

  <!--
    Mode "t:classBodyDeclaration". Snippet class member.
  -->
  <xsl:template mode="t:classBodyDeclaration"
    match="snippet-member | class-snippet-member">
    <xsl:variable name="value" as="xs:string" select="@value"/>

    <xsl:sequence select="t:get-comments(.)"/>
    <xsl:sequence select="t:tokenize($value)"/>
  </xsl:template>

  <!--
    Mode "t:classBodyDeclaration". Deprecated class static block.
  -->
  <xsl:template mode="t:classBodyDeclaration" match="static">
    <xsl:sequence select="
      error
      (
        xs:QName('obsolete-static-block'), 
        'Use class-initializer instead.'
      )"/>
  </xsl:template>

  <!--
    Mode "t:classBodyDeclaration". Class initializer.
  -->
  <xsl:template mode="t:classBodyDeclaration" match="class-initializer">
    <xsl:variable name="static" as="xs:boolean?" select="@static"/>

    <xsl:sequence select="t:get-comments(.)"/>

    <xsl:if test="$static">
      <xsl:sequence select="'static'"/>
      <xsl:sequence select="$t:new-line"/>
    </xsl:if>

    <xsl:sequence select="t:get-block(block)"/>
  </xsl:template>

  <!--
    Mode "t:classBodyDeclaration". Class method.
  -->
  <xsl:template mode="t:classBodyDeclaration"
    match="method | class-method">
    <xsl:sequence select="t:get-comments(.)"/>
    <xsl:sequence select="t:get-annotations(., false())"/>

    <xsl:variable name="throws" as="item()*" select="t:get-throws(.)"/>

    <xsl:variable name="name" as="xs:string" select="@name"/>
    <xsl:variable name="type-parameters" as="item()*"
      select="t:get-type-parameters(.)"/>

    <xsl:sequence select="t:get-modifiers(.)"/>

    <xsl:if test="exists($type-parameters)">
      <xsl:sequence select="$type-parameters"/>
      <xsl:sequence select="' '"/>
    </xsl:if>

    <xsl:sequence select="t:get-returns(.)"/>
    <xsl:sequence select="' '"/>

    <xsl:sequence select="$name"/>
    <xsl:sequence select="'('"/>

    <xsl:variable name="tokens" as="item()*"
      select="t:get-method-parameters(.)"/>

    <xsl:choose>
      <xsl:when test="t:is-multiline($tokens)">
        <xsl:sequence select="$t:indent"/>
        <xsl:sequence select="$tokens"/>
        <xsl:sequence select="$t:unindent"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:sequence select="$tokens"/>
      </xsl:otherwise>
    </xsl:choose>

    <xsl:sequence select="')'"/>
    <xsl:sequence select="$t:new-line"/>

    <xsl:if test="exists($throws)">
      <xsl:sequence select="$t:indent"/>

      <xsl:sequence select="$throws"/>
      <xsl:sequence select="$t:new-line"/>

      <xsl:sequence select="$t:unindent"/>
    </xsl:if>

    <xsl:sequence select="t:get-block(block)"/>
  </xsl:template>

  <!--
    Mode "t:classBodyDeclaration". Constructor.
  -->
  <xsl:template mode="t:classBodyDeclaration" match="constructor">
    <xsl:sequence select="t:get-comments(.)"/>
    <xsl:sequence select="t:get-annotations(., false())"/>

    <xsl:variable name="throws" as="item()*" select="t:get-throws(.)"/>

    <xsl:variable name="tokens" as="item()*">
      <xsl:variable name="name" as="xs:string" select="@name"/>
      <xsl:variable name="type-parameters" as="item()*"
        select="t:get-type-parameters(.)"/>

      <xsl:sequence select="t:get-modifiers(.)"/>

      <xsl:if test="$type-parameters">
        <xsl:sequence select="$type-parameters"/>
        <xsl:sequence select="' '"/>
      </xsl:if>

      <xsl:sequence select="$name"/>
      <xsl:sequence select="'('"/>
      <xsl:sequence select="t:get-method-parameters(.)"/>
      <xsl:sequence select="')'"/>
    </xsl:variable>

    <xsl:sequence select="t:indent-from-second-line($tokens)"/>
    <xsl:sequence select="$t:new-line"/>

    <xsl:if test="exists($throws)">
      <xsl:sequence select="$t:indent"/>

      <xsl:sequence select="$throws"/>
      <xsl:sequence select="$t:new-line"/>

      <xsl:sequence select="$t:unindent"/>
    </xsl:if>

    <xsl:sequence select="t:get-block(block)"/>
  </xsl:template>

  <!--
    Mode "t:classBodyDeclaration". Class field.
  -->
  <xsl:template mode="t:classBodyDeclaration"
    match="field | class-field">
    <xsl:sequence select="t:get-comments(.)"/>
    <xsl:sequence select="t:get-annotations(., false())"/>

    <xsl:variable name="name" as="xs:string" select="@name"/>
    <xsl:variable name="initializer" as="item()*"
      select="t:get-initializer(., false())"/>

    <xsl:sequence select="t:get-modifiers(.)"/>
    <xsl:sequence select="t:get-type(type)"/>
    <xsl:sequence select="' '"/>
    <xsl:sequence select="$name"/>

    <xsl:if test="exists($initializer)">
      <xsl:variable name="tokens" as="item()*">
        <xsl:sequence select="' '"/>
        <xsl:sequence select="'='"/>
        <xsl:sequence select="' '"/>
        <xsl:sequence select="$initializer"/>
      </xsl:variable>

      <xsl:sequence select="t:indent-from-second-line($tokens)"/>
    </xsl:if>

    <xsl:sequence select="';'"/>
    <xsl:sequence select="$t:new-line"/>
  </xsl:template>

  <!--
    Get methods return clause.
      $element - an element to get return clause for.
      Returns a token sequence that defines return type.
  -->
  <xsl:function name="t:get-returns" as="item()+">
    <xsl:param name="element" as="element()"/>

    <xsl:variable name="returns" as="element()?" select="$element/returns"/>

    <xsl:choose>
      <xsl:when test="$returns">
        <xsl:sequence select="t:get-type($returns/type)"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:sequence select="'void'"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:function>

  <!--
    Get method parameters.
      $element - an element to get parameters for.
      Returns a token sequence of parameters.
  -->
  <xsl:function name="t:get-method-parameters" as="item()*">
    <xsl:param name="element" as="element()"/>

    <xsl:variable name="parameters" as="element()?"
      select="$element/parameters"/>
    <xsl:variable name="vararg" as="xs:boolean?"
      select="$parameters/@vararg"/>
    <xsl:variable name="formal-parameters" as="element()*"
      select="$parameters/parameter"/>

    <xsl:variable name="tokens" as="item()*">
      <xsl:for-each select="$formal-parameters">
        <xsl:variable name="name" as="xs:string" select="@name"/>
        <xsl:variable name="final" as="xs:boolean?" select="@final"/>
        <xsl:variable name="type" as="element()" select="type"/>

        <xsl:sequence select="t:get-annotations(., true())"/>

        <xsl:if test="$final">
          <xsl:sequence select="'final'"/>
          <xsl:sequence select="' '"/>
        </xsl:if>

        <xsl:choose>
          <xsl:when test="(position() = last()) and $vararg">
            <xsl:variable name="arity" as="xs:integer"
              select="$type/@arity"/>

            <xsl:sequence select="t:get-type($type, $arity - 1)"/>
            <xsl:sequence select="'...'"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:sequence select="t:get-type($type)"/>
          </xsl:otherwise>
        </xsl:choose>

        <xsl:sequence select="' '"/>
        <xsl:sequence select="$name"/>

        <xsl:if test="position() != last()">
          <xsl:sequence select="','"/>
        </xsl:if>

        <xsl:sequence select="$t:terminator"/>
      </xsl:for-each>
    </xsl:variable>

    <xsl:sequence select="
      t:reformat-tokens($tokens, 3, ' ', $t:new-line, false(), false())"/>
  </xsl:function>

  <!--
    Get method's throws clause.
      $element - an element to get throws clause for.
      Returns optional token sequence that defines throws clause.
  -->
  <xsl:function name="t:get-throws" as="item()*">
    <xsl:param name="element" as="element()"/>

    <xsl:variable name="throws" as="element()?" select="$element/throws"/>

    <xsl:if test="$throws">
      <xsl:sequence select="'throws'"/>
      <xsl:sequence select="' '"/>
      <xsl:sequence select="t:get-type-list($throws/type)"/>
    </xsl:if>
  </xsl:function>

  <!--
    Gets comments for an element.
      $element - an element to get comments for.
      Returns comments as sequence of tokens.
  -->
  <xsl:function name="t:get-comments" as="item()*">
    <xsl:param name="element" as="element()"/>

    <xsl:variable name="comments" as="element()*" select="$element/comment"/>

    <xsl:for-each select="$comments">
      <xsl:variable name="doc" as="xs:boolean"
        select="xs:boolean(@doc) and empty(* except (meta, para))"/>

      <xsl:if test="$doc">
        <xsl:sequence select="$t:begin-doc"/>
        <xsl:sequence select="$t:new-line"/>
      </xsl:if>

      <xsl:apply-templates mode="t:get-comment">
        <xsl:with-param name="doc" select="$doc"/>
      </xsl:apply-templates>

      <xsl:if test="$doc">
        <xsl:sequence select="$t:end-doc"/>
        <xsl:sequence select="$t:new-line"/>
      </xsl:if>
    </xsl:for-each>
  </xsl:function>

  <!--
    Mode "t:get-comment". Default match.
  -->
  <xsl:template mode="t:get-comment" match="*"/>

  <!--
    Mode "t:get-comment".
    Generates comment for a literal text.
      $doc - true for documentation comment, and false otherwise.
  -->
  <xsl:template mode="t:get-comment" match="text()">
    <xsl:param name="doc" as="xs:boolean"/>

    <xsl:variable name="text" as="xs:string?" select="t:trim(.)"/>

    <xsl:if test="$text">
      <xsl:variable name="tokens" as="item()*" select="t:tokenize($text)"/>

      <xsl:sequence select="
        t:get-comment-lines
        (
          $tokens,
          (
            if ($doc) then 
              $t:doc 
            else 
              $t:comment
          )
        )"/>
    </xsl:if>
  </xsl:template>

  <!--
    Mode "t:get-comment".
    Generates comment for "para" element.
      $doc - true for documentation comment, and false otherwise.
  -->
  <xsl:template mode="t:get-comment" match="para">
    <xsl:param name="doc" as="xs:boolean"/>

    <xsl:variable name="type" as="xs:string?" select="@type"/>
    <xsl:variable name="name" as="xs:string?" select="@name"/>
    <xsl:variable name="pre" as="xs:boolean?" select="@pre"/>

    <xsl:variable name="tokens" as="item()*">
      <xsl:if test="$type">
        <xsl:sequence select="concat('@', $type)"/>
        <xsl:sequence select="' '"/>
      </xsl:if>

      <xsl:if test="$name">
        <xsl:sequence select="$name"/>
        <xsl:sequence select="' '"/>
      </xsl:if>

      <xsl:choose>
        <xsl:when test="$pre">
          <xsl:sequence select="t:tokenize(.)"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:sequence select="t:tokenize(.)"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>

    <xsl:sequence select="
      t:get-comment-lines
      (
        $tokens,
        (
          if (not($doc)) then
            $t:comment
          else if ($type or $name) then
            $t:doc-description
          else
            $t:doc
        )
      )"/>
  </xsl:template>

  <!--
    Mode "t:get-comment".
    Generates comment for "unit" element.
      $doc - true for documentation comment, and false otherwise.
  -->
  <xsl:template mode="t:get-comment" match="unit">
    <xsl:param name="doc" as="xs:boolean"/>

    <xsl:sequence select="
      t:get-comment-lines
      (
        t:tokenize(t:get-lines(t:get-unit(.))),
        $t:comment
      )"/>
  </xsl:template>

  <!--
    Mode "t:get-comment".
    Generates comment for "class-members" element.
      $doc - true for documentation comment, and false otherwise.
  -->
  <xsl:template mode="t:get-comment" match="class-members">
    <xsl:param name="doc" as="xs:boolean"/>

    <xsl:sequence select="
      t:get-comment-lines
      (
        t:tokenize(t:get-lines(t:get-class-members(.))),
        $t:comment
      )"/>
  </xsl:template>

  <!--
    Mode "t:get-comment".
    Generates comment for "interface-members" element.
      $doc - true for documentation comment, and false otherwise.
  -->
  <xsl:template mode="t:get-comment" match="interface-members">
    <xsl:param name="doc" as="xs:boolean"/>

    <xsl:sequence select="
      t:get-comment-lines
      (
        t:tokenize(t:get-lines(t:get-interface-members(.))),
        $t:comment
      )"/>
  </xsl:template>

  <!--
    Mode "t:get-comment".
    Generates comment for "annotation-members" element.
      $doc - true for documentation comment, and false otherwise.
  -->
  <xsl:template mode="t:get-comment" match="annotation-members">
    <xsl:param name="doc" as="xs:boolean"/>

    <xsl:sequence select="
      t:get-comment-lines
      (
        t:tokenize(t:get-lines(t:get-annotation-members(.))),
        $t:comment
      )"/>
  </xsl:template>

  <!--
    Mode "t:get-comment".
    Generates comment for "scope" element.
      $doc - true for documentation comment, and false otherwise.
  -->
  <xsl:template mode="t:get-comment" match="scope">
    <xsl:param name="doc" as="xs:boolean"/>

    <xsl:sequence select="
      t:get-comment-lines
      (
        t:tokenize(t:get-lines(t:get-statement-scope(.))),
        $t:comment
      )"/>
  </xsl:template>

  <!--
    Gets comment line tokens.
      $tokens - comment tokens.
      $prefix - comment prefix.
  -->
  <xsl:function name="t:get-comment-lines" as="item()*">
    <xsl:param name="tokens" as="item()*"/>
    <xsl:param name="prefix" as="item()*"/>

    <xsl:variable name="breaks" as="xs:integer+">
      <xsl:variable name="line-breaks" as="xs:integer*"
        select="index-of($tokens, $t:new-line)"/>
      <xsl:variable name="count" as="xs:integer"
        select="count($tokens)"/>

      <xsl:sequence select="0"/>
      <xsl:sequence select="$line-breaks"/>

      <xsl:if test="empty($line-breaks) or $line-breaks[last()] != $count">
        <xsl:sequence select="$count + 1"/>
      </xsl:if>
    </xsl:variable>

    <xsl:sequence select="
      for $i in 1 to count($breaks) - 1 return
      (
        $prefix,
        t:get-sub-tokens
        (
          $tokens,
          $breaks[$i] + 1,
          $breaks[$i + 1]
        ),
        $t:new-line
      )"/>
  </xsl:function>

  <!-- An empty block.-->
  <xsl:variable name="t:empty-block">
    <block/>
  </xsl:variable>

</xsl:stylesheet>
