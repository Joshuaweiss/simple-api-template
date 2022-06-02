import { Schema, InferType, ValidationError, object } from 'yup';
import { APIGatewayEvent } from 'aws-lambda';
import { InvalidRequestError, InvalidRequestBodyJsonError } from '../helpers/errors'

export type RequestEvent<B> = APIGatewayEvent & {
    body: B;
}

export const cleanHeaders = (headers: Record<string, string>): void => {
    Object.keys(headers).forEach((key) => {
        const lower = key.toLowerCase();
        if (key !== lower) {
            /* eslint-disable no-param-reassign */
            headers[lower] = headers[key];
            delete headers[key];
        }
    });
};

export const validateRequestBody = async <S extends Schema>(
    body: string,
    yupSchema: S,
): Promise<InferType<S>> => {
    let json;
    try {
        json = JSON.parse(body);
    } catch (e) {
        console.log(e);
        throw new InvalidRequestBodyJsonError();
    }
    try {
        return await yupSchema.validate(json);
    } catch (e) {
        console.log(e);
        if (e instanceof ValidationError) {
            throw new InvalidRequestError(e.errors);
        }
        throw e;
    }
};
