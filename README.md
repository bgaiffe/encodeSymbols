# encodeSymbols

Just modify the function : atilf:isSymbole so that it answers "true" for those characters you want encoded as "c".
For each character you get :
a char in charDecl with the name of the char and the instances of teh cjhar in the text become &lt;c corresp="pointer towards charDecl" type="unicodeBlock"&gt;the char&lt;/c&gt;.

test with "saxon Emojis.xml encodeSymbols.xsl".

