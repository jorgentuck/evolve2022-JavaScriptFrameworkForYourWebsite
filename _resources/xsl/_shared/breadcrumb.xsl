<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE xsl:stylesheet SYSTEM "http://commons.omniupdate.com/dtd/standard.dtd">

<!--
Implementation Skeleton - 08/24/2018

Breadcrumb XSL
Assumes that a section properties files is being used to extract section titles. 
If there aren't any props files, the xsl skips the section. However, if the current page is the index page, the breadcrumb value the page is used.
If the user leaves the breadcrumb value empty or enters the value of "$skip", the build out will skip the breacrumb for that folder on build out

Example:
<xsl:call-template name="breadcrumb">
<xsl:with-param name="path" select="$dirname"/>
</xsl:call-template>

Dependencies:
- variables.xsl
- functions.xsl
-->

<xsl:stylesheet version="3.0" expand-text="yes"
				xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
				xmlns:xs="http://www.w3.org/2001/XMLSchema"
				xmlns:ou="http://omniupdate.com/XSL/Variables"
				xmlns:fn="http://omniupdate.com/XSL/Functions"
				xmlns:ouc="http://omniupdate.com/XSL/Variables"
				exclude-result-prefixes="ou xsl xs fn ouc">

	<xsl:variable name="breadcrumb-element">li</xsl:variable>
	<!-- a predefined delimiter to place in between crumbs -->
	<xsl:variable name="breadcrumb-delim"></xsl:variable>
	<xsl:variable name="index-filename" select="concat($index-file, '.' , $extension)"/>

	<!-- template for breadcrumb display, use this template to output the breadcrumbs with wrapping HTML -->
	<xsl:template name="output-breadcrumbs">
		<xsl:call-template name="breadcrumb" />
	</xsl:template>

	<!-- The generic breadcrumb template. -->
	<xsl:template name="breadcrumb-general">
		<xsl:param name="href" required="yes" as="xs:string"/>
		<xsl:param name="text" required="yes" as="xs:string"/>
		<xsl:param name="class" as="xs:string" select="'breadcrumb-item'"/>
		<xsl:param name="aria"/>
		<xsl:param name="delim" as="item()" select="$breadcrumb-delim"/>
		<xsl:param name="icon"/>
		<xsl:param name="current"/>

		<xsl:copy-of select="$delim" />
		<xsl:element name="{$breadcrumb-element}">
			<xsl:if test="normalize-space($class)">
				<xsl:attribute name="class">{$class}</xsl:attribute>
			</xsl:if>
			<xsl:if test="normalize-space($aria)">
				<xsl:attribute name="aria-current">{$aria}</xsl:attribute>
			</xsl:if>
			<xsl:choose>
				<xsl:when test="normalize-space($href)">
					<xsl:if test="$icon = 'true'"><span class="fas fa-home"></span></xsl:if> <a href="{$href}">{$text}</a>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="$text"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:element>
	</xsl:template>

	<!-- The current breadcrumb template. -->
	<xsl:template name="breadcrumb-current">
		<xsl:param name="text" required="yes" />
		<xsl:param name="class" as="xs:string">breadcrumb-item active</xsl:param>
		<xsl:param name="aria" as="xs:string">page</xsl:param>
		<xsl:param name="delim" select="$breadcrumb-delim"/>

		<xsl:if test="normalize-space($text)">
			<xsl:call-template name="breadcrumb-general">
				<xsl:with-param name="href"></xsl:with-param>
				<xsl:with-param name="text" select="$text"/>
				<xsl:with-param name="class" select="$class"/>
				<xsl:with-param name="aria" select="$aria"/>
				<xsl:with-param name="delim" select="$delim"/>
				<xsl:with-param name="current" select="true"/>
			</xsl:call-template>
		</xsl:if>
	</xsl:template>

	<!-- The root/home breadcrumb template. -->
	<xsl:template name="breadcrumb-root">
		<xsl:param name="text" select="ou:pcf-param('breadcrumb', document($ou:root || $ou:site || '/' || $props-file))"/>
		<xsl:choose>
			<xsl:when test="normalize-space($text)">
				<xsl:call-template name="breadcrumb-general">
					<xsl:with-param name="href" select="$ou:httproot"/>
					<xsl:with-param name="text" select="$text"/>
					<xsl:with-param name="delim"></xsl:with-param>
					<xsl:with-param name="icon">true</xsl:with-param>
				</xsl:call-template>
			</xsl:when>
			<xsl:otherwise>
				<xsl:call-template name="breadcrumb-general">
					<xsl:with-param name="href" select="$ou:httproot"/>
					<xsl:with-param name="text">Home</xsl:with-param>
					<xsl:with-param name="icon">true</xsl:with-param>
				</xsl:call-template>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

</xsl:stylesheet>