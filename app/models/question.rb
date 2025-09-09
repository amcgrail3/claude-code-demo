# == Schema Information
#
# Table name: questions
#
#  id               :bigint           not null, primary key
#  answer_options   :text
#  content          :text
#  correct_answer   :string
#  difficulty_level :integer
#  question_number  :integer
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  quiz_id          :bigint           not null
#
# Indexes
#
#  index_questions_on_quiz_id  (quiz_id)
#
# Foreign Keys
#
#  fk_rails_...  (quiz_id => quizzes.id)
#
class Question < ApplicationRecord
  belongs_to :quiz
  
  validates :content, presence: true
  validates :answer_options, presence: true
  validates :correct_answer, presence: true
  validates :difficulty_level, presence: true, inclusion: { in: 1..5 }
  validates :question_number, presence: true
  
  def answer_options_array
    JSON.parse(answer_options) rescue []
  end
  
  def answer_options_array=(options)
    self.answer_options = options.to_json
  end
end
