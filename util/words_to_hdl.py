#!/usr/bin/env python3

import sys

def print_help_text():
    print('''Usage: words_to_hdl.py WORDS_FILE HDL_FILE HDL_VECTOR_NAME
Output is written between tags --BEGIN_WORDS_ENTRY and --END_WORDS_ENTRY.
Tags have to appear alone on a line.
Existing text between tags is deleted.''')

if __name__ == '__main__':
    # TODO Implement argument parsing
    if (len(sys.argv) != 4):
        print_help_text()
        exit()

    with open(sys.argv[1], 'r') as words_f, open(sys.argv[2], 'r') as hdl_f:
        words = words_f.readlines()
        hdl = hdl_f.readlines()

    with open(sys.argv[2], 'w') as hdl_f:
        in_tags = False
        idx = 0

        for line in hdl:
            if in_tags == False:
                hdl_f.write(line)

            if line.strip() == '--BEGIN_WORDS_ENTRY':
                in_tags = True
                for word in words:
                    word_entry = sys.argv[3] + '(' + str(idx) + ') <= "' + word.strip() + '";\n'
                    idx += 1
                    hdl_f.write(word_entry)
            elif line.strip() == '--END_WORDS_ENTRY':
                in_tags = False
                hdl_f.write(line)
