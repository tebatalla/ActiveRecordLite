require_relative '02_searchable'
require 'active_support/inflector'

# Phase IIIa
class AssocOptions
  attr_accessor(
    :foreign_key,
    :class_name,
    :primary_key
  )

  def model_class
    # ...
    self.class_name.constantize
  end

  def table_name
    # ...
    model_class.table_name
  end
end

class BelongsToOptions < AssocOptions
  def initialize(name, options = {})
    # ...
    defaults = {
      foreign_key: "#{name.to_s.singularize}_id".to_sym,
      primary_key: :id,
      class_name: "#{name}".singularize.camelcase
    }

    defaults.merge(options).each do |k, v|
      self.send("#{k}=", v)
    end
  end
end

class HasManyOptions < AssocOptions
  def initialize(name, self_class_name, options = {})
    # ...
    defaults = {
      foreign_key: "#{self_class_name.to_s.underscore.singularize}_id".to_sym,
      primary_key: :id,
      class_name: "#{name}".singularize.camelcase
    }

    defaults.merge(options).each do |k, v|
      self.send("#{k}=", v)
    end
  end
end

module Associatable
  # Phase IIIb
  def belongs_to(name, options = {})
    # ...
    options = BelongsToOptions.new(name, options)
    define_method(name) do
      fk = self.send(options.foreign_key)
      options.model_class.where(options.primary_key => fk)[0]
    end
  end

  def has_many(name, options = {})
    # ...
    options = HasManyOptions.new(name, self, options)
    define_method(name) do
      pk = self.send(options.primary_key)
      options.model_class.where(options.foreign_key => pk)
    end
  end

  def assoc_options
    # Wait to implement this in Phase IVa. Modify `belongs_to`, too.
  end
end

class SQLObject
  # Mixin Associatable here...
  extend Associatable
end
