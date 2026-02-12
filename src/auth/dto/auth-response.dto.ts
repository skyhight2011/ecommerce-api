import { ApiProperty } from '@nestjs/swagger';

export class AuthResponseDto {
  @ApiProperty({
    description: 'JWT access token',
    example: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...',
  })
  accessToken!: string;

  @ApiProperty({
    description: 'Token type',
    example: 'Bearer',
  })
  tokenType: string = 'Bearer';

  @ApiProperty({
    description: 'Token expiration time',
    example: '7d',
  })
  expiresIn!: string;

  @ApiProperty({
    description: 'User information',
  })
  user!: {
    id: string;
    email: string;
    firstName?: string;
    lastName?: string;
    role: string;
  };
}
