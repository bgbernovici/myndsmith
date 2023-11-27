# myndsmith
Experimental Swift wrapper around the [SDL2][1] ecosystem (SDL2, SDL2_TTF, SDL2_Mixer, SDL2_Image) and [BGFX][2]. The motivation behind this wrapper is to control the SDL2 library from Swift, providing a cross-platform solution for window management, low-level access to peripherals, and graphics hardware via OpenGL and Direct3D. Additionally, when more advanced shaders are required, the SDL2 window and peripheral control API can be used in tandem with BGFX. BGFX is a middleware graphics abstraction layer with its own language for building shaders. Currently, the wrapper has the bare essentials to run the demos, and it compiles only on Windows for now. The `SampleSDL2` demo features what I assume to be an idiomatic Swift wrapper around SDL2, while `SampleBGFX` mostly calls the C functions directly, with a couple of BX utility functions ported from C++.

## Setup
* Package has been compiled and tested on Windows 11
* Install Swift toolchain. For Windows consult: https://www.swift.org/blog/swift-on-windows/
* Enable Developer mode from Settings
* Install `vcpkg`, preferably in `C:\vcpkg`: https://vcpkg.io/en/getting-started.html
* Run `execute_me.ps1` Powershell script as Administrator (required to create symbolic links)
* Double-check everything is in place with `swift test`
* `swift run SampleSDL2`
* `swift run SampleBGFX`

[1]: https://www.libsdl.org/
[2]: https://github.com/bkaradzic/bgfx

## Demo
### SDL2 + SDL_TTF + SDL_Image sample
![](https://github.com/bgbernovici/myndsmith/blob/main/demos/sdl2_demo.gif)
### SDL2 + BGFX sample (OpenGL backend)
![](https://github.com/bgbernovici/myndsmith/blob/main/demos/bgfx_demo.gif)
