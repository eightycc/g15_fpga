#!/usr/bin/env python3

# This reads a block in G15 assembly format and converts it to a .ptx file
# asm.py [-o output.ptx] [-i input.asm]

import sys
import json
import datetime

digit_0_z = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9',
             'u', 'v', 'w', 'x', 'y', 'z']
digit_0_9 = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9']

# Transfer types decoded from {((S > 27) | (D > 27)), CH}
tr_type = ["TR", "AD", "TVA", "AVA", "TR", "AD", "AV", "SU"]
s_name = ["00", "01", "02", "03", "04", "05", "06", "07", "08", "09",
          "10", "11", "12", "13", "14", "15", "16", "17", "18", "19",
          "20", "21", "22", "23",
          "MQ", "ID", "PN", "20&21|~20&AR",
          "AR", "20&IN", "20&21", "20&21"]
d_name = ["00", "01", "02", "03", "04", "05", "06", "07", "08", "09",
          "10", "11", "12", "13", "14", "15", "16", "17", "18", "19",
          "20", "21", "22", "23",
          "MQ", "ID", "PN", "TEST",
          "AR", "AR+", "PN+", "SPECIAL"]
sc_name = ["Set_Ready", "01", "Fast_Pun_Leader", "Fast_Pun_M19",      # 00-03
           "04", "05", "Tape_Rev0", "Tape_Rev1",                      # 04-07
           "Type_AR", "Type_M19", "Pun_M19", "Card_Pun_M19",          # 08-11
           "Type_In", "13", "Card_Read", "Tape_Read",                 # 12-15
           "HALT", "17", "M20&ID_to_OUT", "19",                       # 16-19
           "20", "21", "AR_Sign_Test", "23",                          # 20-23
           "Multiply", "25", "26", "27",                              # 24-27
           "28", "Overflow_Test", "30", "31"]                         # 28-31

def eprint(*args, **kwargs):
    print(*args, file=sys.stderr, **kwargs)
    
def word29_to_str(word):
    if (word & 0x1 != 0):
        strout = "-."
    else:
        strout = " ."
    word >>= 1
    for i in range(7):
        strout += digit_0_z[word >> (4 * (6 - i)) & 0xf]
    return strout

