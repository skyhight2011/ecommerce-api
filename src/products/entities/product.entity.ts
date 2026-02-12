import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';
import { Product as PrismaProduct, ProductStatus } from '@prisma/client';

export class ProductEntity implements Partial<PrismaProduct> {
  @ApiProperty()
  id!: string;

  @ApiProperty()
  name!: string;

  @ApiProperty()
  slug!: string;

  @ApiPropertyOptional()
  description?: string | null;

  @ApiProperty()
  price!: any;

  @ApiPropertyOptional()
  comparePrice?: any | null;

  @ApiProperty()
  sku!: string;

  @ApiProperty()
  quantity!: number;

  @ApiProperty({
    enum: ['DRAFT', 'ACTIVE', 'INACTIVE', 'OUT_OF_STOCK', 'DISCONTINUED'],
  })
  status!: ProductStatus;

  @ApiProperty()
  categoryId!: string;

  @ApiProperty()
  createdAt!: Date;

  @ApiProperty()
  updatedAt!: Date;

  constructor(partial: Partial<ProductEntity>) {
    Object.assign(this, partial);
  }
}
