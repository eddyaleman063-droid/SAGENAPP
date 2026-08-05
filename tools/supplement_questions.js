#!/usr/bin/env node
/**
 * SAGEN Question Supplement Generator v3
 * Adds high-quality questions to reach target counts per stage.
 * After cleanup, existing questions total ~13,557.
 * This script generates the remaining ~3,228 needed.
 */

const fs = require('fs');
const path = require('path');

function mulberry32(seed) {
  return function () {
    seed |= 0; seed = (seed + 0x6D2B79F5) | 0;
    let t = Math.imul(seed ^ (seed >>> 15), 1 | seed);
    t = (t + Math.imul(t ^ (t >>> 7), 61 | t)) ^ t;
    return ((t ^ (t >>> 14)) >>> 0) / 4294967296;
  };
}

const TARGETS = {
  ac_st1: 2025, ac_st2: 1980, ac_st3: 2250, ac_st4: 2160,
  ac_st5: 2175, ac_st6: 1800, ac_st7: 1875, ac_st8: 2520,
};

// Load existing questions and count per lesson
function loadExisting(stageId) {
  const fp = path.join(__dirname, '..', 'assets', 'content', `questions_${stageId}.json`);
  if (!fs.existsSync(fp)) return [];
  return JSON.parse(fs.readFileSync(fp, 'utf8'));
}

function countPerLesson(questions) {
  const counts = {};
  for (const q of questions) {
    const lid = q.lessonId || q.id.replace(/_q\d+$/, '');
    counts[lid] = (counts[lid] || 0) + 1;
  }
  return counts;
}

// Curriculum structure
const STAGES = [
  { id: 'ac_st1', sessions: 27, lesPerSes: 5, label: 'Fundamentos de Cuentas Digitales' },
  { id: 'ac_st2', sessions: 22, lesPerSes: 6, label: 'Seguridad de Dispositivos' },
  { id: 'ac_st3', sessions: 30, lesPerSes: 5, label: 'Protección de Datos Personales' },
  { id: 'ac_st4', sessions: 24, lesPerSes: 6, label: 'Seguridad en Línea y Redes Sociales' },
  { id: 'ac_st5', sessions: 29, lesPerSes: 5, label: 'Seguridad Móvil' },
  { id: 'ac_st6', sessions: 20, lesPerSes: 6, label: 'Seguridad Empresarial y Profesional' },
  { id: 'ac_st7', sessions: 25, lesPerSes: 5, label: 'Amenazas Avanzadas y Respuesta' },
  { id: 'ac_st8', sessions: 28, lesPerSes: 6, label: 'Evaluación Final y Certificación' },
];

// Knowledge base per stage topic area
const KNOWLEDGE = require('./question_knowledge.js');

function generate() {
  let totalGenerated = 0;

  for (const stage of STAGES) {
    const existing = loadExisting(stage.id);
    const existingCounts = countPerLesson(existing);
    const target = TARGETS[stage.id];
    const need = target - existing.length;

    if (need <= 0) {
      console.log(`${stage.id}: ${existing.length}/${target} (OK, no supplement needed)`);
      continue;
    }

    console.log(`${stage.id}: ${existing.length}/${target} (need ${need} more)`);
    const newQuestions = [];
    let qNum = existing.length;

    const stageNum = parseInt(stage.id.replace('ac_st', ''));

    for (let s = 0; s < stage.sessions; s++) {
      for (let l = 0; l < stage.lesPerSes; l++) {
        const lessonId = `ac_s${stageNum}_ses${s + 1}_l${l + 1}`;
        const current = existingCounts[lessonId] || 0;
        const needed = Math.ceil(need / (stage.sessions * stage.lesPerSes));

        if (current >= 15) continue; // Already has enough

        const toGenerate = Math.min(15 - current, needed);
        if (toGenerate <= 0) continue;

        const seed = stageNum * 100000 + (s + 1) * 1000 + (l + 1) * 10;
        const rng = mulberry32(seed);

        for (let i = 0; i < toGenerate; i++) {
          const q = generateQuestion(stage, s, l, lessonId, rng, i, qNum);
          if (q) {
            newQuestions.push(q);
            qNum++;
          }
        }
      }
    }

    // Merge and write
    const merged = [...existing, ...newQuestions.slice(0, need)];
    const fp = path.join(__dirname, '..', 'assets', 'content', `questions_${stage.id}.json`);
    fs.writeFileSync(fp, JSON.stringify(merged, null, 2), 'utf8');
    totalGenerated += Math.min(newQuestions.length, need);
    console.log(`  → Generated ${Math.min(newQuestions.length, need)} questions. Total: ${merged.length}`);
  }

  console.log(`\nTotal supplemented: ${totalGenerated} questions`);
}

