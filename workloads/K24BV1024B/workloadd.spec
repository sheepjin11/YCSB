# Yahoo! Cloud System Benchmark
# Workload D: Read latest workload
#   95% read, 5% insert

operationcount=10000000
workload=com.yahoo.ycsb.workloads.CoreWorkload

fieldcount=1
fieldlength=1024
zeropadding=20

readallfields=true
readproportion=0.95
updateproportion=0
scanproportion=0
insertproportion=0.05

requestdistribution=latest

