@echo off
echo --- Make Jeca library ---
set SRC=all.d base.d bmp.d misc.d snd.d
dmd -lib -oflibjeca %SRC%
