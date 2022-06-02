import { APIGatewayProxyResult, Context as LambdaContext } from 'aws-lambda';
import { Schema, InferType } from 'yup';
import { ReturnableError, FailuredRequestError } from './errors';
import { RequestEvent, cleanHeaders, validateRequestBody } from './request';
import { defaultHeaders } from './response';
import { createContext, Context} from './context';
import { stripUndefinedValues } from '../utils';

export type HandlerResponse<B> = {
    statusCode?: number;
    headers?: Record<string, string>;
    body: B;
};

export type HandlerOptions<S extends Schema> = {
    bodySchema?: S,
};

export const createHandler = <B, S extends Schema>(
    options: HandlerOptions<S>,
    handler: (
        e: RequestEvent<S extends never ? (string | undefined) : InferType<S>>,
        c: Context,
    ) => Promise<HandlerResponse<B>>,
) => (
    async (
        event: RequestEvent<string>,
        lambdaContext: LambdaContext,
    ): Promise<APIGatewayProxyResult> => {
        if (event.headers) {
            cleanHeaders(event.headers as Record<string, string>);
        }
        const context = await createContext(event, lambdaContext);
        let response;
        try {
            const processedEvent = event;
            if (options?.bodySchema) {
                processedEvent.body = await validateRequestBody(
                    event.body ?? '',
                    options.bodySchema,
                );
            }
            response = await handler(processedEvent as any, context);
        } catch (e) {
            console.log('Error Result: ', e);
            if (e instanceof ReturnableError) {
                return e.asApiResponse();
            }
            return new FailuredRequestError().asApiResponse();
        }
        return {
            statusCode: response.statusCode ?? (
                response.body === undefined
                    ? 204
                    : 200
            ),
            headers: stripUndefinedValues({
                ...defaultHeaders,
                ...response.headers,
            }),
            body: (
                response.body === undefined
                    ? ''
                    : JSON.stringify(response.body)
            ),
        };
    }
);

