# frozen_string_literal: true

require 'ostruct'

module UsersHelper
  def user_roles_to_select
    Users::SchoolManagement.roles.map do |ruby_role, _pg_role|
      OpenStruct.new(value: ruby_role, text: I18n.t("enum.roles.#{ruby_role}"))
    end
  end

  def user_roles_without_school_manager_to_select
    roles = {
      teacher: 'teacher',
      main_teacher: 'main_teacher',
      other: 'other',
      cpe: 'cpe',
      admin_officer: 'admin_officer'
    }
    roles.map do |ruby_role, _pg_role|
      OpenStruct.new(value: ruby_role, text: I18n.t("enum.roles.#{ruby_role}"))
    end
  end

  def phone_pattern
    '^\+?(\d{2,3}\s?)?(\d{2}\s?){3,4}\d{2}$'
  end

  def field_phone_pattern
    '\A\+?(\d{2,3}\s?)?(\d{2}\s?){3,4}\d{2}\z'
  end

  def mail_pattern
    '^[a-z0-9._%+\\-]+@[a-z0-9.\\-]+\.[a-z]{2,}$'
  end

  def optional_phone_pattern
    "^$|#{phone_pattern}"
  end

  def optional_mail_pattern
    "^$|#{mail_pattern}"
  end
end
