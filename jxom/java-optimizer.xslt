<?xml version="1.0" encoding="utf-8"?>
<!--
  This stylesheet provides functions to optimize and simplify jxom expressions.
-->
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:t="http://www.bphx.com/jxom"
  xmlns:p="http://www.bphx.com/jxom/private/java-optimizer"
  xmlns="http://www.bphx.com/java-1.5/2008-02-07"
  xpath-default-namespace="http://www.bphx.com/java-1.5/2008-02-07"
  exclude-result-prefixes="xs t p">

  <!--
    Builds friendly xpath to the element or attribute.
      $node - a node to build xpath for.
      Returns node's xpath.
  -->
  <xsl:function name="t:get-path" as="xs:string">
    <xsl:param name="node" as="node()"/>

    <xsl:sequence select="
      string-join
      (
        if ($node instance of document-node()) then
        (
          '/'
        )
        else
        (
          for $node in $node/ancestor-or-self::* return
          (
            if ($node instance of attribute()) then
            (
              '/@*[self::',
              name($node),
              ']'
            )
            else
            (
              '/*[',
              xs:string(count($node/preceding-sibling::*) + 1),
              '][self::*:',
              name($node),
              ']',
                  
              for 
                $suffix in ('id', 'ref', 'name', 'type'),
                $attribute in 
                  $node/@*[ends-with(lower-case(local-name()), $suffix)]
              return
              (
                '[@', 
                name($attribute), 
                ' = ''',
                xs:string($attribute),
                ''']'
              )
            )
          )
        ),
        ''
      )"/>
  </xsl:function>

  <!-- 
    Splits id list into into a sequence of ids.
      $value - a value to split.
      Returns a sequence of ids.
  -->
  <xsl:function name="t:ids" as="xs:string*">
    <xsl:param name="value" as="xs:string?"/>

    <xsl:sequence select="tokenize($value, '\s+')"/>
  </xsl:function>

  <!-- Java reserved keywords. -->
  <xsl:variable name="t:java-reserved-words" as="xs:string+" select="
    'abstract',   'assert',  'boolean',    'break',
    'byte',       'case',    'catch',      'char',
    'class',      'const',   'continue',   'default',
    'do',         'double',  'else',       'enum',
    'extends',    'false',   'final',      'finally',
    'float',      'for',     'goto',       'if',
    'implements', 'import',  'instanceof', 'int',
    'interface',  'long',    'native',     'new',
    'null',       'package', 'private',    'protected',
    'public',     'return',  'short',      'static',
    'strictfp',   'super',   'switch',     'synchronized',
    'this',       'throw',   'throws',     'transient',
    'true',       'try',     'void',       'volatile',
    'while'"/>

  <!-- Extended reserved names. -->
  <xsl:variable name="t:reserved-names" as="xs:string*">
    <xsl:apply-templates mode="t:call" select="$t:reserved-names-handler"/>
  </xsl:variable>

  <!-- A total set of reserved words. -->
  <xsl:variable name="t:reserved-words" as="xs:string*"
    select="$t:java-reserved-words, $t:reserved-names"/>

  <!-- A handler to collect reserved names. -->
  <xsl:variable name="t:reserved-names-handler" as="element()">
    <t:reserved-names/>
  </xsl:variable>

  <!-- A default handler for the reserved names. -->
  <xsl:template mode="t:call" match="t:reserved-names"/>

  <!--
    Gets a java name for a specified name components.
      $name - a name to generate java name for.
      $default-name - a default name in case a name cannot be built.
      Returns java name (upper case first).
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

  <!-- Predefined types. void. -->
  <xsl:variable name="t:void" as="element()">
    <type name="void"/>
  </xsl:variable>

  <!-- Predefined types. Object. -->
  <xsl:variable name="t:Object" as="element()">
    <type name="Object"/>
  </xsl:variable>

  <!-- Predefined types. char. -->
  <xsl:variable name="t:char" as="element()">
    <type name="char"/>
  </xsl:variable>

  <!-- Predefined types. Character. -->
  <xsl:variable name="t:Character" as="element()">
    <type name="Character"/>
  </xsl:variable>

  <!-- Predefined types. boolean. -->
  <xsl:variable name="t:boolean" as="element()">
    <type name="boolean"/>
  </xsl:variable>

  <!-- Predefined types. Boolean. -->
  <xsl:variable name="t:Boolean" as="element()">
    <type name="Boolean"/>
  </xsl:variable>

  <!-- Predefined types. byte. -->
  <xsl:variable name="t:byte" as="element()">
    <type name="Object"/>
  </xsl:variable>

  <!-- Predefined types. Byte. -->
  <xsl:variable name="t:Byte" as="element()">
    <type name="Byte"/>
  </xsl:variable>

  <!-- Predefined types. short. -->
  <xsl:variable name="t:short" as="element()">
    <type name="short"/>
  </xsl:variable>

  <!-- Predefined types. Short. -->
  <xsl:variable name="t:Short" as="element()">
    <type name="Short"/>
  </xsl:variable>

  <!-- Predefined types. int. -->
  <xsl:variable name="t:int" as="element()">
    <type name="int"/>
  </xsl:variable>

  <!-- Predefined types. Integer. -->
  <xsl:variable name="t:Integer" as="element()">
    <type name="Integer"/>
  </xsl:variable>

  <!-- Predefined types. long. -->
  <xsl:variable name="t:long" as="element()">
    <type name="long"/>
  </xsl:variable>

  <!-- Predefined types. Long. -->
  <xsl:variable name="t:Long" as="element()">
    <type name="Long"/>
  </xsl:variable>

  <!-- Predefined types. float. -->
  <xsl:variable name="t:float" as="element()">
    <type name="float"/>
  </xsl:variable>

  <!-- Predefined types. Float. -->
  <xsl:variable name="t:Float" as="element()">
    <type name="Float"/>
  </xsl:variable>

  <!-- Predefined types. double. -->
  <xsl:variable name="t:double" as="element()">
    <type name="double"/>
  </xsl:variable>

  <!-- Predefined types. Double. -->
  <xsl:variable name="t:Double" as="element()">
    <type name="Double"/>
  </xsl:variable>

  <!-- Predefined types. String. -->
  <xsl:variable name="t:String" as="element()">
    <type name="String"/>
  </xsl:variable>

  <!-- Literal integer zero. -->
  <xsl:variable name="t:zero" as="element()">
    <int value="0"/>
  </xsl:variable>

  <!-- Literal integer one. -->
  <xsl:variable name="t:one" as="element()">
    <int value="0"/>
  </xsl:variable>

  <!--
    Checks whether two types are the same.
    Note we consider types to be equal only and only if
    type1 and type2 are deep equal.
      $type1 - first type.
      $type2 - second type.
      Returns true if types are the same, and false otherwise.
  -->
  <xsl:function name="t:is-same-type" as="xs:boolean">
    <xsl:param name="type1" as="element()"/>
    <xsl:param name="type2" as="element()"/>

    <xsl:sequence select="deep-equal($type1, $type2)"/>
  </xsl:function>

  <!--
    Returns type name for the primitive type, and empty sequence otherwise.
      $type - a type to get name for.
      Returns type name.
  -->
  <xsl:function name="t:get-primitive-type-name" as="xs:string?">
    <xsl:param name="type" as="element()"/>

    <xsl:apply-templates mode="t:get-primitive-type-name" select="$type"/>
  </xsl:function>

  <!--
    Mode "p:get-primitive-type-name". Gets primitive type name.
  -->
  <xsl:template mode="t:get-primitive-type-name" as="xs:string" match="
    type
    [
      @name =
        (
          'Object',
          'String',
          'char',    'Character',
          'boolean', 'Boolean',
          'byte',    'Byte',
          'short',   'Short',
          'int',     'Integer',
          'long',    'Long',
          'float',   'Float',
          'double',  'Double'
        )
    ]
    [
      empty(@package) or (@package = 'java.lang')
    ]">

    <xsl:variable name="arity" as="xs:integer?" select="@arity"/>
    
    <xsl:sequence select="
      if ($arity) then 
        concat(@name, '_', $arity)
      else
        @name"/>
  </xsl:template>

  <!--
    Gets promoted type for two other types.
      $type1 - first type.
      $type2 - second type.
      Returns promoted type.
  -->
  <xsl:function name="t:get-promoted-type" as="element()">
    <xsl:param name="type1" as="element()"/>
    <xsl:param name="type2" as="element()"/>

    <xsl:variable name="name1" as="xs:string?"
      select="t:get-primitive-type-name($type1)"/>

    <xsl:variable name="name2" as="xs:string?"
      select="t:get-primitive-type-name($type2)"/>

    <xsl:choose>
      <xsl:when test="t:is-same-type($type1, $type2)">
        <xsl:sequence select="$type1"/>
      </xsl:when>
      <xsl:when test="exists($name1) and exists($name2)">
        <xsl:variable name="names" as="xs:string+" select="$name1, $name2"/>

        <xsl:sequence select="
          if
          (
            every $name in $names satisfies
              $name =
              (
                'char',    'Character',
                'boolean', 'Boolean',
                'byte',    'Byte',
                'short',   'Short',
                'int',     'Integer',
                'long',    'Long',
                'float',   'Float',
                'double',  'Double'
              )
          )
          then
          (
            (: Promote numbers. :)
            if ($names = ('double', 'Double')) then
              $t:double
            else if ($names = ('float', 'Float')) then
              $t:float
            else if ($names = ('long', 'Long')) then
              $t:long
            else if ($names = ('int', 'Integer')) then
              $t:int
            else if ($names = ('short', 'Short')) then
              $t:short
            else if ($names = ('byte', 'Byte')) then
              $t:byte
            else if ($names = ('char', 'Character')) then
              $t:char
            else
              error
              (
                xs:QName('t:cast'),
                concat
                (
                  'Cannot promote ',
                  $name1,
                  ' and ',
                  $name2,
                  '.'
                )
              )
          )
          else if ($names = 'Object') then
          (
            $t:Object
          )
          else
          (
            error
            (
              xs:QName('t:cast'),
              concat
              (
                'Cannot promote ',
                $name1,
                ' and ',
                $name2,
                '.'
              )
            )
          )"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:sequence select="
          error
          (
            xs:QName('t:cast'),
            concat
            (
              'Cannot promote ',
              $type1/@name,
              ' and ',
              $type2/@name
            )
          )"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:function>

  <!--
    Gets a type of an expression.
      $expression - an expression to get type for.
      $required - true if type is required, and
        false if empty sequence can be returned for unknown type.
      Returns expression's type.
  -->
  <xsl:function name="t:get-type-of" as="element()?">
    <xsl:param name="expression" as="element()"/>
    <xsl:param name="required" as="xs:boolean"/>

    <xsl:apply-templates mode="t:get-type-of" select="$expression">
      <xsl:with-param name="required" tunnel="yes" select="$required"/>
    </xsl:apply-templates>
  </xsl:function>

  <!--
    Mode "t:get-type-of". Error handler.
      $required - true if type is required, and
        false if empty sequence can be returned for unknown type.
  -->
  <xsl:template mode="t:get-type-of" match="@* | node()">
    <xsl:param name="required" tunnel="yes" select="true()"/>

    <xsl:if test="$required">
      <xsl:sequence select="
        error
        (
          xs:QName('t:invalid-type'),
          concat('Unknown type of: ', t:get-path(.))
        )"/>
    </xsl:if>
  </xsl:template>

  <!--
    Mode "t:get-type-of". Meta annotated expression.
  -->
  <xsl:template mode="t:get-type-of" match="*[meta/type]" priority="3">
    <xsl:sequence select="meta/type"/>
  </xsl:template>

  <!--
    Mode "t:get-type-of". boolean expressions and literals.
  -->
  <xsl:template mode="t:get-type-of"
    match="boolean | and | or | not | eq | ne | lt | le | gt | ge">
    <xsl:sequence select="$t:boolean"/>
  </xsl:template>

  <!--
    Mode "t:get-type-of". byte literal.
  -->
  <xsl:template mode="t:get-type-of" match="byte">
    <xsl:sequence select="$t:byte"/>
  </xsl:template>

  <!--
    Mode "t:get-type-of". short literal.
  -->
  <xsl:template mode="t:get-type-of" match="short">
    <xsl:sequence select="$t:short"/>
  </xsl:template>

  <!--
    Mode "t:get-type-of". int literal.
  -->
  <xsl:template mode="t:get-type-of" match="int">
    <xsl:sequence select="$t:int"/>
  </xsl:template>

  <!--
    Mode "t:get-type-of". long literal.
  -->
  <xsl:template mode="t:get-type-of" match="long">
    <xsl:sequence select="$t:long"/>
  </xsl:template>

  <!--
    Mode "t:get-type-of". float literal.
  -->
  <xsl:template mode="t:get-type-of" match="float">
    <xsl:sequence select="$t:float"/>
  </xsl:template>

  <!--
    Mode "t:get-type-of". double literal.
  -->
  <xsl:template mode="t:get-type-of" match="double">
    <xsl:sequence select="$t:double"/>
  </xsl:template>

  <!--
    Mode "t:get-type-of". string literal.
  -->
  <xsl:template mode="t:get-type-of" match="string">
    <xsl:sequence select="$t:String"/>
  </xsl:template>

  <!--
    Mode "t:get-type-of". cast expression.
  -->
  <xsl:template mode="t:get-type-of" match="cast">
    <xsl:sequence select="type"/>
  </xsl:template>

  <!--
    Mode "t:get-type-of". null literal.
  -->
  <xsl:template mode="t:get-type-of" match="null">
    <xsl:sequence select="$t:Object"/>
  </xsl:template>

  <!--
    Mode "t:get-type-of". new-object expression.
  -->
  <xsl:template mode="t:get-type-of" match="new-object">
    <xsl:sequence select="type"/>
  </xsl:template>

  <!--
    Mode "t:get-type-of". Unary expressions.
      $required - true if type is required, and
        false if empty sequence can be returned for unknown type.
  -->
  <xsl:template mode="t:get-type-of"
    match="scope-expression | paren | neg | inc | dec | plus">
    <xsl:param name="required" tunnel="yes" as="xs:boolean" select="true()"/>

    <xsl:sequence select="t:get-type-of(t:get-java-element(.), $required)"/>
  </xsl:template>

  <!--
    Mode "t:get-type-of". Binary expressions.
      $required - true if type is required, and
        false if empty sequence can be returned for unknown type.
  -->
  <xsl:template mode="t:get-type-of"
    match="add | sub | mul | div">
    <xsl:param name="required" tunnel="yes" as="xs:boolean" select="true()"/>

    <xsl:variable name="expressions" as="element()+"
      select="t:get-java-element(.)"/>
    <xsl:variable name="type1" as="element()?"
      select="t:get-type-of($expressions[1], $required)"/>
    <xsl:variable name="type2" as="element()?"
      select="t:get-type-of($expressions[2], $required)"/>

    <xsl:if test="exists($type1) and exists($type2)">
      <xsl:sequence select="t:get-promoted-type($type1, $type2)"/>
    </xsl:if>
  </xsl:template>

  <!--
    Mode "t:get-type-of". Assign expressions.
      $required - true if type is required, and
        false if empty sequence can be returned for unknown type.
  -->
  <xsl:template mode="t:get-type-of" match="
    assign | add-to | sub-from | mul-to | div-by |
    and-with | or-with | xor-with | mod-by | shl-by | shr-by | sshr-by">
    <xsl:param name="required" tunnel="yes" as="xs:boolean" select="true()"/>

    <xsl:variable name="expressions" as="element()+"
      select="t:get-java-element(.)"/>

    <xsl:sequence select="t:get-type-of($expressions[1], $required)"/>
  </xsl:template>

  <!--
    Mode "t:get-type-of". condition.
      $required - true if type is required, and
        false if empty sequence can be returned for unknown type.
  -->
  <xsl:template mode="t:get-type-of" match="condition">
    <xsl:param name="required" tunnel="yes" as="xs:boolean" select="true()"/>

    <xsl:variable name="expressions" as="element()+"
      select="t:get-java-element(.)"/>

    <xsl:variable name="type" as="element()?" select="
      (
        t:get-type-of($expressions[2], false()), 
        t:get-type-of($expressions[3], false())
      )[1]"/>

    <xsl:if test="$required and not($type)">
      <xsl:sequence select="
        error
        (
          xs:QName('t:invalid-type'),
          concat('Unknown type of: ', t:get-path(.))
        )"/>
    </xsl:if>

    <xsl:sequence select="$type"/>
  </xsl:template>

<!--
    Returns a boxed type for some scalar types.
      $type - a type to get a boxed type for.
      Returns boxed type.
  -->
  <xsl:function name="t:get-boxed-type" as="element()">
    <xsl:param name="type" as="element()"/>

    <xsl:variable name="type-name" as="xs:string?"
      select="t:get-primitive-type-name($type)"/>

    <xsl:sequence select="
      if ($type-name = 'char') then
        $t:Character
      else if ($type-name = 'byte') then
        $t:Byte
      else if ($type-name = 'short') then
        $t:Short
      else if ($type-name = 'int') then
        $t:Integer
      else if ($type-name = 'long') then
        $t:Long
      else if ($type-name = 'float') then
        $t:Float
      else if ($type-name = 'double') then
        $t:Double
      else if ($type-name = 'boolean') then
        $t:Boolean
      else
        $type"/>
  </xsl:function>

  <!--
    Returns a unboxed type for a types.
      $type - a type to get a unboxed type for.
      Returns unboxed type.
  -->
  <xsl:function name="t:get-unboxed-type" as="element()">
    <xsl:param name="type" as="element()"/>

    <xsl:variable name="type-name" as="xs:string?"
      select="t:get-primitive-type-name($type)"/>

    <xsl:sequence select="
      if ($type-name = 'Character') then
        $t:char
      else if ($type-name = 'Byte') then
        $t:byte
      else if ($type-name = 'Short') then
        $t:short
      else if ($type-name = 'Integer') then
        $t:int
      else if ($type-name = 'Long') then
        $t:long
      else if ($type-name = 'Float') then
        $t:float
      else if ($type-name = 'Double') then
        $t:double
      else if ($type-name = 'Boolean') then
        $t:boolean
      else
        $type"/>
  </xsl:function>

  <!--
    Gets java element for a specified element.
      $element - an element to get java elements for.
      Returns optional java elements.
  -->
  <xsl:function name="t:get-java-element" as="element()*">
    <xsl:param name="element" as="element()"/>

    <xsl:sequence select="$element/(* except (meta, comment))"/>
  </xsl:function>

  <!--
    Gets simplified expression.
      $expression - an expression to get simplified expression for.
      Returns a simplified expression.
  -->
  <xsl:function name="t:get-simplified-expression" as="element()">
    <xsl:param name="expression" as="element()"/>

    <xsl:apply-templates mode="p:simplify-expression" select="$expression"/>
  </xsl:function>

  <!--
    Tests whether the value of expression is a boolean true.
      $expression - an expression to verify.
      Returns true if value of an expression is a boolean true, and
        false otherwise.
  -->
  <xsl:function name="t:is-boolean-true-expression" as="xs:boolean">
    <xsl:param name="expression" as="element()"/>

    <xsl:sequence select="
      exists
      (
        t:get-simplified-expression($expression)
        [
          self::boolean[xs:boolean(@value)]
        ]
      )"/>
  </xsl:function>

  <!--
    Tests whether the value of expression is a boolean false.
      $expression - an expression to verify.
      Returns true if value of an expression is a boolean true, and
        false otherwise.
  -->
  <xsl:function name="t:is-boolean-false-expression" as="xs:boolean">
    <xsl:param name="expression" as="element()"/>

    <xsl:sequence select="
      exists
      (
        t:get-simplified-expression($expression)
        [
          self::boolean[xs:boolean(@value) = false()]
        ]
      )"/>
  </xsl:function>

  <!--
    Generates not expression.
      $expression - boolean expression.
      Returns negative expression.
  -->
  <xsl:function name="t:generate-not-expression" as="element()">
    <xsl:param name="expression" as="element()"/>

    <xsl:variable name="simplified-expression" as="element()"
      select="t:get-simplified-expression($expression)"/>

    <xsl:choose>
      <xsl:when test="$simplified-expression[self::not]">
        <xsl:sequence
          select="t:get-java-element($simplified-expression)"/>
      </xsl:when>
      <xsl:when
        test="$simplified-expression[xs:boolean(@value)]">
        <boolean value="false"/>
      </xsl:when>
      <xsl:when test="
        $simplified-expression
        [
          self::boolean[xs:boolean(@value) = false()]
        ]">
        <boolean value="true"/>
      </xsl:when>
      <xsl:when test="$simplified-expression[self::parens, self::scope-expression]">
        <xsl:sequence select="
          t:generate-not-expression
          (
            t:get-java-element($simplified-expression)
          )"/>
      </xsl:when>
      <xsl:when test="$simplified-expression[self::and]">
        <or>
          <xsl:sequence select="
            t:generate-not-expression
            (
              t:get-java-element($simplified-expression)[1]
            )"/>
          <xsl:sequence select="
            t:generate-not-expression
            (
              t:get-java-element($simplified-expression)[2]
            )"/>
        </or>
      </xsl:when>
      <xsl:when test="$simplified-expression[self::or]">
        <and>
          <xsl:sequence select="
            t:generate-not-expression
            (
              t:get-java-element($simplified-expression)[1]
            )"/>
          <xsl:sequence select="
            t:generate-not-expression
            (
              t:get-java-element($simplified-expression)[2]
            )"/>
        </and>
      </xsl:when>
      <xsl:when test="$simplified-expression[self::eq]">
        <ne>
          <xsl:sequence
            select="t:get-java-element($simplified-expression)"/>
        </ne>
      </xsl:when>
      <xsl:when test="$simplified-expression[self::ne]">
        <eq>
          <xsl:sequence
            select="t:get-java-element($simplified-expression)"/>
        </eq>
      </xsl:when>
      <xsl:when test="$simplified-expression[self::gt]">
        <le>
          <xsl:sequence
            select="t:get-java-element($simplified-expression)"/>
        </le>
      </xsl:when>
      <xsl:when test="$simplified-expression[self::le]">
        <gt>
          <xsl:sequence
            select="t:get-java-element($simplified-expression)"/>
        </gt>
      </xsl:when>
      <xsl:when test="$simplified-expression[self::lt]">
        <ge>
          <xsl:sequence
            select="t:get-java-element($simplified-expression)"/>
        </ge>
      </xsl:when>
      <xsl:when test="$simplified-expression[self::ge]">
        <lt>
          <xsl:sequence
            select="t:get-java-element($simplified-expression)"/>
        </lt>
      </xsl:when>
      <xsl:otherwise>
        <not>
          <xsl:sequence select="$simplified-expression"/>
        </not>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:function>

  <!--
    Gets a statement the break refers to.
      $block - a root block.
      $break - a break statement.
      Return a statement the break refers to.
  -->
  <xsl:function name="t:get-statement-for-break" as="element()?">
    <xsl:param name="block" as="element()?"/>
    <xsl:param name="break" as="element()"/>

    <xsl:variable name="label" as="xs:string?"
      select="$break/@destination-label"/>
    <xsl:variable name="label-ref" as="xs:string?" select="$break/@label-ref"/>
    <xsl:variable name="ancestors" as="element()*"
      select="$break/ancestor::*[not($block >> .)]"/>

    <xsl:sequence select="
      if (exists($label)) then
        $ancestors
        [
          if (exists($label-ref)) then
            @label-id = $label-ref
          else
            (@label = $label) and empty(@label-id)
        ]
      else
        $ancestors
        [
          self::switch,
          self::for,
          self::for-each,
          self::while,
          self::do-while
        ][last()]"/>
  </xsl:function>

  <!--
    Generates if/then/else if ... statements.
      $closure - a series of conditions and blocks.
      $index - current index.
      $result - collected result.
      Returns if/then/else if ... statements.
  -->
  <xsl:function name="t:generate-if-statement" as="element()">
    <xsl:param name="closure" as="element()*"/>
    <xsl:param name="index" as="xs:integer"/>
    <xsl:param name="result" as="element()?"/>

    <xsl:variable name="condition" as="element()?" select="$closure[$index]"/>

    <xsl:choose>
      <xsl:when test="empty($condition)">
        <xsl:sequence select="$result"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:variable name="block" as="element()"
          select="$closure[$index + 1]"/>

        <xsl:variable name="next-result" as="element()">
          <if>
            <condition>
              <xsl:sequence select="$condition"/>
            </condition>
            <then>
              <xsl:sequence select="$block"/>
            </then>

            <xsl:if test="exists($result)">
              <else>
                <xsl:sequence select="$result"/>
              </else>
            </xsl:if>
          </if>
        </xsl:variable>

        <xsl:sequence select="
          t:generate-if-statement($closure, $index - 2, $next-result)"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:function>

  <!--
    A type used to supply a result of a lambda function.
  -->
  <xsl:variable name="t:complex-type" as="element()">
    <type name="Supplier" package="com.nesterovskyBros"/>
  </xsl:variable>

  <!--  
    Creates a complex expression from a set of statements.
    Return statement should be only, and the last statement 
    in the statements sequence.
  -->
  <xsl:function name="t:create-complex-expression" as="element()">
    <xsl:param name="statements" as="element()+"/>

    <static-invoke name="get">
      <meta>
        <xsl:sequence select="
          t:get-type-of
          (
            t:get-java-element($statements[last()][self::return]), 
            true()
          )"/>
      </meta>

      <xsl:sequence select="$t:complex-type"/>

      <arguments>
        <lambda>
          <block>
            <xsl:sequence select="$statements"/>
          </block>
        </lambda>
      </arguments>
    </static-invoke>
  </xsl:function>

  <!--
    Tests whether a specified element contains complex subexpression.
      $element - an element to verify.
      Returns true if this is a complex expression, and false otherwise.
  -->
  <xsl:function name="t:contains-complex-expression" as="xs:boolean">
    <xsl:param name="element" as="element()"/>

    <xsl:sequence select="exists(t:get-complex-expressions($element))"/>
  </xsl:function>

  <!--
    Gets complex subexpressions within expression.
      $element - an element to get complex subexpressions for.
      Returns a sequence of complex subexpressions within expression.
  -->
  <xsl:function name="t:get-complex-expressions" as="element()*">
    <xsl:param name="element" as="element()"/>

    <xsl:sequence select="
      $element//type
      [
        (@name = $t:complex-type/@name) and 
        (@package = $t:complex-type/@package)
      ]
      [
        every $item in ancestor-or-self::*[not($element >> .)] satisfies
          $item[not(self::meta or self::comment)]
      ]/
        parent::static-invoke[@name = 'get']"/>
  </xsl:function>

  <!--
    Rewrites, if required, try-with-resources statement.
      $try - a try statement.
      $rewrite-using-regular-try - indicates whether to rewrite statement,
        using a regular try.
      $rewrite-multi-catch - indicates whether to rewrite multi-catch clauses.
  -->
  <xsl:function name="t:rewrite-try-statement" as="element()">
    <xsl:param name="try" as="element()"/>
    <xsl:param name="rewrite-using-regular-try" as="xs:boolean"/>
    <xsl:param name="rewrite-multi-catch" as="xs:boolean"/>

    <xsl:variable name="resource" as="element()?" select="$try/resource"/>
    <xsl:variable name="catch" as="element()*" select="$try/catch"/>
    <xsl:variable name="finally" as="element()?" select="$try/finally"/>
    <xsl:variable name="resource-vars" as="element()*" 
      select="$resource/var-decl"/>
    <xsl:variable name="block" as="element()" select="$try/block"/>
    <xsl:variable name="multi-catch" as="xs:boolean" 
      select="$rewrite-multi-catch and exists($catch/parameter/type[2])"/>

    <xsl:choose>
      <xsl:when test="
        not
        (
          $resource and
          (
            $rewrite-using-regular-try or
            $resource-vars/t:contains-complex-expression(.)
          )
        ) and
        not($multi-catch)">
        <xsl:sequence select="$try"/>
      </xsl:when>
      <xsl:when test="$catch or $finally">
        <try>
          <xsl:sequence select="$try/@*"/>
          <xsl:sequence 
            select="$try/* except ($resource, $catch, $finally, $block)"/>

          <xsl:choose>
            <xsl:when test="$resource">
              <xsl:sequence select="
                p:rewrite-try-statement
                (
                  $rewrite-using-regular-try,
                  $resource-vars,
                  count($resource-vars),
                  $block
                )"/>
            </xsl:when>
            <xsl:otherwise>
              <xsl:sequence select="$block"/>            
            </xsl:otherwise>
          </xsl:choose>
    
          <xsl:choose>
            <xsl:when test="$multi-catch">
              <xsl:for-each select="$catch">
                <xsl:variable name="parameter" as="element()" select="parameter"/>
                <xsl:variable name="block" as="element()" select="block"/>

                <xsl:choose>
                  <xsl:when test="$parameter/type[2]">
                    <xsl:for-each select="$parameter/type">
                      <xsl:variable name="type" as="element()" select="."/>
                      
                      <catch>
                        <xsl:for-each select="$parameter">
                          <xsl:copy>
                            <xsl:sequence select="@*"/>
                            <xsl:sequence select="* except type"/>
                            <xsl:sequence select="$type"/>
                          </xsl:copy>
                        </xsl:for-each>
                        <xsl:sequence select="$block"/>
                      </catch>
                    </xsl:for-each>
                  </xsl:when>
                  <xsl:otherwise>
                    <xsl:sequence select="."/>
                  </xsl:otherwise>
                </xsl:choose>
              </xsl:for-each>
            </xsl:when>
            <xsl:otherwise>
              <xsl:sequence select="$catch"/>            
            </xsl:otherwise>
          </xsl:choose>
        
          <xsl:sequence select="$finally"/>
        </try>
      </xsl:when>
      <xsl:otherwise>
        <block>
          <xsl:sequence select="$try/@*"/>
          <xsl:sequence
            select="$try/* except ($resource, $catch, $finally, $block)"/>

          <xsl:sequence select="
            p:rewrite-try-statement
            (
              $rewrite-using-regular-try,
              $resource-vars,
              count($resource-vars),
              $block
            )"/>
        </block>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:function>

  <!--
    Rewrites, if required, try-with-resources statement.
      $rewrite-using-regular-try - indicates whether to rewrite statement,
        using a regular try.
      $resource-vars - resource variables.
      $index - current index of resource variables.
      $result - collected result.
  -->
  <xsl:function name="p:rewrite-try-statement" as="element()">
    <xsl:param name="rewrite-using-regular-try" as="xs:boolean"/>
    <xsl:param name="resource-vars" as="element()+"/>
    <xsl:param name="index" as="xs:integer"/>
    <xsl:param name="result" as="element()"/>

    <xsl:variable name="var" as="element()" 
      select="$resource-vars[$index]"/>
    <xsl:variable name="complex" as="xs:boolean" 
      select="t:contains-complex-expression($var)"/>

    <xsl:variable name="next-result" as="element()">
      <xsl:variable name="id-element" as="element()">
        <element/>
      </xsl:variable>
      
      <xsl:variable name="id" as="xs:string" 
        select="generate-id($id-element)"/>
      
      <xsl:variable name="block" as="element()">
        <xsl:choose>
          <xsl:when test="$result[self::block]">
            <xsl:sequence select="$result"/>
          </xsl:when>
          <xsl:otherwise>
            <block>
              <xsl:sequence select="$result"/>
            </block>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:variable>

      <xsl:choose>
        <xsl:when test="$rewrite-using-regular-try">
          <block>
            <xsl:sequence select="$var"/>
            
            <xsl:variable name="var-id" as="xs:string?" select="$var/@name-id"/>
            
            <xsl:variable name="var-ref" as="element()">
              <var name="{$var/@name}">
                <xsl:if test="$var-id">
                  <xsl:attribute name="name-ref" select="$var-id"/>
                </xsl:if>
              </var>
            </xsl:variable>
            
            <xsl:variable name="error-ref">
              <var name="error" name-ref="{$id}.error"/>
            </xsl:variable>
            
            <xsl:variable name="error-handler-ref">
              <var name="e" name-ref="{$id}.error-handler"/>
            </xsl:variable>
            
            <var-decl name="error" name-id="{$id}.error">
              <type name="Throwable" package="java.lang"/>
              <initialize>
                <null/>
              </initialize>
            </var-decl>
          
            <try>
              <xsl:sequence select="$block"/>
            
              <catch>
                <parameter name="e" name-id="{$id}.error-handler">
                  <type name="Throwable" package="java.lang"/>
                </parameter>
                <block>
                  <expression>
                    <assign>
                       <xsl:sequence select="$error-ref"/>
                       <xsl:sequence select="$error-handler-ref"/>
                    </assign>
                  </expression>
                
                  <throw>
                    <xsl:sequence select="$error-handler-ref"/>
                  </throw>
                </block>
              </catch>
              <finally>
                <if>
                  <condition>
                    <ne>
                      <xsl:sequence select="$var-ref"/>

                      <null/>
                    </ne>
                  </condition>
                  <then>
                    <if>
                      <condition>
                        <ne>
                          <xsl:sequence select="$error-ref"/>
                        
                          <null/>                        
                        </ne>
                      </condition>
                      <then>
                        <try>
                          <block>
                            <expression>
                              <invoke name="close">
                                <instance>
                                  <xsl:sequence select="$var-ref"/>
                                </instance>  
                              </invoke>
                            </expression>
                          </block>
                          <catch>
                            <parameter name="e" name-id="{$id}.suppresed-error">
                              <type name="Throwable" package="java.lang"/>                              
                            </parameter>
                            <block>
                              <expression>
                                <invoke name="addSuppressed">
                                  <instance>
                                    <xsl:sequence select="$error-ref"/>                                  
                                  </instance>
                                  <arguments>
                                     <var name="e" name-ref="{$id}.suppresed-error"/>
                                  </arguments>
                                </invoke>
                              </expression>
                            </block>
                          </catch>
                        </try>
                      </then>
                      <else>
                        <expression>
                          <invoke name="close">
                            <instance>
                              <xsl:sequence select="$var-ref"/>
                            </instance>  
                          </invoke>
                        </expression>
                      </else>
                    </if>
                  </then>
                </if>
              </finally>
            </try>        
          </block>
        </xsl:when>
        <xsl:when test="$complex">
          <xsl:sequence select="$var"/>

          <try>
            <resource>
              <var-decl name="resource" 
                name-id="{$id}.resource">
                <xsl:sequence select="$var/(type, initialize)"/>
              </var-decl>
            </resource>

            <xsl:sequence select="$block"/>
          </try>
        </xsl:when>
        <xsl:otherwise>
          <try>
            <resource>
              <xsl:sequence select="$var"/>
            </resource>
            
            <xsl:sequence select="$block"/>
          </try>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>

    <xsl:sequence select="
      if ($index > 1) then
        $next-result
      else
        p:rewrite-try-statement
        (
          $rewrite-using-regular-try,
          $resource-vars,
          $index - 1,
          $next-result
        )"/>
  </xsl:function>

  <!--
    Mode "p:simplify-expression". Default match.
  -->
  <xsl:template mode="p:simplify-expression" match="*">
    <xsl:sequence select="."/>
  </xsl:template>

  <!--
    Mode "p:simplify-expression". Expression with stored value.
  -->
  <xsl:template mode="p:simplify-expression" match="*[meta/value]"
    priority="2">
    <xsl:sequence select="meta/value/*"/>
  </xsl:template>

  <!--
    Mode "p:simplify-expression". Parenthesis and expression scope.
  -->
  <xsl:template mode="p:simplify-expression" match="parens | scope-expression">
    <xsl:apply-templates mode="p:simplify-expression" select="*"/>
  </xsl:template>

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
                not(p:is-reserved-word($name))
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
                if ((count($group) = 1) and not(p:is-reserved-word($name))) then
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

  <!--
    Tests whether a specified value is a reserved word.
      $value - a value to test.
      Returns true if value is a reserved word, and false otherwise.
  -->
  <xsl:function name="p:is-reserved-word" as="xs:boolean">
    <xsl:param name="value" as="xs:string"/>

    <xsl:sequence select="exists(key('p:id', $value, $p:reserved-words))"/>
  </xsl:function>

</xsl:stylesheet>