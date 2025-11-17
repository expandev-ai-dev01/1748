import sql, { ConnectionPool, IRecordSet, Request } from 'mssql';
import { config } from '@/config';

let pool: ConnectionPool;

/**
 * @summary
 * Establishes a connection pool to the SQL Server database.
 */
export const connectToDatabase = async (): Promise<void> => {
  try {
    const dbConfig = {
      server: config.database.server,
      port: config.database.port,
      user: config.database.user,
      password: config.database.password,
      database: config.database.database,
      options: {
        ...config.database.options,
        connectionTimeout: 30000,
        pool: {
          max: 10,
          min: 0,
          idleTimeoutMillis: 30000,
        },
      },
    };
    pool = await new ConnectionPool(dbConfig).connect();
  } catch (error) {
    console.error('Database connection failed:', error);
    throw error;
  }
};

/**
 * @summary
 * Returns the active connection pool.
 * @returns {ConnectionPool} The SQL Server connection pool.
 */
export const getPool = (): ConnectionPool => {
  if (!pool) {
    throw new Error(
      'Database connection pool has not been initialized. Call connectToDatabase first.'
    );
  }
  return pool;
};

/**
 * @summary
 * Executes a stored procedure with the given parameters.
 * @param {string} procedureName The name of the stored procedure to execute.
 * @param {object} params An object containing the input parameters for the procedure.
 * @returns {Promise<IRecordSet<any>[]>} A promise that resolves to the result sets.
 */
export const executeProcedure = async (
  procedureName: string,
  params: Record<string, any> = {}
): Promise<IRecordSet<any>[]> => {
  const request: Request = getPool().request();
  for (const key in params) {
    if (Object.prototype.hasOwnProperty.call(params, key)) {
      request.input(key, params[key]);
    }
  }
  const result = await request.execute(procedureName);

  if (Array.isArray(result.recordsets)) {
    return result.recordsets;
  }

  return [result.recordset];
};
