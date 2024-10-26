# Banknote_recognition
Görme engelli bireyler için banknot tanıma uygulaması

# Banknot Tespiti Projesi


Bu proje, görme engelli bireylerin banknotları tanımasına yardımcı olan bir mobil uygulamadır. Uygulama, Flutter ile geliştirilmiş bir mobil arayüz ve Python ile yazılmış bir API içerir.

## Proje Yapısı

- `flutter_app/`: Flutter mobil uygulama kodları.
- `python_api/`: Python API kodları.

## Kurulum

### Flutter Uygulaması

1. Flutter SDK'yı yükleyin: [Flutter Install](https://flutter.dev/docs/get-started/install)
2. `flutter_app` dizinine gidin:
    ```sh
    cd flutter_app
    ```
3. Gerekli paketleri yükleyin:
    ```sh
    flutter pub get
    ```
4. Uygulamayı çalıştırın:
    ```sh
    flutter run
    ```

### Python API

1. Python ve pip'i yükleyin.
2. `python_api` dizinine gidin:
    ```sh
    cd python_api
    ```
3. Gerekli bağımlılıkları yükleyin:
    ```sh
    pip install -r requirements.txt
    ```
4. API'yi çalıştırın:
    ```sh
    python app.py
    ```

## Kullanım

Uygulama açıldığında, kullanıcı banknotları tanımlamak için bir fotoğraf çekebilir veya mevcut bir fotoğrafı yükleyebilir. API, fotoğrafı işler ve banknotun değerini geri döner.

## Katkıda Bulunma

Katkıda bulunmak isterseniz, lütfen bir pull request gönderin veya bir issue açın.
