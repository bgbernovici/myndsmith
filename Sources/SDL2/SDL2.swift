@_exported import RAW_SDL2

enum SDLError: Error {
    case initFailed
}

enum SDLRenderError: Error {
    case clearFailed
    case copyFailed
}

enum SDLSurfaceError: Error {

}

public struct SDLRendererFlags: OptionSet {
    public let rawValue: UInt32

    public init(rawValue: UInt32) {
        self.rawValue = rawValue
    }

    public static let software = SDLRendererFlags(rawValue: 0x00000001)
    public static let accelerated = SDLRendererFlags(rawValue: 0x00000002)
    public static let presentVSync = SDLRendererFlags(rawValue: 0x00000004)
    public static let targetTexture = SDLRendererFlags(rawValue: 0x00000008)
}

public struct SDLWindowFlags: OptionSet {
    public let rawValue: UInt32

    public init(rawValue: UInt32) {
        self.rawValue = rawValue
    }

    public static let fullscreen = SDLWindowFlags(rawValue: 0x00000001)
    public static let openGL = SDLWindowFlags(rawValue: 0x00000002)
    public static let shown = SDLWindowFlags(rawValue: 0x00000004)
    public static let hidden = SDLWindowFlags(rawValue: 0x00000008)
    public static let borderless = SDLWindowFlags(rawValue: 0x00000010)
    public static let resizable = SDLWindowFlags(rawValue: 0x00000020)
    public static let minimized = SDLWindowFlags(rawValue: 0x00000040)
    public static let maximized = SDLWindowFlags(rawValue: 0x00000080)
    public static let mouseGrabbed = SDLWindowFlags(rawValue: 0x00000100)
    public static let inputFocus = SDLWindowFlags(rawValue: 0x00000200)
    public static let mouseFocus = SDLWindowFlags(rawValue: 0x00000400)
    public static let fullscreenDesktop = SDLWindowFlags(rawValue: 0x00001000 | SDLWindowFlags.fullscreen.rawValue)
    public static let foreign = SDLWindowFlags(rawValue: 0x00000800)
    public static let allowHighDPI = SDLWindowFlags(rawValue: 0x00002000)
    public static let mouseCapture = SDLWindowFlags(rawValue: 0x00004000)
    public static let alwaysOnTop = SDLWindowFlags(rawValue: 0x00008000)
    public static let skipTaskbar = SDLWindowFlags(rawValue: 0x00010000)
    public static let utility = SDLWindowFlags(rawValue: 0x00020000)
    public static let tooltip = SDLWindowFlags(rawValue: 0x00040000)
    public static let popupMenu = SDLWindowFlags(rawValue: 0x00080000)
    public static let keyboardGrabbed = SDLWindowFlags(rawValue: 0x00100000)
    public static let vulkan = SDLWindowFlags(rawValue: 0x10000000)
    public static let metal = SDLWindowFlags(rawValue: 0x20000000)

    static let inputGrabbed = SDLWindowFlags(rawValue: SDLWindowFlags.mouseGrabbed.rawValue) // equivalent to SDL_WINDOW_MOUSE_GRABBED for compatibility
}

public enum SDLWindowPosition {
    case undefinedMask
    case centeredMask
    case undefined(displayIndex: Int32)
    case centered(displayIndex: Int32)

    var rawValue: UInt32 {
        switch self {
        case .undefinedMask:
            return 0x1FFF0000
        case .centeredMask:
            return 0x2FFF0000
        case .undefined(let displayIndex):
            return SDLWindowPosition.undefinedMask.rawValue | UInt32(displayIndex)
        case .centered(let displayIndex):
            return SDLWindowPosition.centeredMask.rawValue | UInt32(displayIndex)
        }
    }

    static func isUndefined(_ position: UInt32) -> Bool {
        return (position & 0xFFFF0000) == SDLWindowPosition.undefinedMask.rawValue
    }

    static func isCentered(_ position: UInt32) -> Bool {
        return (position & 0xFFFF0000) == SDLWindowPosition.centeredMask.rawValue
    }
}

public class SDL {

    public init(_ flags: UInt32, _ doOnError: @escaping () -> Void = {}) throws {
        guard SDL_Init(flags) == 0 else {
            doOnError()
            throw SDLError.initFailed
        }
    }

    public func pollEvent(_ event: UnsafeMutablePointer<SDL_Event>!) -> Int32 {
        return SDL_PollEvent(event) 
    }

    deinit {
        SDL_Quit()
    }
}

public class Window {

        private var instance: OpaquePointer?

        public init(_ title: UnsafePointer<CChar>!, 
        _ x: SDLWindowPosition, 
        _ y: SDLWindowPosition, 
        _ w: Int32, 
        _ h: Int32,
        _ flags: SDLWindowFlags,
        _ doOnSuccess: @escaping () -> Void = {},
        _ doOnError: @escaping () -> Void = {}) {
            self.instance = SDL_CreateWindow(title, Int32(x.rawValue), Int32(y.rawValue), w, h, flags.rawValue)
            if self.instance == nil { 
                doOnError()
               
            } else {
                doOnSuccess()
            }
        }