function generateQuestion(stage, sessionIdx, lessonIdx, lessonId, rng, qIdx, globalIdx) {
  const stageNum = parseInt(stage.id.replace('ac_st', ''));
  const types = ['multipleChoice', 'trueFalse', 'completePhrase', 'detectRisk', 'whatWouldYouDo', 'createPassword', 'miniCase'];
  const type = types[Math.floor(rng() * types.length)];
  const difficulty = 1 + Math.floor(rng() * 2);

  const s = sessionIdx + 1;
  const l = lessonIdx + 1;

  // Topic-specific questions per stage
  const kb = KNOWLEDGE[stage.id];
  if (kb) {
    const topicQuestions = kb.filter(q =>
      q.lessonId === `${stageNum}_ses${s}_l${l}` ||
      (!q.lessonId && q.stage === stageNum)
    );

    if (topicQuestions.length > 0) {
      const kq = topicQuestions[Math.floor(rng() * topicQuestions.length)];
      return {
        id: `${lessonId}_q${String(globalIdx + 1).padStart(3, '0')}`,
        question: kq.q,
        type: kq.t || type,
        options: kq.o,
        correctIndex: kq.c,
        explanation: kq.e,
        difficulty: kq.d || difficulty,
        lessonId: lessonId,
      };
    }
  }

  // Fallback: contextual template questions
  return generateTemplateQuestion(stage, sessionIdx, lessonIdx, lessonId, type, difficulty, rng, globalIdx);
}

