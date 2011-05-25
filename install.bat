set DMDWIN=\jpro\dmd2\windows
rem Copy lib file and import directories
copy libjeca.lib %DMDWIN%\lib
md %DMDWIN%\import\Jeca
copy *.d %DMDWIN%\import\Jeca
del %DMDWIN%\import\Jeca\test.d
