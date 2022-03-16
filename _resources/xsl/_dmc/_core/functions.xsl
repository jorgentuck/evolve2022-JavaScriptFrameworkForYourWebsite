<?xml version="1.0" encoding="utf-8"?>
<!DOCTYPE xsl:stylesheet [
<!ENTITY nbsp   "&#160;">
<!ENTITY lsaquo   "&#8249;">
<!ENTITY rsaquo   "&#8250;">
<!ENTITY laquo  "&#171;">
<!ENTITY raquo  "&#187;">
<!ENTITY copy   "&#169;">
]>
<xsl:stylesheet version="3.0"
				xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
				xmlns:xs="http://www.w3.org/2001/XMLSchema"
				xmlns:ou="http://omniupdate.com/XSL/Variables"
				xmlns:ouc="http://omniupdate.com/XSL/Variables"
				exclude-result-prefixes="xs ou ouc"
				expand-text="yes">
	
	<xsl:import href="variables.xsl"/> <!-- dmc variables -->
	<xsl:import href="snippets.xsl"/> <!-- dmc snippets -->
	
	<xsl:param name="root" select="concat($ou:root, $ou:site)" />
	<xsl:template name="dmc-item-data" />
	
	<!-- get a single item XML -->
	<!-- has option to add custom xsl attribute to exclude it from the xml output of the file -->
	<xsl:function name="ou:get-item">
		<xsl:param name="document" />
		<item>
			<xsl:attribute name="href" select="concat($dirname, replace($ou:filename, 'xml', $extension))" />
			<xsl:attribute name="dsn" select="ou:pcf-param('dsn')" />
			<xsl:for-each select="$document/item/ouc:div[not(@xml = 'exclude')]">
				<xsl:element name="{translate(./@label, ' ', '_')}"><xsl:apply-templates select="node()[not(self::ouc:multiedit)]" /></xsl:element>
			</xsl:for-each>
			<xsl:if test="$tags != ''">		
				<tags>		
					<xsl:for-each select="tokenize($tags, ',')">
						<xsl:sort select="." />
						<tag>{.}</tag>		
					</xsl:for-each>		
				</tags>		
			</xsl:if>
			<xsl:call-template name="dmc-item-data" />
		</item>
	</xsl:function>
	
	<!-- template for getting all internal items aggregated from staging or production depending on what parameters you pass in -->
	<xsl:function name="ou:get-internal-doc">
		<xsl:param name="path" />  <!-- aggregation starting path -->
		<xsl:variable name="current-path" select="concat($root, $path)" />  <!-- full aggregation path -->
		<xsl:variable name="language" select="$aggregation-language" /> <!-- Configured in variables.xsl - determines what server side language the aggregation will be using -->
		<xsl:variable name="dsn" select="if(ou:pcf-param('dsn') != '') then ou:pcf-param('dsn') else replace($ou:filename, '\..*$', '')" /> <!-- determine what dsn is to be used based on filename without extension -->
		<xsl:variable name="query-string" select="concat('?dir=', encode-for-uri(ou:pcf-param('aggregation-path')), '&#38;dsn=', $dsn)" /> <!-- determine the query string -->
		<xsl:variable name="request-location" select="concat($domain, $dmc-path)"/> <!-- determine the request location string -->
		
		<xsl:choose>
			<xsl:when test="$language = 'php'">
				<!-- path to php script -->
				<xsl:variable name="php-loc" select="concat($request-location, 'php/_core/aggregator.php', $query-string)" />
				<xsl:if test="not($is-pub)">
					<query-path><xsl:value-of select="$php-loc" /></query-path> <!-- output the query path for debugging -->
				</xsl:if>
				<xsl:copy-of select="document($php-loc)" />
			</xsl:when>
			<xsl:when test="$language = 'csharp'">
				<!-- path to c# script -->
				<xsl:variable name="c-loc" select="concat($request-location, 'cs/_core/aggregator.ashx', $query-string)" />
				<xsl:if test="not($is-pub)">
					<query-path><xsl:value-of select="$c-loc" /></query-path> <!-- output the query path for debugging -->
				</xsl:if>
				<xsl:copy-of select="document($c-loc)" />
			</xsl:when>
			<xsl:when test="$language = 'xsl'">
				<xsl:if test="not($is-pub)">
					<query-path>Aggregated via XSL. Starting path: {replace($current-path, '/$', '')}</query-path> <!-- output the query path for debugging -->
				</xsl:if>
				<items>
					<xsl:call-template name="items-with-xsl">
						<xsl:with-param name="current-path" select="replace($current-path, '/$', '')"/> <!-- current path -->
					</xsl:call-template>
				</items>
			</xsl:when>
			<xsl:otherwise>
				<p>Invalid server side language. Please verify/configure <xsl:value-of select="$language" /> is the language you want to use.</p>
			</xsl:otherwise>
		</xsl:choose>

	</xsl:function>
	
	
	<xsl:function name="ou:get-external-doc">
		<xsl:param name="external-xml-url" />
		
		<xsl:variable name="trimmed-url" select="ou:textual-content($external-xml-url)" />
		
		<xsl:choose>
			<xsl:when test="doc-available($trimmed-url)">
				<xsl:copy-of select="doc($trimmed-url)"/>
			</xsl:when>
			<xsl:otherwise>
				{error(QName('http://www.omniupdate.com', 'error'), concat('The external xml: "',$trimmed-url , '" is not accessible.'))}
			</xsl:otherwise>
		</xsl:choose>
	</xsl:function>
	
	
	<!-- BPT Way of Producing DMC XPATH -->
	
	<xsl:function name="ou:get-filter-predicate">
		<xsl:param name="filters" />
		<xsl:param name="filter-target" />
		
		<xsl:value-of select="ou:get-filter-predicate($filters, $filter-target, false(), true())" />
		
	</xsl:function>
	
	<xsl:function name="ou:get-filter-predicate">
		<xsl:param name="filters" />
		<xsl:param name="filter-target" />
		<xsl:param name="strict" as="xs:boolean" />
		
		<xsl:value-of select="ou:get-filter-predicate($filters, $filter-target, $strict, true())" />
		
	</xsl:function>
	
	
	<xsl:function name="ou:get-filter-predicate">
		<xsl:param name="filters" />
		<xsl:param name="filter-target" />
		<xsl:param name="strict" as="xs:boolean" />
		<xsl:param name="case-sensitive" as="xs:boolean" />
		
		
		<xsl:variable name="logical-operator" select="if($strict) then ' and ' else ' or '" />


		<xsl:variable name="case-insensitive-start">
			<xsl:if test="not($case-sensitive)">
				<xsl:text>[translate(text(),'ABCDEFGHIJKLMNOPQRSTUVWXYZ','abcdefghijklmnopqrstuvwxyz')</xsl:text>
			</xsl:if>
		</xsl:variable>

		<xsl:variable name="case-insensitive-end">
			<xsl:if test="not($case-sensitive)">
				<xsl:text>]</xsl:text>
			</xsl:if>
		</xsl:variable>

		<xsl:if test="$filters=>ou:textual-content()!=''">
			<xsl:text>[</xsl:text>
			<xsl:for-each select="tokenize($filters, ',')">
				<xsl:variable name="filter">
					<xsl:choose>
						<xsl:when test="$case-sensitive">
							<xsl:value-of select=".=>normalize-space()" />
						</xsl:when>
						<xsl:otherwise>
							<xsl:value-of select=".=>normalize-space()=>lower-case()" />
						</xsl:otherwise>
					</xsl:choose>
				</xsl:variable>

				<xsl:choose>
					<xsl:when test="contains($filter, '''')">
						<xsl:value-of select="$filter-target || $case-insensitive-start || '=&quot;' || $filter=>replace('&quot;', '') || '&quot;' || $case-insensitive-end" />
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="$filter-target || $case-insensitive-start || '=''' || $filter || '''' || $case-insensitive-end" />
					</xsl:otherwise>
				</xsl:choose>
				<xsl:if test="position() != last()">
					<xsl:value-of select="$logical-operator" />
				</xsl:if>
			</xsl:for-each>
			<xsl:text>]</xsl:text>
		</xsl:if>
	</xsl:function>

	<xsl:function name="ou:get-filter-predicate-multi">
		<xsl:param name="filters" />
		<xsl:param name="filter-target" />
		<xsl:param name="strict" as="xs:boolean" />
		<xsl:param name="case-sensitive" as="xs:boolean" />
		
		
		<xsl:variable name="logical-operator" select="if($strict) then ' and ' else ' or '" />
		
		
		<xsl:variable name="case-insensitive-start">
			<xsl:if test="not($case-sensitive)">
				<xsl:text>[translate(text(),'ABCDEFGHIJKLMNOPQRSTUVWXYZ','abcdefghijklmnopqrstuvwxyz')</xsl:text>
			</xsl:if>
		</xsl:variable>
		
		<xsl:variable name="case-insensitive-end">
			<xsl:if test="not($case-sensitive)">
				<xsl:text>]</xsl:text>
			</xsl:if>
		</xsl:variable>
		
		<xsl:if test="$filters=>ou:textual-content()!=''">
			<!--<xsl:text>[</xsl:text>-->
			<xsl:for-each select="tokenize($filters, ',')">
				<xsl:variable name="filter">
					<xsl:choose>
						<xsl:when test="$case-sensitive">
							<xsl:value-of select=".=>normalize-space()" />
						</xsl:when>
						<xsl:otherwise>
							<xsl:value-of select=".=>normalize-space()=>lower-case()" />
						</xsl:otherwise>
					</xsl:choose>
				</xsl:variable>
				
				<xsl:choose>
					<xsl:when test="contains($filter, '''')">
						<xsl:value-of select="$filter-target || $case-insensitive-start || '=&quot;' || $filter=>replace('&quot;', '') || '&quot;' || $case-insensitive-end" />
					</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="$filter-target || $case-insensitive-start || '=''' || $filter || '''' || $case-insensitive-end" />
					</xsl:otherwise>
				</xsl:choose>
				<xsl:if test="position() != last()">
					<xsl:value-of select="$logical-operator" />
				</xsl:if>
			</xsl:for-each>
			<!--<xsl:text>]</xsl:text>-->
		</xsl:if>
	</xsl:function>

	
	
	<!-- template to grab all the item xml files from production with XSL -->
	<xsl:template name="items-with-xsl">
		<xsl:param name="current-path" /> <!-- current path -->
		<!-- calculate the current path to the production server and replace the root with the domain -->
		<xsl:variable name="domain-dir" select="concat(replace($current-path, $root, $domain), '/')" />
		<xsl:variable name="dsn" select="replace($ou:filename, '\..*$', '')" /> <!-- determine what server side language the aggregation will be using -->
		<xsl:for-each select="doc($current-path)/list/file[contains(text(),'.pcf')]">
			<xsl:variable name="file-path" select="concat($domain-dir, replace(text(), 'pcf', 'xml'))" />
			<xsl:if test="doc-available($file-path)">
				<xsl:copy-of select="doc($file-path)/item[@dsn=$dsn]" />
			</xsl:if>
		</xsl:for-each> 
		<!-- get all directories -->
		<xsl:for-each select="doc($current-path)/list/directory">
			<xsl:call-template name="items-with-xsl">
				<xsl:with-param name="current-path" select="concat($current-path,'/',text())" />
			</xsl:call-template>
		</xsl:for-each>
	</xsl:template>
	
	<xsl:template name="dmc">
		<xsl:param name="options" />
		<xsl:param name="script-name" select="'generic'" />
		<xsl:param name="debug" select="false()" />
		
		<xsl:variable name="script-path">
			<xsl:choose>
				<xsl:when test="$server-type = 'php'">
					<xsl:value-of select="$dmc-path || 'php/' || $script-name || '.php'" />
				</xsl:when>
				<xsl:otherwise>
					<xsl:value-of select="$dmc-path || 'cs/' || $script-name || '.ashx'" />
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		
		<xsl:choose>
			<xsl:when test="$ou:action = 'pub'">
				<xsl:variable name="double-quote">"</xsl:variable>
				<xsl:variable name="escaped-double-quote">\\"</xsl:variable>
				
				<xsl:choose>
					<xsl:when test="$server-type = 'php'">

						<xsl:processing-instruction name="php">
							include_once($_SERVER['DOCUMENT_ROOT'] . "{$script-path}");

							$options = array();
							<xsl:for-each select="$options/node()">
								$options["{name()}"] = "<xsl:value-of select="replace(text(), $double-quote, $escaped-double-quote)" disable-output-escaping="yes" />";
							</xsl:for-each>

							get_{$script-name}_dmc_output($options);

							?</xsl:processing-instruction>
					</xsl:when>
					<xsl:otherwise>
						<xsl:text disable-output-escaping="yes" expand-text="no">&lt;% </xsl:text>
							
							<xsl:variable name="option-notation">
								<xsl:for-each select="$options/node()" expand-text="no">
									<option>{"<xsl:value-of select="name()" />","<xsl:value-of select="replace(text(), $double-quote, $escaped-double-quote)" />"}</option>
								</xsl:for-each>
							</xsl:variable>
						
							{$script-name}.GetDMCOutput(new NameValueCollection()<xsl:value-of select="'{' || string-join($option-notation/option, ',') || '}'" disable-output-escaping="yes" />);
						<xsl:text disable-output-escaping="yes" expand-text="no">%&gt;</xsl:text>
					</xsl:otherwise>
				</xsl:choose>
				
			</xsl:when>
			<xsl:otherwise>

				<xsl:variable name="querystring">
					<xsl:for-each select="$options/node()">
						<xsl:value-of select="name() || '=' || encode-for-uri(text())" />
						<xsl:if test="position()!=last()">&amp;</xsl:if>
					</xsl:for-each>
				</xsl:variable>
				
				<xsl:variable name="script-url" select="$domain || $script-path || '?' || $querystring" />
				
				<xsl:if test="$debug">
					<xsl:variable name="available-options" select="tokenize('datasource,distinct,items_per_page,max,metadata,page,returntype,search_case_sensitive,search_columns,search_phrase,select,sort,type,xpath', ',')" />
					
					<br />
					<div class="panel">
						<xsl:element name="style" expand-text="no">
							.dmc-debug { display: none; }
						</xsl:element>
						<xsl:element name="script" expand-text="no">
							var dmc = {
								toggleDebug: function(){
									var displayLabel = event.currentTarget.children[0];
									var debugInfo = event.currentTarget.parentElement.parentElement.nextElementSibling;
									var debugVisible = debugInfo.style.display == 'block';
									
									if(debugVisible){
										debugInfo.style.display = 'none';
										displayLabel.innerHTML = 'Show Details';
									}else{
										debugInfo.style.display = 'block';
										displayLabel.innerHTML = 'Hide Details';
									}
									event.preventDefault();
								}
							};
						</xsl:element>

						<h5><strong><a href="#" onclick="dmc.toggleDebug();">Debug Info (<span>Show Details</span>)</a></strong></h5>
						<div class="dmc-debug">
							<p style="word-break: break-all;"><strong>DMC API Endpoint:</strong> <br/> <a href="{$script-url}" target="_blank"><xsl:value-of select="$script-url" /></a></p>
							<p style="word-break: break-all;">
								<strong>Options Used:</strong><br/>
								<xsl:for-each select="$options/node()">
									<xsl:sort select="name()" />
									{name()} = "{text()}"<br/>
								</xsl:for-each>
							</p>
							<p style="word-break: break-all;">
								<strong>Additional Options:</strong><br/>
								<xsl:for-each select="$available-options[not(.=$options/node()/name())]">
									{.} = ""<br/>
								</xsl:for-each>
							</p>
						</div>
					</div>
				</xsl:if>
				<xsl:if test="unparsed-text-available($script-url)">
					<xsl:value-of select="unparsed-text($script-url)" disable-output-escaping="yes" />
				</xsl:if>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>

</xsl:stylesheet>
