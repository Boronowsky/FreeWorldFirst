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
