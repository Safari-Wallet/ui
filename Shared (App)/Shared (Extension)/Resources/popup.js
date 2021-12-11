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
})({"8wWJj":[function(require,module,exports) {
var HMR_HOST = null;
var HMR_PORT = 1234;
var HMR_SECURE = false;
var HMR_ENV_HASH = "4a236f9275d0a351";
module.bundle.HMR_BUNDLE_ID = "a732c38bd8498950";
"use strict";
function _createForOfIteratorHelper(o, allowArrayLike) {
    var it;
    if (typeof Symbol === "undefined" || o[Symbol.iterator] == null) {
        if (Array.isArray(o) || (it = _unsupportedIterableToArray(o)) || allowArrayLike && o && typeof o.length === "number") {
            if (it) o = it;
            var i = 0;
            var F = function F() {
            };
            return {
                s: F,
                n: function n() {
                    if (i >= o.length) return {
                        done: true
                    };
                    return {
                        done: false,
                        value: o[i++]
                    };
                },
                e: function e(_e) {
                    throw _e;
                },
                f: F
            };
        }
        throw new TypeError("Invalid attempt to iterate non-iterable instance.\nIn order to be iterable, non-array objects must have a [Symbol.iterator]() method.");
    }
    var normalCompletion = true, didErr = false, err;
    return {
        s: function s() {
            it = o[Symbol.iterator]();
        },
        n: function n() {
            var step = it.next();
            normalCompletion = step.done;
            return step;
        },
        e: function e(_e2) {
            didErr = true;
            err = _e2;
        },
        f: function f() {
            try {
                if (!normalCompletion && it.return != null) it.return();
            } finally{
                if (didErr) throw err;
            }
        }
    };
}
function _unsupportedIterableToArray(o, minLen) {
    if (!o) return;
    if (typeof o === "string") return _arrayLikeToArray(o, minLen);
    var n = Object.prototype.toString.call(o).slice(8, -1);
    if (n === "Object" && o.constructor) n = o.constructor.name;
    if (n === "Map" || n === "Set") return Array.from(o);
    if (n === "Arguments" || /^(?:Ui|I)nt(?:8|16|32)(?:Clamped)?Array$/.test(n)) return _arrayLikeToArray(o, minLen);
}
function _arrayLikeToArray(arr, len) {
    if (len == null || len > arr.length) len = arr.length;
    for(var i = 0, arr2 = new Array(len); i < len; i++)arr2[i] = arr[i];
    return arr2;
}
/* global HMR_HOST, HMR_PORT, HMR_ENV_HASH, HMR_SECURE */ /*::
import type {
  HMRAsset,
  HMRMessage,
} from '@parcel/reporter-dev-server/src/HMRServer.js';
interface ParcelRequire {
  (string): mixed;
  cache: {|[string]: ParcelModule|};
  hotData: mixed;
  Module: any;
  parent: ?ParcelRequire;
  isParcelRequire: true;
  modules: {|[string]: [Function, {|[string]: string|}]|};
  HMR_BUNDLE_ID: string;
  root: ParcelRequire;
}
interface ParcelModule {
  hot: {|
    data: mixed,
    accept(cb: (Function) => void): void,
    dispose(cb: (mixed) => void): void,
    // accept(deps: Array<string> | string, cb: (Function) => void): void,
    // decline(): void,
    _acceptCallbacks: Array<(Function) => void>,
    _disposeCallbacks: Array<(mixed) => void>,
  |};
}
declare var module: {bundle: ParcelRequire, ...};
declare var HMR_HOST: string;
declare var HMR_PORT: string;
declare var HMR_ENV_HASH: string;
declare var HMR_SECURE: boolean;
*/ var OVERLAY_ID = '__parcel__error__overlay__';
var OldModule = module.bundle.Module;
function Module(moduleName) {
    OldModule.call(this, moduleName);
    this.hot = {
        data: module.bundle.hotData,
        _acceptCallbacks: [],
        _disposeCallbacks: [],
        accept: function accept(fn) {
            this._acceptCallbacks.push(fn || function() {
            });
        },
        dispose: function dispose(fn) {
            this._disposeCallbacks.push(fn);
        }
    };
    module.bundle.hotData = undefined;
}
module.bundle.Module = Module;
var checkedAssets, acceptedAssets, assetsToAccept;
function getHostname() {
    return HMR_HOST || (location.protocol.indexOf('http') === 0 ? location.hostname : 'localhost');
}
function getPort() {
    return HMR_PORT || location.port;
} // eslint-disable-next-line no-redeclare
var parent = module.bundle.parent;
if ((!parent || !parent.isParcelRequire) && typeof WebSocket !== 'undefined') {
    var hostname = getHostname();
    var port = getPort();
    var protocol = HMR_SECURE || location.protocol == 'https:' && !/localhost|127.0.0.1|0.0.0.0/.test(hostname) ? 'wss' : 'ws';
    var ws = new WebSocket(protocol + '://' + hostname + (port ? ':' + port : '') + '/'); // $FlowFixMe
    ws.onmessage = function(event) {
        checkedAssets = {
        };
        acceptedAssets = {
        };
        assetsToAccept = [];
        var data = JSON.parse(event.data);
        if (data.type === 'update') {
            // Remove error overlay if there is one
            if (typeof document !== 'undefined') removeErrorOverlay();
            var assets = data.assets.filter(function(asset) {
                return asset.envHash === HMR_ENV_HASH;
            }); // Handle HMR Update
            var handled = assets.every(function(asset) {
                return asset.type === 'css' || asset.type === 'js' && hmrAcceptCheck(module.bundle.root, asset.id, asset.depsByBundle);
            });
            if (handled) {
                console.clear();
                assets.forEach(function(asset) {
                    hmrApply(module.bundle.root, asset);
                });
                for(var i = 0; i < assetsToAccept.length; i++){
                    var id = assetsToAccept[i][1];
                    if (!acceptedAssets[id]) hmrAcceptRun(assetsToAccept[i][0], id);
                }
            } else window.location.reload();
        }
        if (data.type === 'error') {
            // Log parcel errors to console
            var _iterator = _createForOfIteratorHelper(data.diagnostics.ansi), _step;
            try {
                for(_iterator.s(); !(_step = _iterator.n()).done;){
                    var ansiDiagnostic = _step.value;
                    var stack = ansiDiagnostic.codeframe ? ansiDiagnostic.codeframe : ansiDiagnostic.stack;
                    console.error('🚨 [parcel]: ' + ansiDiagnostic.message + '\n' + stack + '\n\n' + ansiDiagnostic.hints.join('\n'));
                }
            } catch (err) {
                _iterator.e(err);
            } finally{
                _iterator.f();
            }
            if (typeof document !== 'undefined') {
                // Render the fancy html overlay
                removeErrorOverlay();
                var overlay = createErrorOverlay(data.diagnostics.html); // $FlowFixMe
                document.body.appendChild(overlay);
            }
        }
    };
    ws.onerror = function(e) {
        console.error(e.message);
    };
    ws.onclose = function() {
        console.warn('[parcel] 🚨 Connection to the HMR server was lost');
    };
}
function removeErrorOverlay() {
    var overlay = document.getElementById(OVERLAY_ID);
    if (overlay) {
        overlay.remove();
        console.log('[parcel] ✨ Error resolved');
    }
}
function createErrorOverlay(diagnostics) {
    var overlay = document.createElement('div');
    overlay.id = OVERLAY_ID;
    var errorHTML = '<div style="background: black; opacity: 0.85; font-size: 16px; color: white; position: fixed; height: 100%; width: 100%; top: 0px; left: 0px; padding: 30px; font-family: Menlo, Consolas, monospace; z-index: 9999;">';
    var _iterator2 = _createForOfIteratorHelper(diagnostics), _step2;
    try {
        for(_iterator2.s(); !(_step2 = _iterator2.n()).done;){
            var diagnostic = _step2.value;
            var stack = diagnostic.codeframe ? diagnostic.codeframe : diagnostic.stack;
            errorHTML += "\n      <div>\n        <div style=\"font-size: 18px; font-weight: bold; margin-top: 20px;\">\n          \uD83D\uDEA8 ".concat(diagnostic.message, "\n        </div>\n        <pre>").concat(stack, "</pre>\n        <div>\n          ").concat(diagnostic.hints.map(function(hint) {
                return '<div>💡 ' + hint + '</div>';
            }).join(''), "\n        </div>\n        ").concat(diagnostic.documentation ? "<div>\uD83D\uDCDD <a style=\"color: violet\" href=\"".concat(diagnostic.documentation, "\" target=\"_blank\">Learn more</a></div>") : '', "\n      </div>\n    ");
        }
    } catch (err) {
        _iterator2.e(err);
    } finally{
        _iterator2.f();
    }
    errorHTML += '</div>';
    overlay.innerHTML = errorHTML;
    return overlay;
}
function getParents(bundle, id) /*: Array<[ParcelRequire, string]> */ {
    var modules = bundle.modules;
    if (!modules) return [];
    var parents = [];
    var k, d, dep;
    for(k in modules)for(d in modules[k][1]){
        dep = modules[k][1][d];
        if (dep === id || Array.isArray(dep) && dep[dep.length - 1] === id) parents.push([
            bundle,
            k
        ]);
    }
    if (bundle.parent) parents = parents.concat(getParents(bundle.parent, id));
    return parents;
}
function updateLink(link) {
    var newLink = link.cloneNode();
    newLink.onload = function() {
        if (link.parentNode !== null) // $FlowFixMe
        link.parentNode.removeChild(link);
    };
    newLink.setAttribute('href', link.getAttribute('href').split('?')[0] + '?' + Date.now()); // $FlowFixMe
    link.parentNode.insertBefore(newLink, link.nextSibling);
}
var cssTimeout = null;
function reloadCSS() {
    if (cssTimeout) return;
    cssTimeout = setTimeout(function() {
        var links = document.querySelectorAll('link[rel="stylesheet"]');
        for(var i = 0; i < links.length; i++){
            // $FlowFixMe[incompatible-type]
            var href = links[i].getAttribute('href');
            var hostname = getHostname();
            var servedFromHMRServer = hostname === 'localhost' ? new RegExp('^(https?:\\/\\/(0.0.0.0|127.0.0.1)|localhost):' + getPort()).test(href) : href.indexOf(hostname + ':' + getPort());
            var absolute = /^https?:\/\//i.test(href) && href.indexOf(window.location.origin) !== 0 && !servedFromHMRServer;
            if (!absolute) updateLink(links[i]);
        }
        cssTimeout = null;
    }, 50);
}
function hmrApply(bundle, asset) {
    var modules = bundle.modules;
    if (!modules) return;
    if (asset.type === 'css') reloadCSS();
    else if (asset.type === 'js') {
        var deps = asset.depsByBundle[bundle.HMR_BUNDLE_ID];
        if (deps) {
            var fn = new Function('require', 'module', 'exports', asset.output);
            modules[asset.id] = [
                fn,
                deps
            ];
        } else if (bundle.parent) hmrApply(bundle.parent, asset);
    }
}
function hmrAcceptCheck(bundle, id, depsByBundle) {
    var modules = bundle.modules;
    if (!modules) return;
    if (depsByBundle && !depsByBundle[bundle.HMR_BUNDLE_ID]) {
        // If we reached the root bundle without finding where the asset should go,
        // there's nothing to do. Mark as "accepted" so we don't reload the page.
        if (!bundle.parent) return true;
        return hmrAcceptCheck(bundle.parent, id, depsByBundle);
    }
    if (checkedAssets[id]) return true;
    checkedAssets[id] = true;
    var cached = bundle.cache[id];
    assetsToAccept.push([
        bundle,
        id
    ]);
    if (cached && cached.hot && cached.hot._acceptCallbacks.length) return true;
    var parents = getParents(module.bundle.root, id); // If no parents, the asset is new. Prevent reloading the page.
    if (!parents.length) return true;
    return parents.some(function(v) {
        return hmrAcceptCheck(v[0], v[1], null);
    });
}
function hmrAcceptRun(bundle, id) {
    var cached = bundle.cache[id];
    bundle.hotData = {
    };
    if (cached && cached.hot) cached.hot.data = bundle.hotData;
    if (cached && cached.hot && cached.hot._disposeCallbacks.length) cached.hot._disposeCallbacks.forEach(function(cb) {
        cb(bundle.hotData);
    });
    delete bundle.cache[id];
    bundle(id);
    cached = bundle.cache[id];
    if (cached && cached.hot && cached.hot._acceptCallbacks.length) cached.hot._acceptCallbacks.forEach(function(cb) {
        var assetsToAlsoAccept = cb(function() {
            return getParents(module.bundle.root, id);
        });
        if (assetsToAlsoAccept && assetsToAccept.length) // $FlowFixMe[method-unbinding]
        assetsToAccept.push.apply(assetsToAccept, assetsToAlsoAccept);
    });
    acceptedAssets[id] = true;
}

},{}],"kN1CH":[function(require,module,exports) {
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
const main = ()=>{
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
};
main();

},{"../messaging":"3eVzl","../utils":"jxYDB","./utils":"jdNV5","@parcel/transformer-js/src/esmodule-helpers.js":"ciiiV","./templating":"jAmhJ"}],"3eVzl":[function(require,module,exports) {
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
const getSendNativeMessage = (logger)=>(method, sessionId, params = {
    })=>{
        const message = {
            method,
            sessionId,
            params
        };
        logger(`Sending message to SafariWebExtensionHandler: ${JSON.stringify(message)}`);
        return browser.runtime.sendNativeMessage('ignored', message.method); // tmp
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
const getLogger = (fileName)=>(message, ...others)=>console.log(`[${fileName}.js] ${message}`, ...others)
;
const getErrorLogger = (fileName)=>(message, ...others)=>console.error(`[${fileName}.js] ${message}`, ...others)
;
const $ = (query)=>query[0] === `#` ? document.querySelector(query) : document.querySelectorAll(query)
;

},{"@parcel/transformer-js/src/esmodule-helpers.js":"ciiiV"}],"jdNV5":[function(require,module,exports) {
var parcelHelpers = require("@parcel/transformer-js/src/esmodule-helpers.js");
parcelHelpers.defineInteropFlag(exports);
parcelHelpers.export(exports, "closeWindow", ()=>closeWindow
);
const closeWindow = ()=>window.close()
;

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
            <input id="balance" class="field__input" type="text" value="${balance} ${_popup.chains[_popup.chainId].gasToken}" disabled>
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

},{"../../utils":"jxYDB","../utils":"jdNV5","@parcel/transformer-js/src/esmodule-helpers.js":"ciiiV","../popup":"kN1CH"}],"d8kI2":[function(require,module,exports) {
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

},{"../../utils":"jxYDB","../utils":"jdNV5","@parcel/transformer-js/src/esmodule-helpers.js":"ciiiV"}]},["8wWJj","kN1CH"], "kN1CH", "parcelRequireae3a")

//# sourceMappingURL=popup.js.map
