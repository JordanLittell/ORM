require_relative 'user'
require_relative 'question'

class Reply
  
  attr_accessor :id, :body, :question_id, :parent_id, :author_id
  
  def initialize(options={})
    @id = options['id']
    @body = options['body']
    @question_id = options['question_id']
    @parent_id = options['parent_id']
    @author_id = options['author_id']
  end
  
  def self.find_by_id(id)
    results = QuestionsDatabase.instance.execute(<<-SQL, id)
      SELECT
        *
      FROM
        replies
      WHERE
        id = ?
    SQL
    results.map { |result| self.new(result) }.first
  end
  
  def self.find_by_user_id(author_id)
    results = QuestionsDatabase.instance.execute(<<-SQL, author_id)
      SELECT
        *
      FROM
        replies
      WHERE
        author_id = ?
    SQL
    results.map { |result| Reply.new(result) }
  end
  
  def self.find_by_question_id(question_id)
    results = QuestionsDatabase.instance.execute(<<-SQL, question_id)
      SELECT
        *
      FROM
        replies
      WHERE
        question_id = ?
    SQL
    results.map { |result| Reply.new(result) }
  end
  
  def author
    User.find_by_id(author_id)
  end
  
  def question
    Question.find_by_id(question_id)
  end
  
  def parent_reply # will this throw an error on NULL?
    Reply.find_by_id(parent_id)
  end
  
  def child_replies
    results = QuestionsDatabase.instance.execute(<<-SQL, id)
      SELECT
        *
      FROM
        replies
      WHERE
        parent_id = ?
    SQL
    results.map { |result| Reply.new(result) }
  end
end