import fs from 'node:fs/promises';
import path from 'node:path';
import { spawnSync } from 'node:child_process';
import {
  ensureArtifactToolWorkspace,
  importArtifactTool,
  createSlideContext,
  padSlideNumber,
} from '/Volumes/jaehoon_ex/jaehoon_ex/.codex/plugins/cache/openai-primary-runtime/presentations/26.515.10909/skills/presentations/scripts/artifact_tool_utils.mjs';

const workspace = '/Volumes/jaehoon_ex/Applications/Jacsim/outputs/019e33ff-63c7-7020-9e24-b022bf95c7f0/presentations/jacsim-social-qa';
const previewDir = path.join(workspace, 'preview');
const outputDir = path.join(workspace, 'output');
const assetDir = path.join(workspace, 'assets');
const outPptx = path.join(outputDir, 'jacsim-social-qa-fix-report.pptx');
const contactSheet = path.join(outputDir, 'jacsim-social-qa-fix-contact-sheet.png');
const manifestPath = path.join(outputDir, 'jacsim-social-qa-fix-manifest.json');
const slideSize = { width: 1280, height: 720 };

await ensureArtifactToolWorkspace(workspace);
const artifact = await importArtifactTool(workspace);
const presentation = artifact.Presentation.create({ slideSize });
const ctx = createSlideContext(artifact, {
  slideSize,
  workspaceDir: workspace,
  assetDir,
  titleFont: 'Apple SD Gothic Neo',
  bodyFont: 'Apple SD Gothic Neo',
  monoFont: 'SF Mono',
});

const C = {
  bg: '#0B1220',
  bg2: '#101827',
  panel: '#162033',
  panel2: '#1D2A41',
  ink: '#F8FAFC',
  muted: '#A8B3C7',
  faint: '#6B7891',
  green: '#67E8A5',
  green2: '#123A2A',
  red: '#FF6B6B',
  red2: '#3B1720',
  amber: '#F6C85F',
  amber2: '#3B2D12',
  blue: '#7DD3FC',
  blue2: '#132B3A',
  white: '#FFFFFF',
};

function shape(slide, { left, top, width, height, fill = C.panel, line = C.panel, radius = 18, name }) {
  const s = ctx.addShape(slide, {
    left, top, width, height, fill,
    line: ctx.line(line, line === 'none' ? 0 : 1),
    name,
  });
  s.borderRadius = radius;
  return s;
}

function text(slide, value, { left, top, width, height, size = 24, color = C.ink, bold = false, mono = false, align = 'left', valign = 'top', fill = '#00000000', radius = 0, inset = 0, name }) {
  const t = ctx.addText(slide, {
    text: value,
    left, top, width, height,
    fontSize: size,
    color,
    bold,
    typeface: mono ? 'SF Mono' : 'Apple SD Gothic Neo',
    align,
    valign,
    fill,
    line: ctx.line('#00000000', 0),
    insets: { left: inset, right: inset, top: inset, bottom: inset },
    name,
  });
  if (radius) t.borderRadius = radius;
  return t;
}

function chip(slide, label, { left, top, width, fill, color = C.ink }) {
  shape(slide, { left, top, width, height: 34, fill, line: fill, radius: 17 });
  text(slide, label, { left, top: top + 7, width, height: 22, size: 15, bold: true, color, align: 'center' });
}

function title(slide, kicker, headline, sub = '') {
  text(slide, kicker, { left: 52, top: 38, width: 420, height: 24, size: 14, color: C.green, bold: true });
  text(slide, headline, { left: 52, top: 70, width: 840, height: 82, size: 42, bold: true });
  if (sub) text(slide, sub, { left: 54, top: 145, width: 820, height: 36, size: 18, color: C.muted });
}

function slideFooter(slide, n) {
  text(slide, `Jacsim QA · 2026-05-17 · ${n}/8`, { left: 52, top: 684, width: 400, height: 20, size: 12, color: C.faint });
}

