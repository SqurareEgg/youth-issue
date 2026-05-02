# Android APK 빌드 가이드

## 📱 APK 정보

**파일명**: `youth-issue-debug.apk`
**크기**: 16MB
**버전**: Debug (개발용)
**앱 이름**: 청년있슈
**패키지 ID**: com.youthissue.app

## 🚀 빌드 방법

### 1. 웹 앱 빌드
```bash
npm run build
```

### 2. Capacitor 동기화
```bash
npx cap sync
```

### 3. Android APK 빌드
```bash
cd android
./gradlew assembleDebug
```

빌드된 APK 위치:
```
android/app/build/outputs/apk/debug/app-debug.apk
```

## 📦 Release APK 빌드 (프로덕션용)

### 1. Keystore 생성 (최초 1회)
```bash
keytool -genkey -v -keystore youth-issue-release.keystore -alias youth-issue -keyalg RSA -keysize 2048 -validity 10000
```

### 2. android/app/build.gradle 수정
```gradle
android {
    ...
    signingConfigs {
        release {
            storeFile file("../../youth-issue-release.keystore")
            storePassword "your-password"
            keyAlias "youth-issue"
            keyPassword "your-password"
        }
    }

    buildTypes {
        release {
            signingConfig signingConfigs.release
            minifyEnabled true
            proguardFiles getDefaultProguardFile('proguard-android-optimize.txt'), 'proguard-rules.pro'
        }
    }
}
```

### 3. Release APK 빌드
```bash
cd android
./gradlew assembleRelease
```

빌드된 Release APK:
```
android/app/build/outputs/apk/release/app-release.apk
```

## 📲 APK 설치 방법

### Android 기기에 직접 설치
1. APK 파일을 휴대폰으로 전송
2. 파일 관리자에서 APK 파일 실행
3. "출처를 알 수 없는 앱" 설치 허용
4. 설치 진행

### ADB로 설치
```bash
adb install youth-issue-debug.apk
```

## ⚙️ Capacitor 설정

**capacitor.config.json**:
```json
{
  "appId": "com.youthissue.app",
  "appName": "청년있슈",
  "webDir": "dist/spa"
}
```

## 🔧 Android Studio에서 빌드

1. Android Studio 실행
2. `File > Open` → `android` 폴더 선택
3. `Build > Build Bundle(s) / APK(s) > Build APK(s)` 선택
4. 빌드 완료 후 `locate` 클릭하여 APK 위치 확인

## 📝 버전 관리

버전 정보는 다음 파일에서 수정:
- `android/app/build.gradle` - versionCode, versionName

```gradle
android {
    defaultConfig {
        applicationId "com.youthissue.app"
        minSdkVersion 22
        targetSdkVersion 34
        versionCode 1
        versionName "1.0"
    }
}
```

## 🐛 문제 해결

### Gradle 빌드 오류
```bash
cd android
./gradlew clean
./gradlew assembleDebug
```

### Capacitor 동기화 오류
```bash
npx cap sync --force
```

### 웹 에셋 재빌드
```bash
npm run build
npx cap copy
```

## 📱 지원 Android 버전

- **최소 버전**: Android 5.1 (API 22)
- **타겟 버전**: Android 14 (API 34)

## 🔐 권한 설정

`android/app/src/main/AndroidManifest.xml`에서 권한 확인:
```xml
<uses-permission android:name="android.permission.INTERNET" />
```

## 🎯 다음 단계

1. ✅ Debug APK 빌드 완료
2. ⏳ Release APK 빌드 및 서명
3. ⏳ Google Play Console 등록
4. ⏳ Play Store 배포
