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

	<xsl:template name="template-headcode">
		<!--Data Sort Table Styles-->
		<link rel="stylesheet" type="text/css" href="https://cdn.datatables.net/1.10.20/css/dataTables.bootstrap4.min.css"/>
	</xsl:template>
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
				<div class="row"> 
					<div class="col-12">
						<h1>{$heading}</h1>
						<div class="table-responsive mt-5 mb-5">
							<table id="directory-list" class="table table-hover directory">
								<thead>
									<tr>
										<th scope="col" id="fname">First Name</th>
										<th scope="col" id="lname">Last Name</th>
										<th scope="col" id="title">Title</th>
										<th scope="col" id="department">Department</th>
										<th scope="col" id="location">Location</th>
										<th scope="col" id="phone">Phone</th>
										<th scope="col" id="email">Email</th>
									</tr>
								</thead>
								<tbody>
									<xsl:call-template name="faculty-list"/>
								</tbody>
							</table>
						</div>
					</div>
				</div><!--End Row-->

				<!-- 				<xsl:apply-templates select="ouc:div[@label='maincontent']" /> -->
				<!-- 				<xsl:call-template name="faculty-list"/> -->
			</div><!--End Container-->
		</div>
	</xsl:template>


	<xsl:template name="faculty-list">
		<xsl:param name="filter-tags" select="ou:pcf-param('filter-tags') => normalize-space() => tokenize('\s*,\s*')"/>
		<xsl:param name="filter-strength" select="ouc:pcf-param('filter-strength')"/>

		<xsl:variable name="filters">			
			<xsl:if test="$filter-tags!=''">
				<xsl:variable name="logical-operator" select="if(ou:pcf-param('filter-strength') = 'and') then ' and ' else ' or '" />				
				<!-- 				<xsl:text>[</xsl:text> -->
				<xsl:for-each select="$filter-tags">
					<xsl:choose>
						<xsl:when test="contains(., '''')">
							<xsl:value-of select="'tags/tag=&quot;' || .=>normalize-space()=>replace('&quot;', '') || '&quot;'" />
						</xsl:when>
						<xsl:otherwise>
							<xsl:value-of select="'tags/tag=''' || normalize-space(.) || ''''" />
						</xsl:otherwise>
					</xsl:choose>
					<xsl:if test="position() != last()">
						<xsl:value-of select="$logical-operator" />
					</xsl:if>
				</xsl:for-each>
				<!-- 				<xsl:text>]</xsl:text> -->
			</xsl:if>
		</xsl:variable>

		<xsl:variable name="filtering_tags" select="ouc:pcf-param('filter-strength')"/>

		<xsl:variable name="filters">
			<xsl:if test="ou:pcf-param('filter-tags') !=''">
				<xsl:if test='$filtering_tags = "or"'>tags/tag[
				</xsl:if>
				<xsl:if test="ou:pcf-param('filter-tags') !=''">
					<xsl:try>
						<xsl:for-each select="tokenize(ou:pcf-param('filter-tags'), ',')"><xsl:if test='$filtering_tags = "and"'>tags/tag[
							</xsl:if>
							translate(text(),'ABCDEFGHIJKLMNOPQRSTUVWXYZ','abcdefghijklmnopqrstuvwxyz')='{. => normalize-space() => lower-case()}'<xsl:if test='$filtering_tags = "and"'>]
							</xsl:if>  
							<xsl:if test="(position() != last())"> {$filtering_tags} </xsl:if>
						</xsl:for-each>
						<xsl:catch/>
					</xsl:try>
				</xsl:if><xsl:if test='$filtering_tags = "or"'>]
				</xsl:if>
			</xsl:if>
		</xsl:variable>


		<xsl:variable name="department">
			<xsl:if test="ouc:pcf-param('department') !=''">
				<xsl:if test="ou:pcf-param('filter-tags') !=''">and</xsl:if>
				department[translate(text(),'ABCDEFGHIJKLMNOPQRSTUVWXYZ','abcdefghijklmnopqrstuvwxyz')="{ouc:pcf-param('department') => normalize-space() => lower-case()}"]
			</xsl:if>
		</xsl:variable>

		<xsl:call-template name="dmc">
			<xsl:with-param name="options">
				<datasource>faculty</datasource>
				<xpath>
					<xsl:choose>
						<xsl:when test="ou:pcf-param('filter-tags') !='' or ouc:pcf-param('department') !=''">
							items/item[{$filters}{$department}]
						</xsl:when>
						<xsl:otherwise>
							items/item
						</xsl:otherwise>
					</xsl:choose>
				</xpath>
				<type>listing</type>
				<querystring_control>true</querystring_control>
				<sort>last_name</sort>
			</xsl:with-param>
			<xsl:with-param name="script-name">faculty</xsl:with-param>
<!-- 			<xsl:with-param name="debug" select="true()"/> -->
		</xsl:call-template>

	</xsl:template>

</xsl:stylesheet>