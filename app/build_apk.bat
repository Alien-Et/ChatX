@echo off
chcp 65001 >nul
echo 正在清理Flutter项目...
cd /d "D:\ChatX\app"
call flutter clean

echo 正在删除Gradle缓存...
cd android
if exist .gradle (
    echo 关闭可能锁定文件的进程...
    taskkill /f /im java.exe 2>nul
    timeout /t 3 /nobreak >nul
    
    echo 删除.gradle目录...
    rmdir /s /q .gradle 2>nul
    if exist .gradle (
        echo 首次删除失败，正在重试...
        timeout /t 5 /nobreak >nul
        rmdir /s /q .gradle 2>nul
    )
)
cd ..

echo 正在获取依赖...
call flutter pub get

echo 正在构建APK...
call flutter build apk --no-tree-shake-icons

echo 构建完成!
pause