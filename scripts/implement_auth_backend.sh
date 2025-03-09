#!/bin/bash
set -e

echo "🔐 Implementiere Authentifizierungsmodul im Backend..."

cd FreeWorldFirst/backend

# DTO für Authentifizierung erstellen
mkdir -p src/auth/dto

cat > src/auth/dto/login.dto.ts << 'EOF'
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
EOF

cat > src/auth/dto/register.dto.ts << 'EOF'
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
EOF

# Auth Service implementieren
cat > src/auth/auth.service.ts << 'EOF'
import { Injectable, UnauthorizedException, ConflictException } from '@nestjs/common';
import { JwtService } from '@nestjs/jwt';
import { PrismaService } from '../prisma/prisma.service';
import { LoginDto } from './dto/login.dto';
import { RegisterDto } from './dto/register.dto';
import * as bcrypt from 'bcrypt';

@Injectable()
export class AuthService {
  constructor(
    private readonly prisma: PrismaService,
    private readonly jwtService: JwtService,
  ) {}

  async validateUser(email: string, password: string): Promise<any> {
    const user = await this.prisma.user.findUnique({ where: { email } });
    if (user && await bcrypt.compare(password, user.password)) {
      const { password, ...result } = user;
      return result;
    }
    return null;
  }

  async login(loginDto: LoginDto) {
    const user = await this.validateUser(loginDto.email, loginDto.password);
    if (!user) {
      throw new UnauthorizedException('Ungültige Anmeldedaten');
    }
    
    const payload = { username: user.username, sub: user.id };
    return {
      access_token: this.jwtService.sign(payload),
      user: {
        id: user.id,
        username: user.username,
        email: user.email,
        isAdmin: user.isAdmin,
      }
    };
  }

  async register(registerDto: RegisterDto) {
    // Überprüfen, ob die E-Mail bereits existiert
    const emailExists = await this.prisma.user.findUnique({
      where: { email: registerDto.email },
    });

    if (emailExists) {
      throw new ConflictException('Diese E-Mail-Adresse wird bereits verwendet');
    }

    // Überprüfen, ob der Benutzername bereits existiert
    const usernameExists = await this.prisma.user.findUnique({
      where: { username: registerDto.username },
    });

    if (usernameExists) {
      throw new ConflictException('Dieser Benutzername wird bereits verwendet');
    }

    // Passwort hashen
    const hashedPassword = await bcrypt.hash(registerDto.password, 10);

    // Benutzer erstellen
    const user = await this.prisma.user.create({
      data: {
        username: registerDto.username,
        email: registerDto.email,
        password: hashedPassword,
      },
    });

    const { password, ...result } = user;
    const payload = { username: result.username, sub: result.id };

    return {
      access_token: this.jwtService.sign(payload),
      user: {
        id: result.id,
        username: result.username,
        email: result.email,
        isAdmin: result.isAdmin,
      }
    };
  }

  async getProfile(userId: string) {
    const user = await this.prisma.user.findUnique({
      where: { id: userId },
      select: {
        id: true,
        username: true,
        email: true,
        isAdmin: true,
        createdAt: true,
      },
    });

    if (!user) {
      throw new UnauthorizedException('Benutzer nicht gefunden');
    }

    return user;
  }
}
EOF

# JWT Strategy implementieren
mkdir -p src/auth/strategies

cat > src/auth/strategies/jwt.strategy.ts << 'EOF'
import { Injectable } from '@nestjs/common';
import { PassportStrategy } from '@nestjs/passport';
import { ExtractJwt, Strategy } from 'passport-jwt';
import { ConfigService } from '@nestjs/config';

@Injectable()
export class JwtStrategy extends PassportStrategy(Strategy) {
  constructor(private configService: ConfigService) {
    super({
      jwtFromRequest: ExtractJwt.fromAuthHeaderAsBearerToken(),
      ignoreExpiration: false,
      secretOrKey: configService.get<string>('JWT_SECRET'),
    });
  }

  async validate(payload: any) {
    return { userId: payload.sub, username: payload.username };
  }
}
EOF

