#!/bin/sh
#v1.1 2015-06.18
# ---- CONFIG ----
# LINTER
PUB_SERVE_PORT=8089
# chrome,vm
TEST_PLATFORM_TARGET=chrome
# EXPORT ENV
#export DOM_STUB="true"
export TEST_ROOT_PATH="./test/"
# ----------------
echo 'Kill pub'
ps ax | grep "port $PUB_SERVE_PORT" | grep -v 'grep' | awk '{print $1}' | xargs -L1 -I {} kill -9 {}
echo 'pub update'
pub update

echo "Running test"
#TEST
pub run test -p $TEST_PLATFORM_TARGET
RESULT=$?
echo "Result: test=$RESULT"
exit $RESULT
