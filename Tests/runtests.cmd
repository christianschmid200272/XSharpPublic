SET ROOT=%~dp0
SET BINARIESDIR=%ROOT%..\XSharp\Binaries
SET TESTDIR=%ROOT%..\XSharp\Binaries\Tests
SET XSCOMPILER=%BINARIESDIR%\Release\Exes\xsc\net46\xsc.exe 
SET XSTESTPROJECT=%ROOT%xSharp Tests.viproj
SET XSRUNTIMEFOLDER=%ROOT%Runtime
SET XSCONFIG=Debug
SET XSFIXEDTESTS=TRUE
SET XSLOGFILE=%TESTDIR%\LogFixed.Txt
IF NOT EXIST %TESTDIR% MKDIR %TESTDIR%
%XSCOMPILER% Automated\CompilerTests.prg /vo2 /out:%TESTDIR%\CompilerTests.exe /nowarn:165,9101
pause
%TESTDIR%\CompilerTests.exe
SET XSFIXEDTESTS=False
SET XSLOGFILE=%TESTDIR%\LogBroken.Txt
%TESTDIR%\CompilerTests.exe
