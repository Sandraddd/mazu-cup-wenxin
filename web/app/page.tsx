"use client";

import { useEffect, useMemo, useRef, useState } from "react";

type Screen = "home" | "ask" | "ritual" | "result" | "records" | "culture" | "about";
type Category = "事业" | "感情" | "健康" | "家庭" | "其他";
type CupResult = "sheng" | "xiao" | "yin";

type RecordItem = {
  id: string;
  createdAt: string;
  question: string;
  category: Category;
  result: CupResult;
};

const RESULT_COPY: Record<CupResult, { name: string; faces: string; seal: string; guidance: string }> = {
  sheng: {
    name: "圣杯",
    faces: "一平一凸 · 较肯定的象征",
    seal: "允",
    guidance: "传统上常被理解为较为肯定的回应。可以把它当作确认内心方向的契机，在审慎评估现实条件后再行动。",
  },
  xiao: {
    name: "笑杯",
    faces: "两面皆平 · 问题仍需厘清",
    seal: "思",
    guidance: "传统上常提示问题、表达或时机尚未清晰。不妨换一个角度重新梳理，再决定下一步。",
  },
  yin: {
    name: "阴杯",
    faces: "两面皆凸 · 提醒暂缓审视",
    seal: "缓",
    guidance: "传统上常被理解为暂不相应。此刻可先停下来补足信息、调整方向，不必急于作出决定。",
  },
};

const CULTURE_ARTICLES = [
  {
    marker: "海",
    title: "妈祖故事",
    subtitle: "从林默娘到海上守护",
    body: "妈祖信俗发源于福建湄洲岛。民间传说中的林默娘慈悲助人、护佑航海者，后世逐渐形成跨地域传播的妈祖信仰与丰富民俗。今天，妈祖文化也承载着崇德、行善、大爱的精神价值。",
  },
  {
    marker: "筊",
    title: "掷筊由来",
    subtitle: "人与信仰之间的礼仪表达",
    body: "掷筊是闽南、台湾及华人社会常见的传统民俗仪式。参与者通常先净心、说明所问，再掷出一对筊杯。不同地区、宫庙的仪式细节可能有所差异，应尊重当地传统。",
  },
  {
    marker: "象",
    title: "三种杯象",
    subtitle: "圣杯、笑杯与阴杯",
    body: "本体验采用常见的简化解释：一平一凸为圣杯，两平面为笑杯，两凸面为阴杯。各地对杯面名称、仪式顺序和具体含义可能略有不同。",
  },
  {
    marker: "礼",
    title: "民俗礼仪",
    subtitle: "敬意、节制与善念",
    body: "体验时宜保持尊重，不以戏谑、赌博或反复追问的心态对待传统礼仪。医疗、法律、财务与重大人生问题仍应依靠充分信息、专业意见和个人判断。",
  },
];

const STORAGE_KEY = "mazu-cup-web-records-v1";

function castCup(): CupResult {
  const first = Math.random() >= 0.5;
  const second = Math.random() >= 0.5;
  if (first !== second) return "sheng";
  return first ? "xiao" : "yin";
}

function readStoredRecords(value: string): RecordItem[] {
  const parsed: unknown = JSON.parse(value);
  if (!Array.isArray(parsed)) return [];
  const categories = new Set<Category>(["事业", "感情", "健康", "家庭", "其他"]);
  const results = new Set<CupResult>(["sheng", "xiao", "yin"]);
  return parsed.filter((item): item is RecordItem => {
    if (!item || typeof item !== "object") return false;
    const record = item as Partial<RecordItem>;
    return typeof record.id === "string"
      && typeof record.createdAt === "string"
      && !Number.isNaN(Date.parse(record.createdAt))
      && typeof record.question === "string"
      && record.question.length <= 120
      && categories.has(record.category as Category)
      && results.has(record.result as CupResult);
  });
}

