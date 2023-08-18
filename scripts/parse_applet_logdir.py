#!/usr/bin/python3

# Parses Spigot enclave log files and spits out:
# (i) Avg Applet Execution time (ii) Applet memory usage (iii) Enclave startup time

import sys
import os
import statistics

def usage():
    print ("python3 parse_results.py <logfile_dir> <log_type>")
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
            res = float(line_stripped.split(" ")[1])
            return res
        
def parse_baseline_memory_usage(lines: list[str]):
    for line in lines:
        line_stripped = line.strip()
        if line_stripped.startswith("rss:"):
            res = float(line_stripped.split(" ")[1][1:])
            return res

def parse_applet_exec_time(lines: list[str], line_prefix: str):
    res = []
    for line in lines:
        line = line.strip()
        if line.startswith("Enclave Exec time:"):
            exec_time = line.split("Enclave Exec time:")[1].strip()
            res = res + [conv_to_secs(exec_time)]
    return res

def parse_enclave_startup_time(lines: list[str]):
    res = []
    for line in lines:
        if line.startswith("Enclave Init time:"):
            encl_init_time = line.split("Enclave Init time:")[1].strip()
            res = res + [conv_to_secs(encl_init_time)]
    return res[0]

def parse_baseline_applet_exec_time(lines: list[str]):
    res = []
    for line in lines:
        line = line.strip()
        if line.startswith("applet_exec_time:"):
            exec_time = line.split("applet_exec_time:")[1].strip()
            res = res + [conv_to_secs(exec_time)]
    return res

def main():
    #filename = sys.argv[1]
    #lines = open(filename, "r+").readlines()

    #applet_exec_times = parse_applet_exec_time(lines, "")
    #applet_exec_avg = statistics.fmean(applet_exec_times)
    #applet_exec_stdev = statistics.stdev(applet_exec_times)

    #mem_usage = float(parse_memory_usage(lines))
    #encl_startup_time = float(parse_enclave_startup_time(lines))
    
    #print ("Applet Execution Time, Avg: %f seconds and Stdev: %f seconds" % (applet_exec_avg, applet_exec_stdev))
    #print ("Applet Memory Usage: %f pages = %f MB" % (mem_usage, mem_usage * 4.0 * (1/1024.0)))
    #print ("Enclave Startup Time: %f seconds" % (encl_startup_time))

    if len(sys.argv) != 3:
        print ("Not enough arguments")
        usage()
        exit(1)

    logdir = sys.argv[1]
    logtype = sys.argv[2]

    if logtype not in ["spigot", "spigot_base", "baseline_tap"]:
        print ("Invalid logtype")
        exit(1)

    applet_exec_time = []
    memory_usage = []
    applet_startup_time = []

    for file in os.listdir(logdir):
        print ("Processing: " + file)
        logfile_lines = open(logdir + "/" + file, "r+").readlines()
        if logtype == "spigot":
            applet_exec_times = parse_applet_exec_time(logfile_lines, "")
            applet_exec_time += applet_exec_times

            mem_usage = parse_memory_usage(logfile_lines)
            memory_usage += [mem_usage]

            startup_time = parse_enclave_startup_time(logfile_lines)
            applet_startup_time += [startup_time]

        elif logtype == "spigot_base":
            applet_exec_times = parse_applet_exec_time(logfile_lines, "")
            applet_exec_time += applet_exec_times
        
        elif logtype == "baseline_tap":
            applet_exec_times = parse_baseline_applet_exec_time(logfile_lines)
            applet_exec_time += applet_exec_times

            mem_usage = parse_baseline_memory_usage(logfile_lines)
            memory_usage += [mem_usage]
        else:
            print ("Should not reach here")
            exit(-1)
        
    if logtype == "spigot":
        applet_exec_avg = statistics.fmean(applet_exec_time)
        applet_exec_stdev = statistics.stdev(applet_exec_time)

        avg_mem_usage = statistics.fmean(memory_usage)

        avg_encl_startup_time = statistics.fmean(applet_startup_time)

        print ("Applet Execution Time, Avg: %f seconds and Stdev: %f seconds" % (applet_exec_avg, applet_exec_stdev))
        print ("Applet Memory Usage, Avg: %f pages = %f MB" % (avg_mem_usage, avg_mem_usage * 4.0 * (1/1024.0)))
        print ("Enclave Startup Time, Avg: %f seconds" % (avg_encl_startup_time))
    elif logtype == "spigot_base":
        applet_exec_avg = statistics.fmean(applet_exec_time)
        applet_exec_stdev = statistics.stdev(applet_exec_time)

        print ("Applet Execution Time, Avg: %f seconds and Stdev: %f seconds" % (applet_exec_avg, applet_exec_stdev))

    elif logtype == "baseline_tap":
        applet_exec_avg = statistics.fmean(applet_exec_time)
        applet_exec_stdev = statistics.stdev(applet_exec_time)

        avg_mem_usage = statistics.fmean(memory_usage)

        print ("Applet Execution Time, Avg: %f seconds and Stdev: %f seconds" % (applet_exec_avg, applet_exec_stdev))
        print ("Memory Usage, Avg: %f MB" % (avg_mem_usage / (1024.0 * 1024.0)))
    
if __name__ == "__main__":
    main()
