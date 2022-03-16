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

<!--
	Implementations Skeleton - 08/24/2018

	Template Matches XSL
-->

<xsl:stylesheet version="3.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xmlns:fn="http://www.w3.org/2005/xpath-functions"
	xmlns:ou="http://omniupdate.com/XSL/Variables"
	xmlns:ouc="http://omniupdate.com/XSL/Variables"
	expand-text="yes"
	exclude-result-prefixes="ou xsl xs fn ouc">
	
	<xsl:template match="table[not(@data-snippet)]">
		<xsl:param name="class" select="tokenize(@class, '\s+')[. != 'table']"/>
		<div class="table-responsive">
			<table>
				<xsl:attribute name="class">{string-join(($class, 'table'), ' ')}</xsl:attribute>
				<xsl:apply-templates select="node()"/>
			</table>
		</div>
	</xsl:template>
	
</xsl:stylesheet>