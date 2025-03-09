#!/bin/bash
set -e

echo "🚀 Richte das Backend mit NestJS, TypeScript und Prisma ein..."

cd FreeWorldFirst/backend

# NestJS CLI installieren und Projekt initialisieren
npm i -g @nestjs/cli
nest new . --package-manager npm

# Zusätzliche Abhängigkeiten installieren
npm install @nestjs/config @nestjs/swagger @nestjs/jwt @nestjs/passport
npm install passport passport-jwt passport-local
npm install prisma @prisma/client
npm install class-validator class-transformer
npm install bcrypt
npm install helmet
npm install cookie-parser

# Dev-Abhängigkeiten
npm install --save-dev @types/passport-jwt @types/passport-local @types/bcrypt
npm install --save-dev @types/cookie-parser

# Prisma initialisieren
npx prisma init

# Prisma Schema erstellen
cat > prisma/schema.prisma << 'EOF'
generator client {
  provider = "prisma-client-js"
}

datasource db {
  provider = "postgresql"
  url      = env("DATABASE_URL")
}

model User {
  id          String        @id @default(uuid())
  username    String        @unique
  email       String        @unique
  password    String
  isAdmin     Boolean       @default(false)
  createdAt   DateTime      @default(now())
  updatedAt   DateTime      @updatedAt
  alternatives Alternative[] @relation("SubmittedBy")
  comments    Comment[]     
  votes       Vote[]
}

model Alternative {
  id          String        @id @default(uuid())
  title       String
  replaces    String
  description String
  reasons     String
  benefits    String
  website     String?
  category    String
  upvotes     Int           @default(0)
  approved    Boolean       @default(false)
  submitter   User          @relation("SubmittedBy", fields: [submitterId], references: [id])
  submitterId String
  createdAt   DateTime      @default(now())
  updatedAt   DateTime      @updatedAt
  comments    Comment[]
  votes       Vote[]
}

model Comment {
  id            String      @id @default(uuid())
  content       String
  user          User        @relation(fields: [userId], references: [id])
  userId        String
  alternative   Alternative @relation(fields: [alternativeId], references: [id])
  alternativeId String
  createdAt     DateTime    @default(now())
  updatedAt     DateTime    @updatedAt
}

model Vote {
  id            String      @id @default(uuid())
  type          String      // "upvote" oder "downvote"
  user          User        @relation(fields: [userId], references: [id])
  userId        String
  alternative   Alternative @relation(fields: [alternativeId], references: [id])
  alternativeId String
  createdAt     DateTime    @default(now())
  updatedAt     DateTime    @updatedAt

  @@unique([userId, alternativeId])
}
EOF

# .env Datei erstellen
cat > .env << 'EOF'
DATABASE_URL="postgresql://postgres:postgres@localhost:5432/freeworldfirst?schema=public"
JWT_SECRET="super-secret-jwt-key-replace-in-production"
JWT_EXPIRATION="1d"
PORT=3001
EOF

# App-Modul aktualisieren
cat > src/app.module.ts << 'EOF'
import { Module } from '@nestjs/common';
import { ConfigModule } from '@nestjs/config';
import { APP_GUARD } from '@nestjs/core';
import { AppController } from './app.controller';
import { AppService } from './app.service';
import { PrismaModule } from './prisma/prisma.module';
import { UsersModule } from './users/users.module';
import { AlternativesModule } from './alternatives/alternatives.module';
import { CommentsModule } from './comments/comments.module';
import { AuthModule } from './auth/auth.module';
import { JwtAuthGuard } from './auth/guards/jwt-auth.guard';

@Module({
  imports: [
    ConfigModule.forRoot({
      isGlobal: true,
    }),
    PrismaModule,
    UsersModule,
    AlternativesModule,
    CommentsModule,
    AuthModule,
  ],
  controllers: [AppController],
  providers: [
    AppService,
    {
      provide: APP_GUARD,
      useClass: JwtAuthGuard,
    },
  ],
})
export class AppModule {}
EOF

# Erstellen der Module und Basisstruktur

# Prisma-Service
mkdir -p src/prisma
cat > src/prisma/prisma.module.ts << 'EOF'
import { Module, Global } from '@nestjs/common';
import { PrismaService } from './prisma.service';

@Global()
@Module({
  providers: [PrismaService],
  exports: [PrismaService],
})
export class PrismaModule {}
EOF

cat > src/prisma/prisma.service.ts << 'EOF'
import { Injectable, OnModuleInit, OnModuleDestroy } from '@nestjs/common';
import { PrismaClient } from '@prisma/client';

