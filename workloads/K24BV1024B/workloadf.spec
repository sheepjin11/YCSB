# Yahoo! Cloud System Benchmark
# Workload F: Read-modify-write workload
#   50% read, 50% RMW

operationcount=10000000
workload=com.yahoo.ycsb.workloads.CoreWorkload

fieldcount=1
fieldlength=1024
zeropadding=20

readallfields=true
readproportion=0.5
updateproportion=0
scanproportion=0
insertproportion=0
readmodifywriteproportion=0.5

requestdistribution=zipfian

