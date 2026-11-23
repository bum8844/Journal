# 마이로그 (MyLog)

하루 또는 일정 기간의 경험을 기록하고, 질문에 답하며 돌아보는 iOS 회고 앱입니다. SwiftUI로 화면을 만들고 SwiftData로 기기 안에 저장합니다. 작성한 글은 기기 밖으로 나가지 않습니다.

- 이름: 마이로그 (홈 화면에 보이는 앱 이름)
- 대상: iPhone, iPad
- 기술: Swift, SwiftUI, SwiftData, Foundation Models(AI 한마디), UserNotifications(종료 알림)

## 목차

1. [주요 기능](#주요-기능)
2. [사용법](#사용법)
3. [개발 환경과 실행](#개발-환경과-실행)
4. [폴더 구성](#폴더-구성)
5. [변수 연결](#변수-연결)
6. [팀 구성](#팀-구성)
7. [참고 문서](#참고-문서)

## 주요 기능

| 기능 | 설명 |
| --- | --- |
| 세 가지 작성 형식 | `오늘의 경험`(좋았던 점·배운 점·아쉬웠던 점·바라는 점), `내일을 위한 정리`(내일 해볼 한 가지·미리 챙길 것·내일의 나에게), `자유`(본문 한 칸) |
| 하루·기간 회고 | 하루는 날짜 하나를, 기간은 시작일과 종료일을 고릅니다. 기간 회고는 앞으로 시작할 기간(미래 날짜)도 쓸 수 있습니다. |
| 사진·중요도 | 사진 한 장을 붙이거나 바꾸거나 뺄 수 있고, 중요도(1 높음, 2 보통, 3 낮음)를 정합니다. |
| 분류·태그·검색 | 카테고리 한 개와 태그 여러 개를 붙이고, 제목·본문·카테고리·태그로 검색합니다. 카테고리와 태그를 함께 걸어 거르고, 분류가 없거나 태그가 없는 글만 따로 볼 수 있습니다. |
| 목록 | 작성일별 구간(오늘, 어제, 날짜)으로 나누어 보여 주고, 카드에서 태그·사진·중요도를 확인합니다. |
| 통계 | 주간·월간 기록 건수와 날짜별 분포, 하루·기간·사진·중요도별 집계, 기간 회고의 예정·진행 중·종료 구분, 분류·태그 미등록 글, 자주 쓴 태그, 카테고리 비율 |
| AI 한마디 | 회고를 쓴 뒤 요청하면 기기 안의 Apple Intelligence 모델이 다음에 해볼 행동을 한국어로 제안합니다. 결과는 글과 함께 저장됩니다. |
| 기간 종료 알림 | 중요도 1단계인 기간 회고는 종료일에 알림을 보냅니다. 낮 12시 한 번, 또는 09:00부터 21:00까지 3시간 간격 중에서 고릅니다. |
| 설정 | 화면 테마(시스템·라이트·다크), 글자 크기, 화면 밝기, 종료일 알림 방식 |
| 시작 화면·아이콘 | 시스템 시작 화면과 앱 안 커버, 라이트·다크 앱 아이콘 |

## 사용법

앱 하단에 `회고`, `통계`, `설정` 탭이 있습니다.

### 1. 회고 쓰기

1. `회고` 탭 오른쪽 위의 `+` 버튼을 누릅니다. 목록이 비어 있으면 `회고 추가하기` 버튼을 누릅니다.
2. 위쪽 탭에서 작성 형식을 고릅니다. 형식마다 질문 카드가 다릅니다. `자유`는 본문 한 칸입니다.
3. 제목을 입력하고 내용을 씁니다. 제목과 본문(또는 한 개 이상의 답변)이 있어야 저장할 수 있습니다.
4. 날짜에서 `하루`나 `기간`을 고릅니다.
   - 하루 회고는 오늘까지의 날짜를 고를 수 있습니다.
   - 기간 회고는 시작일과 종료일을 고릅니다. 종료일은 시작일보다 빠를 수 없고, 미래 날짜도 가능합니다.
5. 중요도를 고릅니다. 기간 회고에서 `1 · 높음`을 고르면 종료일 알림 시각 안내가 나옵니다.
6. 사진이 있으면 `사진`에서 한 장을 고릅니다.
7. 카테고리를 입력하거나 추천 칩에서 고릅니다. 비워 두면 `분류없음`으로 저장됩니다. 태그는 입력 후 `추가`를 누르고, 선택한 태그를 다시 누르면 지워집니다.
8. 필요하면 `AI 한마디 생성`을 눌러 제안을 받습니다. Apple Intelligence를 쓸 수 없는 환경에서는 사유가 안내됩니다.
9. 오른쪽 위의 `저장`을 누릅니다.

### 2. 찾아보기

- 목록은 작성일 기준 최신순이고 `오늘`, `어제`, `11월 17일`처럼 구간 제목이 붙습니다.
- 카드에는 기간 회고만 `시작일 ~ 종료일`이 나옵니다. 하루 회고는 구간 제목이 작성일을 알려 주고, 고른 날짜가 작성일과 다를 때만 `2026년 10월 9일 회고`로 나옵니다.
- 검색창에 제목, 본문, 카테고리, 태그를 입력해 찾습니다.
- 카테고리 칩과 태그 칩을 눌러 거릅니다. 태그를 여러 개 고르면 모두 가진 글만 남습니다. `태그 없음` 칩은 태그가 없는 글만 보여 주고, 개별 태그와 같이 쓸 수 없습니다.
- 카드를 누르면 상세 화면이 열리고, 상세에서 수정과 삭제를 할 수 있습니다.

### 3. 수정과 삭제

- 상세 화면에서 수정하면 작성 화면이 같은 값으로 채워집니다. 저장한 글은 작성 형식을 바꿀 수 없습니다. 형식을 바꾸면 기존 내용이 사라지기 때문입니다.
- 삭제는 목록 카드를 왼쪽으로 밀거나 상세 화면의 삭제 버튼을 누릅니다. 상세에서는 확인 창이 한 번 나옵니다.

### 4. 통계 보기

- `통계` 탭에서 `주간`(월요일부터 일요일)과 `월간`을 고르고, 화살표로 이전·다음 기간으로 이동합니다. 집계 기준은 작성일입니다.
- `미등록`의 `분류`, `태그`를 누르면 해당 글만 모아서 볼 수 있습니다. 0건인 항목은 흐리게 보이고 눌리지 않습니다.

### 5. 설정

- `화면 테마`, `글자 크기`, `종료일 알림 시각`, `화면 밝기`를 바꿉니다. 값은 기기에 저장되어 앱을 다시 켜도 유지됩니다.

## 개발 환경과 실행

| 항목 | 값 |
| --- | --- |
| IDE | Xcode |
| 언어·UI | Swift, SwiftUI |
| 저장소 | SwiftData |
| 배포 대상 | iOS 27.2 (iPhone, iPad) |
| 번들 ID | `com.acb.Journal` |
| 프로젝트 파일 | `Journal.xcodeproj` |

실행 방법

1. 저장소를 받고 `Journal.xcodeproj`를 Xcode로 엽니다.
2. 실행할 기기(iPhone 또는 iPad 시뮬레이터, 실제 기기)를 고르고 실행(`⌘R`)합니다.
3. 종료일 알림은 처음 저장할 때 알림 권한을 요청합니다.
4. `AI 한마디`는 Apple Intelligence가 켜진 지원 기기에서 동작합니다. 시뮬레이터에서는 모델이 준비되지 않아 안내 문구만 나올 수 있습니다.

앱 이름이나 시작 화면은 `Journal/Info.plist`와 프로젝트 설정(`Journal.xcodeproj/project.xcproj`)에 있습니다.

## 폴더 구성

```
Journal/                         저장소 루트
├── README.md                    이 문서
├── Journal.xcodeproj/           Xcode 프로젝트
├── Design/                      화면 시안(HTML 목업)
├── docs/                        팀 공유 문서(모델 안내, QA 기록, 인수인계)
└── Journal/                     앱 소스
    ├── JournalApp.swift         앱 시작점. 저장소(ModelContainer), 테마·글자 크기·밝기, 시작 커버 연결
    ├── ContentView.swift        하단 탭(회고·통계·설정)과 알림으로 앱을 열었을 때의 이동
    ├── JournalEditorView.swift  작성·수정 화면. 입력값을 모아 JournalDatabase에 저장
    ├── JournalCategory.swift    카테고리 이름 규칙(빈 값·"미분류"를 "분류없음"으로 통일)
    ├── JournalTag.swift         태그 정리 규칙(공백·앞의 # 제거)과 태그 유무 판단
    ├── ReflectionStatistics*.swift  통계 집계(Statistics), 차트(Charts), 화면(View)
    ├── ThemeSettingsView.swift  설정 탭 화면과 화면 테마(AppTheme) 정의
    ├── DisplaySettings.swift    글자 크기·밝기 설정과 저장 키
    ├── Info.plist               시작 화면(UILaunchScreen) 설정
    ├── Models/                  데이터 모델
    │   ├── JournalDatabase.swift                회고 한 건의 저장 필드(SwiftData @Model)
    │   ├── JournalDatabase+ReflectionFormat.swift  회고 형식·답변 타입, 대상 날짜(reviewDate)
    │   ├── JournalDatabase+Classification.swift    카테고리·태그 정리와 필터 규칙
    │   ├── JournalDatabase+Samples.swift        Xcode 프리뷰용 샘플
    │   ├── ReflectionFormat+Display.swift       형식 이름과 형식별 질문
    │   ├── ReflectionImportance.swift           중요도(1·2·3)
    │   └── JournalDeletion.swift                삭제와 저장 실패 시 되돌리기
    ├── Views/
    │   ├── List/                목록 화면, 검색창, 카드, 작성일 구간(JournalDaySection)
    │   ├── Detail/              상세 화면
    │   ├── Editor/              작성 화면 부품(형식 탭, 안내 배너, 질문 카드)
    │   ├── Components/          공용 부품(칩, 분류 선택, 필터 바, 기간·사진·중요도 입력, 배지)
    │   └── LaunchCoverView.swift  앱이 켜진 직후 잠깐 보이는 커버
    ├── AI/                      AI 한마디 입력 만들기와 생성
    ├── Notifications/           기간 종료 알림(계획, 예약, 알림에서 앱 열기)
    ├── Theme/                   색과 배경, 유리 카드 같은 공통 디자인(JournalTheme)
    ├── Extensions/              날짜 한국어 표시, 목록 카드 날짜 규칙
    └── Assets.xcassets/         앱 아이콘, 시작 화면, 테마 색상(라이트·다크)
```

## 변수 연결

### 1. 저장 데이터: `JournalDatabase`

회고 한 건은 SwiftData 모델 `JournalDatabase`로 저장합니다. 작성, 목록, 상세, 통계가 모두 이 모델을 읽습니다. 변수와 함수 이름은 `lowerCamelCase`, 타입 이름은 `UpperCamelCase`를 씁니다.

| 프로퍼티 | 타입 | 의미 |
| --- | --- | --- |
| `id` | `UUID` | 회고 식별자. 알림과 삭제가 이 값으로 글을 찾습니다. |
| `title` | `String` | 제목 |
| `content` | `String` | 본문. 형식 회고는 질문 제목과 답변을 합쳐서 저장해 목록·검색·상세가 그대로 읽습니다. |
| `createdAt` | `Date` | 최초 작성 시각. 수정해도 유지하고, 목록 구간과 통계 집계에 씁니다. |
| `category` | `String` | 카테고리 한 개. 비어 있으면 `분류없음`으로 다룹니다. |
| `tags` | `[String]` | 태그 여러 개. 없으면 빈 배열 |
| `format` | `ReflectionFormat?` | 작성 형식(`free`, `tomorrow`, `fourL`). 값이 없으면 자유 형식 |
| `answers` | `[ReflectionAnswer]` | 질문 이름(`question`)과 답변(`text`). 자유 형식은 빈 배열 |
| `isPeriod` | `Bool` | `false`는 하루 회고, `true`는 기간 회고 |
| `startDate` | `Date?` | 하루 회고는 선택한 날짜, 기간 회고는 시작일 |
| `endDate` | `Date?` | 기간 회고의 종료일. 하루 회고는 비움 |
| `photoData` | `Data?` | 사진 한 장 (DB 밖 파일로 저장) |
| `importance` | `ReflectionImportance?` | 중요도. 값이 없으면 `보통` |
| `aiComment` | `String?` | 저장한 AI 한마디 |

값이 없을 수 있는 필드는 이전 버전에서 저장한 글을 읽어도 앱이 멈추지 않게 옵셔널로 두었습니다. 읽을 때는 빈 값을 처리하는 계산 프로퍼티를 씁니다.

| 계산 프로퍼티 | 값 | 쓰는 곳 |
| --- | --- | --- |
| `effectiveFormat` | `format ?? .free` | 작성 화면, 상세 |
| `effectiveImportance` | `importance ?? .normal` | 카드 배지, 알림, 통계 |
| `reviewDate` | `startDate ?? createdAt` | 상세 날짜 표시 |
| `listDateText` | 기간이면 `시작일 ~ 종료일`, 하루는 선택일이 작성일과 다를 때만 | 목록 카드 |

### 2. 작성 화면 상태와 모델 필드

`JournalEditorView`가 입력값을 `@State`로 들고 있다가 저장할 때 모델에 옮깁니다. 수정할 때는 모델 값으로 상태를 채웁니다.

| 작성 화면 상태 | 모델 필드 | 메모 |
| --- | --- | --- |
| `title` | `title` | 앞뒤 공백 제거 |
| `content` | `content` | 자유 형식일 때만 사용 |
| `format` | `format` | 저장한 글은 탭이 잠깁니다. |
| `answersByFormat[format]` | `answers`, `content` | 형식마다 답변을 따로 들고 있어 형식을 바꿔도 섞이지 않습니다. 저장할 때 질문 제목과 답변을 합쳐 `content`에도 넣습니다. |
| `period` (`JournalPeriodValue`) | `isPeriod`, `startDate`, `endDate` | 하루 회고는 `endDate`를 저장하지 않습니다. |
| `photoData` | `photoData` | |
| `importance` | `importance` | |
| `category`, `tags`, `tagInput` | `category`, `tags` | 저장할 때 입력창에 남은 태그도 반영합니다. 빈 카테고리는 `분류없음`으로 저장합니다. |
| `aiComment` | `aiComment` | 입력 내용과 생성 당시 입력이 같을 때만 저장합니다. |

### 3. 화면이 읽는 필드

| 화면 | 읽는 값 | 규칙 |
| --- | --- | --- |
| 목록 (`JournalListView`) | `@Query`로 `createdAt` 내림차순 | 검색과 필터는 `JournalDatabase.filter(...)`, 구간은 `JournalDaySection`이 `createdAt`으로 묶음 |
| 카드 (`JournalCardView`) | `title`, `category`, `tags`, `photoData`, 중요도 | 날짜는 `listDateText` |
| 상세 (`JournalDetailView`) | 모든 필드 | 날짜는 기간이면 `시작일 ~ 종료일`, 하루는 `reviewDate` |
| 통계 (`ReflectionStatisticsView`) | `createdAt`이 선택한 주·월 안에 있는 글 | `StatisticsEntry`로 필요한 값만 옮겨 `ReflectionStatistics`가 집계 |
| 알림 (`PeriodReminderScheduler`) | `id`, `title`, `isPeriod`, 중요도, `endDate` | 기간 회고이면서 중요도 1이고 종료일이 있을 때만 대상 |
| AI (`ReflectionCommentGenerator`) | 형식 이름, 제목, 본문 | `ReflectionCommentInput`이 공백 정리와 길이 제한을 합니다. |

### 4. 분류·태그 정리 규칙

저장, 표시, 필터, 통계가 같은 규칙을 씁니다.

- `JournalCategory.normalized(_:)`: 앞뒤 공백을 지우고, 빈 값과 `미분류`를 `분류없음`으로 통일합니다.
- `JournalTag.normalized(_:)`: 공백과 앞의 `#`을 지웁니다. 빈 값이면 태그로 보지 않습니다.
- `JournalTag.hasNone(_:)`: 실제 태그가 하나도 없는지 판단합니다. `태그 없음` 필터와 통계가 같은 판단을 씁니다.

### 5. 설정 저장 키 (`@AppStorage`)

설정은 회고 데이터와 달리 `UserDefaults`에 저장합니다.

| 키 | 타입 | 기본값 | 쓰는 곳 |
| --- | --- | --- | --- |
| `appTheme` | `AppTheme` (`system`, `light`, `dark`) | `system` | `JournalApp`이 읽어 화면 전체에 적용, 설정 탭이 변경 |
| `appTextSize` | `AppTextSize` | `system` | `AppTextSizeModifier` |
| `usesCustomBrightness` | `Bool` | `false` | 직접 밝기 조절 여부 |
| `appBrightness` | `Double` | `0.5` | 직접 조절한 밝기 |
| `periodEndReminderMode` | `PeriodEndReminderMode` (`noon`, `everyThreeHours`) | `noon` | 작성 화면 안내, 설정, 알림 예약 |

### 6. 데이터 흐름

```
JournalApp
 ├─ .modelContainer(for: JournalDatabase.self)  ← 저장소를 모든 화면에 제공
 └─ ContentView ── 회고 탭 ── JournalListView ──(카드)→ JournalDetailView
        │                          │  └─ + 버튼 ────→ JournalEditorView
        │                          └─ @Query(createdAt 내림차순) → 검색·필터 → 작성일 구간
        ├─ 통계 탭 ── ReflectionStatisticsView ── @Query → StatisticsEntry → ReflectionStatistics
        └─ 설정 탭 ── ThemeSettingsView ── @AppStorage(appTheme 등)

JournalEditorView
 ├─ 저장 ──→ modelContext.save() ──→ PeriodReminderScheduler.reconcile(id)  (종료일 알림 맞춤)
 └─ AI 한마디 ──→ ReflectionCommentInput ──→ ReflectionCommentGenerator ──→ aiComment

삭제(목록 스와이프·상세) ──→ JournalDeletion.delete ──→ 저장 성공 시 알림 정리
```

- 저장, 수정, 삭제는 모두 같은 `ModelContext`로 하고, `@Query`가 바뀐 결과를 목록과 통계에 자동으로 반영합니다.
- 알림은 저장이 끝난 뒤에만 맞춥니다. 저장이 실패하면 변경을 되돌리고 기존 알림을 유지합니다.

## 팀 구성

3조 (GitCode)

| 이름 | 역할 |
| --- | --- |
| 안창범 | 팀장, Git 관리 |
| 김지혜 | 서기, 목록·상세 |
| 추규아 | UI 디자인, 분류 |
| 정연규 | 발표, 통계·설정 |

## 참고 문서

`docs/` 폴더에 팀이 주고받은 안내와 QA 기록이 있습니다.

| 문서 | 내용 |
| --- | --- |
| `docs/model-fields-notice.md` | 모델 필드 추가 안내와 하루 회고 날짜 규칙 |
| `docs/qa-checklist.md` | 통합 QA 체크리스트 |
| `docs/ai-comment-team-handoff.md` | AI 한마디 인수인계 |
| `docs/statistics-settings-integration.md` | 통계·설정 연결 안내 |
| `docs/period-photo-integration.md`, `docs/editor-period-photo-handoff.md` | 기간·사진 입력 연결 안내 |
| `docs/qa-*.md` | 기능별 QA 기록 |
