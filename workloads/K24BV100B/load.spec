# Yahoo! Cloud System Benchmark
# Load: uniform rand inserts

# Load phase for ATC'20 SplinterDB YCSB (100B values)

recordcount=685000000
workload=com.yahoo.ycsb.workloads.CoreWorkload

# Key: 24 bytes (user + zeropadding)
zeropadding=20

# Value: 100 bytes
fieldcount=1
fieldlength=100

