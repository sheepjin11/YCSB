# Yahoo! Cloud System Benchmark
# Workload B: Read mostly workload
#   95% read, 5% update

operationcount=10000000
workload=com.yahoo.ycsb.workloads.CoreWorkload

fieldcount=1
fieldlength=1024
zeropadding=20

readallfields=true
readproportion=0.95
updateproportion=0.05
scanproportion=0
insertproportion=0

requestdistribution=zipfian

