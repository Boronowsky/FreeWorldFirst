import { Module } from '@nestjs/common';
import { AlternativesService } from './alternatives.service';
import { AlternativesController } from './alternatives.controller';

@Module({
  controllers: [AlternativesController],
  providers: [AlternativesService],
  exports: [AlternativesService],
})
export class AlternativesModule {}
