
set :USE_PHP_VERSION_INTERNAL, "8.2"

namespace "fpm" do
  task "start" do
    on release_roles(:fpm) do |host|
      sudo "systemctl start php#{host.properties.use_php_version || fetch(:USE_PHP_VERSION, fetch(:USE_PHP_VERSION_INTERNAL))}-fpm.service"
    end
  end
  task "stop" do
    on release_roles(:fpm) do |host|
      sudo "systemctl stop php#{host.properties.use_php_version || fetch(:USE_PHP_VERSION, fetch(:USE_PHP_VERSION_INTERNAL))}-fpm.service"
    end
  end
  task "reload" do
    on release_roles(:fpm) do |host|
      sudo "systemctl reload php#{host.properties.use_php_version || fetch(:USE_PHP_VERSION, fetch(:USE_PHP_VERSION_INTERNAL))}-fpm.service"
    end
  end
  task "restart" do
    on release_roles(:fpm) do |host|
      sudo "systemctl restart php#{host.properties.use_php_version || fetch(:USE_PHP_VERSION, fetch(:USE_PHP_VERSION_INTERNAL))}-fpm.service"
    end
  end
  task "status" do
    on release_roles(:fpm) do |host|
      sudo "systemctl status php#{host.properties.use_php_version || fetch(:USE_PHP_VERSION, fetch(:USE_PHP_VERSION_INTERNAL))}-fpm.service"
    end
  end
  task "cfg:show" do
    on release_roles(:fpm) do |host|
      execute "cat /etc/php/#{host.properties.use_php_version || fetch(:USE_PHP_VERSION, fetch(:USE_PHP_VERSION_INTERNAL))}/fpm/pool.d/www.conf | egrep -v '^\s*(#|;|$)'", raise_on_non_zero_exit: false # filter ` space + # ` too
    end
  end
  task "ps" do
    on release_roles(:fpm) do
      execute "ps aux | grep fpm"
    end
  end
end
