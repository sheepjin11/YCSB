# Yahoo! Cloud System Benchmark
# Workload E: Short ranges
#   95% scan, 5% insert

operationcount=1300000
workload=com.yahoo.ycsb.workloads.CoreWorkload

fieldcount=1
fieldlength=1024
zeropadding=20

readallfields=true
readproportion=0
updateproportion=0
insertproportion=0.05
scanproportion=0.95

requestdistribution=zipfian

maxscanlength=100
scanlengthdistribution=uniform

