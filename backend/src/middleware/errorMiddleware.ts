import { Request, Response, NextFunction } from 'express';
import { ZodError } from 'zod';
import { errorResponse } from '@/utils/responseHandler';

/**
 * @summary
 * Global error handling middleware.
 * Catches errors from controllers and other middleware.
 */
export function errorMiddleware(
  error: Error,
  _req: Request,
  res: Response,
  _next: NextFunction // eslint-disable-line @typescript-eslint/no-unused-vars
): void {
  console.error('Global Error Handler:', error);

  if (error instanceof ZodError) {
    res.status(400).json(errorResponse('Validation error', 'VALIDATION_ERROR', error.errors));
    return;
  }

  // Handle MS SQL Server custom errors (RAISERROR)
  if ('number' in error && (error as any).number >= 50000) {
    res.status(400).json(errorResponse(error.message, 'BUSINESS_RULE_VIOLATION'));
    return;
  }

  res
    .status(500)
    .json(errorResponse('An unexpected internal server error occurred.', 'INTERNAL_SERVER_ERROR'));
}