function CupBlock({ face, side }: { face: "flat" | "round"; side: "left" | "right" }) {
  return (
    <div className={`cup-block cup-${side} face-${face}`} aria-hidden="true">
      <span />
    </div>
  );
}

function ResultBlocks({ result }: { result: CupResult }) {
  const faces: Record<CupResult, ["flat" | "round", "flat" | "round"]> = {
    sheng: ["flat", "round"],
    xiao: ["flat", "flat"],
    yin: ["round", "round"],
  };
  return (
    <div className="result-blocks" role="img" aria-label={`筊杯结果：${RESULT_COPY[result].faces}`}>
      <CupBlock face={faces[result][0]} side="left" />
      <CupBlock face={faces[result][1]} side="right" />
    </div>
  );
}

export default function Home() {
  const [screen, setScreen] = useState<Screen>("home");
  const [question, setQuestion] = useState("");
  const [category, setCategory] = useState<Category>("事业");
  const [result, setResult] = useState<CupResult | null>(null);
  const [ritualStage, setRitualStage] = useState<"ready" | "lifting" | "turning" | "landed">("ready");
  const [records, setRecords] = useState<RecordItem[]>([]);
  const [saved, setSaved] = useState(false);
  const [expandedArticle, setExpandedArticle] = useState<number | null>(null);
  const [confirmClear, setConfirmClear] = useState(false);
  const timerRef = useRef<number[]>([]);
  const screenRef = useRef<HTMLDivElement>(null);
  const confirmDialogRef = useRef<HTMLDialogElement>(null);

  useEffect(() => {
    const handle = window.setTimeout(() => {
      try {
        const value = localStorage.getItem(STORAGE_KEY);
        if (value) setRecords(readStoredRecords(value));
      } catch {
        setRecords([]);
      }
    }, 0);
    return () => window.clearTimeout(handle);
  }, []);

  useEffect(() => {
    document.title = `妈祖 · 圣杯问心${screen === "home" ? "" : `｜${screenLabel(screen)}`}`;
    window.scrollTo({ top: 0, behavior: "smooth" });
    screenRef.current?.focus({ preventScroll: true });
  }, [screen]);

  useEffect(() => {
    const dialog = confirmDialogRef.current;
    if (!dialog) return;
    if (confirmClear && !dialog.open) {
      dialog.showModal();
      window.setTimeout(() => dialog.querySelector<HTMLButtonElement>("button")?.focus(), 0);
    }
  }, [confirmClear]);

  useEffect(() => () => timerRef.current.forEach(window.clearTimeout), []);

  const currentResult = result ? RESULT_COPY[result] : null;
  const validQuestion = question.trim().length >= 4;

  const formattedRecords = useMemo(
    () => records.map((item) => ({ ...item, date: new Intl.DateTimeFormat("zh-CN", { dateStyle: "medium", timeStyle: "short" }).format(new Date(item.createdAt)) })),
    [records],
  );

  function navigate(next: Screen) {
    timerRef.current.forEach(window.clearTimeout);
    timerRef.current = [];
    setScreen(next);
    setConfirmClear(false);
  }

  function startRitual() {
    if (!validQuestion) return;
    setResult(null);
    setSaved(false);
    setRitualStage("ready");
    navigate("ritual");
  }

  function throwBlocks() {
    if (ritualStage !== "ready") return;
    const lockedResult = castCup();
    setResult(lockedResult);
    const reduceMotion = window.matchMedia("(prefers-reduced-motion: reduce)").matches;

    if (reduceMotion) {
      setRitualStage("landed");
      timerRef.current.push(window.setTimeout(() => navigate("result"), 350));
      return;
    }

    setRitualStage("lifting");
    timerRef.current.push(window.setTimeout(() => setRitualStage("turning"), 520));
    timerRef.current.push(window.setTimeout(() => setRitualStage("landed"), 1840));
    timerRef.current.push(window.setTimeout(() => navigate("result"), 2540));
  }

  function saveRecord() {
    if (!result || saved) return;
    const next = [
      { id: crypto.randomUUID(), createdAt: new Date().toISOString(), question: question.trim(), category, result },
      ...records,
    ];
    setRecords(next);
    try { localStorage.setItem(STORAGE_KEY, JSON.stringify(next)); } catch { /* keep the record for this session */ }
    setSaved(true);
  }

  function deleteRecord(id: string) {
    const next = records.filter((item) => item.id !== id);
    setRecords(next);
    try { localStorage.setItem(STORAGE_KEY, JSON.stringify(next)); } catch { /* keep UI usable when storage is unavailable */ }
  }

  function clearRecords() {
    setRecords([]);
    try { localStorage.removeItem(STORAGE_KEY); } catch { /* already cleared for this session */ }
    setConfirmClear(false);
  }

  function resetQuestion() {
    setResult(null);
    setSaved(false);
    setRitualStage("ready");
    navigate("ask");
  }

  return (
    <main className="site-shell">
      <div className="ambient" aria-hidden="true">
        <div className="moon-glow" />
        <div className="mist mist-one" />
        <div className="mist mist-two" />
        <div className="temple-silhouette"><i /><b /><em /></div>
        <div className="waves wave-one" />
        <div className="waves wave-two" />
      </div>

      {screen !== "home" && (
        <header className="topbar">
          <button className="icon-button" onClick={() => navigate(screen === "result" || screen === "ritual" ? "home" : "home")} aria-label="返回首页">←</button>
          <span>{screenLabel(screen)}</span>
          <button className="wordmark-button" onClick={() => navigate("about")}>说明</button>
        </header>
      )}

      <div className={`screen screen-${screen}`} ref={screenRef} tabIndex={-1} aria-live={screen === "result" ? "polite" : "off"}>
        {screen === "home" && (
          <section className="home-screen" aria-labelledby="main-title">
            <div className="brand-mark" aria-hidden="true"><span>湄</span></div>
            <p className="eyebrow">海上信俗 · 数字文化体验</p>
            <h1 id="main-title">妈祖<span>·</span>圣杯问心</h1>
            <p className="motto">一念诚心 <i /> 静观本心</p>
            <p className="intro">以数字方式了解掷筊礼仪，<br />在片刻静心中梳理自己的问题。</p>
            <button className="primary-button" onClick={() => navigate("ask")}><span>开始请示</span><b>→</b></button>
            <div className="home-grid">
              <button className="portal-card" onClick={() => navigate("records")}><span className="portal-icon">册</span><strong>我的祈愿</strong><small>{records.length ? `${records.length} 条本地记录` : "仅保存在此设备"}</small></button>
              <button className="portal-card" onClick={() => navigate("culture")}><span className="portal-icon">文</span><strong>妈祖文化</strong><small>故事、杯象与礼仪</small></button>
            </div>
            <button className="text-link" onClick={() => navigate("about")}>了解圣杯与体验规则 <span>↗</span></button>
            <p className="boundary"><span>i</span> 文化体验 · 不作预测或现实决策依据</p>
          </section>
        )}

        {screen === "ask" && (
          <section className="content-screen ask-screen" aria-labelledby="ask-title">
            <div className="section-heading">
              <span className="heading-seal">静</span>
              <p className="eyebrow">先静心，再发问</p>
              <h2 id="ask-title">净心 · 请示</h2>
              <p>请深呼吸片刻，将问题写得清楚、具体。</p>
            </div>
            <div className="paper-card form-card">
              <label htmlFor="question">心中所问</label>
              <textarea id="question" value={question} onChange={(event) => setQuestion(event.target.value.slice(0, 120))} placeholder="例如：我是否已充分准备好接受新的工作机会？" rows={5} />
              <div className="field-meta"><span>建议聚焦一件事</span><span>{question.length} / 120</span></div>
              <fieldset>
                <legend>所问类别</legend>
                <div className="category-list">
                  {(["事业", "感情", "健康", "家庭", "其他"] as Category[]).map((item) => (
                    <button key={item} type="button" className={category === item ? "selected" : ""} onClick={() => setCategory(item)} aria-pressed={category === item}>{item}</button>
                  ))}
                </div>
              </fieldset>
            </div>
            <p className="privacy-note">请勿填写身份证号、电话、病历等敏感信息。</p>
            <button className="primary-button" onClick={startRitual} disabled={!validQuestion}><span>进入掷杯体验</span><b>→</b></button>
          </section>
        )}

        {screen === "ritual" && (
          <section className="ritual-screen" aria-labelledby="ritual-title">
            <div className="incense" aria-hidden="true"><span /><i /><b /></div>
            <p className="eyebrow">{ritualStage === "ready" ? "净心" : ritualStage === "lifting" ? "起杯" : ritualStage === "turning" ? "掷杯" : "落杯"}</p>
            <h2 id="ritual-title">{question}</h2>
            <p className="ritual-hint">{ritualStage === "ready" ? "先深呼吸，再轻触筊杯" : ritualStage === "landed" ? "杯落有声，静候片刻" : "诚心起杯，静观本心"}</p>
            <div className={`ritual-stage stage-${ritualStage}`} role="img" aria-label="两枚筊杯正在进行模拟掷杯" aria-live="polite">
              <div className="altar-shadow" />
              <CupBlock face={result === "xiao" || result === "sheng" ? "flat" : "round"} side="left" />
              <CupBlock face={result === "xiao" ? "flat" : "round"} side="right" />
            </div>
            <button className="primary-button" onClick={throwBlocks} disabled={ritualStage !== "ready"}><span>{ritualStage === "ready" ? "轻触掷杯" : "请静候"}</span><b>⌁</b></button>
          </section>
        )}

        {screen === "result" && result && currentResult && (
          <section className="content-screen result-screen" aria-labelledby="result-title">
            <div className="result-aura" aria-hidden="true" />
            <div className="result-seal">{currentResult.seal}</div>
            <p className="eyebrow">本次模拟结果</p>
            <h2 id="result-title">{currentResult.name}</h2>
            <p className="result-faces">{currentResult.faces}</p>
            <ResultBlocks result={result} />
            <div className="paper-card result-card">
              <span>你所问</span>
              <strong>{question}</strong>
              <hr />
              <span>传统释义</span>
              <p>{currentResult.guidance}</p>
            </div>
            <p className="result-boundary">结果由本地随机模拟产生，仅供传统民俗文化体验，不代表神意，也不替代医疗、法律、财务或人生决策。</p>
            <button className="primary-button" onClick={saveRecord} disabled={saved}><span>{saved ? "已保存到祈愿记录" : "保存本次记录"}</span><b>{saved ? "✓" : "+"}</b></button>
            <div className="secondary-actions"><button onClick={resetQuestion}>重新请示</button><button onClick={() => navigate("home")}>完成</button></div>
          </section>
        )}

        {screen === "records" && (
          <section className="content-screen records-screen" aria-labelledby="records-title">
            <div className="section-heading compact">
              <p className="eyebrow">仅此设备可见</p>
              <h2 id="records-title">我的祈愿</h2>
              <p>每一次停下来思考，都值得被温柔记录。</p>
            </div>
            {!formattedRecords.length ? (
              <div className="empty-state"><span>册</span><h3>尚无祈愿记录</h3><p>完成一次请示并保存后，会显示在这里。</p><button onClick={() => navigate("ask")}>开始第一次体验</button></div>
            ) : (
              <>
                <div className="record-list">
                  {formattedRecords.map((item) => (
                    <article className="record-card" key={item.id}>
                      <div className="record-top"><span>{item.category}</span><time dateTime={item.createdAt}>{item.date}</time></div>
                      <h3>{item.question}</h3>
                      <div className="record-result"><b>{RESULT_COPY[item.result].name}</b><small>{RESULT_COPY[item.result].faces}</small></div>
                      <button className="delete-button" onClick={() => deleteRecord(item.id)} aria-label={`删除记录：${item.question}`}>删除</button>
                    </article>
                  ))}
                </div>
                <button className="clear-button" onClick={() => setConfirmClear(true)}>清空全部记录</button>
                {confirmClear && <dialog ref={confirmDialogRef} className="confirm-card" aria-labelledby="clear-title" onCancel={(event) => { event.preventDefault(); setConfirmClear(false); }} onClose={() => setConfirmClear(false)}><strong id="clear-title">确定清空全部记录？</strong><p>此操作无法撤销。</p><div><button onClick={() => setConfirmClear(false)}>取消</button><button onClick={clearRecords}>确认清空</button></div></dialog>}
              </>
            )}
          </section>
        )}

        {screen === "culture" && (
          <section className="content-screen culture-screen" aria-labelledby="culture-title">
            <div className="section-heading compact">
              <p className="eyebrow">海洋信俗 · 人文传承</p>
              <h2 id="culture-title">妈祖文化</h2>
              <p>海不辞水，故能成其大。文化跨越海洋，也连接着人们对平安与善意的共同愿望。</p>
            </div>
            <div className="article-list">
              {CULTURE_ARTICLES.map((article, index) => (
                <article className={`article-card ${expandedArticle === index ? "open" : ""}`} key={article.title}>
                  <button onClick={() => setExpandedArticle(expandedArticle === index ? null : index)} aria-expanded={expandedArticle === index}>
                    <span className="article-marker">{article.marker}</span>
                    <span><strong>{article.title}</strong><small>{article.subtitle}</small></span>
                    <b>{expandedArticle === index ? "−" : "+"}</b>
                  </button>
                  {expandedArticle === index && <div className="article-body"><p>{article.body}</p><small>通识性简述 · 具体仪轨以当地宫庙传统及权威资料为准</small></div>}
                </article>
              ))}
            </div>
          </section>
        )}

        {screen === "about" && (
          <section className="content-screen about-screen" aria-labelledby="about-title">
            <div className="section-heading compact"><p className="eyebrow">透明、克制、尊重</p><h2 id="about-title">关于圣杯</h2><p>了解传统礼仪，也了解数字体验的边界。</p></div>
            <div className="about-grid">
              <article className="paper-card"><span className="number">01</span><h3>什么是筊杯？</h3><p>筊杯通常成对使用，形似弯月，是华人民间信俗中的礼仪器具。掷出后以杯面组合表达请示结果。</p></article>
              <article className="paper-card"><span className="number">02</span><h3>关于连续圣杯</h3><p>部分传统在重大事项中会以连续三次圣杯作为确认，但地区做法不一。本体验只模拟单次掷杯，不鼓励反复追问。</p></article>
              <article className="paper-card"><span className="number">03</span><h3>模拟规则</h3><p>程序分别模拟两枚筊杯的两个杯面：一平一凸、两平、两凸的概率约为 50%、25%、25%。结果生成后立即锁定，不按问题内容调整。</p></article>
              <article className="paper-card boundary-card"><span className="number">界</span><h3>体验边界</h3><p>本网站不提供算命、人生预测或玄学评分。它帮助用户短暂停顿、整理问题并了解传统文化。</p></article>
            </div>
            <button className="primary-button" onClick={() => navigate("ask")}><span>开始文化体验</span><b>→</b></button>
          </section>
        )}
      </div>

      <footer><span>妈祖 · 圣杯问心</span><p>传统文化数字体验 · 数据仅存于当前浏览器</p></footer>
    </main>
  );
}

function screenLabel(screen: Screen) {
  return { home: "首页", ask: "净心请示", ritual: "掷杯体验", result: "问心结果", records: "我的祈愿", culture: "妈祖文化", about: "体验说明" }[screen];
}
