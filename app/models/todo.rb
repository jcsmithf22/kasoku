class Todo < ApplicationRecord
  belongs_to :space

  scope :completed, -> { where(completed: true) }
  scope :pending, -> { where(completed: false) }

  validates :name, presence: true
end
