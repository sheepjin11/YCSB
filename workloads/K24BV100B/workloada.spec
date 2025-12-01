# Yahoo! Cloud System Benchmark
# Workload A: Update heavy workload
#   Application example: Session store recording recent actions
#                        
#   Read/update ratio: 50/50
#   Default data size: 1 KB records (10 fields, 100 bytes each, plus key)
#   Request distribution: zipfian


operationcount=160000000
workload=com.yahoo.ycsb.workloads.CoreWorkload

fieldcount=1
fieldlength=100
zeropadding=20

# Workload A: 50% read, 50% update
readallfields=true
readproportion=0.5
updateproportion=0.5
scanproportion=0
insertproportion=0

requestdistribution=zipfian
