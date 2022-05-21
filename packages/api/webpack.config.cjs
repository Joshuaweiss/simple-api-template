const webpack = require('webpack');
const slsw = require('serverless-webpack');
const path = require('path');

module.exports = {
    entry: slsw.lib.entries,
    target: 'node',
    mode: process.NODE_ENV ?? 'development',
    output: {
        libraryTarget: 'commonjs',
        path: path.join(__dirname, '.webpack'),
        filename: '[name].js',
    },
    resolve: {
        extensions: ['.mjs', '.js', '.ts', '.json'],
    },
    plugins: [
        new webpack.DefinePlugin({
        }),
    ],
    externals: {
		// Possible drivers for knex - we'll ignore them
		'mariasql': 'mariasql',
		'mssql': 'mssql',
		'mysql': 'mysql',
		'mysql2': 'mysql2',
		'oracle': 'oracle',
		'strong-oracle': 'strong-oracle',
		'oracledb': 'oracledb',
		'pg-query-stream': 'pg-query-stream',
		'tedious': 'tedious',
        'better-sqlite3': 'better-sqlite3',
        '@vscode/sqlite3': '@vscode/sqlite3',
        'pg-native': 'pg-native',
	},
    module: {
        rules: [
            {
                test: /\.(j|t)s$/,
                exclude: /node_modules/,
                use: {
                    loader: 'babel-loader',
                    options: {
                        presets: [
                            ['@babel/env', {
                                targets: {
                                    node: 'current',
                                    esmodules: true,
                                },
                            }],
                            '@babel/typescript',
                        ],
                    },
                },
            },
        ],
    },
};
