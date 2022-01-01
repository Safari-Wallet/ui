export type View<P extends object = {}> = {
    render: (params: P) => string;
    onRender?: (params: P) => void;
};
