# 构建ChatX APK脚本 - 针对Java 20.0.2优化
# 确保所有临时文件和输出都在D盘

# 设置工作目录
Set-Location -Path "D:\ChatX\app"

# 创建必要的目录
$tempDir = "D:\ChatX\app\build\tmp"
$homeDir = "D:\ChatX\app\build\home"
$gradleWorkDir = "D:\ChatX\app\build\gradle-work"
$apkOutputDir = "D:\ChatX\app\build\apk"

if (-not (Test-Path $tempDir)) {
    New-Item -ItemType Directory -Path $tempDir -Force
}
if (-not (Test-Path $homeDir)) {
    New-Item -ItemType Directory -Path $homeDir -Force
}
if (-not (Test-Path $gradleWorkDir)) {
    New-Item -ItemType Directory -Path $gradleWorkDir -Force
}
if (-not (Test-Path $apkOutputDir)) {
    New-Item -ItemType Directory -Path $apkOutputDir -Force
}

# 设置环境变量
$env:JAVA_HOME = "C:\Program Files\Java\jdk-20"
$env:GRADLE_USER_HOME = "D:\ChatX\app\android\.gradle"
$env:JAVA_OPTS = "-Djava.io.tmpdir=$tempDir -Duser.home=$homeDir --add-opens=java.base/java.io=ALL-UNNAMED --add-opens=java.base/java.lang=ALL-UNNAMED --add-opens=java.base/java.util=ALL-UNNAMED"

# 清理之前的构建
Write-Host "清理之前的构建..." -ForegroundColor Green
flutter clean

# 获取依赖
Write-Host "获取依赖..." -ForegroundColor Green
flutter pub get

# 构建APK
Write-Host "构建APK..." -ForegroundColor Green
flutter build apk --release

# 检查构建结果
$releaseApk = "D:\ChatX\app\build\app\outputs\flutter-apk\app-release.apk"
if (Test-Path $releaseApk) {
    # 复制APK到指定输出目录
    $outputApk = "$apkOutputDir\ChatX-release.apk"
    Copy-Item -Path $releaseApk -Destination $outputApk -Force
    Write-Host "APK构建成功！输出位置: $outputApk" -ForegroundColor Green
} else {
    Write-Host "APK构建失败！" -ForegroundColor Red
}

Write-Host "构建完成！" -ForegroundColor Green