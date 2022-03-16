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
	<xsl:import href="../../_shared/variables.xsl"/> <!-- customer variables -->
	<xsl:import href="functions.xsl"/> <!-- DMC functions -->
	<xsl:include href="xml-beautify.xsl" />
	
	<!-- <xsl:variable name="get-images-script" select="concat($domain, '/_resources/php/directory/get-faculty-details.php?type=images')" />
	<xsl:variable name="available-images" select="if(doc-available($get-images-script)) then doc($get-images-script) else document('')" /> -->
	
	<xsl:template match="/document">
		<xsl:copy-of select="ou:get-item(.)" />
	</xsl:template>

</xsl:stylesheet>
