#!/bin/bash

PORT="/dev/ttyUSB0"
NODEMCU_UPLOADER="../nodemcu-uploader/nodemcu-uploader.py"
NODEMCU_COMMAND="${NODEMCU_UPLOADER} -p ${PORT} upload"

find -type f | grep -E "^[.]/http/" | sort | sed -e's|[.]/||' | grep -v -E "^[.]" | xargs python ${NODEMCU_COMMAND}