function addBulletList(slide, items, { left, top, width, size = 18, lineHeight = 32, color = C.ink }) {
  items.forEach((item, idx) => {
    text(slide, '•', { left, top: top + idx * lineHeight + 1, width: 18, height: 24, size, color: C.green, bold: true });
    text(slide, item, { left: left + 26, top: top + idx * lineHeight, width, height: lineHeight, size, color });
  });
}

function issueCard(slide, label, heading, body, { left, top, width, height, level = 'P1' }) {
  const levelFill = level === 'P1' ? C.red2 : C.amber2;
  const levelColor = level === 'P1' ? C.red : C.amber;
  shape(slide, { left, top, width, height, fill: C.panel, line: '#25334D', radius: 18 });
  chip(slide, level, { left: left + 20, top: top + 18, width: 52, fill: levelFill, color: levelColor });
  text(slide, label, { left: left + 84, top: top + 24, width: width - 104, height: 18, size: 13, color: C.muted, bold: true });
  text(slide, heading, { left: left + 20, top: top + 64, width: width - 40, height: 52, size: 23, bold: true });
  text(slide, body, { left: left + 20, top: top + 124, width: width - 40, height: height - 144, size: 16, color: C.muted });
}

async function phone(slide, image, { left, top, width = 220, height = 478, label }) {
  shape(slide, { left: left - 10, top: top - 10, width: width + 20, height: height + 20, fill: '#050A14', line: '#26334B', radius: 32 });
  await ctx.addImage(slide, { path: path.join(assetDir, image), left, top, width, height, fit: 'cover', alt: label });
  text(slide, label, { left: left - 10, top: top + height + 16, width: width + 20, height: 22, size: 13, color: C.muted, align: 'center', bold: true });
}

function statusRow(slide, y, command, result, note) {
  text(slide, command, { left: 92, top: y, width: 350, height: 24, size: 18, mono: true, color: C.ink });
  chip(slide, result, { left: 470, top: y - 5, width: 74, fill: C.green2, color: C.green });
  text(slide, note, { left: 570, top: y, width: 560, height: 24, size: 17, color: C.muted });
}

function addSlide() {
  const s = presentation.slides.add();
  s.background.fill = C.bg;
  return s;
}

// 1
{
  const s = addSlide();
  title(s, 'P1/P2 FIX REPORT', 'Jacsim Social QA Fix', 'develop 기준 기능 리스크 수정, 회귀 테스트, 시뮬레이터 확인 자료');
  chip(s, 'P1/P2 전부 수정', { left: 54, top: 200, width: 148, fill: C.green2, color: C.green });
  chip(s, '테스트 PASS', { left: 216, top: 200, width: 112, fill: C.blue2, color: C.blue });
  chip(s, 'Simulator RUN', { left: 342, top: 200, width: 132, fill: C.amber2, color: C.amber });
  addBulletList(s, [
    '공개범위: 자랑글/응원/댓글이 작심 visibility를 따르도록 수정',
    '소셜 알림: 로컬 사용자가 받을 알림만 예약하도록 차단',
    '따라하기: 실제 작심 생성 이후 copiedTaskId로 기록',
    '자랑글 사진/AI 코치: 가짜 경로와 fatalError 제거',
  ], { left: 58, top: 270, width: 650, size: 20, lineHeight: 40 });
  await phone(s, 'after-today.jpg', { left: 850, top: 95, width: 250, height: 544, label: '작업 완료 · Today screen' });
  slideFooter(s, 1);
}

// 2
{
  const s = addSlide();
  title(s, '작업 전 → 작업 완료', 'P1 · 공개범위 누수 차단', '비공개 작심에서 파생된 소셜 콘텐츠가 피드/댓글에서 열릴 수 있던 리스크를 제거했습니다.');
  issueCard(s, 'BEFORE CODE', 'profile과 자랑글/응원/댓글을 같은 규칙으로 허용', "case .profile, .bragPost, .cheerCount, .commentList:\n    return true", { left: 54, top: 205, width: 520, height: 230, level: 'P1' });
  issueCard(s, 'AFTER CODE', '자랑글 계열은 task visibility 기반으로 필터링', "case .profile:\n    return true\ncase .bragPost, .cheerCount, .commentList:\n    return canViewTaskScopedResource(...)", { left: 706, top: 205, width: 520, height: 230, level: 'P1' });
  text(s, '검증 포인트', { left: 54, top: 492, width: 180, height: 28, size: 22, bold: true });
  addBulletList(s, [
    'private 자랑글은 stranger 피드에서 제외',
    'followers 댓글/응원은 oneWay 또는 mutual 관계에서만 허용',
    'profile은 기존처럼 blocked 외에는 계속 접근 가능',
  ], { left: 60, top: 535, width: 800, size: 18, lineHeight: 34 });
  chip(s, 'Jacsim regression test added', { left: 895, top: 548, width: 270, fill: C.green2, color: C.green });
  slideFooter(s, 2);
}

