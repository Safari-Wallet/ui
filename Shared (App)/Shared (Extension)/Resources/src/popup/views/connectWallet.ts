import { $, fromHex } from '../../utils';
import { chainId, chains } from '../popup';
import { View } from '../types';
import { closeWindow } from '../utils';

const view: View<{
    address: string;
    balance: string;
    onConnectWallet: () => void;
}> = {
    render: ({ address, balance }) => `
        <h1>Connect to <span id="title"></span></h1>
        <p class="subtitle"><span id="host"></span></p>
        <p>When you connect your wallet, this dapp will be able to view the contents:</p>
        <div class="field">
            <label class="field__label" for="address">Address</label>
            <input id="address" class="field__input" type="text" value="${address}" disabled>
        </div>
        <div class="field">
            <label class="field__label" for="balance">ETH Balance</label>
            <input id="balance" class="field__input" type="text" value="${fromHex(balance) / (10 ** 18)} ${chains[chainId].gasToken}" disabled>
        </div>
        <div class="flex">
            <button id="cancel" class="button button--secondary">Cancel</button>
            <button id="connect" class="button button--primary">Connect</button>
        </div>
    `,
    onRender: ({ onConnectWallet }) => {
        $('#cancel')?.addEventListener('click', closeWindow);
        $('#connect')?.addEventListener('click', onConnectWallet);

        (browser.tabs as any).query(
            {
                active: true,
                currentWindow: true
            },
            (tabs: browser.tabs.Tab[]) => {
                const tab = tabs[0];
                const $title = $('#title');
                const $host = $('#host');

                if ($title && tab.title) $title.textContent = tab.title;
                if ($host && tab.url) $host.textContent = new URL(tab.url).host;
            }
        );
    }
};

export default view;
