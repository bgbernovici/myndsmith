# Remember project path
$project_path = $pwd.Path

# Go to the root where vcpkg is installed (usually C:\)
Set-Location \vcpkg

# install pkgconf
.\vcpkg install pkgconf --triplet x64-windows --no-print-usage
$env:Path += ';' + $pwd.Path + '\installed\x64-windows\tools\pkgconf\'                
$env:PKG_CONFIG_PATH = '' + $pwd.Path + '\installed\x64-windows\lib\pkgconfig\'

# Install SDL
.\vcpkg install sdl2[core, vulkan]
.\vcpkg install sdl2-image
.\vcpkg install sdl2-mixer
.\vcpkg install sdl2-ttf
.\vcpkg install bgfx

# Generate Windows headers
$includedir_sdl2 = (pkgconf --variable includedir SDL2).Trim()
$includedir_sdl2_image = (pkgconf --variable includedir SDL2_image).Trim()
$includedir_sdl2_mixer = (pkgconf --variable includedir SDL2_mixer).Trim()
$includedir_sdl2_ttf = (pkgconf --variable includedir SDL2_ttf).Trim()

# Create symbolic link
$real_bgfx = $includedir_sdl2 + '/bx'
$sym_bgfx = $includedir_sdl2 + '/bgfx/c99/bx'
Write-Output $real_bgfx 
Write-Output $sym_bgfx 
# New-Item -ItemType Directory -Path $sym_bgfx
New-Item -ItemType SymbolicLink -Path $sym_bgfx -Value $real_bgfx


Write-Output $includedir_sdl2
Write-Output $includedir_sdl2_image
Write-Output $includedir_sdl2_mixer
Write-Output $includedir_sdl2_ttf
# Go back to the project folder
Set-Location $project_path

$PSDefaultParameterValues['Out-File:Encoding'] = 'utf8'
Write-Output ('#include "' + $includedir_sdl2 + '/SDL2/SDL.h"') > Sources/RAW_SDL2/win_gen.h
Write-Output ('#include "' + $includedir_sdl2 + '/SDL2/SDL_vulkan.h"') >> Sources/RAW_SDL2/win_gen.h
Write-Output ('#include "' + $includedir_sdl2 + '/SDL2/SDL_syswm.h"') >> Sources/RAW_SDL2/win_gen.h
Write-Output ('#include "' + $includedir_sdl2_image + '/SDL2/SDL_image.h"') > Sources/RAW_SDL2_IMAGE/win_gen.h
Write-Output ('#include "' + $includedir_sdl2_mixer + '/SDL2/SDL_mixer.h"') > Sources/RAW_SDL2_MIXER/win_gen.h
Write-Output ('#include "' + $includedir_sdl2_ttf + '/SDL2/SDL_ttf.h"') > Sources/RAW_SDL2_TTF/win_gen.h
Write-Output ('#ifndef BGFX_PLATFORM_C99_H_HEADER_GUARD') > Sources/RAW_BGFX/win_gen.h
Write-Output ('#define BGFX_PLATFORM_C99_H_HEADER_GUARD') >> Sources/RAW_BGFX/win_gen.h
Write-Output ('#include "' + $includedir_sdl2 + '/bgfx/c99/bgfx.h"') >> Sources/RAW_BGFX/win_gen.h
Write-Output ('#endif') >> Sources/RAW_BGFX/win_gen.h

# Remove previous builds
Remove-Item -Path .\.build -Recurse

# Copy SDL libraries into the build folder
$bindir_sdl2 = ((pkgconf --variable exec_prefix SDL2).Trim() + "/bin")
$libdir_sdl2 = (pkgconf --variable libdir SDL2).Trim()

$bindir_sdl2_image = ((pkgconf --variable exec_prefix SDL2_image).Trim() + "/bin")
$libdir_sdl2_image = (pkgconf --variable libdir SDL2_image).Trim()

$bindir_sdl2_mixer = ((pkgconf --variable exec_prefix SDL2_mixer).Trim() + "/bin")
$libdir_sdl2_mixer = (pkgconf --variable libdir SDL2_mixer).Trim()

$bindir_sdl2_ttf = ((pkgconf --variable exec_prefix SDL2_ttf).Trim() + "/bin")
$libdir_sdl2_ttf = (pkgconf --variable libdir SDL2_ttf).Trim()

mkdir .build\x86_64-unknown-windows-msvc\debug
foreach ($config in "debug", "release") {
    $path = ".build/x86_64-unknown-windows-msvc/$config"
    Copy-Item ($bindir_sdl2 + '/SDL2.dll') $path
    Copy-Item ($libdir_sdl2 + '/SDL2.lib') $path

    Copy-Item ($bindir_sdl2_image + '/SDL2_image.dll') $path
    Copy-Item ($libdir_sdl2_image + '/SDL2_image.lib') $path

    Copy-Item ($bindir_sdl2_mixer + '/SDL2_mixer.dll') $path
    Copy-Item ($libdir_sdl2_mixer + '/SDL2_mixer.lib') $path

    Copy-Item ($bindir_sdl2_ttf + '/SDL2_ttf.dll') $path
    Copy-Item ($libdir_sdl2_ttf + '/SDL2_ttf.lib') $path

    Copy-Item ($libdir_sdl2_ttf + '/bgfx.lib') $path
    Copy-Item ($libdir_sdl2_ttf + '/bx.lib') $path
    Copy-Item ($libdir_sdl2_ttf + '/bimg.lib') $path
    Copy-Item ($libdir_sdl2_ttf + '/bimg_encode.lib') $path
    Copy-Item ($libdir_sdl2_ttf + '/bimg_decode.lib') $path
}

# Build
swift build 

# Test
swift test

Write-Output "Configuration done."
