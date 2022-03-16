<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE xsl:stylesheet>
<!--
	WIDGET
	This XSL is used for widgets.
	Import this XSL file in your individual widget XSL files, and everything from common.xsl will be imported, including the root document template match.
	Override <xsl:template name="publish-output"/> in the individual widget XSL files.
-->
<xsl:stylesheet version="3.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xmlns:ou="http://omniupdate.com/XSL/Variables"
	xmlns:fn="http://omniupdate.com/XSL/Functions"
	xmlns:ouc="http://omniupdate.com/XSL/Variables"
	xmlns:xlink="https://www.w3.org/1999/xlink"
	exclude-result-prefixes="xs ou fn ouc xlink">

	<xsl:import href="../common.xsl"/>

	<xsl:output method="html" indent="yes" version="4.0" encoding="UTF-8" include-content-type="no" omit-xml-declaration="yes"/>
	<xsl:strip-space elements="*"/>

	<xsl:template name="template-headcode"/>
	<xsl:template name="template-footcode"/>

	<!--
		For Publish and Compare modes, we only output the relevant widget content.
		Despite the high priority, this template can be easily overridden with a basic <xsl:template match="/document"/> in the individual widget XSL files.
	-->
	<xsl:template match="/document[$is-pub]" priority="9001">
		<xsl:call-template name="publish-output"/>
	</xsl:template>

	<!--
		Our output method is html 4.0 in this xsl, so we have to add the doctype for Preview and Edit modes.
		<xsl:next-match/> will match on the <xsl:template match="/document"> inside the imported common.xsl.
	-->
	<xsl:template match="/document">
		<xsl:text disable-output-escaping="yes">&lt;!DOCTYPE html&gt;</xsl:text>
		<xsl:next-match/>
	</xsl:template>

	<xsl:template match="ouc:div[$is-edt]" mode="edt-btn">
		<xsl:copy>
			<xsl:apply-templates select="attribute()|ouc:editor" />
		</xsl:copy>
	</xsl:template>

	<xsl:template name="publish-output">Please define a publish output template.</xsl:template>

</xsl:stylesheet>