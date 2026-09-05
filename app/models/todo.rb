class Todo < ApplicationRecord
  belongs_to :space, touch: true

  scope :completed, -> { where(completed: true) }
  scope :pending, -> { where(completed: false) }

  validates :name, presence: true

  after_create_commit :broadcast_todo_addition
  after_update_commit :broadcast_todo_update
  after_destroy_commit :broadcast_todo_removal

  private
    def broadcast_todo_addition
      broadcast_render_later_to space, partial: "todos/create", locals: { todo: self, space: space }
    end

    def broadcast_todo_update
      broadcast_render_later_to space, partial: "todos/update", locals: { todo: self, space: space }
    end

    def broadcast_todo_removal
      broadcast_render_to space, partial: "todos/destroy", locals: { todo: self }
    end
end
