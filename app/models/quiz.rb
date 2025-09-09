# == Schema Information
#
# Table name: quizzes
#
#  id         :bigint           not null, primary key
#  topic      :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
class Quiz < ApplicationRecord
  has_many :questions, dependent: :destroy
  has_many :quiz_attempts, dependent: :destroy
  
  validates :topic, presence: true
  
  def questions_ordered
    questions.order(:question_number)
  end
end
