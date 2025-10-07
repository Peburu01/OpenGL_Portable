
# 📋 Instructions

**Step-by-step guide for setup, building, running, and troubleshooting your OpenGL project.**

## 🚀 First Time Setup

### 🪟 Windows

```
# Run setup script (auto-elevates for admin privileges)
.\setup\setup-windows.ps1

# Wait for installation to complete
# Restart VSCode when finished
```

**What gets installed:** CMake, Ninja, MinGW-w64 (GCC), Chocolatey, ccache

### 🍎 macOS

```
# Make script executable
chmod +x setup/setup-macos.sh

# Run setup (will prompt for password once)
./setup/setup-macos.sh
```

**What gets installed:** Homebrew, CMake, Ninja, Xcode Command Line Tools, Git, ccache

### 🐧 Linux

```
# Make script executable
chmod +x setup/setup-linux.sh

# Run setup (will prompt for password once)
./setup/setup-linux.sh
```

**What gets installed:** CMake, Ninja, GCC/G++, Git, ccache, OpenGL development libraries

***

## 🏗️ Building & Running

### ⚡ Quick Method (VSCode)

**Build:**
```
Windows/Linux: Ctrl + Shift + B
macOS:        Cmd + Shift + B
```

**Run:**
Press `F5` and choose:
* **🚀 Build and Run** — Builds then runs
* **▶️ Run Only** — Just runs (fastest)
* **🐛 Debug** — Stops at start for debugging

### 🔧 Manual Method (Terminal)

**Build:**
```
cmake --build build --parallel
```

**Run:**
```
# Windows
./app/OpenGLProject.exe

# macOS / Linux
./app/OpenGLProject
```

***

## 📁 Project Structure

```
YourProject/
├── src/              # Your source code
├── app/              # ✅ Final executable (run from here)
├── includes/         # Downloaded dependencies (GLFW, GLAD, etc.)
├── build/            # CMake build files (metadata only)
└── .vscode/          # VSCode configuration
```

**Where is my app?** → `app/OpenGLProject.exe` (Windows) or `app/OpenGLProject` (macOS/Linux)

***

## 🧹 Clean Build (Start Fresh)

### Method 1: VSCode
1. Press `Ctrl+Shift+P` (Windows/Linux) or `Cmd+Shift+P` (macOS)
2. Type: `Tasks: Run Task`
3. Select: `CMake Clean`
4. Build again: `Ctrl+Shift+B` or `Cmd+Shift+B`

### Method 2: Terminal

**🪟 Windows:**
```
Remove-Item -Recurse -Force build, app, includes
cmake -B build -S . -G Ninja
cmake --build build --parallel
```

**🍎 macOS / 🐧 Linux:**
```
rm -rf build app includes
cmake -B build -S . -G Ninja
cmake --build build --parallel
```

***

## ⚙️ Common Commands

### Configure CMake
```
cmake -B build -S . -G Ninja
```

### Build Only
```
cmake --build build --parallel
```

### Run Your App
```
# Windows
./app/OpenGLProject.exe

# macOS / Linux
./app/OpenGLProject
```

### Clean All Generated Files
```
# Windows
Remove-Item -Recurse -Force build, app, includes

# macOS / Linux
rm -rf build app includes
```

### Check ccache Performance
```
ccache -s
```

***

## 🔧 Fix Red Squiggles in Code

If code shows errors but builds fine:

**🪟 Windows:**
```
Remove-Item -Recurse -Force build
cmake -B build -S . -G Ninja
```

**🍎 macOS / 🐧 Linux:**
```
rm -rf build
cmake -B build -S . -G Ninja
```

Then reload VSCode:
* Press `Ctrl+Shift+P` (or `Cmd+Shift+P` on Mac)
* Type: `Developer: Reload Window`
* Press Enter

***

## ⌨️ Keyboard Shortcuts

| Action | Windows/Linux | macOS |
|--------|--------------|-------|
| Build | `Ctrl+Shift+B` | `Cmd+Shift+B` |
| Run | `F5` | `F5` |
| Stop | `Shift+F5` | `Shift+F5` |
| Command Palette | `Ctrl+Shift+P` | `Cmd+Shift+P` |
| Terminal | `` Ctrl+` `` | `` Cmd+` `` |

***

## 🛠️ Troubleshooting

**❌ "ninja: command not found"**
* Run the setup script again for your platform

**🐌 Build is slow**
* First build takes ~10 seconds (compiling dependencies)
* After that, builds take ~0.5 seconds
* Dependencies are cached in `includes/` folder

**🚫 Program won't run**
* Make sure you built it first: `Ctrl+Shift+B` or `Cmd+Shift+B`
* Check that `app/OpenGLProject.exe` exists

**📁 Where is my executable?**
* Look in the `app/` folder, not `build/`
* `build/` only contains CMake metadata

**🔄 Need to reinstall everything**
* Just run the setup script again
* Or manually delete `build/`, `app/`, and `includes/` folders

**🗂️ Too many folders?**
* `app/` — Your executable (the only thing you need to distribute)
* `includes/` — Downloaded libraries (can be deleted and rebuilt)
* `build/` — CMake files (can be deleted and regenerated)

***

## 📦 Distribution

To share your app with others:

1. Build in Release mode:
   ```
   cmake -B build -S . -G Ninja -DCMAKE_BUILD_TYPE=Release
   cmake --build build --parallel
   ```

2. Your executable is in `app/`:
   - **Windows:** `app/OpenGLProject.exe`
   - **macOS/Linux:** `app/OpenGLProject`

3. Copy the executable from `app/` to distribute

***

**Built with ❤️ for fast, clean, and portable OpenGL development.**