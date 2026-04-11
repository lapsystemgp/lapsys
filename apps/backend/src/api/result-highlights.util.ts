export type ResultHighlightItem = {
  /** Stable slug for analytics/UI keys */
  key: string;
  label: string;
  value: string;
  kind: 'key_value' | 'text' | 'structured';
};

export type NormalizedResultHighlights = {
  items: ResultHighlightItem[];
};

function slugify(label: string): string {
  return label
    .toLowerCase()
    .normalize('NFD')
    .replace(/[\u0300-\u036f]/g, '')
    .replace(/[^a-z0-9]+/g, '-')
    .replace(/^-|-$/g, '')
    .slice(0, 64);
}

/**
 * Turns arbitrary JSON highlights from labs into a stable list for patient UI.
 * Supports: legacy object map, array of strings, array of { label, value }, single string.
 */
export function normalizeResultHighlights(raw: unknown): NormalizedResultHighlights {
  if (raw === null || raw === undefined) {
    return { items: [] };
  }

  if (typeof raw === 'string') {
    const t = raw.trim();
    return t ? { items: [{ key: 'note', label: 'Note', value: t, kind: 'text' }] } : { items: [] };
  }

  if (Array.isArray(raw)) {
    const items: ResultHighlightItem[] = [];
    raw.forEach((entry, index) => {
      if (typeof entry === 'string') {
        const t = entry.trim();
        if (t) items.push({ key: `item-${index}`, label: `Item ${index + 1}`, value: t, kind: 'text' });
        return;
      }
      if (entry && typeof entry === 'object' && !Array.isArray(entry)) {
        const o = entry as Record<string, unknown>;
        const label = typeof o.label === 'string' ? o.label : typeof o.name === 'string' ? o.name : `Item ${index + 1}`;
        const value =
          typeof o.value === 'string'
            ? o.value
            : typeof o.text === 'string'
              ? o.text
              : o.value !== undefined && o.value !== null
                ? String(o.value)
                : '';
        if (value.trim()) {
          items.push({
            key: slugify(label) || `item-${index}`,
            label: label.trim(),
            value: value.trim(),
            kind: 'structured',
          });
        }
      }
    });
    return { items };
  }

  if (typeof raw === 'object') {
    const items: ResultHighlightItem[] = [];
    for (const [k, v] of Object.entries(raw as Record<string, unknown>)) {
      if (v === null || v === undefined) continue;
      const value = typeof v === 'string' ? v : typeof v === 'number' || typeof v === 'boolean' ? String(v) : JSON.stringify(v);
      items.push({
        key: slugify(k) || 'item',
        label: k.replace(/_/g, ' ').trim(),
        value: value.trim(),
        kind: 'key_value',
      });
    }
    return { items };
  }

  return { items: [] };
}
