<?xml version="1.0"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:sql="sql:">

<xsl:template match="sql:UpdateStmt" xmlns="sql:">
  <xsl:element name="sql:UpdateStatement">
    <xsl:apply-templates select="sql:relation"/>
    <xsl:apply-templates select="sql:targetList"/>
    <xsl:apply-templates select="sql:whereClause"/>
    <xsl:apply-templates select="sql:fromClause"/>
    <xsl:apply-templates select="sql:returningList"/>
  </xsl:element>
</xsl:template>


</xsl:stylesheet>
