import { IsNotEmpty, IsString, IsOptional, MaxLength, MinLength } from 'class-validator';
import { ApiProperty } from '@nestjs/swagger';

export class CreateAlternativeDto {
  @ApiProperty({ example: 'Signal' })
  @IsNotEmpty()
  @IsString()
  @MinLength(3)
  @MaxLength(100)
  title: string;

  @ApiProperty({ example: 'WhatsApp' })
  @IsNotEmpty()
  @IsString()
  @MinLength(3)
  @MaxLength(100)
  replaces: string;

  @ApiProperty({ example: 'Signal ist ein sicherer Messenger mit Ende-zu-Ende-Verschlüsselung.' })
  @IsNotEmpty()
  @IsString()
  @MinLength(20)
  @MaxLength(2000)
  description: string;

  @ApiProperty({ example: 'WhatsApp sammelt Metadaten und gehört zu Meta (Facebook).' })
  @IsNotEmpty()
  @IsString()
  @MinLength(20)
  @MaxLength(1000)
  reasons: string;

  @ApiProperty({ example: 'Vollständige Ende-zu-Ende-Verschlüsselung, Open Source, keine Werbung.' })
  @IsNotEmpty()
  @IsString()
  @MinLength(20)
  @MaxLength(1000)
  benefits: string;

  @ApiProperty({ example: 'https://signal.org', required: false })
  @IsOptional()
  @IsString()
  website?: string;

  @ApiProperty({ example: 'Kommunikation' })
  @IsNotEmpty()
  @IsString()
  category: string;
}
