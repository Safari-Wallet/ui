import { EthGetAccountsMessage } from './messages/eth_getAccounts';
import { EthGetBalanceMessage } from './messages/eth_getBalance';
import { HelloFrenMessage } from './messages/helloFren';

export type NativeMessages = {
    eth_getAccounts: EthGetAccountsMessage;
    eth_getBalance: EthGetBalanceMessage;
    helloFren: HelloFrenMessage;
};

export type NativeMessageMethod = keyof NativeMessages;

export type NativeMessageParams<M extends NativeMessageMethod> = NativeMessages[M]['params'];

export type NativeMessage<M extends NativeMessageMethod> = {
    destination: 'native';
    method: M;
    params: NativeMessageParams<M>;
    sessionId?: string;
}
