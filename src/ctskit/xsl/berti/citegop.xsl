<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    version="1.0" xmlns:cite="http://chs.harvard.edu/xmlns/cite">
    <xsl:import href="../header.xsl"/>
    <xsl:output encoding="UTF-8" indent="no" method="html"/>
    
    <!-- Placeholder stylesheet mirroring source xml until 
    real stylesheet is written.
    -->
    
    <xsl:variable name="ImageServiceGIP">http://amphoreus.hpcc.uh.edu/tomcat/chsimg/Img?request=GetImagePlus&amp;xslt=gip.xsl&amp;urn=</xsl:variable>
    <xsl:variable name="ImageServiceThumb">http://amphoreus.hpcc.uh.edu/tomcat/chsimg/Img?request=GetBinaryImage&amp;w=200&amp;urn=</xsl:variable>
    
    <!-- parameter to filter displayed properties -->
    <xsl:param name="e_propfilter"/>
    
    <!-- parameter to request hiding property labels -->
    <xsl:param name="e_hideLabels" select="false()"/>
    
    <!-- parameter to request display only all versions should really be done on server -->
    <xsl:param name="e_showAllVersions" select="false()"></xsl:param>
    
    <xsl:template match="/">
        <html>
            <head>
                <meta charset="utf-8"></meta>
                <link rel="stylesheet" href="html-ctskit/ctskit/css/citeCollection.css"></link>
                <link rel="stylesheet" href="html-ctskit/ctskit/css/normalize.css"></link>
                <link rel="stylesheet" href="html-ctskit/ctskit/css/simple.css"></link>
                <link rel="stylesheet" href="html-ctskit/ctskit/css/tei.css"></link>
<!--                
                <link rel="stylesheet" href="css/normalize.css"></link>
                <link rel="stylesheet" href="css/simple.css"></link>
                <link rel="stylesheet" href="css/tei.css"></link>
-->                
                <link rel="stylesheet" href="css/citeCollection.css"></link>
                
                <!-- Everyone uses JQuery -->
                <script src="html-ctskit/ctskit/js/jquery-1.7.2.min.js" type="text/javascript" ></script>
              
                <!-- Sarissa Javascript (for doing xslt stuff) -->	
                <script src="html-ctskit/ctskit/js/sarissa/sarissa-compressed.js" type="text/javascript"></script>
                <script src="html-ctskit/ctskit/js/sarissa/sarissa_ieemu_xpath-compressed.js" type="text/javascript"></script>
                
                <!-- Markdown -->
                <script src="html-ctskit/ctskit/js/markdown.js" type="text/javascript"></script>
                
                <!-- CHS Javascript -->
                <script src="html-ctskit/ctskit/js/cite-cts-kit.js" type="text/javascript" ></script>
                <!-- User-defined variables -->
                <script type="text/javascript">
                   
    	           var textElementClass = "cts-text";
    	           var pathToXSLT = "html-ctskit/ctskit/xsl/chs-gp.xsl";
    	           var urlOfCTS = "http://furman-folio.appspot.com/CTS?request=GetPassagePlus&amp;urn=";
    
                	var imgElementClass = "cite-img";
                  	var imgSize = 2000;
                	var urlOfImgService = "http://amphoreus.hpcc.uh.edu/tomcat/chsimg/Img?urn=";
    	           var pathToImgXSLT = "html-ctskit/ctskit/xsl/gip.xsl";

            		var urlOfCite = "http://folio.furman.edu/cfc/api?req=GetObjectPlus&amp;urn=";
    	           var collectionElementClass = "cite-collection";
    	           var pathToCiteXSLT = "html-ctskit/ctskit/xsl/citeCollection.xsl";
       

    </script>
                
                <title>CITE Collection Service · Get Object Plus</title>
            </head>
            <body>
                <header>
                    <xsl:call-template name="header"/>
                </header>
                <article class="article">
                    <xsl:apply-templates/>
                </article>
                
                <footer>
                    <xsl:call-template name="footer"/>
                </footer>
                
            </body>
            
        </html>
    </xsl:template>
    
    <xsl:template match="cite:request">
        <h2>Requested Collection</h2>
        <p><xsl:apply-templates select="./cite:urn"/></p>
    </xsl:template>
    
    <xsl:template match="cite:reply">
        <table>
            <xsl:if test="not($e_hideLabels)">
            <thead>
                <th>Label</th>
                <th>Value</th>
            </thead>
            </xsl:if>
            <xsl:variable name="maxVersion">
                <xsl:call-template name="getMaxVersion">
                    <xsl:with-param name="remainingVersions" select="citeObject/@urn"/>
                </xsl:call-template>
            </xsl:variable>
            <xsl:for-each select="//cite:citeProperty">
                <!-- TODO should really support a list of properties to show -->
                <xsl:if test="not($e_propfilter) or $e_propfilter = current()/@label">
                 <tr>
                     <xsl:if test="not($e_hideLabels)">
                         <td><xsl:value-of select="current()/@label"/></td>
                     </xsl:if>
                         <td><xsl:call-template name="handleProperty"/></td>
                 </tr>
                </xsl:if>
            </xsl:for-each>
        </table>
    </xsl:template>

    <xsl:template name="handleProperty">
        <xsl:choose>
            
            <xsl:when test="@type= 'citeurn'">
                <xsl:element name="a">
                    <xsl:attribute name="href">api?req=GetObject&amp;urn=<xsl:value-of select="."/></xsl:attribute>
                    <xsl:apply-templates/>
                </xsl:element>
            </xsl:when>
            <xsl:when test="@type= 'citeimg'">
                <xsl:if test="string-length(.) &gt; 6">
                <xsl:element name="a">
                    <xsl:attribute name="href"><xsl:value-of select="$ImageServiceGIP"/><xsl:value-of select="."/></xsl:attribute>
                <xsl:element name="img">
                    <xsl:attribute name="src"><xsl:value-of select="$ImageServiceThumb"/><xsl:value-of select="."/></xsl:attribute>
                </xsl:element>
                </xsl:element>
                </xsl:if>
            </xsl:when>
            <xsl:when test="@type= 'markdown'">
                <span class="md"><xsl:value-of select="."/></span>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="."/>
            </xsl:otherwise>  
            
        </xsl:choose>
        
        
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