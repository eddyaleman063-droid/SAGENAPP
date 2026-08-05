const fs = require('fs');
const path = require('path');

const filePath = process.argv[2] || path.join(__dirname, '..', 'assets', 'content', 'questions_ac_st1.json');
const questions = JSON.parse(fs.readFileSync(filePath, 'utf8'));

console.log(`Original count: ${questions.length}`);

// Filter 1: Remove questions where question text appears as an option
let filtered = questions.filter(q => {
  if (!q.question || !q.options) return false;
  const qText = q.question.toLowerCase().trim();
  return !q.options.some(o => o.toLowerCase().trim() === qText);
});
console.log(`After removing self-referential options: ${filtered.length}`);

// Filter 2: Remove questions with template/placeholder text
const badPatterns = [
  /respuesta correcta sobre/i,
  /solución basada en/i,
  /solución incorrecta pero comun/i,
  /aplicar lo aprendido en/i,
  /ignorar la situaci[oó]n/i,
  /preguntar en redes sociales/i,
  /esperar a que se resuelva solo/i,
  /identificar riesgos es parte de/i,
  /refuerza el concepto de/i,
  /no hay suficiente información/i,
  /solo para expertos/i,
  /solo en algunos pa[ií]ses/i,
  /actividad cotidiana normal/i,
  /pr[aá]ctica neutral sin riesgo/i,
  /opción segura y recomendada/i,
  /que es la seguridad digital/i,
  /una pregunta sobre/i,
  /ejemplo de cuenta digital cotidiana/i,
  /práctica: crea tu primera/i,
  /simulacro: detecta/i,
  /evaluación: identifica/i,
];

const beforeBadPattern = filtered.length;
filtered = filtered.filter(q => {
  const text = (q.question || '') + ' ' + (q.explanation || '');
  return !badPatterns.some(p => p.test(text));
});
console.log(`After removing template questions: ${filtered.length} (removed ${beforeBadPattern - filtered.length})`);

// Filter 3: Remove questions with < 2 non-empty distinct options
filtered = filtered.filter(q => {
  const opts = (q.options || []).filter(o => o && o.trim().length > 0);
  const unique = new Set(opts.map(o => o.trim().toLowerCase()));
  return opts.length >= 2 && unique.size >= 2;
});
console.log(`After removing insufficient distinct options: ${filtered.length}`);

// Filter 4: Remove trueFalse questions with wrong correctIndex
// "Por que es importante proteger tus cuentas" → correctIndex should be 0 (Verdadero)
filtered = filtered.filter(q => {
  if (q.type === 'trueFalse') {
    if (!Array.isArray(q.options) || q.options.length !== 2) return false;
    const opts = q.options.map(o => o.trim().toLowerCase());
    if (!opts.includes('verdadero') || !opts.includes('falso')) return false;
    
    // Questions asking "why is X important" or "is X good" → answer is Verdadero (0)
    const positivePatterns = [
      /por qu[eé] es importante/i,
      /es importante/i,
      /es seguro/i,
      /es recomendable/i,
      /es bueno/i,
      /debes/i,
      /es necesario/i,
      /deber[ií]as/i,
      /puedes/i,
      /es v[aá]lido/i,
      /protege/i,
      /ayuda/i,
      /previene/i,
      /funciona/i,
      /es correcto/i,
    ];
    const isPositive = positivePatterns.some(p => p.test(q.question));
    
    if (isPositive && q.correctIndex !== 0) {
      console.log(`  Fixed trueFalse: "${q.question}" correctIndex ${q.correctIndex} → 0`);
      q.correctIndex = 0;
    }
    
    // Questions with "no" or negative → answer might be Falso (1)
    const negativePatterns = [
      /no es/i,
      /nunca/i,
      /no debes/i,
      /no应该/i,
    ];
    // Don't auto-fix negative ones - too risky
  }
  return true;
});

