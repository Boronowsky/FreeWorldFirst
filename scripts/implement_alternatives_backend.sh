#!/bin/bash
set -e

echo "🏗️ Implementiere Alternativen-Modul im Backend..."

cd FreeWorldFirst/backend

# DTOs für Alternativen erstellen
mkdir -p src/alternatives/dto

cat > src/alternatives/dto/create-alternative.dto.ts << 'EOF'
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
EOF

cat > src/alternatives/dto/update-alternative.dto.ts << 'EOF'
import { IsString, IsOptional, MaxLength, MinLength } from 'class-validator';
import { ApiProperty } from '@nestjs/swagger';

export class UpdateAlternativeDto {
  @ApiProperty({ example: 'Signal', required: false })
  @IsOptional()
  @IsString()
  @MinLength(3)
  @MaxLength(100)
  title?: string;

  @ApiProperty({ example: 'WhatsApp', required: false })
  @IsOptional()
  @IsString()
  @MinLength(3)
  @MaxLength(100)
  replaces?: string;

  @ApiProperty({ example: 'Signal ist ein sicherer Messenger mit Ende-zu-Ende-Verschlüsselung.', required: false })
  @IsOptional()
  @IsString()
  @MinLength(20)
  @MaxLength(2000)
  description?: string;

  @ApiProperty({ example: 'WhatsApp sammelt Metadaten und gehört zu Meta (Facebook).', required: false })
  @IsOptional()
  @IsString()
  @MinLength(20)
  @MaxLength(1000)
  reasons?: string;

  @ApiProperty({ example: 'Vollständige Ende-zu-Ende-Verschlüsselung, Open Source, keine Werbung.', required: false })
  @IsOptional()
  @IsString()
  @MinLength(20)
  @MaxLength(1000)
  benefits?: string;

  @ApiProperty({ example: 'https://signal.org', required: false })
  @IsOptional()
  @IsString()
  website?: string;

  @ApiProperty({ example: 'Kommunikation', required: false })
  @IsOptional()
  @IsString()
  category?: string;
}
EOF

# Erstellen von Entity-Klassen für die Typisierung
mkdir -p src/alternatives/entities

cat > src/alternatives/entities/alternative.entity.ts << 'EOF'
import { ApiProperty } from '@nestjs/swagger';

export class Alternative {
  @ApiProperty()
  id: string;

  @ApiProperty()
  title: string;

  @ApiProperty()
  replaces: string;

  @ApiProperty()
  description: string;

  @ApiProperty()
  reasons: string;

  @ApiProperty()
  benefits: string;

  @ApiProperty({ required: false })
  website: string | null;

  @ApiProperty()
  category: string;

  @ApiProperty()
  upvotes: number;

  @ApiProperty()
  approved: boolean;

  @ApiProperty()
  submitterId: string;

  @ApiProperty()
  createdAt: Date;

  @ApiProperty()
  updatedAt: Date;
}
EOF

# Service für Alternativen erstellen
cat > src/alternatives/alternatives.service.ts << 'EOF'
import { Injectable, NotFoundException, ForbiddenException } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';
import { CreateAlternativeDto } from './dto/create-alternative.dto';
import { UpdateAlternativeDto } from './dto/update-alternative.dto';

@Injectable()
export class AlternativesService {
  constructor(private prisma: PrismaService) {}

  async create(createAlternativeDto: CreateAlternativeDto, userId: string) {
    return this.prisma.alternative.create({
      data: {
        ...createAlternativeDto,
        submitter: {
          connect: { id: userId },
        },
      },
    });
  }

  async findAll(onlyApproved = true, category?: string) {
    const where: any = {};
    
    if (onlyApproved) {
      where.approved = true;
    }
    
    if (category) {
      where.category = category;
    }

    return this.prisma.alternative.findMany({
      where,
      orderBy: {
        upvotes: 'desc',
      },
      include: {
        submitter: {
          select: {
            id: true,
            username: true,
          },
        },
      },
    });
  }

  async getPendingAlternatives() {
    return this.prisma.alternative.findMany({
      where: {
        approved: false,
      },
      orderBy: {
        createdAt: 'desc',
      },
      include: {
        submitter: {
          select: {
            id: true,
            username: true,
          },
        },
      },
    });
  }

  async findOne(id: string) {
    const alternative = await this.prisma.alternative.findUnique({
      where: { id },
      include: {
        submitter: {
          select: {
            id: true,
            username: true,
          },
        },
        comments: {
          include: {
            user: {
              select: {
                id: true,
                username: true,
              },
            },
          },
          orderBy: {
            createdAt: 'desc',
          },
        },
      },
    });

    if (!alternative) {
      throw new NotFoundException(`Alternative mit ID ${id} nicht gefunden`);
    }

    return alternative;
  }

