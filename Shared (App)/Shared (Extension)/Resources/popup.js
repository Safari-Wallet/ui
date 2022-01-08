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
})({"kN1CH":[function(require,module,exports) {
var parcelHelpers = require("@parcel/transformer-js/src/esmodule-helpers.js");
parcelHelpers.defineInteropFlag(exports);
parcelHelpers.export(exports, "log", ()=>log
);
parcelHelpers.export(exports, "error", ()=>error
);
parcelHelpers.export(exports, "Messenger", ()=>Messenger
);
parcelHelpers.export(exports, "chains", ()=>chains
);
parcelHelpers.export(exports, "chainId", ()=>chainId
);
var _messaging = require("../messaging");
var _utils = require("../utils");
var _templating = require("./templating");
var _utils1 = require("./utils");
const log = _utils.getLogger('popup');
const error = _utils.getErrorLogger('popup');
const Messenger = _messaging.getMessenger('popup', {
    logger: log
});
const chains = {
    1: {
        gasToken: `ETH`
    }
};
const chainId = 1;
// - MARK: Main
const onMessage = (methodName, handler)=>{
    log(`Listening to popup.${methodName}`);
    browser.runtime.onMessage.addListener((request, e)=>{
        const { destination , method , params  } = request;
        if (destination !== `popup`) return;
        if (method !== methodName) return;
        log(`Received method '${method}' with params: ${JSON.stringify(params)}`);
        handler(params, '');
    });
};
document.addEventListener(`DOMContentLoaded`, ()=>{
    onMessage('updateState', ({ address , balance  })=>{
        const onConnectWallet = ()=>{
            Messenger.sendToEthereumJs('walletConnected', {
                address,
                balance,
                chainId
            });
            _utils1.closeWindow();
        };
        _templating.render('connectWallet', {
            address,
            balance,
            onConnectWallet
        });
    });
    _templating.render('loading');
    Messenger.sendToBackground('getState');
    log(`loaded`);
});

},{"../messaging":"3eVzl","../utils":"jxYDB","./templating":"jAmhJ","./utils":"jdNV5","@parcel/transformer-js/src/esmodule-helpers.js":"ciiiV"}],"3eVzl":[function(require,module,exports) {
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

},{"@parcel/transformer-js/src/esmodule-helpers.js":"ciiiV"}],"jAmhJ":[function(require,module,exports) {
var parcelHelpers = require("@parcel/transformer-js/src/esmodule-helpers.js");
parcelHelpers.defineInteropFlag(exports);
parcelHelpers.export(exports, "views", ()=>views
);
parcelHelpers.export(exports, "getViewContents", ()=>getViewContents
);
parcelHelpers.export(exports, "render", ()=>render
);
var _root = require("./views/root");
var _rootDefault = parcelHelpers.interopDefault(_root);
var _loading = require("./views/loading");
var _loadingDefault = parcelHelpers.interopDefault(_loading);
var _connectWallet = require("./views/connectWallet");
var _connectWalletDefault = parcelHelpers.interopDefault(_connectWallet);
var _signMessage = require("./views/signMessage");
var _signMessageDefault = parcelHelpers.interopDefault(_signMessage);
var _popup = require("./popup");
var _utils = require("../utils");
const views = {
    loading: _loadingDefault.default,
    root: _rootDefault.default,
    connectWallet: _connectWalletDefault.default,
    signMessage: _signMessageDefault.default
};
const getViewContents = (viewName, params)=>views[viewName].render(params)
;
const render = (viewName, params = {
})=>{
    if (!viewName || !Object.keys(views).includes(viewName)) {
        _popup.error(`Invalid view name: ${viewName}.`);
        return;
    }
    const view = views[viewName];
    if (!view || !view.render) {
        _popup.error(`Invalid view: ${viewName}.`);
        return;
    }
    const $body = _utils.$(`#body`);
    if (!$body) {
        _popup.error(`Could not find body element.`);
        return;
    }
    const viewContents = getViewContents(viewName, params);
    _popup.log(`Rendering view '${viewName}' with ${JSON.stringify(params)}`);
    _popup.log(`View contents: ${viewContents}`);
    _popup.log(`Existing HTML: ${$body.innerHTML}`);
    $body.innerHTML = viewContents;
    _popup.log(`Updated HTML: ${$body.innerHTML}`);
    if (view.onRender) view.onRender(params);
};

},{"./views/root":"lh4jL","./views/loading":"GQsK4","./views/connectWallet":"ehgVS","./views/signMessage":"d8kI2","./popup":"kN1CH","../utils":"jxYDB","@parcel/transformer-js/src/esmodule-helpers.js":"ciiiV"}],"lh4jL":[function(require,module,exports) {
var parcelHelpers = require("@parcel/transformer-js/src/esmodule-helpers.js");
parcelHelpers.defineInteropFlag(exports);
const view = {
    render: ()=>`
        <h1>Safari Wallet</h1>
        <div class="flex">
            <button id="cancel" class="button button--secondary">Cancel</button>
            <button id="connect" class="button button--primary">Connect</button>
        </div>
    `
};
exports.default = view;

},{"@parcel/transformer-js/src/esmodule-helpers.js":"ciiiV"}],"GQsK4":[function(require,module,exports) {
var parcelHelpers = require("@parcel/transformer-js/src/esmodule-helpers.js");
parcelHelpers.defineInteropFlag(exports);
const view = {
    render: ()=>`
        <h1>Loading...</h1>
    `
};
exports.default = view;

},{"@parcel/transformer-js/src/esmodule-helpers.js":"ciiiV"}],"ehgVS":[function(require,module,exports) {
var parcelHelpers = require("@parcel/transformer-js/src/esmodule-helpers.js");
parcelHelpers.defineInteropFlag(exports);
var _utils = require("../../utils");
var _popup = require("../popup");
var _utils1 = require("../utils");
const view = {
    render: ({ address , balance  })=>`
        <h1>Connect to <span id="title"></span></h1>
        <p class="subtitle"><span id="host"></span></p>
        <p>When you connect your wallet, this dapp will be able to view the contents:</p>
        <div class="field">
            <label class="field__label" for="address">Address</label>
            <input id="address" class="field__input" type="text" value="${address}" disabled>
        </div>
        <div class="field">
            <label class="field__label" for="balance">ETH Balance</label>
            <input id="balance" class="field__input" type="text" value="${_utils.fromHex(balance) / 10 ** 18} ${_popup.chains[_popup.chainId].gasToken}" disabled>
        </div>
        <div class="flex">
            <button id="cancel" class="button button--secondary">Cancel</button>
            <button id="connect" class="button button--primary">Connect</button>
        </div>
    `
    ,
    onRender: ({ onConnectWallet  })=>{
        _utils.$('#cancel')?.addEventListener('click', _utils1.closeWindow);
        _utils.$('#connect')?.addEventListener('click', onConnectWallet);
        browser.tabs.query({
            active: true,
            currentWindow: true
        }, (tabs)=>{
            const tab = tabs[0];
            const $title = _utils.$('#title');
            const $host = _utils.$('#host');
            if ($title && tab.title) $title.textContent = tab.title;
            if ($host && tab.url) $host.textContent = new URL(tab.url).host;
        });
    }
};
exports.default = view;

},{"../../utils":"jxYDB","../popup":"kN1CH","../utils":"jdNV5","@parcel/transformer-js/src/esmodule-helpers.js":"ciiiV"}],"jdNV5":[function(require,module,exports) {
var parcelHelpers = require("@parcel/transformer-js/src/esmodule-helpers.js");
parcelHelpers.defineInteropFlag(exports);
parcelHelpers.export(exports, "closeWindow", ()=>closeWindow
);
const closeWindow = ()=>window.close()
;

},{"@parcel/transformer-js/src/esmodule-helpers.js":"ciiiV"}],"d8kI2":[function(require,module,exports) {
var parcelHelpers = require("@parcel/transformer-js/src/esmodule-helpers.js");
parcelHelpers.defineInteropFlag(exports);
var _utils = require("../../utils");
var _utils1 = require("../utils");
const view = {
    render: ()=>`
        <h1>Sign Message</h1>
        <div class="flex">
            <button id="cancel" class="button button--secondary">Cancel</button>
            <button id="sign" class="button button--primary">Sign</button>
        </div>
    `
    ,
    onRender: ({ signMessage  })=>{
        const $cancel = _utils.$('#cancel');
        const $sign = _utils.$('#sign');
        if ($cancel) $cancel.addEventListener(`click`, _utils1.closeWindow);
        if ($sign) $sign.addEventListener(`click`, signMessage);
    }
};
exports.default = view;

},{"../../utils":"jxYDB","../utils":"jdNV5","@parcel/transformer-js/src/esmodule-helpers.js":"ciiiV"}]},["kN1CH"], "kN1CH", "parcelRequireae3a")

//# sourceMappingURL=popup.js.map
