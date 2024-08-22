#!/usr/bin/env python3

# Bendix G-15 assembler, disassembler, and conversion utilities

#   g15util.py cmd [args]

# Commands:
#   g15util.py asm <input file>
#   g15util.py dis <input file>
#   g15util.py cvt -t "pt" | "pti" <input file>

import sys
import os
import getopt
import json
import datetime

digit_0_z = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9',
             'u', 'v', 'w', 'x', 'y', 'z']
digit_0_9 = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9']

pt_codes = [' ', '0', '?', '8', 'S', '4', '?', 'w',
            'R', '2', '?', 'u', '.', '6', '?', 'y',
            '-', '1', '?', '9', '/', '5', '?', 'x',
            'T', '3', '?', 'v', 'W', '7', '?', 'z']
rev_pt_codes = 256 * [-1]
for ch in pt_codes:
    if (ch != '?'):
        rev_pt_codes[ord(ch)] = pt_codes.index(ch)

# Transfer type decoded from {((S > 27) | (D > 27)), CH}:
tr_type = ["TR", "AD", "TVA", "AVA", "TR", "AD", "AV", "SU"]
# Source register names:
s_name = ["00", "01", "02", "03", "04", "05", "06", "07", "08", "09",
          "10", "11", "12", "13", "14", "15", "16", "17", "18", "19",
          "20", "21", "22", "23",
          "MQ", "ID", "PN", "20&21|~20&AR",
          "AR", "20&IN", "20&21", "20&21"]
# Destination register names:
d_name = ["00", "01", "02", "03", "04", "05", "06", "07", "08", "09",
          "10", "11", "12", "13", "14", "15", "16", "17", "18", "19",
          "20", "21", "22", "23",
          "MQ", "ID", "PN", "TEST",
          "AR", "AR+", "PN+", "SPECIAL"]
# Special command names:
sc_name = ["Set_Ready", "01", "Fast_Pun_Leader", "Fast_Pun_M19",      # 00-03
           "04", "05", "Tape_Rev0", "Tape_Rev1",                      # 04-07
           "Type_AR", "Type_M19", "Pun_M19", "Card_Pun_M19",          # 08-11
           "Type_In", "13", "Card_Read", "Tape_Read",                 # 12-15
           "HALT", "17", "M20&ID_to_OUT", "19",                       # 16-19
           "20", "21", "AR_Sign_Test", "23",                          # 20-23
           "Multiply", "25", "26", "27",                              # 24-27
           "28", "Overflow_Test", "30", "31"]                         # 28-31
# Command line names for decoding CD register or {cmd_29, CH}:
cl_name = ["00", "01", "02", "03", "04", "05", "19", "23"]

# -----------------------------------------------------------------------------
# Utility functions
# -----------------------------------------------------------------------------
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

def add_29(a, b):
    # G-15 29-bit signed-magnitude arithmetic. Because of its bit-serial
    # organization the G-15 does not perform a re-complement step when the
    # result of an addition or subtraction is negative. Intermediate
    # results in the AR are always in 2's complement form.
    a &= 0x1fffffff
    b &= 0x1fffffff
    a = ((a & 0x1) << 28) | (a >> 1)
    if (b & 0x1 == 0):
        sum = a + (b >> 1) & 0x1fffffff
    else:
        sum = a - (b >> 1) & 0x1fffffff
    return ((sum << 1 | sum >> 28) & 0x1fffffff) if (sum != 0x10000000) else 0

def checksum(block):
    # Calculate checksum of block using G-15 signed-magnitude arithmetic
    sum = 0
    for word in block:
        sum = add_29(sum, word)
    return sum