  async update(id: string, updateAlternativeDto: UpdateAlternativeDto, userId: string, isAdmin = false) {
    // Prüfen, ob Alternative existiert
    const alternative = await this.prisma.alternative.findUnique({
      where: { id },
      select: { submitterId: true },
    });

    if (!alternative) {
      throw new NotFoundException(`Alternative mit ID ${id} nicht gefunden`);
    }

    // Prüfen, ob Benutzer berechtigt ist
    if (!isAdmin && alternative.submitterId !== userId) {
      throw new ForbiddenException('Sie sind nicht berechtigt, diese Alternative zu bearbeiten');
    }

    return this.prisma.alternative.update({
      where: { id },
      data: updateAlternativeDto,
    });
  }

  async remove(id: string, userId: string, isAdmin = false) {
    // Prüfen, ob Alternative existiert
    const alternative = await this.prisma.alternative.findUnique({
      where: { id },
      select: { submitterId: true },
    });

    if (!alternative) {
      throw new NotFoundException(`Alternative mit ID ${id} nicht gefunden`);
    }

    // Prüfen, ob Benutzer berechtigt ist
    if (!isAdmin && alternative.submitterId !== userId) {
      throw new ForbiddenException('Sie sind nicht berechtigt, diese Alternative zu löschen');
    }

    await this.prisma.comment.deleteMany({
      where: { alternativeId: id },
    });

    await this.prisma.vote.deleteMany({
      where: { alternativeId: id },
    });

    return this.prisma.alternative.delete({
      where: { id },
    });
  }

  async approveAlternative(id: string) {
    const alternative = await this.prisma.alternative.findUnique({
      where: { id },
    });

    if (!alternative) {
      throw new NotFoundException(`Alternative mit ID ${id} nicht gefunden`);
    }

    return this.prisma.alternative.update({
      where: { id },
      data: { approved: true },
    });
  }

  async vote(alternativeId: string, userId: string, voteType: 'upvote' | 'downvote') {
    const alternative = await this.prisma.alternative.findUnique({
      where: { id: alternativeId },
    });

    if (!alternative) {
      throw new NotFoundException(`Alternative mit ID ${alternativeId} nicht gefunden`);
    }

    // Prüfen, ob Benutzer bereits abgestimmt hat
    const existingVote = await this.prisma.vote.findUnique({
      where: {
        userId_alternativeId: {
          userId,
          alternativeId,
        },
      },
    });

    if (existingVote) {
      // Wenn gleicher Vote-Typ, dann Vote entfernen
      if (existingVote.type === voteType) {
        await this.prisma.vote.delete({
          where: {
            userId_alternativeId: {
              userId,
              alternativeId,
            },
          },
        });

        // Upvotes aktualisieren
        const voteCount = await this.countUpvotes(alternativeId);
        
        return this.prisma.alternative.update({
          where: { id: alternativeId },
          data: { upvotes: voteCount },
        });
      } else {
        // Vote-Typ ändern
        await this.prisma.vote.update({
          where: {
            userId_alternativeId: {
              userId,
              alternativeId,
            },
          },
          data: { type: voteType },
        });
      }
    } else {
      // Neuen Vote erstellen
      await this.prisma.vote.create({
        data: {
          type: voteType,
          user: {
            connect: { id: userId },
          },
          alternative: {
            connect: { id: alternativeId },
          },
        },
      });
    }

    // Upvotes aktualisieren
    const voteCount = await this.countUpvotes(alternativeId);
    
    return this.prisma.alternative.update({
      where: { id: alternativeId },
      data: { upvotes: voteCount },
    });
  }

  private async countUpvotes(alternativeId: string): Promise<number> {
    const upvotes = await this.prisma.vote.count({
      where: {
        alternativeId,
        type: 'upvote',
      },
    });

    const downvotes = await this.prisma.vote.count({
      where: {
        alternativeId,
        type: 'downvote',
      },
    });

    return upvotes - downvotes;
  }
}
EOF

# Controller für Alternativen erstellen
cat > src/alternatives/alternatives.controller.ts << 'EOF'
import {
  Controller,
  Get,
  Post,
  Body,
  Patch,
  Param,
  Delete,
  Request,
  Query,
  UseGuards,
} from '@nestjs/common';
import { ApiTags, ApiOperation, ApiResponse, ApiBearerAuth, ApiQuery } from '@nestjs/swagger';
import { AlternativesService } from './alternatives.service';
import { CreateAlternativeDto } from './dto/create-alternative.dto';
import { UpdateAlternativeDto } from './dto/update-alternative.dto';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { AdminGuard } from '../auth/guards/admin.guard';
import { Public } from '../auth/decorators/public.decorator';
import { PrismaService } from '../prisma/prisma.service';

@ApiTags('alternatives')
@Controller('alternatives')
export class AlternativesController {
  constructor(
    private readonly alternativesService: AlternativesService,
    private readonly prisma: PrismaService,
  ) {}

