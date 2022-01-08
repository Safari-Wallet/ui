export type SignTypedDataMessage = {
    method: 'signTypedData';
    params: {
        version: 'v3' | 'v4';
        address: string;
        data: string;
    };
};
