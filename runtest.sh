mongo 127.0.0.1:27017/ycsb --eval "db.usertable.remove({})"
./ycsb/bin/ycsb load mongodb-async -s -P workload1 > outputLoad.txt
