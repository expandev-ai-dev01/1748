/**
 * @summary
 * Creates a standardized success response object.
 * @param data The payload to be included in the response.
 * @param metadata Optional metadata, e.g., for pagination.
 * @returns A success response object.
 */
export const successResponse = <T>(data: T, metadata?: object) => ({
  success: true,
  data,
  metadata: {
    ...metadata,
    timestamp: new Date().toISOString(),
  },
});

/**
 * @summary
 * Creates a standardized error response object.
 * @param message A descriptive error message.
 * @param code A unique error code or token.
 * @param details Optional details about the error, e.g., validation issues.
 * @returns An error response object.
 */
export const errorResponse = (message: string, code: string, details?: any) => ({
  success: false,
  error: {
    code,
    message,
    details,
  },
  timestamp: new Date().toISOString(),
});
