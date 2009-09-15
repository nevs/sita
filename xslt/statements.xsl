<?xml version="1.0"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:sql="sql:">

<!-- plpgsql statement nodes -->

<xsl:template match="BLOCK">
  <xsl:element name="Block">
    <xsl:attribute name="line"><xsl:value-of select="lineno"/></xsl:attribute>
    <xsl:attribute name="label"><xsl:value-of select="label"/></xsl:attribute>
    <body><xsl:apply-templates select="body/*"/></body>
    <exceptions><xsl:copy-of select="exceptions/*" /></exceptions>
  </xsl:element>
</xsl:template>

<xsl:template match="ASSIGN">
  <xsl:element name="Assignment">
    <xsl:attribute name="line"><xsl:value-of select="lineno"/></xsl:attribute>
    <expression><xsl:apply-templates select="expr/EXPR"/></expression>
    <parameter><xsl:value-of select="varno"/></parameter>
  </xsl:element>
</xsl:template>

<xsl:template match="IF">
  <xsl:element name="If">
    <xsl:attribute name="line"><xsl:value-of select="lineno"/></xsl:attribute>
    <condition><xsl:apply-templates select="cond/*"/></condition>
    <true_body><xsl:apply-templates select="true_body/*"/></true_body>
    <false_body><xsl:apply-templates select="false_body/*"/></false_body>
  </xsl:element>
</xsl:template>

<xsl:template match="CASE">
  <xsl:element name="Case">
    <xsl:attribute name="line"><xsl:value-of select="lineno"/></xsl:attribute>
    <xsl:if test="t_expr">
      <expression><xsl:apply-templates select="t_expr/EXPR"/></expression>
      <expression_var><xsl:value-of select="t_varno"/></expression_var>
    </xsl:if>
    <case_when_list>
      <xsl:for-each select="case_when_list/CASE_WHEN">
        <xsl:element name="CaseWhen">
          <xsl:attribute name="line"><xsl:value-of select="lineno"/></xsl:attribute>
          <expression><xsl:apply-templates select="expr/EXPR"/></expression>
          <statements><xsl:apply-templates select="stmts/*"/></statements>
        </xsl:element>
      </xsl:for-each>
    </case_when_list>
    <xsl:if test="else_stmts">
      <xsl:element name="else_statements">
        <xsl:apply-templates select="else_stmts/*"/>
      </xsl:element>
    </xsl:if>
  </xsl:element>
</xsl:template>

<xsl:template match="LOOP">
  <xsl:element name="Loop">
    <xsl:attribute name="line"><xsl:value-of select="lineno"/></xsl:attribute>
    <xsl:attribute name="label"><xsl:value-of select="label"/></xsl:attribute>
    <body><xsl:apply-templates select="body/*"/></body>
  </xsl:element>
</xsl:template>

<xsl:template match="WHILE">
  <xsl:element name="While">
    <xsl:attribute name="line"><xsl:value-of select="lineno"/></xsl:attribute>
    <xsl:attribute name="label"><xsl:value-of select="label"/></xsl:attribute>
    <condition><xsl:apply-templates select="cond/EXPR"/></condition>
    <xsl:element name="body"><xsl:apply-templates select="body/*"/></xsl:element>
  </xsl:element>
</xsl:template>

<xsl:template match="FORI">
  <xsl:element name="ForI">
    <xsl:attribute name="line"><xsl:value-of select="lineno"/></xsl:attribute>
    <xsl:attribute name="label"><xsl:value-of select="label"/></xsl:attribute>
    <xsl:if test="reverse/text() = '1'">
      <xsl:attribute name="reverse">1</xsl:attribute>
    </xsl:if>
    <xsl:element name="variable"><xsl:apply-templates select="var/VAR"/></xsl:element>
    <xsl:element name="lower"><xsl:apply-templates select="lower/EXPR"/></xsl:element>
    <xsl:element name="upper"><xsl:apply-templates select="upper/EXPR"/></xsl:element>
    <xsl:element name="step"><xsl:apply-templates select="step/EXPR"/></xsl:element>
    <xsl:element name="body"><xsl:apply-templates select="body/*"/></xsl:element>
  </xsl:element>
</xsl:template>

<xsl:template match="FORS">
  <xsl:element name="ForS">
    <xsl:attribute name="line"><xsl:value-of select="lineno"/></xsl:attribute>
    <xsl:attribute name="label"><xsl:value-of select="label"/></xsl:attribute>
    <xsl:if test="rec/REC">
      <xsl:element name="rec"><xsl:apply-templates select="rec/REC"/></xsl:element>
    </xsl:if>
    <xsl:if test="row/ROW">
      <xsl:element name="row"><xsl:apply-templates select="row/ROW"/></xsl:element>
    </xsl:if>
    <xsl:element name="body"><xsl:apply-templates select="body/*"/></xsl:element>
    <xsl:element name="query"><xsl:apply-templates select="query/EXPR"/></xsl:element>
  </xsl:element>
