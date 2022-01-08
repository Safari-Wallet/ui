import { getLogger } from '../utils';
import { getMessenger, OnMessage } from '../messaging';
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

const $injection = document.createElement('script');
$injection.type = 'text/javascript';
$injection.async = false;
$injection.src = browser.runtime.getURL('ethereum/index.js');
document.body.insertBefore($injection, document.body.firstChild);

onMessage('forwardToEthereumJs', (params) => {
    Messenger.sendToEthereumJs(params);
});

window.addEventListener(`message`, (event) => {
    if (event.data?.destination !== 'content') return;
    log(`Received message from postMessage: ${JSON.stringify(event)}`);

    const method = event.data?.method;
    if (method) {
        Messenger.sendToBackground(method, event.data.params).then((result) => {
            log(`Received message from background: ${JSON.stringify(result)}`);
            if (!result) return;
            Messenger.sendToEthereumJs({ method, params: result });
        });
    }
});

log(`loaded`);
