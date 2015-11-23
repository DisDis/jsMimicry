#!/bin/sh
#v1.1 2015-06.18
# ---- CONFIG ----
# LINTER
PUB_SERVE_PORT=8089
# chrome,vm
TEST_PLATFORM_TARGET=dartium
# EXPORT ENV
#export DOM_STUB="true"
export TEST_ROOT_PATH="./test/"
# ----------------
#echo "Installing linter"
#pub global activate linter

pub serve --port $PUB_SERVE_PORT --no-force-poll >/dev/null &
PID=$!
echo "Run serve [PID:$PID]"
echo "Runing LINTER"
pub global run linter -s ./
RESULT_LINT=$?
sleep 5
echo "Running test"
#VM
pub run test --pub-serve=$PUB_SERVE_PORT -p $TEST_PLATFORM_TARGET
RESULT=$?
echo "Result: test=$RESULT linter=$RESULT_LINT"
kill $PID || exit 1
exit $RESULT || $RESULT_LINT