cat > src/auth/strategies/local.strategy.ts << 'EOF'
import { Injectable, UnauthorizedException } from '@nestjs/common';
import { PassportStrategy } from '@nestjs/passport';
import { Strategy } from 'passport-local';
import { AuthService } from '../auth.service';

@Injectable()
export class LocalStrategy extends PassportStrategy(Strategy) {
  constructor(private authService: AuthService) {
    super({ usernameField: 'email' });
  }

  async validate(email: string, password: string): Promise<any> {
    const user = await this.authService.validateUser(email, password);
    if (!user) {
      throw new UnauthorizedException('Ungültige Anmeldedaten');
    }
    return user;
  }
}
EOF

# Auth Controller implementieren
cat > src/auth/auth.controller.ts << 'EOF'
import { Controller, Post, Body, Get, UseGuards, Request } from '@nestjs/common';
import { ApiTags, ApiOperation, ApiResponse, ApiBearerAuth } from '@nestjs/swagger';
import { AuthService } from './auth.service';
import { LoginDto } from './dto/login.dto';
import { RegisterDto } from './dto/register.dto';
import { JwtAuthGuard } from './guards/jwt-auth.guard';
import { LocalAuthGuard } from './guards/local-auth.guard';
import { Public } from './decorators/public.decorator';

@ApiTags('auth')
@Controller('auth')
export class AuthController {
  constructor(private readonly authService: AuthService) {}

  @Public()
  @UseGuards(LocalAuthGuard)
  @Post('login')
  @ApiOperation({ summary: 'Benutzeranmeldung' })
  @ApiResponse({ status: 200, description: 'Erfolgreich angemeldet' })
  @ApiResponse({ status: 401, description: 'Ungültige Anmeldedaten' })
  login(@Body() loginDto: LoginDto) {
    return this.authService.login(loginDto);
  }

  @Public()
  @Post('register')
  @ApiOperation({ summary: 'Neuen Benutzer registrieren' })
  @ApiResponse({ status: 201, description: 'Benutzer erfolgreich erstellt' })
  @ApiResponse({ status: 409, description: 'E-Mail oder Benutzername bereits in Verwendung' })
  register(@Body() registerDto: RegisterDto) {
    return this.authService.register(registerDto);
  }

  @UseGuards(JwtAuthGuard)
  @Get('profile')
  @ApiBearerAuth()
  @ApiOperation({ summary: 'Benutzerprofil abrufen' })
  @ApiResponse({ status: 200, description: 'Profil erfolgreich abgerufen' })
  @ApiResponse({ status: 401, description: 'Nicht autorisiert' })
  getProfile(@Request() req) {
    return this.authService.getProfile(req.user.userId);
  }
}
EOF

# Auth Guards implementieren
mkdir -p src/auth/guards

cat > src/auth/guards/local-auth.guard.ts << 'EOF'
import { Injectable } from '@nestjs/common';
import { AuthGuard } from '@nestjs/passport';

@Injectable()
export class LocalAuthGuard extends AuthGuard('local') {}
EOF

# Admin Guard implementieren
cat > src/auth/guards/admin.guard.ts << 'EOF'
import { Injectable, CanActivate, ExecutionContext, ForbiddenException } from '@nestjs/common';
import { PrismaService } from '../../prisma/prisma.service';

@Injectable()
export class AdminGuard implements CanActivate {
  constructor(private prisma: PrismaService) {}

  async canActivate(context: ExecutionContext): Promise<boolean> {
    const request = context.switchToHttp().getRequest();
    const userId = request.user?.userId;

    if (!userId) {
      throw new ForbiddenException('Nicht autorisiert');
    }

    const user = await this.prisma.user.findUnique({
      where: { id: userId },
      select: { isAdmin: true },
    });

    if (!user || !user.isAdmin) {
      throw new ForbiddenException('Administratorrechte erforderlich');
    }

    return true;
  }
}
EOF

echo "✅ Authentifizierungsmodul im Backend erfolgreich implementiert!"