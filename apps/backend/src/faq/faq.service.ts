import { Injectable } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';
import { FaqSearchQueryDto } from './dto/faq-search-query.dto';
import { FaqAskDto } from './dto/faq-ask.dto';
import { fuzzySearchFaq } from '../common/utils/search.utils';

const GUIDED_INTENTS = [
  {
    id: 'prep-fasting',
    label: 'Preparation & fasting',
    query: 'fasting preparation',
  },
  {
    id: 'pricing-help',
    label: 'Pricing and cost',
    query: 'price cost',
  },
  {
    id: 'booking-help',
    label: 'Booking help',
    query: 'book appointment home collection',
  },
  {
    id: 'result-timing',
    label: 'Result turnaround',
    query: 'results turnaround time',
  },
];

@Injectable()
export class FaqService {
  constructor(private readonly prisma: PrismaService) {}

  async listIntents() {
    return { items: GUIDED_INTENTS };
  }

  async search(query: FaqSearchQueryDto) {
    const q = query.q?.trim() ?? '';
    const category = query.category?.trim() ?? '';
    const page = query.page ?? 1;
    const pageSize = query.pageSize ?? 8;

    const { items, totalCount } = await fuzzySearchFaq(
      this.prisma,
      q,
      category,
      page,
      pageSize,
    );

    return { items, pagination: { page, pageSize, totalCount } };
  }

  async ask(dto: FaqAskDto) {
    const searchResult = await this.search({ q: dto.question, page: 1, pageSize: 3 });
    const top = searchResult.items[0] ?? null;

    if (!top) {
      return {
        answer:
          'I could not find a direct FAQ answer. Please contact support at support@testly.local or ask a lab representative.',
        matched: [],
      };
    }

    return {
      answer: top.answer,
      matched: searchResult.items,
      escalation:
        'Need more help? Contact support at support@testly.local or call your selected lab.',
    };
  }
}
