import { NativeMessage } from '../types';

export type HelloFrenMessage = NativeMessage<
    'helloFren',
    {
        foo: string;
        bar: number;
        awgmi: boolean;
    }
>;
