<?xml version="1.0"?>

<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:sql="sql:">

<xsl:output method="xml" version="1.0" encoding="utf-8" indent="yes"/>

<xsl:include href="statements.xsl"/>
<xsl:include href="datums.xsl"/>

<xsl:template match="plpgsql_function">
  <xsl:element name="Function">
    <xsl:attribute name="name"><xsl:value-of select="name"/></xsl:attribute>

    <arguments>
      <xsl:for-each select="arguments/argument">
        <argument>
          <name><xsl:value-of select="name"/></name>
          <datatype><xsl:value-of select="datatype/name"/></datatype>
        </argument>
      </xsl:for-each>
    </arguments>

    <datums>
      <xsl:apply-templates select="datums/*"/>
    </datums>

    <action>
      <xsl:apply-templates select="action/BLOCK"/>
    </action>
  </xsl:element>
</xsl:template>

</xsl:stylesheet>