@Injectable()
export class PrismaService extends PrismaClient implements OnModuleInit, OnModuleDestroy {
  constructor() {
    super({
      log: process.env.NODE_ENV === 'development' ? ['query', 'info', 'warn', 'error'] : ['error'],
    });
  }

  async onModuleInit() {
    await this.$connect();
  }

  async onModuleDestroy() {
    await this.$disconnect();
  }
}
EOF

# Auth Module
mkdir -p src/auth/guards src/auth/strategies src/auth/dto
cat > src/auth/auth.module.ts << 'EOF'
import { Module } from '@nestjs/common';
import { JwtModule } from '@nestjs/jwt';
import { PassportModule } from '@nestjs/passport';
import { ConfigModule, ConfigService } from '@nestjs/config';
import { AuthService } from './auth.service';
import { AuthController } from './auth.controller';
import { JwtStrategy } from './strategies/jwt.strategy';
import { LocalStrategy } from './strategies/local.strategy';
import { UsersModule } from '../users/users.module';

@Module({
  imports: [
    UsersModule,
    PassportModule,
    JwtModule.registerAsync({
      imports: [ConfigModule],
      useFactory: async (configService: ConfigService) => ({
        secret: configService.get<string>('JWT_SECRET'),
        signOptions: {
          expiresIn: configService.get<string>('JWT_EXPIRATION', '1d'),
        },
      }),
      inject: [ConfigService],
    }),
  ],
  controllers: [AuthController],
  providers: [AuthService, JwtStrategy, LocalStrategy],
  exports: [AuthService],
})
export class AuthModule {}
EOF

# Erstellen der Modul-Struktur für andere Bereiche
mkdir -p src/users/dto src/users/entities
mkdir -p src/alternatives/dto src/alternatives/entities
mkdir -p src/comments/dto src/comments/entities

# Main.ts aktualisieren für Swagger
cat > src/main.ts << 'EOF'
import { NestFactory } from '@nestjs/core';
import { ValidationPipe } from '@nestjs/common';
import { SwaggerModule, DocumentBuilder } from '@nestjs/swagger';
import { ConfigService } from '@nestjs/config';
import * as cookieParser from 'cookie-parser';
import * as helmet from 'helmet';
import { AppModule } from './app.module';

async function bootstrap() {
  const app = await NestFactory.create(AppModule);
  const configService = app.get(ConfigService);
  
  // Globale Validierung einrichten
  app.useGlobalPipes(
    new ValidationPipe({
      whitelist: true,
      forbidNonWhitelisted: true,
      transform: true,
    }),
  );

  // Middleware
  app.use(cookieParser());
  app.use(helmet());
  
  // CORS konfigurieren
  app.enableCors({
    origin: configService.get('FRONTEND_URL', 'http://localhost:3000'),
    credentials: true,
  });

  // Swagger API-Dokumentation einrichten
  const config = new DocumentBuilder()
    .setTitle('FreeWorldFirst Collector API')
    .setDescription('API für ethische Alternativen zu BigTech-Produkten')
    .setVersion('1.0')
    .addBearerAuth()
    .build();
  const document = SwaggerModule.createDocument(app, config);
  SwaggerModule.setup('api/docs', app, document);

  const port = configService.get<number>('PORT', 3001);
  await app.listen(port);
  console.log(`Application is running on: http://localhost:${port}`);
}
bootstrap();
EOF

# JwtAuthGuard erstellen
cat > src/auth/guards/jwt-auth.guard.ts << 'EOF'
import { Injectable, ExecutionContext } from '@nestjs/common';
import { Reflector } from '@nestjs/core';
import { AuthGuard } from '@nestjs/passport';
import { IS_PUBLIC_KEY } from '../decorators/public.decorator';

@Injectable()
export class JwtAuthGuard extends AuthGuard('jwt') {
  constructor(private reflector: Reflector) {
    super();
  }

  canActivate(context: ExecutionContext) {
    const isPublic = this.reflector.getAllAndOverride<boolean>(IS_PUBLIC_KEY, [
      context.getHandler(),
      context.getClass(),
    ]);
    
    if (isPublic) {
      return true;
    }
    
    return super.canActivate(context);
  }
}
EOF

# Public Decorator erstellen
mkdir -p src/auth/decorators
cat > src/auth/decorators/public.decorator.ts << 'EOF'
import { SetMetadata } from '@nestjs/common';

export const IS_PUBLIC_KEY = 'isPublic';
export const Public = () => SetMetadata(IS_PUBLIC_KEY, true);
EOF

echo "✅ Backend-Setup erfolgreich abgeschlossen!"