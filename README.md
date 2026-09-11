# Flutter Pokedex

แอป Pokedex สำหรับดู ค้นหา และจัดการข้อมูล Pokémon โดยใช้ Flutter เป็นส่วนหน้าบ้าน และ Node.js/Express เป็น API ที่เชื่อมต่อฐานข้อมูล MySQL/TiDB

## ความต้องการของระบบ

- Flutter 3.29.3 หรือใหม่กว่า
- Dart 3.7 หรือใหม่กว่า
- Node.js และ npm
- Android Studio พร้อม Android Emulator หรือ Google Chrome
- ฐานข้อมูล MySQL/TiDB ที่มีตาราง `Pokemon`

## โครงสร้างโปรเจค

```text
flutter_pokedex/
├─ api/                         # Node.js API
│  ├─ index.js
│  ├─ validation.js
│  ├─ package.json
│  └─ .env                      # ไม่ควร commit ขึ้น Git
├─ lib/                         # Flutter application
│  ├─ main.dart
│  ├─ home_screen.dart
│  ├─ detail_screen.dart
│  ├─ login_screen.dart
│  ├─ admin_screen.dart
│  └─ api_config.dart
├─ android/
├─ web/
├─ pubspec.yaml
└─ README.md
```

## ตั้งค่า API และฐานข้อมูล

1. เปิด Terminal ที่โฟลเดอร์โปรเจค แล้วเข้าโฟลเดอร์ API

   ```powershell
   cd api
   npm install
   ```

2. สร้างหรือแก้ไฟล์ `api/.env` โดยใส่ URL ของฐานข้อมูลของตัวเอง

   ```env
   DATABASE_URL=mysql://USER:PASSWORD@HOST:4000/DATABASE?ssl={"rejectUnauthorized":true}
   PORT=3000
   ```

   ห้ามใส่รหัสผ่านจริงลงใน README หรือ commit ไฟล์ `.env` ขึ้น GitHub

3. ตรวจสอบว่าฐานข้อมูลมีตาราง `Pokemon` และคอลัมน์ที่ API ใช้ เช่น `name`, `total`, `hp`, `atk`, `def`, `spatk`, `spdef`, `spd`, `avatar`, `type1`, `type2`, `num`

## รัน API แบบ localhost

เปิด Terminal ที่โฟลเดอร์ `api` แล้วรัน:

```powershell
node index.js
```

ถ้าทำงานสำเร็จ จะเห็น URL:

```text
http://localhost:3000/
```

ทดสอบโดยเปิด URL นี้ในเบราว์เซอร์ ควรเห็นข้อความ `Hello world!!`

## รัน Flutter

เปิด Terminal อีกหน้าต่างที่โฟลเดอร์หลักของโปรเจค:

```powershell
flutter pub get
flutter devices
```

### Android Emulator

```powershell
flutter run -d emulator-5554
```

ใน [lib/api_config.dart](lib/api_config.dart) แอป Android Emulator ใช้ `http://10.0.2.2:3000` เพื่อเข้าถึง API ที่รันอยู่บนเครื่องคอมพิวเตอร์

### Chrome

```powershell
flutter run -d chrome
```

เมื่อรันบนเว็บ แอปจะใช้ `http://localhost:3000` โดยอัตโนมัติ

### VS Code

1. เปิดโฟลเดอร์โปรเจคหลัก `flutter_pokedex`
2. เลือกอุปกรณ์ด้านขวาล่างเป็น `Medium Phone (android-x64 emulator)` หรือ `Chrome`
3. กด `Run and Debug` หรือกด `F5`

## การเข้าสู่ระบบ Admin

หน้า Admin ใช้ข้อมูลสำหรับทดสอบดังนี้:

```text
ID: admin
Password: 12345
```

## ฟังก์ชันหลัก

- ค้นหา Pokémon จากชื่อหรือหมายเลข 3 หลัก
- กรองตามประเภท Pokémon
- ดูรายละเอียด Pokémon
- Admin สามารถเพิ่ม แก้ไข และลบข้อมูลได้
- `Type 1` จำเป็นต้องเลือก และ `Type 2` เลือก `None` ได้
- หมายเลข Pokémon ต้องมี 3 หลักและห้ามซ้ำ
- ชื่อ Pokémon ห้ามซ้ำ
- ค่าสถานะทั้ง 6 ค่า รวมกันต้องเท่ากับ `Total Stats`
- Avatar URL ไม่จำเป็นต้องใส่ หากไม่มีรูปจะแสดง placeholder สีเทา

## API Endpoints

| Method | Endpoint | รายละเอียด |
| --- | --- | --- |
| GET | `/` | ตรวจสอบว่า API ทำงานอยู่ |
| GET | `/pokemon` | ดึงข้อมูล Pokémon ทั้งหมด |
| GET | `/pokemon/:id` | ดึงข้อมูล Pokémon ตาม id |
| POST | `/pokemon` | เพิ่ม Pokémon ใหม่ |
| PUT | `/pokemon` | แก้ไขข้อมูล Pokémon |
| DELETE | `/pokemon` | ลบ Pokémon โดยส่ง `id` ใน request body |

## แก้ปัญหาเบื้องต้น

### ขึ้น `Connection refused`

- ตรวจสอบว่าเปิด API ด้วย `node index.js` แล้ว
- Android Emulator ต้องใช้ `10.0.2.2` ไม่ใช่ `localhost`
- Chrome ต้องใช้ `localhost:3000`
- ตรวจสอบว่า API ใช้ port `3000` และไม่มีโปรแกรมอื่นใช้งาน port นี้อยู่

### API เชื่อมต่อฐานข้อมูลไม่ได้

- ตรวจสอบค่า `DATABASE_URL` ใน `api/.env`
- ตรวจสอบว่า username, password, host, port และชื่อ database ถูกต้อง
- ตรวจสอบว่า database server เปิดใช้งานและอนุญาตการเชื่อมต่อจากเครื่องนี้

### Android build มีปัญหา

ลองปิดการรัน Flutter/Gradle ที่ซ้ำกัน แล้วรัน:

```powershell
flutter clean
flutter pub get
flutter run
```

## สร้าง APK

สร้าง APK สำหรับทดสอบ:

```powershell
flutter build apk --debug
```

ไฟล์ APK จะอยู่ที่:

```text
build/app/outputs/flutter-apk/app-debug.apk
```
