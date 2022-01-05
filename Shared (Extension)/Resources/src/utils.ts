// - MARK: Types

export type Optional<T> = T | null;

// - MARK: Logging

export type Logger = (message: string, ...others: any[]) => void;

export const getLogger =
    (fileName: string): Logger =>
    (message: string, ...others: any[]) =>
        console.log(`[${fileName}.js] ${message}`, ...others);

export const getErrorLogger =
    (fileName: string): Logger =>
    (message: string, ...others: any[]) =>
        console.error(`[${fileName}.js] ${message}`, ...others);

// - MARK: DOM Helpers

export const $ = <Q extends string>(
    query: Q
): Optional<Q extends `#${string}` ? Element : NodeListOf<Element>> =>
    (query[0] === `#`
        ? document.querySelector(query)
        : document.querySelectorAll(query)) as any;
