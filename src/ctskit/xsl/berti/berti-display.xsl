<?xml version="1.0" encoding="UTF-8"?>
<!-- $Id: start-edition.xsl 1510 2008-08-14 15:27:51Z zau $ -->
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:tei="http://www.tei-c.org/ns/1.0" xmlns:cts="http://chs.harvard.edu/xmlns/cts3">

  <xsl:param name="xml-only"/>
  <xsl:param name="blockid"/>
  <xsl:param name="hide"/>
  <xsl:param name="blocktype"/>

	<!-- Framework for main body of document -->
	<xsl:template match="/">
		<!-- can some of the reply contents in xsl variables
			for convenient use in different parts of the output -->
		<xsl:variable name="urnString">
			<xsl:value-of select="//cts:request/cts:requestUrn"/>
		</xsl:variable>
		<xsl:variable name="psg">
			<xsl:value-of select="//cts:request/cts:psg"/>
		</xsl:variable>
		<xsl:variable name="workUrn">
			<xsl:value-of select="//cts:request/cts:workUrn"/>
		</xsl:variable>
	  <div id="{$blockid}">
	    <xsl:if test="$hide">
	      <xsl:attribute name="style">display:none;</xsl:attribute>
	    </xsl:if>
	    <xsl:choose>
	      <xsl:when test="$xml-only">
	        <textarea><xsl:copy-of select="//TEI|//TEI.2"/></textarea>
	      </xsl:when>
	      <xsl:otherwise>
  				<div class="cts-content">
  					
					<xsl:choose>
						<xsl:when test="/cts:CTSError">
							<xsl:apply-templates select="cts:CTSError"/>
						</xsl:when>
						<xsl:when test="//cts:reply">
						  <div class="passage_urn"><xsl:value-of select="$urnString"/></div>
							<div class="cts-biblio">
							<xsl:choose>
								<xsl:when test="//cts:request/cts:edition">
									<p class="cts-quotation"><xsl:value-of select="//cts:request/cts:groupname"/>, <em>
										<xsl:value-of select="//cts:request/cts:title"/>
									</em>: <xsl:value-of select="//cts:request/cts:psg"/>
									</p>
									<p class="cts-quotation">
										<xsl:value-of select="//cts:request/cts:label"/>
									</p>
								</xsl:when>
								<xsl:when test="//cts:request/cts:translation">
								    <p class="cts-quotation">
										<xsl:value-of select="//cts:request/cts:groupname"/>, <em>
											<xsl:value-of select="//cts:request/cts:title"/>
										</em>: <xsl:value-of select="//cts:request/cts:psg"/></p>
								    <p class="cts-quotation">
										<xsl:value-of select="//cts:request/cts:label"/>
									</p>
								</xsl:when>
								<xsl:when test="//cts:request/cts:title">
								    <p class="cts-quotation">
										<xsl:value-of select="//cts:request/cts:groupname"/>, <em>
											<xsl:value-of select="//cts:request/cts:title"/>: <xsl:value-of select="//cts:request/cts:psg"/>
										</em></p>
								    <p class="cts-quotation">
										<xsl:value-of select="//cts:request/cts:label"/>
									</p>
								</xsl:when>
								<xsl:when test="//cts:request/cts:groupname">
								    <p class="cts-quotation">
										<xsl:value-of select="//cts:request/cts:groupname"/>
									</p>
								    <p class="cts-quotation">
										<xsl:value-of select="//cts:request/cts:label"/>
									</p>
								</xsl:when>
							  <xsl:otherwise>
							    <p class="cts-quotation">TODO - Source Text Title, Author, Edition info will be here.</p>
							  </xsl:otherwise>
							</xsl:choose>
							<!--p class="urn"> ( = <xsl:value-of select="$urnString"/> ) </p-->
							</div>
							<xsl:apply-templates select="//cts:reply"/>
						</xsl:when>
						<xsl:otherwise>
							<div class="cts-biblio">
								<p class="cts-quotation">
									<xsl:apply-templates select="//TEI.2"/>
								</p>
							</div>
						</xsl:otherwise>
					</xsl:choose>
					<!--<xsl:choose>
						<xsl:when test="//cts:inv">
							<xsl:variable name="inv">
								<xsl:value-of select="//cts:inv"/>
							</xsl:variable>
							<xsl:variable name="lnkVar">./CTS?inv=<xsl:value-of select="$inv"/>&amp;request=GetPassagePlus&amp;urn=<xsl:value-of select="//cts:requestUrn"
							/></xsl:variable>
							<p>
								<xsl:element name="a">
									<xsl:attribute name="href">
										<xsl:value-of select="$lnkVar"/>
									</xsl:attribute>
									<xsl:element name="img">
										<xsl:attribute name="src">xml.png</xsl:attribute>
									</xsl:element>
								</xsl:element>
							</p>
						</xsl:when>
						<xsl:otherwise>
							<xsl:variable name="lnkVar">./CTS?request=GetPassagePlus&amp;urn=<xsl:value-of select="//cts:requestUrn"/></xsl:variable>
							<p>
								<xsl:element name="a">
									<xsl:attribute name="href">
										<xsl:value-of select="$lnkVar"/>
									</xsl:attribute>
									<xsl:element name="img">
										<xsl:attribute name="src">xml.png</xsl:attribute>
									</xsl:element>
								</xsl:element>
							</p>
						</xsl:otherwise>
					</xsl:choose>-->
				</div>
	      </xsl:otherwise>
	    </xsl:choose>
	  </div>
	  
	</xsl:template>
	<!-- End Framework for main body document -->
	<!-- Match elements of the CTS reply -->
	<xsl:template match="cts:reply">
