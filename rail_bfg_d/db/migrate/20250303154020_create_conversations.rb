class CreateConversations < ActiveRecord::Migration[8.0]
  def change
    create_table :conversations do |t|
      t.string :channel_id
      t.string :thread_id
      t.text :prompt
      t.text :response
      t.datetime :timestamp

      t.timestamps
    end
  end
end
