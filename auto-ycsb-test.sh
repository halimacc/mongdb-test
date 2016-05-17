#!/bin/bash
#
#--------------------------------------------------------------------------------------------------
# This script helps you automatically test MongoDB with YCSB. This script runs on Ubuntu, and will
# install java and maven if they had not been installed. Test routine in this script follows YCSB
# core workloads, at https://github.com/brianfrankcooper/YCSB/wiki/Core-Workloads.
#
# An example of test local MongoDB server with 32 thread, 1 million records and operations:
#     bash auto-ycsb-test -i 127.0.0.1 -t 32 -r 1000000 -o 1000000
# 
# For more infomation about parameters, type:
#     bash auto-ycsb-test -h
#
#----------------------------------------------------------------------------------------------


MONGODB_IP="127.0.0.1"
MONGODB_PORT=27017
DATABASE="ycsb"

RECORD_COUNT=1000
OPERATION_COUNT=1000
THREADS=1

OUTPUT="./result"

help()
{
  echo "This script helps you automatically test MongoDB with YCSB."
  echo "Options:"
  echo "    -d Directory for test result, default will be $OUTPUT"
  echo "    -i MongoDB server IP address, default will be $MONGODB_IP"
  echo "    -n Test database name, default will be $DATABASE"
  echo "    -o Operation count of YCSB workloads, default will be $OPERATION_COUNT"
  echo "    -p MongoDB server port, default will be $MONGODB_PORT"
  echo "    -r Record count of YCSB workloads, default will be $RECORD_COUNT"
  echo "    -t Thread count of YCSB test client, default will be $THREADS"
}

# Parse script parameters
while getopts :d:i:n:o:p:r:t:h optname; do  
  case $optname in
    d) # Directory for test result
      OUTPUT=${OPTARG}
      ;;
    i) # MongoDB server IP address
      MONGODB_IP=${OPTARG}
      ;;
    n) # Test database name
      DATABASE=${OPTARG}
      ;;
    o) # Operation count
      OPERATION_COUNT=${OPTARG}
      ;;
    p) # MongoDB server port
      MONGODB_PORT=${OPTARG}
      ;;
    r) # Record count
      RECORD_COUNT=${OPTARG}
      ;;
    t) # Threads
      THREADS=${OPTARG}
      ;;
    h) # Help
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
    UPDATED=false

    # check and install java
    if type -p java; then
        echo Java installed
    elif [[ -n "$JAVA_HOME" ]] && [[ -x "$JAVA_HOME/bin/java" ]];  then
        echo Java installed
    else
        echo No Java installation found, install Java
        sudo apt-get update
        UPDATED=true
        sudo apt-get install -y default-jre
        sudo apt-get install -y default-jdk
    fi

    # check and install maven
    if type -p mvn; then
        echo Maven installed
    else
        echo No Maven installation found, install Maven
        if [ !UPDATED ]; then
            sudo apt-get update
        fi
        sudo apt-get install -y maven
    fi
}

install_ycsb()
{
    if [ ! -d ycsb ]; then
        curl -O --location https://github.com/brianfrankcooper/YCSB/releases/download/0.8.0/ycsb-0.8.0.tar.gz
        tar xfvz ycsb-0.8.0.tar.gz
        rm ycsb-0.8.0.tar.gz
        mv ycsb-0.8.0 ycsb
    fi
}

full_workload_test(){
  DB_URL=$MONGODB_IP:$MONGODB_PORT/$DATABASE
  MONGODB_CONN_STR=mongodb://$DB_URL?w=1

  if [ ! -d "$OUTPUT" ]; then
    mkdir -p $OUTPUT 
  fi 

  mongo $DB_URL --eval "db.usertable.remove({})"
  ./ycsb/bin/ycsb load mongodb-async -s -P ycsb/workloads/workloada -threads $THREADS -p mongodb.url=$MONGODB_CONN_STR -p recordcount=$RECORD_COUNT > $OUTPUT/load_a.txt
  ./ycsb/bin/ycsb run mongodb-async -s -P ycsb/workloads/workload1 -threads $THREADS -p mongodb.url=$MONGODB_CONN_STR -p recordcount=$RECORD_COUNT -p operationcount=$OPERATION_COUNT > $OUTPUT/run_a.txt
  ./ycsb/bin/ycsb run mongodb-async -s -P ycsb/workloads/workloadb -threads $THREADS -p mongodb.url=$MONGODB_CONN_STR -p recordcount=$RECORD_COUNT -p operationcount=$OPERATION_COUNT > $OUTPUT/run_b.txt
  ./ycsb/bin/ycsb run mongodb-async -s -P ycsb/workloads/workloadc -threads $THREADS -p mongodb.url=$MONGODB_CONN_STR -p recordcount=$RECORD_COUNT -p operationcount=$OPERATION_COUNT > $OUTPUT/run_c.txt
  ./ycsb/bin/ycsb run mongodb-async -s -P ycsb/workloads/workloadf -threads $THREADS -p mongodb.url=$MONGODB_CONN_STR -p recordcount=$RECORD_COUNT -p operationcount=$OPERATION_COUNT > $OUTPUT/run_f.txt
  ./ycsb/bin/ycsb run mongodb-async -s -P ycsb/workloads/workloadd -threads $THREADS -p mongodb.url=$MONGODB_CONN_STR -p recordcount=$RECORD_COUNT -p operationcount=$OPERATION_COUNT > $OUTPUT/run_d.txt
  mongo $DB_URL --eval "db.usertable.remove({})"
  ./ycsb/bin/ycsb load mongodb-async -s -P ycsb/workloads/workloade -threads $THREADS -p mongodb.url=$MONGODB_CONN_STR -p recordcount=$RECORD_COUNT > $OUTPUT/load_e.txt
  ./ycsb/bin/ycsb run mongodb-async -s -P ycsb/workloads/workloade -threads $THREADS -p mongodb.url=$MONGODB_CONN_STR -p recordcount=$RECORD_COUNT -p operationcount=$OPERATION_COUNT > $OUTPUT/run_e.txt
}

install_java

install_ycsb

#full_workload_test
