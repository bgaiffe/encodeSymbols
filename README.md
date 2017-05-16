# encodeSymbols

Just modify the function : atilf:isSymbole so that it answers "true" for those characters you want encoded as "c".
For each character you get :
a char in charDecl with the name of the char and the instances of teh cjhar in the text become &lt;c corresp="pointer towards charDecl" type="unicodeBlock"&gt;the char&lt;/c&gt;.

test with "saxon Emojis.xml encodeSymbols.xsl".

By default, the character names are fetched from http://unicode-table.com.
In pratice, you probably will want to get a copy of ucd.all.grouped.xml from
 http://unicode.org/ (http://www.unicode.org/Public/UCD/latest/ucdxml/ucd.all.grouped.zip )and modify the parameters ucdLocal and ucdAllGroupedPath accordingly.

I would be surprised if this was bug free :-)