def balance_checksum(target_sum, actual_sum):
    # Given a target checksum and an actual checksum, returns an
    # adjustment factor that when added to the actual checksum will
    # produce the target checksum. Bendix often calls this "Bal."
    # or "Adj. Bal." in their listings.
    t_sign = target_sum & 0x1
    t_mag  = target_sum >> 1
    a_sign = actual_sum & 0x1
    a_mag  = actual_sum >> 1
    if (t_sign == a_sign):
        # When signs are the same, a simple addition or subtraction of the
        # magnitude difference will produce the target checksum.
        if (t_mag < a_mag):
            return ((a_mag - t_mag) << 1) | 0x1
        else:
            return ((t_mag - a_mag) << 1) | 0x0
    else:
        # When signs differ, the 2's complement of the magnitude difference
        # is used so that the carry will flip the sign bit.
        if (t_mag < a_mag):
            return (~(a_mag - t_mag) + 1) << 1 | 0x0
        else:
            return (~(t_mag - a_mag) + 1) << 1 | 0x1

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

def strip_comments_whitespace(line):
    line = line.split("#")[0]
    line = "".join(line.split())
    return line

def print_pti_block(block, pti_file):
    print("# PTI block data:", file=pti_file)
    quad_data = 0
    minus = False
    for block_idx in range(len(block)-1, -1, -1):
        quad_data = (quad_data << 29) | (block[block_idx] & 0x1fffffff)
        if (block_idx % 4 == 0):
            quad_str = "-" if quad_data & 0x1 else " "
            for i in range(29):
                quad_str = quad_str + digit_0_z[(quad_data >> ((28 - i) * 4)) & 0xf]
            quad_str = quad_str + "S" if block_idx == 0 else quad_str + "/"
            print(quad_str, file=pti_file)
            quad_data = 0


def seek_pti_block(pti_file, block_no):
    block_pos = 0
    pti_file.seek(0)
    for line in pti_file:
        if (block_pos == block_no):
            return True
        line = strip_comments_whitespace(line)
        if (line == ""):
            continue
        if (line.find("S") > 0):
            block_pos += 1
    return (block_pos == block_no)

def read_pti_block(pti_file):
    pti_block = ""
    for line in pti_file:
        line = strip_comments_whitespace(line)
        if (line == ""):
            continue
        pti_block += line
        if (line.find("S") > 0):
            break
    if pti_block == "":
        return []

    block = 108 * [0x00000000]
    block_idx = 107
    quad_data = 0
    quad_digits = 0
    minus = False
    for raw_char in pti_block:
        match raw_char:
            case '0' | '1' | '2' | '3' | '4' | '5' | '6' | '7' | '8' | '9':
                # convert character to 4-bit integer and insert into quad
                quad_data = (quad_data << 4) | (ord(raw_char) - ord('0'))
                quad_digits += 1
            case 'u' | 'v' | 'w' | 'x' | 'y' | 'z':
                quad_data = (quad_data << 4) | (ord(raw_char) - ord('u') + 10)
                quad_digits += 1
            case '-':
                minus = True
            case 'S' | '/':
                if (quad_digits != 29):
                    eprint("Error: Invalid number of digits in quad data", quad_digits, block_idx)
                if (block_idx < 0):
                    eprint("Error: Block data overflow (> 108 words)")
                else:
                    for i in range(4):
                        block[block_idx-3+i] = quad_data & 0x1fffffff
                        quad_data >>= 29
                    block_idx -= 4
                quad_data = 0
                quad_digits = 0
                minus = False
            case _:
                eprint("Error: Invalid character in block data:", raw_char)

    # A short block (< 108 words) is shifted to origin 0 and truncated
    if (block_idx != -1):
        short_block_size = 107 - block_idx
        for i in range(short_block_size):
            block[i] = block[i+block_idx+1]
        block = block[:short_block_size]

    return block

def read_pti_file(pti_file):
    blocks = []
    while True:
        block = read_pti_block(pti_file)
        if block == []:
            break
        blocks.append(block)
    return blocks

def print_pt_block(block, pt_file):
    quad_data = 0
    minus = False
    for block_idx in range(len(block)-1, -1, -1):
        quad_data = (quad_data << 29) | (block[block_idx] & 0x1fffffff)
        if (block_idx % 4 == 0):
            quad_str = "-" if quad_data & 0x1 else " "
            for i in range(29):
                quad_str = quad_str + digit_0_z[(quad_data >> ((28 - i) * 4)) & 0xf]
            quad_str = quad_str + "S" if block_idx == 0 else quad_str + "/"
            for ch in quad_str:
                pt_file.write(bytes([rev_pt_codes[ord(ch)]]))
            quad_data = 0