// Filter 5: Fix missing accents in common words
const accentMap = {
  'phone': 'teléfono',
  'telefono': 'teléfono',
  'contrasena': 'contraseña',
  'informacion': 'información',
  'aplicacion': 'aplicación',
  'proteccion': 'protección',
  'verificacion': 'verificación',
  'autenticacion': 'autenticación',
  'privacidad': 'privacidad',
  'busquedas': 'búsquedas',
  'busqueda': 'búsqueda',
  'basica': 'básica',
  'basico': 'básico',
  'seguras': 'seguras',
  'seguro': 'seguro',
  'phishing': 'phishing',
  'ciberseguridad': 'ciberseguridad',
  'passphrase': 'passphrase',
  'wifi': 'Wi-Fi',
  'Wi fi': 'Wi-Fi',
  'vpn': 'VPN',
  'Vpn': 'VPN',
  'online': 'en línea',
  'Offline': 'Sin conexión',
  'offline': 'sin conexión',
  'email': 'correo electrónico',
  'e-mail': 'correo electrónico',
  'link': 'enlace',
  'links': 'enlaces',
  'login': 'inicio de sesión',
  'logout': 'cerrar sesión',
  'browser': 'navegador',
  'hacker': 'hacker',
  'malware': 'malware',
  'virus': 'virus',
  'spam': 'spam',
  'hack': 'hackeo',
  'hacking': 'hackeo',
  'password': 'contraseña',
  'account': 'cuenta',
  'accounts': 'cuentas',
  'data': 'datos',
  'device': 'dispositivo',
  'devices': 'dispositivos',
  'internet': 'internet',
  'security': 'seguridad',
  'privacy': 'privacidad',
  'file': 'archivo',
  'files': 'archivos',
  'screen': 'pantalla',
  'code': 'código',
  'number': 'número',
  'key': 'clave',
  'message': 'mensaje',
  'messages': 'mensajes',
  'search': 'búsqueda',
  'page': 'página',
  'site': 'sitio',
  'web': 'web',
  'update': 'actualización',
  'setting': 'configuración',
  'option': 'opción',
  'information': 'información',
  'personal': 'personal',
  'private': 'privado',
  'public': 'público',
  'strong': 'fuerte',
  'weak': 'débil',
  'safe': 'seguro',
  'risk': 'riesgo',
  'attack': 'ataque',
  'protect': 'proteger',
  'level': 'nivel',
  'step': 'paso',
  'factor': 'factor',
  'practice': 'práctica',
  'example': 'ejemplo',
  'case': 'caso',
  'correct': 'correcto',
  'incorrect': 'incorrecto',
};

// Apply accent fixes to question text and options
filtered = filtered.map(q => {
  let question = q.question || '';
  let explanation = q.explanation || '';
  let options = [...(q.options || [])];
  
  // Add opening ¿ to questions starting with Que/Cual/Como/Por que/etc
  if (/^Que\s/.test(question)) question = '¿' + question;
  if (/^Cual\s/.test(question)) question = '¿' + question;
  if (/^Como\s/.test(question)) question = '¿' + question;
  if (/^Por que\s/.test(question)) question = '¿' + question;
  if (/^Cuando\s/.test(question)) question = '¿' + question;
  if (/^Donde\s/.test(question)) question = '¿' + question;
  if (/^Cuanto\s/.test(question)) question = '¿' + question;
  
  // Fix common missing accents in question text
  for (const [wrong, right] of Object.entries(accentMap)) {
    const regex = new RegExp(`\\b${wrong}\\b`, 'gi');
    question = question.replace(regex, right);
    explanation = explanation.replace(regex, right);
    options = options.map(o => o.replace(regex, right));
  }
  
  return { ...q, question, explanation, options };
});

// Filter 6: Remove exact duplicates within same lesson
const seen = new Set();
const deduped = filtered.filter(q => {
  const key = `${q.lessonId}::${q.question.trim().toLowerCase()}`;
  if (seen.has(key)) return false;
  seen.add(key);
  return true;
});
console.log(`After deduplication: ${deduped.length} (removed ${filtered.length - deduped.length} duplicates)`);

// Filter 7: Remove questions with circular options (option matches question exactly)
const circularFree = deduped.filter(q => {
  const qLower = q.question.toLowerCase().trim();
  return !(q.options || []).some(o => o.toLowerCase().trim() === qLower);
});
console.log(`After removing circular options: ${circularFree.length}`);

// Stats by lesson
const lessonCounts = {};
circularFree.forEach(q => {
  lessonCounts[q.lessonId] = (lessonCounts[q.lessonId] || 0) + 1;
});

console.log('\nQuestions per lesson:');
Object.entries(lessonCounts).sort().forEach(([k, v]) => {
  console.log(`  ${k}: ${v}`);
});

console.log(`\nFinal count: ${circularFree.length}`);
console.log(`Removed: ${questions.length - circularFree.length} bad questions (${((questions.length - circularFree.length) / questions.length * 100).toFixed(1)}%)`);

// Write output
fs.writeFileSync(filePath, JSON.stringify(circularFree, null, 2));
console.log(`\nWritten to ${filePath}`);
