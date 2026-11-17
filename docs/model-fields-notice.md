# 공지: JournalDatabase에 시안 B 필드가 추가됐습니다

공통 모델·필터 담당이 모델에 새 필드를 추가해 `main`에 반영했습니다. (`main` 커밋: `df84b38`)

## 먼저 해야 할 일: `main`을 내 브랜치에 합쳐 주세요

모델 코드는 `main`이 기준입니다. 각자 작업 브랜치에서 아래 순서로 `main`을 받아 주세요.

```bash
git fetch origin
git switch <내 작업 브랜치>
git merge origin/main
```

- 합치기 전에 커밋하지 않은 변경이 있으면 먼저 커밋하거나 `git stash`로 치워 두세요.
- `main`에는 직접 푸시하지 않습니다. 합치는 방향은 `main`에서 내 브랜치로 한 방향입니다. 완성 후의 `main` 반영은 한 번에 PR로 진행합니다.
- 충돌이 나면 임의로 한쪽을 고르지 말고 팀 채팅에 먼저 알려 주세요. 충돌이 나기 쉬운 파일은 `Journal/Models/JournalDatabase.swift`입니다. 이 파일에서는 클래스 본문의 새 필드(아래 표)를 반드시 남기고, 각자 추가한 내용(예: 샘플 데이터)도 함께 남겨야 합니다.
- 합친 뒤에는 Xcode에서 빌드가 통과하는지 확인해 주세요.

## 추가된 필드

`Journal/Models/JournalDatabase.swift`의 클래스 본문에 추가했습니다. 모두 기본값 또는 선택값입니다.

| 필드 | 타입 | 기본값 | 의미 |
| --- | --- | --- | --- |
| `format` | `ReflectionFormat` (`free`, `tomorrow`, `fourL`) | `.free` | 회고 형식 |
| `answers` | `[ReflectionAnswer]` (`question`, `text`) | `[]` | 질문별 답변 (`tomorrow`, `fourL`일 때 사용) |
| `isPeriod` | `Bool` | `false` | `false`는 하루 회고, `true`는 기간 회고 |
| `startDate` | `Date?` | `nil` | 기간 시작일 |
| `endDate` | `Date?` | `nil` | 기간 종료일 |
| `photoData` | `Data?` (`@Attribute(.externalStorage)`) | `nil` | 사진 한 장. 공식 문서 기준으로 모델 저장소 옆의 별도 이진 데이터로 저장됩니다. |

`ReflectionFormat`과 `ReflectionAnswer`의 타입 정의는 `Journal/Models/JournalDatabase+ReflectionFormat.swift`에 있습니다. 코드에서는 `JournalDatabase.ReflectionFormat`, `JournalDatabase.ReflectionAnswer`로 씁니다.

## 기존 코드에 미치는 영향

- 기존 필드(`title`, `content`, `createdAt`, `category`, `tags`)의 이름과 타입은 바뀌지 않았습니다.
- 기존 `JournalDatabase(title:content:category:tags:)` 호출은 수정 없이 그대로 동작합니다. 새 매개변수는 모두 기본값이 있고 뒤에 붙어 있습니다.
- `createdAt`은 기간 용도가 아닙니다. 주·월별 통계는 그대로 `createdAt`을 쓰고, 기간은 `startDate`, `endDate`를 씁니다.
- 새 저장 필드는 클래스 본문에만 추가할 수 있습니다. 확장(extension)에는 저장 프로퍼티를 넣을 수 없습니다(Swift 규칙).

## 역할별로 확인할 점

| 역할 | 확인할 점 |
| --- | --- |
| 작성·편집 | `tomorrow`, `fourL`은 본문 대신 답변에 내용이 들어갈 수 있어서, 현재의 "제목 또는 본문이 비면 저장 불가" 조건을 형식에 맞게 조정해야 합니다. |
| 목록·상세 | 키워드 검색 범위(제목, 본문, 카테고리, 태그)에 답변을 넣을지 정해 주세요. |
| 기간·사진 입력 | `isPeriod`, `startDate`, `endDate`, `photoData`에 값을 채워 작성폼에 전달해 주세요. 종료일이 시작일보다 빠를 때의 저장 방지도 이 역할이 맡습니다. |
| 통계 | 변경 없음. `createdAt`과 `tags`를 그대로 사용합니다. |
| 공통 모델·필터 | 기존 글과 새 글이 카테고리·태그 필터로 모두 찾아지는지 확인합니다. |

## 주의

- 모델 구조가 바뀌었습니다. 시뮬레이터에 이미 저장된 옛 글이 이상하게 보이거나 앱이 꺼지면, 앱을 지우고 다시 설치해 주세요. 이런 증상이 있으면 팀 채팅에 알려 주세요.
- 필드 이름이나 타입을 바꾸고 싶으면 코드를 바꾸기 전에 팀 채팅에 먼저 남겨 주세요. 모두의 코드가 같이 바뀌어야 합니다.
