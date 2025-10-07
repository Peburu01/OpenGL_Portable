# setup-windows.ps1
# Automated setup script for Windows development environment with auto-elevation

# ============================================
# Auto-elevate script if not running as Administrator
# ============================================
if (-Not ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] 'Administrator')) {
    Write-Host "Requesting administrator privileges..." -ForegroundColor Yellow
    
    if ([int](Get-CimInstance -Class Win32_OperatingSystem | Select-Object -ExpandProperty BuildNumber) -ge 6000) {
        $CommandLine = "-NoProfile -ExecutionPolicy Bypass -File `"" + $MyInvocation.MyCommand.Path + "`""
        Start-Process -FilePath PowerShell.exe -Verb Runas -ArgumentList $CommandLine
        Exit
    }
}

# ============================================
# Main Setup Script (runs with admin privileges)
# ============================================

Write-Host "=====================================" -ForegroundColor Cyan
Write-Host "OpenGL Project - Windows Setup" -ForegroundColor Cyan
Write-Host "Running with Administrator privileges" -ForegroundColor Green
Write-Host "=====================================" -ForegroundColor Cyan
Write-Host ""

$needsRestart = $false

# Function to check if a command exists
function Test-Command($command) {
    try {
        if (Get-Command $command -ErrorAction Stop) {
            return $true
        }
    } catch {
        return $false
    }
    return $false
}

# Check and install Winget if needed
Write-Host "Checking package manager..." -ForegroundColor Yellow
if (-not (Test-Command "winget")) {
    Write-Host "ERROR: winget not found. Please install App Installer from Microsoft Store." -ForegroundColor Red
    Write-Host "https://www.microsoft.com/p/app-installer/9nblggh4nns1" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "Press any key to exit..."
    $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
    exit 1
} else {
    Write-Host "[OK] winget is installed" -ForegroundColor Green
}

# Check and install Git
Write-Host "`nChecking Git..." -ForegroundColor Yellow
if (-not (Test-Command "git")) {
    Write-Host "Installing Git..." -ForegroundColor Cyan
    winget install --id Git.Git -e --source winget --accept-package-agreements --accept-source-agreements --silent
    $needsRestart = $true
    Write-Host "[INSTALLED] Git" -ForegroundColor Green
} else {
    Write-Host "[OK] Git is installed" -ForegroundColor Green
}

# Check and install CMake
Write-Host "`nChecking CMake..." -ForegroundColor Yellow
if (-not (Test-Command "cmake")) {
    Write-Host "Installing CMake..." -ForegroundColor Cyan
    winget install --id Kitware.CMake -e --source winget --accept-package-agreements --accept-source-agreements --silent
    $needsRestart = $true
    Write-Host "[INSTALLED] CMake" -ForegroundColor Green
} else {
    $cmakeVersion = cmake --version | Select-Object -First 1
    Write-Host "[OK] $cmakeVersion" -ForegroundColor Green
}

# Check and install Ninja
Write-Host "`nChecking Ninja..." -ForegroundColor Yellow
if (-not (Test-Command "ninja")) {
    Write-Host "Installing Ninja..." -ForegroundColor Cyan
    winget install --id Ninja-build.Ninja -e --source winget --accept-package-agreements --accept-source-agreements --silent
    $needsRestart = $true
    Write-Host "[INSTALLED] Ninja" -ForegroundColor Green
} else {
    $ninjaVersion = ninja --version
    Write-Host "[OK] Ninja $ninjaVersion" -ForegroundColor Green
}

# Check and install MinGW (GCC compiler)
Write-Host "`nChecking C++ Compiler (MinGW)..." -ForegroundColor Yellow
if (-not (Test-Command "gcc") -and -not (Test-Command "g++")) {
    Write-Host "Installing MinGW-w64 (this may take a while)..." -ForegroundColor Cyan
    
    # Download and install MSYS2 which includes MinGW
    Write-Host "Installing MSYS2..." -ForegroundColor Cyan
    winget install --id MSYS2.MSYS2 -e --source winget --accept-package-agreements --accept-source-agreements --silent
    
    Write-Host ""
    Write-Host "IMPORTANT: After script completes, run these commands in MSYS2 terminal:" -ForegroundColor Yellow
    Write-Host "  1. Open MSYS2 from Start Menu" -ForegroundColor Cyan
    Write-Host "  2. Run: pacman -Syu" -ForegroundColor Cyan
    Write-Host "  3. Run: pacman -S mingw-w64-x86_64-gcc mingw-w64-x86_64-gdb" -ForegroundColor Cyan
    Write-Host "  4. Add to PATH: C:\msys64\mingw64\bin" -ForegroundColor Cyan
    Write-Host ""
    
    $needsRestart = $true
} elseif (Test-Command "gcc") {
    $gccVersion = gcc --version | Select-Object -First 1
    Write-Host "[OK] $gccVersion" -ForegroundColor Green
} elseif (Test-Command "cl") {
    Write-Host "[OK] MSVC compiler is installed" -ForegroundColor Green
}

# Check and install Chocolatey (for ccache)
Write-Host "`nChecking Chocolatey (for ccache)..." -ForegroundColor Yellow
if (-not (Test-Command "choco")) {
    Write-Host "Installing Chocolatey..." -ForegroundColor Cyan
    Set-ExecutionPolicy Bypass -Scope Process -Force
    [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072
    
    try {
        Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
        Write-Host "[INSTALLED] Chocolatey" -ForegroundColor Green
        $needsRestart = $true
        
        # Refresh PATH for current session
        $env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")
    } catch {
        Write-Host "[WARNING] Failed to install Chocolatey: $_" -ForegroundColor Yellow
    }
} else {
    Write-Host "[OK] Chocolatey is installed" -ForegroundColor Green
}

# Check and install ccache (build speedup)
Write-Host "`nChecking ccache (build speedup)..." -ForegroundColor Yellow
if (-not (Test-Command "ccache")) {
    if (Test-Command "choco") {
        Write-Host "Installing ccache via Chocolatey..." -ForegroundColor Cyan
        
        try {
            choco install ccache -y --force
            Write-Host "[INSTALLED] ccache - rebuilds will be 30x faster!" -ForegroundColor Green
            $needsRestart = $true
        } catch {
            Write-Host "[WARNING] Failed to install ccache: $_" -ForegroundColor Yellow
            Write-Host "[INFO] You can manually install from: https://ccache.dev/download.html" -ForegroundColor Gray
        }
    } else {
        Write-Host "[SKIP] Chocolatey not available - cannot install ccache" -ForegroundColor Yellow
        Write-Host "[INFO] You can manually install from: https://ccache.dev/download.html" -ForegroundColor Gray
    }
} else {
    $ccacheVersion = ccache --version | Select-Object -First 1
    Write-Host "[OK] $ccacheVersion" -ForegroundColor Green
}

# Summary
Write-Host "`n=====================================" -ForegroundColor Cyan
Write-Host "Setup Complete!" -ForegroundColor Green
Write-Host "=====================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Installed Tools:" -ForegroundColor Yellow
Write-Host "  - Git (version control)" -ForegroundColor White
Write-Host "  - CMake (build system)" -ForegroundColor White
Write-Host "  - Ninja (fast build tool)" -ForegroundColor White
Write-Host "  - MinGW/GCC (C++ compiler)" -ForegroundColor White
if (Test-Command "ccache") {
    Write-Host "  - ccache (30x faster rebuilds)" -ForegroundColor White
} else {
    Write-Host "  - ccache (optional - install manually)" -ForegroundColor Yellow
}

if ($needsRestart) {
    Write-Host ""
    Write-Host "ACTION REQUIRED:" -ForegroundColor Yellow
    Write-Host "1. Close and reopen PowerShell/VSCode" -ForegroundColor Yellow
    Write-Host "2. Verify installations:" -ForegroundColor Yellow
    Write-Host "   - cmake --version" -ForegroundColor Gray
    Write-Host "   - ninja --version" -ForegroundColor Gray
    Write-Host "   - gcc --version" -ForegroundColor Gray
    Write-Host "   - ccache --version (if installed)" -ForegroundColor Gray
    Write-Host "3. Press Ctrl+Shift+B in VSCode to build" -ForegroundColor Yellow
} else {
    Write-Host ""
    Write-Host "Ready to build! Press Ctrl+Shift+B in VSCode" -ForegroundColor Green
}

Write-Host ""
Write-Host "Press any key to exit..."
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
