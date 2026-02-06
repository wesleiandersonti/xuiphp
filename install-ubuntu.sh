#!/usr/bin/env bash
set -euo pipefail

PROJECT_DIR="/var/www/xuikiller"
APACHE_SITE="/etc/apache2/sites-available/xuikiller.conf"
DB_NAME="xuikiller"

if [[ $EUID -ne 0 ]]; then
  echo "Run as root (sudo)."
  exit 1
fi

echo "[1/7] Installing packages"
apt-get update -y
DEBIAN_FRONTEND=noninteractive apt-get install -y \
  apache2 \
  mariadb-server \
  php \
  php-cli \
  php-mysql \
  php-curl \
  php-xml \
  php-mbstring \
  php-zip \
  unzip

echo "[2/7] Enabling Apache modules"
a2enmod rewrite headers

echo "[3/7] Deploying project"
mkdir -p "$PROJECT_DIR"
rsync -a --delete --exclude ".git" ./ "$PROJECT_DIR/"
chown -R www-data:www-data "$PROJECT_DIR"

echo "[4/7] Configuring Apache site"
cat > "$APACHE_SITE" <<'EOF'
<VirtualHost *:80>
    ServerName _
    DocumentRoot /var/www/xuikiller

    <Directory /var/www/xuikiller>
        Options Indexes FollowSymLinks
        AllowOverride All
        Require all granted
    </Directory>

    ErrorLog ${APACHE_LOG_DIR}/xuikiller-error.log
    CustomLog ${APACHE_LOG_DIR}/xuikiller-access.log combined
</VirtualHost>
EOF

a2dissite 000-default >/dev/null 2>&1 || true
a2ensite xuikiller
systemctl restart apache2

echo "[5/7] Creating database"
read -r -p "MariaDB root user [root]: " DB_ROOT_USER
DB_ROOT_USER=${DB_ROOT_USER:-root}
read -r -s -p "MariaDB root password (leave empty for none): " DB_ROOT_PASS
echo ""
read -r -p "New database name [xuikiller]: " DB_NAME_INPUT
DB_NAME=${DB_NAME_INPUT:-$DB_NAME}
read -r -p "New database user [xuikiller]: " DB_USER
DB_USER=${DB_USER:-xuikiller}
read -r -s -p "New database password: " DB_PASS
echo ""

MYSQL_AUTH=""
if [[ -n "$DB_ROOT_PASS" ]]; then
  MYSQL_AUTH="-p$DB_ROOT_PASS"
fi

mysql -u"$DB_ROOT_USER" $MYSQL_AUTH -e "CREATE DATABASE IF NOT EXISTS $DB_NAME CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;"
mysql -u"$DB_ROOT_USER" $MYSQL_AUTH -e "CREATE USER IF NOT EXISTS '$DB_USER'@'localhost' IDENTIFIED BY '$DB_PASS';"
mysql -u"$DB_ROOT_USER" $MYSQL_AUTH -e "GRANT ALL PRIVILEGES ON $DB_NAME.* TO '$DB_USER'@'localhost'; FLUSH PRIVILEGES;"

echo "[6/7] Importing schema"
mysql -u"$DB_ROOT_USER" $MYSQL_AUTH "$DB_NAME" < "$PROJECT_DIR/u388078543_lockkids.sql"

echo "[7/7] Updating db.php"
DB_PHP="$PROJECT_DIR/api/controles/db.php"
if [[ -f "$DB_PHP" ]]; then
  sed -i "s/\$endereco *= *\".*\";/\$endereco = \"localhost\";/" "$DB_PHP"
  sed -i "s/\$dbusuario *= *\".*\";/\$dbusuario = \"$DB_USER\";/" "$DB_PHP"
  sed -i "s/\$dbsenha *= *\".*\";/\$dbsenha = \"$DB_PASS\";/" "$DB_PHP"
  sed -i "s/\$banco *= *\".*\";/\$banco = \"$DB_NAME\";/" "$DB_PHP"
fi

echo "Done. Open: http://<server-ip>/"
