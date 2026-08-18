# Third-Party Notices

LabFox는 Apache-2.0 오픈소스이며, 모바일 앱은 스토어에서 유료로 판매된다.
아래 서드파티 구성 요소를 포함하며, 각 라이선스와 저작권 고지를 명시한다.

> ⚠️ **이 문서는 법적 의무다.** MIT · BSD · Apache-2.0 등 permissive 라이선스도
> **저작권 고지와 라이선스 전문 첨부를 요구한다.** 의존성을 추가하면 여기에 반드시 기록한다.

## 인앱 표시

Flutter는 의존성 라이선스를 자동 수집한다. 앱 내 설정 화면에서 반드시 노출한다.

```dart
showLicensePage(
  context: context,
  applicationName: 'LabFox',
  applicationLegalese: '© 2026 sjungwon03',
);
```

LabFox 자체도 Apache-2.0이므로 이 화면에 함께 표시된다.
`LicenseRegistry`가 pub 패키지의 LICENSE 파일을 자동으로 수집하므로,
pub.dev 의존성은 대부분 이 화면만으로 고지 의무가 충족된다.
**직접 복사한 코드나 폰트·아이콘 등 에셋은 자동 수집되지 않으므로 수동으로 등록한다.**

```dart
LicenseRegistry.addLicense(() async* {
  yield LicenseEntryWithLineBreaks(
    ['<component>'],
    await rootBundle.loadString('assets/licenses/<component>.txt'),
  );
});
```

---

## 허용 라이선스

| 라이선스 | 유료 배포 가능 | 조건 |
|---|---|---|
| MIT | ✅ | 저작권 고지 + 라이선스 전문 |
| BSD-2 / BSD-3 | ✅ | 저작권 고지 + 라이선스 전문 |
| Apache-2.0 | ✅ | 고지 + 변경 사항 명시 + NOTICE 파일 존재 시 전달 |
| ISC | ✅ | 저작권 고지 |
| Zlib | ✅ | 고지 (수정 시 명시) |

## 금지 라이선스

| 라이선스 | 이유 |
|---|---|
| GPL-2.0 / GPL-3.0 | copyleft 전파 — Apache-2.0 무효화, App Store 배포 차단 |
| AGPL | 더 강력한 copyleft — 네트워크 사용까지 포함 |
| LGPL | Flutter는 정적 링크 → 동적 링크 예외를 쓸 수 없음 |
| SSPL / BUSL / Commons Clause | 유료 배포 제한 |
| 라이선스 없음 | 권리 미부여 = 사용 불가 |

> GPL이 금지인 이유는 오픈소스가 아니어서가 아니다. LabFox는 이미 오픈소스다.
> **copyleft가 전파되면 유료 앱을 받은 사용자가 소스를 요구하고 무료로 재배포할 권리를
> 갖게 되어** 유료 모델이 무너지고, Apple 약관과도 충돌한다.

**의존성을 추가하기 전에 반드시 라이선스를 확인한다.** (`AGENTS.md` §8)

---

## 포함된 구성 요소

<!-- 의존성을 추가할 때마다 아래 표를 갱신한다. -->

| 구성 요소 | 버전 | 라이선스 | 출처 |
|---|---|---|---|
| Flutter SDK | — | BSD-3-Clause | https://github.com/flutter/flutter |

*(스캐폴딩 이후 실제 의존성으로 채운다)*

---

## 에셋

| 에셋 | 라이선스 | 출처 |
|---|---|---|
| *(없음)* | | |

폰트·아이콘·이미지도 라이선스 확인 대상이다.
특히 **아이콘 세트는 상용 이용 조건이 까다로운 경우가 많으므로** 도입 전 확인한다.
