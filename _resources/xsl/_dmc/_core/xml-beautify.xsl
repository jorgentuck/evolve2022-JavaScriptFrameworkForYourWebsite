<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="3.0"
xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
xmlns:xs="http://www.w3.org/2001/XMLSchema"
xmlns:ou="http://omniupdate.com/XSL/Variables"
xmlns:ouc="http://omniupdate.com/XSL/Variables"
exclude-result-prefixes="xs ou ouc">
	
	
<!-- 	<xsl:strip-space elements="*" /> -->
<!-- 	<xsl:output method="xml" indent="yes" omit-xml-declaration="no"/> -->


	<xsl:variable name="theme-name">monokai</xsl:variable>
	
	<!-- Format nicely for preview -->
	<xsl:template match="/document[($ou:action != 'pub')]" priority="1">
		<xsl:variable name="post-xml"><xsl:next-match/></xsl:variable>
		<xsl:variable name="lines"><xsl:apply-templates select="$post-xml" mode="xml-beautify"/></xsl:variable>
		<xsl:variable name="gutter-digits" select="string-length(string(count($lines/*)))" as="xs:integer"/>

		<!-- Forces the PCF to render correctly in Edit tab when there are no Editable Regions. -->
		<xsl:variable name="fake-editable-region">
			<ouc:div label="fake" hide="true" />
		</xsl:variable>
		<xsl:apply-templates select="$fake-editable-region/ou:div[@label='fake']" />
		
		<html>
			<head>
				<xsl:call-template name="code-styling">
					<!-- Gutter Width determined by line count's number of digits. -->
					<xsl:with-param name="gutter-width" select="($gutter-digits idiv 2) + 2"/>
				</xsl:call-template>
			</head>
			<body class="cm-s-{$theme-name} CodeMirror">
				<div class="cm-preview-watermark"></div>
				
				<div id="code-editor" class="code-editor">
					<div class="CodeMirror-sizer">
						<div class="CodeMirror-code">
							<xsl:apply-templates select="$lines/*" mode="xml-beautify-line-output"/>
						</div>
					</div>
				</div>
			</body>
		</html>
	</xsl:template>
	
	
	
	<!--
		Convert XML to String
		Element Matches
	-->
	
	<xsl:variable name="newline"><xsl:text>&#xD;&#xA;</xsl:text></xsl:variable>
	<xsl:variable name="tab"><xsl:text>&#x9;</xsl:text></xsl:variable>
	
	<!-- Attribute Output -->
	<xsl:template match="attribute()" mode="xml-beautify">
		<span class="cm-text"><xsl:text> </xsl:text></span>
		<span class="cm-attribute"><xsl:value-of select="name()"/></span>
		<span class="cm-text"><xsl:text>=</xsl:text></span>
		<span class="cm-string"><xsl:text>"</xsl:text><xsl:value-of select="."/><xsl:text>"</xsl:text></span>
	</xsl:template>
	
	<!-- Text Output -->
	<xsl:template match="text()" mode="xml-beautify">
		<span class="cm-text"><xsl:value-of select="."/></span>
	</xsl:template>
	
	<!-- Comment Output -->
	<xsl:template match="comment()" mode="xml-beautify">
		<span class="cm-comment"><xsl:text>&lt;!-- </xsl:text><xsl:value-of select="."/><xsl:text> --&gt;</xsl:text></span>
	</xsl:template>

	<!-- Element Output -->
	<!-- (Potentially self-closing or not nesting) -->
	<xsl:template match="element()" mode="xml-beautify">
		<xsl:param name="depth" as="xs:integer">0</xsl:param>
		
		<ou-line depth="{$depth}">
			<!-- Start Tag -->
			<xsl:call-template name="element-start">
				<xsl:with-param name="el" select="."/>
			</xsl:call-template>
		
			<xsl:if test="node()">
				<!-- Content -->
				<xsl:apply-templates select="node()" mode="xml-beautify">
					<xsl:with-param name="depth" select="$depth+1"/>
				</xsl:apply-templates>
				<!-- End Tag -->
				<xsl:call-template name="element-end">
					<xsl:with-param name="el" select="."/>
				</xsl:call-template>
			</xsl:if>
		</ou-line>
	</xsl:template>
	
	<!-- Element Output -->
	<!-- (With nested Children) -->
	<xsl:template match="element()[element()|comment()]" mode="xml-beautify">
		<xsl:param name="depth" as="xs:integer">0</xsl:param>
		
		<!-- Start Tag -->
		<ou-line depth="{$depth}">
			<xsl:call-template name="element-start">
				<xsl:with-param name="el" select="."/>
			</xsl:call-template>
		</ou-line>
		
		<!-- Content -->
		<xsl:apply-templates select="node()" mode="xml-beautify">
			<xsl:with-param name="depth" select="$depth+1"/>
		</xsl:apply-templates>
		
		<!-- End Tag -->
		<ou-line depth="{$depth}">
			<xsl:call-template name="element-end">
				<xsl:with-param name="el" select="."/>
			</xsl:call-template>
		</ou-line>
	</xsl:template>
	
	
	<!-- Wrap with line if siblings -->
	<xsl:template match="text()[parent::*[element()|comment()]]|
						 comment()[parent::*[element()|comment()]]" mode="xml-beautify">
		<xsl:param name="depth" as="xs:integer">0</xsl:param>
		
		<ou-line depth="{$depth}">
			<xsl:next-match/>
		</ou-line>
	</xsl:template>

	
	
	<!-- 
		Beautify Helpers
	-->
	
	
	<!-- Element START Tag -->
	<xsl:template name="element-start">
		<xsl:param name="el"/>
		<!-- Opening -->
		<span class="cm-bracket"><xsl:text>&lt;</xsl:text></span>
			<span class="cm-tag"><xsl:value-of select="$el/name()"/></span>
			<xsl:apply-templates select="$el/attribute()" mode="xml-beautify"/>
		<span class="cm-bracket"><xsl:if test="not($el/node())">/</xsl:if>&gt;</span>
	</xsl:template>
	
	<!-- Element END Tag -->
	<xsl:template name="element-end">
		<xsl:param name="el"/>
		<!-- Closing -->
		<span class="cm-bracket"><xsl:text>&lt;/</xsl:text></span>
		<span class="cm-tag"><xsl:value-of select="$el/name()"/></span>
		<span class="cm-bracket"><xsl:text>&gt;</xsl:text></span>
	</xsl:template>
	
	<!-- Creates a line -->
	<xsl:template match="ou-line|*[not(parent::*)]" mode="xml-beautify-line-output">
		<div class="cm-line">
			<!-- XSL uses this element to count lines to determine "linenumber gutter" width -->
			<div class="CodeMirror-gutter-wrapper">
				<!-- Prevent self closing, which causes issues in certain scenarios -->
				<xsl:text disable-output-escaping="yes">&lt;div class="CodeMirror-linenumber CodeMirror-gutter-elt"&gt;&lt;/div&gt;</xsl:text>
			</div>
			<pre>
				<xsl:call-template name="SOL">
					<xsl:with-param name="depth" select="if(@depth != '') then @depth else 0"/>
				</xsl:call-template>
				<xsl:copy-of select="node()"/>
			</pre>
		</div>
	</xsl:template>
	
	<!-- Start of Line -->
	<xsl:template name="SOL">
		<xsl:param name="depth" as="xs:integer">0</xsl:param>
		
		<!-- Opening Indenting -->
		<xsl:if test="($depth gt 0)">
			<!-- <span class="cm-newline"><xsl:value-of select="$newline"/></span> -->
			<xsl:for-each select="1 to $depth">
				<span class="cm-tab"><xsl:value-of select="$tab"/></span>
			</xsl:for-each>
		</xsl:if>
	</xsl:template>
	
	
	
	<xsl:template name="code-styling">
		<xsl:param name="gutter-width" as="xs:integer">2</xsl:param>
		
		<link rel="stylesheet" href="https://a.cms.omniupdate.com/resources/lib/codemirror-5.0/lib/codemirror.css"/>
		<link rel="stylesheet" href="https://a.cms.omniupdate.com/resources/lib/codemirror-5.0/theme/{$theme-name}.css"/>
		
		<style type="text/css">
			/* Based on Sublime Text's Monokai theme */

			.cm-s-<xsl:value-of select="$theme-name"/> .CodeMirror-activeline-background {background: #373831 !important;}
			.cm-s-<xsl:value-of select="$theme-name"/> .CodeMirror-matchingbracket {
			  text-decoration: underline;
			  color: white !important;
			}
			
			/* Custom CSS */
			html,body {margin: 0;}
			body {
				overflow-y: auto !important;
				padding-bottom: 1rem;
			}
			
			.cm-text {white-space: normal;}
			.cm-line {position: relative;}
			.cm-tab {width: 2rem;}
			.cm-tab {
				background-image: linear-gradient(to bottom, #75715e 40%, rgba(255, 255, 255, 0) 20%);
				background-position: left;
				background-size: 1px 0.2rem;
				background-repeat: repeat-y;
			}
			
			.CodeMirror-sizer {margin-left: <xsl:value-of select="$gutter-width"/>em;}
			.CodeMirror-gutter-wrapper {left: -<xsl:value-of select="$gutter-width"/>em;}
			
			.CodeMirror-code {counter-reset: cm-line-number;}
			.cm-line .CodeMirror-linenumber:before {
				counter-increment: cm-line-number;
				content: counter(cm-line-number);
			}
			
			.cm-preview-watermark:before {
				color: rgba(0,0,0,0.6);
				text-shadow: 1px 0px 2px rgba(255,255,255,0.1);
				content: 'Preview';
				display: block;
				text-align: center;
				font-size: 2rem;
				line-height: 3rem;
				font-weight: bold;
				font-family: arial;
				margin-bottom: 0.5rem;
				box-shadow: rgba(255,255,255,0.1) 0px 0px 5px;
			}
		</style>
	</xsl:template>
</xsl:stylesheet>