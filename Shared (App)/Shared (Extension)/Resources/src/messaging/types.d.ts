import { NativeMessages, NativeMethodParams } from './native';

export type NativeMethodName = NativeMessages['method'];

export interface NativeMessage<M extends NativeMethodName, P extends NativeMethodParams<M>> {
    destination: 'native';
    method: M;
    params: P;
    sessionId?: string;
}
