const fs = require('fs');
const path = require('path');

const stagesPath = path.join(__dirname, '..', 'assets', 'content', 'stages.json');
const stages = JSON.parse(fs.readFileSync(stagesPath, 'utf8'));

function getLessonsForStage(stageId) {
    const stage = stages.find(s => s.id === stageId);
    if (!stage) return [];
    const lessons = [];
    for (const session of stage.sessions) {
        for (const lesson of session.lessons) {
            lessons.push(lesson);
        }
    }
    return lessons;
}

function getLessonsWithQuestions(qFile) {
    try {
        const data = JSON.parse(fs.readFileSync(qFile, 'utf8'));
        const lessonIds = new Set(data.map(q => q.lessonId));
        return lessonIds;
    } catch(e) {
        return new Set();
    }
}

function getExistingQuestionIds(qFile) {
    try {
        const data = JSON.parse(fs.readFileSync(qFile, 'utf8'));
        return data.map(q => q.id);
    } catch(e) {
        return [];
    }
}

// Stage 1
const st1Lessons = getLessonsForStage('ac_st1');
const st1Existing = getLessonsWithQuestions(path.join(__dirname, '..', 'assets', 'content', 'questions_ac_st1.json'));
const st1Empty = st1Lessons.filter(l => !st1Existing.has(l.id));
const st1QIds = getExistingQuestionIds(path.join(__dirname, '..', 'assets', 'content', 'questions_ac_st1.json'));

// Stage 2
const st2Lessons = getLessonsForStage('ac_st2');
const st2Existing = getLessonsWithQuestions(path.join(__dirname, '..', 'assets', 'content', 'questions_ac_st2.json'));
const st2Empty = st2Lessons.filter(l => !st2Existing.has(l.id));
const st2QIds = getExistingQuestionIds(path.join(__dirname, '..', 'assets', 'content', 'questions_ac_st2.json'));

// Stage 3
const st3Lessons = getLessonsForStage('ac_st3');
const st3Existing = getLessonsWithQuestions(path.join(__dirname, '..', 'assets', 'content', 'questions_ac_st3.json'));
const st3Empty = st3Lessons.filter(l => !st3Existing.has(l.id));
const st3QIds = getExistingQuestionIds(path.join(__dirname, '..', 'assets', 'content', 'questions_ac_st3.json'));

console.log("=== STAGE 1 ===");
console.log("Total lessons:", st1Lessons.length);
console.log("Lessons with questions:", st1Existing.size);
console.log("Empty lessons:", st1Empty.length);
st1Empty.forEach(l => console.log("  EMPTY:", l.id, "-", l.title));
console.log("Existing Q IDs count:", st1QIds.length);
if (st1QIds.length > 0) {
    console.log("Last Q ID:", st1QIds[st1QIds.length - 1]);
}

console.log("\n=== STAGE 2 ===");
console.log("Total lessons:", st2Lessons.length);
console.log("Lessons with questions:", st2Existing.size);
console.log("Empty lessons:", st2Empty.length);
st2Empty.forEach(l => console.log("  EMPTY:", l.id, "-", l.title));
console.log("Existing Q IDs count:", st2QIds.length);
if (st2QIds.length > 0) {
    console.log("Last Q ID:", st2QIds[st2QIds.length - 1]);
}

console.log("\n=== STAGE 3 ===");
console.log("Total lessons:", st3Lessons.length);
console.log("Lessons with questions:", st3Existing.size);
console.log("Empty lessons:", st3Empty.length);
st3Empty.forEach(l => console.log("  EMPTY:", l.id, "-", l.title));
console.log("Existing Q IDs count:", st3QIds.length);
if (st3QIds.length > 0) {
    console.log("Last Q ID:", st3QIds[st3QIds.length - 1]);
}
