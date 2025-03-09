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
