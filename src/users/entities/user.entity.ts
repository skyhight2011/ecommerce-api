import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';
import { User as PrismaUser, UserRole, UserStatus } from '@prisma/client';

export class UserEntity implements Partial<PrismaUser> {
  @ApiProperty()
  id!: string;

  @ApiProperty()
  email!: string;

  @ApiPropertyOptional()
  firstName?: string | null;

  @ApiPropertyOptional()
  lastName?: string | null;

  @ApiPropertyOptional()
  phone?: string | null;

  @ApiProperty({ enum: ['ADMIN', 'CUSTOMER', 'SELLER'] })
  role!: UserRole;

  @ApiProperty({ enum: ['ACTIVE', 'INACTIVE', 'SUSPENDED', 'DELETED'] })
  status!: UserStatus;

  @ApiProperty()
  createdAt!: Date;

  @ApiProperty()
  updatedAt!: Date;

  constructor(partial: Partial<UserEntity>) {
    Object.assign(this, partial);
    // Never expose password - type-safe deletion
    const self = this as Record<string, unknown>;
    if ('password' in self) {
      delete self.password;
    }
  }
}
