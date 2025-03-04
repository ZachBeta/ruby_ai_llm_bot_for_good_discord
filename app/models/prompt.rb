class Prompt < ApplicationRecord
  validates :name, presence: true, uniqueness: { scope: :channel_id }
  validates :content, presence: true
end
