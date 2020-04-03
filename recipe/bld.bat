setlocal EnableDelayedExpansion
@echo on

:: Configure
if "%ARCH%" == "32" (
  set SLN_PLAT=Win32
) else (
  set SLN_PLAT=x64
)

if "%VS_YEAR%" == "2015" (
  set "SLN_FILE=win32\vs14\libcroco.sln"
)
if "%VS_YEAR%" == "2017" (
  set "SLN_FILE=win32\vs15\libcroco.sln"
)

set "MSBUILD_CMD=%VSINSTALLDIR%MSBuild\%VS_VERSION%\Bin\MSBuild.exe"
if not exist "%MSBUILD_CMD%" (
  :: Azure has at least VS 2017
  :: find VS 2017+ installations using vswhere tool
  echo Searching for MSBuild using vswhere...
  set "VSWHERE_CMD=C:\Program Files (x86)\Microsoft Visual Studio\Installer\vswhere.exe"
  if not exist "!VSWHERE_CMD!" (
    set "VSWHERE_CMD=vswhere"
  )
  echo vswhere path: !VSWHERE_CMD!
  for /f "usebackq tokens=*" %%i in (`"!VSWHERE_CMD!" -latest -products * -requires Microsoft.Component.MSBuild -find MSBuild\**\Bin\MSBuild.exe`) do (
    set "MSBUILD_CMD=%%i"
  )
  if not exist "!MSBUILD_CMD!" (
    :: try just finding the VS 2017 installation path
    for /f "usebackq tokens=*" %%i in (`"!VSWHERE_CMD!" -latest -products * -requires Microsoft.Component.MSBuild -version ^[15.0^,16.0^) -property installationPath`) do (
      set "vsdir=%%i"
    )
    set "MSBUILD_CMD=!vsdir!\MSBuild\15.0\Bin\MSBuild.exe"
    if not exist "!MSBUILD_CMD!" (
      :: try a sensible default
      set "MSBUILD_CMD=C:\Program Files (x86)\Microsoft Visual Studio\2017\Enterprise\MSBuild\15.0\Bin\MSBuild.exe"
      if not exist "!MSBUILD_CMD!" (
        echo Could not find MSBuild.exe
        exit 1
      )
    )
  )
  echo MSBuild path: !MSBUILD_CMD!
)

:: Build and Install
"%MSBUILD_CMD%" "%SLN_FILE%" ^
  /p:Configuration="Release" ^
  /p:Platform="%SLN_PLAT%" ^
  /p:GlibEtcInstallRoot="%LIBRARY_PREFIX%" ^
  /p:PythonPath="%BUILD_PREFIX%" ^
  /verbosity:normal
if errorlevel 1 exit 1

:: don't include debug symbols
del %LIBRARY_BIN%\croco*.pdb
if errorlevel 1 exit 1
del %LIBRARY_BIN%\csslint.pdb
if errorlevel 1 exit 1
