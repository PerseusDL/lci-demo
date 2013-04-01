<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:cite="http://chs.harvard.edu/xmlns/cite"
    version="1.0">
    
    <xsl:output method="html" omit-xml-declaration="yes"/>
    
    <!-- parameter to filter displayed properties -->
    <xsl:param name="e_propfilter"/>
    
    <!-- parameter to request display only all versions should really be done on server -->
    <xsl:param name="e_showAllVersions" select="false()"></xsl:param>
    
    <!-- parameter to request the object urn be presented as a link -->
    <xsl:param name="e_linkUrn" select="false()"></xsl:param>
    
    
    <xsl:template match="/">
        <xsl:variable name="maxVersion">
            <xsl:call-template name="getMaxVersion">
                <xsl:with-param name="remainingVersions" select="//cite:citeObject/@urn"/>
            </xsl:call-template>
        </xsl:variable>
        <xsl:message>Max Version <xsl:value-of select="$maxVersion"/></xsl:message>
        <xsl:element name="table">
            <xsl:attribute name="class">lcicites</xsl:attribute>
            <xsl:for-each select="//cite:citeObject">
                <xsl:variable name="thisObject" select="substring-after(@urn,'.')"/>
                <xsl:variable name="thisVersion" select="substring-after(substring-after(@urn,'.'),'.')"/>
                
                <xsl:if test="$e_showAllVersions or $thisVersion=$maxVersion">
                    <xsl:message>This Version <xsl:value-of select="$thisVersion"/></xsl:message>
            <xsl:element name="tr">
                <xsl:element name="td">
                    <xsl:attribute name="class">lciurn</xsl:attribute>
                    <xsl:choose>
                        <xsl:when test="$e_linkUrn">
                            <xsl:element name="a">
                                <xsl:attribute name="href">berti_demo.html#<xsl:value-of select="//cite:citeObject/@urn"/></xsl:attribute>
                                <xsl:value-of select="//cite:citeObject/@urn"/>
                            </xsl:element>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:value-of select="//cite:citeObject/@urn"/>
                        </xsl:otherwise>
                    </xsl:choose>
                    
                </xsl:element>
            </xsl:element>
                <xsl:for-each select="cite:citeProperty">
                    <!-- TODO need to tokenize the list-->
                    <xsl:element name="tr">
                    <xsl:if test="not($e_propfilter) or contains($e_propfilter,current()/@name)">
                    <xsl:element name="td">
                        <xsl:choose>
                         <xsl:when test="@type= 'markdown'">
                             <span class="md"><xsl:value-of select="."/></span>
                         </xsl:when>
                         <xsl:otherwise>
                             <span class="citeprop_{@name}"><xsl:value-of select="."/></span>    
                         </xsl:otherwise>
                        </xsl:choose>
                    </xsl:element>
                </xsl:if>
                    </xsl:element>
                </xsl:for-each>
                </xsl:if>
            </xsl:for-each>
        </xsl:element>
        
    </xsl:template>
    
    
    <xsl:template name="getMaxVersion">
        <xsl:param name="remainingVersions"/>
        <xsl:param name="maxVersion" select="'0'"/>
        <xsl:choose>
            <xsl:when test="count($remainingVersions) = 0">
                <xsl:value-of select="$maxVersion"/>
            </xsl:when>    
            <xsl:otherwise>
                <xsl:variable name="thisVersion" select="substring-after(substring-after($remainingVersions[1],'.'),'.')"/>
                <xsl:message>Testing <xsl:copy-of select="$thisVersion"/></xsl:message>
                <xsl:variable name="newMax">
                    <xsl:choose>
                        <xsl:when test="$thisVersion and $thisVersion > $maxVersion">
                            <xsl:value-of select="$thisVersion"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:value-of select="$maxVersion"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:variable>        
                <xsl:call-template name="getMaxVersion">
                    <xsl:with-param name="remainingVersions" select="$remainingVersions[position() > 1]"/>
                    <xsl:with-param name="maxVersion" select="$newMax"/>
                </xsl:call-template>
            </xsl:otherwise>
        </xsl:choose>
        
    </xsl:template>


</xsl:stylesheet>