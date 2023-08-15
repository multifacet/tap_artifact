#!/usr/bin/python3

# Parses Spigot log files and spits out:
# (i) Avg Applet Execution time (ii) Applet memory usage (iii) Enclave startup time

import sys
from parse import parse

def usage():
    print ("python3 parse_results.py <log_file>")
    sys.exit(1)

def conv_to_secs(s: str):
    if s[-2:] == 'ms':
        return float(s[:-2]) * 0.001
    if s[-2:] == 'us':
        return float(s[:-2]) * 0.000001
    if s[-1] == 's':
        return float(s[:-1])

def parse_memory_usage(lines: list[str]):
    for line in lines:
        line_stripped = line.strip()
        if line_stripped.startswith("Requesting"):
            res = parse("Requesting {} pages from the kernel", line_stripped)
            return res.fixed[0]


def parse_applet_exec_time(lines: list[str], line_prefix: str):
    res = []
    for line in lines:
        if line.startswith("Enclave Exec time:"):
            exec_time = line.split("Enclave Exec time:")[1].strip()
            res = res + [conv_to_secs(exec_time)]
    return res


def main():
    filename = sys.argv[1]
    lines = open(filename, "r+").readlines()

    res = parse_applet_exec_time(lines, "")
    print (res)
    res = parse_memory_usage(lines)
    print (res)

main()
