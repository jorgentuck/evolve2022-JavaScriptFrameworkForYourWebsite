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
Implementation Skeleton - 08/24/2018

Variables XSL
Customer Variables particular to the school
-->

<xsl:stylesheet version="3.0"
				xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
				xmlns:xs="http://www.w3.org/2001/XMLSchema"
				xmlns:ou="http://omniupdate.com/XSL/Variables"
				xmlns:fn="http://omniupdate.com/XSL/Functions"
				xmlns:ouc="http://omniupdate.com/XSL/Variables"
				exclude-result-prefixes="ou xsl xs fn ouc">

	<!-- production server type -->
	<xsl:variable name="server-type" select="'php'"/>
	<!-- production server include type -->
	<xsl:variable name="include-type" select="'php'"/>
	<!-- production server index file name -->
	<xsl:variable name="index-file" select="'index'"/>
	<!-- production server file type extension -->
	<xsl:variable name="extension" select="'html'"/>
	<!-- navigation file for the implementation -->
	<xsl:variable name="nav-file" select="'_nav.ounav'" />
	<!-- enable ou search tags to be output around the include functions and other places -->
	<xsl:variable name="enable-ou-search-tags" select="true()"/>
	<!-- xsl param to enable social meta tag output onto the pages -->
	<xsl:param name="enable-social-meta-tag-output" select="true()" />
	<xsl:param name="dmc-debug" select="true()"/>

	<xsl:param name="override-og-type" select="ou:pcf-param('override-og-type') => normalize-space()"/>
	<xsl:param name="override-og-image" select="if (ou:pcf-param('override-og-image') != '') then $domain || ou:pcf-param('override-og-image') => normalize-space() else ''"/>
	<xsl:param name="override-og-image-alt" select="ou:pcf-param('override-og-image-alt') => normalize-space()"/>
	<xsl:param name="override-og-description" select="ou:pcf-param('override-og-description') => normalize-space()"/>
	<xsl:param name="override-twitter-card-description" select="ou:pcf-param('override-twitter-card-description') => normalize-space()"/>
	<xsl:param name="override-twitter-card-image" select="if (ou:pcf-param('override-twitter-card-image') != '') then $domain || ou:pcf-param('override-twitter-card-image') => normalize-space() else ''"/>
	<xsl:param name="override-twitter-card-image-alt" select="ou:pcf-param('override-twitter-card-image-alt') => normalize-space()"/>
	<xsl:param name="override-twitter-card-type" select="ou:pcf-param('override-twitter-card-type') => normalize-space()"/>
	<xsl:param name="ou:department-name" />
	<xsl:param name="ou:header-include-path" />
	<xsl:param name="ou:footer-include-path" />
	<xsl:param name="ou:cookie-include-path" />
	<xsl:param name="ou:pre-footer-path" />

	<!--
Directory Variables (add "ou:" before variable name - in XSL only)
Example: <xsl:param name="ou:theme-color" /> ... Where "theme-color" is the Directory Variable name
-->

	<xsl:variable name="header-include-path" select="if ($ou:header-include-path != '') then $ou:header-include-path else '/_resources/includes/header.php'" />
	<xsl:variable name="footer-include-path" select="if ($ou:footer-include-path != '') then $ou:footer-include-path else '/_resources/includes/footer.php'" />
	<xsl:variable name="cookie-include-path" select="if ($ou:cookie-include-path != '') then $ou:cookie-include-path else '/_resources/includes/cookie-alert.php'" />

	<!--Slider Variables -->
	<xsl:variable name="slider_check">
		<xsl:for-each select="document/slider/slide" expand-text="true">
			<xsl:variable name="pos" select="position()"/>
			<xsl:variable name="display-slide" select="normalize-space(ou:multiedit-field(concat('display-slide-', $pos)))"/>
			<xsl:if test="$display-slide">found</xsl:if>
		</xsl:for-each>
	</xsl:variable>

	<xsl:variable name="slide-1-qty">
		<xsl:choose>
			<xsl:when test="ou:multiedit-field('display-slide-1') != ''">1</xsl:when>
			<xsl:otherwise>0</xsl:otherwise>
		</xsl:choose>
	</xsl:variable>

	<xsl:variable name="slide-2-qty">
		<xsl:choose>
			<xsl:when test="ou:multiedit-field('display-slide-2') != ''">1</xsl:when>
			<xsl:otherwise>0</xsl:otherwise>
		</xsl:choose>
	</xsl:variable>

	<xsl:variable name="slide-3-qty">
		<xsl:choose>
			<xsl:when test="ou:multiedit-field('display-slide-3') != ''">1</xsl:when>
			<xsl:otherwise>0</xsl:otherwise>
		</xsl:choose>
	</xsl:variable>

	<xsl:variable name="slide-4-qty">
		<xsl:choose>
			<xsl:when test="ou:multiedit-field('display-slide-4') != ''">1</xsl:when>
			<xsl:otherwise>0</xsl:otherwise>
		</xsl:choose>
	</xsl:variable>

	<xsl:variable name="slide-quantity" select="number($slide-1-qty) + number($slide-2-qty) + number($slide-3-qty) +number($slide-4-qty)"/>

</xsl:stylesheet>