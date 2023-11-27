@_exported import RAW_BGFX

public enum BGFXClearFlags: UInt16 {
    case none = 0x0000
    case color = 0x0001
    case depth = 0x0002
    case stencil = 0x0004
    case discardColor0 = 0x0008
    case discardColor1 = 0x0010
    case discardColor2 = 0x0020
    case discardColor3 = 0x0040
    case discardColor4 = 0x0080
    case discardColor5 = 0x0100
    case discardColor6 = 0x0200
    case discardColor7 = 0x0400
    case discardDepth = 0x0800
    case discardStencil = 0x1000
}

public enum BGFXStateWriteFlags: UInt64 {
    case writeR = 0x0000000000000001
    case writeG = 0x0000000000000002
    case writeB = 0x0000000000000004
    case writeA = 0x0000000000000008
    case writeZ = 0x0000004000000000
}

public enum BGFXStateDepthTest: UInt64 {
    case less = 0x0000000000000010
    case lessOrEqual = 0x0000000000000020
    case equal = 0x0000000000000030
    case greaterOrEqual = 0x0000000000000040
    case greater = 0x0000000000000050
    case notEqual = 0x0000000000000060
    case never = 0x0000000000000070
    case always = 0x0000000000000080
    case shift  = 4
    case mask = 0x00000000000000f0
}

public struct BGFXStateWrite {
    public static let RGB = 0 | 
        BGFXStateWriteFlags.writeR.rawValue | 
        BGFXStateWriteFlags.writeG.rawValue | 
        BGFXStateWriteFlags.writeB.rawValue
}

public struct BX {

    public struct Vec3 {
        let x: Float
        let y: Float
        let z: Float

        public init(x: Float, y: Float, z: Float) {
            self.x = x
            self.y = y
            self.z = z
        }

        public func length() -> Float {
            return Float(sqrt(Double(dot(a: self, b: self))))
        }
    } 


    public enum Handedness {
        case Left
		case Right
    }

    public static func normalize(a: Vec3) -> Vec3 {
        let invLen: Float = 1.0 / a.length()
		let result: Vec3 = mul(a: a, b: invLen)
		return result
    }

    //multiplication (vector * vector)
    public static func mul(a: Vec3, b:Vec3) -> Vec3 {
        return Vec3(
			x: a.x * b.x,
			y: a.y * b.y,
			z: a.z * b.z
        )
    }

    //multiplication (vector * scalar)
    public static func mul(a: Vec3, b: Float) -> Vec3 {
         return Vec3(
			x: a.x * b,
			y: a.y * b,
			z: a.z * b
        )
    }
   
    //substraction
    public static func sub(a: Vec3, b: Vec3) -> Vec3 {
        return Vec3(
			x: a.x - b.x,
			y: a.y - b.y,
			z: a.z - b.z
        )
    }

    //cross product
    public static func cross(a: Vec3, b: Vec3) -> Vec3 {
        return Vec3(
			x: a.y * b.z - a.z * b.y,
			y: a.z * b.x - a.x * b.z,
			z: a.x * b.y - a.y * b.x
        )
    }

    //dot product
    public static func dot(a: Vec3, b: Vec3) -> Float {
        return a.x * b.x + a.y * b.y + a.z * b.z
    }

    public static func mtxLookAt(result: inout [Float],
                         eye: Vec3,
                         at: Vec3,
                         _up: Vec3,
                         handedness: Handedness) {

        let  view: Vec3 = normalize(
                a: (Handedness.Right == handedness)
                    ? sub(a: eye, b: at)
                : sub(a: at, b: eye)
		)

		var right = Vec3(x: 0, y: 0, z: 0)
		var up    = Vec3(x: 0, y: 0, z: 0)

		let uxv = cross(a: _up, b: view)

		if (0.0 == dot(a: uxv, b: uxv) ) {
			right = Handedness.Left == handedness ? Vec3(x: -1.0, y: 0.0, z: 0.0) : Vec3(x: 1.0, y: 0.0, z: 0.0) 
		}
		else {
			right = normalize(a: uxv)
		}

		up = cross(a: view, b: right)

		result[0] = right.x
		result[1] = up.x
		result[2] = view.x
		result[3] = 0.0

		result[4] = right.y
		result[5] = up.y
		result[6] = view.y
		result[7] = 0.0

		result[8] = right.z
		result[9] = up.z
		result[10] = view.z
		result[11] = 0.0

		result[12] = -dot(a: right, b: eye)
		result[13] = -dot(a: up,    b: eye)
		result[14] = -dot(a: view,  b: eye)
		result[15] = 1.0
	}

    static func mtxProjXYWH(result: inout [Float], x: Float, y: Float, width: Float, height: Float, 
                near: Float, far: Float, homogeneousNdc: Bool, handedness: Handedness) {
        let diff = far - near
        let aa = homogeneousNdc ? (far + near) / diff : far / diff
        let bb = homogeneousNdc ? (2.0 * far * near) / diff : near * aa

        result[0] = width
        result[5] = height
        result[8] = (handedness == .Right) ? x : -x
        result[9] = (handedness == .Right) ? y : -y
        result[10] = (handedness == .Right) ? -aa : aa
        result[11] = (handedness == .Right) ? -1.0 : 1.0
        result[14] = -bb
    }

    public static func mtxProj(_ result: inout [Float], _ ut: Float,_ dt: Float,_ lt: Float,_ rt: Float,_ near: Float,_ far: Float,_ homogeneousNdc: Bool,_ handedness: Handedness) {
        let invDiffRl = 1.0 / (rt - lt)
        let invDiffUd = 1.0 / (ut - dt)
        let width = 2.0 * near * invDiffRl
        let height = 2.0 * near * invDiffUd
        let xx = (rt + lt) * invDiffRl
        let yy = (ut + dt) * invDiffUd

        mtxProjXYWH(result: &result, x: xx, y: yy, width: width, height: height, near: near, far: far, homogeneousNdc: homogeneousNdc, handedness: handedness)
    }

    public static func toRad(_ degrees: Float) -> Float {
        return degrees * .pi / 180.0
    }

    public static func mtxProj(result: inout [Float], fovy: Float, aspect: Float, near: Float, far: Float, homogeneousNdc: Bool, handedness: Handedness) {
        let height: Float = Float(1.0 / tan(Double(toRad(fovy)) * 0.5))
        let width = height * 1.0 / aspect

        mtxProjXYWH(result: &result, x: 0.0, y: 0.0, width: width, height: height, near: near, far: far, homogeneousNdc: homogeneousNdc, handedness: handedness)
    }

    public static func mtxRotateXY(result: inout [Float], ax: Double, ay: Double) {
        let sx = Float(sin(ax))
        let cx = Float(cos(ax))
        let sy = Float(sin(ay))
        let cy = Float(cos(ay))

        result[0] = cy
        result[2] = sy
        result[4] = sx * sy
        result[5] = cx
        result[6] = -sx * cy
        result[8] = -cx * sy
        result[9] = sx
        result[10] = cx * cy
        result[15] = 1.0
    }
}

