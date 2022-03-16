<?xml version="1.0" encoding="UTF-8"?>
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
	xmlns:ouc="http://omniupdate.com/XSL/Variables"
	xmlns:ou="http://omniupdate.com/XSL/Variables"
	xmlns:fn="http://omniupdate.com/XSL/Functions"
	exclude-result-prefixes="ou xsl xs fn ouc">
	
	<xsl:import href="../../common.xsl" />

	<!-- matching the document of the props file -->
	<xsl:template match="/document">
		<html lang="en">
			<head>
				<link href="//netdna.bootstrapcdn.com/bootswatch/3.1.0/cerulean/bootstrap.min.css" rel="stylesheet"/>
				<style>
					body{
					font-family: 'Helvetica Neue', Helvetica, Arial, sans-serif;
					}
					.ox-regioneditbutton {
					display: none;
					}
				</style>
			</head>
			<body id="properties">
				<div class="container" style="max-width: 800px; margin: 20px 0 0 20px;">
					<h1>Data PCF</h1>
					<p>This will publish an XML to: <xsl:value-of select="$dirname || replace($ou:filename, '\..*$', '.xml')" /></p>
					<h2>Properties</h2>
					<dl>
						<xsl:apply-templates select="descendant::parameter"/>
					</dl>
				</div>
				<div style="display:none;">
					<ouc:div label="fake" group="fake" button="hide"/>
				</div>
			</body>
		</html>
	</xsl:template>

	<!-- matching a parameter that is not empty -->
	<xsl:template match="parameter[.!='']">
		<xsl:apply-templates select="@section"/>
		<dt><xsl:value-of select="@prompt"/></dt>
		<dd><xsl:value-of select="."/></dd>
	</xsl:template>

	<!-- matching a parameter that is empty -->
	<xsl:template match="parameter[.='']">
		<xsl:apply-templates select="@section"/>
		<dt><xsl:value-of select="@prompt"/></dt>
		<dd>[Empty]</dd>
	</xsl:template>

	<!-- matching a parameter with an option -->
	<xsl:template match="parameter[option]">
		<xsl:apply-templates select="@section"/>
		<dt><xsl:value-of select="@prompt"/></dt>
		<dd><xsl:value-of select="option[@selected='true']"/></dd>
	</xsl:template>

	<!-- matching a parameter with a JPG image -->
	<xsl:template match="parameter[contains(.,'jpg')]">
		<xsl:apply-templates select="@section"/>
		<dt><xsl:value-of select="@prompt"/></dt>
		<dd><img style="width:50%; height:auto" src="{.}"/></dd>
	</xsl:template>

	<!-- matching section attribute of parameter -->
	<xsl:template match="@section">
		<dt><h4><xsl:value-of select="."/></h4></dt>
	</xsl:template>

</xsl:stylesheet>