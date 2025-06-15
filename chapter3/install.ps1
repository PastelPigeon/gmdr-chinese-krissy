param(
    [Parameter(Mandatory=$true)]
    [string]$GamePath,
    
    [switch]$CreateBackup
)

# ��ȡ�ű�����Ŀ¼
$ScriptDir = $PSScriptRoot

# �����ϷĿ¼�Ƿ����
if (-not (Test-Path -Path $GamePath -PathType Container)) {
    Write-Error "��ϷĿ¼������: $GamePath"
    exit 1
}

# �����ļ�·��
$chapterPath = Join-Path -Path $GamePath -ChildPath "chapter3_windows"
$dataWinPath = Join-Path -Path $chapterPath -ChildPath "data.win"
$backupPath = "$dataWinPath.bak"
$newDataPath = "$dataWinPath.new"
$xdeltaExe = Join-Path -Path $ScriptDir -ChildPath "xdelta3.exe"
$patchFile = Join-Path -Path $ScriptDir -ChildPath "resources\chapter3.xdelta"
$chapterResourcesPath = Join-Path -Path $ScriptDir -ChildPath "resources\chapter3_windows"

# ����Ҫ�ļ�
if (-not (Test-Path -Path $dataWinPath -PathType Leaf)) {
    Write-Error "�Ҳ�����Ϸ�ļ�: $dataWinPath"
    exit 1
}

if (-not (Test-Path -Path $xdeltaExe -PathType Leaf)) {
    Write-Error "�Ҳ��� xdelta3.exe: $xdeltaExe"
    exit 1
}

if (-not (Test-Path -Path $patchFile -PathType Leaf)) {
    Write-Error "�Ҳ��������ļ�: $patchFile"
    exit 1
}

# ��������
if ($CreateBackup) {
    try {
        Copy-Item -Path $dataWinPath -Destination $backupPath -Force
        Write-Host "�Ѵ�������: $backupPath"
    }
    catch {
        Write-Error "���ݴ���ʧ��: $_"
        exit 1
    }
}

# Ӧ�ò���
try {
    Write-Host "����Ӧ�ò���..."
    & "$xdeltaExe" -d -s "$dataWinPath" "$patchFile" "$newDataPath"
    
    # ��鲹���Ƿ�Ӧ�óɹ�
    if (-not (Test-Path -Path $newDataPath -PathType Leaf)) {
        throw "����Ӧ��ʧ�ܣ�δ�������ļ�"
    }
    
    # �滻ԭʼ�ļ�
    Remove-Item -Path $dataWinPath -Force
    Rename-Item -Path $newDataPath -NewName "data.win" -Force

    Copy-Item -Path $chapterResourcesPath -Destination $gamePath -Recurse -Force
    
    Write-Host "����Ӧ�óɹ�!"
}
catch {
    Write-Error "����Ӧ�ù����г���: $_"
    exit 1
}