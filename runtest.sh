mongo 127.0.0.1:27017/ycsb --eval "db.dropDatabase()"
./ycsb/bin/ycsb load mongodb-async -s -P ycsb/workloads/workloada -threads $1 -p recordcount=$2 > outputLoadA.txt
./ycsb/bin/ycsb run mongodb-async -s -P ycsb/workloads/workload1 -threads $1 -p recordcount=$2 -p operationcount=$3 > outputRunA.txt
./ycsb/bin/ycsb run mongodb-async -s -P ycsb/workloads/workloadb -threads $1 -p recordcount=$2 -p operationcount=$3 > outputRunB.txt
./ycsb/bin/ycsb run mongodb-async -s -P ycsb/workloads/workloadc -threads $1 -p recordcount=$2 -p operationcount=$3 > outputRunC.txt
./ycsb/bin/ycsb run mongodb-async -s -P ycsb/workloads/workloadf -threads $1 -p recordcount=$2 -p operationcount=$3 > outputRunF.txt
./ycsb/bin/ycsb run mongodb-async -s -P ycsb/workloads/workloadd -threads $1 -p recordcount=$2 -p operationcount=$3 > outputRunD.txt
mongo 127.0.0.1:27017/ycsb --eval "db.dropDatabase()"
./ycsb/bin/ycsb load mongodb-async -s -P ycsb/workloads/workloade -threads $1 -p recordcount=$2 > outputLoadE.txt
./ycsb/bin/ycsb run mongodb-async -s -P ycsb/workloads/workloade -threads $1 -p recordcount=$2 -p operationcount=$3 > outputRunE.txt