</xsl:template>

<xsl:template match="FORC">
  <xsl:element name="ForC">
    <xsl:attribute name="line"><xsl:value-of select="lineno"/></xsl:attribute>
    <xsl:attribute name="label"><xsl:value-of select="label"/></xsl:attribute>
    <xsl:attribute name="curvar"><xsl:value-of select="curvar"/></xsl:attribute>
    <xsl:if test="rec/REC">
      <xsl:element name="rec"><xsl:apply-templates select="rec/REC"/></xsl:element>
    </xsl:if>
    <xsl:if test="row/ROW">
      <xsl:element name="row"><xsl:apply-templates select="row/ROW"/></xsl:element>
    </xsl:if>
    <xsl:element name="body"><xsl:apply-templates select="body/*"/></xsl:element>
    <xsl:element name="argquery"><xsl:apply-templates select="argquery/EXPR"/></xsl:element>
  </xsl:element>
</xsl:template>

<xsl:template match="EXIT">
  <xsl:element name="Exit">
    <xsl:attribute name="line"><xsl:value-of select="lineno"/></xsl:attribute>
    <xsl:attribute name="label"><xsl:value-of select="label"/></xsl:attribute>
    <xsl:if test="is_exit/text() = '0'">
      <xsl:attribute name="type">continue</xsl:attribute>
    </xsl:if>
    <xsl:if test="is_exit/text() = '1'">
      <xsl:attribute name="type">exit</xsl:attribute>
    </xsl:if>
    <xsl:element name="cond"><xsl:apply-templates select="cond/EXPR"/></xsl:element>
  </xsl:element>
</xsl:template>

<xsl:template match="RETURN">
  <xsl:element name="Return">
    <xsl:attribute name="line"><xsl:value-of select="lineno"/></xsl:attribute>
    <xsl:attribute name="retvarno"><xsl:value-of select="retvarno"/></xsl:attribute>
    <xsl:element name="expr"><xsl:apply-templates select="expr/EXPR"/></xsl:element>
  </xsl:element>
</xsl:template>

<xsl:template match="RETURN_NEXT">
  <xsl:element name="ReturnNext">
    <xsl:attribute name="line"><xsl:value-of select="lineno"/></xsl:attribute>
    <xsl:attribute name="retvarno"><xsl:value-of select="retvarno"/></xsl:attribute>
    <xsl:element name="expr"><xsl:apply-templates select="expr/EXPR"/></xsl:element>
  </xsl:element>
</xsl:template>

<xsl:template match="RETURN_QUERY">
  <xsl:element name="ReturnQuery">
    <xsl:attribute name="line"><xsl:value-of select="lineno"/></xsl:attribute>
    <xsl:if test="query/EXPR">
      <xsl:element name="query"><xsl:apply-templates select="query/EXPR"/></xsl:element>
    </xsl:if>
    <xsl:if test="dynquery/EXPR">
      <xsl:element name="dynquery"><xsl:apply-templates select="dynquery/EXPR"/></xsl:element>
    </xsl:if>
    <xsl:element name="params"><xsl:apply-templates select="params/*"/></xsl:element>
  </xsl:element>
</xsl:template>

<xsl:template match="RAISE">
  <xsl:element name="Raise">
    <xsl:attribute name="line"><xsl:value-of select="lineno"/></xsl:attribute>
    <xsl:attribute name="elog_level"><xsl:value-of select="elog_level"/></xsl:attribute>
    <xsl:attribute name="condname"><xsl:value-of select="condname"/></xsl:attribute>
    <xsl:attribute name="message"><xsl:value-of select="message"/></xsl:attribute>
    <xsl:element name="params"><xsl:apply-templates select="params/*"/></xsl:element>
    <xsl:element name="options">
      <xsl:for-each select="options/RAISE_OPTION">
        <xsl:element name="RaiseOption">
          <xsl:attribute name="opt_type"><xsl:value-of select="opt_type"/></xsl:attribute>
          <xsl:element name="expr"><xsl:apply-templates select="expr/EXPR"/></xsl:element>
        </xsl:element>
      </xsl:for-each>
    </xsl:element>
  </xsl:element>
</xsl:template>

<xsl:template match="EXECSQL">
  <xsl:element name="ExecuteSQL">
    <xsl:attribute name="line"><xsl:value-of select="lineno"/></xsl:attribute>
    <xsl:element name="statement"><xsl:apply-templates select="sqlstmt/EXPR"/></xsl:element>
    <xsl:if test="into/text() = '1'">
      <xsl:element name="into">
        <xsl:attribute name="strict"><xsl:value-of select="strict"/></xsl:attribute>
        <xsl:apply-templates select="rec/REC|row/ROW"/>
      </xsl:element>
    </xsl:if>
  </xsl:element>
