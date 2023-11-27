@testable import SDL2
@testable import SDL2_TTF
@testable import SDL2_Image
@testable import SDL2_Mixer
@testable import BGFX

import XCTest

final class SDLTests: XCTestCase {
    func testVersion() {
        var compiled = SDL_version()
        compiled.major = Uint8(SDL_MAJOR_VERSION)
        compiled.minor = Uint8(SDL_MINOR_VERSION)
        compiled.patch = Uint8(SDL_PATCHLEVEL)

        var linked = SDL_version()
        print(SDL_GetVersion(&linked))
    }

    func testAPIAvailability() {
        XCTAssertNotNil(SDL_Init.self)
        XCTAssertNotNil(SDL_CreateWindow.self)
        XCTAssertNotNil(SDL_DestroyWindow.self)
        XCTAssertNotNil(SDL_Quit.self)
    }

    func testKeyCodeAvailability() {
        XCTAssertNotNil(SDL_KeyCode.self)
    }

    func testTTF() {
        XCTAssertNotNil(TTF_Init.self)
    }

    func testImage() {
        XCTAssertNotNil(IMG_Init.self)
    }

    func testMixer() {
        XCTAssertNotNil(Mix_Init.self)
    }

    func testBGFX() {
        XCTAssertNotNil(bgfx_init.self)
    }
}