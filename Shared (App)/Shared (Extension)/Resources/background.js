// TODO: Move the utils into a shared file. We can compile background.js, content.js and popup.js from TS
//       if needed, which will give us proper ESM support (and much else).

`use strict`;

// - MARK: Setup

// For message signing:
let from = ``;
let params = {};

// - MARK: Utils

const log = (message, ...others) =>
    console.log(`[background.js] ${message}`, ...others)

const sendNativeMessage = (method, sessionId, params = {}) => {
    const message = { method, sessionId, params };
    log(`Sending message to SafariWebExtensionHandler: ${JSON.stringify(message)}`);
    return browser.runtime.sendNativeMessage(message.method); // tmp
}

const sendBrowserRuntimeMessage = (destination, method, params = {}) => {
    const message = { destination, method, params, sessionId: undefined /* tmp */ };
    log(`Sending message to browser runtime: ${JSON.stringify(message)}`);
    return browser.runtime.sendMessage(message);
}

// - MARK: Listeners

browser.runtime.onMessage.addListener(async (request, sender, sendResponse) => {
    log(`Received message from browser runtime: ${JSON.stringify(request)}`);

    const onMethod = async (methodName, handler) => {
        const { destination, method, sessionId, params } = request;
        if (destination !== `background`) return;
        if (method !== methodName) return;
        
        log(`Received method '${method}' with params: ${JSON.stringify(params)}`);
        await handler(params, sessionId);
    }

    onMethod('getState', async (_params, sessionId) => {
        const [address] = await sendNativeMessage('eth_getAccounts', sessionId);
        const balance = await sendNativeMessage('eth_getBalance', sessionId);
        
        // TODO: address could return a { error: 'error message' } object. We need to check for that 
        
        sendResponse({ address, balance });

        sendBrowserRuntimeMessage('popup', 'updateState', {
            address,
            balance,
        })
    });

//         case `eth_signTypedData_v3`: // * Return requested data from native app to popup.js
//             /*
//             TODO
//             const signature = await browser.runtime.sendNativeMessage({
//                 from: request.message.from,
//                 message: `eth_signTypedData_v3`,
//                 params: request.message.params,
//             });
//             browser.runtime.sendMessage({
//                 message: signature.message,
//             });
//             */
//             break;
//         case `cancel`: // * Cancel current method and notify popup.js of cancellation
//             browser.runtime.sendMessage({
//                 message: {
//                     message: `cancel`,
//                 },
//             });
//             break;
});


log(`loaded`);
