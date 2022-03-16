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
LDP Forms Configuration File Customer Specific - 12/27/18
-->

<xsl:stylesheet version="3.0" 
				xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
				xmlns:xs="http://www.w3.org/2001/XMLSchema"
				xmlns:ou="http://omniupdate.com/XSL/Variables"
				xmlns:fn="http://omniupdate.com/XSL/Functions"
				xmlns:ouc="http://omniupdate.com/XSL/Variables"
				exclude-result-prefixes="ou xsl xs fn ouc">

	<xsl:import href="/var/staging/OMNI-INF/stylesheets/ldp-forms/v2/ldp-config.xsl"/> <!-- global xsl of the configuration file -->
	
	<!-- the surrounding class for the errors -->
	<xsl:variable name="form-error-class">has-error</xsl:variable>
	<!-- the class for the error message appended to each element with an error -->
	<xsl:variable name="form-error-element-class">label label-danger</xsl:variable>
	<!-- the type of element that will be appended to each element with an error -->
	<xsl:variable name="form-error-element">span</xsl:variable>
	
	<!-- the css class for the successful form submission -->
	<xsl:variable name="form-message-success-class">alert alert-success</xsl:variable>
	<!-- the css class for the unsuccessful form submission -->
	<xsl:variable name="form-message-error-class">alert alert-danger</xsl:variable>

</xsl:stylesheet>