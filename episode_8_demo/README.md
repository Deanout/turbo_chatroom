Create postgres db for current user:
createdb

psql
CREATE USER turbo_dev PASSWORD 'password...' WITH CREATEDB;



heroku addons:create heroku-postgresql
git subtree push --prefix episode_8_demo heroku main