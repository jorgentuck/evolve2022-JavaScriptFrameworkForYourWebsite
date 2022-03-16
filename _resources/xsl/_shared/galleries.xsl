<?xml version="1.0" encoding="utf-8"?>
<!--
OU LDP GALLERIES
Transforms gallery asset XML into a dynamic gallery on the web page.
-->
<!DOCTYPE xsl:stylesheet SYSTEM "http://commons.omniupdate.com/dtd/standard.dtd">
<xsl:stylesheet version="3.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xmlns:ou="http://omniupdate.com/XSL/Variables"
	xmlns:fn="http://www.w3.org/2005/xpath-functions"
	xmlns:ouc="http://omniupdate.com/XSL/Variables" exclude-result-prefixes="ou xsl xs fn ouc">

	<!-- import core gallery code -->
	<xsl:import href="/var/staging/OMNI-INF/stylesheets/ldp-galleries/v2/galleries.xsl"/>

	<!--
		The following templates match the LDP gallery nodes and output the proper HTML Code based on a specified parameter.

		In order to add different gallery types, create new template matches for the gallery node under new modes.
		Don't forget to include the tunneling `$gallery-options` variable if you would like to include advanced options for the gallery

		Example:
		<xsl:template match="gallery" mode="new-type"></template>
	-->
	<xsl:template match="gallery">
		<xsl:param name="gallery-type" select="$default-gallery-type"/>
		<xsl:param name="gallery-options" tunnel="yes"/>

		<xsl:choose>
			<xsl:when test="$gallery-type = 'fancybox'">
				<xsl:apply-templates select="." mode="fancybox"/>
			</xsl:when>
			<xsl:when test="$gallery-type = 'slick'">
				<xsl:apply-templates select="." mode="slick"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:comment>The specified gallery is not available. Please ensure you have the supported Gallery Types in the Page Properties or create a template for the gallery type you have chosen.</xsl:comment>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

</xsl:stylesheet>