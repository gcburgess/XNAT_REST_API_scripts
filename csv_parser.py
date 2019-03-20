#!/usr/bin/env python3

import sys
import csv
import getopt



def main(argv):
    try:
        opts, args = getopt.getopt(argv,"sc")
    except getopt.GetoptError:
        print("Use command-line option -s to parse sessions")
        print("Use command-line option -c to parse scans")
        print("e.g.: csv_parser.py -s")
        sys.exit(2)
    for opt, arg in opts:
        if opt == '-h':
            print("Use command-line option -s to parse sessions")
            print("Use command-line option -c to parse scans")
            print("e.g.: csv_parser.py -s")
            sys.exit()
        elif opt in ("-s"):
            method = "session"
        elif opt in ("-c"):
            method = "scan"
    #print("Method is", method)

    # use stdin if it's full                                                        
    if not sys.stdin.isatty():
        input_stream = sys.stdin

    # otherwise, read the given filename                                            
    else:
        try:
            input_filename = sys.argv[1]
        except IndexError:
            message = 'need filename as first argument if stdin is not full'
            raise IndexError(message)
        else:
            input_stream = open(input_filename, 'rU')

    for line in input_stream:
        #print line # do something useful with each line
        for row in csv.reader([line], delimiter=',', quotechar='"'):
            if method == "session":
        	    print("%s,%s,%s,%s,%s,%s,\"%s\"" % (row[2], row[6], row[5], row[3], row[7], row[8], row[4]))
            elif method == "scan":
                print("%s,%s,%s,%s,%s,%s,%s,\"%s\"" % (row[1], row[2], row[3], row[4], row[5], row[6], row[8], row[7]))
            else:
                print("INVALID METHOD",method)
                sys.exit(2)

if __name__ == "__main__":
    main(sys.argv[1:])
