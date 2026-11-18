# 작성·편집 담당자용 기간·사진 연결 안내

작성폼인 `Journal/JournalEditorView.swift`에 기간·사진 입력을 연결할 때 사용합니다. 두 입력 뷰는 [팀 작업 브랜치 `work/yeongyu`](https://github.com/bum8844/Journal/tree/work/yeongyu)에 있습니다. 전체 역할과 날짜 합의 사항은 [기간·사진 연동 안내](period-photo-integration.md), 저장 타입은 [공통 모델 공지](model-fields-notice.md)를 참고하세요.

## 1. 작성폼 상태와 초기화

기존 `JournalEditorView`에 상태를 추가하고, 현재 `init(journal:)` 안에서 초기화하는 예시입니다. `journal == nil`이면 새 회고, 값이 있으면 편집입니다.

```swift
@State private var period: JournalPeriodValue
@State private var photoData: Data?
```

```swift
// 기존 init(journal:) 내부
_period = State(initialValue: JournalPeriodValue(
    isPeriod: journal?.isPeriod ?? false,
    startDate: journal?.startDate ?? journal?.createdAt,
    endDate: journal?.endDate
))
_photoData = State(initialValue: journal?.photoData)
```

날짜가 없는 새 회고는 오늘 하루로 열립니다. 기존 글은 저장된 날짜부터 사용하고, 값이 없으면 최초 작성일을 보여줍니다. 작성 중 선택값은 `@State`에 두고 저장할 때 모델에 반영하면 편집 취소 시 원래 데이터가 유지됩니다.

## 2. 화면 연결과 저장 버튼

작성폼의 기존 `VStack`에서 팀이 정한 위치에 아래 두 뷰를 한 번씩 붙입니다.

```swift
JournalPeriodPicker(value: $period)
JournalPhotoPicker(photoData: $photoData)
```

| 연결 값 | 작성폼이 확인할 내용 |
| --- | --- |
| `period.isValid` | 기존 제목·내용 검사와 함께 사용합니다. KPT·4L은 자유 본문 대신 질문별 답변을 검사하는 기준을 작성 담당에서 정합니다. |
| `period.savedEndDate` | 하루 모드에서 `nil`이며, 기간 모드에서는 선택한 종료일입니다. |
| `photoData: Data?` | 선택 또는 교체가 완료되면 새 값이 들어오고, 제거하면 `nil`이 됩니다. 취소·불러오기 실패 시 기존 값이 유지됩니다. |

```swift
// 저장 버튼
.disabled(!isValid || !period.isValid)

// save() 첫 줄
guard isValid, period.isValid else { return }
```

사진 변환은 비동기입니다. 사진을 고른 직후 로딩이 끝나기 전에 저장할 수 있는지 통합 시 확인하세요. 저장 버튼을 로딩 중에 막아야 한다면, 사진 입력 뷰에서 작성폼에 로딩 상태를 전달하는 방식은 입력 뷰 담당과 맞춥니다.

## 3. 기존 save()에 모델 매핑

아래 대입은 기존 `let target = journal ?? JournalDatabase(...)` 다음, `modelContext.save()` 전에 둡니다. 현재의 신규 삽입과 편집 저장, 오류 시 롤백 흐름을 이어서 사용합니다.

```swift
target.isPeriod = period.isPeriod
target.startDate = period.isPeriod ? period.startDate : nil
target.endDate = period.savedEndDate
target.photoData = photoData
```

- **하루 선택일 저장은 팀 결정 대기 중입니다.** 위 예시는 공지대로 `startDate`를 기간 시작일에만 사용하는 경우입니다. 하루도 `startDate`에 저장하기로 합의하면 대입을 `target.startDate = period.startDate`로 바꿉니다. 합의 전에는 하루 날짜 선택을 최종 저장 기능으로 안내하지 않습니다.
- 회고 형식은 기존 모델의 `JournalDatabase.ReflectionFormat`(`.free`, `.kpt`, `.fourL`)과 `[JournalDatabase.ReflectionAnswer]`(`question`, `text`)를 사용합니다. 새 글에 기본 형식 설정을 붙이게 되면 설정 담당과 값 전달 방식을 맞추고, 편집은 기존 `journal.format`과 `journal.answers`를 읽습니다.
- `createdAt`은 최초 작성일로 유지합니다. 기간·사진을 수정해도 기존 작성일은 덮어쓰지 않습니다.

## 4. 연결 후 확인

1. 기존 회고가 하루·사진 없음으로 열리고, 저장하지 않고 뒤로 가면 원래 값이 유지되는지 확인합니다.
2. 사진이 있는 기간 회고를 저장한 뒤 앱을 재실행합니다. 편집에서 두 날짜와 사진이 다시 표시되는지 확인합니다.
3. 편집에서 하루로 바꾸고 사진을 제거한 뒤 다시 저장합니다. 종료일과 사진이 비어 있고 상세에도 반영되는지 확인합니다.
4. 시작일보다 빠른 종료일로 저장할 수 없는지 확인합니다. 날짜 표시·정렬·통계 기준을 바꾸는 작업은 팀 합의 후 각각 연결합니다.
