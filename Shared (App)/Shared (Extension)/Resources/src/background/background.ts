import { getMessenger, OnMessage } from '../messaging';

import { getLogger } from '../utils';

const log = getLogger('background');
const Messenger = getMessenger('background', { logger: log });

browser.runtime.onMessage.addListener(async (request, sender, sendResponse) => {
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
            sessionId
        );

        // TODO: address could return a { error: 'error message' } object. We need to check for that

        sendResponse({ address, balance });
        Messenger.sendToPopup('updateState', {
            address,
            balance
        });
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
