`use strict`;

// - MARK: Setup / Global State

const chainId = 1;

// For message signing:
let from = ``;
let params = {};

const chains = {
    1: {
        gasToken: `ETH`,
    },
};

// - MARK: Utils

const log = (message, ...others) =>
    console.log(`[popup.js] ${message}`, ...others)

const error = (message, ...others) =>
    console.error(`[popup.js] ${message}`, ...others)

const emitMessage = (destination, method, params = {}) => {
    let message = { destination, method, params };
    
    log(`Emitting message: ${JSON.stringify(message)}`);
    
    if (destination === 'background') {
        browser.runtime.sendMessage(message);
        return;
    }

    browser.tabs.query({
        active: true,
        currentWindow: true,
    }, (tabs) => {
        const [tab] = tabs;
        browser.tabs.sendMessage(tab.id, message);
    });
}

const $ = (query) =>
    query[0] === (`#`)
    ? document.querySelector(query)
    : document.querySelectorAll(query);

const onMessage = (methodName, handler) => {
    log(`Listening to popup.${methodName}`)

    browser.runtime.onMessage.addListener((request, e) => {
        const { destination, method, params } = request;

        if (destination !== `popup`) return;
        if (method !== methodName) return;

        log(`Received method '${method}' with params: ${JSON.stringify(params)}`);
        handler(params);
    })
}

// - MARK: Views

const views = {
    default: () => `
        <h1>Safari Wallet</h1>
            <div class="flex">
                <button id="cancel" class="button button--secondary">Cancel</button>
                <button id="connect" class="button button--primary">Connect</button>
            </div>
    `,
    connectWallet: ({ address, balance }) => `
        <h1>Connect to <span id="title"></span></h1>
        <p class="subtitle"><span id="host"></span></p>
        <p>When you connect your wallet, this dapp will be able to view the contents:</p>
        <div class="field">
            <label class="field__label" for="address">Address</label>
            <input id="address" class="field__input" type="text" value="${address}" disabled>
        </div>
        <div class="field">
            <label class="field__label" for="balance">ETH Balance</label>
            <input id="balance" class="field__input" type="text" value="${balance} ${chains[chainId].gasToken}" disabled>
        </div>
        <div class="flex">
            <button id="cancel" class="button button--secondary">Cancel</button>
            <button id="connect" class="button button--primary">Connect</button>
        </div>
    `,
    signMessage: () => `
        <h1>Sign Message</h1>
        <div class="flex">
            <button id="cancel" class="button button--secondary">Cancel</button>
            <button id="sign" class="button button--primary">Sign</button>
        </div>
    `,
    loading: () => `
        <h1>Loading...</h1>
    `,
};

const viewHandlers = {
    default: () => {},
    connectWallet: ({ onConnectWallet }) => {
        $(`#cancel`).addEventListener(`click`, closeWindow);
        $(`#connect`).addEventListener(`click`, onConnectWallet);
        browser.tabs.query({
            active: true,
            currentWindow: true,
        }, (tabs) => {
            const tab = tabs[0];
            $(`#title`).textContent = tab.title;
            $(`#host`).textContent = new URL(tab.url).host;
        });
    },
    eth_signTypedData_v3: () => {
        $(`#body`).innerHTML = views.signMessage();
        $(`#cancel`).addEventListener(`click`, closeWindow);
        $(`#sign`).addEventListener(`click`, signMessage);
    }
}

const getViewContents = (viewName, params = {}) =>
    views[viewName](params);

const render = (viewName = 'default', params = {}) => {
    if (!viewName || !Object.keys(views).includes(viewName) || !Object.keys(viewHandlers).includes(viewName)) {
        error(`Invalid view name: ${viewName}.`);
        return;
    }

    log(`Rendering view '${viewName}' with ${JSON.stringify(params)}`);
    log(`View contents: ${getViewContents(viewName, params)}`);
    log(`View handlers: ${JSON.stringify(viewHandlers[viewName])}`);
    log(`existing html: ${$(`#body`).innerHTML}`);
    
    $(`#body`).innerHTML = getViewContents(viewName, params);

    log(`updated html: ${$(`#body`).innerHTML}`);
    
    viewHandlers[viewName](params);
};

// - MARK: Actions

const closeWindow = () =>
    window.close();

const signMessage = () => {
    closeWindow();
};

// - MARK: Go

document.addEventListener(`DOMContentLoaded`, () => {
    onMessage('updateState', ({ address, balance }) => {
        const onConnectWallet = () => {
            emitMessage('content', 'forwardToEthereumJs', { method: 'walletConnected', params: { address, balance, chainId } });
            closeWindow();
        }

        render('connectWallet', { address, balance, onConnectWallet })
    });

    render('loading');
    emitMessage('background', 'getState');
    
    log(`loaded`);
});
