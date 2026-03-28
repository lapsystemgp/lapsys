import { Body, Controller, Get, Post, Query } from '@nestjs/common';
import { ApiOperation, ApiTags } from '@nestjs/swagger';
import { FaqSearchQueryDto } from './dto/faq-search-query.dto';
import { FaqAskDto } from './dto/faq-ask.dto';
import { FaqService } from './faq.service';

@ApiTags('faq')
@Controller('faq')
export class FaqController {
  constructor(private readonly faqService: FaqService) {}

  @Get('intents')
  @ApiOperation({ summary: 'List guided FAQ intents for chatbot quick actions' })
  listIntents() {
    return this.faqService.listIntents();
  }

  @Get('search')
  @ApiOperation({ summary: 'Search curated FAQ entries' })
  search(@Query() query: FaqSearchQueryDto) {
    return this.faqService.search(query);
  }

  @Post('ask')
  @ApiOperation({ summary: 'Guided FAQ answer endpoint (non-LLM)' })
  ask(@Body() dto: FaqAskDto) {
    return this.faqService.ask(dto);
  }
}
