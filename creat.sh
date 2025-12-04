#!/bin/bash
# Script completo de configuración de kiosco

echo "=== CONFIGURACIÓN DE KIOSCO ==="

# 1. Actualizar sistema
apt update && apt upgrade -y

# 2. Instalar paquetes necesarios
apt install -y x11-xserver-utils xdotool unclutter openssh-server fail2ban x11vnc lightdm unclutter firefox-esr apache2 fluxbox

# Instalamos Samba 
apt install samba samba-common-bin

cat > /root/samba.sh << 'EOF'
#!/bin/bash

SMBCONF="/etc/samba/smb.conf"
INCLUDE_LINE="include = /etc/samba/smb.conf.local"

# Verificar si ya existe
if grep -q "^include.*smb.conf.local" "$SMBCONF"; then
    echo "La línea include ya existe en $SMBCONF"
else
    # Agregar después de [global]
    sed -i '/^\[global\]/a\    '"$INCLUDE_LINE" "$SMBCONF"
    echo "Línea include agregada automáticamente"
fi
EOF

chmod +x /root/samba.sh

#ejecutmos
/root/samba.sh

# password de samba.


# 3. Configurar autologin
cat > /etc/lightdm/lightdm.conf << EOF
[Seat:*]
autologin-user=kiosk
autologin-user-timeout=0
greeter-hide-users=true
allow-guest=false
EOF

# 4. Crear usuario kiosk
useradd -m -s /bin/bash kiosk
PASS=`kiosk:$(openssl rand -base64 12)`
echo $PASS
echo $PASS | chpasswd
#echo "kiosk:$(openssl rand -base64 12)" | chpasswd
passwd -l kiosk

cat > /home/kiosk/.fluxbox/startup << 'EOF'
#!/bin/sh
# KIOSCO CONFIGURATION - FLUXBOX

# ========================================
# CONFIGURACIÓN DEL SISTEMA X
# ========================================

# Desactivar salvapantallas y ahorro de energía
xset s off
xset -dpms
xset s noblank

# Configurar fondo (opcional)
# feh --bg-scale /ruta/a/fondo.jpg &

# Desactivar cursor del mouse
unclutter -idle 0.5 -root &

# Configurar teclado (desactivar teclas especiales)
xmodmap -e "keycode 115 = "  # Desactivar Windows/Super
xmodmap -e "keycode 116 = "  # Desactivar teclas de función

# ========================================
# SERVICIOS NECESARIOS
# ========================================

# Iniciar D-Bus
if [ -z "$DBUS_SESSION_BUS_ADDRESS" ]; then
    eval $(dbus-launch --sh-syntax --exit-with-session)
fi

# Panel simple (opcional)
# tint2 -c ~/.config/tint2/kiosk.tint2rc &

# ========================================
# CONFIGURACIÓN DE FLUXBOX
# ========================================

# Cargar configuración inicial
if [ -f ~/.fluxbox/init ]; then
    . ~/.fluxbox/init
fi

# Iniciar Fluxbox en segundo plano
fluxbox &

# ========================================
# ESPERAR INICIO COMPLETO
# ========================================

sleep 3  # Esperar que Fluxbox se inicialice

# ========================================
# APLICACIÓN PRINCIPAL DEL KIOSCO
# ========================================

# OPCIÓN 1: Firefox (Recomendado)
#firefox --kiosk --private-window http://tu-pagina-kiosco.com &

# OPCIÓN 2: Chromium
# chromium-browser --kiosk --incognito --no-first-run --disable-translate http://tu-pagina.com &

# OPCIÓN 3: Navegador específico para kiosco
# epiphany --application-mode http://tu-pagina.com &

# ========================================
# VIGILANCIA DE LA APLICACIÓN
# ========================================

# Script que reinicia la aplicación si se cierra
while true; do
    # Verificar si la aplicación está corriendo
    if ! pgrep -x "firefox-esr" > /dev/null; then
        echo "Aplicación cerrada. Reiniciando..."
        firefox --kiosk --private-window http://localhost &
    fi
    
    # Forzar pantalla completa si se sale
    sleep 5
done

# ========================================
# MANTENER EL SCRIPT ACTIVO
# ========================================
wait
EOF

chown kiosk: /home/kiosk/.fluxbox/startup 
init 3
init 5

