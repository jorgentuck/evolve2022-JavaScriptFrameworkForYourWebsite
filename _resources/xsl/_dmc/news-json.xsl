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
	<xsl:import href="../_shared/functions.xsl"/> <!-- customer variables -->
	<xsl:import href="_core/functions.xsl"/> <!-- DMC functions -->
	<xsl:include href="_core/xml-beautify.xsl" />

	<xsl:output method="text" />

	<xsl:output method="text" />

	<xsl:template match="/document">

		<xsl:variable name="internal-doc" select="ou:get-internal-doc(ou:pcf-param('aggregation-path'))" />
		<xsl:variable name="external-doc" select="ou:get-external-doc(ou:pcf-param('external-xml-url'))" />


			<xsl:variable name="news" as="map(*)*">

				<xsl:for-each select="$internal-doc/items/item">

					<xsl:map>

						<xsl:map-entry key="'url'" select="@href => normalize-space()"/>
						<xsl:map-entry key="'title'" select="title/node() => normalize-space()"/>
						<xsl:map-entry key="'item_date'" select="item_date/node() => normalize-space()"/>
						<xsl:map-entry key="'author'" select="author/node() => normalize-space()"/>
						<xsl:map-entry key="'image_src'" select="image/img/@src => normalize-space()"/>
						<xsl:map-entry key="'image_alt'" select="image/img/@alt => normalize-space()"/>
						<xsl:map-entry key="'image_caption'" select="image_caption/node() => normalize-space()"/>
						<xsl:map-entry key="'thumbnail_src'" select="thumbnail/img/@src => normalize-space()"/>
						<xsl:map-entry key="'thumbnail_alt'" select="thumbnail/img/@alt => normalize-space()"/>
						<xsl:map-entry key="'summary'" select="summary/node() => normalize-space()"/>
						<xsl:map-entry key="'department'" select="department/node() => normalize-space()"/>
						<xsl:map-entry key="'display'" select="display/node() => normalize-space()"/>
						<xsl:map-entry key="'featured'" select="featured/node() => normalize-space()"/>

					</xsl:map>
					
				</xsl:for-each>

			</xsl:variable>

		<xsl:value-of select="serialize(array{$news}, map{'method': 'json', 'indent': $not-pub})"/>

	</xsl:template>

</xsl:stylesheet>
