import SDL2
import SDL2_TTF
import SDL2_Image
import Foundation

let sdlInstance = try SDL(SDL_INIT_VIDEO, {
    fatalError("SDL could not initialize! SDL_Error: \(String(cString: SDL_GetError()))")})

let ttfInstance: SDLTTF = try SDLTTF({
    fatalError("SDL_TTF could not initialize! SDL_TTF_Error: \(String(cString: SDL_GetError()))")})

let window = Window( 
    "Swifty SDL2 Demo",
    SDLWindowPosition.centeredMask,
    SDLWindowPosition.centeredMask,
    800, 
    600,
    SDLWindowFlags.shown)

let renderer = Renderer(
    window, 
    -1, 
    SDLRendererFlags.accelerated
)

let font = try Font("Sources/SampleSDL2/OpenSans-Regular.ttf", 25)

let textSurface = try font.renderTextSolid(
    "myndsmith surprisingly works!", 
    SDL_Color(r: 255, g: 255, b: 255, a: 255))

let imgSurface = try Surface("Sources/SampleSDL2/myndsmith.png")
    
let textTexture = Texture(renderer, Surface(textSurface.get))
let imgTexture = Texture(renderer, imgSurface)

let textDestinationRect = Rect(0, 0, 800, 80)
let imgDestinationRect = Rect(800/4, 100, 800/2, 800/2)

var quit = false
var event = SDL_Event()

// Run until app is quit
while !quit {
    
    // Poll for (input) events
    while sdlInstance.pollEvent(&event) > 0 {
        // If the quit event is triggered do
        if event.type == SDL_QUIT.rawValue {
            // Quit the run loop
            quit = true
        }
    }

    // Clear the renderer
    _ = try renderer.clear()

    // Render the text
    _ = try renderer.copy(textTexture, nil, textDestinationRect)

    // Render the image
    _ = try renderer.copy(imgTexture, nil, imgDestinationRect)

    // Present the renderer
    _ = renderer.present()

    // wait 100 ms
    SDL_Delay(100)
}