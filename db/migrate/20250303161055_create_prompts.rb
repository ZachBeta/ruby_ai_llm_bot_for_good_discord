class CreatePrompts < ActiveRecord::Migration[8.0]
  def change
    create_table :prompts do |t|
      t.text :content
      t.string :name

      t.timestamps
    end
  end
end
