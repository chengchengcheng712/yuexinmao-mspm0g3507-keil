@echo off
chcp 65001 >nul
setlocal

:: 修复 RT-Thread Studio 中 art_pi_factory 的配置问题
:: 问题1: 缺少 rt-thread / libraries 链接
:: 问题2: factory 工程仍配置旧版 lwip-2.0.2，与当前 SDK 不匹配

set "SDK_ROOT=D:\installer\sdk-bsp-stm32h750-realthread-artpi-master\sdk-bsp-stm32h750-realthread-artpi-master"
set "PROJ=D:\RT-ThreadStudio\workspace\art_pi_factory"

echo.
echo ==========================================
echo  art_pi_factory RT-Thread Studio 配置修复
echo ==========================================
echo.

net session >nul 2>&1
if %errorlevel% neq 0 (
    echo 正在请求管理员权限...
    powershell -NoProfile -Command "Start-Process -FilePath '%~f0' -Verb RunAs"
    exit /b
)

if not exist "%PROJ%\.project" (
    echo [错误] 找不到工程: %PROJ%
    pause & exit /b 1
)

cd /d "%PROJ%"

echo [1/3] 检查 rt-thread / libraries ...
if exist "rt-thread\include\rtthread.h" (
    echo       rt-thread 已存在
) else (
    echo       创建 rt-thread 链接...
    if exist rt-thread rmdir rt-thread 2>nul
    mklink /D rt-thread "%SDK_ROOT%\rt-thread"
)

if exist "libraries\drivers\drv_gpio.c" (
    echo       libraries 已存在
) else (
    echo       创建 libraries 链接...
    if exist libraries rmdir libraries 2>nul
    mklink /D libraries "%SDK_ROOT%\libraries"
)

if not exist "rt-thread\include\rtthread.h" (
    echo [错误] rt-thread 仍不可用，请检查 SDK 路径
    pause & exit /b 1
)

echo.
echo [2/3] 检查 lwIP 配置 ...
findstr /C:"CONFIG_RT_USING_LWIP202=y" .config >nul 2>&1
if %errorlevel%==0 (
    echo       检测到旧版 lwIP 2.0.2 配置，正在改为 2.0.3 ...
    powershell -NoProfile -Command "(Get-Content '.config') -replace 'CONFIG_RT_USING_LWIP202=y','# CONFIG_RT_USING_LWIP202 is not set' -replace '# CONFIG_RT_USING_LWIP203 is not set','CONFIG_RT_USING_LWIP203=y' | Set-Content '.config'"
    findstr /C:"CONFIG_RT_USING_LWIP_VER_NUM" .config >nul || echo CONFIG_RT_USING_LWIP_VER_NUM=0x20003>>.config
    echo       .config 已更新，请在 Studio 中重新保存 RT-Thread Settings
) else (
    echo       lwIP 配置看起来正常
)

echo.
echo [3/3] 完成。接下来在 RT-Thread Studio 中操作：
echo.
echo   1. 右键 art_pi_factory -^> Refresh
echo   2. 双击打开 RT-Thread Settings
echo   3. 左侧: Components -^> Network -^> LwIP
echo   4. 选择: lwIP v2.0.3  (不要选 2.1.2)
echo   5. 按 Ctrl+S 保存，等待工程自动刷新
echo   6. Project -^> Clean
echo   7. Project -^> Build Project
echo.
pause
