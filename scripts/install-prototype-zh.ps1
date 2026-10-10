#Requires -Version 5.1
<#
.SYNOPSIS
    汉化《虐杀原形》(PROTOTYPE, 2009, Steam AppID 10150)。

.DESCRIPTION
    自动化安装 "Prototype(R) 新版 100% 汉化重译（第二版）"：
      1) 备份会被覆盖的原文件
      2) 覆盖 emoose PrototypeFix 优化文件并给 prototypef.exe 打 xdelta 补丁
      3) 用 ScarfaceExtractor 解包 8 个 .rcf
      4) 覆盖 14511 个汉化文件
      5) 把必须移除的 11 个文件移到备份目录

    默认是预演（dry-run），只打印将要做什么；只有显式加 -Apply 才会真正改动游戏目录。
    本脚本会修改游戏安装，请先确认游戏是纯净英文版并已启动过一次英文版。

.PARAMETER PatchRoot
    解压后的补丁根目录，即包含 "Prototype(R)：优化文件" / "Prototype(R)：汉化文件" 子目录的那一层。

.PARAMETER GameDir
    游戏安装目录。省略时自动从 Steam 库中查找 ...\steamapps\common\Prototype。

.PARAMETER BackupDir
    备份目录，默认 D:\PrototypeBackup。

.PARAMETER SkipOptimization
    已经装过优化文件时使用，跳过第 2 步。

.EXAMPLE
    pwsh -File install-prototype-zh.ps1 -PatchRoot 'D:\PrototypePatch\Prototype(R)：第二版补丁'

.EXAMPLE
    pwsh -File install-prototype-zh.ps1 -PatchRoot 'D:\PrototypePatch\Prototype(R)：第二版补丁' -Apply
#>
[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)][string]$PatchRoot,
    [string]$GameDir,
    [string]$BackupDir = 'D:\PrototypeBackup',
    [switch]$SkipOptimization,
    [switch]$Apply
)

$ErrorActionPreference = 'Stop'
$requiredRcf = @('00audio.rcf','01audio.rcf','00woi.rcf','01woi.rcf','02woi.rcf','03woi.rcf','art.rcf','movies.rcf')
$unpackedDirs = @('art','audio','movies')
$looseFiles = @(
    'prototypef.exe','prototypeenginef.dll','binkw32.dll','cementfiles.p3d',
    'skuinfo.p3d','proto_uv.dat','10150_install.vdf'
)
$patchLeftovers = @(
    'ApplyGameLaunchFix.bat','prototypef.vcdiff','xdelta3-3.1.0-i686.exe','prototypef.exe.bak'
)
$cleanupFiles = @(
    '00audio.rcf.备份','00woi.rcf.备份','01audio.rcf.备份','01woi.rcf.备份',
    '02woi.rcf.备份','03woi.rcf.备份','art.rcf.备份','movies.rcf.备份',
    '解包rcf.bat','extraction_log.txt','ScarfaceExtractor.exe'
)

function Write-Step { param([string]$Message) Write-Host "`n== $Message" -ForegroundColor Cyan }
function Write-Plan { param([string]$Message) Write-Host "   - $Message" }
function Invoke-Do {
    param([string]$Description, [scriptblock]$Action)
    if ($Apply) { & $Action } else { Write-Plan "[dry-run] $Description" }
}

function Resolve-SteamGameDir {
    $candidates = New-Object System.Collections.Generic.List[string]
    $steamPath = (Get-ItemProperty 'HKCU:\SOFTWARE\Valve\Steam' -ErrorAction SilentlyContinue).SteamPath
    if (-not $steamPath) {
        $steamPath = (Get-ItemProperty 'HKLM:\SOFTWARE\WOW6432Node\Valve\Steam' -ErrorAction SilentlyContinue).InstallPath
    }
    if ($steamPath) {
        $candidates.Add((Join-Path $steamPath 'steamapps\common\Prototype'))
        $vdf = Join-Path $steamPath 'steamapps\libraryfolders.vdf'
        if (Test-Path -LiteralPath $vdf) {
            foreach ($m in [regex]::Matches((Get-Content -LiteralPath $vdf -Raw), '"path"\s+"([^"]+)"')) {
                $root = $m.Groups[1].Value -replace '\\\\', '\'
                $candidates.Add((Join-Path $root 'steamapps\common\Prototype'))
            }
        }
    }
    foreach ($c in $candidates) { if (Test-Path -LiteralPath $c) { return $c } }
    return $null
}

