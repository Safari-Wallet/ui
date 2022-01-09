export type HelloFrenMessage = {
    method: "helloFren";
    params: {
        foo: string;
        bar: number;
        wagmi?: boolean;
    };
}
