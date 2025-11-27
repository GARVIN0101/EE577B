import os

def file_id(node):
    return (node // 4) * 10 + (node % 4)

def coord(n):
    return n % 4, n // 4

# ===================================================
# helper: convert little-endian 64-bit → big-endian
# ===================================================
def to_big(x):
    return int.from_bytes(x.to_bytes(8, "little"), "big")

# ===================================================
# build packet (LITTLE-ENDIAN as seen by router)
# ===================================================
def build_packet(src, dst):
    src_x, src_y = coord(src)
    dst_x, dst_y = coord(dst)

    dx = abs(dst_x - src_x)
    dy = abs(dst_y - src_y)

    sx = 0 if dst_x > src_x else 1
    sy = 0 if dst_y < src_y else 1

    vc = (src + dst) & 1
    payload  = dst & 0xFFFFFFFF
    sourceID = src & 0xFFFF

    pkt = 0
    pkt |= (vc & 1) << 63
    pkt |= (sx & 1) << 62
    pkt |= (sy & 1) << 61
    pkt |= 0        << 56
    pkt |= (dx & 0xF) << 52
    pkt |= (dy & 0xF) << 48
    pkt |= (sourceID & 0xFFFF) << 32
    pkt |= payload
    return pkt

def delivered_packet(src, dst):
    pkt = build_packet(src, dst)
    pkt &= ~(0xF << 52)
    pkt &= ~(0xF << 48)
    return pkt

# ===================================================
# DMEM fill (BIG-ENDIAN in file)
# ===================================================
os.makedirs("dmem_fill", exist_ok=True)

for node in range(16):
    fid = file_id(node)
    with open(f"dmem_fill/cmp_test.dmem.{fid:02d}.fill", "w") as f:

        # 0..14: original packets (convert to big-endian)
        for dst in range(16):
            if dst != node:
                be = to_big(build_packet(node, dst))
                f.write(f"{be:016X}\n")

        # 15..31 padding
        for _ in range(17):
            f.write("0000000000000000\n")

# ===================================================
# DMEM dump (BIG-ENDIAN in file)
# ===================================================
os.makedirs("dmem_dump", exist_ok=True)

for node in range(16):
    fid = file_id(node)
    with open(f"dmem_dump/cmp_test.dmem.{fid:02d}.dump", "w") as f:

        # 0..14: original
        for dst in range(16):
            if dst != node:
                be = to_big(build_packet(node, dst))
                f.write(f"{be:016X}\n")

        # 15 padding
        f.write("0000000000000000\n")

        # 16..30: received packets
        for src in range(16):
            if src != node:
                be = to_big(delivered_packet(src, node))
                f.write(f"{be:016X}\n")

        # 31 padding
        f.write("0000000000000000\n")
