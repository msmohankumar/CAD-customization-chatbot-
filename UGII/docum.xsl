<?xml version="1.0" encoding="UTF-8"?>
<!--       

-->
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:lc="http://www-cyp.ugsolutions.com/assemblies/pman">

	<xsl:template match="/">
		<html>
			<!-- This header needed for the RoboHelp TDOC transformation -->
			<head>
				<title>
				<xsl:value-of select="lc:PrefDefinition/lc:Application/@name"/> Customer Defaults</title>
				<xsl:comment> $MVD$:app("RoboHELP HTML Edition by Blue Sky Software, portions by MicroVision Dev. Inc.","769") </xsl:comment>
				<xsl:comment> $MVD$:template("","0","0") </xsl:comment>
				<xsl:comment> $MVD$:color("18","80ff","orange","0") </xsl:comment>
				<xsl:comment> $MVD$:fontset("Arial","Arial") </xsl:comment>
				<xsl:comment> $MVD$:fontset("Swiss 721 SWA","Swiss 721 SWA") </xsl:comment>
				<xsl:comment> $MVD$:fontset("Times New Roman","Times New Roman") </xsl:comment>
				<xsl:comment> $MVD$:fontset("Courier New","Courier New") </xsl:comment>
				<META NAME="generator" CONTENT="RoboHELP by Blue Sky Software www.blue-sky.com HTML Edition"/>
				<Link rel="StyleSheet" HREF="..\Style1.css"/>
			</head>
			<!-- Print the title using the name attribute of the PrefDefinitions->Application element -->
			<body>
				<title>
					<xsl:value-of select="lc:PrefDefinition/lc:Application/@name"/> Customer Defaults</title>
				<xsl:apply-templates select="lc:PrefDefinition"/>
				<hr size="4" color="#000080"/>
			</body>
		</html>
	</xsl:template>

	<!-- Groups -->
	<xsl:template match="lc:Group">
		<h3><xsl:value-of select="@name"/></h3>
		<xsl:apply-templates select="lc:Pref"/>
	</xsl:template>

	<!-- SubCategory -->
	<xsl:template match="lc:SubCategory">
		<h1><xsl:value-of select="@name"/></h1>
		<xsl:apply-templates select="lc:Tab"/>
	</xsl:template>

	<!-- Category Processing: Print the name -->
	<xsl:template match="lc:Category">
		<xsl:if test="@csh">
			<a name="{@csh}"/>
		</xsl:if>
		<p>
			<h1>
				<xsl:value-of select="@name"/>
			</h1>
		</p>
		<xsl:apply-templates select="lc:Tab"/>
		<xsl:apply-templates select=".//lc:SubCategory"/>
	</xsl:template>

    <!--  Tab processing: print each tab name -->
    <xsl:template match="lc:Tab">
		<xsl:if test="@csh">
			<a name="{@csh}"/>
		</xsl:if>
		<p>
			<h2>
				<xsl:value-of select="@name"/>
			</h2>
			<xsl:apply-templates/>
		</p>
	</xsl:template>
    
	<!-- Processing for Formatted element -->
	<xsl:template match="lc:Formatted">
	<pre><xsl:value-of select="."/></pre>
	</xsl:template>

	<!-- Docum processing -->
    <xsl:template match="lc:Docum">
		<p>
			<xsl:apply-templates />
		</p>
	</xsl:template>
    
	<!-- Docum processing: These appear as notes associated with the Default -->
	<xsl:template match="lc:Pref/lc:Docum">
		<p><font size="2">
			<xsl:text>Note: </xsl:text>
			<xsl:apply-templates />
		</font></p>
	</xsl:template>

	<xsl:template match="lc:Description">
		<p>
			<xsl:apply-templates />
		</p>
	</xsl:template>
    
	<!--Process Label -->
	<xsl:template match="lc:Label">
	<p>
		<h5><xsl:value-of select="@label"/></h5>
	</p>
	</xsl:template>
    
	<!-- Pref element processing: Extract default information and print to the html -->
	<xsl:template match="lc:Pref">
		<!-- title -->
		<p>
			<xsl:apply-templates select="lc:UIData/lc:Label"/>
			<h4>
				<xsl:value-of select="@title"/>
			</h4>
			<p>
				<!-- Description and default names -->
				<xsl:apply-templates  select="lc:Description"/>
			</p>
			<!-- Dump the name of the default -->
			<p>
				<xsl:text>Default Name: </xsl:text>
				<xsl:value-of select="@name"/>
			</p>
			<!-- Applies to -->
            <xsl:choose>
				<xsl:when test="contains(@name,'_EU')">
					<xsl:text>Applies to inch parts.</xsl:text>
                </xsl:when>
				<xsl:when test="contains(@name,'_MU')">
					<xsl:text>Applies to millimeter parts.</xsl:text>
                </xsl:when>
				<xsl:when test="contains(@name,'_SIU')">
					<xsl:text>Applies to meter parts.</xsl:text>
                </xsl:when>
				<xsl:when test="contains(@name,'_MCU')">
					<xsl:text>Applies to micrometer parts.</xsl:text>
				</xsl:when>
				<xsl:when test="contains(@name,'_UNX')">
					<xsl:text>Applies to: Unix</xsl:text>
				</xsl:when>
				<xsl:when test="contains(@name,'_WIN')">
					<xsl:text>Applies to: Windows</xsl:text>
				</xsl:when>
			</xsl:choose>
			<!-- Units -->
			<xsl:if test="@unit">
			<p>Unit: <xsl:value-of select="@unit"/>
			</p>
			</xsl:if>

			<!-- Pref element processing: Extract enumeation information -->
			<xsl:if test="./lc:Data[@type='enum']">
				<p>
					<xsl:text>Valid Options: [</xsl:text>
					<xsl:for-each select=".//lc:EnumElem">
						<xsl:value-of select="@name"/>
						<xsl:if test="following-sibling::*">, </xsl:if>
					</xsl:for-each>
					<xsl:text>]</xsl:text>
				</p>
			</xsl:if>
			<!-- Pref element processing: Extract color information -->
			<xsl:if test="./lc:Data[@type='color']">
				<p>
					<xsl:text>Valid Options: [</xsl:text>
					<xsl:for-each select=".//lc:EnumElem">
						<xsl:value-of select="@name"/>
						<xsl:if test="following-sibling::*">, </xsl:if>
					</xsl:for-each>
					<xsl:text>]</xsl:text>
				</p>
			</xsl:if>
            
			<xsl:apply-templates select="lc:Docum"/>
			<xsl:apply-templates select=".//lc:Data[@type='range']"/>
		</p>
	</xsl:template>
  
	<!-- Pref element processing: Extract range information -->
	<xsl:template match="lc:Data[@type='range']">
		<p>
			<xsl:text>Valid Range: [</xsl:text>
			<xsl:apply-templates select="lc:LowerBound"/>
			<xsl:apply-templates select="lc:UpperBound"/>
			<xsl:text>]</xsl:text>
		</p>
	</xsl:template>
	<xsl:template match="lc:LowerBound">
		<xsl:choose>
			<xsl:when test="@include='1'">&gt;=
				<xsl:value-of select="@value"/>
			</xsl:when>
			<xsl:when test="@include='0'">&gt;
				<xsl:value-of select="@value"/>
			</xsl:when>
			<xsl:otherwise/>
		</xsl:choose>
	</xsl:template>
	<xsl:template match="lc:UpperBound">
        <xsl:if test="../lc:LowerBound">, </xsl:if>
        <xsl:choose>
			<xsl:when test="@include='1'"> &lt;=
				<xsl:value-of select="@value"/>
			</xsl:when>
			<xsl:when test="@include='0'"> &lt;
				<xsl:value-of select="@value"/>
			</xsl:when>
			<xsl:otherwise/>
		</xsl:choose>
	</xsl:template>
    
</xsl:stylesheet>
