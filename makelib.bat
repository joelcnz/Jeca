rem Make Jeca library
dmd -lib -oflibjeca all.d base.d bmp.d misc.d
echo Copy to program(s) to use
copy libjeca.lib ..\..\Abc5
