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
		<xsl:param name="sidebar" select="ou:pcf-param('sidebar')[normalize-space(.)]"/>


		<div class="content" id="main-content">

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
				<div class="row mt-3 mb-5"> 
					<div class="col-12">
						<h1>{$heading}</h1>
					</div>
				</div><!--End Row-->

				<xsl:apply-templates select="ouc:div[@label='maincontent']" />
				<xsl:call-template name="events-list"/>
			</div><!--End Container-->
		</div>
	</xsl:template>


	<xsl:template name="events-list">
		<xsl:param name="items-per-page" select="(ou:pcf-param('items-per-page') => number(), 10)[boolean(.)][1]"/>
		<xsl:variable name="filtering_tags" select="ouc:pcf-param('filter-strength')"/>

		<!-- New Way with predicate function that uses one parameter -->
		<!-- 		<xsl:variable name="logical-operator" select="
if (ou:pcf-param('filter-strength') = 'and') then
true()
else
false()"/>

<xsl:variable name="filter-predicate" select="ou:get-filter-predicate(ou:pcf-param('filter-tags'), 'category', $logical-operator, false())"/>


<xsl:variable name="xpath">
<xsl:text>items/item</xsl:text>
<xsl:apply-templates select="$filter-predicate"/>
</xsl:variable> -->

		<!-- New Way with Predicate that uses multiple parameters --> 
		<xsl:variable name="logical-operator" select="
													  if (ou:pcf-param('filter-strength') = 'and') then
													  true()
													  else
													  false()"/>
		<xsl:variable name="filter-predicate" select="ou:get-filter-predicate-multi(ou:pcf-param('filter-tags'), 'tags/tag', $logical-operator, false())"/>
		<xsl:variable name="dept-predicate" select="ou:get-filter-predicate-multi(ou:pcf-param('department'), 'department', false(), false())"/>
		<xsl:variable name="year-predicate" select="ou:get-filter-predicate-multi(ou:pcf-param('year-filter'), 'year/year', false(), false())"/>
		<xsl:variable name="xpath">
			<xsl:text>items/item</xsl:text>
			<xsl:if test="$filter-predicate or $dept-predicate or $year-predicate">
				<xsl:text>[</xsl:text>
				<xsl:if test="$filter-predicate"> (<xsl:apply-templates select="$filter-predicate"/>) </xsl:if>
				<xsl:if test="$filter-predicate and $dept-predicate"> and </xsl:if>
				<xsl:if test="$dept-predicate"> (<xsl:apply-templates select="$dept-predicate"/>) </xsl:if>
				<xsl:if test="$filter-predicate and $year-predicate or $dept-predicate and $year-predicate"> and </xsl:if>
				<xsl:if test="$year-predicate"> (<xsl:apply-templates select="$year-predicate"/>) </xsl:if>
				<xsl:text>]</xsl:text>
			</xsl:if>
		</xsl:variable>

		<xsl:variable name="sort">date(item_date) desc</xsl:variable>


		<xsl:call-template name="dmc">
			<xsl:with-param name="options">
				<items_per_page>{$items-per-page}</items_per_page>
				<datasource>events</datasource>
				<xpath>{$xpath}</xpath>
				<type>listing</type>
				<max_page_links>7</max_page_links>
				<querystring_control>true</querystring_control>				
				<sort>{$sort}</sort>
				<type>listing</type>
				<style>wide</style>
			</xsl:with-param>
			<xsl:with-param name="script-name">events</xsl:with-param>
			<xsl:with-param name="debug" select="true()"/>
		</xsl:call-template>

	</xsl:template>


</xsl:stylesheet>