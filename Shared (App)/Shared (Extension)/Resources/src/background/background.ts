import { getMessenger, OnMessage } from '../messaging';

import { getLogger } from '../utils';

const log = getLogger('background');
const Messenger = getMessenger('background', { logger: log });

browser.runtime.onMessage.addListener((request, sender, sendResponse) => {
    log(`Received message from browser runtime: ${JSON.stringify(request)}`);

    const onMethod: OnMessage = async (methodName, handler) => {
        const { destination, method, sessionId, params } = request;

        if (destination !== `background`) return;
        if (method !== methodName) return;

        log(
            `Received method '${method}' with params: ${JSON.stringify(params)}`
        );

        await handler(params, sessionId);
    };

    onMethod('getState', async (_params, sessionId) => {
        const [address] = await Messenger.sendToNative(
            'eth_getAccounts',
            sessionId
        );

        const balance = await Messenger.sendToNative(
            'eth_getBalance',
            sessionId,
            {
                address,
                block: 'latest'
            }
        );

        // TODO: address could return a { error: 'error message' } object. We need to check for that

        sendResponse({ address, balance });
        Messenger.sendToPopup('updateState', {
            address,
            balance
        });
    });

    onMethod('eth_signTypedData_v3', async (params, sessionId) => {
        log('eth_signTypedData_v3: sending to native', params);

        const signature = await Messenger.sendToNative(
            'signTypedData',
            sessionId,
            {
                version: 'v3',
                address: params[0],
                data: params[1]
            }
        );

        log(`eth_signTypedData_v3 response: ${JSON.stringify(signature)}`);

        // TODO: Handle user cancelation

        sendResponse({ signature });
    });

    // TODO: Merge with eth_signTypedData_v3
    onMethod('eth_signTypedData_v4', async (params, sessionId) => {
        log('eth_signTypedData_v4: sending to native', params);

        const signature = await Messenger.sendToNative(
            'signTypedData',
            sessionId,
            {
                version: 'v4',
                address: params[0],
                data: params[1]
            }
        );

        log(`eth_signTypedData_v4 response: ${JSON.stringify(signature)}`);

        // TODO: Handle user cancelation

        sendResponse({ signature });
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
    return true; // https://developer.mozilla.org/en-US/docs/Mozilla/Add-ons/WebExtensions/API/runtime/onMessage#sending_an_asynchronous_response_using_sendresponse
});

log(`loaded`);
