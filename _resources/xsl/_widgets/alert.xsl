<?xml version="1.0" encoding="utf-8"?>
<!DOCTYPE xsl:stylesheet[
<!ENTITY times   "&#215;">
]>
<!--
	Widget Example: Emergency Alert Widget
	
	This is an example widget that shows the usage of widget.xsl for the standard PCF to Include Emergency Alert solution.
	
	In some implementations, it may be unnecessary to override the page-content template. when applicable, override a template that is called within the page-content template.
	Override <xsl:template name="publish-output"/> to output just the widget content.
-->
<xsl:stylesheet version="3.0" 
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xmlns:ou="http://omniupdate.com/XSL/Variables"
	xmlns:fn="http://omniupdate.com/XSL/Functions"
	xmlns:ouc="http://omniupdate.com/XSL/Variables"
	exclude-result-prefixes="xsl xs ou fn ouc"
	expand-text="yes">
	
	<xsl:import href="widget.xsl"/>
	
	<xsl:template name="template-headcode">
		<xsl:if test="$is-edt" expand-text="no">
			<style>
				table.ou-alert th { width: 15% }
			</style>
		</xsl:if>
		<xsl:if test="$not-pub" expand-text="no">
			<style>
				#alert-notification { display: block !important;}
			</style>
		</xsl:if>
	</xsl:template>
	<xsl:template name="template-footcode"/>
	
	<xsl:template name="page-content" />
	
	<xsl:template name="publish-output">
		<xsl:call-template name="common-alert"/>
	</xsl:template>

	<xsl:template name="common-alert">
		
		<xsl:if test="$not-pub">
			<xsl:choose>
				<xsl:when test="ou:pcf-param('show-alert') = 'true'">
					<h3 class="text-center">Alert is enabled. Changes do not impact live site until published.</h3>
				</xsl:when>
				<xsl:otherwise>
					<h3 class="text-center">Alert is disabled. Changes do not impact live site until published.</h3>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:if>
		
		<xsl:if test="ou:pcf-param('show-alert') = 'true' or $not-pub">
			<div id="alert-notification" style="display:none;">
				<div class="container">
					<span class="icon-alert"></span>
					<xsl:apply-templates select="ouc:div[@label='alert']" />
				</div>
			</div>
		</xsl:if>
		
	</xsl:template>
	
	<xsl:template match="table[@class='ou-alert']">
		<xsl:variable name="heading" select="tbody/tr/td[@class='heading']" />
		<xsl:variable name="description" select="tbody/tr/td[@class='description']" />
		<xsl:variable name="link" select="tbody/tr/td[@class='link']//a[1]" />
		
		<div class="alert alert-{ou:pcf-param('alert-type')} alert-dismissible fade show" role="alert">
			<h4 class="alert-heading">{$heading}</h4>
			<p>{$description}</p>
			<hr />
			<xsl:if test="$link">
				<a class="btn btn-secondary btn-sm" role="button">
					<xsl:apply-templates select="$link/attribute()[not(name()=('class','role'))]" />
					{$link}
				</a>
			</xsl:if>
			
			<xsl:variable name="cookie-lifespan" select="ou:pcf-param('cookie-lifespan')=>ou:textual-content()" />
			
			<button type="button" class="close{if($cookie-lifespan = '') then ' d-none' else ''}" aria-label="Close" data-dismiss="alert" id="close-alert" data-dismissal-cookie-name="alert_dismissed_{replace(string(current-dateTime()), '\D', '')}" data-dismissal-cookie-lifespan="{$cookie-lifespan}">
				<span aria-hidden="true">&times;</span>
			</button>
			
		</div>
	</xsl:template>
	
</xsl:stylesheet>
