class Todo < ApplicationRecord
  belongs_to :space, touch: true

  scope :completed, -> { where(completed: true) }
  scope :pending, -> { where(completed: false) }

  validates :name, presence: true

  after_create_commit :broadcast_create_later
  after_update_commit :broadcast_update_later
  after_destroy_commit :broadcast_destroy

  private

  def broadcast_create_later
    broadcast_render_later_to space,
                              partial: "todos/create",
                              locals: {
                                todo: self,
                                space: space
                              }
  end

  def broadcast_update_later
    broadcast_render_later_to space,
                              partial: "todos/update",
                              locals: {
                                todo: self,
                                space: space
                              }
  end

  def broadcast_destroy
    broadcast_render_to space, partial: "todos/destroy", locals: { todo: self }
  end
end