def read_pt_block(pt_file):
    block = 108 * [0x00000000]
    block_idx = 107
    quad_data = 0
    quad_digits = 0
    minus = False
    while (bin_char := pt_file.read(1)):
        bin_char = ord(bin_char)
        if (bin_char > 31):
            eprint("Error: Invalid character in PT block1:", bin_char)
            continue
        pt_char = pt_codes[bin_char]
        if (pt_char == '?'):
            eprint("Error: Invalid character in PT block2:", bin_char)
            continue
        match pt_char:
            case '0' | '1' | '2' | '3' | '4' | '5' | '6' | '7' | '8' | '9':
                # convert character to 4-bit integer and insert into quad
                quad_data = (quad_data << 4) | (ord(pt_char) - ord('0'))
                quad_digits += 1
            case 'u' | 'v' | 'w' | 'x' | 'y' | 'z':
                quad_data = (quad_data << 4) | (ord(pt_char) - ord('u') + 10)
                quad_digits += 1
            case '-':
                minus = True
            case 'S' | '/':
                if (quad_digits != 29):
                    eprint("Error: Invalid number of digits in quad data", quad_digits, block_idx)
                if (block_idx < 0):
                    eprint("Error: Block data overflow (> 108 words)")
                else:
                    for i in range(4):
                        block[block_idx-3+i] = quad_data & 0x1fffffff
                        quad_data >>= 29
                    block_idx -= 4
                quad_data = 0
                quad_digits = 0
                minus = False
                if (pt_char == 'S'):
                    break
            case ' ':
                #if block_idx != 107 or quad_digits != 0:
                    #print("Extraneous space in block:", block_idx, quad_digits)
                continue
            case _:
                eprint("Error: Invalid character in PT block3:", pt_char)

    if block_idx == 107:
        return []

    # A short block (< 108 words) is shifted to origin 0 and truncated
    if (block_idx != -1):
        short_block_size = 107 - block_idx
        for i in range(short_block_size):
            block[i] = block[i+block_idx+1]
        block = block[:short_block_size]

    return block

def read_pt_file(pt_file):
    blocks = []
    while True:
        block = read_pt_block(pt_file)
        if block == []:
            break
        blocks.append(block)
    return blocks

def read_json_block(json_block):
    # fill block_data array with value indicating undefined for debug
    block = 108 * [0xf0000000]
    block_idx = 107
    quad_data = 0
    quad_digits = 0
    minus = False

    # iterate over data string one character at a time
    for json_char in json_block["data"]:
        match json_char:
            case '0' | '1' | '2' | '3' | '4' | '5' | '6' | '7' | '8' | '9':
                # convert character to 4-bit integer and insert into quad
                quad_data = (quad_data << 4) | (ord(json_char) - ord('0'))
                quad_digits += 1
            case 'u' | 'v' | 'w' | 'x' | 'y' | 'z':
                quad_data = (quad_data << 4) | (ord(json_char) - ord('u') + 10)
                quad_digits += 1
            case '-':
                minus = True
            case 'S' | 'R':
                if (quad_digits != 29):
                    eprint("Error: Invalid number of digits in quad data", quad_digits, block_idx)
                if (block_idx < 0):
                    eprint("Error: Block data overflow (> 108 words)")
                else:
                    for i in range(4):
                        block[block_idx-3+i] = quad_data & 0x1fffffff
                        quad_data >>= 29
                    block_idx -= 4
                quad_data = 0
                quad_digits = 0
                minus = False
            case _:
                eprint("Error: Invalid character in block data:", json_char)

    # A short block (< 108 words) is shifted to origin 0 and truncated
    if (block_idx != -1):
        short_block_size = 107 - block_idx
        for i in range(short_block_size):
            block[i] = block[i+block_idx+1]
        block = block[:short_block_size]
    return block

