import { IsEmail, IsNotEmpty, MinLength } from 'class-validator';
import { ApiProperty } from '@nestjs/swagger';

export class LoginDto {
  @ApiProperty({ example: 'benutzer@example.com' })
  @IsEmail()
  email: string;

  @ApiProperty({ example: 'sicheres_passwort' })
  @IsNotEmpty()
  @MinLength(8)
  password: string;
}
