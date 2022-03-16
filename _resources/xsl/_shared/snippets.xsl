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

<!--
Implementation Skeleton - 08/24/2018

Snippets XSL
Customer Snippets
-->

<xsl:stylesheet version="3.0"
				xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
				xmlns:xs="http://www.w3.org/2001/XMLSchema"
				xmlns:ou="http://omniupdate.com/XSL/Variables"
				xmlns:fn="http://omniupdate.com/XSL/Functions"
				xmlns:ouc="http://omniupdate.com/XSL/Variables"
				expand-text="yes"
				exclude-result-prefixes="xs ou fn ouc">

	<!-- Figure and Caption --> 
	<xsl:template match="table[@class='ou-figure-caption']">
		<div class="figure"> 
			<xsl:choose>
				<xsl:when test="tbody/tr[1]/td/descendant::img/@src !=''"><img src="{tbody/tr[1]/td/descendant::img/@src}" class="figure-img" alt="{tbody/tr[1]/td/descendant::img/@alt}"/></xsl:when>
				<xsl:otherwise><xsl:apply-templates select="tbody/tr[1]/td/node()"/></xsl:otherwise>
			</xsl:choose>
			<p class="figure-caption">{ou:textual-content(tbody/tr[2]/td/node())}</p>
		</div>
	</xsl:template>

	<!--Gallery Slider with Lightbox -->

	<xsl:template match="table[@class='ou-carousel-gallery']">
		<div class="gallery-slider-wrapper">
			<div class="gallery-slider">
				<xsl:apply-templates select="tbody/tr/td/gallery/images/image"></xsl:apply-templates>
			</div>
		</div>
	</xsl:template>

	<xsl:template match="table[@class='ou-carousel-gallery']/tbody/tr/td/gallery/images/image">
		<div class="slide">
			<xsl:choose>
				<xsl:when test="link !=''">
					<a title="{title}" href="{@url}" data-caption="{caption}"> <img src="{@url}" alt="{description}" /></a>
				</xsl:when>
				<xsl:otherwise>
					<img src="{@url}" alt="{description}" />
				</xsl:otherwise>
			</xsl:choose>
		</div>
	</xsl:template>

	<!-- Home Page Feature -->
	<xsl:template match="table[@data-snippet='ou-full-width-feature']">
		<section class="bg-gray fullwidth-split">
			<div class="container-fluid">
				<div class="row no-gutters">
					<div class="col-md-6 fullwidth-split-image">
						<xsl:if test="tbody/tr[6]/td/node()='Right'">
							<xsl:attribute name="class">col-md-6 fullwidth-split-image order-md-2</xsl:attribute>
						</xsl:if>
						<img class="bg-image" src="{tbody/tr[5]/td/descendant::img/@src}" alt="{tbody/tr[5]/td/descendant::img/@alt}"/></div>
					<div class="col-md-6 fullwidth-split-text">
						<xsl:if test="tbody/tr[6]/td/node()='Right'">
							<xsl:attribute name="class">col-md-6 fullwidth-split-text order-md-1</xsl:attribute>
						</xsl:if>
						<div class="text-wrapper">
							<xsl:if test="tbody/tr[6]/td/node()='Right'">
								<xsl:attribute name="class">text-wrapper text-right</xsl:attribute>
							</xsl:if>
							<h2>{tbody/tr[1]/td/node()}</h2>
							<h3>{tbody/tr[2]/td/node()}</h3>
							<span class="lead pb-3">{tbody/tr[3]/td/node()}</span>
							<p><a class="btn btn-default"><xsl:apply-templates select="tbody/tr[4]/td/descendant::a/attribute()"/>{tbody/tr[4]/td/descendant::a}</a></p>
						</div>
					</div>
				</div>
			</div>
		</section>
	</xsl:template>


	<!-- Cards -->
	<xsl:template match="table[@data-snippet='ou-cards']">
		<xsl:param name="items" select="tbody/tr[@data-name='item']"/>
		<div class="row">
			<xsl:for-each select="$items">
				<xsl:variable name="heading" select="ou:get-value(td[@data-name='heading'])"/>
				<div class="col-lg-4">
					<div class="card">
						<xsl:if test="td[@data-name='image']/descendant::img/@src !=''">
							<xsl:apply-templates select="td[@data-name='image']/descendant::img"/>
						</xsl:if>
						<div class="card-body">
							<h3><xsl:value-of select="$heading"/></h3>
							<xsl:apply-templates select="td[@data-name='content']/node()"/>
						</div>
					</div>
				</div>
			</xsl:for-each>
		</div>
	</xsl:template>

	<!-- Row -->
	<xsl:template match="table[@data-snippet='ou-row']">
		<div class="row">
			<div class="col">
				<xsl:apply-templates select="tbody/tr/td/node()"/>
			</div>
		</div>
	</xsl:template>


	<xsl:template match="table[@data-snippet='ou-testimonials']">
		<div class="slider-wrapper section section-with-background">
			<div class="testimonial-slider">
				<xsl:apply-templates select="tbody/tr"/>
			</div>
		</div>
	</xsl:template>

	<xsl:template match="table[@data-snippet='ou-testimonials']/tbody/tr">
		<div class="slide"><img src="{td[4]/descendant::img/@src}" alt="{td[4]/descendant::img/@src}" />
			<div class="testimonial-quote">
				<p>{td[3]/node()}</p>
			</div>
			<div class="testimonial-name">
				<p><strong>{td[1]/node()}</strong><xsl:if test="td[2]/node() != ''"> - {td[2]/node()}</xsl:if></p>
			</div>
		</div>
	</xsl:template>


	<xsl:template match="table[@data-snippet='ou-program-finder-cta']">
		<xsl:variable name="link" select="tbody/tr[3]/td[1]/descendant::a/@href"/>
		<xsl:variable name="link-text" select="tbody/tr[3]/td[1]/descendant::a/."/>
		<div class="card text-center">
			<div class="card-body">
				<p style="font-size:20px;" class="card-title"><xsl:value-of select="tbody/tr[1]/td[1]/."/></p>
				<p class="card-text"><xsl:value-of select="tbody/tr[2]/td[1]/."/></p>
				<a href="{$link}" class="btn btn-primary"><xsl:apply-templates select="tbody/tr[3]/td[1]/descendant::a/attribute()[name() != 'class']"/>{$link-text}</a>
			</div>
		</div>
	</xsl:template>


	<xsl:template match="table[@data-snippet='ou-stats']">
		<div class="section bg-blue">
			<div class="container">
				<div class="row">
					<xsl:apply-templates select="tbody/tr"/>
				</div>
			</div>
		</div>
	</xsl:template>

	<xsl:template match="table[@data-snippet='ou-stats']/tbody/tr">
		<xsl:if test="td[1]/node() !=''">
			<div class="col-md-4">
				<div class="icon">
					<span class="fas fa-{td[4]/node()}"></span>
					<xsl:if test="td[1]/node() !=''">
						<span>{ou:textual-content(td[1]/node())}</span>
					</xsl:if>
					<xsl:if test="td[2]/node() !=''">
						<span>{ou:textual-content(td[2]/node())}
							<xsl:if test="td[3]/node() !=''">
								<br/>{ou:textual-content(td[3]/node())}
							</xsl:if>
						</span>
					</xsl:if>
				</div>
			</div>
		</xsl:if>
	</xsl:template>


	<xsl:template match="table[@class='ou-snippet-two-column-content']">
		<div class="row mx-md-n5">
			<div class="col px-md-5">
				<div class="p-3 border bg-light"><xsl:apply-templates select="tbody/tr[1]/td[1]/node()"/></div>
			</div>
			<div class="col px-md-5">
				<div class="p-3 border bg-light"><xsl:apply-templates select="tbody/tr[1]/td[2]/node()"/></div>
			</div>
		</div>
	</xsl:template>

	<xsl:template match="table[@class='ou-snippet-three-column-content']">
		<div class="container">
			<div class="row">
				<div class="col-sm">
					<xsl:apply-templates select="tbody/tr[1]/td[1]/node()"/>
				</div>
				<div class="col-sm">
					<xsl:apply-templates select="tbody/tr[1]/td[2]/node()"/>
				</div>
				<div class="col-sm">
					<xsl:apply-templates select="tbody/tr[1]/td[3]/node()"/>
				</div>
			</div>
		</div>
	</xsl:template>


	<xsl:template match="table[@class='ou-snippet-data-tables']">
		<xsl:apply-templates />
	</xsl:template>

	<xsl:template match="table[@class='ou-snippet-blockquote']">
		<blockquote class="blockquote">
			<p class="mb-0"><xsl:apply-templates select="tbody/tr[1]/td[1]/node()"/></p>
		</blockquote>
	</xsl:template>


	<xsl:template match="table[@data-snippet='ou-columns']">
		<xsl:param name="rows" select="tbody/tr[@data-name='row'][ou:not-empty(.)]"/>

		<xsl:variable name="row-width">12</xsl:variable>

		<xsl:for-each select="$rows">
			<xsl:variable name="columns" select="count(td[@data-name='content'])"/>
			<xsl:variable name="col-width" select="$row-width idiv $columns"/>

			<div class="row">
				<xsl:for-each select="td[@data-name='content']">
					<div class="col-sm-{$col-width}">
						<xsl:apply-templates select="node()"/>
					</div>
				</xsl:for-each>
			</div>
		</xsl:for-each>
	</xsl:template>

	<!-- Accordion Element -->
	<xsl:template match="table[@data-snippet='ou-accordion']">
		<xsl:param name="expand-panel" select="ou:get-value(tbody/tr/td[@data-name='expand-panel'])"/>
		<xsl:param name="items" select="tbody/tr[@data-name='item']"/>

		<xsl:variable name="accordion-id" select="'accordion-' || generate-id()"/>

		<xsl:if test="$items[ou:get-value(td[@data-name='heading'])]">
			<div id="{$accordion-id}" class="accordion">
				<xsl:for-each select="$items">
					<xsl:variable name="heading" select="ou:get-value(td[@data-name='heading'])"/>
					<xsl:variable name="content" select="ou:get-value(td[@data-name='content'])"/>

					<xsl:variable name="item-id" select="'item-' || generate-id()"/>
					<xsl:if test="$heading">
						<div class="card">
							<div id="{$item-id}-headingOne" class="card-header">
								<h3 class="mb-0"><button class="btn btn-link accordion-trigger" data-toggle="collapse" data-target="#{$item-id}-collapseOne" aria-expanded="false" aria-controls="{$item-id}-collapseOne">{$heading}<span class="fas fa-angle-down"></span><span class="fas fa-angle-up"></span></button></h3>
							</div>
							<div id="{$item-id}-collapseOne" class="collapse" aria-labelledby="{$item-id}-headingOne" data-parent="#{$accordion-id}">
								<xsl:if test="$expand-panel = position()">
									<xsl:attribute name="class">collapse show</xsl:attribute>
								</xsl:if>
								<div class="card-body">
									<xsl:apply-templates select="$content"/>
								</div>
							</div>
						</div>
					</xsl:if>
				</xsl:for-each>
			</div>
		</xsl:if>
	</xsl:template>

	<!-- Tabs -->
	<xsl:template match="table[@data-snippet='ou-tabs']">
		<xsl:param name="tab-shown" select="ou:get-value(tbody/tr/td[@data-name='tab-shown'])"/>
		<xsl:param name="items" select="tbody/tr[@data-name='item']"/>

		<xsl:variable name="valid-tab-shown" as="xs:numeric">
			<xsl:choose>
				<xsl:when test="$tab-shown and ou:get-value($items[$tab-shown]/td[@data-name='heading'])">
					<xsl:copy-of select="$tab-shown"/>
				</xsl:when>
				<xsl:otherwise>1</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>

		<xsl:if test="$items[ou:get-value(td[@data-name='heading'])]">
			<xsl:variable name="nav-id" select="'tab-' || generate-id() || '-nav'"/>
			<xsl:variable name="content-id" select="'tab-' || generate-id() || '-content'"/>
			<div class="tabs"><nav>
				<div id="nav-{$nav-id}" class="nav nav-tabs" role="tablist">
					<xsl:for-each select="$items">
						<xsl:variable name="heading" select="ou:get-value(td[@data-name='heading'])"/>
						<xsl:variable name="item-id" select="'item-' || generate-id()"/>
						<xsl:variable name="tab-id" select="$item-id || '-tab'"/>

						<a id="{$item-id}-parent" class="nav-item nav-link" href="#{$item-id}" data-toggle="tab" role="tab" aria-controls="{$item-id}" aria-selected="true">
							<xsl:if test="position() = $valid-tab-shown">
								<xsl:attribute name="class">nav-item nav-link active</xsl:attribute>
								<xsl:attribute name="aria-selected">true</xsl:attribute>
							</xsl:if>
							<xsl:value-of select="$heading"/></a> 
					</xsl:for-each>
				</div>
				</nav>
				<div id="nav-tabContent-a" class="tab-content">
					<xsl:for-each select="$items">
						<xsl:variable name="heading" select="ou:get-value(td[@data-name='heading'])"/>
						<xsl:variable name="content" select="ou:get-value(td[@data-name='content'])"/>

						<xsl:variable name="item-id" select="'item-' || generate-id()"/>
						<xsl:variable name="tab-id" select="$item-id || '-parent'"/>

						<xsl:if test="$heading">
							<div class="tab-pane fade" id="{$item-id}" role="tabpanel" aria-labelledby="{$tab-id}">
								<xsl:if test="position() = $valid-tab-shown">
									<xsl:attribute name="class">tab-pane fade show active</xsl:attribute>
								</xsl:if>
								<xsl:apply-templates select="$content"/>
							</div>
						</xsl:if>
					</xsl:for-each>
				</div>
			</div>
		</xsl:if>


	</xsl:template>

	<!-- Vertical Tabs -->
	<xsl:template match="table[@data-snippet='ou-tabs-vertical']">
		<xsl:param name="tab-shown" select="ou:get-value(tbody/tr/td[@data-name='tab-shown'])"/>
		<xsl:param name="items" select="tbody/tr[@data-name='item']"/>

		<xsl:variable name="valid-tab-shown" as="xs:numeric">
			<xsl:choose>
				<xsl:when test="$tab-shown and ou:get-value($items[$tab-shown]/td[@data-name='heading'])">
					<xsl:copy-of select="$tab-shown"/>
				</xsl:when>
				<xsl:otherwise>1</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>

		<xsl:if test="$items[ou:get-value(td[@data-name='heading'])]">
			<xsl:variable name="nav-id" select="'tab-' || generate-id()"/>
			<xsl:variable name="content-id" select="'tab-' || generate-id() || '-content'"/>
			<div class="row">
				<div class="col-3">
					<div id="v-pills-{$nav-id}" class="nav flex-column nav-pills" role="tablist" aria-orientation="vertical">
						<xsl:for-each select="$items">
							<xsl:variable name="heading" select="ou:get-value(td[@data-name='heading'])"/>
							<xsl:variable name="item-id" select="'v-pills-item-' || generate-id()"/>
							<xsl:variable name="tab-id" select="$item-id || '-tab'"/>

							<a id="{$item-id}-tab" class="nav-link" href="#{$item-id}" data-toggle="pill" role="tab" aria-controls="{$item-id}">
								<xsl:if test="position() = $valid-tab-shown">
									<xsl:attribute name="class">nav-link active</xsl:attribute>
									<xsl:attribute name="aria-selected">true</xsl:attribute>
								</xsl:if>
								<xsl:value-of select="$heading"/></a> 
						</xsl:for-each>
					</div>
				</div>

				<div class="col-9">
					<div id="v-pills-{$nav-id}Content" class="tab-content">
						<xsl:for-each select="$items">
							<xsl:variable name="heading" select="ou:get-value(td[@data-name='heading'])"/>
							<xsl:variable name="content" select="ou:get-value(td[@data-name='content'])"/>

							<xsl:variable name="item-id" select="'v-pills-item-' || generate-id()"/>
							<xsl:variable name="tab-id" select="$item-id || '-tab'"/>

							<xsl:if test="$heading">
								<div id="{$item-id}" class="tab-pane fade" role="tabpanel" aria-labelledby="{$item-id}-tab">
									<xsl:if test="position() = $valid-tab-shown">
										<xsl:attribute name="class">tab-pane fade show active</xsl:attribute>
									</xsl:if>
									<xsl:apply-templates select="$content"/>
								</div>
							</xsl:if>
						</xsl:for-each>



					</div>
				</div>

			</div>
		</xsl:if>


	</xsl:template>


	<xsl:template match="table[@data-snippet='ou-image-card']">
		<div class="card mb-3" style="max-width: 540px;">
			<div class="row no-gutters">
				<div class="col-md-4">
					<xsl:variable name="image" select="tbody[1]/tr[1]/td[1]/descendant::img/@src"/>
					<xsl:variable name="image-alt" select="tbody[1]/tr[1]/td[1]/descendant::img/@alt"/>
					<img src="{$image}" class="card-img" alt="{$image-alt}"/>
				</div>
				<div class="col-md-8">
					<div class="card-body">
						<p style="font-size:18px;" class="card-title"><xsl:value-of select="tbody/tr[2]/td[1]/."/></p>
						<p class="card-text"><xsl:apply-templates select="tbody/tr[3]/td[1]/node()"/></p>
					</div>
				</div>
			</div>
		</div>
	</xsl:template>

	<xsl:template match="table[@class='ou-snippet-space']">
		<span class="ou-space"></span>
	</xsl:template>

	<xsl:template match="table[@class='ou-snippet-space-2x']">
		<span class="ou-space-2x"></span>
	</xsl:template>

	<!-- Tables -->

	<xsl:template match="table[not(contains(@class, 'ou-'))]">
		<div class="table-responsive">
			<table>
				<xsl:attribute name="class">table <xsl:value-of select="@class"/></xsl:attribute>
				<xsl:apply-templates/>
			</table>
		</div>
	</xsl:template>


	<!-- Card -->

	<xsl:template match="table[@class='ou-card']">
		<div class="card bg-secondary">
			<xsl:choose>
				<xsl:when test="tbody/tr[4]/td/node() = 'Grey'">
					<xsl:attribute name="class">card bg-secondary</xsl:attribute>
				</xsl:when>
				<xsl:otherwise>
					<xsl:attribute name="class">card white</xsl:attribute>
				</xsl:otherwise>
			</xsl:choose>
			<div class="card-body">
				<h3 class="card-title">{ou:textual-content(tbody/tr[1]/td/node())}</h3>
				<p class="card-text">{ou:textual-content(tbody/tr[2]/td/node())}</p>
				<a class="btn btn-default"><xsl:apply-templates select="tbody/tr[3]/td/descendant::a/attribute()"/>{ou:textual-content(tbody/tr[3]/td/descendant::a)}</a>
			</div>
		</div>
	</xsl:template>

	<!-- Image Grid -->

	<xsl:template match="table[@data-snippet='ou-image-grid']">
		<xsl:variable name="id" select="generate-id()"/>
		<div class="row justify-content-center text-center section-intro">
			<div class="row">
				<xsl:for-each select="tbody/tr">
					<div class="col-sm-4 mb-3"><a href="{td[1]/descendant::img/@src}" data-lightbox="gallery-{$id}" data-title="{td[1]/descendant::img/@alt}"> <img class="thumbnail" src="{td[1]/descendant::img/@src}" alt="{td[1]/descendant::img/@alt}" />
						<h3>{td[2]/node()}</h3>
						</a>
					</div>
				</xsl:for-each>
			</div>
		</div>
	</xsl:template>

	<!-- Introductory Section -->

	<xsl:template match="table[@data-snippet='ou-intro']">
		<div class="row justify-content-center text-center section-intro">
			<div class="col-12 col-md-9 col-lg-8">
				<xsl:if test="ou:textual-content(tbody/tr[1]/td/node()) !=''">
					<span class="title-decorative">{tbody/tr[1]/td/node()}</span>
				</xsl:if>
				<xsl:if test="ou:textual-content(tbody/tr[2]/td/node()) !=''">
					<h2 class="display-4">{tbody/tr[2]/td/node()}</h2>
				</xsl:if>
				<xsl:if test="ou:textual-content(tbody/tr[3]/td/node()) !=''">
					<p class="lead pb-3 font-weight-light">{tbody/tr[3]/td/node()}</p>
				</xsl:if>
			</div>
		</div>
	</xsl:template>


	<!-- Two White Boxes with Images  -->

	<xsl:template match="table[@data-snippet='ou-two-boxes']">
		<div class="row">
			<div class="col-12">
				<xsl:if test="ou:textual-content(tbody/tr[1]/td/node()) !=''">
					<h3 class="mt-5">{ou:textual-content(tbody/tr[1]/td/node())}</h3>
				</xsl:if>
				<div class="row">
					<div class="col-lg-6">
						<div class="card white">
							<xsl:if test="tbody/tr[6]/td[1]/descendant::img/@src !=''">
								<img src="{tbody/tr[6]/td[1]/descendant::img/@src}" class="card-img-top" alt="{tbody/tr[6]/td[1]/descendant::img/@alt}"/>
							</xsl:if>
							<div class="card-body">
								<h3 class="card-title">{ou:textual-content(tbody/tr[3]/td[1]/node())}</h3>
								<p class="card-text">{ou:textual-content(tbody/tr[4]/td[1]/node())}</p>
								<xsl:if test="tbody/tr[5]/td[1]/descendant::a/@href !=''">
									<a href="{tbody/tr[5]/td[1]/descendant::a/@href}" class="btn btn-default btn-blue"><xsl:apply-templates select="tbody/tr[5]/td[1]/descendant::a/attribute()"/>{tbody/tr[5]/td[1]/descendant::a}</a>
								</xsl:if>
							</div>
						</div>
					</div>
					<div class="col-lg-6">
						<div class="card white">
							<xsl:if test="tbody/tr[6]/td[2]/descendant::img/@src !=''">
								<img src="{tbody/tr[6]/td[2]/descendant::img/@src}" class="card-img-top" alt="{tbody/tr[5]/td[2]/descendant::img/@alt}"/>
							</xsl:if>
							<div class="card-body">
								<h3 class="card-title">{ou:textual-content(tbody/tr[3]/td[2]/node())}</h3>
								<p class="card-text">{ou:textual-content(tbody/tr[4]/td[2]/node())}</p>
								<xsl:if test="tbody/tr[5]/td[2]/descendant::a/@href !=''">
									<a href="{tbody/tr[5]/td[2]/descendant::a/@href}" class="btn btn-default btn-blue"><xsl:apply-templates select="tbody/tr[5]/td[1]/descendant::a/attribute()"/>{tbody/tr[5]/td[1]/descendant::a}</a>
								</xsl:if>
							</div>
						</div>
					</div>
				</div>
			</div><!--End Row-->
		</div>
	</xsl:template>


	<!-- Home Page News and Events Feed -->

	<xsl:template match="table[@class='ou-news-events']">
		<div class="section bg-blue">
			<div class="container">
				<div class="row">
					<div class="col-lg-6">
						<div class="news-events-header">
							<xsl:if test="tbody/tr/td[@data-name='header'][1]/node() !=''">{tbody/tr/td[@data-name='header'][1]/node()}</xsl:if>
							<a class="news"><xsl:apply-templates select="tbody/tr[2]/td[1]/descendant::a/attribute()"/><span class="far fa-newspaper"></span>{ou:textual-content(tbody/tr[2]/td[1]/descendant::a)}</a>
						</div>
						<div class="row">
							<xsl:apply-templates select="tbody/tr[3]/td[1]/node()"/>
						</div>
					</div>
					<div class="col-lg-5 offset-lg-1 events">
						<div class="news-events-header">
							<xsl:if test="tbody/tr/td[@data-name='header'][2]/node() !=''">{tbody/tr/td[@data-name='header'][2]/node()}</xsl:if>
							<a class="events"><xsl:apply-templates select="tbody/tr[2]/td[2]/descendant::a/attribute()"/><span class="far fa-calendar-alt"></span> {ou:textual-content(tbody/tr[2]/td[2]/descendant::a)}</a>
						</div>
						<xsl:apply-templates select="tbody/tr[3]/td[2]/node()"/>
					</div>
				</div>
			</div>
		</div>
	</xsl:template>


	<!-- Video Snippet -->

	<xsl:template match="table[@data-snippet='ou-banner-video']" expand-text="yes">
		<xsl:param name="video" select="tbody/tr[@data-name='data']/td[@data-name='video']/video/source/@src"/>
		<xsl:param name="title" select="ou:get-value(tbody/tr[@data-name='data']/td[@data-name='title'])"/>
		<xsl:param name="subtitle" select="ou:get-value(tbody/tr[@data-name='data']/td[@data-name='subtitle'])"/>
		<xsl:param name="image" select="tbody/tr[@data-name='data']/td[@data-name='image']/descendant::img/@src"/>
		<xsl:param name="cta" select="ou:get-value(tbody/tr[@data-name='data']/td[@data-name='cta']/descendant::a)"/>

		<div class="slider-wrapper">
			<div class="video-feature" style="background-image: url('{$image}');">
				<xsl:if test="$title != '' or  $cta != ''">
					<div class="video-caption">
						<xsl:if test="$title != ''">
							<h1>{$title}</h1>
							<h2>{$subtitle}</h2>
						</xsl:if>
						<xsl:if test="$cta">
							<a class="btn btn-default">
								<xsl:apply-templates select="tbody/tr[@data-name='data']/td[@data-name='cta']/descendant::a/attribute()"></xsl:apply-templates>
								{$cta}
							</a>
						</xsl:if>
					</div>
				</xsl:if>
				<button type="button" class="play-pause" title="play/pause"><span class="fa fa-pause"></span><span class="sr-only">Pause Video</span></button> 
				<div data-video="{$video}" data-type="video/mp4" data-image="{$image}"><video id="myVideo" autoplay="true" muted="true" loop="true" playsinline="true"><source src="{$video}" type="video/mp4"/></video></div>
				<div class="overlay"></div>
			</div>
		</div>
	</xsl:template>







</xsl:stylesheet>