        public var get: OpaquePointer? {
            return self.instance
        }

        deinit {
            if instance != nil {
                SDL_DestroyWindow(instance)
            }
        }
}

public class Renderer {
        private var instance: OpaquePointer?

        public init(_ window: Window,
             _ index: Int32, 
             _ flags: SDLRendererFlags,
             _ doOnSuccess: @escaping () -> Void = {},
             _ doOnError: @escaping () -> Void = {}) {
            self.instance = SDL_CreateRenderer(window.get, index, flags.rawValue)
            if self.instance == nil {
                doOnError()
            } else {
                doOnSuccess()
            }
        }

        public var get: OpaquePointer? {
            return self.instance
        }

        deinit {
            if instance != nil {
                SDL_DestroyRenderer(instance)   
            }     
        }

        public func clear() throws -> Renderer {
            if SDL_RenderClear(self.get) != 0 {
                throw SDLRenderError.clearFailed
            }
            return self
        }

        public func copy(_ texture: Texture, _ srcrect: Rect? = nil, _ dstrect: Rect? = nil) throws {
            
            let pointerSrcrect: UnsafeMutablePointer<SDL_Rect> = UnsafeMutablePointer<SDL_Rect>.allocate(capacity: 1)
            let pointerDstrect: UnsafeMutablePointer<SDL_Rect> = UnsafeMutablePointer<SDL_Rect>.allocate(capacity: 1)
            
            defer {
                pointerSrcrect.deinitialize(count: 1)
                pointerDstrect.deinitialize(count: 1)
                pointerSrcrect.deallocate()
                pointerDstrect.deallocate()
            }

            if SDL_RenderCopy(
                        self.get, texture.get, 
                        srcrect?.getPointer(vesselPointer: pointerSrcrect), 
                        dstrect?.getPointer(vesselPointer: pointerDstrect)) != 0 {
                        throw SDLRenderError.copyFailed
            }
        }

        public func present() -> Renderer {
            SDL_RenderPresent(self.get);
	        return self
        }
}

public class Surface {
    // typealias SDL_Surface = OpaquePointer

    public var instance: SDL_Surface

    public init(_ surface: SDL_Surface) {
        self.instance = surface
    }

    public init(_ surface: UnsafeMutablePointer<SDL_Surface>) {
        self.instance = surface.pointee
    }

    public var get: UnsafeMutablePointer<SDL_Surface> {
        return withUnsafeMutablePointer(to: &instance) {
            UnsafeMutablePointer<SDL_Surface>($0)
        }
    }

    deinit {
        self.get.deinitialize(count: 1)
    }
}

public class Texture {
    
    /**
        * An efficient driver-specific representation of pixel data
    */
    public typealias SDL_Texture = OpaquePointer

    private let instance: SDL_Texture

    public init(_ texture: SDL_Texture) {
        self.instance = texture
    }

    public init(_ renderer: Renderer, _ surface: Surface) {
        self.instance = SDL_CreateTextureFromSurface(renderer.get, surface.get)
    }

    public var get: SDL_Texture {
        return instance
    }
}

public struct Rect {

    private var instance: SDL_Rect

    public var get: SDL_Rect {
        return instance
    }

    public func getPointer(vesselPointer: UnsafeMutablePointer<SDL_Rect>) ->  UnsafeMutablePointer<SDL_Rect>{
        vesselPointer.initialize(to: self.get)
        return vesselPointer
    }
     
    public init() {
        self.instance = SDL_Rect(x: 0, y: 0, w: 0, h: 0)
    }

    public init(_ rect: Rect) {
        self.instance = SDL_Rect(x: rect.x, y: rect.y, w: rect.width, h: rect.height)
    }

    public init(_ x: Int32, _ y: Int32, _ width: Int32, _ height: Int32) {
        self.instance = SDL_Rect(x: x, y: y, w: width, h: height)
    }

    public var x: Int32 {
        return instance.x
    }

    public var y: Int32 {
        return instance.y
    }

    public var width: Int32 {
        return instance.w
    }

    public var height: Int32 {
        return instance.h
    }

    public func setX(newX: Int32) -> Rect {
        return Rect(newX, self.y, self.width, self.height)
    }

    public func setY(newY: Int32) ->  Rect {
        return Rect(self.x, newY, self.width, self.height)
    }

    public func setWidth(newWidth: Int32) ->  Rect {
        return Rect(self.x, self.y, newWidth, self.height)
    }

    public func setHeight(newHeight: Int32) ->  Rect {
        return Rect(self.x, self.y, self.width, newHeight)
    }
}