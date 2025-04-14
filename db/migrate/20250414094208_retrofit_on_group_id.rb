class RetrofitOnGroupId < ActiveRecord::Migration[7.1]
  def up
    Rake::Task['retrofit:nullify_group_id'].invoke
  end

  def down
  end
end
