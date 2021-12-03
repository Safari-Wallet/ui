import { inject } from '../ethereum';

(async () => {
    inject();

    // * This forwards messages from popup.js to ethereum/index.js
    browser.runtime.onMessage.addListener((request, sender, sendResponse) => {
        window.postMessage(request.message);
    });

    // * This forwards messages from ethereum/index.js to background.js
    window.addEventListener(`message`, (event) => {
        browser.runtime.sendMessage({
            message: {
                message: `update_method`,
                method: event.data
            }
        });
    });
})();
