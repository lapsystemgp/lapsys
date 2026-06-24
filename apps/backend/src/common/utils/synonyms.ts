/**
 * Medical test synonym groups for the Egyptian lab-testing market.
 * Each inner array is one equivalence group — any member maps to all others.
 * All strings must be lowercase.
 */
const SYNONYM_GROUPS: string[][] = [
  // ── Complete Blood Count ───────────────────────────────────────────────
  ['cbc', 'complete blood count', 'full blood count', 'blood count',
   'فحص دم كامل', 'صورة دم كاملة', 'تعداد دم'],

  // ── Liver Function ────────────────────────────────────────────────────
  ['lft', 'liver function test', 'liver function tests', 'liver function',
   'liver panel', 'hepatic function', 'وظائف الكبد', 'تحليل الكبد'],

  // ── Kidney / Renal Function ───────────────────────────────────────────
  ['kft', 'rft', 'kidney function test', 'kidney function tests',
   'renal function test', 'renal function', 'kidney panel',
   'وظائف الكلى', 'تحليل الكلى'],

  // ── Thyroid Function ──────────────────────────────────────────────────
  ['tft', 'thyroid function test', 'thyroid function tests', 'thyroid panel',
   'thyroid function', 'وظائف الغدة الدرقية', 'تحليل الغدة الدرقية'],

  // ── TSH ───────────────────────────────────────────────────────────────
  ['tsh', 'thyroid stimulating hormone', 'thyrotropin',
   'هرمون تحفيز الغدة الدرقية'],

  // ── HbA1c ─────────────────────────────────────────────────────────────
  ['hba1c', 'hb a1c', 'a1c', 'glycated hemoglobin', 'glycosylated hemoglobin',
   'hemoglobin a1c', 'السكر التراكمي', 'سكر تراكمي'],

  // ── Fasting Blood Sugar ───────────────────────────────────────────────
  ['fbs', 'fbg', 'fasting blood sugar', 'fasting blood glucose',
   'fasting glucose', 'سكر صائم', 'جلوكوز صائم'],

  // ── Random Blood Sugar ────────────────────────────────────────────────
  ['rbs', 'rbg', 'random blood sugar', 'random blood glucose',
   'سكر عشوائي', 'جلوكوز عشوائي'],

  // ── General glucose / sugar ───────────────────────────────────────────
  ['blood sugar', 'blood glucose', 'glucose', 'سكر', 'جلوكوز'],

  // ── Lipid Profile ─────────────────────────────────────────────────────
  ['lipid profile', 'lipid panel', 'cholesterol panel',
   'فحص الدهون', 'دهون الدم', 'كوليسترول شامل', 'ليبيد بروفايل'],

  // ── Uric Acid ─────────────────────────────────────────────────────────
  ['uric acid', 'urate', 'حمض اليوريك', 'يوريك'],

  // ── Creatinine ───────────────────────────────────────────────────────
  ['creatinine', 'creat', 'كرياتينين'],

  // ── Urea / BUN ────────────────────────────────────────────────────────
  ['bun', 'blood urea nitrogen', 'urea', 'يوريا'],

  // ── ESR ───────────────────────────────────────────────────────────────
  ['esr', 'erythrocyte sedimentation rate', 'sed rate', 'sedimentation rate',
   'سرعة الترسب'],

  // ── CRP ───────────────────────────────────────────────────────────────
  ['crp', 'c-reactive protein', 'c reactive protein', 'بروتين سي التفاعلي'],

  // ── Iron / Ferritin ───────────────────────────────────────────────────
  ['iron', 'serum iron', 'ferritin', 'حديد', 'فيريتين'],

  // ── TIBC ──────────────────────────────────────────────────────────────
  ['tibc', 'total iron binding capacity', 'iron binding capacity'],

  // ── Vitamin D ─────────────────────────────────────────────────────────
  ['vitamin d', 'vit d', 'vitd', '25-oh vitamin d', '25 oh vitamin d',
   'cholecalciferol', 'فيتامين د', 'فيتامين d'],

  // ── Vitamin B12 ───────────────────────────────────────────────────────
  ['vitamin b12', 'vit b12', 'b12', 'cobalamin', 'cyanocobalamin',
   'فيتامين ب12', 'فيتامين ب 12'],

  // ── Hepatitis B ───────────────────────────────────────────────────────
  ['hbsag', 'hbs ag', 'hepatitis b', 'hepatitis b surface antigen',
   'التهاب الكبد بي', 'التهاب الكبد ب'],

  // ── Hepatitis C ───────────────────────────────────────────────────────
  ['hcv', 'hepatitis c', 'hepatitis c virus', 'anti hcv',
   'التهاب الكبد سي', 'التهاب الكبد ج'],

  // ── HIV ───────────────────────────────────────────────────────────────
  ['hiv', 'aids test', 'human immunodeficiency virus', 'فيروس نقص المناعة'],

  // ── PSA ───────────────────────────────────────────────────────────────
  ['psa', 'prostate specific antigen', 'prostate antigen',
   'أنتيجين البروستاتا'],

  // ── Prothrombin Time / Coagulation ────────────────────────────────────
  ['pt', 'prothrombin time', 'inr', 'وقت البروثرومبين'],
  ['ptt', 'aptt', 'partial thromboplastin time'],

  // ── Liver Enzymes ─────────────────────────────────────────────────────
  ['alt', 'sgpt', 'alanine aminotransferase', 'alanine transaminase',
   'إنزيمات الكبد', 'انزيمات الكبد'],
  ['ast', 'sgot', 'aspartate aminotransferase', 'aspartate transaminase'],
  ['alp', 'alkaline phosphatase', 'فوسفاتاز قلوية'],
  ['ggt', 'gamma gt', 'gamma-glutamyl transferase', 'gamma glutamyl'],

  // ── Bilirubin ─────────────────────────────────────────────────────────
  ['bilirubin', 'total bilirubin', 'direct bilirubin', 'بيليروبين'],

  // ── Rheumatoid Factor ─────────────────────────────────────────────────
  ['rf', 'rheumatoid factor', 'عامل الروماتويد', 'روماتويد'],

  // ── ANA ───────────────────────────────────────────────────────────────
  ['ana', 'antinuclear antibody', 'antinuclear antibodies'],

  // ── Urine Analysis ────────────────────────────────────────────────────
  ['urine analysis', 'ua', 'urinalysis', 'complete urine analysis', 'cua',
   'تحليل بول', 'تحليل البول'],

  // ── Stool Analysis ────────────────────────────────────────────────────
  ['stool analysis', 'fecal analysis', 'تحليل براز', 'تحليل البراز'],

  // ── Blood Group ───────────────────────────────────────────────────────
  ['blood group', 'blood type', 'abo', 'blood grouping', 'فصيلة الدم'],

  // ── Cultures ──────────────────────────────────────────────────────────
  ['blood culture', 'مزرعة دم'],
  ['urine culture', 'مزرعة بول'],

  // ── Electrolytes ──────────────────────────────────────────────────────
  ['electrolytes', 'sodium', 'potassium', 'na k', 'شوارد', 'كهارل',
   'صوديوم', 'بوتاسيوم'],

  // ── Calcium / Magnesium ───────────────────────────────────────────────
  ['calcium', 'serum calcium', 'كالسيوم'],
  ['magnesium', 'serum magnesium', 'مغنيسيوم'],

  // ── Albumin ───────────────────────────────────────────────────────────
  ['albumin', 'serum albumin', 'ألبومين'],

  // ── Hemoglobin ────────────────────────────────────────────────────────
  ['hemoglobin', 'haemoglobin', 'hb', 'hgb', 'هيموجلوبين'],

  // ── Tumor markers ─────────────────────────────────────────────────────
  ['afp', 'alpha fetoprotein', 'alpha-fetoprotein', 'ألفا فيتو بروتين'],
  ['cea', 'carcinoembryonic antigen'],
  ['ca125', 'ca 125', 'cancer antigen 125'],
  ['ca199', 'ca 19-9', 'ca 19 9'],

  // ── TORCH ─────────────────────────────────────────────────────────────
  ['torch', 'toxoplasma rubella cmv herpes', 'prenatal screening'],

  // ── Reproductive hormones ─────────────────────────────────────────────
  ['fsh', 'follicle stimulating hormone', 'هرمون تحفيز الجريب'],
  ['lh', 'luteinizing hormone', 'هرمون ملوتن'],
  ['prolactin', 'prl', 'برولاكتين'],
  ['testosterone', 'total testosterone', 'تستوستيرون'],
  ['hcg', 'beta hcg', 'beta-hcg', 'human chorionic gonadotropin',
   'pregnancy test', 'تحليل حمل', 'اختبار حمل'],

  // ── Other common tests ────────────────────────────────────────────────
  ['insulin', 'fasting insulin', 'أنسولين'],
  ['cortisol', 'serum cortisol', 'كورتيزول'],
  ['d-dimer', 'd dimer', 'ddimer'],
  ['semen analysis', 'sperm analysis',
   'تحليل حيوانات منوية', 'تحليل السائل المنوي'],
];

// Build a flat lookup: lowercase term → full synonym group
const SYNONYM_MAP = new Map<string, string[]>();
for (const group of SYNONYM_GROUPS) {
  for (const term of group) {
    SYNONYM_MAP.set(term.toLowerCase(), group);
  }
}

/**
 * Expand each token to its synonym group (all equivalent terms).
 * Returns string[][] — outer array is AND (all must match),
 * inner array is OR (any synonym is accepted).
 *
 * Example: expandTokens(['cbc']) → [['cbc', 'complete blood count', 'صورة دم كاملة', ...]]
 */
export function expandTokens(tokens: string[]): string[][] {
  return tokens.map((token) => {
    const group = SYNONYM_MAP.get(token.toLowerCase());
    return group ?? [token];
  });
}
