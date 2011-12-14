echo -- Installing Jeca library --
set DWIN=\jpro\dmd2\windows
rem Copy lib file and import directories
copy libjeca.lib %DWIN%\lib
md %DWIN%\import\Jeca
copy *.d %DWIN%\import\Jeca
del %DWIN%\import\Jeca\test.d