# ---------- 0. 解析与校验 ----------
Write-Step '解析路径与前置检查'

if (-not (Test-Path -LiteralPath $PatchRoot)) { throw "PatchRoot 不存在: $PatchRoot" }
$patchRootItem = Get-Item -LiteralPath $PatchRoot

$optDir = Get-ChildItem -LiteralPath $PatchRoot -Directory | Where-Object { $_.Name -like '*优化文件*' } | Select-Object -First 1
$hanhuaDir = Get-ChildItem -LiteralPath $PatchRoot -Directory | Where-Object { $_.Name -like '*汉化文件*' } | Select-Object -First 1
if (-not $optDir) { throw "在 $PatchRoot 下找不到「优化文件」目录" }
if (-not $hanhuaDir) { throw "在 $PatchRoot 下找不到「汉化文件」目录" }
$payloadDir = Join-Path $hanhuaDir.FullName '汉化文件'
$toolDir = Join-Path $hanhuaDir.FullName '解包rcf工具'
if (-not (Test-Path -LiteralPath $payloadDir)) { throw "找不到汉化文件目录: $payloadDir" }
if (-not (Test-Path -LiteralPath $toolDir)) { throw "找不到解包工具目录: $toolDir" }
Write-Plan "补丁根目录: $($patchRootItem.FullName)"
Write-Plan "汉化文件数: $((Get-ChildItem -LiteralPath $payloadDir -Recurse -File -Force).Count)"

if (-not $GameDir) { $GameDir = Resolve-SteamGameDir }
if (-not $GameDir -or -not (Test-Path -LiteralPath $GameDir)) { throw '找不到游戏目录，请用 -GameDir 指定' }
$GameDir = (Get-Item -LiteralPath $GameDir).FullName
Write-Plan "游戏目录: $GameDir"

$already = $unpackedDirs | Where-Object { Test-Path -LiteralPath (Join-Path $GameDir $_) }
if ($already) {
    throw "游戏目录已存在 $($already -join ', ') 文件夹，说明已经打过这个汉化。请先用 references/install-procedure.md 的回退步骤或 Steam「验证游戏文件完整性」还原成纯净英文版。"
}
$missing = $requiredRcf | Where-Object { -not (Test-Path -LiteralPath (Join-Path $GameDir $_)) }
if ($missing) { throw "游戏目录缺少原版包: $($missing -join ', ') —— 请确认是纯净英文原版且 Steam 已完整下载" }
if (-not (Test-Path -LiteralPath (Join-Path $env:USERPROFILE 'Documents\Prototype'))) {
    Write-Warning '没有发现 Documents\Prototype，说明可能还没启动过英文版游戏。建议先启动一次英文版再打补丁。'
}

if (-not $Apply) {
    Write-Host "`n*** DRY-RUN：以下内容只是预演，不会改动任何文件。加 -Apply 才会执行。***" -ForegroundColor Yellow
}

# ---------- 1. 备份 ----------
Write-Step '1/5 备份会被覆盖的原文件'
Invoke-Do "创建备份目录 $BackupDir" { New-Item -ItemType Directory -Path $BackupDir -Force | Out-Null }
foreach ($f in $looseFiles) {
    $src = Join-Path $GameDir $f
    if (Test-Path -LiteralPath $src) {
        Invoke-Do "备份 $f" { Copy-Item -LiteralPath $src -Destination (Join-Path $BackupDir $f) -Force }
    }
}
Invoke-Do '导出 .rcf 清单到 rcf-inventory.csv' {
    Get-ChildItem -LiteralPath $GameDir -Filter *.rcf |
        Select-Object Name, Length, LastWriteTime |
        Export-Csv -LiteralPath (Join-Path $BackupDir 'rcf-inventory.csv') -NoTypeInformation -Encoding UTF8
}

