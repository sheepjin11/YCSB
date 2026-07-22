# Yahoo! Cloud System Benchmark
# Load: uniform rand inserts (24B key, 1KiB value)

recordcount=84750000
workload=com.yahoo.ycsb.workloads.CoreWorkload

# Key: 24 bytes (user + zeropadding)
zeropadding=20

# Value: 1024 bytes
fieldcount=1
fieldlength=1024
