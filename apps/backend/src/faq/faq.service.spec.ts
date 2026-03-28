import { FaqService } from './faq.service';

describe('FaqService', () => {
  const prismaMock = {
    faqEntry: {
      count: jest.fn(),
      findMany: jest.fn(),
    },
  } as any;

  let service: FaqService;

  beforeEach(() => {
    jest.clearAllMocks();
    service = new FaqService(prismaMock);
  });

  it('returns guided intents', async () => {
    const result = await service.listIntents();
    expect(result.items.length).toBeGreaterThan(0);
  });

  it('searches faq entries with pagination', async () => {
    prismaMock.faqEntry.count.mockResolvedValue(1);
    prismaMock.faqEntry.findMany.mockResolvedValue([
      {
        id: 'faq-1',
        question: 'Do I need to fast?',
        answer: 'Yes for some tests.',
        category: 'Preparation',
        tags: ['fasting'],
      },
    ]);

    const result = await service.search({ q: 'fasting', page: 1, pageSize: 8 });

    expect(result.pagination.totalCount).toBe(1);
    expect(result.items[0].id).toBe('faq-1');
  });

  it('returns escalation text when no faq match', async () => {
    prismaMock.faqEntry.count.mockResolvedValue(0);
    prismaMock.faqEntry.findMany.mockResolvedValue([]);

    const result = await service.ask({ question: 'unknown question' });

    expect(result.answer).toContain('could not find');
  });
});