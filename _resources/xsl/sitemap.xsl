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
SiteMap Skeleton - 09/04/2018

SiteMap XSL
Defines the sitemap and A to Z pages
-->

<xsl:stylesheet version="3.0" 
				xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
				xmlns:xs="http://www.w3.org/2001/XMLSchema"
				xmlns:ou="http://omniupdate.com/XSL/Variables"
				xmlns:fn="http://omniupdate.com/XSL/Functions"
				xmlns:ouc="http://omniupdate.com/XSL/Variables"
				exclude-result-prefixes="ou xsl xs fn ouc" expand-text="yes">

	<xsl:import href="common.xsl"/>
	<xsl:import href="/var/staging/OMNI-INF/stylesheets/sitemap/v1/sitemap-functions.xsl"/>

	<xsl:param name="override-og-type" select="ou:pcf-param('override-og-type') => normalize-space()"/>
	<xsl:param name="override-og-image" select="ou:pcf-param('override-og-image') => normalize-space()"/>
	<xsl:param name="override-og-image-alt" select="ou:pcf-param('override-og-image-alt') => normalize-space()"/>
	<xsl:param name="override-og-description" select="ou:pcf-param('override-og-description') => normalize-space()"/>
	<xsl:param name="override-twitter-card-description" select="ou:pcf-param('override-twitter-card-description') => normalize-space()"/>
	<xsl:param name="override-twitter-card-image" select="ou:pcf-param('override-twitter-card-image') => normalize-space()"/>
	<xsl:param name="override-twitter-card-image-alt" select="ou:pcf-param('override-twitter-card-image-alt') => normalize-space()"/>
	<xsl:param name="override-twitter-card-type" select="ou:pcf-param('override-twitter-card-type') => normalize-space()"/>

	<xsl:template name="template-headcode"/>
	<xsl:template name="template-footcode" expand-text="no">
		<script type="text/javascript">
			$(document).ready(function(){
			$('a[href^="#"][href!="#"]').on('click',function(e){
			var headerHeight = 200;
			var fragmentid = $(this).attr('href').replace('#', '');
			var $el = $('#' + fragmentid); // find fragment based on id attribute.
			if(!$el.length) $el = $('a[name="' + fragmentid + '"]'); // if no matching fragment found then find using the name attribute.
			if($el.length){
			e.preventDefault();
			$('html, body').animate({scrollTop:$el.offset().top - headerHeight}, 700);
			}
			});
			});
		</script>
	</xsl:template>

	<!-- what is the index page for the specific implementation -->
	<xsl:param name="index-file-name" select="'index.html'" />
	<!-- extensions to exclude from page build out -->
	<xsl:param name="exclusion-extensions-from-sitemap">inc,xml</xsl:param>
	<!-- filenames to exclude from page build out -->
	<xsl:param name="exclusion-filenames-from-sitemap">props.html</xsl:param>

	<!-- outputs the page content, as called from the common. This should be adjusted to match the common page structure for the a-z and sitemap page -->

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
				<h1>{$heading}</h1>
				<xsl:apply-templates select="ouc:div[@label='maincontent']" />
				<xsl:choose>
					<xsl:when test="not($sitemap = '')">
						<xsl:if test="not($is-pub)">
							<div class="alert alert-info">
								<xsl:call-template name="preview-message" />
							</div>
						</xsl:if>
						<xsl:choose>
							<xsl:when test="$page-type = 'a-to-z'">
								<xsl:call-template name="a-to-z-output" />
							</xsl:when>
							<xsl:when test="$page-type = 'sitemap'">	
								<xsl:call-template name="sitemap-output" />
							</xsl:when>
						</xsl:choose>
					</xsl:when>
					<xsl:otherwise>
						<xsl:call-template name="sitemap-output-error" />
					</xsl:otherwise>
				</xsl:choose>
			</div><!--End Container-->

		</div>
	</xsl:template>



	<xsl:template name="hero">
		<xsl:param name="banner-text"/>
		<xsl:param name="banner-src"/>

		<xsl:if test="$banner-src">
			<div class="jumbotron jumbotron-fluid bg-image" style="background-image:url({iri-to-uri($banner-src)})">
				<xsl:if test="$banner-text">
					<div class="container">
						<p class="h1">{$banner-text}</p>
					</div>
				</xsl:if>
			</div>
		</xsl:if>
	</xsl:template>



	<!-- example of full attribute set -->
	<!-- <xsl:attribute-set name="sitemap-index-link-element-attr">
<xsl:attribute name="class">this is 4 classes</xsl:attribute>
<xsl:attribute name="href">https://www.omniupdate.com/</xsl:attribute>
</xsl:attribute-set> -->

	<!-- sitemap wrapper element -->
	<xsl:param name="sitemap-wrapper-element" select="'ul'" />
	<!-- sitemap wrapper element attributes -->
	<xsl:attribute-set name="sitemap-wrapper-element-attr" />

	<!-- sitemap list element -->
	<xsl:param name="sitemap-list-element" select="'li'" />
	<!-- sitemap list element attributes, do not declare an attribute called data-level -->
	<xsl:attribute-set name="sitemap-list-element-attr" />

	<!-- sitemap inner list element -->
	<xsl:param name="sitemap-list-inner-element" select="'ul'" />
	<!-- sitemap inner list element attributes, do not declare an attribute called data-level -->
	<xsl:attribute-set name="sitemap-list-inner-element-attr" />

	<!-- sitemap list element for index pages -->
	<xsl:param name="sitemap-index-link-element" select="'a'" />
	<!-- sitemap list element for index pages, do not declare an attribute called href -->
	<xsl:attribute-set name="sitemap-index-link-element-attr" />

	<!-- output individual page item as part of the sitemap, url is the page absolute link, title is the page title from page properties -->
	<xsl:template name="sitemap-page-output">
		<li><a href="{url}"><xsl:value-of select="title" /></a></li>
	</xsl:template>

	<!-- a to z elements, remove if customer does not have A to Z -->

	<!-- parameter for declaring the alphabetical list element -->
	<xsl:param name="alpha-list-element" select="'ul'" />
	<xsl:attribute-set name="alpha-list-element-attr">
		<xsl:attribute name="class">horizontal-list</xsl:attribute>
	</xsl:attribute-set>
	<!-- template outputing the individual letters in the alphabetical list for the A to Z page, current-grouping-key() is the individual letter -->
	<xsl:template name="alpha-list-individual">
		<li>
			<a href="#letter-{current-grouping-key()}">
				<xsl:value-of select="current-grouping-key()"/>
			</a>
		</li>
	</xsl:template>

	<!-- template for the individual alpha letter in the A to Z list output, current-grouping-key() is the individual letter, should not change the id -->
	<xsl:template name="individual-alpha-letter">
		<p id="letter-{current-grouping-key()}"><xsl:value-of select="current-grouping-key()"/></p>
	</xsl:template>

	<!-- the individual A-Z letters on the page -->
	<xsl:param name="alpha-letter-wrap" select="'ul'" />
	<!--the individual A-Z letters on the page attributes -->
	<xsl:attribute-set name="alpha-letter-wrap-attr" />

	<!-- template for the individual page output in the A to Z list output, url is the fully qualified URL, title is the page title from page properties -->
	<xsl:template name="individual-alpha-page-link-output">
		<li>
			<a href="{url}">
				<xsl:value-of select="title"/>
			</a>
		</li>
	</xsl:template>

</xsl:stylesheet>