#!/bin/bash

MONGODB_IP="127.0.0.1"
MONGODB_PORT=27017
DATABASE="ycsb"

RECORD_COUNT=1000
OPERATION_COUNT=1000
THREADS=1

help()
{
  echo "This script helps you automatically test MongoDB with YCSB."
  echo "Options:"
  echo "          -i MongoDB server ip address, default will be $MONGODB_IP"
  echo "          -p MongoDB server port, default will be $MONGODB_PORT"
  echo "          -d Test database name, default will be $DATABASE"
  echo "          -r Record count for YCSB workloads, default will be $RECORD_COUNT"
  echo "          -o Operation count for YCSB workloads, default will be $OPERATION_COUNT"
  echo "          -t Threads for YCSB workloads, default will be $THREADS"
}

# Parse script parameters
while getopts :m:r:o:t:h optname; do  
  case $optname in
    i) # mongoDB ip
      MONGODB_IP=${OPTARG}
      ;;
    p) # mongoDB port
      MONGODB_PORT=${OPTARG}
      ;;
    d) # mongoDB database
      DATABASE=${OPTARG}
      ;;
    r) # record count
      RECORD_COUNT=${OPTARG}
      ;;
    o) # operation count
      OPERATION_COUNT=${OPTARG}
      ;;
    t) # threads
      THREADS=${OPTARG}
      ;;
    h) # help
      help
      exit 2
      ;;
    \?) # Unrecognized option - show help
      echo -e \\n"Option -${BOLD}$OPTARG${NORM} not allowed."
      help
      exit 2
      ;;
  esac
done

install_java()
{
    sudo apt-get update

    # install java
    sudo apt-get install -y default-jre
    sudo apt-get install -y default-jdk

    # install maven
    sudo apt-get install -y maven
}

install_ycsb()
{
    curl -O --location https://github.com/brianfrankcooper/YCSB/releases/download/0.8.0/ycsb-0.8.0.tar.gz
    tar xfvz ycsb-0.8.0.tar.gz
    rm ycsb-0.8.0.tar.gz
    mv ycsb-0.8.0 ycsb
}

full_workload_test(){
  DB_URL=$MONGODB_IP:$MONGODB_PORT/$DATABASE
  MONGODB_CONN_STR=mongodb://$DB_URL?w=1

  mongo $DB_URL --eval "db.dropDatabase()"
  ./ycsb/bin/ycsb load mongodb-async -s -P ycsb/workloads/workloada -threads $THREADS -p mongodb.url=$MONGODB_CONN_STR -p recordcount=$RECORD_COUNT > outputLoadA.txt
  ./ycsb/bin/ycsb run mongodb-async -s -P ycsb/workloads/workload1 -threads $THREADS -p mongodb.url=$MONGODB_CONN_STR -p recordcount=$RECORD_COUNT -p operationcount=$OPERATION_COUNT > outputRunA.txt
  ./ycsb/bin/ycsb run mongodb-async -s -P ycsb/workloads/workloadb -threads $THREADS -p mongodb.url=$MONGODB_CONN_STR -p recordcount=$RECORD_COUNT -p operationcount=$OPERATION_COUNT > outputRunB.txt
  ./ycsb/bin/ycsb run mongodb-async -s -P ycsb/workloads/workloadc -threads $THREADS -p mongodb.url=$MONGODB_CONN_STR -p recordcount=$RECORD_COUNT -p operationcount=$OPERATION_COUNT > outputRunC.txt
  ./ycsb/bin/ycsb run mongodb-async -s -P ycsb/workloads/workloadf -threads $THREADS -p mongodb.url=$MONGODB_CONN_STR -p recordcount=$RECORD_COUNT -p operationcount=$OPERATION_COUNT > outputRunF.txt
  ./ycsb/bin/ycsb run mongodb-async -s -P ycsb/workloads/workloadd -threads $THREADS -p mongodb.url=$MONGODB_CONN_STR -p recordcount=$RECORD_COUNT -p operationcount=$OPERATION_COUNT > outputRunD.txt
  mongo $DBURL --eval "db.dropDatabase()"
  ./ycsb/bin/ycsb load mongodb-async -s -P ycsb/workloads/workloade -threads $THREADS -p mongodb.url=$MONGODB_CONN_STR -p recordcount=$RECORD_COUNT > outputLoadE.txt
  ./ycsb/bin/ycsb run mongodb-async -s -P ycsb/workloads/workloade -threads $THREADS -p mongodb.url=$MONGODB_CONN_STR -p recordcount=$RECORD_COUNT -p operationcount=$OPERATION_COUNT > outputRunE.txt
}

install_java
install_ycsb
full_workload_test
