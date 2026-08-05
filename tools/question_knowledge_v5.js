#!/usr/bin/env node
/**
 * Combined Knowledge Base Loader
 * Loads kb_stages_1_4.js and kb_stages_5_8.js into a single module.
 */
const kb14 = require('./kb_stages_1_4.js');
const kb58 = require('./kb_stages_5_8.js');

module.exports = {
  st1: kb14.st1 || [],
  st2: kb14.st2 || [],
  st3: kb14.st3 || [],
  st4: kb14.st4 || [],
  st5: kb58.st5 || [],
  st6: kb58.st6 || [],
  st7: kb58.st7 || [],
  st8: kb58.st8 || [],
};

// Count totals
let total = 0;
for (let i = 1; i <= 8; i++) {
  const count = (module.exports[`st${i}`] || []).length;
  console.log(`st${i}: ${count} questions`);
  total += count;
}
console.log(`Total knowledge base: ${total} questions`);
