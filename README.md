## My Ruby study

URL shorter service.

rubyの勉強しようと思って何となく作ったURL短縮サービス的なもの。

### Installation

```
bundle install --path vendor/bundler
bower install
mysql -uroot -e "create database tan"
mysql -uroot tan < schema.sql
```

### Start application

`bundle exec unicorn -c unicorn_config.rb`

### License

MIT

おわり

