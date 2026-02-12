import { Request } from 'express';

/**
 * Typed Request with User
 * Use this instead of 'any' for request objects
 */
export interface RequestWithUser extends Request {
  user: {
    id: string;
    email: string;
    role: string;
    firstName?: string | null;
    lastName?: string | null;
    status: string;
  };
}

/**
 * Type guard to check if request has user
 */
export function isRequestWithUser(req: any): req is RequestWithUser {
  return (
    req &&
    typeof req === 'object' &&
    'user' in req &&
    typeof req.user === 'object' &&
    typeof req.user.id === 'string' &&
    typeof req.user.email === 'string'
  );
}
