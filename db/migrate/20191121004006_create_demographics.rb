class CreateDemographics < ActiveRecord::Migration[6.0]
  def change
    create_table :demographics do |t|
      t.belongs_to :user, null: false, foreign_key: true
      t.string :first_names, null: false
      t.string :last_names, null: false
      t.boolean :deaf, null: false
      t.boolean :nzsl_first_language, null: false
      t.string :age_bracket
      t.string :location
      t.string :gender
      t.string :ethnicity
      t.string :language_roles, array: true, default: []
      t.string :subject_expertise

      t.timestamps
    end
  end
end
