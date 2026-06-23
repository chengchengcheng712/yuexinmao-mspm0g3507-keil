@echo off
chcp 65001 >nul
setlocal EnableDelayedExpansion

:: ============================================================
::  ART-Pi Keil 工程一键配置（比 RT-Thread Studio 简单）
::  用法：右键“以管理员身份运行”
:: ============================================================

set "SDK_ROOT=D:\installer\sdk-bsp-stm32h750-realthread-artpi-master\sdk-bsp-stm32h750-realthread-artpi-master"
set "PROJ_NAME=art_pi_blink_led"
set "PROJ_DIR=%SDK_ROOT%\projects\%PROJ_NAME%"

echo.
echo ========================================
echo  ART-Pi Keil 工程配置
echo  工程: %PROJ_NAME%
echo ========================================
echo.

net session >nul 2>&1
if %errorLevel% neq 0 (
    echo 请求管理员权限...
    powershell -NoProfile -Command "Start-Process -FilePath '%~f0' -Verb RunAs"
    exit /b
)

if not exist "%SDK_ROOT%\rt-thread\include\rtthread.h" (
    echo [错误] SDK 路径不对: %SDK_ROOT%
    pause & exit /b 1
)

if not exist "%PROJ_DIR%\project.uvprojx" (
    echo [错误] 找不到 Keil 工程: %PROJ_DIR%
    pause & exit /b 1
)

cd /d "%PROJ_DIR%"

if exist rt-thread rmdir rt-thread 2>nul
if exist libraries rmdir libraries 2>nul

mklink /D rt-thread "%SDK_ROOT%\rt-thread"
mklink /D libraries "%SDK_ROOT%\libraries"

if not exist rt-thread\include\rtthread.h (
    echo [错误] 符号链接创建失败
    pause & exit /b 1
)

echo.
echo [成功] 符号链接已创建
echo.
echo 接下来请按顺序操作：
echo.
echo 1. 安装 Keil 器件包（只需一次）
echo    打开 Keil -^> Project -^> Manage -^> Pack Installer
echo    搜索 STM32H7xx_DFP -^> Install
echo    或访问: https://www.keil.arm.com/packs/stm32h7xx_dfp-keil/
echo.
echo 2. 用 Keil 打开工程：
echo    %PROJ_DIR%\project.uvprojx
echo.
echo 3. 若提示缺少器件包，点 Install 安装 Keil.STM32H7xx_DFP
echo.
echo 4. 编译：按 F7
echo.
echo 5. 下载到 ART-Pi（需配置 QSPI Flash 算法）：
echo    复制 %SDK_ROOT%\debug\flm\ART-Pi_W25Q64.FLM
echo    到 Keil 安装目录 ARM\Flash\ 下
echo    然后在 Options -^> Debug -^> Settings -^> Flash Download 添加
echo    起始地址 0x90000000
echo.
echo 提示：建议先用 art_pi_blink_led 验证环境，再开 art_pi_factory
echo       factory 工程很大，Keil 评估版有 32KB 代码限制，可能编不过
echo.
pause
