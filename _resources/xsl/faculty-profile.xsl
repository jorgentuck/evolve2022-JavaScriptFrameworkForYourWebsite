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
		<xsl:param name="name" select="concat(ou:multiedit-field('first_name'),' ', ou:multiedit-field('last_name'))"/>
		<xsl:variable name="image" select="ou:multiedit-field('image')/descendant::img/@src"/>
		<xsl:variable name="image-alt" select="ou:multiedit-field('image')/descendant::img/@alt"/>


		<div class="content" id="main-content">

			<div class="container">

				<div class="row"> 

					<div class="col-12">
						<nav aria-label="breadcrumb">
							<ol class="breadcrumb">
								<xsl:call-template name="output-breadcrumbs" />
							</ol>
						</nav>

						<h1 class="mb-5">Faculty Directory</h1>
					</div>
				</div>


				<div class="row">
					<div class="col-md-4 order-md-12"> 
						<xsl:choose>
							<xsl:when test="$image !=''">
								<img alt="{$image-alt}" src="{$image}" class="faculty-headshot"/>  
							</xsl:when>
							<xsl:otherwise>
								<img alt="Faculty Placeholder" src="/_resources/images/faculty-image-placeholder.jpg" class="faculty-headshot"/>  
							</xsl:otherwise>
						</xsl:choose>
					</div>

					<div class="col-md-8 order-md-1">
						<h2 class="font-weight-light font-size-lg">{$name}</h2>
						<xsl:if test="ou:multiedit-field('title') !=''">
							<h3>{ou:multiedit-field('title')}<xsl:if test="ou:multiedit-field('department') !=''">, {ou:multiedit-field('department')}</xsl:if></h3>
						</xsl:if>

						<div class="faculty-box">
							<xsl:if test="ou:multiedit-field('phone') !=''">
								<div class="faculty-box-info">
									<div class="faculty-box-info-title">Phone</div>
									<div class="faculty-box-info-desc">{ou:multiedit-field('phone')}</div>
								</div>
							</xsl:if>

							<xsl:if test="ou:multiedit-field('email') !=''">
								<div class="faculty-box-info">
									<div class="faculty-box-info-title">Email</div>
									<div class="faculty-box-info-desc">
										<a href="mailto:{ou:multiedit-field('email')}">{ou:multiedit-field('email')}</a>
									</div>
								</div>
							</xsl:if>

							<xsl:if test="ou:multiedit-field('fax') !=''">
								<div class="faculty-box-info">
									<div class="faculty-box-info-title">Fax</div>
									<div class="faculty-box-info-desc">
										{ou:multiedit-field('fax')}
									</div>
								</div>
							</xsl:if>
						</div>


						<div class="faculty-box">

							<xsl:if test="ou:multiedit-field('building') !=''">
								<div class="faculty-box-info">
									<div class="faculty-box-info-title">Office</div>
									<div class="faculty-box-info-desc">
										{ou:multiedit-field('room_number')} {ou:multiedit-field('building')}
									</div>
								</div>
							</xsl:if>

							<xsl:if test="ou:multiedit-field('office_hours') !=''">
								<div class="faculty-box-info">
									<div class="faculty-box-info-title">Office Hours</div>
									<div class="faculty-box-info-desc">
										{ou:multiedit-field('office_hours')}
									</div>
								</div>
							</xsl:if>

						</div>
					</div>
				</div>

				<div class="row">
					<div class="col-12">  
						<xsl:apply-templates select="ouc:div[@label='maincontent']"/>
					</div>
				</div>
			</div><!--End Container-->
		</div>
	</xsl:template>





</xsl:stylesheet>