def read_json_file(json_file):
    try:
        json_db = json.load(json_file)
    except:
        eprint("Error: Invalid JSON file format")
        return []

    all_blocks = []
    block_idx = 0
    for json_block in json_db["entries"]:
        block_num = json_block["blocknum"]
        block_errs = json_block["nerrors"]
        block_checksum = json_block["checksum"]
        block = read_json_block(json_block)
        all_blocks.append(block)
        calc_checksum = word29_to_str(checksum(block))
        print("Index:", block_idx, "Block:", block_num, "Len:", len(block), "Errors:", block_errs, "Checksum:", block_checksum, "Calc:", calc_checksum)
        block_idx += 1

    # find block number range in json_block
    block_num_max = 0
    for json_block in json_db["entries"]:
        block_num = json_block["blocknum"]
        if block_num > block_num_max:
            block_num_max = block_num
    # create 1 to many map of tape block numbers to index into json_db["entries"]
    block_map = [[] for i in range(block_num_max + 1)]
    #print("Block map:", block_map)
    entry_idx = 0
    for json_block in json_db["entries"]:
        block_num = json_block["blocknum"]
        block_map[block_num].append(entry_idx)
        #print("Block:", block_num, "Entry:", entry_idx, "Map:", block_map)
        entry_idx += 1
    # select one json_db["entries"] block for each tape block
    blocks = []
    map_idx = 0
    print("Block map:", block_map)
    for map in block_map:
        if len(map) == 0:
            if map_idx != 0:
                eprint("Error: Missing block in JSON file:", map_idx)
            continue
        min_errs = 99999
        sel_entry_idx = 0
        for entry_idx in map:
            entry = json_db["entries"][entry_idx]
            if entry["nerrors"] < min_errs:
                min_errs = entry["nerrors"]
                sel_entry_idx = entry_idx
        if json_db["entries"][sel_entry_idx]["nerrors"] > 0:
            eprint("Warning: Block", map_idx, "has errors:", json_db["entries"][sel_entry_idx]["nerrors"])
        blocks.append(read_json_block(json_db["entries"][sel_entry_idx]))
        map_idx += 1

    return blocks

# -----------------------------------------------------------------------------
# The mighty G-15 assembler
# -----------------------------------------------------------------------------
def str_asm_word29(s):
    pfx = ""
    bp = 0
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
        if (i == 4):
            if (fields[i][-1] == "*"):
                bp = 1
                fields[i] = fields[i][:-1]
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

    return ((i_d << 28) | (t << 21) | (bp << 20) | (n << 13) | (ch << 11) | (src << 6) | (d << 1) | s_d)

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

def assemble_file(asm_file):
    block = 108 * [0xf0000000]
    block_map = []
    line_no = 0
    for line in asm_file:
        line_no += 1
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
            if (block[addr] != 0xf0000000):
                eprint("Duplicate address in asm file: " + line)
            else:
                block[addr] = data
                map_code = 'A' if is_asm else 'C'
                block_map.append([map_code, addr])
    return [block, block_map]

