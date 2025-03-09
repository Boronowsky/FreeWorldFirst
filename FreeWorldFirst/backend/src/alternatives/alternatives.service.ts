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
