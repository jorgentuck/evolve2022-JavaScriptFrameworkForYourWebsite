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
	<xsl:variable name="tags">
		<xsl:variable name="tagset">
			<xsl:try>
				<xsl:sequence select="doc(concat('ou:/Tag/GetTags?site=', $ou:site,'&amp;path=', encode-for-uri($ou:stagingpath)))/tags"/>
				<xsl:catch>
					<tags/>
				</xsl:catch>
			</xsl:try>
		</xsl:variable>
		<xsl:try>
			<xsl:for-each select="$tagset//name">
				<xsl:value-of select="if (position() != last()) then concat(normalize-space(.), ', ') else normalize-space(.)"/>
			</xsl:for-each>
			<xsl:catch/>
		</xsl:try>
	</xsl:variable>

	<xsl:template name="page-content">
		<xsl:param name="sidebar" select="ou:pcf-param('sidebar')[normalize-space(.)]"/>
		<xsl:param name="display-author" select="ou:multiedit-field('author') => normalize-space()"/>
		<xsl:variable name="heading-image" select="ou:multiedit-field('image')/descendant::img/@src"/>
		<xsl:variable name="image-alt" select="ou:multiedit-field('image')/descendant::img/@alt"/>
		<xsl:variable name="image-caption" select="ou:multiedit-field('image_caption')"/>
		<xsl:variable name="item_date" select="ou:multiedit-field('item_date')"/>
		<xsl:variable name="display_datetime">
			<xsl:choose>
				<xsl:when test="$item_date = ''"/>
				<xsl:when test="
								$item_date != '' 
								and (((contains($item_date, 'AM'))
								or  (contains($item_date, 'PM'))))">
					<xsl:value-of select="$item_date =>  ou:to-dateTime() => format-dateTime('[MNn,3-3] [D], [Y0001]')"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="concat($item_date, ' 12:00:00 PM') =>  ou:to-dateTime() => format-dateTime('[MNn,3-3] [D], [Y0001]')"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>


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
					<div class="col-12 mb-3">
						<h1>{ou:multiedit-field('title')}</h1>
						<h2 class="title-decorative font-size-sm">
							<xsl:if test="$display-author !=''">By {$display-author} |</xsl:if> {$display_datetime}</h2>
					</div>
				</div>


				<div class="row">  
					<div class="col-lg-7 col-xl-8">
						<div class="figure">
							<xsl:choose>
								<xsl:when test="$heading-image !=''">
									<img src="{$heading-image}" class="figure-img" alt="{$image-alt}"/> 
								</xsl:when>
								<xsl:otherwise>
									<img src="/_resources/images/placeholder-730-460.png" class="figure-img" alt="placeholder"/> 
								</xsl:otherwise>
							</xsl:choose>
							<p class="figure-caption">{$image-caption}</p>
						</div>
						<xsl:apply-templates select="ouc:div[@label='socialcontent']" />
					</div>
					<xsl:if test="$tags !='' or ouc:pcf-param('department') !=''">
						<div class="col-lg-5 col-xl-4">
							<div id="sidebar" class="mt-4">
								<xsl:call-template name="related-news">
								</xsl:call-template>
								<a href="{$ou:dirname}/index.html" class="btn btn-default mt-5">Return to News</a>
							</div>
						</div>
					</xsl:if>
				</div>

				<div class="row mt-3"> 
					<div class="col-12">
						<div class="post-content mb-5">
							<xsl:apply-templates select="ouc:div[@label='maincontent']" />
						</div>

					</div>
				</div><!--End Row-->
			</div><!--End Container-->
		</div>
	</xsl:template>


	<xsl:template name="related-news">
		<xsl:param name="items-per-page" select="(ou:pcf-param('items-per-page') => number(), 10)[boolean(.)][1]"/>
		<xsl:param name="filter-tags" select="$tags => normalize-space() => tokenize('\s*,\s*')"/>
		<xsl:param name="filter-strength" select="ouc:pcf-param('filter-strength')"/>
		<xsl:variable name="filtering_tags" select="ouc:pcf-param('filter-strength')"/>

		<xsl:variable name="filters">
			<xsl:if test ="$tags !=''">
				<xsl:if test='$filtering_tags = "or"'>tags/tag[
				</xsl:if>
				<xsl:if test="$tags !=''">
					<xsl:try>
						<xsl:for-each select="tokenize($tags, ',')"><xsl:if test='$filtering_tags = "and"'>tags/tag[
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
		<xsl:variable name="dir" select="$ou:dirname"></xsl:variable>


		<xsl:variable name="sort">date(item_date) desc</xsl:variable>

		<xsl:call-template name="dmc">
			<xsl:with-param name="options">
				<directory>{$dir}</directory>
				<items_per_page>5</items_per_page>
				<datasource>news</datasource>
				<xpath>
					<xsl:choose>
						<xsl:when test="$tags !='' or ouc:pcf-param('department') !=''">
							items/item[@href!='{$ou:path}'and{$filters}]
						</xsl:when>
						<xsl:otherwise>
							items/item[@href!='{$ou:path}']
						</xsl:otherwise>
					</xsl:choose>
				</xpath>
				<type>related</type>
				<querystring_control>true</querystring_control>				
				<sort>{$sort}</sort>
			</xsl:with-param>
			<xsl:with-param name="script-name">news</xsl:with-param>
			<!-- 			<xsl:with-param name="debug" select="true()"/> -->
		</xsl:call-template>
	</xsl:template>




</xsl:stylesheet>