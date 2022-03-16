<?xml version="1.0" encoding="utf-8"?>
<!DOCTYPE xsl:stylesheet>
<!--
Widget Example: Emergency Alert Widget

This is an example widget that shows the usage of widget.xsl for the standard PCF to Include Emergency Alert solution.

In some implementations, it may be unnecessary to override the page-content template. when applicable, override a template that is called within the page-content template.
Override <xsl:template name="publish-output"/> to output just the widget content.

Contributors: Akifumi Yamamoto
Last Updated: 2017/10/10
-->
<xsl:stylesheet version="3.0" 
				xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
				xmlns:xs="http://www.w3.org/2001/XMLSchema"
				xmlns:ou="http://omniupdate.com/XSL/Variables"
				xmlns:fn="http://omniupdate.com/XSL/Functions"
				xmlns:ouc="http://omniupdate.com/XSL/Variables"
				exclude-result-prefixes="xsl xs ou fn ouc"
				expand-text="yes"
				>

	<xsl:import href="widget.xsl"/>

	<xsl:template name="template-headcode"/>
	<xsl:template name="template-footcode"/>

	<xsl:template name="publish-output">
		<xsl:call-template name="common-alert"/>
	</xsl:template>

	<xsl:template name="page-content">
		<div style="margin-top: 200px;height:400px;padding:20px">
			<p>The edit and preview modes can have additional helpful content like edit options.</p>
		</div>
		<xsl:call-template name="common-alert"/>
	</xsl:template>

	<xsl:template name="common-alert">
		<xsl:if test="ou:pcf-param('show-alert') = 'true' or $ou:action = 'edt'">
			<xsl:variable name="content" select="ou:pcf-param('content') => normalize-space()" />
			<xsl:variable name="policy-link-text" select="ou:pcf-param('policy-link-text') => normalize-space()" />
			<xsl:variable name="policy-link" select="ou:pcf-param('policy-link') => normalize-space()" />
			<xsl:variable name="button-text" select="ou:pcf-param('button-text') => normalize-space()" />
			<div class="alert cookiealert" role="alert">
				<div class="container">
					<div class="row">
						<div class="col-lg-10">
							<span id="cookieconsent:desc" class="cc-message">{$content}
								<xsl:if test="$policy-link-text !='' and $policy-link !=''">
									<a aria-label="learn more about cookies" role="button" tabindex="0" class="cc-link" href="{$policy-link}" rel="noopener noreferrer nofollow" target="_blank">{$policy-link-text}</a>
								</xsl:if>
							</span>
						</div>
						<div class="col-lg-2">
							<div class="cc-compliance"><a aria-label="dismiss cookie message" role="button" tabindex="0" class="btn btn-default btn-light-2 acceptcookies">{$button-text}</a></div>
						</div>
					</div>
				</div>
			</div>

		</xsl:if>
	</xsl:template>

</xsl:stylesheet>
