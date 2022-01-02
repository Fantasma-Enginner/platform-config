@echo off

setlocal
cd /d %~dp0

:install
if not "%VPS_HOME%" == "" goto checkVPSHome
set VPS_HOME=C:\Software\VPS

:checkVPSHome
if exist "%VPS_HOME%" goto okVPS
mkdir %VPS_HOME%
:okVPS
set "APP_NAME=platform-config"
set "APP_HOME=%VPS_HOME%\%APP_NAME%"
set "SERVICE_NAME=VPS-%APP_NAME%"

sc query state=all | find "%SERVICE_NAME%"
if %ERRORLEVEL% equ 1 goto copyBin
sc query | find "%SERVICE_NAME%"
if %ERRORLEVEL% equ 1 goto copyBin 
net stop %SERVICE_NAME%
if %ERRORLEVEL% equ 0 goto copyBin 
echo ERROR: No ha sido posible detener el servicio %SERVICE_NAME%. No es posible continuar con la instalación.
goto end

if exist %APP_HOME% goto copyBin
mkdir %APP_HOME%
:copyBin
xcopy /e /y /q bin %APP_HOME%\bin\
echo Recursos ejecutables copiados


set "conf_dir=%APP_HOME%\bin\config\" 
if exist "%conf_dir%" goto okConfigVPS
mkdir %conf_dir%

:okConfigVPS
cd config
for %%a in (*.*) do if not exist "%conf_dir%\%%a" copy "%%a" "%conf_dir%"
cd ..

sc query state=all | find "%SERVICE_NAME%"
if %ERRORLEVEL% equ 1 %APP_HOME%/bin/%APP_NAME%.exe install
if %ERRORLEVEL% equ 0 goto starService
echo ADVERTENCIA: No ha sido posible instalar el servicio.
:starService
net start %SERVICE_NAME%
if %ERRORLEVEL% equ 2 echo ADVERTENCIA: No ha sido posible iniciar el servicio. Un usuario con privilegios administrativos debe iniciar el servicio manualmente.  

:end
echo Finalizado
pause