# frozen_string_literal: true

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
      other: 'other', cpe: 'cpe',
      admin_officer: 'admin_officer' }
    roles.map do |ruby_role, _pg_role|
      OpenStruct.new(value: ruby_role, text: I18n.t("enum.roles.#{ruby_role}"))
    end
  end
end
