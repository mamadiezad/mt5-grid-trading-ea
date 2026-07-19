# MT5 Grid Trading EA — ربات معامله‌گر گرید برای متاتریدر ۵ 🤖

> **Expert Advisor** حرفه‌ای برای **متاتریدر ۵** با استراتژی **Grid Trading** — معاملات خودکار **Buy Stop** و **Sell Stop** با مدیریت هوشمند موقعیت‌ها، تریلینگ استاپ و سناریوهای خروج متنوع.

[![MQL5](https://img.shields.io/badge/MQL5-Expert_Advisor-0055FF?logo=metatrader)](https://www.mql5.com)
[![Forex](https://img.shields.io/badge/Forex-Grid_Trading-00C853?logo=finance)](https://www.metatrader5.com)
[![License: MIT](https://img.shields.io/badge/License-MIT-blue)](LICENSE)

<br/>

---

## 📋 معرفی

این یک **Expert Advisor (EA)** حرفه‌ای برای **MetaTrader 5** است که با استفاده از استراتژی **Grid Trading** معامله می‌کند. الگوریتم گرید، تعداد مشخصی معامله **Buy Stop** و **Sell Stop** در دو طرف قیمت فعلی با فواصل و حجم‌های قابل تنظیم قرار می‌دهد.

در سناریوهای مختلف بازار، رفتارهای هوشمندانه‌ای مانند **بستن تمام معاملات** در سود هدف، **تریل کردن استاپ** برای قفل سود، و **مدیریت ریسک** خودکار از خود نشان می‌دهد.

> **Grid Trading Expert Advisor for MetaTrader 5** — Automated buy stop and sell stop grid trading bot with trailing stop management, profit targets, loss limits, and scenario-based behavior.

<br/>

---

## ⚙️ پارامترهای ورودی

### تنظیمات گرید
| پارامتر | نوع | پیش‌فرض | توضیح |
|---------|:---:|:-------:|-------|
| `GridOrdersPerSide` | int | 5 | تعداد معاملات در هر طرف (خرید/فروش) |
| `GridStepPoints` | double | 50 | فاصله بین معاملات گرید (پیپ) |
| `GridVolume` | double | 0.01 | حجم هر معامله (لات) |
| `GridMultiplier` | double | 1.0 | ضریب افزایش حجم در هر سطح |
| `GridSpread` | double | 20 | فاصله اولین معامله از قیمت (پیپ) |

### تریلینگ استاپ
| پارامتر | نوع | پیش‌فرض | توضیح |
|---------|:---:|:-------:|-------|
| `UseTrailing` | bool | true | فعال/غیرفعال کردن تریلینگ |
| `TrailStart` | double | 100 | فاصله فعال‌سازی تریلینگ (پیپ) |
| `TrailStep` | double | 30 | گام تریلینگ (پیپ) |

### مدیریت ریسک
| پارامتر | نوع | پیش‌فرض | توضیح |
|---------|:---:|:-------:|-------|
| `MagicNumber` | int | 202401 | شناسه یکتای ربات |
| `MaxSpread` | double | 50 | حداکثر اسپرد مجاز (پیپ) |
| `CloseOnProfit` | bool | true | بستن همه در سود هدف |
| `TotalProfitTarget` | double | 50.0 | سود هدف (واحد حساب) |
| `TotalLossLimit` | double | -100.0 | حد ضرر کل (واحد حساب) |
| `MaxPositions` | int | 20 | حداکثر موقعیت‌های همزمان |

### رفتار گرید
| پارامتر | نوع | پیش‌فرض | توضیح |
|---------|:---:|:-------:|-------|
| `HedgeMode` | bool | false | حالت هج (فعال بودن هر دو طرف) |
| `AutoRebuild` | bool | true | بازسازی خودکار گرید |

<br/>

---

## 🎯 نحوه عملکرد

### ۱. قرارگیری گرید
EA در ابتدا تعداد مشخصی سفارش **Buy Stop** (بالای قیمت) و **Sell Stop** (پایین قیمت) با فواصل مشخص قرار می‌دهد:

```
قیمت فعلی: 1.1000

Buy Stop 5: 1.1300
Buy Stop 4: 1.1250
Buy Stop 3: 1.1200
Buy Stop 2: 1.1150
Buy Stop 1: 1.1100
============== 1.1000 ==============
Sell Stop 1: 1.0900
Sell Stop 2: 1.0850
Sell Stop 3: 1.0800
Sell Stop 4: 1.0750
Sell Stop 5: 1.0700
```

### ۲. تریلینگ استاپ
وقتی قیمت به اندازه `TrailStart` به نفع یک معامله حرکت کند، EA استاپ‌لاس را به اندازه `TrailStep` عقب می‌کشد تا سود قفل شود.

### ۳. سناریوهای خروج
- **سود هدف**: وقتی سود کل به `TotalProfitTarget` برسد، همه معاملات بسته می‌شوند.
- **حد ضرر**: وقتی ضرر کل به `TotalLossLimit` برسد، همه معاملات بسته می‌شوند.
- **بازسازی خودکار**: وقتی همه معاملات بسته شدند، گرید دوباره ساخته می‌شود.

<br/>

---

## 🚀 نصب و استفاده

### پیش‌نیازها
- **MetaTrader 5** نصب شده
- یک حساب معاملاتی (دمو یا واقعی)

### مراحل نصب

```bash
# 1. فایل EA را دانلود کنید
wget https://raw.githubusercontent.com/mamadiezad/mt5-grid-trading-ea/main/Experts/GridTradingEA.mq5

# 2. فایل را در پوشه Experts متاتریدر خود کپی کنید:
#    (MetaTrader 5 설치 경로)/MQL5/Experts/

# 3. متاتریدر را ری‌استارت کنید

# 4. EA را از Navigator به چارت بکشید و پارامترها را تنظیم کنید
```

### تنظیم پیشنهادی برای حساب دمو

| پارامتر | مقدار |
|---------|:-----:|
| GridOrdersPerSide | 3 |
| GridStepPoints | 100 |
| GridVolume | 0.01 |
| TrailStart | 50 |
| TrailStep | 15 |
| TotalProfitTarget | 10.0 |
| TotalLossLimit | -25.0 |

<br/>

---

## 📁 ساختار پروژه

```
mt5-grid-trading-ea/
├── Experts/
│   └── GridTradingEA.mq5    # فایل اصلی Expert Advisor
├── README.md                 # مستندات (فارسی + انگلیسی)
└── LICENSE                   # مجوز MIT
```

<br/>

---

## ⚠️ هشدار ریسک

**معاملات فارکس و CFDها ریسک بالایی دارند.** این EA برای **حساب دمو** طراحی و تست شده. قبل از استفاده در حساب واقعی:

1. حتماً در حساب دمو تست کنید
2. پارامترها را با توجه به جفت ارز و تایم‌فریم تنظیم کنید
3. از حجم‌های پایین شروع کنید
4. حد ضرر و سود هدف مناسب تنظیم کنید

> **Risk Warning:** Forex and CFD trading involves substantial risk. Test this EA on a demo account first.

<br/>

---

## 🔗 ریپوهای مرتبط

- [🤖 ربات چت ناشناس تلگرام](https://github.com/mamadiezad/robot-chat-nashnas) — Telegram Chat Bot
- [🚀 FastAPI Tasks](https://github.com/mamadiezad/fastapi-tasks) — Task Management API
- [🎨 Next.js Portfolio](https://github.com/mamadiezad/nextjs-portfolio) — Personal Portfolio

<br/>

---

## 📜 لایسنس

**MIT** — آزاد برای استفاده شخصی و تجاری.

<br/>

---

<p align="center">
  ساخته شده با ❤️ توسط <a href="https://github.com/mamadiezad">Mohammad</a>
</p>
