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
