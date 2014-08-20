require 'active_support/inflector'

module QueryHelperModule
  
  def table_name
    self.class.to_s.pluralize.underscore
  end
  
  def save
    var_names = self.instance_variables.map { |v| v.to_s.gsub('@', '') }
    var_vals = var_names.map { |var| self.instance_variable_get("@#{var}") }
    question_marks = "(#{var_vals.drop(1).map { "?" }.join(", ")})"
    update_string = var_names.drop(1).map { |var| "#{var} = ?" }.join(", ")
    
    if id.nil?
      QuestionsDatabase.instance.execute(<<-SQL, *var_vals.drop(1))
      INSERT INTO
        #{self.table_name} (#{var_names.drop(1).join(", ")})
      VALUES
        #{question_marks}
      SQL
      @id = QuestionsDatabase.instance.last_insert_row_id
    else
      QuestionsDatabase.instance.execute(<<-SQL, *var_vals.drop(1))
      UPDATE
        #{self.table_name}
      SET
        #{update_string}
      WHERE
        id = #{@id}
      SQL
    end
  end
end