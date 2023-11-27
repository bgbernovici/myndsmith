import SDL2
import BGFX
import Foundation

// Initialize SDL video systems
guard SDL_Init(SDL_INIT_VIDEO) == 0 else {
    fatalError("SDL could not initialize! SDL_Error: \(String(cString: SDL_GetError()))")
}

// Create a window at the center of the screen with 800x800 pixel resolution
var window = SDL_CreateWindow(
    "Swifty BGFX with SDL2",
     Int32(SDL_WINDOWPOS_UNDEFINED_MASK)|(0), 
     Int32(SDL_WINDOWPOS_UNDEFINED_MASK)|(0),
    800, 800,
    UInt32(SDL_WINDOW_SHOWN.rawValue) | UInt32(SDL_WINDOW_RESIZABLE.rawValue)
)

var quit = false 
var event = SDL_Event()

SDL_GL_CreateContext(window);

// Initialize BGFX
var initBGFX: bgfx_init_t = bgfx_init_t()
bgfx_init_ctor(&initBGFX)
initBGFX.resolution.width = 800
initBGFX.resolution.height = 800
initBGFX.resolution.reset = UInt32(0x00000080)
initBGFX.type = BGFX_RENDERER_TYPE_OPENGL

var wmi: SDL_SysWMinfo = SDL_SysWMinfo()
if (SDL_GetWindowWMInfo(window, &wmi) == SDL_TRUE) {
        print("Window info acquired.")
}
var pd: bgfx_platform_data_t = bgfx_platform_data_t()
pd.ndt = nil
pd.nwh = UnsafeMutableRawPointer(wmi.info.win.window)
initBGFX.platformData = pd


if (!bgfx_init(&initBGFX)) {
    fatalError("Error initializing BGFX")
} else {
    print("BGFX Initialized.")
}

struct PosColorVertex {
    let x: Float
    let y: Float
    let z: Float
    let abgr: Uint32
}

let cubeVertices: [PosColorVertex] = [
    PosColorVertex(x: -1.0,  y: 1.0,  z: 1.0, abgr: 0xff000000),
    PosColorVertex( x: 1.0,  y: 1.0,  z: 1.0, abgr: 0xff0000ff ),
    PosColorVertex(x: -1.0, y: -1.0,  z: 1.0, abgr: 0xff00ff00 ),
    PosColorVertex(x: 1.0, y: -1.0,  z: 1.0, abgr: 0xff00ffff ),
    PosColorVertex(x: -1.0,  y: 1.0, z: -1.0, abgr: 0xffff0000 ),
    PosColorVertex( x: 1.0,  y: 1.0, z: -1.0, abgr: 0xffff00ff ),
    PosColorVertex(x: -1.0, y: -1.0, z: -1.0, abgr: 0xffffff00 ),
    PosColorVertex( x: 1.0, y: -1.0, z: -1.0, abgr: 0xffffffff)
]

let cubeTriList: [UInt16] = [    
    0, 1, 2,
    1, 3, 2,
    4, 6, 5,
    5, 6, 7,
    0, 2, 4,
    4, 2, 6,
    1, 5, 3,
    5, 7, 3,
    0, 4, 1,
    4, 5, 1,
    2, 3, 6,
    6, 3, 7,
]

bgfx_set_view_clear(0, 0x0001 | 0x0002, 0x443355FF, 1.0, 0);

var pcvLayout: bgfx_vertex_layout_t = bgfx_vertex_layout_t()
bgfx_vertex_layout_begin(&pcvLayout, BGFX_RENDERER_TYPE_OPENGL);
bgfx_vertex_layout_add(&pcvLayout, BGFX_ATTRIB_POSITION, 3, BGFX_ATTRIB_TYPE_FLOAT, false, false);
bgfx_vertex_layout_add(&pcvLayout, BGFX_ATTRIB_COLOR0, 4, BGFX_ATTRIB_TYPE_UINT8, true, false);
bgfx_vertex_layout_end(&pcvLayout);

var vbh: bgfx_vertex_buffer_handle_t  = bgfx_create_vertex_buffer(
    bgfx_copy(cubeVertices, UInt32(cubeVertices.count * MemoryLayout<PosColorVertex>.stride)), 
    &pcvLayout,
    0x0000)
