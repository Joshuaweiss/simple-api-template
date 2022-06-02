/* eslint-disable max-classes-per-file */
import { APIGatewayProxyResult } from 'aws-lambda';
import { defaultHeaders } from './response';

export abstract class ReturnableError extends Error {
    message: string;

    statusCode: number;

    headers: Record<string, string>;

    errors: Array<string>;

    asApiResponse(): APIGatewayProxyResult {
        const { statusCode } = this;
        return {
            statusCode,
            headers: this.headers,
            body: JSON.stringify({
                statusCode,
                name: this.name,
                errors: this.errors,
            }),
        };
    }
}

export class FailuredRequestError extends ReturnableError {
    constructor(errors: Array<string> = []) {
        super();
        this.message = 'Generic Error';
        this.statusCode = 500;
        this.headers = defaultHeaders;
        this.errors = errors;
    }
}

export class ConflictingResourceError extends ReturnableError {
    constructor(errors: Array<string> = []) {
        super();
        this.name = 'Conflicting Resource';
        this.message = 'Tried to save conflicting resource';
        this.statusCode = 409;
        this.errors = errors;
    }
}

export class NotFoundResourceError extends ReturnableError {
    constructor(errors: Array<string> = []) {
        super();
        this.name = 'Resource Not Found';
        this.message = 'Could not find resource';
        this.statusCode = 404;
        this.errors = errors;
    }
}

export class InvalidRequestError extends ReturnableError {
    constructor(errors: Array<string> = []) {
        super();
        this.name = 'Invalid Request';
        this.message = 'Tried to make invalid request';
        this.statusCode = 400;
        this.errors = errors;
    }
}

export class UnauthorizedRequestError extends ReturnableError {
    constructor(errors: Array<string> = []) {
        super();
        this.name = 'Unauthorized';
        this.message = 'Provided credentials are invalid or expired';
        this.statusCode = 401;
        this.errors = errors;
    }
}

export class ForbiddenRequestError extends ReturnableError {
    constructor(errors: Array<string> = []) {
        super();
        this.name = 'Forbidden';
        this.message = 'Missing required permisions';
        this.statusCode = 403;
        this.errors = errors;
    }
}

export class InvalidRequestBodyJsonError extends ReturnableError {
    constructor(errors: Array<string> = []) {
        super();
        this.name = 'Invalid Request Body JSON';
        this.message = 'Request body JSON is invalid';
        this.statusCode = 400;
        this.errors = errors;
    }
}

export class ServiceUnavailableError extends ReturnableError {
    constructor(errors: Array<string> = []) {
        super();
        this.name = 'Service Unavailable';
        this.message = 'Service is temporarily unavailable';
        this.statusCode = 503;
        this.errors = errors;
    }
}

// Errors only have inherited properties which are not serialized by JSON stringify
export const formatError = (e: Error): Record<string, unknown> => {
    const result: Record<string, unknown> = {};
    for (const name of Object.getOwnPropertyNames(e)) {
        result[name] = (e as any)[name];
    }
    return result;
};
