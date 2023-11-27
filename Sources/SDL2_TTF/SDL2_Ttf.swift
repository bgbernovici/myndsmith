@_exported import RAW_SDL2_TTF
import SDL2

enum SDLTTFError: Error {
    case initFailed
}

enum SDLFontError: Error {
    case initFailed
    case surfaceCreationFailed
}

public class SDLTTF {

    public init(_ doOnError: @escaping () -> Void = {}) throws {
        guard TTF_Init() == 0 else {
            doOnError()
            throw SDLTTFError.initFailed
        }
    }

    deinit {
        TTF_Quit()
    }
}


public class Font {
    public typealias TTF_Font = OpaquePointer
    public let instance: TTF_Font?

    public init(_ path: String, _ size: Int32) throws {
         self.instance = TTF_OpenFont(path, size)
         guard instance != nil else {
            throw SDLFontError.initFailed
         }
    }

    public var get: TTF_Font {
        return self.instance!
    }

    public func renderTextSolid(_ text: String, _ fg: SDL_Color) throws -> Surface {
        let surface: UnsafeMutablePointer<SDL_Surface>? = TTF_RenderText_Solid(self.instance, text, fg)
        guard surface != nil else {
            throw SDLFontError.surfaceCreationFailed
        }
        return Surface(surface!)
    }
}