# -----------------------------------------------------------------------------
# G-15 disassembler
# -----------------------------------------------------------------------------
def print_block_raw(block, list_file):
    print("Block raw data:", file=list_file)
    for i in range(len(block)):
        if (i % 10 == 0 and i != 0):
            print("", file=list_file)
        if (i % 10 == 0):
            print("    " + bin_to_dstr(i) + ":", end="", sep="", file=list_file)
        if (block[i] == 0xf0000000):
            print("   --------", end="", file=list_file)
        else:
            print(" ", word29_to_str(block[i]), end="", file=list_file)

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
            bin_to_dstr1(c) + "." + bin_to_dstr(s) + "." +
            bin_to_dstr(d)) + ("*" if (bp == 1) else " ")

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
    is_abs = is_imm and not is_rel
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
        elif (cname == "19"):
            if (ch == 0):
                cname = "Start_DA-1"
            elif (ch == 1):
                cname = "Stop_DA-1"
        elif (cname == "20"):
            cname = "Return_Exit->" + cl_name[c] + "[" + bin_to_dstr(n) + "]"
        elif (cname == "21"):
            cname = "Mark_Exit->" + cl_name[c] + "[" + bin_to_dstr(n) + "]"
        elif (cname == "23"):
            if (ch == 0):
                cname = "Clear"
            elif (ch == 3):
                cname = "PN&M2->ID, PN&~M2->PN"
        elif (cname == "25"):
            if (ch == 1):
                cname = "Divide"
        elif (cname == "26"):
            if (ch == 0):
                cname = "Shift_MQ_ID+"
            elif (ch == 1):
                cname = "Shift_MQ_ID"
        elif (cname == "27"):
            if (ch == 0):
                cname = "Normalize+"
            elif (ch == 1):
                cname = "Normalize"
        elif (cname == "28"):
            if (ch == 0):
                cname = "Ready_Test"
            elif (ch == 1):
                cname = "Ready_In_Test"
            elif (ch == 2):
                cname = "Ready_Out_Test"
            elif (ch == 3):
                cname = "DA-1_Off_Test"
        elif (cname == "30"):
            cname = "MT_Write_FC" + str(ch)
        elif (cname == "31"):
            if (ch == 0):
                cname = "Next_Command_AR"
            elif (ch == 1):
                cname = "CN|M18->M18"
            elif (ch == 2):
                cname = "M18|M20->M18"

        semantics += " " + cname
    else:
        # transfer command
        ttype = (ch + 4) if (s > 27 or d > 27) else ch
        semantics += " " + s_name[s] + "->" + tr_type[ttype] + "->" + d_name[d]
    return semantics

def print_block_decoded(block_data, block_map, list_file):
    print("\nDecoded block data:", file=list_file)
    for i in range(len(block_map)):
        kind = block_map[i][0]
        addr = block_map[i][1]
        word = block_data[addr]
        print("    " + bin_to_dstr(addr) + ": ", end="", sep="", file=list_file)
        if (kind == 'C'):
            print(word29_to_str(word), sep="", file=list_file)
        else:
            print(command_to_pprasm(word), "   # ", command_to_semantics(word, addr), sep="", file=list_file)
 
def usage():
    eprint("Usage: g15util.py cmd [args]")
    eprint("Commands:")
    eprint("  g15util.py asm <input file>")
    eprint("  g15util.py dis <input file> [block_no]")
    eprint("  g15util.py cvt -t \"pt\" | \"pti\" <input file>")
    sys.exit(1)

def open_input_file(fn, f_mode="r"):
    try:
        f = open(fn, mode=f_mode)
    except FileNotFoundError:
        eprint("Error: Input file not found:", fn)
        sys.exit(1)
    except:
        eprint("Error: Error opening input file:", fn)
        sys.exit(1)
    return f

def open_output_file(fn, f_mode="w"):
    try:
        f = open(fn, mode=f_mode)
    except:
        eprint("Error: Error opening output file:", fn)
        sys.exit(1)
    return f

def assemble():
    if (len(sys.argv) != 3):
        usage()
    asm_fn = sys.argv[2]
    fname, fext = os.path.splitext(asm_fn)
    if fext != ".asm":
        eprint("Error: Input filename must have .asm extension:", asm_fn)
        sys.exit(1)
    asm_file = open_input_file(asm_fn)
    list_fn = fname + ".lst"
    list_file = open_output_file(list_fn)
    pti_fn = fname + ".pti"
    pti_file = open_output_file(pti_fn)
    print("Assembling:", asm_fn)
    [block, block_map] = assemble_file(asm_file)
    print_block_raw(block, list_file)
    # replace unused words in block with 0
    for i in range(len(block)):
        if (block[i] == 0xf0000000):
            block[i] = 0
    print("\nCalculated checksum:", word29_to_str(checksum(block)), file=list_file)
    print_block_decoded(block, block_map, list_file)
    print_pti_block(block, pti_file)
    list_file.close()
    pti_file.close()
    asm_file.close()

