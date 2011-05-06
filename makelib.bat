rem Make Jeca library
dmd -lib -oflibjeca all.d base.d bmp.d misc.d
copy libjeca.lib \jpro\dmd2\windows\lib
