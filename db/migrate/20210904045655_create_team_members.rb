class CreateTeamMembers < ActiveRecord::Migration[6.1]
  def change
    create_table :team_members do |t|
      t.string :email, null: false, index: { unique: true }
      t.string :first_name
      t.string :last_name
      t.string :role

      t.timestamps
    end
  end
end
