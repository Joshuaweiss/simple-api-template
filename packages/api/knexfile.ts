import { SSMClient, GetParameterCommand } from "@aws-sdk/client-ssm";

const ssmClient = new SSMClient({});

const stage = process.env.STAGE ?? 'local';

const getConnection = async () => {
    if (stage === 'local') {
        return {
            user: 'master',
            password: '1234',
            database: 'test_proj_db',
            host: 'localhost',
            port: 5432,
        };
    }

    const { Parameter: password } = await ssmClient.send(new GetParameterCommand({
        Name: process.env.RDS_PASSWORD_SECRET_ID,
    }));

    return {
        user: process.env.MASTER_USERNAME,
        password,
        database: process.env.DATABASE_NAME,
        host: process.env.RDS_ENDPOINT,
        port: 5432,
    };
};

export default async () => ({
    client: 'pg',
    version: '13.6',
    connection: await getConnection(),
    pool: {
        min: 0,
        max: 2,
    },
    migrations: {
        tableName: 'knex_migrations',
        extension: 'ts',
        loadExtensions: ['.ts'],
    },
});
