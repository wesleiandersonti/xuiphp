# Lock Kids / Xtream Server Panel

Painel web para gerenciamento de IPTV com clientes, testes, revendedores e conteudos
(canais/filmes/series), com APIs no padrao Xtream e geracao de playlists.

## Destaques
- API Xtream completa em `player_api.php`.
- Playlists M3U e SS-IPTV prontas para consumo.
- Redirecionamento de streams com validacao de vencimento.
- Importacao de M3U com separacao por categorias e series.

## Requisitos
- Ubuntu 22.04 LTS (recomendado) ou equivalente.
- PHP 7.2+ com `pdo_mysql`.
- MySQL/MariaDB.
- Apache com `mod_rewrite` habilitado.

## Instalacao rapida (Ubuntu limpo)
Execute o instalador completo (nao interativo):

```bash
curl -fsSL https://raw.githubusercontent.com/wesleiandersonti/xuiphp/master/install-ubuntu.sh -o install-ubuntu.sh
sudo bash install-ubuntu.sh
```

O script instala Apache/PHP/MariaDB, clona o repo, importa o SQL e configura o
`api/controles/db.php` com valores padrao.

## Credenciais padrao do instalador
O instalador usa estes valores fixos:
- DB_NAME: `xuikiller`
- DB_USER: `xuikiller`
- DB_PASS: `Xuikiller@2026`

Para alterar manualmente, edite `api/controles/db.php`.

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
