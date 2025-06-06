 راه‌اندازی محیط دسکتاپ مجازی با NoVNC

این راهنما چگونگی نصب و پیکربندی یک محیط دسکتاپ مجازی با استفاده از VNC و noVNC روی سیستم لینوکس را توضیح می‌دهد.

 پیش‌نیازها

- سیستم عامل لینوکس (ترجیحاً Ubuntu/Debian)
- دسترسی root (یا کاربر با مجوز sudo)
- اتصال به اینترنت

 نصب و راه‌اندازی

1. اسکریپت نصب را قابل اجرا کنید:

```bash
chmod +x setup_vnc_novnc.sh
```

2. اسکریپت را با دسترسی root اجرا کنید:

```bash
sudo bash setup_vnc_novnc.sh
```

 دستورات مدیریتی

 راه‌اندازی دستی دسکتاپ
در صورت ریبوت شدن سیستم، می‌توانید دسکتاپ را به صورت دستی راه‌اندازی کنید:

```bash
vncserver :1 -geometry 1280x800 -depth 24
```

 مدیریت سرویس‌ها
برای راه‌اندازی مجدد سرویس‌ها:

```bash
systemctl restart novnc
vncserver -kill :1
```

 غیرفعال کردن فایروال (در صورت نیاز)
اگر با مشکلات اتصال مواجه شدید، می‌توانید فایروال را موقتاً غیرفعال کنید:

```
ufw disable
```

 نکات فنی

- پورت پیش‌فرض VNC: 5901
- پورت پیش‌فرض noVNC: 6080


 دانلود و اجرای مستقیم

```bash
sudo bash -c "$(curl -fsSL https://raw.githubusercontent.com/RTDeveloperman/NoVNC/main/setup_vnc_novnc.sh)"
```
