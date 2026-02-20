# frozen_string_literal: true

class SolidCache::InstallGenerator < Rails::Generators::Base
  source_root File.join(Gem.loaded_specs.fetch("solid_cache").full_gem_path, "lib/generators/solid_cache/install/templates")

  def copy_files
    template "config/cache.yml"

    if Rails.application.config.active_record.schema_format == :sql
      copy_sql_schema_for_adapter
    else
      template "db/cache_schema.rb"
    end
  end

  def configure_cache_store_adapter
    gsub_file Pathname.new(destination_root).join("config/environments/production.rb"),
      /(# )?config\.cache_store = (:.*)/, "config.cache_store = :solid_cache_store"
  end

  private
    def copy_sql_schema_for_adapter
      sql_file = sql_schema_file_for_adapter

      if sql_file
        copy_file sql_file, "db/cache_structure.sql"
      else
        raise_unsupported_adapter_error
      end
    end

    def sql_schema_file_for_adapter
      case current_adapter
      when "postgresql", "postgis"
        "db/cache_structure.postgresql.sql"
      when "mysql2", "trilogy"
        "db/cache_structure.mysql.sql"
      when "sqlite3"
        "db/cache_structure.sqlite3.sql"
      else
        nil
      end
    end

    def current_adapter
      ActiveRecord::Base.connection_db_config.adapter
    end

    def raise_unsupported_adapter_error
      error_message = <<~ERROR

        ERROR: Unsupported database adapter for SQL schema format: #{current_adapter.inspect}

        SolidCache supports installing for the following Rails adapters with schema_format = :sql:
          - PostgreSQL (postgresql, postgis)
          - MySQL (mysql2, trilogy)
          - SQLite (sqlite3)
      ERROR

      raise error_message
    end
end
