#!/bin/bash

# MIT License
# 
# Copyright (c) RTDeveloperman Boosio(Boosyou) 2025 Developerman.it@gmail.com
# 
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
# 
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
# 
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.
# آپدیت و نصب ابزارهای مورد نیاز
apt update && apt upgrade -y
apt install -y xfce4 xfce4-goodies tightvncserver x11vnc firefox autocutsel python3-pip git curl

# نصب pip در صورت نبودن
command -v pip3 >/dev/null 2>&1 || apt install -y python3-pip

# نصب noVNC
cd /root
git clone https://github.com/novnc/noVNC.git
cd noVNC
git submodule update --init --recursive
pip3 install websockify

# اجرای اولیه vncserver برای ساخت فایل xstartup
vncserver :1
vncserver -kill :1

# تنظیمات xstartup
cat > ~/.vnc/xstartup <<EOF
#!/bin/sh
unset SESSION_MANAGER
unset DBUS_SESSION_BUS_ADDRESS
export XMODIFIERS="@im=fcitx"
export FONT_PATH=/usr/share/fonts/X11/misc:/usr/share/fonts/X11/75dpi/:/usr/share/fonts/X11/100dpi/:/usr/share/fonts/X11/Type1
xrdb \$HOME/.Xresources
xhost +local:
autocutsel -fork
startxfce4 &
EOF

chmod +x ~/.vnc/xstartup

# اسکریپت راه‌انداز noVNC
cat > /usr/local/bin/start-novnc.sh <<EOF
#!/bin/bash
websockify --web /root/noVNC 6080 localhost:5901
EOF

chmod +x /usr/local/bin/start-novnc.sh

# فایل systemd برای noVNC
cat > /etc/systemd/system/novnc.service <<EOF
[Unit]
Description=noVNC WebSocket Proxy
After=network.target

[Service]
ExecStart=/usr/local/bin/start-novnc.sh
WorkingDirectory=/root/noVNC
Restart=always
User=root

[Install]
WantedBy=multi-user.target
EOF

# فعال‌سازی سرویس
systemctl daemon-reexec
systemctl daemon-reload
systemctl enable novnc.service
systemctl restart novnc.service

# اجرای مجدد VNC سرور
vncserver :1 -geometry 1280x800 -depth 24

# باز کردن پورت‌ها
ufw allow 5901/tcp
ufw allow 6080/tcp
ufw enable

echo "✅ نصب کامل شد! حالا می‌تونی به این آدرس بری:"
echo "👉 http://[IP]:6080"
