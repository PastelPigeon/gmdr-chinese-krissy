param(
    [Parameter(Mandatory=$true)]
    [string]$GamePath,
    
    [switch]$CreateBackup
)

# 获取脚本所在目录
$ScriptDir = $PSScriptRoot

# 检查游戏目录是否存在
if (-not (Test-Path -Path $GamePath -PathType Container)) {
    Write-Error "游戏目录不存在: $GamePath"
    exit 1
}

# 定义文件路径
$chapterPath = Join-Path -Path $GamePath -ChildPath "chapter3_windows"
$dataWinPath = Join-Path -Path $chapterPath -ChildPath "data.win"
$backupPath = "$dataWinPath.bak"
$newDataPath = "$dataWinPath.new"
$xdeltaExe = Join-Path -Path $ScriptDir -ChildPath "xdelta3.exe"
$patchFile = Join-Path -Path $ScriptDir -ChildPath "resources\chapter3.xdelta"
$chapterResourcesPath = Join-Path -Path $ScriptDir -ChildPath "resources\chapter3_windows"

# 检查必要文件
if (-not (Test-Path -Path $dataWinPath -PathType Leaf)) {
    Write-Error "找不到游戏文件: $dataWinPath"
    exit 1
}

if (-not (Test-Path -Path $xdeltaExe -PathType Leaf)) {
    Write-Error "找不到 xdelta3.exe: $xdeltaExe"
    exit 1
}

if (-not (Test-Path -Path $patchFile -PathType Leaf)) {
    Write-Error "找不到补丁文件: $patchFile"
    exit 1
}

# 创建备份
if ($CreateBackup) {
    try {
        Copy-Item -Path $dataWinPath -Destination $backupPath -Force
        Write-Host "已创建备份: $backupPath"
    }
    catch {
        Write-Error "备份创建失败: $_"
        exit 1
    }
}

# 应用补丁
try {
    Write-Host "正在应用补丁..."
    & "$xdeltaExe" -d -s "$dataWinPath" "$patchFile" "$newDataPath"
    
    # 检查补丁是否应用成功
    if (-not (Test-Path -Path $newDataPath -PathType Leaf)) {
        throw "补丁应用失败，未生成新文件"
    }
    
    # 替换原始文件
    Remove-Item -Path $dataWinPath -Force
    Rename-Item -Path $newDataPath -NewName "data.win" -Force

    Copy-Item -Path $chapterResourcesPath -Destination $gamePath -Recurse -Force
    
    Write-Host "补丁应用成功!"
}
catch {
    Write-Error "补丁应用过程中出错: $_"
    exit 1
}