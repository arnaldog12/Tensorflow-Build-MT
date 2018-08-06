:: This script assumes the standard setup on tensorflow Jenkins windows machines.
:: It is NOT guaranteed to work on any other machine. Use at your own risk!
::
:: REQUIREMENTS:
:: * All installed in standard locations:
::   - JDK8, and JAVA_HOME set.
::   - Microsoft Visual Studio 2015 Community Edition
::   - Msys2
::   - Anaconda3
::   - CMake
:: * Before running this script, you have to set BUILD_CC_TESTS and BUILD_PYTHON_TESTS
::   variables to either "ON" or "OFF".
:: * Either have the REPO_ROOT variable set, or run this from the repository root directory.

:: Check and set REPO_ROOT
@echo off
IF [%REPO_ROOT%] == [] (
  SET REPO_ROOT=..
)

:: Turn echo back on, above script turns it off.
ECHO ON

:: Set environment variables to be shared between runs. Do not override if they
:: are set already.

IF DEFINED CMAKE_EXE (ECHO CMAKE_EXE is set to %CMAKE_EXE%) ELSE (SET CMAKE_EXE="C:/Program Files/CMake/bin/cmake.exe")
IF DEFINED SWIG_EXE (ECHO SWIG_EXE is set to %SWIG_EXE%) ELSE (SET SWIG_EXE="C:/tools/swigwin-3.0.10/swig.exe")
IF DEFINED PY_EXE (ECHO PY_EXE is set to %PY_EXE%) ELSE (SET PY_EXE="C:/Users/administrator/AppData/Local/Continuum/miniconda3/envs/python35/python.exe")
IF DEFINED PY_LIB (ECHO PY_LIB is set to %PY_LIB%) ELSE (SET PY_LIB="C:/Users/administrator/AppData/Local/Continuum/miniconda3/envs/python35/libs/python35.lib")
IF DEFINED CUDNN_HOME (ECHO CUDNN_HOME is set to %CUDNN_HOME%) ELSE (SET CUDNN_HOME="C:/Program Files/NVIDIA GPU Computing Toolkit/CUDA/v8.0")
IF DEFINED CUDA_TOOLKIT_ROOT_DIR (ECHO CUDA_TOOLKIT_ROOT_DIR is set to %CUDA_TOOLKIT_ROOT_DIR%) ELSE (SET CUDA_TOOLKIT_ROOT_DIR="C:/Program Files/NVIDIA GPU Computing Toolkit/CUDA/v8.0/bin")

:: verbosity:quiet
SET CMAKE_DIR=C:/tensorflow/tensorflow/contrib/cmake
SET MSBUILD_EXE="C:/Program Files (x86)/Microsoft Visual Studio/2017/Professional/MSBuild/15.0/Bin/MSBuild.exe"

:: Run cmake to create Visual Studio Project files.
%CMAKE_EXE% %CMAKE_DIR% -A x64 -DCMAKE_BUILD_TYPE=Release -Dtensorflow_ENABLE_GPU=ON -DCUDNN_HOME=%CUDNN_HOME% -DCUDA_HOST_COMPILER="C:\Program Files (x86)\Microsoft Visual Studio 14.0\VC\bin\amd64\cl.exe" -DPYTHON_EXECUTABLE=%PY_EXE% -Dtensorflow_BUILD_PYTHON_BINDINGS=OFF -DCMAKE_CXX_FLAGS_DEBUG="/MTd /Zi /Ob0 /Od /RTC1" -DCMAKE_CXX_FLAGS_MINSIZEREL="/MT /O1 /Ob1 /DNDEBUG" -DCMAKE_CXX_FLAGS_RELEASE="/MT /O2 /Ob2 /DNDEBUG" -DCMAKE_CXX_FLAGS_RELWITHDEBINFO="/MT /Zi /O2 /Ob1 /DNDEBUG" -DCMAKE_C_FLAGS_DEBUG="/MTd /Zi /Ob0 /Od /RTC1" -DCMAKE_C_FLAGS_MINSIZEREL="/MT /O1 /Ob1 /DNDEBUG" -DCMAKE_C_FLAGS_RELEASE="/MT /O2 /Ob2 /DNDEBUG" -DCMAKE_C_FLAGS_RELWITHDEBINFO="/MT /Zi /O2 /Ob1 /DNDEBUG"

:: Run msbuild in the resulting VS project files to build a pip package.
%MSBUILD_EXE% /p:Configuration=Release /p:Platform=x64 /m:6 tensorflow.sln /t:Clean;Build /p:PreferredToolArchitecture=x64