// 3
{
  const s = addSlide();
  title(s, '작업 전 → 작업 완료', 'P1 · 로컬 소셜 알림 오발송 차단', '내가 한 행동을 내 기기에 친구 행동처럼 띄우는 경로를 target/source 기준으로 막았습니다.');
  issueCard(s, 'BEFORE FLOW', '친구 요청 방향이 반대로 저장될 수 있음', 'fromUserId = row.user.id\ntoUserId = currentUserID\n→ 검색한 상대가 나에게 요청한 것처럼 기록', { left: 54, top: 205, width: 355, height: 260, level: 'P1' });
  issueCard(s, 'BEFORE FLOW', '원격 이벤트용 알림을 로컬에서 즉시 예약', 'follow / cheer / comment / follow challenge 이후\n내 행동인데도 “친구가…” 알림 예약 가능', { left: 462, top: 205, width: 355, height: 260, level: 'P1' });
  issueCard(s, 'AFTER GUARD', 'source/target이 로컬 수신 조건일 때만 예약', 'target == currentUserID\nsource != currentUserID\n그 외 targeted social notification은 return', { left: 870, top: 205, width: 355, height: 260, level: 'P1' });
  addBulletList(s, [
    '친구 검색 팔로우 요청: currentUser → targetUser 방향으로 저장',
    'self-triggered friendGraduated/friendPosted 로컬 예약 제거',
    'LocalNotificationSchedulerAdapter 자체에도 이중 방어 추가',
  ], { left: 70, top: 520, width: 900, size: 18, lineHeight: 34 });
  slideFooter(s, 3);
}

// 4
{
  const s = addSlide();
  title(s, '작업 전 → 작업 완료', 'P2 · 미완성 기능을 실제 완료 흐름으로 연결', '탭 시점의 가짜 성공 처리와 placeholder 저장을 실제 성공 이벤트 기반으로 바꿨습니다.');
  issueCard(s, 'FOLLOW CHALLENGE', '탭 순간 copiedTaskId를 임의 생성하고 기록', '작심 생성 실패/취소와 무관하게 따라하기 기록이 남을 수 있음', { left: 54, top: 205, width: 360, height: 250, level: 'P2' });
  issueCard(s, 'BRAG IMAGE', '샘플/파일명만 저장하고 카드에는 실제 이미지가 없음', 'imagePaths에는 fake path만 있고 imageStore 저장/로드 없음', { left: 462, top: 205, width: 360, height: 250, level: 'P2' });
  issueCard(s, 'AI COACH', '실사용 경로가 fatalError로 종료', 'RealAICoachClientAdapter.sendMessage / weeklyReflection 미구현', { left: 870, top: 205, width: 360, height: 250, level: 'P2' });
  addBulletList(s, [
    'NewTaskModel이 실제 생성된 Domain.Task를 콜백으로 반환',
    '선택 이미지를 imageStore에 저장하고 Feed/Profile 카드에서 Data로 렌더링',
    'AI 코치는 네트워크 없이도 크래시 없는 deterministic 응답 제공',
  ], { left: 70, top: 520, width: 930, size: 18, lineHeight: 34 });
  slideFooter(s, 4);
}

