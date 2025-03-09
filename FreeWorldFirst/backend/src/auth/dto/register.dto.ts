import { IsEmail, IsNotEmpty, MinLength, Matches } from 'class-validator';
import { ApiProperty } from '@nestjs/swagger';

export class RegisterDto {
  @ApiProperty({ example: 'benutzer' })
  @IsNotEmpty()
  @Matches(/^[a-zA-Z0-9_-]+$/, {
    message: 'Benutzername darf nur Buchstaben, Zahlen, Unterstriche und Bindestriche enthalten',
  })
  username: string;

  @ApiProperty({ example: 'benutzer@example.com' })
  @IsEmail()
  email: string;

  @ApiProperty({ example: 'sicheres_passwort' })
  @IsNotEmpty()
  @MinLength(8)
  password: string;
}
