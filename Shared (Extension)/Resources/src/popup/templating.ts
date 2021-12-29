import root from './views/root';
import loading from './views/loading';
import connectWallet from './views/connectWallet';
import signMessage from './views/signMessage';

import { error, log } from './popup';
import { $ } from '../utils';
import { View } from './types';

// - MARK: Types

export const views = {
    loading,
    root,
    connectWallet,
    signMessage
};

export type Views = typeof views;

export type ViewName = keyof Views;

export type ViewParams<N extends ViewName> = Parameters<Views[N]['render']>[0];

// - MARK: Render

export const getViewContents = <N extends ViewName>(
    viewName: N,
    params: ViewParams<N>
) => views[viewName].render(params as any);

export const render = <N extends ViewName>(
    viewName: N,
    params: ViewParams<N> = {}
) => {
    if (!viewName || !Object.keys(views).includes(viewName)) {
        error(`Invalid view name: ${viewName}.`);
        return;
    }

    const view = views[viewName] as View<ViewParams<N>>;
    if (!view || !view.render) {
        error(`Invalid view: ${viewName}.`);
        return;
    }

    const $body = $(`#body`);
    if (!$body) {
        error(`Could not find body element.`);
        return;
    }

    const viewContents = getViewContents(viewName, params);

    log(`Rendering view '${viewName}' with ${JSON.stringify(params)}`);
    log(`View contents: ${viewContents}`);
    log(`Existing HTML: ${$body.innerHTML}`);

    $body.innerHTML = viewContents;

    log(`Updated HTML: ${$body.innerHTML}`);

    if (view.onRender) view.onRender(params);
};
