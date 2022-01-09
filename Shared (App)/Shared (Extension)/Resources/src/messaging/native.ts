// Native messaging conforms to a set of shared interfaces between the
// TypeScript and Swift code, which allows us to fully type the messages
// up and down the stack, and validate when emitting and receiving.

import { EthGetAccountsMessage } from './messages/eth_getAccounts';
import { EthGetBalanceMessage } from './messages/eth_getBalance';
import { HelloFrenMessage } from './messages/helloFren';

export type NativeMessages = 
 | EthGetAccountsMessage
 | EthGetBalanceMessage
 | HelloFrenMessage;

export type NativeMethodParams = {
    eth_getAccounts: EthGetAccountsMessage['params'];
    eth_getBalance: EthGetBalanceMessage['params'];
    helloFren: HelloFrenMessage['params'];
};
