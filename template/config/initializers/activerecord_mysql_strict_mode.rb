class ActiveRecord::ConnectionAdapters::Mysql2Adapter

private
  alias_method :configure_connection_without_strict_mode, :configure_connection

  def configure_connection
    configure_connection_without_strict_mode
    execute "SET sql_mode='ansi,traditional'"
  end
end
