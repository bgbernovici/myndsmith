@_exported import RAW_SDL2_IMAGE
import SDL2

enum SDLSurfaceError: Error {
    case initImageFailed
}

extension Surface {
    public convenience init(_ path: String) throws {
        let img: UnsafeMutablePointer<SDL_Surface>! = IMG_Load(path)
        guard img != nil else {
            throw SDLSurfaceError.initImageFailed
        }
        self.init(img)
    }
}