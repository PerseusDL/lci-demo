<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    version="1.0"
    xmlns:cts="http://chs.harvard.edu/xmlns/cts3"
    xmlns:cts-x="http://alpheios.net/namespaces/cts-x"
    xmlns:tei="http://www.tei-c.org/ns/1.0" 
    xmlns:exsl="http://exslt.org/common"
    exclude-result-prefixes="tei cts-x cts exsl">
    
    <xsl:output method="html" encoding="UTF-8"/>
    
    <xsl:variable name="nontext">
        <table>
        <nontext xml:lang="grc">
            <char><xsl:text> </xsl:text></char>
            <char>“</char>
            <char>”</char>
            <char>—</char>
            <char>&quot;</char>
            <char>‘</char>
            <char>’</char>
            <char>,</char>
            <char>.</char>
            <char>:</char>
            <char>;</char>
            <char>&#x0387;</char>
            <char>&#x00B7;</char>
            <char>?</char>
            <char>!</char>
            <char>[</char>
            <char>]</char>
            <char>{</char>
            <char>}</char>
            <char>-</char>
        </nontext>
            <nontext xml:lang="greek">
                <char><xsl:text> </xsl:text></char>
                <char>“</char>
                <char>”</char>
                <char>—</char>
                <char>&quot;</char>
                <char>‘</char>
                <char>’</char>
                <char>,</char>
                <char>.</char>
                <char>:</char>
                <char>;</char>
                <char>&#x0387;</char>
                <char>&#x00B7;</char>
                <char>?</char>
                <char>!</char>
                <char>[</char>
                <char>]</char>
                <char>{</char>
                <char>}</char>
                <char>-</char>
            </nontext>
            <nontext xml:lang="*">
                <char><xsl:text> </xsl:text></char>
                <char>“</char>
                <char>”</char>
                <char>—</char>
                <char>&quot;</char>
                <char>‘</char>
                <char>’</char>
                <char>,</char>
                <char>.</char>
                <char>:</char>
                <char>;</char>
                <char>&#x0387;</char>
                <char>&#x00B7;</char>
                <char>?</char>
                <char>!</char>
                <char>[</char>
                <char>]</char>
                <char>{</char>
                <char>}</char>
                <char>-</char>
            </nontext>
        </table>
    </xsl:variable>
    <xsl:variable name="nontextTable" select="exsl:node-set($nontext)/table/nontext"/>
    <xsl:template match="/">
        <xsl:variable name="text">
            <xsl:apply-templates select="//tei:text//text()[not(ancestor::tei:note) and not(ancestor::tei:bibl)]"/>
        </xsl:variable>
        <xsl:variable name="lang" select="//tei:text/@xml:lang"/>
        <xsl:variable name="match-nontext">
            <xsl:choose>
                <xsl:when test="$lang and $nontextTable[@xml:lang=$lang]">
                    <xsl:copy-of select="exsl:node-set($nontextTable[@xml:lang=$lang])/char"/>
                </xsl:when>
                <xsl:otherwise><xsl:copy-of select="exsl:node-set($nontextTable[@xml:lang='*'])/char"/></xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="tokenized">
            <xsl:call-template name="tokenize-text">
                <xsl:with-param name="remainder" select="normalize-space($text)"/>
                <xsl:with-param name="match-nontext" select="$match-nontext"/>
            </xsl:call-template>
        </xsl:variable>
        <div lang="{$lang}" class="{$lang} alpheios-enabled-text">
            <xsl:for-each select="exsl:node-set($tokenized)/token">
                <xsl:variable name="toktext" select="current()/text()"/>
                <xsl:variable name="count" select="count(preceding-sibling::token[@type = 'text' and text() = $toktext]) + 1"/>
                <span class="token {@type}" data-ref="{concat($toktext,$count)}"><xsl:value-of select="."/></span>
            </xsl:for-each>
        </div>
    </xsl:template>
	
	<xsl:template match="text()">
		<xsl:copy/>
	</xsl:template>
    
    <xsl:template name="tokenize-text">
        <xsl:param name="tokenized"/>
        <xsl:param name="remainder"/>
        <xsl:param name="pending"/>
        <xsl:param name="match-nontext"/>
        <xsl:variable name="tokens">
           <tokens>
           <xsl:choose>
           <!-- when we have pending characters and something else to process -->
           <xsl:when test="$pending and $remainder">
               <xsl:variable name="next_char" select="substring($remainder,1,1)"/>
               
               <xsl:message>Pending <xsl:copy-of select="$pending"/></xsl:message>
               <xsl:message>Remainder <xsl:copy-of select="$remainder"/></xsl:message>
               <xsl:message>Next char<xsl:copy-of select="$next_char"/></xsl:message>
               
               <xsl:choose>
                    <!-- when we have pending chars and the the next char is non-text, then make a text token with the
                          pending chars and a punc token with the non-text char, and continue to process the rest -->
                   <xsl:when test="exsl:node-set($match-nontext)/char[text() = $next_char]">
                         <token type="text"><xsl:value-of select="$pending"/></token>
                         <token type="punc"><xsl:value-of select="$next_char"/></token>)
                       <rest><xsl:value-of select="substring($remainder,2)"/></rest>
                    </xsl:when>
                    <xsl:otherwise>
                        <!-- when we have pending chars and the next char is text, add the next char to the pending chars 
                             and continue to process the rest-->
                        <pending><xsl:value-of select="concat($pending,$next_char)"/></pending>
                        <rest><xsl:value-of select="substring($remainder,2)"/></rest>
                    </xsl:otherwise>
               </xsl:choose>
           </xsl:when>
           <!-- when we have pending characters and nothing else to process -->
           <xsl:when test="$pending">
               <!-- make a text token from the pending chars -->
               <token type="text"><xsl:value-of select="$pending"/></token>
           </xsl:when>
           <!-- when we don't have pending characters but do have more to process -->
           <xsl:when test="$remainder">
               <xsl:variable name="next_char" select="substring($remainder,1,1)"/>
               <xsl:choose>
                   <!-- when the next char is non text, make a punc token and continue to process the rest -->
                   <xsl:when test="exsl:node-set($match-nontext)/char[text() = $next_char]">
                       <token type="punc"><xsl:value-of select="$next_char"/></token>)
                       <rest><xsl:value-of select="substring($remainder,2)"/></rest>
                   </xsl:when>
                   <!-- when the next char is text, create a new pending string and continue to process the rest -->
                   <xsl:otherwise>
                       <pending><xsl:value-of select="$next_char"/></pending>
                       <rest><xsl:value-of select="substring($remainder,2)"/></rest>
                   </xsl:otherwise>
               </xsl:choose>
           </xsl:when>    
           <!-- no pending and no remainder, nothing else to do -->
           <xsl:otherwise/>
           </xsl:choose>
           </tokens>
        </xsl:variable>
        <xsl:variable name="newtokens" select="exsl:node-set($tokens)/tokens"/>
        <xsl:variable name="newtokenized">
            <tokens>
                <xsl:if test="$tokenized"><xsl:copy-of select="$tokenized//token"/></xsl:if>
                <xsl:if test="$newtokens"><xsl:copy-of select="$newtokens//token"/></xsl:if>
            </tokens>
        </xsl:variable>
        <xsl:choose>
            <!-- if we have any new token data, recurse to the next step -->
            <xsl:when test="$newtokens/*">
                <xsl:call-template name="tokenize-text">
                    <xsl:with-param name="match-nontext" select="$match-nontext"/>
                    <xsl:with-param name="pending" select="$newtokens/pending/text()"/>
                    <xsl:with-param name="remainder" select="$newtokens/rest/text()"/>
                    <xsl:with-param name="tokenized" select="exsl:node-set($newtokenized)/tokens"/>
                </xsl:call-template>
            </xsl:when>
            <!-- otherwise, just return the results -->
            <xsl:otherwise>
                <xsl:copy-of select="exsl:node-set($newtokenized)//token"/>
            </xsl:otherwise>
        </xsl:choose> 
    </xsl:template>
	    
    <xsl:template match="*"/>
</xsl:stylesheet>