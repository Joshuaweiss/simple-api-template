import { SecretsManagerClient, GetSecretValueCommand } from "@aws-sdk/client-secrets-manager";

const secretManagerClient = new SecretsManagerClient({});

const stage = process.env.STAGE ?? 'local';

const getConnection = async () => {
    if (stage === 'local') {
        const localConfig = {
            user: 'master',
            password: '1234',
            database: 'test_proj_db',
            host: 'localhost',
            port: 5432,
        };
        console.log('DATABASE CONNECTION', localConfig);
        return localConfig;
    }

    console.log('GET DATABASE PASSWORD');
    const { SecretString: password } = await secretManagerClient.send(
        new GetSecretValueCommand({
            SecretId: process.env.RDS_PASSWORD_SECRET_ID,
        }),
    );

    const connectionConfig = {
        user: process.env.MASTER_USERNAME,
        password: `${password}`,
        database: process.env.DATABASE_NAME,
        host: process.env.RDS_ENDPOINT,
        port: 5432,
    };

    console.log('DATABASE CONNECTION', {
        ...connectionConfig,
        password: '********',
    });

    return connectionConfig;
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
