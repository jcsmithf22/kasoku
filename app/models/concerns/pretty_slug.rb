module PrettySlug
  extend ActiveSupport::Concern

  included do
    before_create :set_slug
    class_attribute :slug_prefix, instance_writer: false
    class_attribute :slug_length, instance_writer: false, default: 12
    class_attribute :slug_column, instance_writer: false, default: :slug
    class_attribute :slug_separator, instance_writer: false, default: "_"
  end

  private

  def default_prefix
    self.class.name.downcase[0..2]
  end

  def set_slug
    slug = generate_slug
    attempts = 1

    while self.class.exists?(self.class.slug_column => slug) && attempts < 4
      slug = generate_slug
      attempts += 1
    end

    write_attribute(self.class.slug_column, slug)
  end

  def generate_slug
    "#{self.class.slug_prefix || default_prefix}#{self.class.slug_separator}#{SecureRandom.hex((self.class.slug_length / 2).to_i)}"
  end
end
