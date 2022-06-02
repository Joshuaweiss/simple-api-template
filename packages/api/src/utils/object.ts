type ExcludeUndefined<K extends string | number | symbol, O extends Record<K, any>> = (
    O[K] extends undefined ? never : K
)

export const stripUndefinedValues = <
    O extends Record<string, unknown>
>(obj: O): Omit<O, ExcludeUndefined<keyof O, O>> => {
    const o: Record<string, unknown> = {};
    for (const k in obj) {
        if (
            Object.prototype.hasOwnProperty.call(obj, k)
            && obj[k] !== undefined
        ) {
            o[k] = obj[k];
        }
    }
    return o as Omit<O, ExcludeUndefined<keyof O, O>>;
}
