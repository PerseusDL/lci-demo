<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:cite="http://chs.harvard.edu/xmlns/img" exclude-result-prefixes="cite" version="1.0">

<!--    <xsl:output method="html" omit-xml-declaration="yes"/>
-->    
    
    <xsl:template match="/">
        <div class="citeimagediv">
        <xsl:element name="a">
            <xsl:attribute name="href"><xsl:value-of select="//cite:zoomableUrl"/></xsl:attribute>
        <xsl:element name="img">
            <xsl:attribute name="class">cite-image</xsl:attribute>
            <xsl:attribute name="src"><xsl:value-of select="//cite:binaryUrl"/>&amp;w=500</xsl:attribute>
            <xsl:attribute name="alt"><xsl:value-of select="//cite:urn"/></xsl:attribute>
        </xsl:element>
        </xsl:element>
            <div class="citeimagecaption">
            <p><xsl:apply-templates select="//cite:urn"/></p>
            <p><xsl:value-of select="//cite:caption"/></p>
            <p><xsl:value-of select="//cite:rights"/></p>
            </div>
        </div>
        
    </xsl:template>

</xsl:stylesheet>
