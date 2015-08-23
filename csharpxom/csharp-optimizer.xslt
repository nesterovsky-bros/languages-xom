<?xml version="1.0" encoding="utf-8"?>
<!--
  This stylesheet provides functions to optimize and simplify C# expressions.
-->
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:t="http://www.bphx.com/csharp"
  xmlns:p="http://www.bphx.com/csharp/private/csharp-optimizer"
  xmlns="http://www.bphx.com/csharp-3.0/2009-05-23"
  xpath-default-namespace="http://www.bphx.com/csharp-3.0/2009-05-23"
  exclude-result-prefixes="xs t p">

  <!-- Predefined types. bool -->
  <xsl:variable name="t:bool" as="element()">
    <type name="bool"/>
  </xsl:variable>

  <!-- Predefined types. bool? -->
  <xsl:variable name="t:nullable-bool" as="element()"
    select="t:get-nullable($t:bool)"/>

  <!-- Predefined types. byte -->
  <xsl:variable name="t:byte" as="element()">
    <type name="byte"/>
  </xsl:variable>

  <!-- Predefined types. byte? -->
  <xsl:variable name="t:nullable-byte" as="element()"
    select="t:get-nullable($t:byte)"/>

  <!-- Predefined types. char -->
  <xsl:variable name="t:char" as="element()">
    <type name="char"/>
  </xsl:variable>

  <!-- Predefined types. char? -->
  <xsl:variable name="t:nullable-char" as="element()"
    select="t:get-nullable($t:char)"/>

  <!-- Predefined types. decimal -->
  <xsl:variable name="t:decimal" as="element()">
    <type name="decimal"/>
  </xsl:variable>

  <!-- Predefined types. decimal? -->
  <xsl:variable name="t:nullable-decimal" as="element()"
    select="t:get-nullable($t:decimal)"/>

    <!-- Predefined types. double -->
  <xsl:variable name="t:double" as="element()">
    <type name="double"/>
  </xsl:variable>

  <!-- Predefined types. double? -->
  <xsl:variable name="t:nullable-double" as="element()"
    select="t:get-nullable($t:double)"/>

  <!-- Predefined types. float -->
  <xsl:variable name="t:float" as="element()">
    <type name="float"/>
  </xsl:variable>

  <!-- Predefined types. float? -->
  <xsl:variable name="t:nullable-float" as="element()"
    select="t:get-nullable($t:float)"/>

  <!-- Predefined types. int -->
  <xsl:variable name="t:int" as="element()">
    <type name="int"/>
  </xsl:variable>

  <!-- Predefined types. int? -->
  <xsl:variable name="t:nullable-int" as="element()"
    select="t:get-nullable($t:int)"/>

  <!-- Predefined types. long -->
  <xsl:variable name="t:long" as="element()">
    <type name="long"/>
  </xsl:variable>

  <!-- Predefined types. long? -->
  <xsl:variable name="t:nullable-long" as="element()"
    select="t:get-nullable($t:long)"/>

  <!-- Predefined types. object -->
  <xsl:variable name="t:object" as="element()">
    <type name="object"/>
  </xsl:variable>

  <!-- Predefined types. sbyte -->
  <xsl:variable name="t:sbyte" as="element()">
    <type name="sbyte"/>
  </xsl:variable>

  <!-- Predefined types. sbyte? -->
  <xsl:variable name="t:nullable-sbyte" as="element()"
    select="t:get-nullable($t:sbyte)"/>

  <!-- Predefined types. short -->
  <xsl:variable name="t:short" as="element()">
    <type name="short"/>
  </xsl:variable>

  <!-- Predefined types. short? -->
  <xsl:variable name="t:nullable-short" as="element()"
    select="t:get-nullable($t:short)"/>

  <!-- Predefined types. string -->
  <xsl:variable name="t:string" as="element()">
    <type name="string"/>
  </xsl:variable>

  <!-- Predefined types. uint -->
  <xsl:variable name="t:uint" as="element()">
    <type name="uint"/>
  </xsl:variable>

  <!-- Predefined types. uint? -->
  <xsl:variable name="t:nullable-uint" as="element()"
    select="t:get-nullable($t:uint)"/>

  <!-- Predefined types. ulong -->
  <xsl:variable name="t:ulong" as="element()">
    <type name="ulong"/>
  </xsl:variable>

  <!-- Predefined types. ulong? -->
  <xsl:variable name="t:nullable-ulong" as="element()"
    select="t:get-nullable($t:ulong)"/>

  <!-- Predefined types. ushort -->
  <xsl:variable name="t:ushort" as="element()">
    <type name="ushort"/>
  </xsl:variable>

  <!-- Predefined types. ushort? -->
  <xsl:variable name="t:nullable-ushort" as="element()"
    select="t:get-nullable($t:ushort)"/>

  <!-- Predefined types. void -->
  <xsl:variable name="t:void" as="element()">
    <type name="void"/>
  </xsl:variable>

  <!-- Predefined types. System.Type -->
  <xsl:variable name="t:Type" as="element()">
    <type name="Type" namespace="System"/>
  </xsl:variable>

  <!-- Predefined types. DateTime -->
  <xsl:variable name="t:DateTime" as="element()">
    <type name="DateTime" namespace="System"/>
  </xsl:variable>

  <!-- Predefined types. Nullable DateTime -->
  <xsl:variable name="t:nullable-DateTime" as="element()"
    select="t:get-nullable($t:DateTime)"/>

  <!-- Predefined types. TimeSpan -->
  <xsl:variable name="t:TimeSpan" as="element()">
    <type name="TimeSpan" namespace="System"/>
  </xsl:variable>

  <!-- Predefined types. Nullable TimeSpan. -->
  <xsl:variable name="t:nullable-TimeSpan" as="element()"
    select="t:get-nullable($t:TimeSpan)"/>

  <!-- Literal integer zero. -->
  <xsl:variable name="t:zero" as="element()">
    <int value="0"/>
  </xsl:variable>

  <!-- Literal integer one. -->
  <xsl:variable name="t:one" as="element()">
    <int value="1"/>
  </xsl:variable>

  <!-- Boolean true literal. -->
  <xsl:variable name="t:true" as="element()">
    <bool value="true"/>
  </xsl:variable>

  <!-- Boolean false literal. -->
  <xsl:variable name="t:false" as="element()">
    <bool value="false"/>
  </xsl:variable>

  <!--
    Returns type name for the primitive type, and empty sequence otherwise.
      $type - a type to get name for.
      Returns type name.
  -->
  <xsl:function name="t:get-primitive-type-name" as="xs:string?">
    <xsl:param name="type" as="element()?"/>

    <xsl:variable name="unwrapped-type" as="element()?" select="
      if ($type/t:is-nullable-type(.)) then
        $type/type-arguments/type
      else
        $type"/>

    <xsl:if test="
      not(xs:boolean($unwrapped-type/@pointer)) and
      empty($unwrapped-type/@rank)">
      <xsl:apply-templates mode="t:get-primitive-type-name"
        select="$unwrapped-type"/>
    </xsl:if>
  </xsl:function>

  <!--
    Mode "t:get-primitive-type-name". Gets primitive type name.
  -->
  <xsl:template mode="t:get-primitive-type-name" as="xs:string" match="
    type
    [
      not(@namespace) and
      (
        @name =
          (
            'bool',
            'byte',
            'char',
            'decimal',
            'double',
            'float',
            'int',
            'long',
            'object',
            'sbyte',
            'short',
            'string',
            'uint',
            'ulong',
            'ushort',
            'void'
          )
      )
    ]">

    <xsl:variable name="rank" as="xs:integer?" select="@rank"/>
    
    <xsl:sequence select="
      if ($rank) then
        concat(@name, '_', $rank)
      else
        @name"/>
  </xsl:template>

  <!--
    Mode "t:get-primitive-type-name". Gets primitive type name.
  -->
  <xsl:template mode="t:get-primitive-type-name" as="xs:string" match="
    type
    [
      (@name = 'Nullable') and
      (@namespace = 'System') and
      (count(type-arguments/type) = 1)
    ]">
    <xsl:apply-templates mode="#current" select="type-arguments/type"/>
  </xsl:template>

  <!--
    Mode "t:get-primitive-type-name". Gets primitive type name.
  -->
  <xsl:template mode="t:get-primitive-type-name" as="xs:string" match="
    type
    [
      (@name = ('DateTime', 'TimeSpan', 'Type')) and
      (@namespace = 'System')
    ]">

    <xsl:sequence select="@name"/>
  </xsl:template>

  <!--
    Mode "t:get-primitive-type-name". System.Boolean.
  -->
  <xsl:template mode="t:get-primitive-type-name" as="xs:string"
    match="type[(@name = 'Boolean') and (@namespace = 'System')]">

    <xsl:sequence select="'bool'"/>
  </xsl:template>

  <!--
    Mode "t:get-primitive-type-name". System.Byte.
  -->
  <xsl:template mode="t:get-primitive-type-name" as="xs:string"
    match="type[(@name = 'Byte') and (@namespace = 'System')]">

    <xsl:sequence select="'byte'"/>
  </xsl:template>


  <!--
    Mode "t:get-primitive-type-name". System.Char.
  -->
  <xsl:template mode="t:get-primitive-type-name" as="xs:string"
    match="type[(@name = 'Char') and (@namespace = 'System')]">

    <xsl:sequence select="'char'"/>
  </xsl:template>

  <!--
    Mode "t:get-primitive-type-name". System.Decimal.
  -->
  <xsl:template mode="t:get-primitive-type-name" as="xs:string"
    match="type[(@name = 'Decimal') and (@namespace = 'System')]">

    <xsl:sequence select="'decimal'"/>
  </xsl:template>

  <!--
    Mode "t:get-primitive-type-name". System.Double.
  -->
  <xsl:template mode="t:get-primitive-type-name" as="xs:string"
    match="type[(@name = 'Double') and (@namespace = 'System')]">

    <xsl:sequence select="'double'"/>
  </xsl:template>


  <!--
    Mode "t:get-primitive-type-name". System.Single.
  -->
  <xsl:template mode="t:get-primitive-type-name" as="xs:string"
    match="type[(@name = 'Single') and (@namespace = 'System')]">

    <xsl:sequence select="'float'"/>
  </xsl:template>


  <!--
    Mode "t:get-primitive-type-name". System.Int32.
  -->
  <xsl:template mode="t:get-primitive-type-name" as="xs:string"
    match="type[(@name = 'Int32') and (@namespace = 'System')]">

    <xsl:sequence select="'int'"/>
  </xsl:template>

  <!--
    Mode "t:get-primitive-type-name". System.Int64.
  -->
  <xsl:template mode="t:get-primitive-type-name" as="xs:string"
    match="type[(@name = 'Int64') and (@namespace = 'System')]">

    <xsl:sequence select="'long'"/>
  </xsl:template>

  <!--
    Mode "t:get-primitive-type-name". System.Object.
  -->
  <xsl:template mode="t:get-primitive-type-name" as="xs:string"
    match="type[(@name = 'Object') and (@namespace = 'System')]">

    <xsl:sequence select="'object'"/>
  </xsl:template>

  <!--
    Mode "t:get-primitive-type-name". System.SByte.
  -->
  <xsl:template mode="t:get-primitive-type-name" as="xs:string"
    match="type[(@name = 'SByte') and (@namespace = 'System')]">

    <xsl:sequence select="'sbyte'"/>
  </xsl:template>

  <!--
    Mode "t:get-primitive-type-name". System.Int16.
  -->
  <xsl:template mode="t:get-primitive-type-name" as="xs:string"
    match="type[(@name = 'Int16') and (@namespace = 'System')]">

    <xsl:sequence select="'short'"/>
  </xsl:template>

  <!--
    Mode "t:get-primitive-type-name". System.String.
  -->
  <xsl:template mode="t:get-primitive-type-name" as="xs:string"
    match="type[(@name = 'String') and (@namespace = 'System')]">

    <xsl:sequence select="'string'"/>
  </xsl:template>

  <!--
    Mode "t:get-primitive-type-name". System.UInt32.
  -->
  <xsl:template mode="t:get-primitive-type-name" as="xs:string"
    match="type[(@name = 'UInt32') and (@namespace = 'System')]">

    <xsl:sequence select="'uint'"/>
  </xsl:template>

  <!--
    Mode "t:get-primitive-type-name". System.UInt64.
  -->
  <xsl:template mode="t:get-primitive-type-name" as="xs:string"
    match="type[(@name = 'UInt64') and (@namespace = 'System')]">

    <xsl:sequence select="'ulong'"/>
  </xsl:template>

  <!--
    Mode "t:get-primitive-type-name". System.UInt16.
  -->
  <xsl:template mode="t:get-primitive-type-name" as="xs:string"
    match="type[(@name = 'UInt16') and (@namespace = 'System')]">

    <xsl:sequence select="'ushort'"/>
  </xsl:template>

  <!--
    Mode "t:get-primitive-type-name". System.Void.
  -->
  <xsl:template mode="t:get-primitive-type-name" as="xs:string"
    match="type[(@name = 'Void') and (@namespace = 'System')]">

    <xsl:sequence select="'void'"/>
  </xsl:template>

  <!--
    Gets promoted type for two other types.
      $type1 - first type.
      $type2 - second type.
      Returns a promoted type.
  -->
  <xsl:function name="t:get-promoted-type" as="element()?">
    <xsl:param name="type1" as="element()?"/>
    <xsl:param name="type2" as="element()?"/>

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
        <xsl:variable name="nullable1" as="xs:boolean"
          select="$type1/t:is-nullable-type(.) = true()"/>
        <xsl:variable name="nullable2" as="xs:boolean"
          select="$type2/t:is-nullable-type(.) = true()"/>
        <xsl:variable name="nullable" as="xs:boolean"
          select="$nullable1 or $nullable2"/>
        <xsl:variable name="signed" as="xs:boolean"
          select="$names = ('int', 'long', 'short', 'sbyte')"/>

        <xsl:sequence select="
          if ($name1 = $name2) then
            if (not($nullable2)) then
              $type1
            else
              $type2
          else if
          (
            every $name in $names satisfies
              $name =
              (
                'byte',
                'char',
                'decimal',
                'double',
                'float',
                'int',
                'long',
                'sbyte',
                'short',
                'uint',
                'ulong',
                'ushort'
              )
          )
          then
            (: Promote numbers. :)
            if ($names = 'decimal') then
              if ($nullable) then
                $t:nullable-decimal
              else
                $t:decimal
            else if ($names = 'double') then
              if ($nullable) then
                $t:nullable-double
              else
                $t:double
            else if ($names = 'float') then
              if ($nullable) then
                $t:nullable-float
              else
                $t:float
            else if ($names = 'ulong') then
              if ($signed) then
                if ($nullable) then
                  $t:nullable-decimal
                else
                  $t:decimal
              else
                if ($nullable) then
                  $t:nullable-ulong
                else
                  $t:ulong
            else if ($names = 'long') then
              if ($nullable) then
                $t:nullable-long
              else
                $t:long
            else if ($names = 'uint') then
              if ($signed) then
                if ($nullable) then
                  $t:nullable-long
                else
                  $t:long
              else
                if ($nullable) then
                  $t:nullable-uint
                else
                  $t:uint
            else if ($names = 'int') then
              if ($nullable) then
                $t:nullable-int
              else
                $t:int
            else if ($names = 'ushort') then
              if ($signed) then
                if ($nullable) then
                  $t:nullable-int
                else
                  $t:int
              else
                if ($nullable) then
                  $t:nullable-ushort
                else
                  $t:ushort
            else if ($names = 'short') then
              if ($nullable) then
                $t:nullable-short
              else
                $t:short
            else
              if ($nullable) then
                $t:nullable-int
              else
                $t:int
          else
            t:custom-promote
            (
              $type1,
              $type2,
              $name1,
              $name2
            )"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:sequence select="
          t:custom-promote
          (
            $type1,
            $type2,
            $name1,
            $name2
          )"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:function>

  <!--
    Custom type promotion.
      $type1 - first type.
      $type2 - second type.
      $name1 - a primitive name for the first type.
      $name2 - a primitive name for the second type.
      Returns a promoted type.
  -->
  <xsl:function name="t:custom-promote" as="element()?">
    <xsl:param name="type1" as="element()?"/>
    <xsl:param name="type2" as="element()?"/>
    <xsl:param name="name1" as="xs:string?"/>
    <xsl:param name="name2" as="xs:string?"/>

    <xsl:apply-templates mode="t:call" select="$t:promote-types-handler">
      <xsl:with-param name="type1" select="$type1"/>
      <xsl:with-param name="type2" select="$type2"/>
      <xsl:with-param name="name1" select="$name1"/>
      <xsl:with-param name="name2" select="$name2"/>
    </xsl:apply-templates>
  </xsl:function>

  <!-- A type promotion handler. -->
  <xsl:variable name="t:promote-types-handler" as="element()">
    <t:promote-types/>
  </xsl:variable>

  <!--
    A type promotion default handler.
      $type1 - first type.
      $type2 - second type.
      $name1 - a primitive name for the first type.
      $name2 - a primitive name for the second type.
      Returns a promoted type.
  -->
  <xsl:template mode="t:call" match="t:promote-types">
    <xsl:param name="type1" tunnel="yes" as="element()?"/>
    <xsl:param name="type2" tunnel="yes" as="element()?"/>
    <xsl:param name="name1" tunnel="yes" as="xs:string?"/>
    <xsl:param name="name2" tunnel="yes" as="xs:string?"/>

    <!-- Do nothing. -->
  </xsl:template>

  <!--
    Gets a type of an expression.
      $expression - an expression to get type for.
      Returns expression's type or empty sequence if result is unknown.
  -->
  <xsl:function name="t:get-type-of" as="element()?">
    <xsl:param name="expression" as="element()"/>

    <xsl:apply-templates mode="t:get-type-of" select="$expression"/>
  </xsl:function>

  <!--
    Mode "t:get-type-of". Default match.
  -->
  <xsl:template mode="t:get-type-of" match="*"/>

  <!--
    Mode "t:get-type-of". Meta annotated expression.
  -->
  <xsl:template mode="t:get-type-of" match="*[meta/type]" priority="3">
    <xsl:sequence select="meta/type"/>
  </xsl:template>

  <!--
    Mode "t:get-type-of". Complex expression.
  -->
  <xsl:template mode="t:get-type-of" 
    match="invoke[t:is-complex-expression(.)]">
    <xsl:apply-templates mode="#current" 
      select="cast/(anonymous-method, lambda)/block/t:get-elements(return)"/>                         
  </xsl:template>

  <!-- Mode "t:get-type-of". byte. -->
  <xsl:template mode="t:get-type-of" match="byte">
    <xsl:sequence select="$t:byte"/>
  </xsl:template>

  <!-- Mode "t:get-type-of". char. -->
  <xsl:template mode="t:get-type-of" match="char">
    <xsl:sequence select="$t:char"/>
  </xsl:template>

  <!-- Mode "t:get-type-of". decimal. -->
  <xsl:template mode="t:get-type-of" match="decimal">
    <xsl:sequence select="$t:decimal"/>
  </xsl:template>

  <!-- Mode "t:get-type-of". double. -->
  <xsl:template mode="t:get-type-of" match="double">
    <xsl:sequence select="$t:double"/>
  </xsl:template>

  <!-- Mode "t:get-type-of". float. -->
  <xsl:template mode="t:get-type-of" match="float">
    <xsl:sequence select="$t:char"/>
  </xsl:template>

  <!-- Mode "t:get-type-of". char. -->
  <xsl:template mode="t:get-type-of" match="int">
    <xsl:sequence select="$t:int"/>
  </xsl:template>

  <!-- Mode "t:get-type-of". long. -->
  <xsl:template mode="t:get-type-of" match="long">
    <xsl:sequence select="$t:long"/>
  </xsl:template>

  <!-- Mode "t:get-type-of". sbyte. -->
  <xsl:template mode="t:get-type-of" match="sbyte">
    <xsl:sequence select="$t:char"/>
  </xsl:template>

  <!-- Mode "t:get-type-of". short -->
  <xsl:template mode="t:get-type-of" match="short">
    <xsl:sequence select="$t:char"/>
  </xsl:template>

  <!-- Mode "t:get-type-of". string. -->
  <xsl:template mode="t:get-type-of" match="string">
    <xsl:sequence select="$t:string"/>
  </xsl:template>

  <!-- Mode "t:get-type-of". uint. -->
  <xsl:template mode="t:get-type-of" match="uint">
    <xsl:sequence select="$t:uint"/>
  </xsl:template>

  <!-- Mode "t:get-type-of". ulong. -->
  <xsl:template mode="t:get-type-of" match="ulong">
    <xsl:sequence select="$t:ulong"/>
  </xsl:template>

  <!-- Mode "t:get-type-of". ushort. -->
  <xsl:template mode="t:get-type-of" match="ushort">
    <xsl:sequence select="$t:ushort"/>
  </xsl:template>

  <!-- Mode "t:get-type-of". boolean expressions and literals. -->
  <xsl:template mode="t:get-type-of"
    match="bool | and | or | not | is | eq | ne | lt | le | gt | ge">
    <xsl:sequence select="$t:bool"/>
  </xsl:template>

  <!--
    Mode "t:get-type-of".
    parens, post-inc, post-dec, inc, dec, plus, neg, inv,
    checked, unchecked.
  -->
  <xsl:template mode="t:get-type-of" match="
    parens |
    post-inc |
    post-dec |
    inc |
    dec |
    plus |
    neg |
    inv |
    checked |
    unchecked">
    <xsl:variable name="value" as="element()" select="t:get-elements(.)"/>

    <xsl:apply-templates mode="#current" select="$value"/>
  </xsl:template>

  <!-- Mode "t:get-type-of". assigns. -->
  <xsl:template mode="t:get-type-of" match="
    assign |
    add-to |
    sub-from |
    mul-to |
    div-by |
    mod-by |
    binary-and-with |
    binary-or-with |
    binary-xor-with |
    lsh-to |
    rsh-to">
    <xsl:variable name="arguments" as="element()+"
      select="t:get-elements(.)"/>

    <xsl:apply-templates mode="#current" select="$arguments[1]"/>
  </xsl:template>

  <!-- Mode "t:get-type-of". new-object, stackalloc, new-delegate. -->
  <xsl:template mode="t:get-type-of"
    match="new-object | stackalloc | new-delegate">
    <xsl:sequence select="type"/>
  </xsl:template>

  <!-- Mode "t:get-type-of". new-array. -->
  <xsl:template mode="t:get-type-of" match="new-array">
    <xsl:variable name="type" as="element()?" select="type"/>
    <xsl:variable name="rank" as="xs:string?" select="@rank"/>

    <xsl:if test="exists($type)">
      <xsl:choose>
        <xsl:when test="$rank">
          <type>
            <xsl:sequence select="$type/(@* except @rank)"/>
            <xsl:attribute name="rank" select="$type/@rank, $rank"/>
            <xsl:sequence select="$type/*"/>
          </type>
        </xsl:when>
        <xsl:otherwise>
          <xsl:sequence select="$type"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:if>
  </xsl:template>

  <!-- Mode "t:get-type-of". typeof, default, cast, as. -->
  <xsl:template mode="t:get-type-of" match="typeof">
    <xsl:sequence select="$t:Type"/>
  </xsl:template>

  <!-- Mode "t:get-type-of". default, cast, as. -->
  <xsl:template mode="t:get-type-of" match="default | cast | as">
    <xsl:sequence select="type"/>
  </xsl:template>

  <!-- Mode "t:get-type-of". sizeof. -->
  <xsl:template mode="t:get-type-of" match="sizeof">
    <xsl:sequence select="$t:int"/>
  </xsl:template>

  <!-- Mode "t:get-type-of". lsh, rsh, coalesce. -->
  <xsl:template mode="t:get-type-of" match="lsh | rsh | coalesce">
    <xsl:variable name="arguments" as="element()+"
      select="t:get-elements(.)"/>

    <xsl:apply-templates mode="#current" select="$arguments[1]"/>
  </xsl:template>

  <!-- Mode "t:get-type-of". binary-and, binary-xor, binary-or. -->
  <xsl:template mode="t:get-type-of"
    match="binary-and | binary-xor | binary-or">
    <xsl:sequence select="$t:int"/>
  </xsl:template>

  <!-- Mode "t:get-type-of". mul, div, mod, add, sub. -->
  <xsl:template mode="t:get-type-of" match="mul | div | mod | add | sub">
    <xsl:variable name="arguments" as="element()+"
      select="t:get-elements(.)"/>
    <xsl:variable name="argument1" as="element()"
      select="$arguments[1]"/>
    <xsl:variable name="argument2" as="element()"
      select="$arguments[2]"/>

    <xsl:variable name="type1" as="element()?">
      <xsl:apply-templates mode="#current" select="$argument1"/>
    </xsl:variable>

    <xsl:variable name="type2" as="element()?">
      <xsl:apply-templates mode="#current" select="$argument2"/>
    </xsl:variable>

    <xsl:sequence select="t:get-promoted-type($type1, $type2)"/>
  </xsl:template>

  <!-- Mode "t:get-type-of". condition. -->
  <xsl:template mode="t:get-type-of" match="condition">
    <xsl:variable name="arguments" as="element()+"
      select="t:get-elements(.)"/>
    <xsl:variable name="argument1" as="element()"
      select="$arguments[2]"/>
    <xsl:variable name="argument2" as="element()"
      select="$arguments[3]"/>

    <xsl:variable name="type1" as="element()?">
      <xsl:apply-templates mode="#current" select="$argument1"/>
    </xsl:variable>

    <xsl:variable name="type2" as="element()?">
      <xsl:apply-templates mode="#current" select="$argument2"/>
    </xsl:variable>

    <xsl:sequence select="t:get-promoted-type($type1, $type2)"/>
  </xsl:template>

  <!-- Mode "t:get-type-of". pointer-member-ref. -->
  <xsl:template mode="t:get-type-of" match="pointer-member-ref">
    <xsl:variable name="member" as="element()+"
      select="t:get-elements(.)[2]"/>

    <xsl:apply-templates mode="#current" select="$member"/>
  </xsl:template>

  <!-- Mode "t:get-type-of". pointer-subscript, deref. -->
  <xsl:template mode="t:get-type-of" match="pointer-subscript | deref">
    <xsl:variable name="value" as="element()"
      select="t:get-elements(.)"/>

    <xsl:variable name="type" as="element()?">
      <xsl:apply-templates mode="#current" select="$value"/>
    </xsl:variable>

    <xsl:if test="exists($type)">
      <xsl:variable name="pointer" as="xs:integer?" select="$type/@pointer"/>

      <xsl:if test="$pointer > 0">
        <type>
          <xsl:sequence select="$type/(@* except @pointer)"/>

          <xsl:if test="$pointer > 1">
            <xsl:attribute name="pointer" select="$pointer - 1"/>
          </xsl:if>
          <xsl:sequence select="*"/>
        </type>
      </xsl:if>
    </xsl:if>
  </xsl:template>

  <!-- Mode "t:get-type-of". addressof. -->
  <xsl:template mode="t:get-type-of" match="addressof">
    <xsl:variable name="value" as="element()"
      select="t:get-elements(.)"/>

    <xsl:variable name="type" as="element()?">
      <xsl:apply-templates mode="#current" select="$value"/>
    </xsl:variable>

    <xsl:variable name="pointer" as="xs:integer?" select="$type/@pointer"/>

    <xsl:if test="exists($type)">
      <type>
        <xsl:sequence select="$type/(@* except @pointer)"/>

        <xsl:attribute name="pointer" select="
          if ($pointer) then
            $pointer + 1
          else
            1"/>

        <xsl:sequence select="*"/>
      </type>
    </xsl:if>
  </xsl:template>

  <!--
    Gets simplified expression.
      $expression - an expression to get simplified expression for.
      Returns a simplified expression.
  -->
  <xsl:function name="t:get-simplified-expression" as="element()">
    <xsl:param name="expression" as="element()"/>

    <xsl:apply-templates mode="t:simplify-expression" select="$expression"/>
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
          self::bool/xs:boolean(@value)
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
          self::bool/xs:boolean(@value) = false()
        ]
      )"/>
  </xsl:function>

  <!--
    Generates not expression.
      $expression - boolean expression.
      Returns boolean not expression.
  -->
  <xsl:function name="t:generate-not-expression" as="element()">
    <xsl:param name="expression" as="element()"/>

    <xsl:variable name="simplified-expression" as="element()"
      select="t:get-simplified-expression($expression)"/>

    <xsl:choose>
      <xsl:when test="$simplified-expression[self::not]">
        <xsl:sequence select="t:get-elements($simplified-expression)"/>
      </xsl:when>
      <xsl:when
        test="$simplified-expression/self::bool/xs:boolean(@value) = true()">
        <bool value="false"/>
      </xsl:when>
      <xsl:when 
        test="$simplified-expression/self::bool/xs:boolean(@value) = false()">
        <bool value="true"/>
      </xsl:when>
      <xsl:when test="$simplified-expression[self::parens]">
        <xsl:sequence select="
          t:generate-not-expression
          (
            t:get-elements($simplified-expression)
          )"/>
      </xsl:when>
      <xsl:when test="$simplified-expression[self::and]">
        <or>
          <xsl:sequence select="
            t:get-elements($simplified-expression)/
              t:generate-not-expression(.)"/>
        </or>
      </xsl:when>
      <xsl:when test="$simplified-expression[self::or]">
        <and>
          <xsl:sequence select="
            t:get-elements($simplified-expression)/
              t:generate-not-expression(.)"/>
        </and>
      </xsl:when>
      <xsl:when test="$simplified-expression[self::eq]">
        <ne>
          <xsl:sequence
            select="t:get-elements($simplified-expression)"/>
        </ne>
      </xsl:when>
      <xsl:when test="$simplified-expression[self::ne]">
        <eq>
          <xsl:sequence
            select="t:get-elements($simplified-expression)"/>
        </eq>
      </xsl:when>
      <xsl:when test="$simplified-expression[self::gt]">
        <le>
          <xsl:sequence
            select="t:get-elements($simplified-expression)"/>
        </le>
      </xsl:when>
      <xsl:when test="$simplified-expression[self::le]">
        <gt>
          <xsl:sequence
            select="t:get-elements($simplified-expression)"/>
        </gt>
      </xsl:when>
      <xsl:when test="$simplified-expression[self::lt]">
        <ge>
          <xsl:sequence
            select="t:get-elements($simplified-expression)"/>
        </ge>
      </xsl:when>
      <xsl:when test="$simplified-expression[self::ge]">
        <lt>
          <xsl:sequence
            select="t:get-elements($simplified-expression)"/>
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
    Generates neg expression.
      $expression - numeric expression.
      Returns negative expression.
  -->
  <xsl:function name="t:generate-neg-expression" as="element()">
    <xsl:param name="expression" as="element()"/>

    <xsl:choose>
      <xsl:when test="exists($expression[self::neg])">
        <xsl:sequence select="t:get-elements($expression)"/>
      </xsl:when>
      <xsl:when test="
        exists
        (
          $expression
          [
            self::decimal or
            self::double or
            self::float or
            self::int or
            self::long or
            self::sbyte or
            self::short
          ]
        ) and
        starts-with($expression/@value, '-')">
        <xsl:for-each select="$expression">
          <xsl:copy>
            <xsl:attribute name="value"
              select="substring-after($expression/@value, '-')"/>
          </xsl:copy>
        </xsl:for-each>
      </xsl:when>
      <xsl:otherwise>
        <neg>
          <xsl:sequence select="$expression"/>
        </neg>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:function>

  <!--
    Generates if/then/else if ... statements.
      $closure - a series of conditions and blocks.
      Returns if/then/else if ... statements.
  -->
  <xsl:function name="t:generate-if-statement" as="element()">
    <xsl:param name="closure" as="element()*"/>

    <xsl:sequence
      select="t:generate-if-statement($closure, count($closure) - 1, ())"/>
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
    Generates an expression from parts.
      $operator - an operator name
      $expressions - a sequence of expressions.
      Returns a combined condition
  -->
  <xsl:function name="t:combine-expression" as="element()">
    <xsl:param name="operator" as="xs:string"/>
    <xsl:param name="expressions" as="element()+"/>

    <xsl:sequence
      select="t:combine-expression($operator, $expressions, 1, ())"/>
  </xsl:function>

  <!--
    Generates an expression from parts.
      $operator - an operator name
      $expressions - a sequence of expressions.
      $index - current index.
      $result - collected result.
      Returns a combined condition
  -->
  <xsl:function name="t:combine-expression" as="element()">
    <xsl:param name="operator" as="xs:string"/>
    <xsl:param name="expressions" as="element()+"/>
    <xsl:param name="index" as="xs:integer"/>
    <xsl:param name="result" as="element()?"/>

    <xsl:variable name="expression" as="element()?"
      select="$expressions[$index]"/>

    <xsl:choose>
      <xsl:when test="empty($expression)">
        <xsl:sequence select="$result"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:variable name="next-result" as="element()">
          <xsl:choose>
            <xsl:when test="empty($result)">
              <xsl:sequence select="$expression"/>
            </xsl:when>
            <xsl:otherwise>
              <xsl:element name="{$operator}">
                <xsl:sequence select="$result"/>
                <xsl:sequence select="$expression"/>
              </xsl:element>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:variable>

        <xsl:sequence select="
          t:combine-expression
          (
            $operator,
            $expressions,
            $index + 1,
            $next-result
          )"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:function>

  <!-- Mode "t:simplify-expression". Default match. -->
  <xsl:template mode="t:simplify-expression" match="*">
    <xsl:sequence select="."/>
  </xsl:template>

  <!-- Mode "t:simplify-expression". Expression with stored value. -->
  <xsl:template mode="t:simplify-expression" match="*[meta/value]"
    priority="2">
    <xsl:sequence select="meta/value/*"/>
  </xsl:template>

  <!-- Mode "t:simplify-expression". Parenthesis and expression scope. -->
  <xsl:template mode="t:simplify-expression" match="parens">
    <xsl:apply-templates mode="t:simplify-expression" select="*"/>
  </xsl:template>

  <!-- Gets a default value for a type. -->
  <xsl:function name="t:get-default-value" as="element()">
    <xsl:param name="type" as="element()"/>
    <xsl:param name="initial-value" as="xs:boolean"/>

    <xsl:apply-templates mode="t:get-default-value" select="$type">
      <xsl:with-param name="initial-value" as="xs:boolean" tunnel="yes"
        select="$initial-value"/>
    </xsl:apply-templates>
  </xsl:function>

  <!-- Mode "t:get-default-value". Default match. -->
  <xsl:template mode="t:get-default-value" match="*">
    <default>
      <xsl:sequence select="."/>
    </default>
  </xsl:template>

  <!-- Mode "t:get-default-value". Nullable value. -->
  <xsl:template mode="t:get-default-value" priority="2"
    match="type[t:is-nullable-type(.)]">
    <xsl:param name="initial-value" as="xs:boolean" tunnel="yes"
      select="false()"/>

    <xsl:choose>
      <xsl:when test="$initial-value">
        <xsl:sequence select="
          t:get-default-value(type-arguments/type, true())"/>
      </xsl:when>
      <xsl:otherwise>
        <null>
          <meta>
            <xsl:sequence select="."/>
          </meta>
        </null>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!-- Mode "t:get-default-value". bool -->
  <xsl:template mode="t:get-default-value"
    match="type[t:get-primitive-type-name(.) = 'bool']">
    <bool value="false"/>
  </xsl:template>

  <!-- Mode "t:get-default-value". byte -->
  <xsl:template mode="t:get-default-value"
    match="type[t:get-primitive-type-name(.) = 'byte']">
    <byte value="0"/>
  </xsl:template>

  <!-- Mode "t:get-default-value". decimal -->
  <xsl:template mode="t:get-default-value"
    match="type[t:get-primitive-type-name(.) = 'decimal']">
    <decimal value="0"/>
  </xsl:template>

  <!-- Mode "t:get-default-value". double -->
  <xsl:template mode="t:get-default-value"
    match="type[t:get-primitive-type-name(.) = 'double']">
    <double value="0"/>
  </xsl:template>

  <!-- Mode "t:get-default-value". float -->
  <xsl:template mode="t:get-default-value"
    match="type[t:get-primitive-type-name(.) = 'float']">
    <float value="0"/>
  </xsl:template>

  <!-- Mode "t:get-default-value". int -->
  <xsl:template mode="t:get-default-value"
    match="type[t:get-primitive-type-name(.) = 'int']">
    <int value="0"/>
  </xsl:template>

  <!-- Mode "t:get-default-value". long -->
  <xsl:template mode="t:get-default-value"
    match="type[t:get-primitive-type-name(.) = 'long']">
    <long value="0"/>
  </xsl:template>

  <!-- Mode "t:get-default-value". object -->
  <xsl:template mode="t:get-default-value"
    match="type[t:get-primitive-type-name(.) = 'object']">
    <null>
      <meta>
        <type name="object"/>
      </meta>
    </null>
  </xsl:template>

  <!-- Mode "t:get-default-value". sbyte -->
  <xsl:template mode="t:get-default-value"
    match="type[t:get-primitive-type-name(.) = 'sbyte']">
    <sbyte value="0"/>
  </xsl:template>

  <!-- Mode "t:get-default-value". short -->
  <xsl:template mode="t:get-default-value"
    match="type[t:get-primitive-type-name(.) = 'short']">
    <short value="0"/>
  </xsl:template>

  <!-- Mode "t:get-default-value". string -->
  <xsl:template mode="t:get-default-value"
    match="type[t:get-primitive-type-name(.) = 'string']">
    <xsl:param name="initial-value" as="xs:boolean" tunnel="yes"
      select="false()"/>

    <xsl:choose>
      <xsl:when test="$initial-value">
        <string value=""/>
      </xsl:when>
      <xsl:otherwise>
        <null>
          <meta>
            <type name="string"/>
          </meta>
        </null>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!-- Mode "t:get-default-value". uint -->
  <xsl:template mode="t:get-default-value"
    match="type[t:get-primitive-type-name(.) = 'uint']">
    <uint value="0"/>
  </xsl:template>

  <!-- Mode "t:get-default-value". ulong -->
  <xsl:template mode="t:get-default-value"
    match="type[t:get-primitive-type-name(.) = 'ulong']">
    <ulong value="0"/>
  </xsl:template>

  <!-- Mode "t:get-default-value". ushort -->
  <xsl:template mode="t:get-default-value"
    match="type[t:get-primitive-type-name(.) = 'ushort']">
    <ushort value="0"/>
  </xsl:template>

  <!-- Mode "t:get-default-value". Type -->
  <xsl:template mode="t:get-default-value"
    match="type[t:get-primitive-type-name(.) = 'Type']">
    <null>
      <meta>
        <type name="Type" namespace="System"/>
      </meta>
    </null>
  </xsl:template>

  <!--
    Converts or casts an expression to a specified type.
      $expression - an expression to convert.
      $type - a target type.
      Returns converted expression, or empty sequence
        if conversion is not possible.
  -->
  <xsl:function name="t:convert-expression" as="element()?">
    <xsl:param name="expression" as="element()"/>
    <xsl:param name="type" as="element()"/>

    <xsl:variable name="source-type" as="element()?"
      select="t:get-type-of($expression)"/>

    <xsl:if test="exists($source-type)">
      <xsl:sequence
        select="t:convert-expression($expression, $source-type, $type)"/>
    </xsl:if>
  </xsl:function>

  <!-- A convert expression handler. -->
  <xsl:variable name="t:convert-expression-handler" as="element()">
    <t:convert-expression/>
  </xsl:variable>

  <!-- A cast expression handler. -->
  <xsl:variable name="t:cast-expression-handler" as="element()">
    <t:cast-expression/>
  </xsl:variable>

  <!--
    Converts or casts an expression to a specified target type.
      $expression - an expression to convert.
      $source-type - an expression type.
      $target-type - a target type.
      Returns converted expression, or empty sequence
      if conversion is not possible.
  -->
  <xsl:function name="t:convert-expression" as="element()?">
    <xsl:param name="expression" as="element()"/>
    <xsl:param name="source-type" as="element()"/>
    <xsl:param name="target-type" as="element()"/>

    <xsl:variable name="source-nullable" as="xs:boolean"
      select="t:is-nullable-type($source-type)"/>
    <xsl:variable name="target-nullable" as="xs:boolean"
      select="t:is-nullable-type($target-type)"/>
    <xsl:variable name="source-name" as="xs:string?"
      select="t:get-primitive-type-name($source-type)"/>
    <xsl:variable name="target-name" as="xs:string?"
      select="t:get-primitive-type-name($target-type)"/>

    <xsl:choose>
      <xsl:when test="
        (
          ($source-nullable = $target-nullable) and
          ($source-name = $target-name)
        ) or
        t:is-same-type
        (
          (
            if ($source-nullable) then
              $source-type/type-arguments/type
            else
              $source-type
          ),
          (
            if ($target-nullable) then
              $target-type/type-arguments/type
            else
              $target-type
          )
        )">
        <xsl:choose>
          <xsl:when test="$source-nullable and not($target-nullable)">
            <xsl:apply-templates mode="t:call"
              select="$t:cast-expression-handler">
              <xsl:with-param name="expression" tunnel="yes"
                select="$expression"/>
              <xsl:with-param name="source-type" tunnel="yes"
                select="$source-type"/>
              <xsl:with-param name="target-type" tunnel="yes"
                select="$target-type"/>
              <xsl:with-param name="source-name" tunnel="yes"
                select="$source-name"/>
              <xsl:with-param name="target-name" tunnel="yes"
                select="$target-name"/>
            </xsl:apply-templates>
          </xsl:when>
          <xsl:otherwise>
            <xsl:sequence select="$expression"/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:when>
      <xsl:when test="$target-name = 'object'">
        <xsl:sequence select="$expression"/>
      </xsl:when>
      <xsl:when test="$expression/self::null">
        <!-- Cast null to anything. -->
        <null>
          <meta>
            <xsl:sequence select="$target-type"/>
          </meta>
        </null>
      </xsl:when>
      <xsl:when test="exists($source-name) and exists($target-name)">
        <xsl:variable name="names" as="xs:string+"
          select="$source-name, $target-name"/>

        <xsl:choose>
          <xsl:when test="$source-name = $target-name">
            <xsl:choose>
              <xsl:when test="$source-nullable and not($target-nullable)">
                <xsl:apply-templates mode="t:call"
                  select="$t:cast-expression-handler">
                  <xsl:with-param name="expression" tunnel="yes"
                    select="$expression"/>
                  <xsl:with-param name="source-type" tunnel="yes"
                    select="$source-type"/>
                  <xsl:with-param name="target-type" tunnel="yes"
                    select="$target-type"/>
                  <xsl:with-param name="source-name" tunnel="yes"
                    select="$source-name"/>
                  <xsl:with-param name="target-name" tunnel="yes"
                    select="$target-name"/>
                </xsl:apply-templates>
              </xsl:when>
              <xsl:otherwise>
                <xsl:sequence select="$expression"/>
              </xsl:otherwise>
            </xsl:choose>
          </xsl:when>
          <xsl:when test="
            every $name in $names satisfies
              $name =
                (
                  'char',
                  'byte',
                  'decimal',
                  'double',
                  'float',
                  'int',
                  'long',
                  'sbyte',
                  'short',
                  'uint',
                  'ulong',
                  'ushort'
                )">

            <xsl:choose>
              <xsl:when test="
                ($source-nullable and  not($target-nullable)) or
                ($names = 'char') or
                ($source-name = ('double', 'decimal')) or
                (($source-name = 'float') and ($target-name != 'double')) or
                ($target-name = ('byte', 'sbyte')) or
                (
                  ($source-name = 'int') and
                  ($target-name = ('short', 'uint', 'ushort', 'ulong'))
                ) or
                (
                  ($source-name = 'long') and
                  ($target-name = ('short', 'int', 'uint', 'ushort', 'ulong'))
                ) or
                (
                  ($source-name = 'sbyte') and
                  ($target-name = ('uint', 'ushort', 'ulong'))
                ) or
                (
                  ($source-name = 'short') and
                  ($target-name = ('sbyte', 'uint', 'ushort', 'ulong'))
                ) or
                (
                  ($source-name = 'uint') and
                  ($target-name = ('int', 'sbyte', 'ushort', 'ulong'))
                ) or
                (
                  ($source-name = 'ulong') and
                  ($target-name = ('int', 'long', 'sbyte', 'uint', 'ushort'))
                ) or
                (
                  ($source-name = 'ushort') and
                  ($target-name = 'sbyte')
                )">

                <xsl:apply-templates mode="t:call"
                  select="$t:cast-expression-handler">
                  <xsl:with-param name="expression" tunnel="yes"
                    select="$expression"/>
                  <xsl:with-param name="source-type" tunnel="yes"
                    select="$source-type"/>
                  <xsl:with-param name="target-type" tunnel="yes"
                    select="$target-type"/>
                  <xsl:with-param name="source-name" tunnel="yes"
                    select="$source-name"/>
                  <xsl:with-param name="target-name" tunnel="yes"
                    select="$target-name"/>
                </xsl:apply-templates>
              </xsl:when>
              <xsl:otherwise>
                <xsl:sequence select="$expression"/>
              </xsl:otherwise>
            </xsl:choose>
          </xsl:when>
          <xsl:otherwise>
            <xsl:apply-templates mode="t:call"
              select="$t:convert-expression-handler">
              <xsl:with-param name="expression" tunnel="yes"
                select="$expression"/>
              <xsl:with-param name="source-type" tunnel="yes"
                select="$source-type"/>
              <xsl:with-param name="target-type" tunnel="yes"
                select="$target-type"/>
              <xsl:with-param name="source-name" tunnel="yes"
                select="$source-name"/>
              <xsl:with-param name="target-name" tunnel="yes"
                select="$target-name"/>
            </xsl:apply-templates>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:when>
      <xsl:otherwise>
        <xsl:apply-templates mode="t:call"
          select="$t:convert-expression-handler">
          <xsl:with-param name="expression" tunnel="yes" select="$expression"/>
          <xsl:with-param name="source-type" tunnel="yes"
            select="$source-type"/>
          <xsl:with-param name="target-type" tunnel="yes"
            select="$target-type"/>
          <xsl:with-param name="source-name" tunnel="yes"
            select="$source-name"/>
          <xsl:with-param name="target-name" tunnel="yes"
            select="$target-name"/>
        </xsl:apply-templates>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:function>

  <!--
    Mode "t:convert-expression". Default match.
      $expression - an expression to convert.
      $source-type - an expression type.
      $target-type - a target type.
      $source-name - an primitive source type name, if available.
      $target-name - an primitive target type name, if available.
  -->
  <xsl:template mode="t:call" match="t:convert-expression">
    <xsl:param name="expression" tunnel="yes" as="element()"/>
    <xsl:param name="source-type" tunnel="yes" as="element()"/>
    <xsl:param name="target-type" tunnel="yes" as="element()"/>
    <xsl:param name="source-name" tunnel="yes" as="xs:string?"/>
    <xsl:param name="target-name" tunnel="yes" as="xs:string?"/>

    <!-- Default implementation. Do nothing. -->
  </xsl:template>

  <!--
    Mode "t:cast-expression". Default match.
      $expression - an expression to convert.
      $source-type - an expression type.
      $target-type - a target type.
      $source-name - an primitive source type name, if available.
      $target-name - an primitive target type name, if available.
  -->
  <xsl:template mode="t:call" match="t:cast-expression">
    <xsl:param name="expression" tunnel="yes" as="element()"/>
    <xsl:param name="source-type" tunnel="yes" as="element()"/>
    <xsl:param name="target-type" tunnel="yes" as="element()"/>
    <xsl:param name="source-name" tunnel="yes" as="xs:string?"/>
    <xsl:param name="target-name" tunnel="yes" as="xs:string?"/>

    <xsl:choose>
      <xsl:when test="
        (local-name($expression) = $source-name) and
        (
          (
            $expression/self::byte and
            (
              $target-name =
                (
                  'decimal',
                  'double',
                  'float',
                  'int',
                  'long',
                  'short',
                  'uint',
                  'ulong',
                  'ushort'
                )
            )
          ) or
          (
            $expression/self::float and 
            ($target-name = 'double')
          ) or
          (
            $expression/self::int and
            (
              $target-name =
                (
                  'decimal',
                  'double',
                  'long'
                )
            )
          ) or
          (
            $expression/self::sbyte and
            (
              $target-name =
                (
                  'decimal',
                  'double',
                  'float',
                  'int',
                  'long',
                  'short'
                )
            )
          ) or
          (
            $expression/self::short and
            (
              $target-name =
                (
                  'decimal',
                  'double',
                  'float',
                  'int',
                  'long'
                )
            )
          ) or
          (
            $expression/self::uint and
            (
              $target-name =
                (
                  'decimal',
                  'double',
                  'long',
                  'ulong'
                )
            )
          ) or
          (
            $expression/self::ushort and
            (
              $target-name =
                (
                  'decimal',
                  'double',
                  'float',
                  'int',
                  'long',
                  'uint',
                  'ulong'
                )
            )
          )
        )">
        <xsl:element name="{$target-name}">
          <xsl:attribute name="value" select="$expression/@value"/>
        </xsl:element>
      </xsl:when>
      <xsl:otherwise>
        <cast>
          <xsl:sequence select="$expression"/>
          <xsl:sequence select="$target-type"/>
        </cast>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!--
    Verifies whether the specified element is a complex expression.
      $element - an element to verify.
      Returns true if element is a complex expression, and false otherwise.
  -->
  <xsl:function name="t:is-complex-expression" as="element()*">
    <xsl:param name="element" as="element()*"/>

    <xsl:sequence select="
      $element[self::invoke][empty(arguments)]
      [
        cast
        [
          type
          [
            (@name = 'Func') and
            (@namespace = 'System') and
            count(type-arguments/type) = 1
          ]
        ]/
          (anonymous-method, lambda)[empty(parameters)]/
            block
            [
              p:get-return-statements(., ())[1] is t:get-elements(.)[last()]
            ]
      ]
      [
        empty(ancestor::query) or
        (ancestor::query | ancestor::block)[last()][self::block]
      ]"/>
  </xsl:function>

  <!--
    Gets return statements in scope.
      $scope - a scope to get statements for.
      $result - a collected result.
  -->
  <xsl:function name="p:get-return-statements" as="element()*">
    <xsl:param name="scope" as="element()*"/>
    <xsl:param name="result" as="element()*"/>

    <xsl:choose>
      <xsl:when test="empty($scope)">
        <xsl:sequence select="$result"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:variable name="children" as="element()*"
          select="t:get-scope-statements($scope)"/>

        <xsl:sequence select="
          p:get-return-statements
          (
            $children,
            ($result | $children[self::return])
          )"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:function>

</xsl:stylesheet>