def disassemble():
    if (len(sys.argv) > 4):
        usage()
    dis_fn = sys.argv[2]
    single_block = True if len(sys.argv) == 4 else False
    if single_block:
        try:
            block_no = int(sys.argv[3])
        except:
            usage()
        
    fname, fext = os.path.splitext(dis_fn)
    if fext == ".pt":
        dis_file = open_input_file(dis_fn, "rb")
    else:
        dis_file = open_input_file(dis_fn)
    list_fn = fname + ".dislst"
    list_file = open_output_file(list_fn)
    blocks = []
    if fext == ".pti":
        blocks = read_pti_file(dis_file)
    elif fext == ".pt":
        blocks = read_pt_file(dis_file)
    else:
        blocks = read_json_file(dis_file)
    block_no = 0
    for block in blocks:
        print("\nBlock number:", block_no, file=list_file)
        print_block_raw(block, list_file)
        print("\nCalculated checksum:", word29_to_str(checksum(block)), file=list_file)
        # create simple block map, all words are considered to be commands
        block_map = []
        for i in range(len(block)):
            block_map.append(['A', i])
        print_block_decoded(block, block_map, list_file)
        block_no += 1
    list_file.close()
    dis_file.close()

def convert():
    try:
        opts, args = getopt.getopt(sys.argv[2:], "t:")
    except getopt.GetoptError as err:
        eprint(str(err))
        usage()
    target_ft = ""
    for o, a in opts:
        if o == "-t":
            if a == "pt":
                print("Converting to PT...")
                target_ft = "pt"
            elif a == "pti":
                print("Converting to PTI...")
                target_ft = "pti"
            else:
                usage()
        else:
            usage()
    if target_ft == "":
        usage()
    if len(args) != 1:
        usage()

    cvt_fn = args[0]
    fname, fext = os.path.splitext(cvt_fn)    
    if fext == ".pt":
        cvt_file = open_input_file(cvt_fn, "rb")
    else:
        cvt_file = open_input_file(cvt_fn)

    if fext == ".pti":
        blocks = read_pti_file(cvt_file)
    elif fext == ".pt":
        blocks = read_pt_file(cvt_file)
    else:
        blocks = read_json_file(cvt_file)
    print("target_ft:", target_ft)
    if target_ft == "pt":
        print("Converting to pt...")
        pt_fn = fname + ".pt"
        pt_file = open_output_file(pt_fn, "wb")
        blanks = 30
        for block in blocks:
            for ctr in range(0, blanks):
                pt_file.write(bytes([0]))
            blanks = 75
            print_pt_block(block, pt_file)
        for ctr in range(0, 30):
            pt_file.write(bytes([0]))
        pt_file.close()
    elif target_ft == "pti":
        print("Converting to pti...")
        pti_fn = fname + ".pti"
        pti_file = open_output_file(pti_fn)
        for block in blocks:
            print_pti_block(block, pti_file)
        pti_file.close()
    cvt_file.close()

def balance():
    if (len(sys.argv) != 4):
        usage()
    try:
        r_sum = str_to_word29(sys.argv[2])
        a_sum = str_to_word29(sys.argv[3])
    except ValueError as e:
        eprint(e)
        usage()
    adj = balance_checksum(r_sum, a_sum)
    print("r_sum:", word29_to_str(r_sum), "a_sum:", word29_to_str(a_sum),
          "adj:", word29_to_str(adj), "sum:", word29_to_str(add_29(a_sum, adj)))
    
def sum():
    if (len(sys.argv) != 4):
        usage()
    try:
        ar_add = str_to_word29(sys.argv[2])
        v_add = str_to_word29(sys.argv[3])
    except ValueError as e:
        eprint(e)
        usage()
    sum = add_29(ar_add, v_add)
    print("ar_add:", word29_to_str(ar_add), "v_add:", word29_to_str(v_add),
          "sum:", word29_to_str(sum))
    
def main():
    if len(sys.argv) < 2:
        usage()

    cmd = sys.argv[1]
    if cmd == "asm":
        assemble()
    elif cmd == "dis":
        disassemble()
    elif cmd == "cvt":
        convert()
    elif cmd == "bal":
        balance()
    elif cmd == "sum":
        sum()
    else:
        usage()

if __name__ == "__main__":
    main()