// 5
{
  const s = addSlide();
  title(s, '작업 완료 설계', '저장소와 마이그레이션은 privacy-safe로 축소', '기존 BragPost 테이블을 직접 갈아엎지 않고 공개범위만 V6 보조 모델로 붙였습니다.');
  shape(s, { left: 70, top: 218, width: 310, height: 130, fill: C.panel2, line: '#2A3A56', radius: 20 });
  text(s, 'Domain.BragPost', { left: 94, top: 244, width: 260, height: 28, size: 24, bold: true });
  text(s, '+ visibility: TaskVisibility', { left: 96, top: 290, width: 260, height: 24, size: 19, color: C.green, mono: true });
  text(s, '→', { left: 410, top: 265, width: 60, height: 60, size: 44, color: C.faint, align: 'center' });
  shape(s, { left: 500, top: 218, width: 350, height: 130, fill: C.panel2, line: '#2A3A56', radius: 20 });
  text(s, 'CurrentSwiftDataSchema', { left: 524, top: 244, width: 310, height: 28, size: 23, bold: true });
  text(s, 'BragPostVisibilityModel', { left: 526, top: 290, width: 280, height: 24, size: 19, color: C.blue, mono: true });
  text(s, '→', { left: 880, top: 265, width: 60, height: 60, size: 44, color: C.faint, align: 'center' });
  shape(s, { left: 970, top: 218, width: 230, height: 130, fill: C.green2, line: '#23563D', radius: 20 });
  text(s, 'Legacy default', { left: 992, top: 244, width: 185, height: 28, size: 23, bold: true, color: C.green });
  text(s, 'missing visibility = private', { left: 994, top: 290, width: 180, height: 44, size: 17, color: C.ink });
  addBulletList(s, [
    'V1→current migration test로 기존 작심 visibility private 보정 확인',
    '기존 자랑글에 visibility row가 없으면 private로 해석해 보수적으로 보호',
    'seed social post는 public visibility row를 추가해 추천 피드가 비지 않도록 보정',
  ], { left: 86, top: 430, width: 960, size: 19, lineHeight: 38 });
  slideFooter(s, 5);
}

// 6
{
  const s = addSlide();
  title(s, '작업 완료 화면 캡처', 'Simulator smoke test', 'iPhone 17 Pro / iOS 26.1에서 빌드·설치·실행 후 주요 화면을 확인했습니다.');
  await phone(s, 'after-today.jpg', { left: 80, top: 190, width: 210, height: 456, label: 'Today' });
  await phone(s, 'after-feed.jpg', { left: 375, top: 190, width: 210, height: 456, label: 'Feed' });
  await phone(s, 'after-brag-compose.jpg', { left: 670, top: 190, width: 210, height: 456, label: 'Brag composer' });
  await phone(s, 'after-brag-visibility.jpg', { left: 965, top: 190, width: 210, height: 456, label: 'Visibility section' });
  slideFooter(s, 6);
}

// 7
{
  const s = addSlide();
  title(s, '검증 결과', 'Build & test matrix', '실패했던 SwiftData migration 경로까지 포함해 재검증했습니다.');
  shape(s, { left: 62, top: 205, width: 1120, height: 350, fill: C.panel, line: '#25334D', radius: 24 });
  statusRow(s, 245, 'tuist generate', 'PASS', 'Project generated');
  statusRow(s, 300, 'tuist test Data', 'PASS', 'SwiftData V1→current migration, BragPost visibility, AI coach 포함');
  statusRow(s, 355, 'tuist test Jacsim', 'PASS', '친구 요청 방향, 따라하기, 사진 저장, 댓글 시트, visibility policy 포함');
  statusRow(s, 410, 'tuist build Jacsim', 'PASS', '앱 빌드 성공');
  statusRow(s, 465, 'XcodeBuildMCP build_run_sim', 'PASS', 'iPhone 17 Pro simulator 실행 및 스크린샷 확보');
  text(s, '참고: `tuist test Domain`은 현재 Domain scheme test action에 testable이 없어 실행 대상이 없다고 보고합니다. 이번 공개범위 정책은 실제 실행되는 Jacsim regression test에도 추가했습니다.', { left: 76, top: 585, width: 1040, height: 48, size: 16, color: C.muted });
  slideFooter(s, 7);
}

