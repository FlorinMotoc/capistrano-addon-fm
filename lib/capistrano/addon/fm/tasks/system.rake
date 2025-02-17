
task "php" do
  on release_roles(:fpm) do
    execute "hostname && php -v"
  end
end
task "composer" do
  on release_roles(:fpm) do
    execute "hostname && sudo runuser -u www-data -- composer --version"
  end
end

task "hostname" do
  on release_roles(:app) do execute "hostname" end
end
task "cpu" do
  on release_roles(:app) do
    execute "hostname && cat /proc/cpuinfo | egrep 'model name|MHz'"
  end
end
task "uptime" do
  on release_roles(:app) do
    execute "hostname && uptime"
  end
end
task "kernel" do
  on release_roles(:app) do
    execute "hostname && lsb_release -a && uname -a"
  end
end

task "hosts" do
  on release_roles(:app) do
    execute "hostname && cat /etc/hosts"
  end
end

task "ufw:status" do
  on release_roles(:all) do
    sudo "ufw status verbose"
  end
end

task "haproxy:version" do
  on release_roles(:haproxy) do
    execute "haproxy -v"
  end
end
task "ssh:version" do
  on release_roles(:all) do
    execute "ssh -V"
  end
end
task "xz:version" do
  on release_roles(:all) do
    execute "xz -V"
  end
end

namespace "list" do
  task "users" do
    on release_roles(:app) do
      execute "ls -lah /home", raise_on_non_zero_exit: false
    end
  end
  task "supervisor" do
    on release_roles(:supervisor) do
      execute "ls -lah /etc/supervisor/conf.d/* && ls -lah /etc/supervisor/conf.d/*/", raise_on_non_zero_exit: false
    end
  end
end

# redis
namespace "redis" do
  task "cfg:show" do
    on release_roles(:redis) do
      sudo 'cat /etc/redis/redis.conf | egrep -v "^\s*(#|$)"', raise_on_non_zero_exit: false # filter ` space + # ` too
    end
  end
  task "version" do
    on release_roles(:redis) do
      execute 'redis-server --version', raise_on_non_zero_exit: false
    end
  end
end

# systemctl
namespace "systemctl" do
  task "daemon-reload" do
    on release_roles(:all) do
      sudo "systemctl daemon-reload", raise_on_non_zero_exit: false
    end
  end
  task "reboot" do
    on release_roles(:all) do
      sudo "systemctl reboot", raise_on_non_zero_exit: false
    end
  end
end

# system
namespace "system" do
  # disk_space
  namespace "disk_space" do
    task "all" do
      invoke! "system:disk_space:df"
      invoke! "system:disk_space:zfs"
      invoke! "system:disk_space:btrfs"
    end
    task "df" do
      on release_roles(:all) do
        execute "df -HT"
      end
    end
    task "zfs" do
      on release_roles(:all) do
        execute "sudo zpool list"
      end
    end
    task "btrfs" do
      on release_roles(:all) do
        execute "sudo btrfs filesystem show"
      end
    end
  end # end disk_space
  # connections
  namespace "connections:count" do
    task "total" do
      on release_roles(:app) do
        execute "hostname && netstat -ant | grep ESTABLISHED | wc -l", raise_on_non_zero_exit: false
      end
    end
    task "per_address" do
      on release_roles(:app) do
        execute "hostname && netstat -natu | awk '{print $5}' | cut -d: -f1 | sort | uniq -c | sort -n", raise_on_non_zero_exit: false
      end
    end
    task "via_ss" do
      on release_roles(:app) do
        execute "hostname && ss -s", raise_on_non_zero_exit: false
      end
    end
  end # end connections
end # end system

