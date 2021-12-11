import { getMessenger, OnMessage } from '../messaging';
import { getErrorLogger, getLogger } from '../utils';
import { render } from './templating';
import { closeWindow } from './utils';

// - MARK: Setup

export const log = getLogger('popup');
export const error = getErrorLogger('popup');
export const Messenger = getMessenger('popup', { logger: log });

export const chains = {
    1: {
        gasToken: `ETH`
    }
};

export const chainId: keyof typeof chains = 1;

// - MARK: Main

const main = () => {
    const onMessage: OnMessage = (methodName, handler) => {
        log(`Listening to popup.${methodName}`);

        browser.runtime.onMessage.addListener((request, e) => {
            const { destination, method, params } = request;

            if (destination !== `popup`) return;
            if (method !== methodName) return;

            log(
                `Received method '${method}' with params: ${JSON.stringify(
                    params
                )}`
            );

            handler(params, '');
        });
    };

    document.addEventListener(`DOMContentLoaded`, () => {
        onMessage('updateState', ({ address, balance }) => {
            const onConnectWallet = () => {
                Messenger.sendToEthereumJs('walletConnected', {
                    address,
                    balance,
                    chainId
                });
                closeWindow();
            };

            render('connectWallet', { address, balance, onConnectWallet });
        });

        render('loading');
        Messenger.sendToBackground('getState');

        log(`loaded`);
    });
};

main();
