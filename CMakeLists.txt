cmake_minimum_required(VERSION 3.15)
project(OpenGLProject VERSION 1.0.0)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_EXPORT_COMPILE_COMMANDS ON)

# ============================================
# Performance Optimizations
# ============================================

# Enable compiler cache if available (ccache/sccache)
find_program(CCACHE_PROGRAM ccache)
find_program(SCCACHE_PROGRAM sccache)

if(SCCACHE_PROGRAM)
    set(CMAKE_CXX_COMPILER_LAUNCHER "${SCCACHE_PROGRAM}")
    set(CMAKE_C_COMPILER_LAUNCHER "${SCCACHE_COMPILER_LAUNCHER}")
    message(STATUS "Using sccache for faster builds")
elseif(CCACHE_PROGRAM)
    set(CMAKE_CXX_COMPILER_LAUNCHER "${CCACHE_PROGRAM}")
    set(CMAKE_C_COMPILER_LAUNCHER "${CCACHE_PROGRAM}")
    message(STATUS "Using ccache for faster builds")
    
    # Configure ccache for optimal performance
    set(ENV{CCACHE_COMPRESS} "true")
    set(ENV{CCACHE_COMPRESSLEVEL} "6")
    set(ENV{CCACHE_MAXSIZE} "1G")
else()
    message(STATUS "No compiler cache found - install ccache for 30x faster rebuilds")
endif()

# ============================================
# Custom Output Directories
# ============================================

# Your app goes to app/ folder
set(CMAKE_RUNTIME_OUTPUT_DIRECTORY ${CMAKE_SOURCE_DIR}/app)

# CMake metadata stays in build/ folder (this is automatic when you run cmake -B build)

# Enable parallel compilation
if(MSVC)
    add_compile_options(/MP)
    message(STATUS "MSVC: Enabled parallel compilation")
endif()

# ============================================
# FetchContent: Store dependencies in includes/
# ============================================
include(FetchContent)

# Store all external dependencies in includes/ folder
set(FETCHCONTENT_BASE_DIR "${CMAKE_SOURCE_DIR}/includes")

# ============================================
# Auto-fetch GLFW
# ============================================
set(GLFW_BUILD_DOCS OFF CACHE BOOL "" FORCE)
set(GLFW_BUILD_TESTS OFF CACHE BOOL "" FORCE)
set(GLFW_BUILD_EXAMPLES OFF CACHE BOOL "" FORCE)
set(GLFW_INSTALL OFF CACHE BOOL "" FORCE)

FetchContent_Declare(
    glfw
    GIT_REPOSITORY https://github.com/glfw/glfw.git
    GIT_TAG 3.4
    GIT_SHALLOW TRUE
)

FetchContent_MakeAvailable(glfw)

# Force GLFW libraries to stay in includes/
set_target_properties(glfw PROPERTIES
    ARCHIVE_OUTPUT_DIRECTORY "${CMAKE_SOURCE_DIR}/includes/glfw-build"
    LIBRARY_OUTPUT_DIRECTORY "${CMAKE_SOURCE_DIR}/includes/glfw-build"
    RUNTIME_OUTPUT_DIRECTORY "${CMAKE_SOURCE_DIR}/includes/glfw-build"
)

# ============================================
# Auto-fetch GLAD (manual build required)
# ============================================
FetchContent_Declare(
    glad_content
    GIT_REPOSITORY https://github.com/premake-libs/glad.git
    GIT_TAG master
)

# Use the modern approach - avoid deprecated FetchContent_Populate
FetchContent_GetProperties(glad_content)
if(NOT glad_content_POPULATED)
    # Set policy to suppress warning during transition period
    if(POLICY CMP0169)
        cmake_policy(SET CMP0169 OLD)
    endif()
    
    FetchContent_Populate(glad_content)
    
    # Build GLAD as a static library
    add_library(glad_lib STATIC
        ${glad_content_SOURCE_DIR}/src/glad.c
    )
    
    target_include_directories(glad_lib PUBLIC
        ${glad_content_SOURCE_DIR}/include
    )
    
    # Force GLAD libraries to stay in includes/
    set_target_properties(glad_lib PROPERTIES
        ARCHIVE_OUTPUT_DIRECTORY "${CMAKE_SOURCE_DIR}/includes/glad-build"
        LIBRARY_OUTPUT_DIRECTORY "${CMAKE_SOURCE_DIR}/includes/glad-build"
        RUNTIME_OUTPUT_DIRECTORY "${CMAKE_SOURCE_DIR}/includes/glad-build"
    )
endif()

# ============================================
# Main Executable - Goes to app/ folder
# ============================================
add_executable(${PROJECT_NAME} 
    src/main.cpp
)

# Link libraries
target_link_libraries(${PROJECT_NAME} 
    PRIVATE
        glad_lib
        glfw
)

# ============================================
# Platform-Specific Configuration
# ============================================
if(APPLE)
    target_link_libraries(${PROJECT_NAME}
        PRIVATE
            "-framework OpenGL"
            "-framework Cocoa"
            "-framework IOKit"
            "-framework CoreVideo"
    )
elseif(WIN32)
    target_link_libraries(${PROJECT_NAME}
        PRIVATE
            opengl32
            gdi32
    )
elseif(UNIX AND NOT APPLE)
    target_link_libraries(${PROJECT_NAME}
        PRIVATE
            GL
            X11
            pthread
            Xrandr
            Xi
            dl
    )
endif()

# ============================================
# Build Information
# ============================================
message(STATUS "===================================")
message(STATUS "OpenGL Project Configuration")
message(STATUS "===================================")
message(STATUS "Version: ${PROJECT_VERSION}")
message(STATUS "C++ Standard: ${CMAKE_CXX_STANDARD}")
message(STATUS "Build Type: ${CMAKE_BUILD_TYPE}")
message(STATUS "Compiler: ${CMAKE_CXX_COMPILER_ID}")
message(STATUS "Generator: ${CMAKE_GENERATOR}")
message(STATUS "Dependencies: includes/ (source + libs)")
message(STATUS "Your app: app/")
message(STATUS "CMake metadata: build/")
message(STATUS "===================================")