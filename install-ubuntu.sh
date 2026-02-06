#!/usr/bin/env bash
set -euo pipefail

PROJECT_DIR="/var/www/xuikiller"
APACHE_SITE="/etc/apache2/sites-available/xuikiller.conf"
REPO_URL="https://github.com/wesleiandersonti/xuiphp.git"
REPO_BRANCH="master"
DB_NAME="xuikiller"
DB_USER="xuikiller"
DB_PASS="Xuikiller@2026"
DB_ROOT_USER="root"
DB_ROOT_PASS=""

if [[ $EUID -ne 0 ]]; then
  echo "Run as root (sudo)."
  exit 1
fi

echo "[1/7] Installing packages"
apt-get update -y
DEBIAN_FRONTEND=noninteractive apt-get install -y \
  apache2 \
  git \
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

echo "[3/7] Cloning project"
if [[ -d "$PROJECT_DIR/.git" ]]; then
  git -C "$PROJECT_DIR" fetch --all --prune
  git -C "$PROJECT_DIR" checkout "$REPO_BRANCH"
  git -C "$PROJECT_DIR" pull --ff-only
else
  rm -rf "$PROJECT_DIR"
  git clone --branch "$REPO_BRANCH" "$REPO_URL" "$PROJECT_DIR"
fi
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
