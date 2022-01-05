import { getLogger } from '../utils';
import { getMessenger, OnMessage } from '../messaging';
import { inject } from '../ethereum';
import { findOrCreateSessionId } from './sessions';

// - MARK: Utils

const log = getLogger(`content`);

const Messenger = getMessenger('content', {
    logger: log,
    sessionId: findOrCreateSessionId()
});

const onMessage: OnMessage = (methodName, handler) => {
    log(`Listening to content.${methodName}`);

    browser.runtime.onMessage.addListener((request, e) => {
        const { destination, method, sessionId, params } = request;

        if (destination !== `content`) return;
        if (method !== methodName) return;

        log(
            `Received method '${method}' with params: ${JSON.stringify(params)}`
        );
        handler(params, sessionId);
    });
};

log(`session ID`, findOrCreateSessionId());

// - MARK: Main

inject();

onMessage('forwardToEthereumJs', (params) => {
    window.postMessage({ ...params });
});

window.addEventListener(`message`, (event) => {
    log(`Received message from ethereum.js: ${JSON.stringify(event)}`);

    if (event.data.method) {
        Messenger.sendToBackground(event.data.method, event.data.params);
    }
});

log(`loaded`);
