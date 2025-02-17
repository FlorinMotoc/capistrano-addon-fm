
namespace 'cat' do
  task 'env' do
    on release_roles(:fpm) do
      execute "cat /var/www/*/*/.env", raise_on_non_zero_exit: false
    end
  end
end

namespace "empty_file" do
  task "all" do
    invoke! "empty_file:check"
    invoke! "empty_file:nginx"
    invoke! "empty_file:fpm"
    invoke! "empty_file:laravel"
    invoke! "empty_file:logs2"
    invoke! "empty_file:check"
  end
  task "check" do
    on release_roles(:app) do
      execute "ls -lahS /var/log/nginx/*.log", raise_on_non_zero_exit: false
      execute "ls -lahS /var/log/php*-fpm.log", raise_on_non_zero_exit: false
      execute "ls -lahS /var/www/*/current/storage/logs/*", raise_on_non_zero_exit: false
      execute "ls -lahS /var/www/*/current/logs/*", raise_on_non_zero_exit: false
    end
  end
  task "nginx" do
    on release_roles(:app) do
      execute "sudo truncate -s 0 /var/log/nginx/*.log", raise_on_non_zero_exit: false
    end
  end
  task "fpm" do
    on release_roles(:app) do
      execute "sudo truncate -s 0 /var/log/php*-fpm.log", raise_on_non_zero_exit: false
    end
  end
  task "laravel" do
    on release_roles(:app) do
      execute "sudo truncate -s 0 /var/www/*/current/storage/logs/*.log && sudo truncate -s 0 /var/www/*/current/storage/logs/*.err", raise_on_non_zero_exit: false
      execute "sudo rm /var/www/*/current/storage/logs/*.log.*", raise_on_non_zero_exit: false
      execute "sudo rm /var/www/*/current/storage/logs/*.err.*", raise_on_non_zero_exit: false
    end
  end
  task "logs2" do
    on release_roles(:app) do
      execute "sudo truncate -s 0 /var/www/*/current/logs/*.log && sudo truncate -s 0 /var/www/*/current/logs/*.err", raise_on_non_zero_exit: false
      execute "sudo rm /var/www/*/current/logs/*.log.*", raise_on_non_zero_exit: false
      execute "sudo rm /var/www/*/current/logs/*.err.*", raise_on_non_zero_exit: false
    end
  end
end