# ---------- 2. 优化文件 ----------
if (-not $SkipOptimization) {
    Write-Step '2/5 覆盖优化文件并给 prototypef.exe 打补丁'
    Invoke-Do '复制优化文件到游戏目录' {
        Get-ChildItem -LiteralPath $optDir.FullName -File | Copy-Item -Destination $GameDir -Force
    }
    Invoke-Do '运行 ApplyGameLaunchFix.bat（xdelta 补丁，自动备份 prototypef.exe）' {
        $line = 'cd /d "' + $GameDir + '" && ApplyGameLaunchFix.bat < nul'
        $out = cmd.exe /c $line 2>&1
        $out | ForEach-Object { Write-Host "     $_" }
        if ($out -notmatch 'Patch applied successfully') { throw 'xdelta 补丁未成功，请检查上方输出' }
    }
    foreach ($f in $patchLeftovers) {
        $p = Join-Path $GameDir $f
        if (Test-Path -LiteralPath $p) { Invoke-Do "删除 $f" { Remove-Item -LiteralPath $p -Force } }
    }
} else {
    Write-Step '2/5 跳过优化文件（-SkipOptimization）'
}

# ---------- 3. 解包 rcf ----------
Write-Step '3/5 解包 8 个 .rcf（约 7.3 GB，1 分钟左右）'
Invoke-Do '复制 ScarfaceExtractor.exe 与 解包rcf.bat 到游戏目录' {
    Copy-Item -LiteralPath (Join-Path $toolDir 'ScarfaceExtractor.exe') -Destination $GameDir -Force
    Copy-Item -LiteralPath (Join-Path $toolDir '解包rcf.bat') -Destination $GameDir -Force
}
Invoke-Do '运行 解包rcf.bat（输入 1）' {
    $line = 'cd /d "' + $GameDir + '" && 解包rcf.bat'
    $out = '1' | cmd.exe /c $line 2>&1
    $out | ForEach-Object { Write-Host "     $_" }
    $log = Join-Path $GameDir 'extraction_log.txt'
    if (-not (Test-Path -LiteralPath $log)) { throw '没有生成 extraction_log.txt，解包可能失败' }
    $okCount = ([regex]::Matches((Get-Content -LiteralPath $log -Raw), '提取完成')).Count
    Write-Host "     解包成功标记数: $okCount / 8"
    if ($okCount -lt 8) { throw '解包不完整，请检查 extraction_log.txt' }
}

# ---------- 4. 覆盖汉化文件 ----------
Write-Step '4/5 覆盖汉化文件（14511 个同名文件，约 5 分钟）'
Invoke-Do '把汉化文件合并复制进游戏目录' {
    $null = robocopy $payloadDir $GameDir /E /NFL /NDL /NJH /NP /R:1 /W:1
    if ($LASTEXITCODE -ge 8) { throw "robocopy 失败，退出码 $LASTEXITCODE" }
    $s = Get-FileHash -LiteralPath (Join-Path $GameDir 'prototypeenginef.dll') -Algorithm SHA256
    $t = Get-FileHash -LiteralPath (Join-Path $payloadDir 'prototypeenginef.dll') -Algorithm SHA256
    if ($s.Hash -ne $t.Hash) { throw 'prototypeenginef.dll 未正确替换' }
    Write-Host '     prototypeenginef.dll 校验一致'
}

# ---------- 5. 清理 ----------
Write-Step '5/5 移出必须移除的 11 个文件（不移出游戏起不来）'
$removedDir = Join-Path $BackupDir 'removed-from-gamedir'
Invoke-Do "创建 $removedDir" { New-Item -ItemType Directory -Path $removedDir -Force | Out-Null }
foreach ($f in $cleanupFiles) {
    $src = Join-Path $GameDir $f
    if (Test-Path -LiteralPath $src) {
        Invoke-Do "移出 $f" { Move-Item -LiteralPath $src -Destination (Join-Path $removedDir $f) -Force }
    } else {
        Write-Plan "$f 不存在，跳过"
    }
}

Write-Step '完成'
if ($Apply) {
    Write-Host '汉化已安装。请用 Steam 启动游戏，主菜单应为：主菜单 / 新游戏 /【继续游戏】/ 选项 / 额外 / 退出。' -ForegroundColor Green
    Write-Host '提醒玩家：字幕默认关闭，需要在选项里手动开启，并把字幕延迟设为 32M。' -ForegroundColor Green
    Write-Host "备份位置: $BackupDir（含 removed-from-gamedir\ 里的 8 个原始 .rcf.备份）"
} else {
    Write-Host '以上为预演结果。确认无误后加 -Apply 重新运行。' -ForegroundColor Yellow
}
