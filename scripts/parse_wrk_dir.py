#!/usr/bin/python3

# Parses Spigot enclave log files and spits out:
# (i) Avg Applet Execution time (ii) Applet memory usage (iii) Enclave startup time

import sys
import os
import statistics

def usage():
    print ("python3 parse_results.py <wrk_log_directory>")
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

def parse_enclave_startup_time(lines: list[str]):
    res = []
    for line in lines:
        if line.startswith("Enclave Init time:"):
            encl_init_time = line.split("Enclave Init time:")[1].strip()
            res = res + [conv_to_secs(encl_init_time)]
    return res[0]

def parse_wrk_latency_throughput(lines: list[str]):
    latency = 100000
    throughput = 0
    for line in lines:
        line = line.strip()
        if line.startswith("Latency"):
            avg_lat = line.split(" ")[4].strip()
            latency = conv_to_secs(avg_lat)
        if line.startswith("Requests/sec"):
            throughput = float(line.split(" ")[5].strip())
    
    return (latency, throughput)


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

    dir_name = sys.argv[1]
    latency = []
    throughput = []

    for filename in os.listdir(dir_name):
        logfile_lines = open(dir_name + "/" + filename, "r+").readlines()
        lat, thrpt = parse_wrk_latency_throughput(logfile_lines)
        latency = latency + [lat]
        throughput = throughput + [thrpt]

    print ("Average Latency: %f seconds, stdev: %f seconds" % (statistics.fmean(latency), statistics.stdev(latency)))
    print ("Average Throughput: %f Requests/sec, stdev: %f Requests/sec" % (statistics.fmean(throughput), statistics.stdev(throughput)))

main()
