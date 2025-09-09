# == Schema Information
#
# Table name: quiz_attempts
#
#  id           :bigint           not null, primary key
#  completed_at :datetime
#  final_score  :float
#  user_answers :text
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#  quiz_id      :bigint           not null
#
# Indexes
#
#  index_quiz_attempts_on_quiz_id  (quiz_id)
#
# Foreign Keys
#
#  fk_rails_...  (quiz_id => quizzes.id)
#
class QuizAttempt < ApplicationRecord
  belongs_to :quiz
  
  validates :user_answers, presence: true
  validates :final_score, presence: true, inclusion: { in: 0..100 }
  
  def user_answers_hash
    JSON.parse(user_answers) rescue {}
  end
  
  def user_answers_hash=(answers)
    self.user_answers = answers.to_json
  end
  
  def completed?
    completed_at.present?
  end
end
