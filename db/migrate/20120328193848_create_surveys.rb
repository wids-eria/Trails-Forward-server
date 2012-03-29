class CreateSurveys < ActiveRecord::Migration
  def change
    create_table :surveys do |t|
      t.date :capture_date

      t.timestamps
    end
  end
end
