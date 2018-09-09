module ECDSA
  class Group
    getter name : String
    getter p  : BigInt
    getter a  : BigInt
    getter b  : BigInt
    getter gx : BigInt
    getter gy : BigInt
    getter n  : BigInt

    def initialize(@name : String,
                   @p : BigInt,
                   @a : BigInt,
                   @b : BigInt,
                   @gx : BigInt,
                   @gy : BigInt,
                   @n : BigInt)
    end

    def g
      Point.new(self, @gx, @gy)
    end

    def infinity
      Point.new(self, true)
    end

    def create_key_pair
      secret_key = ECDSA::Math.random(BigInt.new(1), n - 1)
      create_key_pair(secret_key)
    end

    def create_key_pair(secret_key : BigInt) : NamedTuple(secret_key: BigInt, public_key: Point)
      {
        secret_key: secret_key,
        public_key: create_public_key(secret_key),
      }
    end

    def create_public_key(secret_key : BigInt) : Point
      g * secret_key
    end

    def inverse(n1 : BigInt, n2 : BigInt)
      ECDSA::Math.mod_inverse(n1, n2)
    end

    def sign(secret_key : BigInt, message : String) : Signature
      # inputs (k should not be used twice)
      temp_key_k = ECDSA::Math.random(BigInt.new(1), n-1)
      sign(secret_key, message, temp_key_k)
    end

    def sign(secret_key : BigInt, message : String, temp_key_k : BigInt) : Signature
      # https://en.wikipedia.org/wiki/Elliptic_Curve_Digital_Signature_Algorithm

      r = BigInt.new(0)
      s = BigInt.new(0)

      hash = BigInt.new(ECDSA::Math.hash(message), base: 16)

      # computing r
      curve_point = g * temp_key_k
      r = curve_point.x
      return sign(secret_key, message) if r == 0

      # computing s
      s = (inverse(temp_key_k, n) * (hash + secret_key * r)) % n
      return sign(secret_key, message) if s == 0

      Signature.new(r: r, s: s)
    end

    def verify(public_key : Point, message : String, signature : Signature)
      verify(public_key, message, signature.r, signature.s)
    end

    def verify(public_key : Point, message : String, r : BigInt, s : BigInt) : Bool

      # some verifications of input params??

      hash = BigInt.new(ECDSA::Math.hash(message), base: 16)

      c = inverse(s, n)

      u1 = (hash * c) % n
      u2 = (r * c) % n
      xy = (g * u1) + (public_key * u2)

      v = xy.x % n
      v == r
    end
  end
end