// 8
{
  const s = addSlide();
  title(s, 'QA Sign-off', 'P1/P2 closure summary', '기획/QA 관점에서 앱 사용 중 치명도가 높은 미완성 경로를 닫았습니다.');
  const rows = [
    ['P1', 'Privacy leak', '자랑글·응원·댓글 공개범위가 task visibility를 따름', 'Closed'],
    ['P1', 'Wrong local notification', 'source/target guard + self-trigger 제거', 'Closed'],
    ['P2', 'Follow challenge false success', '실제 task 생성 이후 copiedTaskId로 기록', 'Closed'],
    ['P2', 'Brag image placeholder', 'imageStore 저장/로드 및 카드 렌더링', 'Closed'],
    ['P2', 'AI Coach fatalError', '크래시 없는 local deterministic adapter', 'Closed'],
  ];
  let y = 220;
  rows.forEach(([sev, area, fix, status]) => {
    shape(s, { left: 68, top: y - 12, width: 1080, height: 54, fill: y % 2 === 0 ? C.panel : C.panel2, line: '#25334D', radius: 14 });
    chip(s, sev, { left: 88, top: y - 2, width: 50, fill: sev === 'P1' ? C.red2 : C.amber2, color: sev === 'P1' ? C.red : C.amber });
    text(s, area, { left: 165, top: y + 2, width: 240, height: 24, size: 18, bold: true });
    text(s, fix, { left: 425, top: y + 2, width: 520, height: 24, size: 17, color: C.muted });
    chip(s, status, { left: 1012, top: y - 2, width: 86, fill: C.green2, color: C.green });
    y += 66;
  });
  text(s, '남은 리스크', { left: 68, top: 588, width: 160, height: 26, size: 22, bold: true });
  text(s, '빌드 로그에 보이는 AppDelegate/KeyboardObserver/JSTabBar deprecation은 이번 변경 파일이 아니며 기존 경고입니다. 별도 정리 작업으로 분리하는 것이 맞습니다.', { left: 225, top: 590, width: 900, height: 46, size: 16, color: C.muted });
  slideFooter(s, 8);
}

await fs.mkdir(previewDir, { recursive: true });
await fs.mkdir(outputDir, { recursive: true });
const previewPaths = [];
for (let i = 0; i < presentation.slides.count; i += 1) {
  const slide = presentation.slides.getItem(i);
  const png = await presentation.export({ slide, format: 'png', scale: 1 });
  const previewPath = path.join(previewDir, `slide-${padSlideNumber(i + 1)}.png`);
  await fs.writeFile(previewPath, Buffer.from(await png.arrayBuffer()));
  previewPaths.push(previewPath);
}
const pptx = await artifact.PresentationFile.exportPptx(presentation);
await pptx.save(outPptx);
const py = '/Volumes/jaehoon_ex/jaehoon_ex/.cache/codex-runtimes/codex-primary-runtime/dependencies/python/bin/python3';
const sheetScript = '/Volumes/jaehoon_ex/jaehoon_ex/.codex/plugins/cache/openai-primary-runtime/presentations/26.515.10909/skills/presentations/scripts/make_contact_sheet.py';
const result = spawnSync(py, [sheetScript, '--output', contactSheet, ...previewPaths], { encoding: 'utf8' });
if (result.status !== 0) {
  throw new Error(`contact sheet failed\n${result.stdout}\n${result.stderr}`);
}
const stat = await fs.stat(outPptx);
const manifest = {
  output: outPptx,
  outputBytes: stat.size,
  contactSheet,
  slideCount: presentation.slides.count,
  previewPaths,
  sourceScreenshots: [
    path.join(assetDir, 'after-today.jpg'),
    path.join(assetDir, 'after-feed.jpg'),
    path.join(assetDir, 'after-brag-compose.jpg'),
    path.join(assetDir, 'after-brag-visibility.jpg'),
  ],
};
await fs.writeFile(manifestPath, `${JSON.stringify(manifest, null, 2)}\n`, 'utf8');
console.log(JSON.stringify(manifest, null, 2));
