import { Knex } from 'knex';
import {
    APIGatewayEvent,
    Context as LambdaContext
} from 'aws-lambda';
import { createKnex } from './database';

type JWT = {
    claims: {
        sub: string;
    };
    scopes: Array<string>;
};

export type Context = {
    auth: JWT | undefined;
    dbHandle: Knex;
    dbTransaction: (fn: (trx: Context) => Promise<void>) => Promise<void>;
    lambdaContext: LambdaContext;
};

export const createContext = async (
    event: APIGatewayEvent,
    lambdaContext: LambdaContext,
): Promise<Context> => {
    const context = {
        auth: event.requestContext?.authorizer?.jwt,
        lambdaContext,
        // We intentionally don't lazily initialize the db handle.
        // If we did we would have to build all queries within async code.
        // This would be a problem because knex queries are overloaded to look
        // like promises and awaiting a query returns the the result. What looks
        // like valid code could evalutate a query before it's done being built.
        // There are other ways to explicitly opt into creating the handle in
        // requests if required.
        dbHandle: await createKnex(),
        dbTransaction: async (fn: (c: Context) => Promise<void>): Promise<void> => (
            context.dbHandle.transaction((trx) => (
                fn({
                    ...context,
                    dbHandle: trx,
                })
            ))
        ),
    };
    return context;
};
