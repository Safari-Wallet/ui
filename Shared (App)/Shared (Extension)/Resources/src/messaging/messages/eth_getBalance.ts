export type EthGetBalanceMessage = {
    method: "eth_getBalance";
    params: {
        address: string;
        block?: string;
    };
}
