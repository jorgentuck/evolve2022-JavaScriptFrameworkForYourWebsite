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

Home XSL
Defines the page structure for the home page 
-->

<xsl:stylesheet version="3.0" 
				xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
				xmlns:xs="http://www.w3.org/2001/XMLSchema"
				xmlns:ou="http://omniupdate.com/XSL/Variables"
				xmlns:fn="http://omniupdate.com/XSL/Functions"
				xmlns:ouc="http://omniupdate.com/XSL/Variables"
				exclude-result-prefixes="ou xsl xs fn ouc">

	<xsl:import href="common.xsl"/>

	<xsl:template name="template-headcode"/>
	<xsl:template name="template-footcode"/>

	<xsl:template name="page-content"> 
		<xsl:param name="banner-content" select="ou:pcf-param('banner-content')"/>
		<xsl:param name="heading" select="normalize-space($page-heading)"/>

		<div class="slider-wrapper">
			<xsl:call-template name="hero">			
				<xsl:with-param name="banner-content" select="$banner-content"/>		
			</xsl:call-template>
		</div>
		<div class="content" id="main-content">
			<xsl:apply-templates select="ouc:div[@label='maincontent']" />


			<xsl:apply-templates select="ouc:div[@label='social-media']"/>
		</div>
	</xsl:template>





	<xsl:template name="hero">
		<xsl:param name="banner-content"/>		
		<xsl:choose>
			<xsl:when test="$banner-content = 'video'">
				<xsl:apply-templates select="ouc:div[@label='video']"/>				
			</xsl:when>
			<xsl:when test="$banner-content = 'slider'">
				<xsl:apply-templates select="ouc:div[@label='slider']"/>				
			</xsl:when>
			<xsl:when test="$banner-content = 'image'">
				<xsl:apply-templates select="ouc:div[@label='image']"/>	
			</xsl:when>
			<xsl:otherwise></xsl:otherwise>
		</xsl:choose>		
	</xsl:template>




</xsl:stylesheet>