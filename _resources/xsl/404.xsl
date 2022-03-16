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
	<xsl:template name="template-footcode"/>

	<xsl:template name="page-content">
		<xsl:param name="heading" select="normalize-space($page-heading)"/>
		<xsl:param name="banner-src" select="ou:pcf-param('banner-src') => normalize-space()"/>
		<xsl:param name="sidebar" select="ou:pcf-param('sidebar')[normalize-space(.)]"/>

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
											<h2 class="side-nav-heading"><a href="">Side Nav Heading</a></h2>
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
						<div class="mt-lg-5 mb-lg-5 text-center">
							<p>&nbsp;</p>
							<span class="fas fa-exclamation-triangle" aria-hidden="true"></span>
							<h2 class="text-center">File not found (404 error)</h2>
							<p class="restrict">If you think what you're looking for should be here, please <a href="mailto:{ou:pcf-param('web-admin-email')}">contact our web administrator</a>.</p>
							<p>&nbsp;</p>
						</div>
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

		<!-- 		<xsl:apply-templates select="ouc:div[@label='full-width-content']" /> -->
		<!-- START Pre-Footer -->
		<!-- 		<xsl:if test="ou:pcf-param('pre-footer') = 'on'">
<xsl:call-template name="pre-footer"/>
</xsl:if> -->
		<!-- END Pre-Footer -->
	</xsl:template>


</xsl:stylesheet>