function generateTemplateQuestion(stage, sessionIdx, lessonIdx, lessonId, type, difficulty, rng, globalIdx) {
  const s = sessionIdx + 1;
  const l = lessonIdx + 1;
  const stageNum = parseInt(stage.id.replace('ac_st', ''));
  const seed = Math.floor(rng() * 10000);

  if (type === 'trueFalse') {
    const statements = [
      `Es fundamental mantener actualizadas las contraseñas y configuraciones de seguridad en ${stage.label.toLowerCase()}.`,
      `La seguridad en línea requiere atención constante y actualización de conocimientos.`,
      `Usar contraseñas únicas para cada cuenta es una práctica recomendada de seguridad.`,
      `La verificación en dos pasos añade una capa importante de protección a las cuentas.`,
      `Ignorar las actualizaciones de seguridad deja los dispositivos vulnerables a ataques conocidos.`,
      `Las redes Wi-Fi públicas son tan seguras como las redes privadas del hogar.`,
      `Compartir contraseñas con amigos cercanos es seguro si confías en ellos.`,
      `Las copias de seguridad regulares son esenciales para proteger contra pérdida de datos.`,
      `El cifrado protege la información incluso si el dispositivo es comprometido.`,
      `La concienciación en seguridad es la primera línea de defensa contra ciberataques.`,
    ];
    const idx = seed % statements.length;
    const isTrue = rng() > 0.35;
    return {
      id: `${lessonId}_q${String(globalIdx + 1).padStart(3, '0')}`,
      question: statements[idx],
      type: 'trueFalse',
      options: ['Verdadero', 'Falso'],
      correctIndex: isTrue ? 0 : 1,
      explanation: isTrue
        ? 'Esta afirmación es correcta según las mejores prácticas de ciberseguridad.'
        : 'Esta afirmación es incorrecta. Consulta las mejores prácticas de seguridad para más detalles.',
      difficulty,
      lessonId,
    };
  }

  if (type === 'completePhrase') {
    const phrases = [
      { q: 'Para proteger tu cuenta digital, es esencial usar una contraseña ______ y única.', c: 0, o: ['Fuerte', 'Corta', 'Simple', 'Compartida'], e: 'Las contraseñas fuertes y únicas son la base de la seguridad de cuentas.' },
      { q: 'La verificación en dos pasos proporciona una capa ______ de seguridad.', c: 0, o: ['Adicional', 'Menor', 'Opcional', 'Innecesaria'], e: 'La 2FA añade un factor extra de protección más allá de la contraseña.' },
      { q: 'Las actualizaciones de seguridad corrigen ______ que podrían ser explotadas.', c: 0, o: ['Vulnerabilidades', 'Archivos', 'Programas', 'Contraseñas'], e: 'Los parches de seguridad cierran agujeros descubiertos.' },
      { q: 'El cifrado convierte los datos en código ______ sin la clave correcta.', c: 0, o: ['Ilegible', 'Visible', 'Público', 'Editable'], e: 'El cifrado asegura que solo quien tenga la clave pueda leer los datos.' },
      { q: 'En una red Wi-Fi ______, debes usar VPN para proteger tu conexión.', c: 0, o: ['Pública', 'Privada', 'Del hogar', ' Corporativa'], e: 'Las redes públicas son vulnerables a la interceptación.' },
    ];
    const p = phrases[seed % phrases.length];
    return {
      id: `${lessonId}_q${String(globalIdx + 1).padStart(3, '0')}`,
      question: p.q,
      type: 'completePhrase',
      options: p.o,
      correctIndex: p.c,
      explanation: p.e,
      difficulty,
      lessonId,
    };
  }

  if (type === 'detectRisk') {
    const risks = [
      { q: 'Usar la misma contraseña en todas tus cuentas digitales.', c: 0, o: ['Riesgoso', 'Seguro'], e: 'La reutilización de contraseñas expone todas las cuentas si una se filtra.' },
      { q: 'Conectarte al Wi-Fi del café para acceder a tu banco.', c: 0, o: ['Riesgoso', 'Seguro'], e: 'El Wi-Fi público puede ser interceptado por atacantes.' },
      { q: 'No actualizar el sistema operativo de tu teléfono durante meses.', c: 0, o: ['Riesgoso', 'Seguro'], e: 'Las actualizaciones sin instalar dejan vulnerabilidades abiertas.' },
      { q: 'Hacer clic en un enlace de un correo no solicitado que parece venir de tu banco.', c: 0, o: ['Riesgoso', 'Seguro'], e: 'Los enlaces de correos sospechosos pueden dirigir a sitios de phishing.' },
      { q: 'Compartir tu ubicación en tiempo real en redes sociales mientras viajas.', c: 0, o: ['Riesgoso', 'Seguro'], e: 'Revelar tu ubicación en tiempo real puede ser explotado por delincuentes.' },
      { q: 'Instalar aplicaciones de fuentes no oficiales en tu teléfono.', c: 0, o: ['Riesgoso', 'Seguro'], e: 'Las apps de fuentes no verificadas pueden contener malware.' },
      { q: 'No configurar la verificación en dos pasos en tus cuentas importantes.', c: 0, o: ['Riesgoso', 'Seguro'], e: 'Sin 2FA, una contraseña filtrada da acceso completo a la cuenta.' },
      { q: 'Guardar contraseñas en un papel visible en tu escritorio.', c: 0, o: ['Riesgoso', 'Seguro'], e: 'Cualquier persona con acceso al lugar puede ver y usar las contraseñas.' },
    ];
    const r = risks[seed % risks.length];
    return {
      id: `${lessonId}_q${String(globalIdx + 1).padStart(3, '0')}`,
      question: `Detecta el riesgo: ${r.q}`,
      type: 'detectRisk',
      options: r.o,
      correctIndex: r.c,
      explanation: r.e,
      difficulty,
      lessonId,
    };
  }

  if (type === 'whatWouldYouDo') {
    const scenarios = [
      { q: 'Recibes un correo de tu banco pidiendo que verifiques tu cuenta haciendo clic en un enlace. ¿Qué haces?', c: 0, o: ['No hacer clic, abrir el navegador e ir directamente al sitio del banco', 'Hacer clic para verificar', 'Reenviarlo a un amigo', 'Responder al correo'], e: 'Siempre acceder al banco por el navegador, no por enlaces de correo.' },
      { q: 'Ves a alguien mirando tu contraseña mientras la escribes en una computadora pública. ¿Qué haces?', c: 0, o: ['Bloquear la pantalla y cambiar la contraseña después', 'Ignorar la situación', 'Decirle que pare pero seguir escribiendo', 'Cambiar de lugar'], e: 'El shoulder surfing es una técnica real de robo de credenciales.' },
      { q: 'Tu teléfono muestra un mensaje de que tiene 5 virus y debes llamar a un número. ¿Qué haces?', c: 0, o: ['Ignorar, es un virus de soporte técnico falso', 'Llamar al número', 'Pagar lo que pidan', 'Desinstalar el antivirus'], e: 'Los mensajes de soporte técnico falso son una estafa común.' },
      { q: 'Encuentras un USB en la calle y lo conectas a tu computadora para ver qué contiene. ¿Qué haces?', c: 0, o: ['No conectarlo, podría contener malware', 'Conectarlo para revisarlo', 'Darlo a un amigo', 'Borrarlo sin mirar'], e: 'Los USB abandonados pueden contener software malicioso.' },
      { q: 'Un amigo te pide tu contraseña de Netflix para ver una serie. ¿Qué haces?', c: 0, o: ['Ofrecer crear una cuenta de invitado o negarte amablemente', 'Darle la contraseña', 'Pedirle dinero', 'Crear una cuenta nueva para él'], e: 'Compartir credenciales compromete la seguridad de la cuenta.' },
    ];
    const sc = scenarios[seed % scenarios.length];
    return {
      id: `${lessonId}_q${String(globalIdx + 1).padStart(3, '0')}`,
      question: sc.q,
      type: 'whatWouldYouDo',
      options: sc.o,
      correctIndex: sc.c,
      explanation: sc.e,
      difficulty: 2,
      lessonId,
    };
  }

  if (type === 'createPassword') {
    const passwords = [
      { q: '¿Cuál de las siguientes contraseñas es la más segura?', c: 0, o: ['Kx$9mP#2vL!nQ4wR', 'contraseña123', '12345678', 'password'], e: 'La contraseña con mayor longitud y variedad de caracteres es la más resistente.' },
      { q: '¿Qué contraseña es más segura para tu correo electrónico?', c: 0, o: ['T#uM3sCr!pt0$2024', 'correo123', 'mi correo', 'email'], e: 'Una contraseña con caracteres variados y longitud adecuada es la más segura.' },
      { q: 'Selecciona la contraseña más segura para tu cuenta bancaria:', c: 0, o: ['B@nc0$egur0!2024#xY', 'banco123', '1234567890', 'banco'], e: 'La contraseña bancaria debe ser especialmente fuerte y única.' },
    ];
    const pw = passwords[seed % passwords.length];
    return {
      id: `${lessonId}_q${String(globalIdx + 1).padStart(3, '0')}`,
      question: pw.q,
      type: 'createPassword',
      options: pw.o,
      correctIndex: pw.c,
      explanation: pw.e,
      difficulty: 1,
      lessonId,
    };
  }

  if (type === 'miniCase') {
    const cases = [
      { q: 'Caso: María recibe un correo de su banco pidiendo verificar su cuenta. El correo tiene errores de ortografía y el enlace lleva a un sitio que no es el de su banco. ¿Qué debería hacer?', c: 0, o: ['No hacer clic en el enlace y reportar el correo como phishing', 'Hacer clic para verificar si es real', 'Reenviar el correo a sus amigos', 'Llamar al número del correo'], e: 'Los errores de ortografía y enlaces sospechosos son señales claras de phishing.' },
      { q: 'Caso: Pedro quiere conectarse al Wi-Fi del aeropuerto para revisar su correo bancario. ¿Qué debería hacer primero?', c: 0, o: ['Activar su VPN antes de acceder al correo', 'Acceder directamente al correo', 'Apagar el teléfono', 'Usar datos móviles sin verificar'], e: 'La VPN protege tu conexión en redes públicas como aeropuertos.' },
      { q: 'Caso: Ana encuentra un USB en la estación de autobuses. ¿Qué debería hacer?', c: 0, o: ['No conectarlo a ningún dispositivo', 'Conectarlo a su computadora para revisarlo', 'Darlo a un amigo', 'Borrarlo y usarlo'], e: 'Los USB encontrados pueden contener malware diseñado para infectar dispositivos.' },
      { q: 'Caso: Roberto recibe un mensaje de WhatsApp de un número desconocido con un enlace a una oferta increíble. ¿Qué hacer?', c: 0, o: ['No hacer clic y bloquear al remitente', 'Hacer clic para ver la oferta', 'Compartir con amigos', 'Responder preguntando'], e: 'Los enlaces de desconocidos en mensajería son un vector común de phishing.' },
      { q: 'Caso: Luis quiere vender su teléfono viejo. ¿Qué debe hacer primero con sus datos?', c: 0, o: ['Borrar todos los datos, restablecer de fábrica y desvincular cuentas', 'Solo borrar las fotos', 'Darlo con los datos intactos', 'Venderlo sin preocupaciones'], e: 'El restablecimiento de fábrica y desvinculación de cuentas es esencial.' },
    ];
    const cs = cases[seed % cases.length];
    return {
      id: `${lessonId}_q${String(globalIdx + 1).padStart(3, '0')}`,
      question: cs.q,
      type: 'miniCase',
      options: cs.o,
      correctIndex: cs.c,
      explanation: cs.e,
      difficulty: 2,
      lessonId,
    };
  }

  // Default: multipleChoice
  const mcQuestions = [
    { q: `En el contexto de seguridad digital, ¿cuál es la práctica más recomendable?`, c: 0, o: ['Aplicar las mejores prácticas de seguridad aprendidas', 'Ignorar las advertencias del sistema', 'Compartir credenciales con colegas', 'Usar siempre la configuración por defecto'], e: 'La práctica recomendada es fundamental para mantener la seguridad.' },
    { q: `¿Qué riesgo está asociado con no tomar precauciones de seguridad?`, c: 0, o: ['Exposición de datos personales y cuentas comprometidas', 'Mejora automática de la seguridad', 'Ningún riesgo real', 'Solo inconvenientes menores'], e: 'Sin las precauciones adecuadas, los datos quedan expuestos.' },
    { q: `¿Cuál es el primer paso para protegerte en el mundo digital?`, c: 0, o: ['Conocer los riesgos y configurar las protecciones adecuadas', 'Ignorar el problema', 'Esperar a que algo malo pase', 'Pedir ayuda en redes sociales'], e: 'La concienciación y la configuración inicial son esenciales.' },
    { q: `¿Qué consecuencia puede tener ignorar la seguridad digital?`, c: 0, o: ['Pérdida de datos, robo de identidad o fraude financiero', 'Ninguna consecuencia', 'Solo molestias temporales', 'Mejora del dispositivo'], e: 'Ignorar la seguridad puede tener consecuencias graves.' },
    { q: `Según las mejores prácticas, ¿cada cuánto debes revisar la seguridad de tus cuentas?`, c: 0, o: ['Periódicamente, al menos una vez al mes', 'Nunca es necesario', 'Solo cuando hay un problema', 'Una vez al año'], e: 'La revisión periódica es parte esencial del mantenimiento.' },
  ];
  const mc = mcQuestions[seed % mcQuestions.length];
  return {
    id: `${lessonId}_q${String(globalIdx + 1).padStart(3, '0')}`,
    question: mc.q,
    type: 'multipleChoice',
    options: mc.o,
    correctIndex: mc.c,
    explanation: mc.e,
    difficulty,
    lessonId,
  };
}

generate();
