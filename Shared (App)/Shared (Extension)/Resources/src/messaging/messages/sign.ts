export type SignMessage = {
    method: 'sign';
    params: {
        method:
            | 'eth_sign'
            | 'personal_sign'
            | 'eth_signTypedData_v3'
            | 'eth_signTypedData_v4';
        address: string;
        data: string;
    };
};
