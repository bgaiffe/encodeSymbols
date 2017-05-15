<?xml version="1.0" encoding="utf-8"?>


<!-- On devrait ajouter le type... (bloc) -->


<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:tei="http://www.tei-c.org/ns/1.0" xmlns:atilf="http://www.atilf.fr" version="2.0" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:my="http://www.example.com/my" xmlns="http://www.tei-c.org/ns/1.0">

  <xsl:output method="xml"/>



  <!-- modify this in order to decide what are the symbols to encode... -->
  <!-- parameter is the unicode code -->
  <xsl:function name="atilf:isSymbole" as="xs:boolean">
    <xsl:param name="cde" as="xs:integer?"/>

    <xsl:choose>
      <xsl:when test="$cde &gt; 65535">
	true
      </xsl:when>
      <xsl:otherwise>
	false
      </xsl:otherwise>
    </xsl:choose>
  </xsl:function>

 <!-- <xsl:function name="atilf:isSymbole" as="xs:boolean">
    <xsl:param name="cde" as="xs:integer?"/>

    <xsl:choose>
      <xsl:when test="$cde &gt; 127">
	true
      </xsl:when>
      <xsl:otherwise>
	false
      </xsl:otherwise>
    </xsl:choose>
  </xsl:function> -->


  
  
  <xsl:template name="addPath">
    <xsl:param name="path"/>
    <xsl:param name="nmspace"/>

    <!-- <xsl:message>On veut créer <xsl:value-of select="substring-before($path, '/')"/></xsl:message> -->
    <xsl:element name="{substring-before($path, '/')}" namespace="{$nmspace}">
      <xsl:if test="string-length(substring-after($path, '/')) &gt; 0">
	<xsl:call-template name="addPath">
	  <xsl:with-param name="path" select="substring-after($path, '/')"/>
	  <xsl:with-param name="nmspace" select="$nmspace"/>
	</xsl:call-template>
      </xsl:if>
    </xsl:element>
  </xsl:template>

    <xsl:function name="atilf:removeHeads" as="node()">
      <xsl:param name="paths"/>

	<paths>
	  <xsl:for-each select="$paths/descendant::text()">

	    <xsl:if test="string-length(substring-after(., '/')) &gt; 0">
	      <path><xsl:value-of select="substring-after(., '/')"/></path>
	    </xsl:if>
	  </xsl:for-each>
	</paths>
    
    </xsl:function>
  

  <xsl:function name="atilf:copyAndEnsurePaths" as="node()">
    <xsl:param name="nd" as="node()"/>
    <xsl:param name="paths" as="node()"/>

    <!-- <xsl:message>
      <xsl:text>copyAndEnsurePaths(</xsl:text><xsl:copy-of select="$nd"/><xsl:text>, </xsl:text>
      <xsl:copy-of select="$paths"/><xsl:text>)</xsl:text>
    </xsl:message> -->
    <xsl:choose>
      <xsl:when test="$nd/self::*">
	<!-- $nd doit être en tête de chacun des paths... -->
	
	<xsl:element name="{name($nd)}" namespace="{namespace-uri($nd)}">
	  <xsl:for-each select="$nd/@*">
	    <xsl:copy-of select="."/>
	  </xsl:for-each>
	  <xsl:for-each select="$nd/node()">
	    <xsl:choose>
	      <xsl:when test="self::*">
		<xsl:variable name="monNom" select="concat(local-name(.), '/')"/>
		<xsl:variable name="hisPaths">
		  <paths>
		    <xsl:for-each select="atilf:removeHeads($paths)/descendant::text()">
		      <xsl:if test="starts-with(., $monNom)">
			<path><xsl:copy-of select="."/></path>
		      </xsl:if>
		    </xsl:for-each>
		  </paths>
		</xsl:variable>
		<xsl:copy-of select="atilf:copyAndEnsurePaths(., $hisPaths)"/>
	      </xsl:when>
	      <xsl:otherwise>
		<xsl:copy-of select="."/>
	      </xsl:otherwise>
	    </xsl:choose>
	  </xsl:for-each>
	  <!-- on ajoute les nds à ajouter si nécessaire -->
	  <xsl:for-each select="atilf:removeHeads($paths)/descendant::text()">
	    <xsl:variable name="p" select="substring-before(., '/')"/>
	    <xsl:if test="not($nd/*[local-name()=$p])">
	      <!-- <ilFautAjouter><xsl:value-of select="."/></ilFautAjouter>  -->
	      <xsl:call-template name="addPath">
		<xsl:with-param name="path" select="."/>
		<xsl:with-param name="nmspace" select="namespace-uri($nd)"/>
	      </xsl:call-template> 
	    </xsl:if>
	  </xsl:for-each>
	</xsl:element>
      </xsl:when>
      <xsl:otherwise>
	<xsl:copy-of select="$nd"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:function>

 

  
  <!-- as usual, my is not mine :-) -->
  <xsl:function name="my:int-to-hex" as="xs:string">
      <xsl:param name="in" as="xs:integer"/>
      <xsl:sequence
        select="if ($in eq 0)
                then '0'
                else
                  concat(if ($in gt 16)
                         then my:int-to-hex($in idiv 16)
                         else '',
                         substring('0123456789ABCDEF',
                                   ($in mod 16) + 1, 1))"/>
  </xsl:function>

  

  
  
   <xsl:function name="atilf:indexPremEmoji_v3" as="xs:integer">
    <xsl:param name="codes" as="xs:integer*"/>

    <xsl:variable name="all"
		  select="
			  for $i in 1 to count($codes) return
			  if (atilf:isSymbole($codes[$i])) then $i else ()"/>

    <xsl:choose>
      <xsl:when test="count($all) = 0">
	-1
      </xsl:when>
      <xsl:otherwise>
	<xsl:value-of select="$all[1]"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:function>
  
  <xsl:function name="atilf:emoji" as="node()*">
    <xsl:param name="s" as="xs:string"/>

    <!-- <xsl:message><xsl:text>atilf:emoji(</xsl:text>
    <xsl:value-of select="$s"/>
    <xsl:text>)&#x0a;</xsl:text>
    </xsl:message> -->
    <xsl:variable name="codes" select="string-to-codepoints($s)"/>
    <xsl:variable name="indexPremEmoji" select="atilf:indexPremEmoji_v3($codes)"/>
    <xsl:choose>
      <xsl:when test="$indexPremEmoji = -1">
	<xsl:value-of select="$s"/>
      </xsl:when>
      <xsl:otherwise>
	<!-- <xsl:message><xsl:text>trouvé émoji en </xsl:text>
	<xsl:value-of select="$indexPremEmoji"/>
	</xsl:message> -->
	<xsl:value-of select="substring($s, 0, $indexPremEmoji)"/>
	<c><xsl:value-of select="substring($s, $indexPremEmoji, 1) "/></c>
	<xsl:copy-of select="atilf:emoji(substring($s, $indexPremEmoji+1))"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:function> 


  <xsl:function name="atilf:getUnicode">
    <xsl:param name="char"/>

    
    <!-- <xsl:message>
      <xsl:text>atilf:getUnicode(</xsl:text>
      <xsl:value-of select="$char"/>
      <xsl:text>)</xsl:text>
    </xsl:message> -->

    

    <xsl:variable name="code" select="my:int-to-hex(string-to-codepoints($char))"/>


    <!-- Il faudrait récupérer le fichier xml qui va bien -->
    <xsl:variable name="htPage" select="unparsed-text(concat('https://unicode-table.com/en/', $code))"/>

    
    <char>
      <charName>
    <xsl:analyze-string select="$htPage" regex="&lt;title&gt;[^-]+-\s*([^(]+)\s*\([^&lt;]+">
      <xsl:matching-substring>
	<xsl:copy-of select="normalize-space(regex-group(1))"/>
      </xsl:matching-substring>
    </xsl:analyze-string>
      </charName>
      <mapping type="unicode">
	<xsl:value-of select="$code"/>
      </mapping>
      <mapping type="standard">
	<xsl:value-of select="$char"/>
      </mapping>
      <desc>
    <xsl:analyze-string select="$htPage" regex="&lt;td&gt;Block&lt;/td&gt;&lt;td&gt;&lt;a[^&gt;]*&gt;([^&lt;]+)">
      <xsl:matching-substring>
	<xsl:copy-of select="regex-group(1)"/>
      </xsl:matching-substring>
    </xsl:analyze-string>
      </desc>
    </char>
  </xsl:function>

  <xsl:template match="/">
    <xsl:variable name="p1">
      <xsl:apply-templates mode="copy"/>
    </xsl:variable>
    <!-- <xsl:variable name="symboles">
      <symbols>
	<xsl:for-each-group select="$p1/descendant::atilf:c" group-by="text()">
	  <xsl:copy-of select="atilf:getUnicode(my:int-to-hex(string-to-codepoints(current-group()/text())))"/>
	</xsl:for-each-group>
      </symbols>
    </xsl:variable> -->
  
    <xsl:variable name="paths">
      <paths>
	<path>teiCorpus/teiHeader/encodingDesc/charDecl/</path>
      </paths>
    </xsl:variable>
    <xsl:variable name="p2">
      <xsl:copy-of select="atilf:copyAndEnsurePaths($p1/node(), $paths)"/>
    </xsl:variable>
    <!-- maintenant on ajoute nos caractères dans le charDecl et on pointe (via @corresp) depuis
	 les <c> du texte ... -->
    <xsl:variable name="p3">
      <xsl:apply-templates mode="createCharDecl" select="$p2"/>
    </xsl:variable>
    <xsl:variable name="p4">
      <xsl:apply-templates mode="refToChars" select="$p3"/>
    </xsl:variable>
    <xsl:copy-of select="$p4"/>
  </xsl:template>

  <xsl:template match="*" mode="copy">
    <xsl:copy>
      <xsl:apply-templates select="@* | node()" mode="copy"/>
    </xsl:copy>
  </xsl:template>

  <xsl:template match="@*" mode="copy">
    <xsl:copy/>
  </xsl:template>

  <xsl:template match="text()" mode="copy">
    <xsl:copy-of select="atilf:emoji(.)"/>
  </xsl:template>


  <xsl:template match="*" mode="createCharDecl">
    <xsl:copy>
      <xsl:apply-templates select="@* | node()" mode="createCharDecl"/>
    </xsl:copy>
  </xsl:template>

  <xsl:template match="@* | text() | comment() | processing-instruction()" mode="createCharDecl">
    <xsl:copy/>
  </xsl:template>

  <xsl:template match="tei:charDecl" mode="createCharDecl">
    <xsl:copy>
      <xsl:for-each-group select="//descendant::tei:c" group-by="text()">
	<!-- <xsl:variable name="cd" select="atilf:getUnicode(my:int-to-hex(string-to-codepoints(current-group()/text())))"/> -->
	<xsl:variable name="cd" select="atilf:getUnicode(current-group()[1]/text())"/>
	<xsl:apply-templates select="$cd" mode="createCharDecl"/>
      </xsl:for-each-group>
    </xsl:copy>
  </xsl:template>

  <xsl:template match="tei:char" mode="createCharDecl">
    <xsl:copy>
      <xsl:apply-templates select="@*" mode="createCharDecl"/>
      <xsl:attribute name="xml:id">
	<xsl:value-of select="generate-id()"/>
      </xsl:attribute>
       <xsl:apply-templates select="node()" mode="createCharDecl"/>
    </xsl:copy>
  </xsl:template>

  <xsl:template match="*" mode="refToChars">
    <xsl:copy>
      <xsl:apply-templates select="@* | node()" mode="refToChars"/>
    </xsl:copy>
  </xsl:template>

  <xsl:template match="@* | text() | comment() | processing-instruction" mode="refToChars">
    <xsl:copy/>
  </xsl:template>

  <xsl:template match="tei:c" mode="refToChars">
    <xsl:variable name="montexte" select="./text()"/>
    <xsl:copy>
      <xsl:apply-templates select="@*"/>
      <xsl:attribute name="corresp">
	<xsl:value-of select="concat('#', /descendant::tei:char[tei:mapping[@type='standard']/text()=$montexte]/@xml:id)"/>
      </xsl:attribute>
      <xsl:attribute name="type">
	<xsl:value-of select="//tei:char[tei:mapping[@type='standard']/text()=$montexte]/tei:desc"/>
      </xsl:attribute>
      <xsl:apply-templates mode="refToChars"/>
    </xsl:copy>
  </xsl:template>
  
</xsl:stylesheet>