</xsl:template>

<xsl:template match="DYNEXECUTE">
  <xsl:element name="DynamicExecute">
    <xsl:attribute name="line"><xsl:value-of select="lineno"/></xsl:attribute>
    <xsl:element name="query"><xsl:apply-templates select="query/EXPR"/></xsl:element>
    <xsl:if test="into/text() = '1'">
      <xsl:element name="into">
        <xsl:attribute name="strict"><xsl:value-of select="strict"/></xsl:attribute>
        <xsl:apply-templates select="rec/REC|row/ROW"/>
      </xsl:element>
    </xsl:if>
    <xsl:element name="params"><xsl:apply-templates select="params/*"/></xsl:element>
  </xsl:element>
</xsl:template>

<xsl:template match="DYNFORS">
  <xsl:element name="DynamicForS">
    <xsl:attribute name="line"><xsl:value-of select="lineno"/></xsl:attribute>
    <xsl:attribute name="label"><xsl:value-of select="label"/></xsl:attribute>
    <xsl:if test="rec/REC">
      <xsl:element name="rec"><xsl:apply-templates select="rec/REC"/></xsl:element>
    </xsl:if>
    <xsl:if test="row/ROW">
      <xsl:element name="row"><xsl:apply-templates select="row/ROW"/></xsl:element>
    </xsl:if>
    <xsl:element name="body"><xsl:apply-templates select="body/*"/></xsl:element>
    <xsl:element name="query"><xsl:apply-templates select="query/EXPR"/></xsl:element>
    <xsl:element name="params"><xsl:apply-templates select="params/*"/></xsl:element>
  </xsl:element>
</xsl:template>

<xsl:template match="GETDIAG">
  <xsl:element name="GetDiagnostics">
    <xsl:attribute name="line"><xsl:value-of select="lineno"/></xsl:attribute>
    <xsl:element name="diagnostic_items">
      <xsl:for-each select="diag_items/*">
        <xsl:element name="DiagnosticItem">
          <xsl:attribute name="kind"><xsl:value-of select="kind"/></xsl:attribute>
          <xsl:attribute name="target"><xsl:value-of select="target"/></xsl:attribute>
        </xsl:element>
      </xsl:for-each>
    </xsl:element>
  </xsl:element>
</xsl:template>

<xsl:template match="OPEN">
  <xsl:element name="Open">
    <xsl:attribute name="line"><xsl:value-of select="lineno"/></xsl:attribute>
    <xsl:attribute name="curvar"><xsl:value-of select="curvar"/></xsl:attribute>
    <xsl:element name="returntype"><xsl:apply-templates select="returntype/ROW"/></xsl:element>
    <xsl:element name="argquery"><xsl:apply-templates select="argquery/EXPR"/></xsl:element>
    <xsl:element name="query"><xsl:apply-templates select="query/EXPR"/></xsl:element>
    <xsl:element name="dynquery"><xsl:apply-templates select="dynquery/EXPR"/></xsl:element>
  </xsl:element>
</xsl:template>

<xsl:template match="FETCH">
  <xsl:element name="Fetch">
    <xsl:attribute name="line"><xsl:value-of select="lineno"/></xsl:attribute>
    <xsl:attribute name="curvar"><xsl:value-of select="curvar"/></xsl:attribute>
    <xsl:attribute name="direction"><xsl:value-of select="direction"/></xsl:attribute>
    <xsl:attribute name="how_many"><xsl:value-of select="how_many"/></xsl:attribute>
    <xsl:attribute name="is_move"><xsl:value-of select="is_move"/></xsl:attribute>
    <xsl:element name="rec"><xsl:apply-templates select="rec/REC"/></xsl:element>
    <xsl:element name="row"><xsl:apply-templates select="row/ROW"/></xsl:element>
    <xsl:element name="expr"><xsl:apply-templates select="expr/EXPR"/></xsl:element>
  </xsl:element>
</xsl:template>

<xsl:template match="CLOSE">
  <xsl:element name="Close">
    <xsl:attribute name="line"><xsl:value-of select="lineno"/></xsl:attribute>
    <xsl:attribute name="curvar"><xsl:value-of select="curvar"/></xsl:attribute>
  </xsl:element>
</xsl:template>

<xsl:template match="PERFORM">
  <xsl:element name="Perform">
    <xsl:attribute name="line"><xsl:value-of select="lineno"/></xsl:attribute>
    <xsl:element name="expr"><xsl:apply-templates select="expr/EXPR"/></xsl:element>
  </xsl:element>
</xsl:template>


</xsl:stylesheet>
