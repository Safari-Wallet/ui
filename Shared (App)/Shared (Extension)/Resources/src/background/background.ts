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

    onMethod('sign', async (params, sessionId) => {
        log('sign: sending to native', params);

        const signature = await Messenger.sendToNative(
            'sign',
            sessionId,
            params
        );

        // TODO: Handle user cancelation

        sendResponse({ signature });
    });

    return true; // https://developer.mozilla.org/en-US/docs/Mozilla/Add-ons/WebExtensions/API/runtime/onMessage#sending_an_asynchronous_response_using_sendresponse
});

log(`loaded`);
