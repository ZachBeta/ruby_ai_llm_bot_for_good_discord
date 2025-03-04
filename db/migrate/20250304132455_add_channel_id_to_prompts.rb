class AddChannelIdToPrompts < ActiveRecord::Migration[8.0]
  def change
    add_column :prompts, :channel_id, :string
  end
end
