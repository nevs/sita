<?xml version="1.0"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:sql="sql:">

<xsl:include href="select.xsl"/>
<xsl:include href="insert.xsl"/>
<xsl:include href="update.xsl"/>

<xsl:template match="sql:sql_parse_tree">
  <SQLParseTree sql:xmlns="sql:">
    <xsl:apply-templates/>
  </SQLParseTree>
</xsl:template>

<xsl:template match="sql:RangeVar">
  <xsl:element name="sql:RangeVariable">
    <xsl:if test="sql:catalogname/text()">
      <xsl:attribute name="database_name"><xsl:value-of select="sql:catalogname"/></xsl:attribute>
    </xsl:if>
    <xsl:if test="sql:schemaname/text()">
      <xsl:attribute name="schema_name"><xsl:value-of select="sql:schemaname"/></xsl:attribute>
    </xsl:if>
    <xsl:attribute name="relation_name"><xsl:value-of select="sql:relname"/></xsl:attribute>
  </xsl:element>
</xsl:template>

<xsl:template match="sql:ResTarget">
  <xsl:element name="sql:ResultTarget">
    <xsl:attribute name="name"><xsl:value-of select="name"/></xsl:attribute>
    <xsl:apply-templates select="sql:val/."/>
  </xsl:element>
</xsl:template>

<xsl:template match="sql:ColumnRef">
  <sql:ColumnReference>
    <xsl:apply-templates select="sql:fields"/>
  </sql:ColumnReference>
</xsl:template>

<xsl:template match="sql:TypeCast">
  <sql:TypeCast>
    <sql:argument>
      <xsl:apply-templates select="sql:arg"/>
    </sql:argument>
    <sql:type_name><xsl:apply-templates select="sql:typename/sql:TypeName/sql:names"/></sql:type_name>
  </sql:TypeCast>
</xsl:template>

<xsl:template match="sql:FuncCall">
  <sql:FunctionCall>
    <sql:function_name><xsl:apply-templates select="sql:funcname"/></sql:function_name>
    <sql:arguments>
      <xsl:for-each select="sql:args/sql:List/.">
        <xsl:apply-templates/>
      </xsl:for-each>
    </sql:arguments>
  </sql:FunctionCall>
</xsl:template>

<xsl:template match="sql:A_Const">
  <sql:Constant><xsl:apply-templates/></sql:Constant>
</xsl:template>

<xsl:template match="sql:A_Expr">
  <sql:Expression>
    <xsl:element name="sql:Operator">
        <xsl:choose>
          <xsl:when test="sql:kind = 'EXPR_OP'">
            <xsl:attribute name="type">normal</xsl:attribute>
            <xsl:attribute name="name"><xsl:apply-templates select="sql:name"/></xsl:attribute>
          </xsl:when>
          <xsl:when test="sql:kind = 'EXPR_AND'">
            <xsl:attribute name="type">boolean</xsl:attribute>
            <xsl:attribute name="name">AND</xsl:attribute>
          </xsl:when>
          <xsl:when test="sql:kind = 'EXPR_OR'">
            <xsl:attribute name="type">boolean</xsl:attribute>
            <xsl:attribute name="name">OR</xsl:attribute>
          </xsl:when>
          <xsl:when test="sql:kind = 'EXPR_NOT'">
            <xsl:attribute name="type">boolean</xsl:attribute>
            <xsl:attribute name="name">NOT</xsl:attribute>
          </xsl:when>
          <xsl:when test="sql:kind = 'EXPR_OP_ANY'">
            <xsl:attribute name="type">any</xsl:attribute>
            <xsl:attribute name="name"><xsl:apply-templates select="sql:name"/></xsl:attribute>
          </xsl:when>
          <xsl:when test="sql:kind = 'EXPR_OP_ALL'">
            <xsl:attribute name="type">all</xsl:attribute>
            <xsl:attribute name="name"><xsl:apply-templates select="sql:name"/></xsl:attribute>
          </xsl:when>
          <xsl:when test="sql:kind = 'EXPR_OP_DISTINCT'">
            <xsl:attribute name="type">distinct</xsl:attribute>
            <xsl:attribute name="name"><xsl:apply-templates select="sql:name"/></xsl:attribute>
          </xsl:when>
          <xsl:when test="sql:kind = 'EXPR_OP_NULLIF'">
            <xsl:attribute name="type">nullif</xsl:attribute>
            <xsl:attribute name="name"><xsl:apply-templates select="sql:name"/></xsl:attribute>
          </xsl:when>
          <xsl:when test="sql:kind = 'EXPR_OP_OF'">
            <xsl:attribute name="type">of</xsl:attribute>
            <xsl:attribute name="name"><xsl:apply-templates select="sql:name"/></xsl:attribute>
          </xsl:when>
          <xsl:when test="sql:kind = 'EXPR_OP_IN'">
            <xsl:attribute name="type">in</xsl:attribute>
            <xsl:attribute name="name"><xsl:apply-templates select="sql:name"/></xsl:attribute>
          </xsl:when>
        </xsl:choose>
    </xsl:element>
    <sql:left><xsl:apply-templates select="sql:lexpr"/></sql:left>
    <sql:right><xsl:apply-templates select="sql:rexpr"/></sql:right>
  </sql:Expression>
</xsl:template>

<xsl:template match="sql:ParamRef">
  <sql:ParameterReference><xsl:value-of select="sql:number"/></sql:ParameterReference>
</xsl:template>


<!-- Datatypes -->

<xsl:template match="sql:String">
  <sql:String><xsl:value-of select="sql:value"/></sql:String>
</xsl:template>

<xsl:template match="sql:Integer">
  <sql:Integer><xsl:value-of select="sql:value"/></sql:Integer>
</xsl:template>

<xsl:template match="sql:Null">
  <sql:Null></sql:Null>
</xsl:template>

<xsl:template match="sql:FuncCall/sql:funcname|sql:TypeName/sql:names|sql:A_Expr/sql:operator/sql:name|sql:ColumnRef/sql:fields">
  <xsl:call-template name="list-to-string"/>
</xsl:template>

<xsl:template name="list-to-string">
  <xsl:for-each select="sql:List/sql:String/sql:value">
    <xsl:value-of select="."/>
    <xsl:if test="position() != last()">
      <xsl:text>.</xsl:text>
    </xsl:if>
  </xsl:for-each>
</xsl:template>

</xsl:stylesheet>
