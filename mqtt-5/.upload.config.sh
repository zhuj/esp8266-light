#!/bin/bash

PORT="/dev/ttyUSB0"
NODEMCU_UPLOADER="../nodemcu-uploader/nodemcu-uploader.py"
NODEMCU_COMMAND="${NODEMCU_UPLOADER} --baud 115200 --start_baud 115200 -p ${PORT} upload"

find -type f | grep -E "^[.]/config/" | sort | sed -e's|[.]/||' | grep -v -E "^[.]" | xargs python ${NODEMCU_COMMAND}

