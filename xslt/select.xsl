<?xml version="1.0"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:sql="sql:">

<xsl:template match="sql:SelectStmt">
  <sql:SelectStatement>
    <xsl:apply-templates select="sql:distinctClause"/>
    <xsl:apply-templates select="sql:intoClause"/>
    <xsl:apply-templates select="sql:targetList"/>
    <xsl:apply-templates select="sql:fromClause"/>
    <xsl:apply-templates select="sql:whereClause"/>
    <xsl:apply-templates select="sql:groupClause"/>
    <xsl:apply-templates select="sql:havingClause"/>
    <xsl:apply-templates select="sql:windowClause"/>
    <xsl:apply-templates select="sql:withClause"/>
    <xsl:apply-templates select="sql:valuesLists"/>
    <xsl:apply-templates select="sql:sortClause"/>
    <xsl:apply-templates select="sql:limitOffset"/>
    <xsl:apply-templates select="sql:limitCount"/>
    <xsl:apply-templates select="sql:lockingClause"/>
  </sql:SelectStatement>
</xsl:template>

<xsl:template match="sql:targetList">
  <sql:TargetList>
    <xsl:for-each select="sql:List/.">
      <xsl:apply-templates/>
    </xsl:for-each>
  </sql:TargetList>
</xsl:template>

<xsl:template match="sql:valuesLists">
  <sql:ValuesLists>
    <xsl:for-each select="sql:List/.">
        <xsl:for-each select="sql:List/.">
          <sql:List>
            <xsl:apply-templates/>
          </sql:List>
        </xsl:for-each>
    </xsl:for-each>
  </sql:ValuesLists>
</xsl:template>

<xsl:template match="sql:fromClause">
  <sql:FromClause>
    <xsl:for-each select="sql:List/.">
      <xsl:apply-templates/>
    </xsl:for-each>
  </sql:FromClause>
</xsl:template>



</xsl:stylesheet>
