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

Interior XSL
Defines the basic interior page
-->

<xsl:stylesheet version="3.0" 
				xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
				xmlns:xs="http://www.w3.org/2001/XMLSchema"
				xmlns:ou="http://omniupdate.com/XSL/Variables"
				xmlns:fn="http://omniupdate.com/XSL/Functions"
				xmlns:ouc="http://omniupdate.com/XSL/Variables"
				exclude-result-prefixes="ou xsl xs fn ouc">

	<xsl:import href="common.xsl"/>	

	<xsl:template name="template-headcode">
		<xsl:copy-of select="ou:ssi('/_resources/search/_ou-search-settings.css.html')" />
	</xsl:template>

	<xsl:template name="template-footcode">
		<xsl:copy-of select="ou:ssi('/_resources/search/_ou-search-settings.search.html')" />
	</xsl:template>	

	<xsl:template name="page-content">
		<xsl:param name="heading" select="normalize-space($page-heading)"/>

		<div class="content" id="main-content">

			<!--End Page-Title Section-->

			<div class="container">
				<div class="row">
					<div class="col-12">
						<nav aria-label="breadcrumb">
							<ol class="breadcrumb">
								<xsl:call-template name="output-breadcrumbs" />
							</ol>
						</nav>
					</div>
				</div>


				<xsl:if test="ou:pcf-param('show-heading') = 'yes'">
					<h1>{$heading}</h1>
				</xsl:if>
				<xsl:if test="not($ou:action = 'pub')">
					<div class="alert alert-info">
						<p>Search functionality will appear on production only.</p>
					</div>
				</xsl:if>
				<!-- where OU Search will be displayed -->
				<div id="ou-search-output"></div>
				<xsl:apply-templates select="ouc:div[@label='maincontent']" />
			</div>
			<section>
				<div class="container">
					<xsl:apply-templates select="ouc:div[@label='subcontent']" />
				</div>
			</section>

			<xsl:apply-templates select="ouc:div[@label='full-width-content']"></xsl:apply-templates>

		</div>


	</xsl:template>

</xsl:stylesheet>