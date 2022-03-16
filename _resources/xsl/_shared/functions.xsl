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
Implementation Skeleton - 08/24/2018

Functions XSL
Customer Functions particular to the school
-->

<xsl:stylesheet version="3.0" 
				xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
				xmlns:xs="http://www.w3.org/2001/XMLSchema"
				xmlns:ou="http://omniupdate.com/XSL/Variables"
				xmlns:fn="http://omniupdate.com/XSL/Functions"
				xmlns:ouc="http://omniupdate.com/XSL/Variables"
				exclude-result-prefixes="ou xsl xs fn ouc">

	<!-- insert custom functions for the implementation -->
	<xsl:function name="ou:get-iso-date-time">
		<xsl:param name="the-date"/>
		<!-- calculate date -->
		<xsl:variable name="date" select="substring-before($the-date, ' ')"/>
		<xsl:variable name="M" select="substring-before($date, '/')"/>
		<xsl:variable name="D-Y" select="substring-after($date, '/')"/>
		<xsl:variable name="D" select="substring-before($D-Y, '/')"/>
		<xsl:variable name="Y" select="substring-after($D-Y, '/')"/>
		<!-- calculate time -->
		<xsl:variable name="time-ampm" select="substring-after($the-date, ' ')"/>
		<xsl:variable name="time" select="substring-before($time-ampm, ' ')"/>
		<xsl:variable name="ampm" select="substring-after($time-ampm, ' ')"/>
		<xsl:variable name="h" select="substring-before($time, ':')"/>
		<xsl:variable name="m-s" select="substring-after($time, ':')"/>
		<xsl:variable name="m" select="substring-before($m-s, ':')"/>
		<xsl:variable name="s" select="substring-after($m-s, ':')"/>
		
		<xsl:variable name="hh">
			<xsl:choose>
				<!-- Midnight -->
				<xsl:when test="$ampm = 'AM' and $h='12'">
					<xsl:value-of select="format-number(0, '00')"/>
				</xsl:when>
				<!-- Morning to Noon -->
				<xsl:when test="$ampm = 'AM' or $h='12'">
					<xsl:value-of select="format-number(number($h), '00')"/>
				</xsl:when>
				<!-- Afternoon -->
				<xsl:otherwise>
					<xsl:value-of select="format-number(number($h)+12, '00')"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		
		<xsl:value-of select="concat($Y, '-', $M, '-', $D, 'T', $hh, ':', $m, ':', $s)"/> 
	</xsl:function>
	
	<xsl:function name="ou:to-dateTime" as="xs:dateTime">
		<xsl:param name="pcf-date"/>
		<!--define time zone-->
		<xsl:variable name="time-zone" select="'-08:00'"/>
		<!--tokenize date from PCF, which uses datetime param-->
		<xsl:variable name="token-date" select="tokenize($pcf-date, ' ')"/>
		<!--calculate date depending on TCF or PCF dateTime-->
		<xsl:variable name="date">
			<xsl:choose>
				<xsl:when test="matches($pcf-date,'^\S+, \S+ \d{1,2}, \d{4} \d{1,2}:\d{2}:\d{2} [AP]M [A-Z]{3}$')">
					<!--TCF format 'Monday, January 26, 2015 2:13:39 PM PST' to '2015-01-26'-->
					<xsl:value-of select="concat($token-date[4], '-', ou:month-num($token-date[2], 'long'), '-', ou:double-digit(substring-before($token-date[3], ',')))"/>
				</xsl:when>
				<xsl:otherwise>
					<!--PCF format '01/26/2015 08:26:39 PM' to '2015-01-26'-->
					<xsl:value-of select="concat(tokenize($token-date[1], '/')[3], '-', ou:double-digit(tokenize($token-date[1], '/')[1]), '-', ou:double-digit(tokenize($token-date[1], '/')[2]))"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<xsl:variable name="time">
			<xsl:choose>
				<xsl:when test="matches($pcf-date,'^\S+, \S+ \d{1,2}, \d{4} \d{1,2}:\d{2}:\d{2} [AP]M [A-Z]{3}$')">
					<!--convert 'Monday, January 26, 2015 2:13:39 PM PST' to '2015-01-26'-->
					<xsl:value-of select="concat(ou:double-digit(if ($token-date[6] = 'PM' and number(tokenize($token-date[5], ':')[1]) &lt; 12) then number(tokenize($token-date[5], ':')[1]) + 12 else if ($token-date[6] = 'PM' and number(tokenize($token-date[5], ':')[1]) = 12) then '00' else tokenize($token-date[5], ':')[1]), ':', ou:double-digit(tokenize($token-date[5], ':')[2]), ':', ou:double-digit(tokenize($token-date[5], ':')[3]))"/>
				</xsl:when>
				<xsl:otherwise>
					<!--convert '01/26/2015 08:26:39 PM' to '20:26:39'-->
					<xsl:value-of select="concat(ou:double-digit(if ($token-date[3] = 'PM' and number(tokenize($token-date[2], ':')[1]) &lt; 12) then number(tokenize($token-date[2], ':')[1]) + 12 else if ($token-date[3] = 'PM' and number(tokenize($token-date[2], ':')[1]) = 12) then '00' else tokenize($token-date[2], ':')[1]), ':', ou:double-digit(tokenize($token-date[2], ':')[2]), ':', ou:double-digit(tokenize($token-date[2], ':')[3]))"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		<!--new object xs:dateTime('2015-01-01T20:26:39-08:00')-->
		<xsl:value-of select="dateTime(xs:date($date), xs:time(concat($time, $time-zone)))" />
	</xsl:function>
	
	<xsl:function name="ou:double-digit">
		<xsl:param name="num"/>
		<xsl:value-of select="format-number(number($num), '00')"/>
	</xsl:function>
	
	<xsl:function name="ou:month-abbrev-en" as="xs:string?">
		<xsl:param name="date" as="xs:anyAtomicType?"/>
		<xsl:sequence select="('Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec')[month-from-date(xs:date($date))]"/>
	</xsl:function>
	
	<xsl:function name="ou:day-of-week" as="xs:integer?">
		<xsl:param name="date" as="xs:anyAtomicType?"/>
		<xsl:sequence select="if (empty($date)) then () else xs:integer((xs:date($date) - xs:date('1901-01-06')) div xs:dayTimeDuration('P1D')) mod 7"/>
	</xsl:function>
	
	<xsl:function name="ou:day-of-week-abbrev-en" as="xs:string?">
		<xsl:param name="date" as="xs:anyAtomicType?"/>
		<xsl:sequence select="('Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat')[ou:day-of-week($date) + 1]"/>
	</xsl:function>
	
	<xsl:function name="ou:month-name">
		<xsl:param name="month-num" />
		<xsl:value-of select="ou:month-name($month-num,'long')" />	
	</xsl:function>
	
	<xsl:function name="ou:month-name">
		<xsl:param name="month-num" />
		<xsl:param name="length" />
		<xsl:variable name="months" select="('January','February','March','April','May','June','July','August','September','October','November','December')" />
		<xsl:variable name="months-short" select="('Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec')" />
		<xsl:value-of select="if($length = 'short') then $months-short[number($month-num)] else $months[number($month-num)]" />
	</xsl:function>
	
	<xsl:function name="ou:month-num">
		<xsl:param name="month-name" />
		<xsl:value-of select="ou:month-num($month-name,'long')" />	
	</xsl:function>
	
	<xsl:function name="ou:month-num">
		<xsl:param name="month-name" />
		<xsl:param name="length" />
		<xsl:variable name="months" select="('January','February','March','April','May','June','July','August','September','October','November','December')" />
		<xsl:variable name="months-short" select="('Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec')" />
		<xsl:value-of select="ou:double-digit(if ($length = 'short') then index-of($months-short,$month-name) else index-of($months,$month-name))" />
	</xsl:function>
	
	<xsl:function name="ou:display-long-date">
		<xsl:param name="str" />
		<xsl:variable name="dateTime" select="ou:to-dateTime($str)"/>
		<xsl:variable name="day" select="format-dateTime($dateTime, '[D1]')"/>
		<xsl:variable name="month" select="format-dateTime($dateTime, '[M1]')"/>
		<xsl:variable name="year" select="format-dateTime($dateTime, '[Y0001]')"/>
		<xsl:try>
			<xsl:value-of select="concat(ou:month-name($month),' ',$day,', ',$year)" />
			<xsl:catch />
		</xsl:try>
	</xsl:function>
	
		
</xsl:stylesheet>