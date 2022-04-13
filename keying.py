import ctypes

authy = ctypes.CDLL('./libauthing.dylib')
authy.auth.argtypes = (ctypes.c_char_p)
authy.auth.restype = ctypes.c_bool

def auth(msg: str):
    return authy.auth(ctypes.c_char_p(msg.encode()))