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
})({"ib3eQ":[function(require,module,exports) {
var _messaging = require("../messaging");
var _utils = require("../utils");
const logger = _utils.getLogger('ethereum');
const { sendToContent  } = _messaging.getMessenger('ethereum', {
    logger
});
// MARK: - Styling prelims
const styleOverlay = {
    backgroundColor: `#000`,
    height: `100vh`,
    left: `0`,
    opacity: `0`,
    position: `fixed`,
    top: `0`,
    transition: `opacity .2`,
    width: `100vw`,
    willChange: `opacity`,
    zIndex: `9999999`
};
// MARK: - Class
class Ethereum {
    constructor(){
        this.waitingFor = {
        };
        this.opened = false;
        this.overlay = document.createElement(`div`);
        Object.assign(this.overlay.style, styleOverlay);
        this.overlay.onclick = ()=>this.close()
        ;
        const styleDiv = {
            alignItems: `center`,
            backgroundColor: `#fff`,
            borderRadius: `8px 8px 0 0`,
            bottom: `0`,
            columnGap: `18px`,
            display: `flex`,
            fontSize: `18px`,
            height: `45px`,
            justifyContent: `center`,
            left: `calc(calc(100vw - 368px) / 2)`,
            position: `fixed`,
            transform: `translateY(100%)`,
            transition: `transform .3s`,
            width: `368px`,
            willChange: `transform`,
            zIndex: `10000000`
        };
        this.div = document.createElement(`div`);
        this.div.innerHTML = `
        <svg width="22px" height="16px" viewBox="0 0 22 16" fill="none">
            <path fill-rule="evenodd" clip-rule="evenodd" d="M0 1.33333C0 0.597005 0.616262 0 1.37634 0H15.1398C15.8998 0 16.5161 0.597005 16.5161 1.33333V6.23633C17.0205 5.68262 17.7583 5.33333 18.5806 5.33333C20.1008 5.33333 21.3333 6.52734 21.3333 8C21.3333 9.47266 20.1008 10.6667 18.5806 10.6667C17.7583 10.6667 17.0205 10.3174 16.5161 9.76367V14.6667C16.5161 15.403 15.8998 16 15.1398 16H1.37634C0.616262 16 0 15.403 0 14.6667V10.2445C0 9.33333 1.61089 9.26921 2.07089 9.77083C2.57526 10.3203 3.31048 10.6667 4.12903 10.6667C5.64919 10.6667 6.88171 9.47266 6.88171 8C6.88171 6.52734 5.64919 5.33333 4.12903 5.33333C3.31048 5.33333 2.57526 5.67969 2.07089 6.22917C1.61089 6.73079 0 6.66667 0 5.75553V1.33333Z" fill="#3478f6" />
        </svg>
    `;
        Object.assign(this.div.style, styleDiv);
        this.message = document.createElement(`p`);
        this.message.innerText = `Open the wallet extension to connect`;
        this.div.appendChild(this.message);
        window.addEventListener('message', (event)=>{
            const { method , params , destination  } = event.data;
            if (destination !== 'ethereum') return;
            const resolve = this.waitingFor[method];
            if (!resolve) return;
            switch(method){
                case 'walletConnected':
                    resolve([
                        params.address
                    ]);
                    window.ethereum.close();
                    break;
                case 'eth_signTypedData_v3':
                case 'eth_signTypedData_v4':
                    resolve(params.signature);
                    break;
            }
            delete this.waitingFor[method];
        });
    }
    close() {
        window.postMessage(`cancel`);
        this.overlay.style.opacity = '0';
        this.div.style.transform = `translateY(100%)`;
        this.overlay.remove();
        this.div.remove();
        this.opened = false;
    }
    isConnected() {
    // TODO
    }
    on(event, _callback) {
    }
    request(payload) {
        return new Promise((resolve, reject)=>{
            logger('Request', payload);
            const showPrompt = (message)=>{
                if (window.ethereum.opened === false) {
                    window.ethereum.opened = true;
                    window.ethereum.message.textContent = message;
                    document.body.insertBefore(window.ethereum.overlay, document.body.firstChild);
                    document.body.insertBefore(window.ethereum.div, document.body.firstChild);
                    setTimeout(()=>{
                        window.ethereum.overlay.style.opacity = 0.4;
                        window.ethereum.div.style.transform = `translateY(0)`;
                    }, 1);
                }
            };
            switch(payload.method){
                case `eth_requestAccounts`:
                    showPrompt(`Open the wallet extension to connect`);
                    this.waitingFor.walletConnected = resolve;
                    break;
                case `eth_signTypedData_v3`:
                case `eth_signTypedData_v4`:
                    // showPrompt(`Open the wallet extension to sign`);
                    sendToContent({
                        method: payload.method,
                        params: payload.params
                    });
                    this.waitingFor[payload.method] = resolve;
                    break;
                default:
                    // * Invalid or unimplemented method
                    logger(`Invalid or unimplemented method`, payload.method);
                    resolve(false);
            }
        });
    }
}
// MARK: - Export
if (!window.browser) {
    // Injected script is being
    window.ethereum = new Ethereum();
    logger(`loaded`);
}

},{"../messaging":"3eVzl","../utils":"jxYDB"}],"3eVzl":[function(require,module,exports) {
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

},{}],"jxYDB":[function(require,module,exports) {
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

},{"@parcel/transformer-js/src/esmodule-helpers.js":"ciiiV"}]},["ib3eQ"], "ib3eQ", "parcelRequireae3a")

//# sourceMappingURL=index.js.map
