//
E.on('init', function() {

  // load ESP8266 module & slow down freq
  require("ESP8266").setCPUFreq(80);

  // clean up all signals
  var pins = {
    0: true,   // GPIO0: firmware-update / factory-reset button
    1: false,  // GPIO1: U0TXD (don't use me)
    2: true,   // GPIO2: light pwm
    3: false,  // GPIO3: U0RXD (don't use me)
    4: true,   // ESP-01: unwired
    5: true,   // ESP-01: unwired
    6: false,  // XXX: flash (CLK)
    7: false,  // XXX: flash (MISO)
    8: false,  // XXX: flash (MOSI)
    9: false,  // XXX: flash (-WP)   (QIO?)
    10: false, // XXX: flash (-HOLD) (QIO?)
    11: false, // XXX: flash (CS)
    12: true,  // ESP-01: unwired
    13: true,  // ESP-01: unwired
    14: true,  // ESP-01: unwired
    15: true   // ESP-01: unwired
  };
  for (var pin in pins) {
    if (pins[pin]) {
      try {
        pinMode(pin, "output");
        digitalWrite(pin, 0);
        analogWrite(pin, 0);
      } catch(e) {
        // do nothing
      }
    }
  }

  // stop Wi-Fi
  var Wifi = require("Wifi");
  Wifi.disconnect();
  Wifi.stopAP();
  console.log(Wifi.getStatus());

  // then start the module
  esp8266_light_start();
});


// define EPROM (over flash)
var EPROM = (function() {

  // see http://www.espruino.com/Reference#t_Flash
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

  var _addr = function(addr) {
    var addr_max = (page.addr + page.length);
    var n = page.addr;
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
    var addr_max = (page.addr + page.length);
    var data = [];
    var n = page.addr;
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
    flash.erasePage(page.addr);
    var n = page.addr;
    for (var addr in data) {
      if (data[addr]!==undefined) {
        n = _write(n, addr, data[addr]);
      }
    }
    return n;
  };

  var write = function(addr, data) {
    var addr_max = (page.addr + page.length);
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
    flash.erasePage(page.addr);
  };

  var SSID = 0;
  var PASS = 1;

  return {
    readAll: function() { return readAll().map(function(x) { return E.toString(x); }); },
    write: function(addr, data) { return write(addr, E.toUint8Array(data)); },
    //erase: function() { erase(); },
    //cleanup: function() { cleanup(); },
    read_wifi_config: function() {
        var all = this.readAll();
        return {
            ssid: all[SSID],
            pass: all[PASS],
            empty: function() { return ((!this.ssid) || (!this.pass)); }
        };
    },
    write_wifi_config: function(ssid, pass) {
        this.write(SSID, ssid);
        this.write(PASS, pass);
    }
  };
})();


function esp8266_light_start() {
  esp8266_light_start_wifi(function(connected) {
    var Wifi = require("Wifi");
    console.log(Wifi.getStatus());
  });
}

function esp8266_light_start_wifi(callback) {
  var Wifi = require("Wifi");
  var config = EPROM.read_wifi_config();

  var startAP = function() {
    var ssid = "esp-light-" + (function(s){
      return Math.abs(s.split("").reduce(function(a,b){a=((a<<5)-a)+b.charCodeAt(0);return a&a; },0)) & 1000;
    })(require("ESP8266").getState().flashChip);
    Wifi.startAP(ssid, { password: ssid }, function() {
      console.log("status=", Wifi.getStatus());
      callback(false);
    });
  };

  if (config.empty()) {
    startAP();
  } else {
    Wifi.connect(config.ssid, { password: config.ssid }, function(err) {
      console.log("err=", err, "info=", Wifi.getIP());
      console.log("status=", Wifi.getStatus());
      Wifi.getDetails(function(details) {
        var connected = ('connnected' == details.status);
        if (connected) {
          callback(true);
        } else {
          startAP();
        }
      });
    });
  }
}





// start HTTP
(function(){
  var http_handlers = {

  };
  require("http").createServer(function(req, res) {
    var a = url.parse(req.url, true);
    var prefix = (a.method + ":" + a.pathname);
    var handler = http_handlers[prefix];
    if (handler !== undefined) {
      handler(req, res, a);
    } else {
      res.writeHead(404, {'Content-Type': 'text/plain'});
      res.end("404: Page "+a.pathname+" not found");
    }
  }).listen(80);
});
