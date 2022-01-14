// The different components need to communicate through different channels:
// @todo

import { NativeMessageMethod, NativeMessageParams } from './messaging/index';
import { Logger } from './utils';

// - MARK: Types

export type Origin = 'content' | 'popup' | 'background' | 'ethereum';
export type Destination = 'content' | 'popup' | 'background' | 'ethereum';

export type Method = string;

export type ForwardToEthereumMethod = 'forwardToEthereumJs';

export type MethodParams = {
    [method: Method]: any;
};

export type MessageWithoutDestination<M extends Method> = {
    method: M;
    params: MethodParams[M];
};

export interface Message<M extends Method>
    extends MessageWithoutDestination<M> {
    destination: Destination;
    sessionId?: string;
}

export type OnMessage = <M extends Method>(
    methodName: M,
    handler: (
        params: MethodParams[M],
        sessionId: string
    ) => void | Promise<void>
) => void | Promise<void>;

// - MARK: Core messaging

export const getSendNativeMessage =
    (logger: Logger) =>
    <M extends NativeMessageMethod>(
        method: M,
        sessionId: string,
        params: NativeMessageParams<M> = {}
    ) => {
        const message = {
            method,
            sessionId,
            params
        };

        logger(
            `Sending message to SafariWebExtensionHandler: ${JSON.stringify(
                message
            )}`
        );

        return browser.runtime.sendNativeMessage('ignored', { message });
    };

export const getSendBrowserRuntimeMessage =
    (logger: Logger, sessionId?: string) =>
    <M extends Method>(
        destination: Destination,
        method: M,
        params: MethodParams[M] = {}
    ) => {
        const message = {
            destination,
            method,
            params,
            sessionId
        };

        logger(
            `Sending message to browser runtime: ${JSON.stringify(message)}`
        );

        return browser.runtime.sendMessage(message);
    };

export const getSendBrowserTabMessage =
    (logger: Logger, sessionId?: string) =>
    <M extends Method>(
        destination: Destination,
        method: M,
        params: MethodParams[M] = {}
    ) => {
        const message = {
            destination,
            method,
            params,
            sessionId
        };

        logger(`Sending message to browser tabs: ${JSON.stringify(message)}`);

        (browser.tabs as any).query(
            {
                active: true,
                currentWindow: true
            },
            (tabs: browser.tabs.Tab[]) => {
                const [tab] = tabs;

                if (tab && tab.id) {
                    browser.tabs.sendMessage(tab.id, message);
                }
            }
        );
    };

export const getSendMessageToEthereumJs =
    (
        logger: Logger,
        conduit: (message: MessageWithoutDestination<Method>) => void
    ) =>
    <M extends Method>(method: M, params: MethodParams[M] = {}) => {
        const message = {
            method,
            params
        };

        logger(`Sending message to Ethereum.js: ${JSON.stringify(message)}`);

        return conduit(message);
    };

export const getSendWindowMessage =
    (logger: Logger) =>
    <M extends Method>(
        destination: Destination,
        method: M,
        params: MethodParams[M] = {}
    ) =>
        window.postMessage({ destination, method, params });

// - MARK: Messaging

type Messengers = {
    background: typeof getBackgroundMessenger;
    popup: typeof getPopupMessenger;
    content: typeof getContentMessenger;
};

type MessengerReturn<O extends keyof Messengers> = ReturnType<Messengers[O]>;
type MessengerParams<O extends keyof Messengers> = Parameters<Messengers[O]>[0];

export const getMessenger = <O extends keyof Messengers>(
    origin: O,
    params: MessengerParams<O>
): MessengerReturn<O> => {
    if (origin === 'background') {
        return getBackgroundMessenger(params) as MessengerReturn<O>;
    }

    if (origin === 'popup') {
        return getPopupMessenger(params) as MessengerReturn<O>;
    }

    if (origin === 'content') {
        return getContentMessenger(params as any) as MessengerReturn<O>;
    }

    throw new Error(`Unknown origin: ${origin}`);
};

export const getBackgroundMessenger = ({ logger }: { logger: Logger }) => {
    const sendToContent = <M extends Method>({
        method,
        params
    }: MessageWithoutDestination<M>) =>
        getSendBrowserTabMessage(logger)('content', method, params);

    const sendToEthereumJs = getSendMessageToEthereumJs(logger, (params) =>
        sendToContent({ method: 'forwardToEthereumJs', params })
    );

    const sendToPopup = <M extends Method>(
        method: M,
        params: MethodParams[M] = {}
    ) => getSendBrowserRuntimeMessage(logger)('popup', method, params);

    return {
        sendToContent,
        sendToEthereumJs,
        sendToPopup,
        sendToNative: getSendNativeMessage(logger)
    };
};

export const getPopupMessenger = ({ logger }: { logger: Logger }) => {
    const sendToContent = <M extends Method>({
        method,
        params
    }: MessageWithoutDestination<M>) =>
        getSendBrowserTabMessage(logger)('content', method, params);

    const sendToEthereumJs = getSendMessageToEthereumJs(logger, (params) =>
        sendToContent({ method: 'forwardToEthereumJs', params })
    );

    const sendToBackground = <M extends Method>(
        method: M,
        params: MethodParams[M] = {}
    ) => getSendBrowserRuntimeMessage(logger)('background', method, params);

    return {
        sendToContent,
        sendToEthereumJs,
        sendToBackground,
        sendToNative: getSendNativeMessage(logger)
    };
};

export const getContentMessenger = ({
    logger,
    sessionId
}: {
    logger: Logger;
    sessionId: string;
}) => {
    const sendToPopup = <M extends Method>({
        method,
        params
    }: MessageWithoutDestination<M>) =>
        getSendBrowserRuntimeMessage(logger, sessionId)(
            'popup',
            method,
            params
        );

    const sendToEthereumJs = <M extends Method>({
        method,
        params
    }: MessageWithoutDestination<M>) =>
        getSendWindowMessage(logger)('ethereum', method, params);

    const sendToBackground = <M extends Method>(
        method: M,
        params: MethodParams[M] = {}
    ) =>
        getSendBrowserRuntimeMessage(logger, sessionId)(
            'background',
            method,
            params
        );

    return {
        sendToPopup,
        sendToEthereumJs,
        sendToBackground
    };
};
