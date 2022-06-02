export const unwrapExists = <T>(
    t: T,
    s?: string,
): Exclude<T, null | undefined> => {
    if (t == null) {
        throw Error(s ?? `Unwrapped value was ${typeof t}`);
    }
    return t as Exclude<T, null | undefined>;
};
