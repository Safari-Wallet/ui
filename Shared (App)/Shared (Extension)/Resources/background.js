`use strict`;

let method = ``;

// For message signing:
let from = ``;
let params = {};

browser.runtime.onMessage.addListener(async (request, sender, sendResponse) => {
    if (typeof request.message === `undefined`) {
        console.log(`before switch: request.message is undefined`);
        return;
    }

    switch (request.message.message) {
        case `eth_requestAccounts`: // * Return requested data from native app to popup.js
            const address = await browser.runtime.sendNativeMessage(`eth_requestAccounts`);
            console.log(`address:`);
            console.table(address);
            if (typeof address.error !== `undefined`) {
                // TODO handle error
                console.log(`Error fetching address:`, address.error);
            } else {
                browser.runtime.sendMessage({
                    message: {
                        message: address,
                    },
                });
            }
            break;
        case `eth_signTypedData_v3`: // * Return requested data from native app to popup.js
            /*
            TODO
            const signature = await browser.runtime.sendNativeMessage({
                from: request.message.from,
                message: `eth_signTypedData_v3`,
                params: request.message.params,
            });
            browser.runtime.sendMessage({
                message: signature.message,
            });
            */
            break;
        case `eth_call`:
            console.log(`background.js has received eth_call`);
//            const data = await browser.runtime.sendNativeMessage(JSON.stringify({
//                method: `eth_call`,
//                params: ``,
//            }));
            const data = await browser.runtime.sendNativeMessage({
                method: `eth_call`,
                params: `this is a mock parameter`,
            });
            console.table(data);
            break;
        case `cancel`: // * Cancel current method and notify popup.js of cancellation
            browser.runtime.sendMessage({
                message: {
                    message: `cancel`,
                },
            });
            break;
        case `get_state`: // * Send current method, address, balance, and network (?) to popup.js
            const currentAddress = await browser.runtime.sendNativeMessage(`eth_getAccounts`);
            const balance = await browser.runtime.sendNativeMessage(`eth_getBalance`);
            console.log(`currentAddress response: `, currentAddress);
            console.log(`currentBalance response: `, balance);
            // TODO: address could return a { error: 'error message' } object. We need to check for that 
            browser.runtime.sendMessage({
                message: {
                    address: currentAddress[0],
                    balance: balance,
                    from,
                    method,
                    params,
                },
            });
//            break;
//        case `eth_sign`: // * Sings message. Send as hex string
            const signature = await browser.runtime.sendNativeMessage({
                method: `eth_sign`,
                params: [`0xdeadbeaf`], // optional second item: password of the wallet
            });
            console.log(`eth_sign response: `, signature);
            // TODO: address could return a { error: 'error message' } object. We need to check for that
//            browser.runtime.sendMessage({
//                message: {
//                    signature: signature,
//                    from,
//                    method,
//                    params,
//                },
//            });
            break;
        case `update_method`: // * Update current method from content.js
            method = request.message.method === `cancel`
                ? ``
                : request.message.method;
            console.log(`new method, `, method);
            break;
        case `update_from`: // * Update "from" for message signing from content.js
            from = request.message.from;
            break;
        case `update_params`: // * Update "params" for message signing from content.js
            params = request.message.params;
            break;
        default: // * Unimplemented or invalid method
            console.log(`background [unimplemented]:`, request.message.message);
    }
});
