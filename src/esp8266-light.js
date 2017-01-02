// first, clean up all signals
(function() {
  var pins = {
    0: true,
    1: false,
    2: true,
    3: false,
    4: true,
    5: true,
    6: false,
    7: false,
    8: false,
    9: false,
    10: false,
    11: false,
    12: true,
    13: true,
    14: true,
    15: true
  };

  for (var pin in pins) {
    if (pins[pin]) {
      pinMode(pin, "output");
      digitalWrite(pin, 0);
      analogWrite(pin, 0);
    }
  }
})();

// load ESP8266 module & slow down freq
var ESP8266 = require("ESP8266");
ESP8266.setCPUFreq(80);

// define EPROM (over flash)
var EPROM = (function() {

  var flash = require("Flash");
  var page = (function(flash) {
    var addr = -1;
    var free = flash.getFree();
    if (free.length) {
      addr = free[0].addr;
    } else {
      free = require("ESP8266").getFreeFlash();
      if (free.length <= 0) { throw "Couldn't find ESP8266 free flash"; }
      addr = free[0].addr;
    }

    var page = flash.getPage(addr);
    if (!page) { throw "Couldn't find flash page"; }
    return page;
  })(flash);

  var addr_min = (page.addr);
  var addr_max = (page.addr + page.length);

  var _addr = function(addr) {
    var n = addr_min;
    var key = flash.read(4, n);
    var lastAddr = -1;
    while (key[3]!=255 && n<addr_max) {
      if (key[0] == addr) { lastAddr = n; }
      var l = (key[1] | (key[2]<<8));
      n += ((l+7) & ~3);
      key = flash.read(4, n);
    }
    return { addr:lastAddr, end:n };
  };

  var readAll = function() {
    var data = [];
    var n = addr_min;
    var key = flash.read(4, n);
    var lastAddr = -1;
    while (key[3]!=255 && n<addr_max) {
      var l = (key[1] | (key[2]<<8));
      if (l) { data[key[0]] = flash.read(l, n+4); }
      n += ((l+7) & ~3);
      key = flash.read(4, n);
    }
    return data;
  };

  var _write = function(n, addr, data) {
    flash.write(new Uint8Array([addr, data.length, data.length>>8, 0]), n);
    n+=4;
    if (data.length!=4) {
      var d = new Uint8Array((data.length+3)&~3);
      d.set(data);
      data = d;
    }
    if (data.length) { flash.write(data, n); }
    return n+data.length;
  };

  var cleanup = function() {
    var data = readAll();
    flash.erasePage(addr_min);
    var n = addr_min;
    for (var addr in data) {
      if (data[addr]!==undefined)
        n = _write(n, addr, data[addr]);
    }
    return n;
  };

  var write = function(addr, data) {
    var a = _addr(addr);
    if (a.addr >= 0) {
      key = flash.read(4, a.addr);
      var l = (key[1] | (key[2]<<8));
      var oldData = flash.read(l, a.addr+4);
      if (oldData == data) { return; }
    }
    if (a.end+data.length+4>=addr_max) {
      a.end = cleanup();
      if (a.end+data.length+4>=addr_max) {
        throw "Not enough memory!";
      }
    }
    _write(a.end, addr, data);
  };

  var erase = function() {
    this.flash.erasePage(addr_min);
  };

  return {
    readAll: function() { return readAll().map(x => E.toString(x)); },
    write: function(addr, data) { return write(addr, E.toUint8Array(data)); }
    erase: function() { erase(); }
  };
})();

// stop WiFi
var Wifi = require("Wifi");
Wifi.disconnect();
Wifi.stopAP();
console.log(Wifi.getStatus());