  @Post()
  @ApiBearerAuth()
  @ApiOperation({ summary: 'Neue Alternative erstellen' })
  @ApiResponse({ status: 201, description: 'Alternative erfolgreich erstellt' })
  async create(
    @Body() createAlternativeDto: CreateAlternativeDto,
    @Request() req,
  ) {
    return this.alternativesService.create(
      createAlternativeDto,
      req.user.userId,
    );
  }

  @Public()
  @Get()
  @ApiOperation({ summary: 'Alle genehmigten Alternativen abrufen' })
  @ApiQuery({ name: 'category', required: false })
  @ApiResponse({ status: 200, description: 'Alternativen erfolgreich abgerufen' })
  async findAll(@Query('category') category?: string) {
    return this.alternativesService.findAll(true, category);
  }

  @Get('pending')
  @UseGuards(AdminGuard)
  @ApiBearerAuth()
  @ApiOperation({ summary: 'Alle ausstehenden Alternativen abrufen (nur Admin)' })
  @ApiResponse({ status: 200, description: 'Ausstehende Alternativen erfolgreich abgerufen' })
  async getPendingAlternatives() {
    return this.alternativesService.getPendingAlternatives();
  }

  @Public()
  @Get(':id')
  @ApiOperation({ summary: 'Alternative mit ID abrufen' })
  @ApiResponse({ status: 200, description: 'Alternative erfolgreich abgerufen' })
  @ApiResponse({ status: 404, description: 'Alternative nicht gefunden' })
  async findOne(@Param('id') id: string) {
    return this.alternativesService.findOne(id);
  }

  @Patch(':id')
  @ApiBearerAuth()
  @ApiOperation({ summary: 'Alternative aktualisieren' })
  @ApiResponse({ status: 200, description: 'Alternative erfolgreich aktualisiert' })
  @ApiResponse({ status: 403, description: 'Nicht berechtigt' })
  @ApiResponse({ status: 404, description: 'Alternative nicht gefunden' })
  async update(
    @Param('id') id: string,
    @Body() updateAlternativeDto: UpdateAlternativeDto,
    @Request() req,
  ) {
    // Prüfen, ob Benutzer Admin ist
    const user = await this.prisma.user.findUnique({
      where: { id: req.user.userId },
      select: { isAdmin: true },
    });

    return this.alternativesService.update(
      id,
      updateAlternativeDto,
      req.user.userId,
      user?.isAdmin || false,
    );
  }

  @Delete(':id')
  @ApiBearerAuth()
  @ApiOperation({ summary: 'Alternative löschen' })
  @ApiResponse({ status: 200, description: 'Alternative erfolgreich gelöscht' })
  @ApiResponse({ status: 403, description: 'Nicht berechtigt' })
  @ApiResponse({ status: 404, description: 'Alternative nicht gefunden' })
  async remove(@Param('id') id: string, @Request() req) {
    // Prüfen, ob Benutzer Admin ist
    const user = await this.prisma.user.findUnique({
      where: { id: req.user.userId },
      select: { isAdmin: true },
    });

    return this.alternativesService.remove(
      id,
      req.user.userId,
      user?.isAdmin || false,
    );
  }

  @Post(':id/approve')
  @UseGuards(AdminGuard)
  @ApiBearerAuth()
  @ApiOperation({ summary: 'Alternative genehmigen (nur Admin)' })
  @ApiResponse({ status: 200, description: 'Alternative erfolgreich genehmigt' })
  @ApiResponse({ status: 404, description: 'Alternative nicht gefunden' })
  async approveAlternative(@Param('id') id: string) {
    return this.alternativesService.approveAlternative(id);
  }

  @Post(':id/vote')
  @ApiBearerAuth()
  @ApiOperation({ summary: 'Für Alternative abstimmen' })
  @ApiQuery({ name: 'type', enum: ['upvote', 'downvote'] })
  @ApiResponse({ status: 200, description: 'Abstimmung erfolgreich' })
  @ApiResponse({ status: 404, description: 'Alternative nicht gefunden' })
  async vote(
    @Param('id') id: string,
    @Query('type') type: 'upvote' | 'downvote',
    @Request() req,
  ) {
    return this.alternativesService.vote(id, req.user.userId, type);
  }
}
EOF

# Alternativen-Modul erstellen
cat > src/alternatives/alternatives.module.ts << 'EOF'
import { Module } from '@nestjs/common';
import { AlternativesService } from './alternatives.service';
import { AlternativesController } from './alternatives.controller';

@Module({
  controllers: [AlternativesController],
  providers: [AlternativesService],
  exports: [AlternativesService],
})
export class AlternativesModule {}
EOF

echo "✅ Alternativen-Modul im Backend erfolgreich implementiert!"