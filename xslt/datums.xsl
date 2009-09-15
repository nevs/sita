<?xml version="1.0"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:sql="sql:">

<xsl:include href="sql.xsl"/>

<xsl:template match="VAR">
  <xsl:element name="Variable">
    <xsl:attribute name="dno"><xsl:value-of select="dno"/></xsl:attribute>
    <xsl:attribute name="line"><xsl:value-of select="lineno"/></xsl:attribute>
    <xsl:attribute name="name"><xsl:value-of select="refname"/></xsl:attribute>
    <xsl:attribute name="datatype"><xsl:value-of select="datatype/name"/></xsl:attribute>
    <xsl:attribute name="const"><xsl:value-of select="isconst"/></xsl:attribute>
    <xsl:attribute name="not_null"><xsl:value-of select="not_null"/></xsl:attribute>
    <xsl:if test="default_val/EXPR">
      <xsl:element name="default_value"><xsl:apply-templates select="default_val/EXPR"/></xsl:element>
    </xsl:if>
  </xsl:element>
</xsl:template>

<xsl:template match="ROW">
  <xsl:element name="Row">
    <xsl:attribute name="dno"><xsl:value-of select="dno"/></xsl:attribute>
    <xsl:attribute name="line"><xsl:value-of select="lineno"/></xsl:attribute>
    <xsl:attribute name="name"><xsl:value-of select="refname"/></xsl:attribute>
    <xsl:element name="fields">
      <xsl:for-each select="fields/field">
        <xsl:element name="Field">
          <xsl:attribute name="name"><xsl:value-of select="fieldname"/></xsl:attribute>
          <xsl:attribute name="dno"><xsl:value-of select="varno"/></xsl:attribute>
        </xsl:element>
      </xsl:for-each>
    </xsl:element>

  </xsl:element>
</xsl:template>

<xsl:template match="REC">
  <xsl:element name="Record">
    <xsl:attribute name="dno"><xsl:value-of select="dno"/></xsl:attribute>
    <xsl:attribute name="line"><xsl:value-of select="lineno"/></xsl:attribute>
    <xsl:attribute name="name"><xsl:value-of select="refname"/></xsl:attribute>

  </xsl:element>
</xsl:template>

<xsl:template match="RECFIELD">
  <xsl:element name="RecordField">
    <xsl:attribute name="dno"><xsl:value-of select="dno"/></xsl:attribute>

  </xsl:element>
</xsl:template>

<xsl:template match="ARRAYELEM">
  <xsl:element name="ArrayElement">
    <xsl:attribute name="dno"><xsl:value-of select="dno"/></xsl:attribute>

  </xsl:element>
</xsl:template>

<xsl:template match="EXPR">
  <xsl:element name="Expression">
    <xsl:attribute name="dno"><xsl:value-of select="dno"/></xsl:attribute>
    <xsl:attribute name="query"><xsl:value-of select="query"/></xsl:attribute>
    <parameters>
      <xsl:for-each select="params/Param">
        <Parameter><xsl:value-of select="index"/></Parameter>
      </xsl:for-each>
    </parameters>
    <xsl:apply-templates select="sql:sql_parse_tree"/>
  </xsl:element>
</xsl:template>

<xsl:template match="TRIGARG">
  <xsl:element name="TriggerArgument">
    <xsl:attribute name="dno"><xsl:value-of select="dno"/></xsl:attribute>

  </xsl:element>
</xsl:template>

</xsl:stylesheet>
