namespace "nginx" do
  task "start" do
    on release_roles(:nginx) do
      sudo "systemctl start nginx.service"
    end
  end
  task "stop" do
    on release_roles(:nginx) do
      sudo "systemctl stop nginx.service"
    end
  end
  task "reload" do
    on release_roles(:nginx) do
      sudo "systemctl reload nginx.service"
    end
  end
  task "restart" do
    on release_roles(:nginx) do
      sudo "systemctl restart nginx.service"
    end
  end
  task "status" do
    on release_roles(:nginx) do
      sudo "systemctl status nginx.service"
    end
  end
end
