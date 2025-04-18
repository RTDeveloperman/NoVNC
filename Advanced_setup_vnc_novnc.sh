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

#!/bin/bash

# Ask for VNC password
echo "[*] Please enter your desired VNC password:"
read -s vncpass
echo "[*] Confirm password:"
read -s vncpass_confirm

# Check if passwords match
if [ "$vncpass" != "$vncpass_confirm" ]; then
  echo "[!] Passwords do not match. Exiting."
  exit 1
fi

echo "[*] Installing required packages..."
apt update
apt install -y xfce4 xfce4-goodies tightvncserver git curl wget python3 python3-pip autocutsel net-tools ufw

echo "[*] Installing noVNC..."
cd /root
git clone https://github.com/novnc/noVNC.git
cd noVNC
git clone https://github.com/novnc/websockify.git

echo "[*] Creating xstartup file..."
mkdir -p ~/.vnc

cat > ~/.vnc/xstartup <<EOF
#!/bin/bash
export XMODIFIERS="@im=fcitx"
export FONT_PATH=/usr/share/fonts/X11/misc:/usr/share/fonts/X11/75dpi:/usr/share/fonts/X11/100dpi:/usr/share/fonts/X11/Type1
xrdb \$HOME/.Xresources
autocutsel -fork
startxfce4 &
EOF

chmod +x ~/.vnc/xstartup

echo "[*] Setting VNC password..."
echo "$vncpass" | vncpasswd -f > ~/.vnc/passwd
chmod 600 ~/.vnc/passwd

echo "[*] Starting VNC server..."
vncserver -kill :1 >/dev/null 2>&1
vncserver :1 -geometry 1280x800 -depth 24

echo "[*] Creating noVNC startup script..."
cat > /usr/local/bin/start-novnc.sh <<EOF
#!/bin/bash
/root/noVNC/utils/novnc_proxy --vnc localhost:5901 --listen 6080 --web /root/noVNC
EOF

chmod +x /usr/local/bin/start-novnc.sh

echo "[*] Creating noVNC systemd service..."
cat > /etc/systemd/system/novnc.service <<EOF
[Unit]
Description=noVNC WebSocket Proxy
After=network.target vncserver@1.service

[Service]
Type=simple
ExecStart=/usr/local/bin/start-novnc.sh
Restart=always
User=root

[Install]
WantedBy=multi-user.target
EOF

echo "[*] Creating VNC systemd service..."
cat > /etc/systemd/system/vncserver@1.service <<EOF
[Unit]
Description=Start TightVNC server at startup for user %i
After=syslog.target network.target

[Service]
Type=forking
User=root
PAMName=login
PIDFile=/root/.vnc/%H:1.pid
ExecStartPre=-/usr/bin/vncserver -kill :1 > /dev/null 2>&1
ExecStart=/usr/bin/vncserver :1 -geometry 1280x800 -depth 24
ExecStop=/usr/bin/vncserver -kill :1

[Install]
WantedBy=multi-user.target
EOF

echo "[*] Enabling and starting services..."
systemctl daemon-reexec
systemctl daemon-reload
systemctl enable vncserver@1.service
systemctl start vncserver@1.service
systemctl enable novnc.service
systemctl start novnc.service

echo "[*] Configuring UFW firewall..."
ufw allow 5901/tcp
ufw allow 6080/tcp
ufw reload || echo "Firewall not active, skipping reload."

echo ""
echo "✅ Setup complete!"
echo "🌐 Access noVNC at: http://$(hostname -I | awk '{print $1}'):6080/vnc.html"
