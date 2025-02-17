
namespace "mysql" do
  task "start" do
    on release_roles(:mysql) do
      sudo "systemctl start mysql", raise_on_non_zero_exit: false
    end
  end
  task "stop" do
    on release_roles(:mysql) do
      sudo "systemctl stop mysql", raise_on_non_zero_exit: false
    end
  end
  task "restart" do
    on release_roles(:mysql), in: :sequence, wait: 5 do
      sudo "systemctl restart mysql", raise_on_non_zero_exit: false
    end
  end
  task "status" do
    on release_roles(:mysql) do
      sudo "systemctl status mysql", raise_on_non_zero_exit: false
    end
  end
  task "cfg:show" do
    on release_roles(:mysql) do
      execute 'cat /etc/mysql/mysql.conf.d/mysqld.cnf | egrep -v "^\s*(#|$)"', raise_on_non_zero_exit: false # filter ` space + # ` too
    end
  end
  task "cfg:show:auto" do
    on release_roles(:mysql) do
      sudo 'cat /var/lib/mysql/auto.cnf', raise_on_non_zero_exit: false
    end
  end
  task "tail" do
    on release_roles(:mysql) do
      sudo "tail /var/log/mysql/error.log -f -n 1", raise_on_non_zero_exit: false
    end
  end
  task "tail:multi" do
    on release_roles(:mysql) do
      sudo "tail /var/log/syslog /var/log/mysql/error.log -f -n 1", raise_on_non_zero_exit: false
    end
  end
  task "ls:logs" do
    on release_roles(:mysql) do
      sudo "ls -lah /var/log/mysql/", raise_on_non_zero_exit: false
    end
  end
  task "ps" do
    on release_roles(:mysql) do
      execute 'ps aux | grep /usr/sbin/mysqld', raise_on_non_zero_exit: false
    end
  end
  task "size" do
    on release_roles(:mysql) do
      sudo "du -msh /var/lib/mysql", raise_on_non_zero_exit: false
    end
  end
end


