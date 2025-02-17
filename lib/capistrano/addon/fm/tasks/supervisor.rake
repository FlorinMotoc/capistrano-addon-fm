namespace "supervisor" do
  task "start" do
    on release_roles(:supervisor) do
      sudo "supervisorctl start all", raise_on_non_zero_exit: false
    end
  end
  task "stop" do
    on release_roles(:supervisor) do
      sudo "supervisorctl stop all", raise_on_non_zero_exit: false
    end
  end
  task "restart" do
    on release_roles(:supervisor) do
      invoke! "supervisor:stop"
      invoke! "supervisor:start"
    end
  end
  task "reread" do
    on release_roles(:supervisor) do
      sudo "supervisorctl reread", raise_on_non_zero_exit: false
    end
  end
  task "update" do
    on release_roles(:supervisor) do
      sudo "supervisorctl update", raise_on_non_zero_exit: false
    end
  end
  task "status" do
    on release_roles(:supervisor) do
      sudo "supervisorctl status", raise_on_non_zero_exit: false
    end
  end
end
