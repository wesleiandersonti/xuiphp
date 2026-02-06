# Lock Kids / Xtream Server Panel

Painel web para gerenciamento de IPTV com suporte a clientes, testes, revendedores,
conteudos (canais/filmes/series) e integracao com APIs no padrao Xtream.

## Visao geral
- Backend em PHP com PDO/MySQL.
- Frontend em Bootstrap 5 + jQuery + DataTables.
- API estilo Xtream em `player_api.php` e geracao de playlists M3U/SSIPTV.
- Rotas encurtadas e streaming via `.htaccess`.

## Requisitos
- PHP 7.2+ (com extensao `pdo_mysql`).
- MySQL/MariaDB.
- Apache com `mod_rewrite` habilitado (ou Nginx equivalente com rules).

## Instalacao rapida
1) Aponte o DocumentRoot do servidor web para esta pasta.
2) Importe o banco usando `u388078543_lockkids.sql`.
3) Atualize as credenciais do banco em `api/controles/db.php`.
4) Garanta que `.htaccess` esteja ativo (AllowOverride All).
5) Acesse `index.php` para fazer login.

## Configuracao do banco
Arquivo: `api/controles/db.php`

Edite os valores para o seu ambiente:
- `$endereco` (host)
- `$dbusuario` (usuario)
- `$dbsenha` (senha)
- `$banco` (nome do banco)

## Estrutura principal
- Login: `index.php`
- Menu/layout: `menu.php`
- Dashboard: `dashboard.php`
- Clientes/Testes: `clientes.php`, `testes.php`
- Conteudos: `categorias.php`, `canais.php`, `filmes.php`, `serie.php`
- Planos/Revendedores: `planos.php`, `revendedores.php`
- Upload M3U: `uploud.php`

## APIs internas (painel)
Estas rotas recebem POST e retornam JSON para modais e acoes do painel:
- `api/clientes.php`
- `api/testes.php`
- `api/categorias.php`
- `api/canais.php`
- `api/filmes.php`
- `api/series.php`
- `api/planos.php`
- `api/revendedores.php`

## APIs publicas (Xtream/M3U)

### Autenticacao basica
`GET /player_api.php?username=<USER>&password=<PASS>`

### Categorias
- `GET /player_api.php?username=<USER>&password=<PASS>&action=get_live_categories`
- `GET /player_api.php?username=<USER>&password=<PASS>&action=get_vod_categories`
- `GET /player_api.php?username=<USER>&password=<PASS>&action=get_series_categories`

### Streams
- `GET /player_api.php?username=<USER>&password=<PASS>&action=get_live_streams`
- `GET /player_api.php?username=<USER>&password=<PASS>&action=get_vod_streams`
- `GET /player_api.php?username=<USER>&password=<PASS>&action=get_series`

### Infos
- `GET /player_api.php?username=<USER>&password=<PASS>&action=get_vod_info&vod_id=<ID>`
- `GET /player_api.php?username=<USER>&password=<PASS>&action=get_series_info&series_id=<ID>`

### M3U
- `GET /get.php?username=<USER>&password=<PASS>&type=m3u_plus&output=ts`
- `GET /get.php?username=<USER>&password=<PASS>&type=m3u_plus&output=m3u8`

### SS-IPTV
- `GET /ssiptv.php?username=<USER>&password=<PASS>&ssiptv&output=ts`
- `GET /ssiptv.php?username=<USER>&password=<PASS>&ssiptv&output=m3u8`

### EPG
- `GET /xmltv.php?username=<USER>&password=<PASS>`

## Rotas encurtadas (Rewrite)
Configuradas em `.htaccess`:
- `/m3u-ts/<user>/<pass>` -> `get.php` (ts)
- `/m3u-m3u8/<user>/<pass>` -> `get.php` (m3u8)
- `/ss-ts/<user>/<pass>` -> `ssiptv.php` (ts)
- `/ss-m3u8/<user>/<pass>` -> `ssiptv.php` (m3u8)
- `/epg/<user>/<pass>` -> `xmltv.php`

## Streaming
Redirecionadores validam cliente e vencimento:
- `redirecionar-live.php`
- `redirecionar-vod.php`
- `redirecionar-series.php`

URLs baseadas em rewrite:
- `/live/<user>/<pass>/<id>.ts`
- `/movie/<user>/<pass>/<id>.<ext>`
- `/series/<user>/<pass>/<id>.<ext>`

## Seguranca (observacoes)
- `admin.pass` e `clientes.senha` parecem armazenadas em texto puro no banco.
  Em ambiente real, recomendado migrar para hash (ex: password_hash).
- Credenciais do banco ficam no arquivo `api/controles/db.php`.

## Scripts e assets
- JS customizados em `js/*`
- Estilos do menu em `css/menu.css`

## Problemas comuns
- 404 em rotas encurtadas: verifique `mod_rewrite` e AllowOverride.
- Erro de conexao: valide credenciais em `api/controles/db.php`.
- API retorna auth=0: usuario/senha invalida ou vencido.
