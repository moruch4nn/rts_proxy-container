# rts_proxy-container
RedTownServerのVelocityProxyのdocker imageです。

## 機能一覧
### 自動アップデート
起動時にVelocityプロキシを自動的に最新にアップデートします。 <br>
### 必須プラグインの自動ダウンロード
起動時に必須プラグインの最新バージョンを自動的にダウンロードします。 <br>
### 追加プラグインのダウンロード
起動時に `$PLUGIN_LINKS` に指定されたプラグインを自動的にダウンロードします。 <br>
例: `$PLUGIN_LINKS = viaversion=https://host/,geyser=https://host2/` <br>
### Configを環境変数で管理
config.tomlの内容を全て環境変数で管理できます。 <br>
例: <br>
`$BIND` = 0.0.0.0:25565 <br>
`$ONLINE_MODE` = true <br>
`$SERVERS` = lobby=localhost:25566,survival=localhost:25567,rpg=localhost:25568 <br>
`$HAPROXY_PROTOCOL` = true <br>
`$SHOW_MAX_PLAYERS` = 500 <br>
