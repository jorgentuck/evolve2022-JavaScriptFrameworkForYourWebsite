<?xml version="1.0" encoding="utf-8"?>
<!DOCTYPE xsl:stylesheet [
<!ENTITY amp   "&#38;">
<!ENTITY copy   "&#169;">
<!ENTITY gt   "&#62;">
<!ENTITY hellip "&#8230;">
<!ENTITY laquo  "&#171;">
<!ENTITY lsaquo   "&#8249;">
<!ENTITY lsquo   "&#8216;">
<!ENTITY lt   "&#60;">
<!ENTITY nbsp   "&#160;">
<!ENTITY quot   "&#34;">
<!ENTITY raquo  "&#187;">
<!ENTITY rsaquo   "&#8250;">
<!ENTITY rsquo   "&#8217;">
]>


<xsl:stylesheet version="3.0" 
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xmlns:ou="http://omniupdate.com/XSL/Variables"
	xmlns:fn="http://omniupdate.com/XSL/Functions"
	xmlns:ouc="http://omniupdate.com/XSL/Variables"
	exclude-result-prefixes="ou xsl xs fn ouc">
	

	<!-- Possible values are php, csharp, xsl. php and csharp are much faster than xsl. -->
	<xsl:variable name="aggregation-language">php</xsl:variable>
	
	<!-- Possible values are php or csharp -->
	<xsl:variable name="server-type">php</xsl:variable>
	
	<!-- Location of dmc scripts -->
	<xsl:variable name="dmc-path">/_resources/dmc/</xsl:variable>
	
	<xsl:variable name="tags">
		<xsl:variable name="tagset">
			<xsl:try>
				<xsl:sequence select="doc(concat('ou:/Tag/GetTags?site=', $ou:site,'&amp;path=', encode-for-uri($ou:stagingpath)))/tags" />
				<xsl:catch>
					<tags></tags>
				</xsl:catch>
			</xsl:try>
		</xsl:variable>
		<xsl:try>
			<xsl:for-each select="$tagset//name">
				<xsl:value-of select="if (position() != last()) then concat(normalize-space(.), ',') else normalize-space(.)"/>
			</xsl:for-each>
			<xsl:catch></xsl:catch>
		</xsl:try>
	</xsl:variable>

</xsl:stylesheet>