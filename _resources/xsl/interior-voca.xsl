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
				xmlns:fn="http://www.w3.org/2005/xpath-functions"
				xmlns:ou="http://omniupdate.com/XSL/Variables"
				xmlns:ouc="http://omniupdate.com/XSL/Variables"
				expand-text="yes"
				exclude-result-prefixes="ou xsl xs fn ouc">

	<xsl:import href="common.xsl"/>

	<xsl:template name="template-headcode"/>
	<xsl:template name="template-footcode">
		<script src="/_resources/js/evolve/voca-uppercase-h2.js" type="text/javascript"></script>
	</xsl:template>

	<xsl:template name="page-content">
		<xsl:param name="heading" select="normalize-space($page-heading)"/>
		<xsl:param name="banner-content" select="ou:pcf-param('banner-content')"/>
		<xsl:param name="sidebar" select="ou:pcf-param('sidebar')[normalize-space(.)]"/>

		<div class="content" id="main-content">

			<div class="slider-wrapper">
				<xsl:call-template name="hero">			
					<xsl:with-param name="banner-content" select="$banner-content"/>		
				</xsl:call-template>
			</div>

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


				<xsl:choose>
					<xsl:when test="$sidebar => count() > 0">
						<div class="row">
							<div class="col-lg-8 mb-5 order-2">
								<xsl:if test="ou:pcf-param('show-heading') = 'yes'">
									<h1>{$heading}</h1>
								</xsl:if>
								<xsl:apply-templates select="ouc:div[@label='maincontent']" />
							</div>

							<xsl:if test="$sidebar => count() > 0">
								<div class="col-lg-4 pr-lg-5 order-1">
									<xsl:if test="$sidebar = 'side-navigation'">
										<div id="sidebar">
											<h2 class="side-nav-heading">{ou:pcf-param('side-heading')}</h2>
											<nav class="navbar navbar-expand-lg navbar-light">
												<div class="navbar-brand d-lg-none">Navigate this section:</div>
												<button class="navbar-toggler" type="button" data-toggle="collapse" data-target="#navbarToggler" aria-controls="navbarToggler" aria-expanded="false" aria-label="Toggle navigation">
													<span class="fas fa-chevron-down"></span>
													<span class="fas fa-chevron-up"></span>
												</button>
												<div class="navbar-collapse collapse" id="navbarToggler">
													<xsl:call-template name="side-navigation" />
												</div>
											</nav>
										</div>
									</xsl:if>
									<xsl:if test="$sidebar = 'side-content'">
										<xsl:apply-templates select="ouc:div[@label='side-content']" />
									</xsl:if>


								</div>
							</xsl:if>

						</div>				<!--End Row-->
					</xsl:when>
					<xsl:otherwise>
						<xsl:if test="ou:pcf-param('show-heading') = 'yes'">
							<h1>{$heading}</h1>
						</xsl:if>
						<xsl:apply-templates select="ouc:div[@label='maincontent']" />
					</xsl:otherwise>
				</xsl:choose>

			</div><!--End Container-->
			<section>
				<div class="container">
					<xsl:apply-templates select="ouc:div[@label='subcontent']" />
				</div>
			</section>

			<xsl:apply-templates select="ouc:div[@label='full-width-content']"></xsl:apply-templates>

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