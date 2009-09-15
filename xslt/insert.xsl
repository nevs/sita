<?xml version="1.0"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:sql="sql:">

<xsl:template match="sql:InsertStmt">
  <sql:InsertStatement>
    <xsl:apply-templates select="sql:relation"/>
    <xsl:apply-templates select="sql:cols"/>
    <xsl:apply-templates select="sql:selectStmt"/>
    <xsl:apply-templates select="sql:returningList"/>
  </sql:InsertStatement>
</xsl:template>

<xsl:template match="sql:relation">
  <sql:relation>
    <xsl:apply-templates/>
  </sql:relation>
</xsl:template>


</xsl:stylesheet>
