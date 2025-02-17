# capistrano-addon-fm

---

## Installation

- Add this to your `Gemfile`
```ruby
gem 'capistrano-addon-fm'
```
- Run `bundle install`
- Add this to your `Capfile`
```ruby
require 'capistrano/addon/fm'
```

## Usage

### this will add new tasks for `cap` command
new tasks (example run: cap prod TASK - replace 'prod' with your stage (devel/local/etc))
#### supervisor related commands:
    cap prod supervisor:start                           Will run supervisorctl `start all`
    cap prod supervisor:stop                            Will run supervisorctl `stop all`
    cap prod supervisor:restart                         Will restart all supervisor processes (via stop and start)
    cap prod supervisor:reread                          Will run supervisorctl `reread`
    cap prod supervisor:update                          Will run supervisorctl `update`
    cap prod supervisor:status                          Will display all supervisor processes
    cap prod supervisor:status | grep RUNNING           Will display all supervisor processes in RUNNING state
    cap prod supervisor:status | grep -v RUNNING        Will display all supervisor processes without the ones in RUNNING state
#### nginx related commands:
    cap prod nginx:start
    cap prod nginx:stop
    cap prod nginx:reload
    cap prod nginx:restart
    cap prod nginx:status
#### fpm related commands: TO-BE-ADDED
#### system related commands:
    cap prod php                                        Run 'php -v'
    cap prod composer                                   Run 'composer --version'
    cap prod hostname                                   Run `hostname`
    cap prod cpu                                        Run `cat /proc/cpuinfo | egrep 'model name|MHz'`
    cap prod uptime                                     Run `uptime`
    cap prod kernel                                     Run `lsb_release -a && uname -a`
    cap prod hosts                                      Run `cat /etc/hosts`
    cap prod ufw:status                                 Run 'ufw status verbose'
    cap prod list:users                                 Run 'ls -lah /home'
    cap prod list:supervisor                            Run 'ls -lah /etc/supervisor/conf.d/* && ls -lah /etc/supervisor/conf.d/*/'
    cap prod redis:cfg:show                             Run 'cat /etc/redis/redis.conf | egrep -v "^\s*(#|$)"'
    cap prod systemctl:daemon-reload                    Run 'systemctl daemon-reload'
    cap prod haproxy|ssh|xz|redis :version (ex: cap prod haproxy:version)
    cap prod system:disk_space: all|df|zfs|btrfs
    cap prod system:connections:count: total|per_address|via_ss
#### env-with-secrets:
    cap env:upload                                      Will upload .env file to server and decrypt
    cap env:upload:diff                                 Will run `diff` command to server's .env versus local .env - decrypted
    cap env:local:encrypt_file                          Will encrypt `cap-secrets-LOCAL.txt` to `ap-secrets.enc.b64`
    cap env:local:decrypt_file                          Will decrypt `ap-secrets.enc.b64` into `cap-secrets-LOCAL.txt`
    cap env:local:secrets                               cat `cap-secrets-LOCAL.txt`
#### custom related commands:
    cap prod cat:env                                    Run `cat /var/www/*/*/.env`
    cap prod empty_file:check                           Run `la -lah on nginx, fpm, laravel and var/www/*/current/logs/*`
    cap prod empty_file: nginx|fpm|laravel|logs2        Run `truncate -s 0 && rm ` on nginx, fpm, laravel and var/www/*/current/logs/*`
    cap prod empty_file:all                             Run check + truncate/rm + check on all
#### Helpful commands
    cap prod command ROLES=role1,role2                  Run command on specified role(s)
    cap prod command HOSTS=host1,host2                  Run command on specified host(s)

## Configuration

Following variables are available to be changed (shown with defaults)

```ruby
# env-with-secrets
set :local_path, './'
set :file_to_encrypt, 'cap-secrets-LOCAL.txt'
set :file_to_decrypt, 'cap-secrets.enc.b64'
set :encryption_key_file, 'cap-secrets-encryption-key-LOCAL.txt'
```

## env-with-secrets
### This will allow you to have .env files committed to git with secrets inside (encrypted)
- Inside .env file you need to use `="CAP_ENCRYPTED_SECRETS[something]"`. Examples:
  - `DB_PASSWORD="CAP_ENCRYPTED_SECRETS[DB_PASSWORD]"`
  - `MAIL_PASSWORD="CAP_ENCRYPTED_SECRETS[MAIL_PASSWORD]"`
- After deploy, the `CAP_ENCRYPTED_SECRETS[DB_PASSWORD]` will be replaced to whatever secret you wrote in the secrets file for key `DB_PASSWORD`
  - Also, the `CAP_ENCRYPTED_SECRETS` will be removed; this is used for the regex to know when to replace
- You also need 3 files - generate them by running `cap {prod} env:local:encrypt_file` - this will generate the files when they don't exist
  - `cap-secrets-encryption-key-LOCAL.txt`
    - Don't push this to git.
    - You need to manually share this with other colleagues to be able to deploy and/or encrypt/decrypt .env files.
    - This is the encryption key. You can change it to whatever you want. Default is 40 random chars.
  - `cap-secrets-LOCAL.txt`
    - Don't push this to git.
    - Generated by `cap {prod} env:local:decrypt_file`
      - Decrypts `cap-secrets.enc.b64` into `cap-secrets-LOCAL.txt`
    - This file stores `SOME_KEY="secret"` on each line
      - The `SOME_KEY` will be used in .env files like this: `SOME_VAR="CAP_ENCRYPTED_SECRETS[SOME_KEY]"`
  - `cap-secrets.enc.b64`
      - Push this to git.
      - Generated by `cap {prod} env:local:encrypt_file`
          - Encrypts `cap-secrets-LOCAL.txt` into `cap-secrets.enc.b64`
- You can also change the location and name of these files by changing the 4 variables from `Configuration`
  - You can also use subdirectories, but you need to create directories first.
  - Everything is related to `Capfile`
  - If you don't set anything, then the default is root of project (or, near the Capfile)
- Finally, you need to have this in your `deploy.rb` or `stages/{stage}.rb`
  - `before "deploy:symlink:release", "env:upload:diff"`
    - I like having `diff` too, before `upload`, to see in `cap {prod} deploy` output the diff - if any
    - So it will be:
      - `before "deploy:symlink:release", "env:upload:diff"`
      - `before "deploy:symlink:release", "env:upload"`
  - Also, for each `server` line, you need to specify which .env file to use via `env_file_location`. Example:
    - `server "web1", user: "user1", roles: %w{ app web etc }, env_file_location: '.env.prod.web1'`
      - File `.env.prod.web1` should exist at root of project
  - Preferably to update `.gitignore` file with the 2 `LOCAL` files
    - `cap-secrets-LOCAL.txt`
    - `cap-secrets-encryption-key-LOCAL.txt`

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
