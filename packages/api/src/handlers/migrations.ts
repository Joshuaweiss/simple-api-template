import path from 'path';
import { createKnex } from '../helpers/database';

class WebpackMigrationSource {
    migrationContext: any;

    constructor(migrationContext: any) {
        this.migrationContext = migrationContext;
    }

    getMigrations() {
        return Promise.resolve(this.migrationContext.keys().sort());
    }

    /* eslint-disable class-methods-use-this */
    getMigrationName(migration: any) {
        return path.parse(migration).base;
    }
    /* eslint-enable class-methods-use-this */

    getMigration(migration: any) {
        return this.migrationContext(migration);
    }
}

export const handler = async () => {
    const knex = await createKnex();
    try {
        await knex.migrate.latest({
            migrationSource: new WebpackMigrationSource((require as any).context('../../migrations', false, /.ts$/)),
        });
    } finally {
        await knex.destroy();
    }
};