var ibh: bgfx_index_buffer_handle_t = bgfx_create_index_buffer(
    bgfx_copy(cubeTriList, UInt32(cubeTriList.count * MemoryLayout<UInt16>.stride)), 
    0x0000)

var counter: UInt = 0

func loadShader(FILENAME: String) -> bgfx_shader_handle_t {
    var shaderPath: String

    switch bgfx_get_renderer_type().rawValue {
        case 9:
            shaderPath = "Sources/SampleBGFX/shaders/glsl/"
        default:
            fatalError("NO SHADER FOR YOUR RENDERER")
    }

    let filePath = shaderPath + FILENAME

    guard let fileData: Data = FileManager.default.contents(atPath: filePath) else {
        fatalError("Couldn't find shaders")
    }

    let fileSize = fileData.count

    let mem = fileData.withUnsafeBytes { bgfx_copy($0.baseAddress!, UInt32(fileSize)) }

    return bgfx_create_shader(mem)
}

// Load shaders
let vsh: bgfx_shader_handle_t = loadShader(FILENAME: "vs_cubes.bin");
let fsh: bgfx_shader_handle_t = loadShader(FILENAME: "fs_cubes.bin");

let program: bgfx_program_handle_t = bgfx_create_program(vsh, fsh, true);


var move_x = 0, move_y = 0, move_z = 0
while !quit {
    
    
    bgfx_set_view_rect(0, 0, 0, UInt16(initBGFX.resolution.width), UInt16(initBGFX.resolution.height))

    let at = BX.Vec3(x: 0.0, y: 0.0,  z: 0.0)
    let eye = BX.Vec3(x: 0.0 + Float(move_x), y: 0.0 +  Float(move_y), z: -5.0 + Float(move_z))
    let up = BX.Vec3(x: 0.0, y: 0.0, z: 0.0)
    var view = [Float](repeating: 0.0, count: 16)

    BX.mtxLookAt(result: &view, eye: eye, at: at, _up: up, handedness: BX.Handedness.Right)

    var proj = [Float](repeating: 0.0, count: 16)
    BX.mtxProj(result: &proj, fovy: 60.0, aspect: Float(initBGFX.resolution.width / initBGFX.resolution.height), 
        near: Float(0.1), far: Float(100.0), homogeneousNdc: bgfx_get_caps().pointee.homogeneousDepth, handedness: BX.Handedness.Right)
    
    bgfx_set_view_transform(0, view, proj)

    var transform_matrix = [Float](repeating: 0.0, count: 16)
    BX.mtxRotateXY(result: &transform_matrix, ax: Double(counter) * 0.01, ay: Double(counter) * 0.01)
    bgfx_set_transform(transform_matrix, 16)
    bgfx_set_vertex_buffer(0, vbh, 0, 8);
    bgfx_set_index_buffer(ibh, 0, 3*12);

    bgfx_set_state(BGFXStateWrite.RGB | BGFXStateWriteFlags.writeA.rawValue | BGFXStateWriteFlags.writeZ.rawValue | BGFXStateDepthTest.less.rawValue, 0)
    bgfx_submit(0, program, 0, 0x00);

    bgfx_frame(false)
    counter += 1

    while SDL_PollEvent(&event) > 0 {
        if event.type == SDL_QUIT.rawValue {
            quit = true
        }
        if event.type == SDL_KEYDOWN.rawValue {
            if event.key.keysym.scancode == SDL_SCANCODE_W {
                move_y += 1
            }
            if event.key.keysym.scancode == SDL_SCANCODE_S {
                move_y -= 1
            }
            if event.key.keysym.scancode == SDL_SCANCODE_D {
                move_x += 1
            }
            if event.key.keysym.scancode == SDL_SCANCODE_A {
                move_x -= 1
            }
            if event.key.keysym.scancode == SDL_SCANCODE_E {
                move_z += 1
            }
            if event.key.keysym.scancode == SDL_SCANCODE_Q {
                move_z -= 1
            }
        }
    }

    SDL_Delay(10) 
}

SDL_DestroyWindow(window)

SDL_Quit()