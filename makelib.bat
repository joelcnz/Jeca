@echo off
echo --- Make Jeca library ---
set SRC=all.d base.d bmp.d misc.d snd.d
dmd -lib -oflibjeca %SRC%
echo Copy lib file and import directories
copy libjeca.lib \jpro\dmd2\windows\lib
md \jpro\dmd2\windows\import\Jeca
copy *.d \jpro\dmd2\windows\import\Jeca
rem Note copies test.d file with the import files
