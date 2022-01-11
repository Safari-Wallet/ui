import { getMessenger } from '../messaging';
import { getLogger } from '../utils';

const logger = getLogger('ethereum');
const { sendToContent } = getMessenger('ethereum', { logger });

// MARK: - Setup

declare global {
    interface Window {
        ethereum: any;
    }
}

// MARK: - Styling prelims

const styleOverlay = {
    backgroundColor: `#000`,
    height: `100vh`,
    left: `0`,
    opacity: `0`,
    position: `fixed`,
    top: `0`,
    transition: `opacity .2`,
    width: `100vw`,
    willChange: `opacity`,
    zIndex: `9999999`
};

// MARK: - Class

class Ethereum {
    opened: boolean;
    overlay: HTMLDivElement;
    div: HTMLDivElement;
    message: HTMLParagraphElement;

    waitingFor: Record<string, (result: any) => void> = {};

    constructor() {
        this.opened = false;

        this.overlay = document.createElement(`div`);
        Object.assign(this.overlay.style, styleOverlay);
        this.overlay.onclick = () => this.close();

        const styleDiv = {
            alignItems: `center`,
            backgroundColor: `#fff`,
            borderRadius: `8px 8px 0 0`,
            bottom: `0`,
            columnGap: `18px`,
            display: `flex`,
            fontSize: `18px`,
            height: `45px`,
            justifyContent: `center`,
            left: `calc(calc(100vw - 368px) / 2)`,
            position: `fixed`,
            transform: `translateY(100%)`,
            transition: `transform .3s`,
            width: `368px`,
            willChange: `transform`,
            zIndex: `10000000`
        };
        this.div = document.createElement(`div`);
        this.div.innerHTML = `
        <svg width="22px" height="16px" viewBox="0 0 22 16" fill="none">
            <path fill-rule="evenodd" clip-rule="evenodd" d="M0 1.33333C0 0.597005 0.616262 0 1.37634 0H15.1398C15.8998 0 16.5161 0.597005 16.5161 1.33333V6.23633C17.0205 5.68262 17.7583 5.33333 18.5806 5.33333C20.1008 5.33333 21.3333 6.52734 21.3333 8C21.3333 9.47266 20.1008 10.6667 18.5806 10.6667C17.7583 10.6667 17.0205 10.3174 16.5161 9.76367V14.6667C16.5161 15.403 15.8998 16 15.1398 16H1.37634C0.616262 16 0 15.403 0 14.6667V10.2445C0 9.33333 1.61089 9.26921 2.07089 9.77083C2.57526 10.3203 3.31048 10.6667 4.12903 10.6667C5.64919 10.6667 6.88171 9.47266 6.88171 8C6.88171 6.52734 5.64919 5.33333 4.12903 5.33333C3.31048 5.33333 2.57526 5.67969 2.07089 6.22917C1.61089 6.73079 0 6.66667 0 5.75553V1.33333Z" fill="#3478f6" />
        </svg>
    `;
        Object.assign(this.div.style, styleDiv);

        this.message = document.createElement(`p`);
        this.message.innerText = `Open the wallet extension to connect`;

        this.div.appendChild(this.message);

        window.addEventListener('message', (event) => {
            const { method, params, destination } = event.data;

            if (destination !== 'ethereum') return;

            const resolve = this.waitingFor[method];
            if (!resolve) return;
            switch (method) {
                case 'walletConnected':
                    resolve([params.address]);
                    window.ethereum.close();
                    break;
                case 'sign':
                    resolve(params.signature);
                    break;
            }
            delete this.waitingFor[method];
        });
    }

    close() {
        window.postMessage(`cancel`);
        this.overlay.style.opacity = '0';
        this.div.style.transform = `translateY(100%)`;
        this.overlay.remove();
        this.div.remove();
        this.opened = false;
    }

    isConnected() {
        // TODO
    }

    on(event: string, _callback: any) {
        switch (event) {
            case `accountsChanged`:
                break;
            case `chainChanged`:
                break;
            case `connect`:
                break;
            case `disconnect`:
                break;
            default:
            // * Invalid or unimplemented event
        }
    }

    request(payload: { method: any; params: any; from: any }) {
        return new Promise((resolve, reject) => {
            logger('Request', payload);

            const showPrompt = (message: string) => {
                if (window.ethereum.opened === false) {
                    window.ethereum.opened = true;
                    window.ethereum.message.textContent = message;
                    document.body.insertBefore(
                        window.ethereum.overlay,
                        document.body.firstChild
                    );
                    document.body.insertBefore(
                        window.ethereum.div,
                        document.body.firstChild
                    );
                    setTimeout(() => {
                        window.ethereum.overlay.style.opacity = 0.4;
                        window.ethereum.div.style.transform = `translateY(0)`;
                    }, 1);
                }
            };

            switch (payload.method) {
                case `eth_requestAccounts`:
                    showPrompt(`Open the wallet extension to connect`);
                    this.waitingFor.walletConnected = resolve;
                    break;
                case `eth_sign`:
                case `personal_sign`:
                case `eth_signTypedData_v3`:
                case `eth_signTypedData_v4`:
                    // showPrompt(`Open the wallet extension to sign`);
                    sendToContent({
                        method: 'sign',
                        params: {
                            method: payload.method,
                            address: payload.params[0],
                            data: payload.params[1]
                        }
                    });
                    this.waitingFor.sign = resolve;
                    break;
                default:
                    // * Invalid or unimplemented method
                    logger(`Invalid or unimplemented method`, payload.method);
                    resolve(false);
            }
        });
    }
}

// MARK: - Export

if (!window.browser) {
    // Injected script is being
    (window as any).ethereum = new Ethereum();
    logger(`loaded`);
}
