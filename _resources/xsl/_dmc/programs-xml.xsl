<?xml version="1.0" encoding="utf-8"?>
<!DOCTYPE xsl:stylesheet [
<!ENTITY nbsp   "&#160;">
<!ENTITY lsaquo   "&#8249;">
<!ENTITY rsaquo   "&#8250;">
<!ENTITY laquo  "&#171;">
<!ENTITY raquo  "&#187;">
<!ENTITY copy   "&#169;">
]>
<xsl:stylesheet version="3.0"
				xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
				xmlns:xs="http://www.w3.org/2001/XMLSchema"
				xmlns:ou="http://omniupdate.com/XSL/Variables"
				xmlns:ouc="http://omniupdate.com/XSL/Variables"
				exclude-result-prefixes="xs ou ouc"
				expand-text="yes">
	
	<xsl:import href="/var/staging/OMNI-INF/stylesheets/implementation/v1/template-matches.xsl"/> <!-- global template matches -->
	<xsl:import href="/var/staging/OMNI-INF/stylesheets/implementation/v1/variables.xsl"/> <!-- global variables -->
	<xsl:import href="/var/staging/OMNI-INF/stylesheets/implementation/v1/functions.xsl"/> <!-- global functions -->
	<xsl:import href="../_shared/variables.xsl"/> <!-- customer variables -->
	<xsl:import href="_core/functions.xsl"/> <!-- DMC functions -->
	<xsl:include href="_core/xml-beautify.xsl" />
	
<!-- 	<xsl:output method="xml" version="1.0" include-content-type="yes" /> -->

	<xsl:template match="/document">
		<xsl:variable name="internal-doc" select="ou:get-internal-doc(ou:pcf-param('aggregation-path'))" />
<!-- 		<xsl:variable name="external-doc" select="ou:get-external-doc(ou:pcf-param('external-xml-url'))" /> -->
		
		<root>
			<items>
				<xsl:for-each select="$internal-doc/items/item">
					<item href="{@href}">
						<xsl:apply-templates />
					</item>
				</xsl:for-each>
			</items>
			<distinct-lists>
				<pathways>
					<xsl:for-each select="distinct-values($internal-doc/items/item/pathway/text())">
						<xsl:sort select="." />
						<pathway>{.}</pathway>
					</xsl:for-each>
				</pathways>
				<degree-types>
					<xsl:for-each select="distinct-values($internal-doc/items/item/degree-type/text())">
						<xsl:sort select="." />
						<degree-type>{.}</degree-type>
					</xsl:for-each>
				</degree-types>
				<xsl:variable name="title-letters">
					<xsl:for-each select="$internal-doc/items/item/title/text()">
						<letter>{substring(., 1, 1)}</letter>
					</xsl:for-each>
				</xsl:variable>
				<title-letters>
					<xsl:for-each select="distinct-values($title-letters/letter/text())">
						<xsl:sort select="." />
						<letter>{.}</letter>
					</xsl:for-each>
				</title-letters>
			</distinct-lists>
		</root>
		
		
	</xsl:template>
	
</xsl:stylesheet>
