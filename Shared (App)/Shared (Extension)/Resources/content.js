// modules are defined as an array
// [ module function, map of requires ]
//
// map of requires is short require name -> numeric require
//
// anything defined in a previous bundle is accessed via the
// orig method which is the require for previous bundles

(function (modules, entry, mainEntry, parcelRequireName, globalName) {
  /* eslint-disable no-undef */
  var globalObject =
    typeof globalThis !== 'undefined'
      ? globalThis
      : typeof self !== 'undefined'
      ? self
      : typeof window !== 'undefined'
      ? window
      : typeof global !== 'undefined'
      ? global
      : {};
  /* eslint-enable no-undef */

  // Save the require from previous bundle to this closure if any
  var previousRequire =
    typeof globalObject[parcelRequireName] === 'function' &&
    globalObject[parcelRequireName];

  var cache = previousRequire.cache || {};
  // Do not use `require` to prevent Webpack from trying to bundle this call
  var nodeRequire =
    typeof module !== 'undefined' &&
    typeof module.require === 'function' &&
    module.require.bind(module);

  function newRequire(name, jumped) {
    if (!cache[name]) {
      if (!modules[name]) {
        // if we cannot find the module within our internal map or
        // cache jump to the current global require ie. the last bundle
        // that was added to the page.
        var currentRequire =
          typeof globalObject[parcelRequireName] === 'function' &&
          globalObject[parcelRequireName];
        if (!jumped && currentRequire) {
          return currentRequire(name, true);
        }

        // If there are other bundles on this page the require from the
        // previous one is saved to 'previousRequire'. Repeat this as
        // many times as there are bundles until the module is found or
        // we exhaust the require chain.
        if (previousRequire) {
          return previousRequire(name, true);
        }

        // Try the node require function if it exists.
        if (nodeRequire && typeof name === 'string') {
          return nodeRequire(name);
        }

        var err = new Error("Cannot find module '" + name + "'");
        err.code = 'MODULE_NOT_FOUND';
        throw err;
      }

      localRequire.resolve = resolve;
      localRequire.cache = {};

      var module = (cache[name] = new newRequire.Module(name));

      modules[name][0].call(
        module.exports,
        localRequire,
        module,
        module.exports,
        this
      );
    }

    return cache[name].exports;

    function localRequire(x) {
      return newRequire(localRequire.resolve(x));
    }

    function resolve(x) {
      return modules[name][1][x] || x;
    }
  }

  function Module(moduleName) {
    this.id = moduleName;
    this.bundle = newRequire;
    this.exports = {};
  }

  newRequire.isParcelRequire = true;
  newRequire.Module = Module;
  newRequire.modules = modules;
  newRequire.cache = cache;
  newRequire.parent = previousRequire;
  newRequire.register = function (id, exports) {
    modules[id] = [
      function (require, module) {
        module.exports = exports;
      },
      {},
    ];
  };

  Object.defineProperty(newRequire, 'root', {
    get: function () {
      return globalObject[parcelRequireName];
    },
  });

  globalObject[parcelRequireName] = newRequire;

  for (var i = 0; i < entry.length; i++) {
    newRequire(entry[i]);
  }

  if (mainEntry) {
    // Expose entry point to Node, AMD or browser globals
    // Based on https://github.com/ForbesLindesay/umd/blob/master/template.js
    var mainExports = newRequire(mainEntry);

    // CommonJS
    if (typeof exports === 'object' && typeof module !== 'undefined') {
      module.exports = mainExports;

      // RequireJS
    } else if (typeof define === 'function' && define.amd) {
      define(function () {
        return mainExports;
      });

      // <script>
    } else if (globalName) {
      this[globalName] = mainExports;
    }
  }
})({"h2Qcl":[function(require,module,exports) {
var _utils = require("../utils");
var _messaging = require("../messaging");
var _sessions = require("./sessions");
// - MARK: Utils
const log = _utils.getLogger(`content`);
const Messenger = _messaging.getMessenger('content', {
    logger: log,
    sessionId: _sessions.findOrCreateSessionId()
});
const onMessage = (methodName, handler)=>{
    log(`Listening to content.${methodName}`);
    browser.runtime.onMessage.addListener((request, e)=>{
        const { destination , method , sessionId , params  } = request;
        if (destination !== `content`) return;
        if (method !== methodName) return;
        log(`Received method '${method}' with params: ${JSON.stringify(params)}`);
        handler(params, sessionId);
    });
};
log(`session ID`, _sessions.findOrCreateSessionId());
// - MARK: Main
const $injection = document.createElement('script');
$injection.type = 'text/javascript';
$injection.async = false;
$injection.src = browser.runtime.getURL('ethereum/index.js');
document.body.insertBefore($injection, document.body.firstChild);
onMessage('forwardToEthereumJs', (params)=>{
    Messenger.sendToEthereumJs(params);
});
window.addEventListener(`message`, (event)=>{
    if (event.data?.destination !== 'content') return;
    log(`Received message from postMessage: ${JSON.stringify(event)}`);
    const method = event.data?.method;
    if (method) Messenger.sendToBackground(method, event.data.params).then((result)=>{
        log(`Received message from background: ${JSON.stringify(result)}`);
        if (!result) return;
        Messenger.sendToEthereumJs({
            method,
            params: result
        });
    });
});
log(`loaded`);

},{"../utils":"jxYDB","../messaging":"3eVzl","./sessions":"02nhl"}],"jxYDB":[function(require,module,exports) {
var parcelHelpers = require("@parcel/transformer-js/src/esmodule-helpers.js");
parcelHelpers.defineInteropFlag(exports);
parcelHelpers.export(exports, "getLogger", ()=>getLogger
);
parcelHelpers.export(exports, "getErrorLogger", ()=>getErrorLogger
);
parcelHelpers.export(exports, "$", ()=>$
);
parcelHelpers.export(exports, "fromHex", ()=>fromHex
);
const getLogger = (fileName)=>(message, ...others)=>{
        //console.log(`[${fileName}.js] ${message}`, ...others);
        // todo deal with "others"
        const xhr = new XMLHttpRequest();
        xhr.onload = (data)=>{
        // todo handle
        };
        xhr.open(`POST`, `http://localhost:8081/add?message=${message}&sender=${fileName}.js`, true);
        xhr.send();
    }
;
const getErrorLogger = (fileName)=>(message, ...others)=>console.error(`[${fileName}.js] ${message}`, ...others)
;
const $ = (query)=>query[0] === `#` ? document.querySelector(query) : document.querySelectorAll(query)
;
const fromHex = (hex)=>{
    if (hex === '0x0') return 0;
    hex.startsWith('0x') && (hex = hex.slice(2));
    let ascii = '';
    for(var i = 0; i < hex.length; i += 2)ascii += String.fromCharCode(parseInt(hex.substr(i, 2), 16));
    return parseInt(ascii);
};

},{"@parcel/transformer-js/src/esmodule-helpers.js":"ciiiV"}],"ciiiV":[function(require,module,exports) {
exports.interopDefault = function(a) {
    return a && a.__esModule ? a : {
        default: a
    };
};
exports.defineInteropFlag = function(a) {
    Object.defineProperty(a, '__esModule', {
        value: true
    });
};
exports.exportAll = function(source, dest) {
    Object.keys(source).forEach(function(key) {
        if (key === 'default' || key === '__esModule' || dest.hasOwnProperty(key)) return;
        Object.defineProperty(dest, key, {
            enumerable: true,
            get: function() {
                return source[key];
            }
        });
    });
    return dest;
};
exports.export = function(dest, destName, get) {
    Object.defineProperty(dest, destName, {
        enumerable: true,
        get: get
    });
};

},{}],"3eVzl":[function(require,module,exports) {
var parcelHelpers = require("@parcel/transformer-js/src/esmodule-helpers.js");
parcelHelpers.defineInteropFlag(exports);
parcelHelpers.export(exports, "getSendNativeMessage", ()=>getSendNativeMessage
);
parcelHelpers.export(exports, "getSendBrowserRuntimeMessage", ()=>getSendBrowserRuntimeMessage
);
parcelHelpers.export(exports, "getSendBrowserTabMessage", ()=>getSendBrowserTabMessage
);
parcelHelpers.export(exports, "getSendMessageToEthereumJs", ()=>getSendMessageToEthereumJs
);
parcelHelpers.export(exports, "getSendWindowMessage", ()=>getSendWindowMessage
);
parcelHelpers.export(exports, "getMessenger", ()=>getMessenger
);
parcelHelpers.export(exports, "getBackgroundMessenger", ()=>getBackgroundMessenger
);
parcelHelpers.export(exports, "getPopupMessenger", ()=>getPopupMessenger
);
parcelHelpers.export(exports, "getContentMessenger", ()=>getContentMessenger
);
parcelHelpers.export(exports, "getEthereumMessenger", ()=>getEthereumMessenger
);
const getSendNativeMessage = (logger)=>async (method, _sessionId, params = {
    })=>{
        const message = {
            method,
            params
        };
        logger(`Sending message to SafariWebExtensionHandler: ${JSON.stringify(message)}`);
        const result = await browser.runtime.sendNativeMessage('ignored', message);
        logger(`Result from message: ${JSON.stringify(result)}`);
        if (result.error) throw new Error(`Received error from SafariWebExtensionHandler: ${JSON.stringify(result)}`);
        return result;
    }
;
const getSendBrowserRuntimeMessage = (logger, sessionId)=>(destination, method, params = {
    })=>{
        const message = {
            destination,
            method,
            params,
            sessionId
        };
        logger(`Sending message to browser runtime: ${JSON.stringify(message)}`);
        return browser.runtime.sendMessage(message);
    }
;
const getSendBrowserTabMessage = (logger, sessionId)=>(destination, method, params = {
    })=>{
        const message = {
            destination,
            method,
            params,
            sessionId
        };
        logger(`Sending message to browser tabs: ${JSON.stringify(message)}`);
        browser.tabs.query({
            active: true,
            currentWindow: true
        }, (tabs)=>{
            const [tab] = tabs;
            if (tab && tab.id) browser.tabs.sendMessage(tab.id, message);
        });
    }
;
const getSendMessageToEthereumJs = (logger, conduit)=>(method, params = {
    })=>{
        const message = {
            method,
            params
        };
        logger(`Sending message to Ethereum.js: ${JSON.stringify(message)}`);
        return conduit(message);
    }
;
const getSendWindowMessage = (logger)=>(destination, method, params = {
    })=>window.postMessage({
            destination,
            method,
            params
        })
;
const getMessenger = (origin, params)=>{
    if (origin === 'background') return getBackgroundMessenger(params);
    if (origin === 'popup') return getPopupMessenger(params);
    if (origin === 'content') return getContentMessenger(params);
    if (origin === 'ethereum') return getEthereumMessenger(params);
    throw new Error(`Unknown origin: ${origin}`);
};
const getBackgroundMessenger = ({ logger  })=>{
    const sendToContent = ({ method , params  })=>getSendBrowserTabMessage(logger)('content', method, params)
    ;
    const sendToEthereumJs = getSendMessageToEthereumJs(logger, (params)=>sendToContent({
            method: 'forwardToEthereumJs',
            params
        })
    );
    const sendToPopup = (method, params = {
    })=>getSendBrowserRuntimeMessage(logger)('popup', method, params)
    ;
    return {
        sendToContent,
        sendToEthereumJs,
        sendToPopup,
        sendToNative: getSendNativeMessage(logger)
    };
};
const getPopupMessenger = ({ logger  })=>{
    const sendToContent = ({ method , params  })=>getSendBrowserTabMessage(logger)('content', method, params)
    ;
    const sendToEthereumJs = getSendMessageToEthereumJs(logger, (params)=>sendToContent({
            method: 'forwardToEthereumJs',
            params
        })
    );
    const sendToBackground = (method, params = {
    })=>getSendBrowserRuntimeMessage(logger)('background', method, params)
    ;
    return {
        sendToContent,
        sendToEthereumJs,
        sendToBackground,
        sendToNative: getSendNativeMessage(logger)
    };
};
const getContentMessenger = ({ logger , sessionId  })=>{
    const sendToPopup = ({ method , params  })=>getSendBrowserRuntimeMessage(logger, sessionId)('popup', method, params)
    ;
    const sendToEthereumJs = ({ method , params  })=>getSendWindowMessage(logger)('ethereum', method, params)
    ;
    const sendToBackground = (method, params = {
    })=>getSendBrowserRuntimeMessage(logger, sessionId)('background', method, params)
    ;
    return {
        sendToPopup,
        sendToEthereumJs,
        sendToBackground
    };
};
const getEthereumMessenger = ({ logger  })=>{
    const sendToContent = ({ method , params  })=>getSendWindowMessage(logger)('content', method, params)
    ;
    return {
        sendToContent
    };
};

},{"@parcel/transformer-js/src/esmodule-helpers.js":"ciiiV"}],"02nhl":[function(require,module,exports) {
var parcelHelpers = require("@parcel/transformer-js/src/esmodule-helpers.js");
parcelHelpers.defineInteropFlag(exports);
parcelHelpers.export(exports, "findOrCreateSessionId", ()=>findOrCreateSessionId
);
const findOrCreateSessionId = ()=>{
    let sessionId = window.sessionStorage.getItem('balanceWalletSessionId');
    if (!sessionId) {
        sessionId = Math.random().toString(36).substring(2, 15);
        window.sessionStorage.setItem('balanceWalletSessionId', sessionId);
    }
    return sessionId;
};

},{"@parcel/transformer-js/src/esmodule-helpers.js":"ciiiV"}]},["h2Qcl"], "h2Qcl", "parcelRequireae3a")

//# sourceMappingURL=content.js.map
