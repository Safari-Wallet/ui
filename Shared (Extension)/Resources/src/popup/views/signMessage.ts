import { $ } from '../../utils';
import { View } from '../types';
import { closeWindow } from '../utils';

const view: View<{ signMessage: () => void }> = {
    render: () => `
        <h1>Sign Message</h1>
        <div class="flex">
            <button id="cancel" class="button button--secondary">Cancel</button>
            <button id="sign" class="button button--primary">Sign</button>
        </div>
    `,
    onRender: ({ signMessage }) => {
        const $cancel = $('#cancel');
        const $sign = $('#sign');

        if ($cancel) $cancel.addEventListener(`click`, closeWindow);
        if ($sign) $sign.addEventListener(`click`, signMessage);
    }
};

export default view;
