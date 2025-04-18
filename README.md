# NoVNC
این اسکریپت یک محیط دسکتاپ مجازی با استفاده از VNC و noVNC روی سیستم لینوکس نصب و راه‌اندازی می‌کند
Make it executable:

chmod +x setup_vnc_novnc.sh


Run as root:

sudo bash setup_vnc_novnc.sh
----------------------------------------------------------
برای استارت دستی دسکتاپ (در صورت ریبوت شدن سیستم):
vncserver :1 -geometry 1280x800 -depth 24



برای استاپ یا ریستارت سرویس‌ها:
systemctl restart novnc
vncserver -kill :1


برای غیرفعال کردن Firewall (اگر نیاز شد):

ufw disable

