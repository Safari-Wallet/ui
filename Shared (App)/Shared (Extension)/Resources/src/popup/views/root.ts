import { View } from '../types';

const view: View = {
    render: () => `
        <h1>Safari Wallet</h1>
        <div class="flex">
            <button id="cancel" class="button button--secondary">Cancel</button>
            <button id="connect" class="button button--primary">Connect</button>
        </div>
    `
};

export default view;