<!--		<xsl:if test="(@xml:lang = 'grc') or (@xml:lang = 'lat')">
			<div class="chs-alphaios-hint">Because this page has Greek or Latin text on it, it can take advantage of the morphological and lexical tools from the <a href="http://alpheios.net/" target="blank">Apheios Project</a>. If you would like to be able to learn about Greek and Latin words by double-clicking on them, you should use <a href="http://www.getfirefox.com" target="blank">Firefox</a>, and download the <a href="http://alpheios.net/">Alpheios Plugin</a>. Many thanks to the brilliant developers at Alpheios for working with us! For the moment, the Alpheios tools will not correctly identify words that are partly supplied or unclear on the original document.</div>
		</xsl:if>-->
			<!--<xsl:attribute name="lang">
				<xsl:choose>
				<xsl:when test="@xml:lang = 'lat'">la</xsl:when>
				<xsl:otherwise><xsl:value-of select="@xml:lang"/></xsl:otherwise>
				</xsl:choose>
			</xsl:attribute>-->
			<!--<xsl:if test="(//cts:reply/@xml:lang = 'grc') or (//cts:reply/@xml:lang = 'lat')">
				<xsl:attribute name="class">cts-content alpheios-enabled-text</xsl:attribute>
			</xsl:if>-->			
			<xsl:apply-templates/>
	</xsl:template>
	<xsl:template match="cts:CTSError">
		<h1>CTS Error</h1>
		<p class="cts:error">
			<xsl:apply-templates select="cts:message"/>
		</p>
		<p>Error code: <xsl:apply-templates select="cts:code"/></p>
		<p>CTS library version: <xsl:apply-templates select="cts:libraryVersion"/>
		</p>
		<p>CTS library date: <xsl:apply-templates select="cts:libraryDate"/>
		</p>
	</xsl:template>
	<xsl:template match="cts:prevnext">
		<!-- TODO add the next/previous links -->
	</xsl:template>
	
	<!-- ********************************************************** -->
	<!-- Include support for a handful of TEI namespaced elements   -->
	<!-- ********************************************************** -->
	<!-- poetry line -->
	<xsl:template match="tei:l|l">
		<p class="tei_line">
			<span class="tei_lineNumber">
				<xsl:value-of select="@n"/>
				<xsl:text>&#160;&#160;&#160;&#160;</xsl:text>
			</span>
			<xsl:apply-templates/>
		</p>
	</xsl:template>
	<!-- fragments and columns for papyrus work -->
	<xsl:template match="tei:div[@type='frag']">
		<div class="tei_fragment">
			<xsl:apply-templates/>
		</div>
	</xsl:template>
	<xsl:template match="tei:div[@type='col']">
		<div class="tei_column">
			<xsl:apply-templates/>
		</div>
	</xsl:template>
	<xsl:template match="tei:div|div">
		<xsl:choose>
			<xsl:when test="@n">
				<div class="tei_section">
					<span class="tei_sectionNum"><xsl:value-of select="@n"/></span><xsl:apply-templates/>
				</div>
			</xsl:when>
			<xsl:otherwise>
				<xsl:apply-templates/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
   
    
	<!-- quotations -->
	<xsl:template match="tei:q|q">“<xsl:apply-templates/>”</xsl:template>
	<!-- "speech" and "speaker" (used for Platonic dialogues -->
	<xsl:template match="tei:speech">
		<p>
			<xsl:apply-templates/>
		</p>
	</xsl:template>
	<xsl:template match="tei:speaker|speaker">
		<span class="tei_speaker"><xsl:apply-templates/> — </span>
	</xsl:template>
	<!-- Div's of type "book" and "line-groups", both resolving to "Book" elements in xhtml, with the enumeration on the @n attribute -->
	<xsl:template match="tei:div[@type='book']|div[@type='book']">
		<div class="tei_book">
			<!--span class="tei_bookNumber">Book <xsl:value-of select="@n"/></span-->
			<xsl:apply-templates/>
		</div>
	</xsl:template>
    <xsl:template match="tei:div1[@type='book']|div1[@type='book']">
        <div class="tei_book">
            <!--span class="tei_bookNumber">Book <xsl:value-of select="@n"/></span-->
            <xsl:apply-templates/>
        </div>
    </xsl:template>
    <xsl:template match="tei:div[@type='chapter']|div[@type='chapter']">
        <div class="tei_book">
            <!--span class="tei_bookNumber">Chapter <xsl:value-of select="@n"/></span-->
            <xsl:apply-templates/>
        </div>
    </xsl:template>
	<xsl:template match="tei:lg|lg">
		<div class="tei_book">
			<!--span class="tei_bookNumber">Book <xsl:value-of select="@n"/></span-->
			<xsl:apply-templates/>
		</div>
	</xsl:template>
	<!-- Editorial status: "unclear". Begin group of templates for adding under-dots through recursion -->
	<xsl:template match="tei:unclear|unclear">
		<span class="tei_unclearText">
			<xsl:call-template name="addDots"/>
			<!-- <xsl:apply-templates/> -->
		</span>
	</xsl:template>
	<!-- A bit of recursion to add under-dots to unclear letters -->
	<xsl:template name="addDots">
		<xsl:variable name="currentChar">1</xsl:variable>
		<xsl:variable name="stringLength">
			<xsl:value-of select="string-length(text())"/>
		</xsl:variable>
		<xsl:variable name="myString">
			<xsl:value-of select="normalize-space(text())"/>
		</xsl:variable>
		<xsl:call-template name="addDotsRecurse">
			<xsl:with-param name="currentChar">
				<xsl:value-of select="$currentChar"/>
			</xsl:with-param>
			<xsl:with-param name="stringLength">
				<xsl:value-of select="$stringLength"/>
			</xsl:with-param>
			<xsl:with-param name="myString">
				<xsl:value-of select="$myString"/>
			</xsl:with-param>
		</xsl:call-template>
	</xsl:template>
	<xsl:template name="addDotsRecurse">
		<xsl:param name="currentChar"/>
		<xsl:param name="myString"/>
		<xsl:param name="stringLength"/>
		<xsl:choose>
			<xsl:when test="$currentChar &lt;= string-length($myString)">
				<xsl:call-template name="addDotsRecurse">
					<xsl:with-param name="currentChar">
						<xsl:value-of select="$currentChar + 2"/>
					</xsl:with-param>
					<xsl:with-param name="stringLength">
						<xsl:value-of select="$stringLength + 1"/>
					</xsl:with-param>
					<!-- a bit of complexity here to put dots under all letters except spaces -->
					<xsl:with-param name="myString">
						<xsl:choose>
							<xsl:when test="substring($myString,$currentChar,1) = ' '">
								<xsl:value-of select="concat(substring($myString,1,$currentChar), ' ', substring($myString, ($currentChar+1),(string-length($myString) - ($currentChar))) )"/>
							</xsl:when>
							<xsl:otherwise>
								<xsl:value-of
									select="concat(substring($myString,1,$currentChar), '&#803;', substring($myString, ($currentChar+1),(string-length($myString) - ($currentChar))) )"/>
							</xsl:otherwise>
						</xsl:choose>
					</xsl:with-param>
				</xsl:call-template>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="$myString"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	<!-- end under-dot recursion for "unclear" text -->
	<!-- Editorial status: "supplied" -->
	<!-- By default, wraps supplied text in angle-brackets -->
	<!-- Optionally, hide supplied text, replacing each character with non-breaking spaces, through recursion -->
	<xsl:template match="tei:supplied|supplied">
		<!-- Toggle between the two lines below depending on whether you want to show supplied text or not -->
		<span class="tei_suppliedText">&lt;<xsl:apply-templates/>&gt;</span>
		<!--<span class="suppliedText"><xsl:call-template name="replaceSupplied"/></span>-->
	</xsl:template>
	<!-- begin replacing supplied text with non-breaking spaces -->
	<xsl:template name="replaceSupplied">
		<xsl:variable name="currentChar">1</xsl:variable>
		<xsl:variable name="stringLength">
			<xsl:value-of select="string-length(text())"/>
		</xsl:variable>
		<xsl:variable name="myString">
			<xsl:value-of select="normalize-space(text())"/>
		</xsl:variable>
		<xsl:call-template name="replaceSuppliedRecurse">
			<xsl:with-param name="currentChar">
				<xsl:value-of select="$currentChar"/>
			</xsl:with-param>
			<xsl:with-param name="stringLength">
				<xsl:value-of select="$stringLength"/>
			</xsl:with-param>
			<xsl:with-param name="myString">
				<xsl:value-of select="$myString"/>
			</xsl:with-param>
		</xsl:call-template>
	</xsl:template>
	<xsl:template name="replaceSuppliedRecurse">
		<xsl:param name="currentChar"/>
		<xsl:param name="myString"/>
		<xsl:param name="stringLength"/>
		<xsl:choose>
			<xsl:when test="$currentChar &lt;= string-length($myString)">
				<xsl:call-template name="replaceSuppliedRecurse">
					<xsl:with-param name="currentChar">
						<xsl:value-of select="$currentChar + 2"/>
					</xsl:with-param>
					<xsl:with-param name="stringLength">
						<xsl:value-of select="$stringLength"/>
					</xsl:with-param>
					<xsl:with-param name="myString">
						<xsl:value-of select="concat(substring($myString,1,($currentChar - 1)),'&#160;&#160;',substring($myString, ($currentChar + 1)))"/>
					</xsl:with-param>
				</xsl:call-template>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="$myString"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
	<!-- ignore the tei header for now -->
	<xsl:template match="tei:teiHeader"></xsl:template>
	
	<!-- end replacing supplied text with non-breaking spaces -->
	<xsl:template match="tei:add[@place='supralinear']|add[@place='supralinear']">
		<span class="tei_supralinearText">
			<xsl:apply-templates/>
		</span>
	</xsl:template>
	<xsl:template match="tei:title|title">
		<span class="tei_title">
			<xsl:apply-templates/>
		</span>
	</xsl:template>
	<xsl:template match="tei:note|note">
		<!-- <span class="note">
			<xsl:apply-templates/>
			</span> -->
	</xsl:template>
	<xsl:template match="tei:add|add">
		<span class="tei_addedText">
			<xsl:apply-templates/>
		</span>
	</xsl:template>
	<xsl:template match="tei:choice|choice">
		<span class="tei_choice">(<xsl:apply-templates select="tei:sic|sic"/><xsl:apply-templates select="tei:orig|orig"/>
			<xsl:apply-templates select="tei:corr|corr"/>)</span>
	</xsl:template>
	<xsl:template match="tei:sic|sic">
		<span class="tei_sic"><xsl:apply-templates/>[sic]</span>
		<!-- <xsl:if test="current()/following-sibling::tei:corr">/</xsl:if> -->
	</xsl:template>
	<xsl:template match="tei:orig|orig">
		<span class="tei_orig"><xsl:apply-templates/></span>
		<!-- <xsl:if test="current()/following-sibling::tei:corr">/</xsl:if> -->
	</xsl:template>
	<xsl:template match="tei:corr|corr">
		<span class="tei_corr">&#160;&#160;/&#160;&#160;<xsl:apply-templates/></span>
		<!-- <xsl:if test="current()/following-sibling::tei:sic">/</xsl:if> -->
	</xsl:template>
	<xsl:template match="tei:del|del">
		<span class="tei_del">
			<xsl:apply-templates/>
		</span>
	</xsl:template>
	<xsl:template match="tei:list|list">
		<ul>
			<xsl:apply-templates/>
		</ul>
	</xsl:template>
	<xsl:template match="tei:item|item">
		<li>
			<xsl:apply-templates/>
		</li>
	</xsl:template>
	<xsl:template match="tei:title|title">
		<span class="tei_primaryTitle">
			<xsl:apply-templates/>
		</span>
	</xsl:template>
	<xsl:template match="tei:head|head">
		<h3>
			<xsl:apply-templates/>
		</h3>
	</xsl:template>
	
	<xsl:template match="tei:quote[@rend='blockquote']|quote[@rend='blockquote']">
		<div class="quote"><xsl:apply-templates/></div>
	</xsl:template>
	
	<xsl:template match="tei:p|p">
		<p><xsl:apply-templates/></p>
	</xsl:template>
	
	
	<xsl:template match="tei:gap[@reason='pendingmarkup']|gap[@reason='pendingmarkup']">
		<div class="gap">. . .</div>
	</xsl:template>
	
	<xsl:template match="milestone[@unit='chapter']">
	  <div class="tei_milestone"><xsl:value-of select="@unit"/><xsl:text> </xsl:text><xsl:value-of select="@n"/></div>
	</xsl:template>
	
	<!-- Default: replicate unrecognized markup -->
	<xsl:template match="@*|node()" priority="-1">
		<xsl:copy>
			<xsl:apply-templates select="@*|node()"/>
		</xsl:copy>
	</xsl:template>
</xsl:stylesheet>
