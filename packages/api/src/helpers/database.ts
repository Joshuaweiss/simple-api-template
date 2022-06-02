import { knexSnakeCaseMappers } from 'objection';
import knex, { Knex } from 'knex';
import makeDbConfig from '../../knexfile';

export const createKnex = async (): Promise<Knex> => (
    knex({
        ...await makeDbConfig(),
        ...knexSnakeCaseMappers(),
    })
);
