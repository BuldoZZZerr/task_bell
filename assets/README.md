# Папка для фоновых картинок

**Переместите сюда папку BGs** из корня проекта.

Должна получиться такая структура:

```
assets/
  BGs/
    Light/
      Today (Light).png
      Week (Light).png
      Calendar (Light).png
      Settings (Light).png
    Dark/
      Today (Dark).png
      Week (Dark).png
      Calendar (Dark).png
      Settings (Dark).png
```

То есть: вырежьте папку `BGs` из корня проекта (рядом с `lib/`) и вставьте её в папку `assets/`.

После этого выполните в корне проекта:
```
flutter clean
flutter pub get
```
и заново запустите приложение.
