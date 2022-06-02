const { execSync } = require('node:child_process');

const LOCAL_CONFIG = {
    master_username: { value: 'master' },
    database_name: { value: 'test_proj_db' },
    rds_endpoint: { value: 'localhost:5432' },
    rds_password_secret_id: { value: '1234' }
};

module.exports = (conf) => {
    if (!conf.options.stage) {
        return LOCAL_CONFIG;
    }

    const commandOutput = execSync(
        [
            'terraform',
            '-chdir=../infrastructure',
            'output',
            '-json'
        ].join(' '),
    );
    return JSON.parse(commandOutput);
}
