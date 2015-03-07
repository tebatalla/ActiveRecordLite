require_relative 'db_connection'
require_relative '01_sql_object'

module Searchable
  def where(params)
    # ...
    Relation.new(self).where(params).evaluate
  end

  # def includes(params)
  #   Relation.new(self.parse_all(DBConnection.execute(<<-SQL,other_table)))
  #   SELECT
  #     *
  #   FROM
  #     #{self.table_name}
  #   JOIN
  #     #{other_table}
  #   ON
  #     #{self}
  #
  #   SQL
  # end
end

class SQLObject
  # Mixin Searchable here...
  extend Searchable
end

class Relation
  extend Searchable
  def criteria
    @criteria ||= {:conditions => {}}
  end

  def where(args)
    criteria[:conditions].merge!(args)
    self
  end

  def initialize(klass)
    @klass = klass
  end

  def evaluate
    where_line = criteria[:conditions].keys.map{ |k| "#{k} = ?" }.join(' AND ')
    @klass.parse_all(DBConnection.execute(<<-SQL,*criteria[:conditions].values))
    SELECT
      *
    FROM
      #{@klass.table_name}
    WHERE
      #{where_line}
    SQL
  end
end
