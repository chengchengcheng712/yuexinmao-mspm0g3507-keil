@echo off
chcp 65001 >nul
set "PROJ=D:\RT-ThreadStudio\workspace\art_pi_factory"

echo 检查 art_pi_factory 工程配置 ...
echo 工程路径: %PROJ%
echo.

if not exist "%PROJ%" (
    echo [X] 工程目录不存在
    goto :end
)

cd /d "%PROJ%"

if exist "rt-thread\include\rtthread.h" (echo [OK] rt-thread\include\rtthread.h) else (echo [X] 缺少 rtthread.h)
if exist "libraries\drivers\include\drv_common.h" (echo [OK] libraries\drivers\drv_common.h) else (echo [X] 缺少 drv_common.h)
if exist "board\board.h" (echo [OK] board\board.h) else (echo [X] 缺少 board.h)
if exist ".project" (echo [OK] .project) else (echo [X] 缺少 .project)
if exist ".cproject" (echo [OK] .cproject) else (echo [X] 缺少 .cproject)

echo.
dir rt-thread 2>nul | findstr /i "<SYMLINKD>" >nul && echo [OK] rt-thread 是符号链接 || echo [!] rt-thread 可能不是符号链接
dir libraries 2>nul | findstr /i "<SYMLINKD>" >nul && echo [OK] libraries 是符号链接 || echo [!] libraries 可能不是符号链接

:end
echo.
pause
