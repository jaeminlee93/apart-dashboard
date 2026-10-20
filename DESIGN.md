# DESIGN.md — 신혼 전세 지도 디자인 시스템

원티드 [Montage](https://github.com/wanteddev/montage-web) (`@montage-ui/theme`)의 토큰 구조를 이 프로젝트(바닐라 HTML/CSS 단일 페이지, PC 지도 중심 대시보드)에 맞게 가져온 것이다.
Montage의 컴포넌트 라이브러리를 설치하지는 않고, **토큰 값과 규칙만 CSS 변수로 옮겨 쓴다.**

- 출처: `packages/theme/src/theme/{atomic,semantic,typography,radius,spacing,opacity,breakpoint}`
- 원칙: ① 색은 항상 **시맨틱 토큰**으로 쓴다(원색 hex 직접 사용 금지). ② 라이트/다크 모두 지원한다. ③ 파란 브랜드색은 "선택·행동"에만 쓰고, 점수 의미(좋음/주의)는 초록·주황 상태색으로 분리한다.

---

## 1. 색상

### 1.1 Atomic 팔레트 (Montage 원본값)

| 계열 | 사용 단계 |
|---|---|
| Blue | 40 `#0054D1` · 45 `#005EEB` · **50 `#0066FF`** · 55 `#1A75FF` · 60 `#3385FF` · 90 `#C9DEFE` · 95 `#EAF2FE` |
| Cool Neutral | 5 `#0F0F10` · 7 `#141415` · 15 `#1B1C1E` · 17 `#212225` · 22 `#2E2F33` · 23 `#333438` · 25 `#37383C` · 40 `#5A5C63` · 50 `#70737C` · 70 `#989BA2` · 90 `#C2C4C8` · 96 `#E1E2E4` · 97 `#EAEBEC` · 98 `#F4F4F5` · 99 `#F7F7F8` |
| Green | 40 `#009632` · **50 `#00BF40`** · 60 `#1ED45A` |
| Orange | **50 `#FF9200`** · 60 `#FFA938` |
| Red | 40 `#E52222` · **50 `#FF4242`** · 60 `#FF6363` |

### 1.2 Semantic 토큰 → CSS 변수

기존 `index.html`의 변수(`--bg`, `--panel`, `--ink`, …)를 아래 이름으로 교체한다. 괄호는 기존 변수와의 대응.

```css
:root {
  /* background / surface */
  --bg:            #F7F7F8;                    /* background.neutral.secondary (--bg) */
  --surface:       #FFFFFF;                    /* surface.neutral.primary (--panel) */
  --surface-sub:   rgba(112,115,124,.08);      /* surface.neutral.secondary (--chip) */
  --surface-faint: rgba(112,115,124,.05);      /* surface.neutral.tertiary */
  --surface-strong:rgba(112,115,124,.16);      /* surface.neutral.strong */
  --surface-brand-subtle: rgba(0,102,255,.05); /* surface.brand.subtle — 선택된 항목 배경 */

  /* foreground (text / icon) */
  --fg:            #171719;                    /* foreground.neutral.primary (--ink) */
  --fg-secondary:  rgba(46,47,51,.88);         /* secondary */
  --fg-tertiary:   rgba(55,56,60,.61);         /* tertiary (--muted) */
  --fg-quaternary: rgba(55,56,60,.28);         /* quaternary — placeholder */
  --fg-disable:    rgba(55,56,60,.16);
  --fg-inactive:   #989BA2;                    /* "데이터 없음" 구 (--none) */
  --fg-inverse:    #F7F7F8;

  /* brand */
  --brand:         #0066FF;                    /* foreground.brand.primary (--accent) */
  --brand-strong:  #005EEB;                    /* surface.brand.strong — hover */
  --brand-heavy:   #0054D1;                    /* surface.brand.heavy — pressed */

  /* status */
  --positive:      #00BF40;                    /* (--good) */
  --cautionary:    #FF9200;                    /* (--warn) */
  --negative:      #FF4242;
  --positive-bg:   rgba(0,191,64,.08);
  --cautionary-bg: rgba(255,146,0,.08);
  --negative-bg:   rgba(255,66,66,.08);
  --positive-line: rgba(0,191,64,.43);
  --cautionary-line: rgba(255,146,0,.43);
  --negative-line: rgba(255,66,66,.43);

  /* line */
  --line:          #E1E2E4;                    /* line.neutral.primaryOpaque (--line) */
  --line-sub:      #EAEBEC;                    /* secondaryOpaque — 목록 구분선 */
  --line-faint:    #F4F4F5;                    /* tertiaryOpaque */
  --line-brand:    rgba(0,102,255,.28);
  --focus-ring:    rgba(0,102,255,.12);        /* line.brand.focus */

  /* effect */
  --dimmer:        rgba(23,23,25,.52);
}

:root[data-theme="dark"], @media (prefers-color-scheme: dark) { /* 둘 다 같은 값 적용 */
  --bg:            #0F0F10;                    /* coolNeutral 5 */
  --surface:       #1B1C1E;                    /* coolNeutral 15 */
  --surface-sub:   rgba(112,115,124,.22);
  --surface-faint: rgba(112,115,124,.12);
  --surface-strong:rgba(112,115,124,.28);
  --surface-brand-subtle: rgba(51,133,255,.05);

  --fg:            #F7F7F8;
  --fg-secondary:  rgba(194,196,200,.88);
  --fg-tertiary:   rgba(174,176,182,.61);
  --fg-quaternary: rgba(174,176,182,.28);
  --fg-disable:    rgba(152,155,162,.16);
  --fg-inactive:   #5A5C63;
  --fg-inverse:    #171719;

  --brand:         #3385FF;
  --brand-strong:  #1A75FF;
  --brand-heavy:   #0066FF;

  --positive:      #1ED45A;
  --cautionary:    #FFA938;
  --negative:      #FF6363;
  --positive-bg:   rgba(30,212,90,.08);
  --cautionary-bg: rgba(255,169,56,.08);
  --negative-bg:   rgba(255,99,99,.08);
  --positive-line: rgba(30,212,90,.43);
  --cautionary-line: rgba(255,169,56,.43);
  --negative-line: rgba(255,99,99,.43);

  --line:          #37383C;                    /* coolNeutral 25 */
  --line-sub:      #333438;                    /* 23 */
  --line-faint:    #2E2F33;                    /* 22 */
  --line-brand:    rgba(51,133,255,.28);
  --focus-ring:    rgba(51,133,255,.12);
  --dimmer:        rgba(23,23,25,.74);
}
```

> 구현 시 다크 값은 `@media (prefers-color-scheme: dark) { :root { … } }` 하나로 쓴다(위 선택자 표기는 설명용).

### 1.3 지도 색상 (이 프로젝트 전용)

구 색칠은 **추천 점수 = 의미 있는 상태**이므로 브랜드 파랑이 아니라 상태색을 쓴다. 파랑은 "선택된 구" 외곽선·포커스에만 쓴다.

| 용도 | 토큰 | 비고 |
|---|---|---|
| 상위 점수 | `--positive` | 채움 투명도 `0.45`, 외곽선은 같은 색 100% |
| 중간 점수 | `--cautionary` | 동일 규칙 |
| 조건 미충족 / 데이터 없음 | `--fg-inactive` | 채움 `0.18` |
| 표본 적음 | 해당 점수색 + 점선 외곽선 | 색만으로 구분하지 않는다 |
| 선택된 구 | `--brand` 외곽선 2px | 채움은 그대로 |
| 호버 | 외곽선 `--line-brand` | |

색만으로 정보를 전달하지 않는다. 순위 목록의 점(dot)·범례에 **등급 텍스트(상/중/하)** 를 함께 쓴다.

---

## 2. 타이포그래피

Montage 스케일을 그대로 쓰되, 이 프로젝트에서 쓰는 단계만 추린다. 폰트는 **Pretendard** 우선(Montage가 쓰는 계열), 없으면 시스템 한글 폰트.

```css
font-family: "Pretendard Variable", Pretendard, -apple-system, BlinkMacSystemFont,
             "Apple SD Gothic Neo", "Malgun Gothic", "Noto Sans KR", sans-serif;
```

| 토큰 | size / line-height | letter-spacing | 굵기 (regular/medium/bold) | 이 프로젝트에서의 용도 |
|---|---|---|---|---|
| `title3` | 24 / 32px | -0.023em | 400/500/**700** | 페이지 제목 |
| `heading2` | 20 / 28px | -0.012em | 400/500/**600** | 구 상세 패널의 구 이름 |
| `headline1` | 18 / 26px | -0.002em | 400/500/**600** | 섹션 제목 ("생활 인프라") |
| `headline2` | 17 / 24px | 0 | 400/500/**600** | 종합 점수 숫자 |
| `body1` | 16 / 24px | 0.0057em | 400/500/600 | 기본 본문 |
| `body2` | 15 / 22px | 0.0096em | 400/500/600 | 순위 목록, 상세 패널 본문 |
| `body2-reading` | 15 / 24px | 0.0096em | 〃 | 한 줄 요약 문구 등 줄글 |
| `label1` | 14 / 20px | 0.0145em | 400/**500**/600 | 버튼, 필터 세그먼트, 입력 라벨 |
| `label2` | 13 / 18px | 0.0194em | 〃 | 칩, 통계 항목 라벨 |
| `caption1` | 12 / 16px | 0.0252em | 〃 | 안내 문구, 출처, 범례 |
| `caption2` | 11 / 14px | 0.0311em | 〃 | 지도 위 구 이름 라벨 |

규칙
- 가격·점수 등 숫자는 `font-variant-numeric: tabular-nums`.
- 한글 줄바꿈은 `word-break: keep-all`.
- 본문 최소 크기는 `caption2`(11px) 이상. 핵심 정보(가격, 점수)는 `body2` 이상.
- 굵기는 3단계만: 일반 400 / 강조 500 / 제목 600(heading~label) · 700(title~display).

---

## 3. 간격 · 반경 · 그림자

### 간격 (Spacing, px)
`0 · 2 · 4 · 6 · 8 · 10 · 12 · 14 · 16 · 20 · 24 · 32 · 40 · 48 · 56 · 64 · 72 · 80`

| 용도 | 값 |
|---|---|
| 아이콘-텍스트, 칩 내부 | 4 · 6 |
| 컨트롤 내부 패딩 | 8 · 12 |
| 카드/패널 내부 패딩 | 16 (넓은 패널 20) |
| 섹션 사이 | 24 |
| 사이드바와 지도 사이 | 0 (구분선만) |

### 반경 (Radius, px)
`0 · 4 · 8 · 10 · 12 · 14 · 16 · 20 · 24 · 28 · 32 · full`

| 요소 | 반경 |
|---|---|
| 막대 그래프 바, 작은 인디케이터 | 4 |
| 버튼, 입력, 세그먼트, 목록 항목 | 8 |
| 통계 박스, 경고 박스 | 8–10 |
| 점수 카드, 상세 패널 카드 | 12 |
| 칩, 범례 점, 라디오 점 | full |

### 그림자 (Elevation)
Montage `shadow.normal` 값을 쓴다. 기본 화면은 **그림자 없이 선(line)으로 구분**하고, 떠 있는 요소에만 쓴다.

| 토큰 | 값 | 용도 |
|---|---|---|
| `shadow-xsmall` | `0 1px 2px -1px rgba(23,23,25,.10)` | 지도 위 작은 컨트롤 |
| `shadow-small` | `0 2px 4px -2px rgba(23,23,25,.06), 0 4px 6px -1px rgba(23,23,25,.06)` | 호버 카드, 툴팁 |
| `shadow-medium` | `0 4px 6px -2px rgba(23,23,25,.07), 0 10px 15px -3px rgba(23,23,25,.07)` | 지도 위 떠 있는 상세 패널 |

다크 모드에서는 그림자를 쓰지 않고 `--surface` → `--surface-sub` 단차와 `--line`으로 구분한다.

### 투명도 단계
`0 · .05 · .08 · .12 · .16 · .22 · .28 · .35 · .43 · .52 · .61 · .74 · .88 · .97 · 1` — 임의 값(예: 0.3, 0.5)을 만들지 말고 이 단계에서 고른다.

---

## 4. 레이아웃

- 대상은 **PC 웹**. 모바일 최적화는 범위 밖(PRD §4).
- 브레이크포인트(Montage): `sm 768` · `md 992` · `lg 1200` · `xl 1600`. 기본 설계 기준은 `lg`(1200px) 이상, 992 미만에서는 사이드바를 접는다.
- 구조: 좌측 사이드바(고정 폭 360px: 필터·순위·상세) + 우측 지도(나머지 전부). 사이드바 안 스크롤은 내부에서만 한다.
- z-index: 지도 0 → 지도 컨트롤 400 → 사이드바 500 → 툴팁/팝오버 1000 → 모달 2000.

---

## 5. 컴포넌트 규칙

공통: 포커스는 `outline: 2px solid var(--brand); outline-offset: 2px` 또는 `box-shadow: 0 0 0 3px var(--focus-ring)`. 전환은 `120–160ms ease-out`, `prefers-reduced-motion`에서는 끈다.

### 버튼 / 세그먼트 (전세·반전세 토글)
- 높이 36px, 패딩 0 12px, `label1` medium, 반경 8.
- 기본: 배경 `--surface`, 글자 `--fg-secondary`, 테두리 `1px --line`.
- 선택: 배경 `--surface-brand-subtle`, 글자·테두리 `--brand` (`--line-brand`). 채운 파란 버튼은 화면당 주요 행동 1개일 때만.
- hover: 배경 `--surface-faint`. disabled: 글자 `--fg-disable`, 배경 `--surface-faint`.

### 칩 (태그)
- `label2`, 패딩 2px 10px, 반경 full, 배경 `--surface-sub`, 글자 `--fg-secondary`.
- 의미 칩(표본 적음 등): 배경 `--cautionary-bg`, 글자 `--cautionary`, 테두리 `--cautionary-line`.

### 순위 목록
- 항목 높이 40px 이상, 패딩 8px 12px, 반경 8, 항목 사이 구분선 `--line-sub`.
- hover `--surface-faint`, 선택 `--surface-brand-subtle` + 좌측 점수 등급 점.
- 구성: `[순위] [점수 점] 구 이름 …… 점수` — 점수는 `tabular-nums`, 우측 정렬.

### 카드 (점수, 통계)
- 배경 `--surface-sub`, 반경 12(점수) / 8(통계), 패딩 12–16, 테두리 없음.
- 통계 항목: 위 `caption1` `--fg-tertiary` 라벨, 아래 `body2` medium 값.

### 점수 막대
- 높이 8px, 반경 4, 트랙 `--line`, 채움 `--brand`(요소별 기여도) 또는 점수 등급색. 한 막대에는 한 색만 쓴다.
- 막대 옆에 항상 숫자를 같이 쓴다.

### 경고/안내 박스
- "표본 적음", "실거래가는 현재 매물가와 다를 수 있어요" 등.
- 배경 `--cautionary-bg`, 테두리 `1px --cautionary-line`, 반경 8, 패딩 8px 12px, `caption1`. 아이콘(!) 병행.
- 오류는 `--negative-*`, 성공/충족은 `--positive-*` 동일 규칙.

### 입력 / 셀렉트
- 높이 36px, 반경 8, 테두리 `1px --line`, 배경 `--surface`. focus 시 테두리 `--brand` + `--focus-ring`.

### 지도 라벨·툴팁
- 구 이름: `caption2` medium, 글자 `--fg`, 흰색(또는 `--surface`) 외곽 글로우 2px로 가독성 확보.
- 툴팁: 배경 `--surface`, `shadow-small`, 반경 8, 패딩 8px 12px, `label2`.

---

## 6. 문구 톤 (PRD §5-1 연계)

- 해요체, 짧게. "걸어서 해결돼요", "이동이 필요할 수 있어요".
- 숫자는 단위와 기준을 같이: "마트·편의점 5곳 (반경 500m 평균)", "전세 평균 2억 6천만 원 · 12건".
- 금액 표기: 억/만 원 단위로 풀어 쓰고 천 단위 쉼표는 만 원 단위 이하에서만 (`2억 6,500만 원`).
- 불확실성은 숨기지 않는다: 표본 적음, 구 평균 한계, 실거래 vs 매물가 차이를 항상 표시.

---

## 7. 접근성

- 본문 대비 4.5:1 이상. `--fg-tertiary` 이하 단계는 보조 정보에만 쓰고 핵심 수치에 쓰지 않는다.
- 색 단독 전달 금지(점수 등급은 색 + 텍스트/패턴).
- 모든 인터랙션 요소는 키보드 포커스 가능, 포커스 링 항상 보이게.
- 지도 구 클릭은 순위 목록으로도 동일하게 선택할 수 있어야 한다.

---

## 8. 적용 체크리스트 (`index.html` 마이그레이션)

1. `:root` 변수를 §1.2 이름으로 교체 (`--panel`→`--surface`, `--ink`→`--fg`, `--muted`→`--fg-tertiary`, `--accent`→`--brand`, `--good`→`--positive`, `--warn`→`--cautionary`, `--none`→`--fg-inactive`, `--chip`→`--surface-sub`).
2. 다크 모드 값을 Montage 다크 시맨틱 값으로 교체.
3. 폰트를 Pretendard 스택으로, 크기를 §2 스케일에 맞춤.
4. 반경을 4/8/12/full 로 정리, 그림자는 떠 있는 요소에만.
5. 지도 구 색칠을 §1.3 규칙(상태색 + 점선 + 텍스트 등급)으로 정리.
