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
Widget Example: Global Header Widget

This is an example widget that shows the usage of widget.xsl for the standard PCF to Include Global Header solution.

In some implementations, it may be unnecessary to override the page-content template. when applicable, override a template that is called within the page-content template.
Override <xsl:template name="publish-output"/> to output just the widget content.
-->
<xsl:stylesheet version="3.0" expand-text="yes"
				xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
				xmlns:xs="http://www.w3.org/2001/XMLSchema"
				xmlns:ou="http://omniupdate.com/XSL/Variables"
				xmlns:fn="http://omniupdate.com/XSL/Functions"
				xmlns:ouc="http://omniupdate.com/XSL/Variables"
				xmlns:xlink="https://www.w3.org/1999/xlink"
				xmlns:map="http://www.w3.org/2005/xpath-functions/map"
				xmlns:func="http://www.w3.org/2005/xpath-functions"
				exclude-result-prefixes="xs ou fn ouc xlink map func">

	<xsl:import href="widget.xsl"/>

	<xsl:template name="template-footcode"/>

	<!--
The mobile version of the header has a different publish output.
Create a new template match in addition to using the default publish-output template for the main header.
-->
	<xsl:template match="/document[$is-pub and ends-with($ou:filename,'.mobile.html')]">
		<xsl:call-template name="mobile-header"/>
	</xsl:template>
	<xsl:template name="publish-output">
		<xsl:call-template name="common-header"/>
	</xsl:template>

	<xsl:template match="comment()" />
	<xsl:template name="mobile-header" />

	<xsl:template name="page-content">
		<div class="container-lg">
			<div class="row" style="min-height:350px;margin:15px;padding:15px;">
				<div class="col" >
					<xsl:apply-templates select="ouc:div[@label = 'main-navigation'][$is-edt]" mode="edt-btn" />
					<!-- 					<xsl:apply-templates select="ouc:div[@label = 'audience-navigation'][$is-edt]" mode="edt-btn" /> -->
					<xsl:apply-templates select="ouc:div[@label = 'utility-navigation'][$is-edt]" mode="edt-btn" />
					<hr />
					<h2>Global Header</h2>
					<p>Edit the global header using the editable regions and page properties.</p>
				</div>
			</div>
		</div>
	</xsl:template>

	<xsl:template name="common-header">
		<header class="siteHeader sticky-wrapper">    

			<!-- Mobile Logo, Icons -->
			<div class="container-fluid mobile-header"> 
				<div class="row">
					<div class="col-12">
						<div class="mobile-logo"><a href="{ou:pcf-param('logo-link')}"><span class="sr-only">Gallena University</span></a></div>

						<div class="mobile-buttons-wrapper">
							<button type="button" data-toggle="modal" data-target="#site-navigation" class="menuToggle"><span class="sr-only">Menu</span><span class="fas fa-bars"></span></button>
						</div>
					</div>
				</div>
			</div>


			<div class="modal fade site-navigation" id="site-navigation" tabindex="-1" role="dialog">
				<div class="modal-dialog" role="document">
					<div class="modal-content">
						<div class="modal-body">
							<button type="button" class="btn menuClose" data-dismiss="modal"><span class="far fa-times-circle"></span><span class="sr-only">Close Menu</span></button>

							<!--Main Top Menu-->    
							<nav class="main-navigation" aria-label="Primary navigation">
								<div class="top-row">
									<div class="container-fluid">
										<div class="row">
											<div class="col-xl-2">
												<div class="logo"><a href="{ou:pcf-param('logo-link')}"><span class="sr-only">Gallena University</span></a></div>
											</div>
											<div class="col-xl-10">
												<nav class="audience">
													<ul class="nav justify-content-end">
														<xsl:for-each select="ouc:div[@label = 'utility-navigation']//a">
															<li class="nav-item">
																<a class="nav-link">
																	<xsl:apply-templates select="node()|attribute()[not(name() = 'class')]" />
																</a>
															</li>
														</xsl:for-each>
													</ul>
												</nav>
											</div>
										</div>
									</div>
								</div>
								<div class="bottom-row">
									<div class="container-fluid">
										<div class="row">
											<div class="col offset-xl-2">
												<ul class="nav justify-content-end nav-fill">
													<xsl:for-each select="ouc:div[@label = 'main-navigation']//a">
														<li class="nav-item">
															<a class="nav-link">
																<xsl:apply-templates select="node()|attribute()[not(name() = 'class')]" />
															</a>
														</li>
													</xsl:for-each>
													<li>
														<div class="header-search hidden-xs">
															<form id="searchForm" action="/search/index.html?" method="get" role="search" novalidate="novalidate">
																<div class="input-group">
																	<label class="search-label sr-only" for="searchbox">Search the Site</label>
																	<input type="text" id="ousearchq" class="form-control" title="ousearchq" name="ousearchq" placeholder="Search..."/>
																	<span class="input-group-btn">
																		<button class="btn btn-default" type="submit"><span class="fas fa-search"></span><span class="sr-only">Search</span></button>
																	</span>
																</div>
															</form>
														</div>
													</li>
												</ul>
											</div>
										</div>
									</div>
								</div>
							</nav>
						</div>
					</div>
				</div>
			</div>


		</header>

	</xsl:template>

</xsl:stylesheet>