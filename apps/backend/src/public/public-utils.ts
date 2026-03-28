export function clampInt(value: unknown, opts: { min: number; max: number; defaultValue: number }) {
  const parsed = typeof value === 'string' ? Number.parseInt(value, 10) : Number.NaN;
  if (!Number.isFinite(parsed)) return opts.defaultValue;
  return Math.min(opts.max, Math.max(opts.min, parsed));
}

export function clampFloat(value: unknown, opts: { min: number; max: number; defaultValue: number }) {
  const parsed = typeof value === 'string' ? Number.parseFloat(value) : Number.NaN;
  if (!Number.isFinite(parsed)) return opts.defaultValue;
  return Math.min(opts.max, Math.max(opts.min, parsed));
}

export function parseBoolean(value: unknown): boolean | undefined {
  if (value === undefined) return undefined;
  if (typeof value !== 'string') return undefined;
  if (value === 'true') return true;
  if (value === 'false') return false;
  return undefined;
}

export function parseCsv(value: unknown): string[] {
  if (typeof value !== 'string') return [];
  return value
    .split(',')
    .map((part) => part.trim())
    .filter((part) => part.length > 0);
}

function hashStringToUint32(input: string) {
  // djb2-ish, stable, fast, non-crypto
  let hash = 5381;
  for (let index = 0; index < input.length; index += 1) {
    hash = (hash * 33) ^ input.charCodeAt(index);
  }
  return hash >>> 0;
}

export function placeholderDistanceKm(stableId: string) {
  // 0.8km .. 12.0km (1 decimal)
  const raw = hashStringToUint32(stableId) % 113; // 0..112
  const km = 0.8 + raw / 10;
  return Math.round(km * 10) / 10;
}

