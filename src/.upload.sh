#!/bin/bash

PORT="/dev/ttyUSB0"
NODEMCU_UPLOADER="../nodemcu-uploader/nodemcu-uploader.py"
NODEMCU_COMMAND="${NODEMCU_UPLOADER} --baud 9600 --start_baud 9600 -p ${PORT} upload"

find -type f | sort | sed -e's|[.]/||' | grep -v -E "^[.]" | xargs python ${NODEMCU_COMMAND}

