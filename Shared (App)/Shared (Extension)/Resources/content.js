`use strict`;

// - MARK: Utils

const log = (message, ...others) =>
    console.log(`[content.js] ${message}`, ...others)

const sendBrowserRuntimeMessage = (destination, method, params = {}) => {
    const message = { destination, method, params, sessionId: findOrCreateSessionId() };
    log(`Sending message to browser runtime: ${JSON.stringify(message)}`);
    browser.runtime.sendMessage(message);
}

const onMessage = (methodName, handler) => {
    log(`Listening to content.${methodName}`)

    browser.runtime.onMessage.addListener((request, e) => {
        const { destination, method, sessionId, params } = request;
        
        if (destination !== `content`) return;
        if (method !== methodName) return;
        
        log(`Received method '${method}' with params: ${JSON.stringify(params)}`);
        handler(params, sessionId);
    })
}

// - MARK: Session handling

const findOrCreateSessionId = () => {
    let sessionId = window.sessionStorage.getItem("balanceWalletSessionId");
    if (!sessionId) {
        sessionId = Math.random().toString(36).substring(2, 15);
        window.sessionStorage.setItem("balanceWalletSessionId", sessionId);
    }
    return sessionId;
};

log(`session ID`, findOrCreateSessionId());

// - MARK: Message forwarding

// TODO: remove this extra layer of indirection. ethereum.js should be instantiated
//       with some sort of client and should be able to call bg.js directly.

onMessage('forwardToEthereumJs', (params) => {
    window.postMessage({ ...params });
})

window.addEventListener(`message`, (event) => {
    log(`Received message from ethereum.js: ${JSON.stringify(event)}`);
    sendBrowserRuntimeMessage('background', event.data.method, event.data.params);
});

// - MARK: Inject

window.__balance_sendBrowserRuntimeMessage = sendBrowserRuntimeMessage;

const inject = (path) => {
    const injection = document.createElement(`script`);
    injection.setAttribute(`type`, `text/javascript`);
    injection.setAttribute(`async`, `false`);
    injection.setAttribute(`src`, browser.runtime.getURL(path));
    document.body.insertBefore(injection, document.body.firstChild);
};

inject(`ethereum/dist.js`);

log(`loaded`);
