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
Widget Example: Global Footer Widget

This is an example widget that shows the usage of widget.xsl for the standard PCF to Include Global Footer solution.

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

If you have a mobile version of the footer as well, match with something like this:
<xsl:template match="/document[$is-pub and ends-with($ou:filename,'.mobile.html')]">
<xsl:call-template name="mobile-footer"/>
</xsl:template>
-->
	<xsl:template name="publish-output">
		<xsl:call-template name="common-footer"/>
	</xsl:template>

	<xsl:template name="common-header" />

	<xsl:template name="common-footer">
		<xsl:param name="name" select="ou:pcf-param('name') => normalize-space()" />
		<xsl:param name="name-link" select="ou:pcf-param('name-link') => normalize-space()" />
		<xsl:param name="address-1" select="ou:pcf-param('address-1') => normalize-space()" />
		<xsl:param name="address-2" select="ou:pcf-param('address-2') => normalize-space()" />
		<xsl:param name="address-3" select="ou:pcf-param('address-3') => normalize-space()" />
		<xsl:param name="address-link" select="ou:pcf-param('address-link') => normalize-space()" />
		<xsl:param name="phone" select="ou:pcf-param('phone') => normalize-space()" />
		<xsl:param name="phone-2" select="translate(ou:pcf-param('phone'), '-', '')" />
		<xsl:param name="fb" select="ou:pcf-param('facebook-link') => normalize-space()" />
		<xsl:param name="twitter" select="ou:pcf-param('twitter-link') => normalize-space()" />
		<xsl:param name="linkedin" select="ou:pcf-param('linkedin-link') => normalize-space()" />
		<xsl:param name="ig" select="ou:pcf-param('instagram-link') => normalize-space()" />
		<footer id="footer">
			<div class="container">
				<div class="row">
					<div class="col-lg-3 col-xl-3">
						<xsl:if test="ou:pcf-param('logo-img') != ''">
							<img class="pull-right" src="{ou:pcf-param('logo-img')}" alt="{ou:pcf-param('logo-description')}" />
						</xsl:if>
						<h2><a href="{$name-link}"><xsl:if test="$name">{$name}</xsl:if></a></h2>
						<ul class="footer-address">
							<li class="location">
								<a href="{$address-link}">
									<xsl:if test="$address-1">{$address-1}</xsl:if>
									<xsl:if test="$address-2"><br />{$address-2}</xsl:if>
									<xsl:if test="$address-3"><br />{$address-3}</xsl:if></a></li>
							<li><xsl:if test="$phone">
								<a href="tel:{$phone-2}">{$phone}</a>
								</xsl:if></li>
						</ul>
					</div>
					<div class="col-lg-9 col-xl-8 offset-xl-1">
						<div class="row footer-nav justify-content-center">
							<div class="col-6 col-md-3">
								<ul class="list-unstyled">
									<xsl:apply-templates select="ouc:div[@label = 'list-one']/descendant::li" />
								</ul>
							</div>
							<div class="col-6 col-md-3">
								<ul class="list-unstyled">
									<xsl:apply-templates select="ouc:div[@label = 'list-two']/descendant::li" />
								</ul>
							</div>
							<div class="col-6 col-md-3">
								<ul class="list-unstyled">
									<xsl:apply-templates select="ouc:div[@label = 'list-three']/descendant::li" />
								</ul>
							</div>
							<div class="col-6 col-md-3">
								<ul class="list-unstyled">
									<xsl:apply-templates select="ouc:div[@label = 'list-four']/descendant::li" />
								</ul>
							</div>
							<div class="col-12">
								<ul class="footer-social nav justify-content-center nav-fill">
									<xsl:if test="$fb">
										<li class="nav-item"><a href="{$fb}" class="facebook"><span class="sr-only">Facebook</span></a></li>
									</xsl:if>
									<xsl:if test="$twitter">
										<li class="nav-item"><a href="{$twitter}" class="twitter"><span class="sr-only">Twitter</span></a></li>
									</xsl:if>
									<xsl:if test="$ig">
										<li class="nav-item"><a href="{$ig}" class="instagram"><span class="sr-only">Instagram</span></a></li>
									</xsl:if>
									<xsl:if test="$linkedin">
										<li class="nav-item"><a href="{$linkedin}" class="linkedin"><span class="sr-only">LinkedIn</span></a></li>
									</xsl:if>
								</ul>
							</div>
						</div>
					</div>
				</div>
			</div>
			<div class="copyright">
				<div class="container">
					<div class="row">
						<div class="col-12">
							<ul class="list-inline">
								<li class="list-inline-item"><span id="directedit">&copy;</span>{ou:pcf-param('copyright-text')}</li>
								<xsl:for-each select="ouc:div[@label = 'sub-footer']//a">
									<li class="list-inline-item">
										<a>
											<xsl:apply-templates select="node()|attribute()[not(name() = 'class')]" />
										</a>
									</li>
								</xsl:for-each>
								<!-- 								<li class="list-inline-item"><a href="">Equal Opportunity Policy</a></li>
<li class="list-inline-item"><a href="">Privacy Policy</a></li>
<li class="list-inline-item"><a href="">Title IX Policy</a></li>
<li class="list-inline-item"><a href="">A Proud Member of the Nebraska State College System</a></li> -->
							</ul>
						</div>
					</div>
				</div>
			</div>
		</footer>
	</xsl:template>

	<xsl:template name="page-content">
		<div class="container-lg">
			<div class="row" style="min-height:200px;margin:15px;padding:15px;">
				<div class="col" style="margin-top:120px">
					<h2>Global Footer</h2>
					<p>Edit the global footer using the editable regions and page properties.</p>
					<hr />
				</div>
			</div>
		</div>
		<div class="container-lg">
			<div class="row">
				<div class="col-4">
					<xsl:apply-templates select="ouc:div[@label = 'sub-footer'][$is-edt]" mode="edt-btn" />
				</div>
				<div class="col-2">
					<xsl:apply-templates select="ouc:div[@label = 'list-one'][$is-edt]" mode="edt-btn" />
				</div>
				<div class="col-2">
					<xsl:apply-templates select="ouc:div[@label = 'list-two'][$is-edt]" mode="edt-btn" />
				</div>
				<div class="col-2">
					<xsl:apply-templates select="ouc:div[@label = 'list-three'][$is-edt]" mode="edt-btn" />
				</div>
				<div class="col-2">
					<xsl:apply-templates select="ouc:div[@label = 'list-four'][$is-edt]" mode="edt-btn" />
				</div>
			</div>
		</div>
	</xsl:template>

</xsl:stylesheet>