import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';
import {
  IsString,
  IsNumber,
  IsOptional,
  IsEnum,
  Min,
  MaxLength,
} from 'class-validator';

enum ProductStatus {
  DRAFT = 'DRAFT',
  ACTIVE = 'ACTIVE',
  INACTIVE = 'INACTIVE',
  OUT_OF_STOCK = 'OUT_OF_STOCK',
  DISCONTINUED = 'DISCONTINUED',
}

export class CreateProductDto {
  @ApiProperty({ example: 'MacBook Pro 16"' })
  @IsString()
  @MaxLength(255)
  name!: string;

  @ApiProperty({ example: 'macbook-pro-16' })
  @IsString()
  @MaxLength(255)
  slug!: string;

  @ApiPropertyOptional({ example: 'Powerful laptop for professionals' })
  @IsOptional()
  @IsString()
  description?: string;

  @ApiProperty({ example: 2499.99 })
  @IsNumber()
  @Min(0)
  price!: number;

  @ApiPropertyOptional({ example: 2799.99 })
  @IsOptional()
  @IsNumber()
  @Min(0)
  comparePrice?: number;

  @ApiProperty({ example: 'MBP16-001' })
  @IsString()
  @MaxLength(100)
  sku!: string;

  @ApiPropertyOptional({ example: 50, default: 0 })
  @IsOptional()
  @IsNumber()
  @Min(0)
  quantity?: number;

  @ApiProperty({ example: 'category-id-here' })
  @IsString()
  categoryId!: string;

  @ApiPropertyOptional({
    enum: ProductStatus,
    default: ProductStatus.DRAFT,
  })
  @IsOptional()
  @IsEnum(ProductStatus)
  status?: ProductStatus;
}
