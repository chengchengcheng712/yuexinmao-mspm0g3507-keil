@echo off
chcp 65001 >nul
setlocal EnableDelayedExpansion

:: ============================================================
::  ART-Pi art_pi_factory 手动导入一键配置脚本
::  功能：复制工程 + 创建 rt-thread/libraries 符号链接 + 校验
::  用法：右键“以管理员身份运行”
:: ============================================================

set "SDK_ROOT=D:\installer\sdk-bsp-stm32h750-realthread-artpi-master\sdk-bsp-stm32h750-realthread-artpi-master"
set "WORKSPACE_PROJ=D:\RT-ThreadStudio\workspace\art_pi_factory"
set "SDK_PROJ=%SDK_ROOT%\projects\art_pi_factory"

echo.
echo ========================================
echo  ART-Pi art_pi_factory 工程配置工具
echo ========================================
echo.

:: ---------- 检查管理员权限 ----------
net session >nul 2>&1
if %errorLevel% neq 0 (
    echo [提示] 需要管理员权限来创建符号链接，正在请求提升权限...
    powershell -NoProfile -Command "Start-Process -FilePath '%~f0' -Verb RunAs"
    exit /b
)

:: ---------- 检查 SDK 路径 ----------
if not exist "%SDK_ROOT%\rt-thread\include\rtthread.h" (
    echo [错误] 找不到 SDK 根目录，请检查路径：
    echo        %SDK_ROOT%
    echo.
    echo 请用记事本打开本脚本，修改顶部的 SDK_ROOT 变量。
    pause
    exit /b 1
)

if not exist "%SDK_PROJ%\.project" (
    echo [错误] 找不到 SDK 中的 art_pi_factory 工程：
    echo        %SDK_PROJ%
    pause
    exit /b 1
)

:: ---------- 复制工程到 workspace（如不存在或不完整）----------
if not exist "%WORKSPACE_PROJ%\.project" (
    echo [1/4] 正在从 SDK 复制 art_pi_factory 到 workspace ...
    if not exist "%WORKSPACE_PROJ%" mkdir "%WORKSPACE_PROJ%"
    robocopy "%SDK_PROJ%" "%WORKSPACE_PROJ%" /E /XD rt-thread libraries /NFL /NDL /NJH /NJS /nc /ns /np
    if !errorlevel! GEQ 8 (
        echo [错误] 复制工程失败。
        pause
        exit /b 1
    )
    echo       复制完成。
) else (
    echo [1/4] workspace 中已有 art_pi_factory，跳过复制。
)

cd /d "%WORKSPACE_PROJ%"
if %errorlevel% neq 0 (
    echo [错误] 无法进入工程目录：%WORKSPACE_PROJ%
    pause
    exit /b 1
)

:: ---------- 创建 rt-thread 符号链接 ----------
echo [2/4] 配置 rt-thread 符号链接 ...
call :SetupLink "rt-thread" "%SDK_ROOT%\rt-thread"
if %errorlevel% neq 0 goto :failed

:: ---------- 创建 libraries 符号链接 ----------
echo [3/4] 配置 libraries 符号链接 ...
call :SetupLink "libraries" "%SDK_ROOT%\libraries"
if %errorlevel% neq 0 goto :failed

:: ---------- 校验 ----------
echo [4/4] 校验工程文件 ...
set "OK=1"

if not exist "rt-thread\include\rtthread.h" (
    echo [失败] 缺少 rt-thread\include\rtthread.h
    set "OK=0"
)
if not exist "libraries\drivers\include\drv_common.h" (
    echo [失败] 缺少 libraries\drivers\include\drv_common.h
    set "OK=0"
)
if not exist "board\board.h" (
    echo [失败] 缺少 board\board.h
    set "OK=0"
)
if not exist ".project" (
    echo [失败] 缺少 .project（不是有效 Eclipse 工程）
    set "OK=0"
)

if "%OK%"=="0" goto :failed

echo.
echo ========================================
echo  配置成功！工程已就绪，可以导入 Studio
echo ========================================
echo.
echo 工程路径：
echo   %WORKSPACE_PROJ%
echo.
echo 接下来在 RT-Thread Studio 中操作：
echo   1. 文件 -^> 导入 (Import)
echo   2. 选择：General -^> Existing Projects into Workspace
echo   3. 浏览到：%WORKSPACE_PROJ%
echo   4. 勾选 art_pi_factory
echo   5. 【不要】勾选 Copy projects into workspace
echo   6. 点击 Finish
echo   7. Project -^> Clean，再 Build Project
echo.
pause
exit /b 0

:SetupLink
set "LINK_NAME=%~1"
set "LINK_TARGET=%~2"

if exist "%LINK_NAME%\NUL" (
    if exist "%LINK_NAME%\include\rtthread.h" (
        echo       %LINK_NAME% 已正确存在，跳过。
        exit /b 0
    )
    if /i "%LINK_NAME%"=="libraries" (
        if exist "%LINK_NAME%\drivers\include\drv_common.h" (
            echo       %LINK_NAME% 已正确存在，跳过。
            exit /b 0
        )
    )
    echo       删除旧的 %LINK_NAME% ...
    rmdir "%LINK_NAME%" 2>nul
    if exist "%LINK_NAME%" rd /s /q "%LINK_NAME%"
)

echo       mklink /D %LINK_NAME% %LINK_TARGET%
mklink /D "%LINK_NAME%" "%LINK_TARGET%" >nul
if %errorlevel% neq 0 (
    echo [错误] 创建 %LINK_NAME% 链接失败。请确认以管理员身份运行。
    exit /b 1
)
exit /b 0

:failed
echo.
echo ========================================
echo  配置失败，请检查上方错误信息
echo ========================================
pause
exit /b 1
