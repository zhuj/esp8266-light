-- SRC: http://download.geonames.org/export/dump/timeZones.txt['TimeZoneId']={GMT, offset, 1},
-- cat timeZones.txt | sed -e's|[.][0-9]*||g' | while read a b c d e f; do echo "['$b']={$c, $d, $e},"; done >> time-zones.lua
-- tz-name -> { offset@Jan, offset@Jul, rawOffset }
-- pleas uncomment places you want to use (see time-zones.lua.src)

return {
['Europe/Minsk']={3, 3, 3},
['Europe/St.Petersburg']={3, 3, 3},
['Asia/Yekaterinburg']={5, 5, 5},
}
