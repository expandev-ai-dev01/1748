import { z } from 'zod';

// Reusable Zod schemas for common data types

/**
 * @summary Validates a foreign key (positive integer).
 */
export const zFK = z.coerce.number().int().positive({ message: 'Must be a positive integer' });

/**
 * @summary Validates an optional/nullable foreign key.
 */
export const zNullableFK = zFK.nullable();

/**
 * @summary Validates a standard name string (1-100 characters).
 */
export const zName = z
  .string()
  .min(1, 'Name cannot be empty')
  .max(100, 'Name cannot exceed 100 characters');

/**
 * @summary Validates an optional/nullable description string (max 500 characters).
 */
export const zNullableDescription = z
  .string()
  .max(500, 'Description cannot exceed 500 characters')
  .nullable();

/**
 * @summary Validates a BIT type from the database (coerces to boolean).
 */
export const zBit = z.coerce.boolean();
