import ctypes
import base64

keying = ctypes.CDLL('./libkeying.dylib')
keying.create.restype = ctypes.c_char_p
keying.sign.argtypes = (ctypes.c_char_p,)
keying.sign.restype = ctypes.c_char_p

def create():
    print("creating")
    out = keying.create()
    print(out)
    print(out.decode())


def sign():
    out = keying.sign(ctypes.c_char_p("dGVzdA==".encode()))
    print(out)
    print(out.decode())