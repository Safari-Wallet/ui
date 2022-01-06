// - MARK: Types

export type Optional<T> = T | null;

// - MARK: Logging

export type Logger = (message: string, ...others: any[]) => void;

export const getLogger =
    (fileName: string): Logger =>
    (message: string, ...others: any[]) => {
        //console.log(`[${fileName}.js] ${message}`, ...others);
        // todo deal with "others"
        const xhr = new XMLHttpRequest();
        xhr.onload = (data) => {
            // todo handle
        };
        xhr.open(`POST`, `http://localhost:8081/add?message=${message}&sender=${fileName}.js`, true);
        xhr.send();
    };

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
