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
XSL Snippet Helper Add-On
=========================

These functions enhance the robustness of snippets.

Dependencies:
- For automatic typing, the element must have a @data-type value.
- For manual typing, pass in the type of the data you want or the value will default to basic text with all elements stripped out.

Usage:
Add the below statement inside a file that also imports the dependant file(s)
<xsl:import href="/absolute/path/to/snippet-helper.xsl"/>

=========================
-->

<xsl:stylesheet version="3.0" 
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xs="http://www.w3.org/2001/XMLSchema"
	xmlns:fn="http://www.w3.org/2005/xpath-functions"
	xmlns:ou="http://omniupdate.com/XSL/Variables"
	xmlns:ouc="http://omniupdate.com/XSL/Variables"
	exclude-result-prefixes="ou ouc xs fn">
	
	<xsl:param name="defcon-attributes" as="element(attributes)*">
		<attributes>
			<xsl:attribute name="class">alert danger</xsl:attribute>
			<xsl:attribute name="style">background-color: red</xsl:attribute>
		</attributes>
		<attributes>
			<xsl:attribute name="class">alert warning</xsl:attribute>
			<xsl:attribute name="style">background-color: orange</xsl:attribute>
		</attributes>
		<attributes>
			<xsl:attribute name="class">alert info</xsl:attribute>
			<xsl:attribute name="style">background-color: cyan</xsl:attribute>
		</attributes>
		<attributes>
			<xsl:attribute name="class">alert primary</xsl:attribute>
			<xsl:attribute name="style">background-color: blue</xsl:attribute>
		</attributes>
		<attributes>
			<xsl:attribute name="class">alert success</xsl:attribute>
			<xsl:attribute name="style">background-color: green</xsl:attribute>
		</attributes>
	</xsl:param>
	
	<xsl:function name="ou:get-value">
		<xsl:param name="parameter"/>
		
		<!-- Potential for other ways to retrieve the value -->
		<xsl:choose>
			<xsl:when test="$parameter instance of element()">
				<xsl:copy-of select="ou:get-value-by-element($parameter, $parameter/@data-type)" copy-namespaces="no"/>
			</xsl:when>
		</xsl:choose>
	</xsl:function>
	
	<xsl:function name="ou:get-value">
		<xsl:param name="parameter"/>
		<xsl:param name="type" as="xs:string?"/>
		
		<!-- Potential for other ways to retrieve the value -->
		<xsl:choose>
			<xsl:when test="$parameter instance of element()">
				<xsl:copy-of select="ou:get-value-by-element($parameter, $type)" copy-namespaces="no"/>
			</xsl:when>
		</xsl:choose>
	</xsl:function>
	
	<xsl:function name="ou:get-value-by-element">
		<xsl:param name="element" as="element()"/>
		<xsl:param name="type" as="xs:string?"/>
		
		<!-- Defaults to text -->
		<xsl:choose>
			<xsl:when test="$type = 'link'">
				<xsl:copy-of select="$element/descendant::a[1]" copy-namespaces="no"/>
			</xsl:when>
			<xsl:when test="$type = 'links'">
				<xsl:copy-of select="$element/descendant::a" copy-namespaces="no"/>
			</xsl:when>
			<xsl:when test="$type = 'list'">
				<xsl:copy-of select="$element/descendant::li" copy-namespaces="no"/>
			</xsl:when>
			<xsl:when test="$type = 'image-link'">
				<xsl:choose>
					<xsl:when test="$element/descendant::a[img]">
						<xsl:copy-of select="$element/descendant::a[img][1]" copy-namespaces="no"/>
					</xsl:when>
					<xsl:otherwise>
						<xsl:copy-of select="$element/descendant::img[1]" copy-namespaces="no"/>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:when>
			<xsl:when test="$type = 'text-link'">
				<xsl:choose>
					<xsl:when test="$element/descendant::a[normalize-space(replace(string(.), '&nbsp;', ' '))]">
						<xsl:copy-of select="$element/descendant::a[normalize-space(replace(string(.), '&nbsp;', ' '))][1]" copy-namespaces="no"/>
					</xsl:when>
					<xsl:otherwise>
						<xsl:copy-of select="normalize-space(replace(string($element), '&nbsp;', ' '))" copy-namespaces="no"/>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:when>
			<xsl:when test="$type = 'image'">
				<xsl:copy-of select="$element/descendant::img[1]" copy-namespaces="no"/>
			</xsl:when>
			<xsl:when test="$type = 'images'">
				<xsl:copy-of select="$element/descendant::img" copy-namespaces="no"/>
			</xsl:when>
			<xsl:when test="$type = 'wysiwyg'">
				<xsl:choose>
					<xsl:when test="$element/@data-add-p = 'true'">
						<xsl:copy-of select="ou:add-p-tags($element/node())" copy-namespaces="no"/>
					</xsl:when>
					<xsl:otherwise>
						<xsl:copy-of select="$element/node()" copy-namespaces="no"/>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:when>
			<xsl:when test="$type = 'number'">
				<xsl:copy-of select="number(replace(string($element), '&nbsp;', ' '))" copy-namespaces="no"/>
			</xsl:when>
			<xsl:when test="$type = 'list'">
				<xsl:copy-of select="$element/descendant::li" copy-namespaces="no"/>
			</xsl:when>
			<xsl:when test="$type = 'iframe'">
				<xsl:copy-of select="$element/descendant::iframe[1]" copy-namespaces="no"/>
			</xsl:when>
			<xsl:when test="$type = 'snippet'">
				<xsl:variable name="snippet-names" select="tokenize($element/@data-snippets, ',')"/>
				<xsl:copy-of select="$element/table[@data-snippet = $snippet-names][1]" copy-namespaces="no"/> <!-- No descendant::table in case there are nested snippets -->
			</xsl:when>
			<xsl:when test="$type = 'snippets'">
				<xsl:variable name="snippet-names" select="tokenize($element/@data-snippets, ',')"/>
				<xsl:copy-of select="$element/table[@data-snippet = $snippet-names]" copy-namespaces="no"/> <!-- No descendant::table in case there are nested snippets -->
			</xsl:when>
			<xsl:when test="$type = 'element'">
				<xsl:variable name="element-names" select="for-each(tokenize($element/@data-elements, ','), function($token) { normalize-space($token) })"/>
				<xsl:copy-of select="$element/node()[name() = $element-names][1]" copy-namespaces="no"/> <!-- Only check against direct children nodes, and only grab the first one -->
			</xsl:when>
			<xsl:when test="$type = 'elements'">
				<xsl:variable name="element-names" select="for-each(tokenize($element/@data-elements, ','), function($token) { normalize-space($token) })"/>
				<xsl:copy-of select="$element/node()[name() = $element-names]" copy-namespaces="no"/> <!-- Only check against direct children nodes -->
			</xsl:when>
			<xsl:otherwise>
				<xsl:copy-of select="normalize-space(replace(string($element), '&nbsp;', ' '))" copy-namespaces="no"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:function>
	
	<!--	
		<xsl:when test="$type = 'element'">
			<xsl:variable name="xpath" select="$element/@data-xpath"/>
			<xsl:copy-of select="$element/$xpath" copy-namespaces="no"/> <!-\- I don't think this works. -\->
		</xsl:when>
	-->
	
	<!--
		This function wraps adjacent groups of phrasing elements in p tags.
		This is useful for when the WYSIWYG editor doesn't always add p tags.
		Known cases:
		 - Mini-WYSIWYG in MultiEdit
		 - Table cells in WYSIWYG when users don't press `return`
		 
		Notes: 
		 Only phrasing elements are allowed inside p tags, so we group content by phrasing elements: https://www.w3.org/TR/html5/dom.html#phrasing-content
		 The variable may need adjusting depending on specification changes.
	-->
	<xsl:function name="ou:add-p-tags">
		<xsl:param name="content" as="node()*"/>
		<xsl:variable name="phrase-elements" select="('', 'a', 'abbr', 'area', 'audio', 'b', 'bdi', 'bdo', 'br', 'button', 'canvas', 'cite', 'code', 'data', 'datalist', 'del', 'dfn', 'em', 'embed', 'i', 'iframe', 'img', 'input', 'ins', 'kbd', 'keygen', 'label', 'map', 'mark', 'math', 'meter', 'noscript', 'object', 'output', 'progress', 'q', 'ruby', 's', 'samp', 'script', 'select', 'small', 'span', 'strong', 'sub', 'sup', 'svg', 'template', 'textarea', 'time', 'u', 'var', 'video', 'wbr')" />
		<xsl:for-each-group select="$content" group-adjacent="name() = $phrase-elements">
			<xsl:choose>
				<xsl:when test="current-grouping-key()">
					<xsl:if test="ou:not-empty(current-group())">
						<p><xsl:copy-of select="current-group()" copy-namespaces="no"/></p>
					</xsl:if>
				</xsl:when>
				<xsl:otherwise>
					<xsl:copy-of select="current-group()" copy-namespaces="no"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:for-each-group>
	</xsl:function>
	
	<!-- Is Element Empty -->
	<!--
		Example:
			ou:is-empty(ouc:div[@label='additional-content'])
	-->
	
	<xsl:mode name="is-empty-table-collapse" on-no-match="shallow-copy"/>
	<xsl:template match="table[starts-with(@class, 'ou-') or starts-with(@data-snippet, 'ou-')]" mode="is-empty-table-collapse"><xsl:apply-templates select="tbody/tr/td/node()" mode="#current"/></xsl:template>
	
	<xsl:function name="ou:is-empty" as="xs:boolean">
		<!-- [DEV] Future improvement: Check for type -->
		
		<xsl:param name="element"/>
		
		<!-- Collapse all table transformations so ou:textual-content doesn't find table headers/captions -->
		<xsl:variable name="element-collapsed"><xsl:apply-templates select="$element" mode="is-empty-table-collapse"/></xsl:variable>
		<!-- Debug output -->
		<!-- <xsl:apply-templates select="$element" mode="is-empty-table-collapse"/> -->
		
		<!-- Validating element names -->
		<xsl:variable name="elements-valid-by-name"                select="('br', 'hr', 'form', 'iframe', 'frame')"/>
		<!-- Validating element attributes -->
		<xsl:variable name="elements-valid-by-attribute"           select="('src', 'href')"/>
		<!-- Element names to be ignored by attribute check since they already failed content check -->
		<xsl:variable name="elements-valid-by-attribute-exception" select="('a')"/>
		
		
		<xsl:choose>
			<!-- Auto pass elements -->
			<xsl:when test="$element-collapsed/descendant::element()[name() = $elements-valid-by-name]">
				<xsl:sequence select="false()"/>
			</xsl:when>
			<!-- Check for any textual content -->
			<xsl:when test="(ou:textual-content($element-collapsed) != '')">
				<xsl:sequence select="false()"/>
			</xsl:when>
			<!-- Check for elements with a non-empty src/href attribute -->
			<!-- 'a' tags with no content, are considered empty, even with a valid href -->
			<xsl:when test="$element-collapsed/descendant::element()[attribute()[name() = $elements-valid-by-attribute] != ''][name() != $elements-valid-by-attribute-exception]">
				<xsl:sequence select="false()"/>
			</xsl:when>
			<!-- Element is considered EMPTY -->
			<xsl:otherwise>
				<xsl:sequence select="true()"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:function>
	
	<xsl:function name="ou:not-empty" as="xs:boolean">
		<xsl:param name="element"/>
		
		<xsl:copy-of select="not(ou:is-empty($element))"/>
	</xsl:function>
	
	<xsl:template name="snippet-message" expand-text="yes">
		<xsl:param name="defcon" as="xs:integer" required="true"/>
		<xsl:param name="title" as="xs:string" required="true"/>
		<xsl:param name="message" as="document-node()"/>
		
		<div class="alert">
			<xsl:copy-of select="$defcon-attributes[$defcon]/attribute()"/>
			<h3 class="alert-heading">{$title}</h3>
			<xsl:apply-templates select="$message"/>
		</div>
	</xsl:template>
	
</xsl:stylesheet>