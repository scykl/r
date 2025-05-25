# 保存为 auto_add_r_path.ps1，右键“以管理员身份运行”

# 定义可能存在的根目录（自动探测C盘/D盘）
$searchRoots = @(
    "C:\Program Files\R",
    "D:\Program Files\R"
)

# 自动查找最新R版本路径
$rVersions = foreach ($root in $searchRoots) {
    if (Test-Path $root) {
        Get-ChildItem -Path $root -Directory -Filter "R-*" | 
        Where-Object { $_.Name -match 'R-(\d+\.\d+\.\d+)' } |
        ForEach-Object {
            [PSCustomObject]@{
                Path = $_.FullName
                Version = [version]($matches[1])
            }
        }
    }
}

# 选择最新版本
$latestR = $rVersions | Sort-Object Version -Descending | Select-Object -First 1

if (-not $latestR) {
    Write-Host "错误：未在以下位置发现R语言安装目录：`n$($searchRoots -join "`n")" -ForegroundColor Red
    exit
}

$rBinPath = Join-Path $latestR.Path "bin\x64"  # 自动定位64位bin目录

# 更新环境变量（需要管理员权限）
$currentPath = [Environment]::GetEnvironmentVariable("Path", "Machine")
if ($currentPath -notmatch [regex]::Escape($rBinPath)) {
    [Environment]::SetEnvironmentVariable("Path", "$currentPath;$rBinPath", "Machine")
    Write-Host "✅ 已自动添加最新R路径：$rBinPath" -ForegroundColor Green
    # 刷新当前会话环境变量
    $env:Path = [Environment]::GetEnvironmentVariable("Path", "Machine")
} else {
    Write-Host "⚠️ 路径已存在：$rBinPath" -ForegroundColor Yellow
}
