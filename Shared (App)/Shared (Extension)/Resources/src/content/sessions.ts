export const findOrCreateSessionId = () => {
    let sessionId = window.sessionStorage.getItem('balanceWalletSessionId');
    if (!sessionId) {
        sessionId = Math.random().toString(36).substring(2, 15);
        window.sessionStorage.setItem('balanceWalletSessionId', sessionId);
    }
    return sessionId;
};