def bin_to_dstr(d):
    return digit_0_z[d // 10] + digit_0_9[d % 10]

def bin_to_dstr1(d):
    return digit_0_9[d % 10]

def dstr_to_bin(s):
    if (len(s) != 1 and len(s) != 2):
        raise ValueError("Invalid length of dstr: " + s)
    if (len(s) == 1):
        s = "0" + s
    if ((s[0] not in digit_0_z) or (s[1] not in digit_0_9)):
        raise ValueError("Invalid character in dstr: " + s)
    return (digit_0_z.index(s[0]) * 10 + digit_0_9.index(s[1]))

def checksum(block):
    # Calculate checksum of block using signed-magnitude arithmetic
    sum = 0
    for word in block:
        if (word & 0x1 != 0):
            sum = sum - (word >> 1) & 0x1fffffff
        else:
            sum = sum + (word >> 1) & 0x1fffffff
    if (sum == 0x10000000):
        return 0
    return (sum << 1 | sum >> 28)

def str_to_word29(s):
    sign = 0
    word = 0
    for ch in s:
        if (ch == '.'):
            continue
        elif (ch == '-'):
            sign = 1
        elif (ch in digit_0_z):
            word = (word << 4) | digit_0_z.index(ch)
        else:
            raise ValueError("Invalid character in word29: " + ch)
    return (word << 1) | sign

def str_asm_word29(s):
    # Behold: the mighty assembler:
    pfx = ""
    fields = s.split(".")
    if (len(fields) < 5 or len(fields) > 6):
        raise ValueError("Invalid number of fields in asm: " + s)
    if (len(fields) == 6):
        pfx = fields[0]
        fields = fields[1:]
        if (pfx != "u" and pfx != "w" and pfx != ""):
            raise ValueError("Invalid prefix in asm: " + s)
    for i in range(5):
        if (fields[i] == ""):
            raise ValueError("Empty field in asm: " + s)
        try:
            fields[i] = dstr_to_bin(fields[i])
        except:
            raise ValueError("Invalid field in asm: " + s)
    t = fields[0]
    if (t > 127):
        raise ValueError("Invalid T field in asm: " + s)
    n = fields[1]
    if (n > 127):
        raise ValueError("Invalid N field in asm: " + s)
    if (fields[2] > 7):
        raise ValueError("Invalid CH field in asm: " + s)
    ch = fields[2] & 0x3
    src = fields[3]
    if (src > 31):
        raise ValueError("Invalid S field in asm: " + s)
    d = fields[4]
    if (d > 31):
        raise ValueError("Invalid D field in asm: " + s)
    s_d = fields[2] >> 2
    if (d == 31):
        if (pfx == "w"):
            i_d = 1
        elif (pfx == ""):
            i_d = 0
        else:
            raise ValueError("Invalid prefix in asm: " + s)
    else:
        if (pfx == "u"):
            i_d = 0
        elif (pfx == ""):
            i_d = 1
        else:
            raise ValueError("Invalid prefix in asm: " + s)

    return ((i_d << 28) | (t << 21) | (n << 13) | (ch << 11) | (src << 6) | (d << 1) | s_d)

def asm_line(fields):
    # Parse address
    is_asm = False
    try:
        addr = dstr_to_bin(fields[0])
    except:
        addr = 0xffffffff
    # Parse assembler statement or constant
    if (fields[1].count(".") == 1):
        try:
            data = str_to_word29(fields[1])
        except ValueError as e:
            eprint(e)
            data = 0xffffffff
    else:
        try:
            data = str_asm_word29(fields[1])
            is_asm = True
        except ValueError as e:
            eprint(e)
            data = 0xffffffff
    return [addr, data, is_asm]

def asm_file(filename):
    blocks = 108 * [0xf0000000]
    blocks_map = []
    with open (filename, "r") as file:
        for line in file:
            wk_line = line
            wk_line = wk_line.split("#")[0]
            wk_line = "".join(wk_line.split())
            if (wk_line == ""):
                continue
            fields = wk_line.split(":")
            if (len(fields) != 2):
                eprint("Invalid number of fields in asm line: " + line)
                continue
            [addr, data, is_asm] = asm_line(fields)
            if (addr != 0xffffffff):
                if (blocks[addr] != 0xf0000000):
                    eprint("Duplicate address in asm file: " + line)
                else:
                    blocks[addr] = data
                    map_code = 'A' if is_asm else 'C'
                    blocks_map.append([map_code, addr])
    return [blocks, blocks_map]

def dump_block_raw(block_data):
    print("\nBlock raw data:")
    for i in range(len(block_data)):
        if (i % 10 == 0 and i != 0):
            print("")
        if (i % 10 == 0):
            print("    " + bin_to_dstr(i) + ":", end="", sep="")
        if (block_data[i] == 0xf0000000):
            print("   --------", end="")
        else:
            print(" ", word29_to_str(block_data[i]), end="")

def decode_word(word):
    i_d = (word >> 28) & 0x1
    t   = (word >> 21) & 0x7f
    bp  = (word >> 20) & 0x1
    n   = (word >> 13) & 0x7f
    ch  = (word >> 11) & 0x03
    s   = (word >> 6)  & 0x1f
    d   = (word >> 1)  & 0x1f
    s_d = word & 0x1
    p   = " "
    if ((d != 31) & (i_d == 0)):
        p = "u"
    elif ((d == 31) & (i_d == 1)):
        p = "w"
    c = (s_d << 2) | ch
    return [i_d, t, bp, n, ch, s, d, s_d, p, c]

def command_to_pprasm(word):
    [i_d, t, bp, n, ch, s, d, s_d, p, c] = decode_word(word)
    return (p + "." + bin_to_dstr(t) + "." + bin_to_dstr(n) + "." + 
            bin_to_dstr1(c) + "." + bin_to_dstr(s) + "." + bin_to_dstr(d))

def incr_waddr(a):
    return (a + 1) % 108

def command_to_semantics(word, waddr):
    [i_d, t, bp, n, ch, s, d, s_d, p, c] = decode_word(word)
    semantics = ""
    # immediate command
    is_imm = (i_d == 0)
    # immediate command with relative timing
    is_rel = is_imm and (d == 31) and (s >= 24) and (s < 28)
    # immediate command with absolute timing
    is_abs = is_imm and (d != 31) and ((s < 24) or (s >= 28))
    start_waddr = 0;
    end_waddr = 0;
    if is_imm:
        start_waddr = incr_waddr(waddr)
        if (d == 31) and (s == 21):  # special command MARK
            end_waddr = start_waddr
        elif is_abs:
            end_waddr = (t + 108 - 1) % 108
        else:
            # relative timing is unpredictable for SHIFT and NORMALIZE,
            # so we fall back to T as a word counter for all relative timing
            # commands
            end_waddr = (t + 108 + start_waddr - 1) % 108
        if (start_waddr != end_waddr):
            semantics += "I [" + bin_to_dstr(start_waddr) + ":" + bin_to_dstr(end_waddr) + "]"
        else:
            semantics += "I    [" + bin_to_dstr(start_waddr) + "]"
    else:
        start_waddr = t
        if ((d == 31) and (s == 21)) or (s_d == 0):
            end_waddr = start_waddr
        else:
            end_waddr = start_waddr
            if (end_waddr & 1 == 1):
                # a double-word command starting at an odd address
                # transfers just one word
                end_waddr = incr_waddr(end_waddr)
        if (start_waddr != end_waddr):
            semantics += "D [" + bin_to_dstr(start_waddr) + ":" + bin_to_dstr(end_waddr) + "]"
        else:
            semantics += "D    [" + bin_to_dstr(start_waddr) + "]"
    if (d == 31):
        # special command
        cname = sc_name[s]
        if (cname == "01"):
            cname = "Mag_Tape_Write" + str(ch)
        elif (cname == "04"):
            cname = "Mag_Tape_Rev_Search" + str(ch)
        elif (cname == "05"):
            cname = "Mag_Tape_Fwd_Search" + str(ch)
        elif (cname == "13"):
            cname = "Mag_Tape_Read" + str(ch)
        elif (cname == "17"):
            if (ch == 0):
                cname = "Ring_Bell"
            elif (ch == 1):
                cname = "Man_Punch_Test"
            elif (ch == 2):
                cname = "Start_INPUT"
            elif (ch == 3):
                cname = "Stop_INPUT"
        semantics += " " + cname
    else:
        # transfer command
        ttype = (ch + 4) if (s > 27 or d > 27) else ch
        semantics += " " + s_name[s] + "->" + tr_type[ttype] + "->" + d_name[d]
    return semantics

def dump_block_decoded(block_data, block_map):
    print("\nDecoded block data:")
    for i in range(len(block_map)):
        kind = block_map[i][0]
        addr = block_map[i][1]
        word = block_data[addr]
        print("    " + bin_to_dstr(addr) + ": ", end="", sep="")
        if (kind == 'C'):
            print(word29_to_str(word), sep="")
        else:
            print(command_to_pprasm(word), "   # ", command_to_semantics(word, addr), sep="")
        
def main():
    [block_data, block_map] = asm_file("diaper/testv_0.asm")
    # report unused words
    for i in range(108):
        if (block_data[i] == 0xf0000000):
            print("Unused word in block:", i)
    dump_block_raw(block_data)
    # replace unused words in block with 0
    for i in range(len(block_map)):
        if (block_map[i] == 0xf0000000):
            block_map[i] = 0
    print("\n\nCalculated checksum:", word29_to_str(checksum(block_data)))
    dump_block_decoded(block_data, block_map)
    #print(block_map)

if __name__ == "__main__":
    main()
       