class QuizzesController < ApplicationController
  def index
    @quizzes = Quiz.includes(:quiz_attempts).order(created_at: :desc).limit(20)
  end

  def show
    @quiz = Quiz.find(params[:id])
    @quiz_attempts = @quiz.quiz_attempts.where(completed_at: nil).order(created_at: :desc)
  end

  def new
    @quiz = Quiz.new
  end

  def create
    topic = params[:quiz][:topic]
    
    if topic.blank?
      redirect_to new_quiz_path, alert: "Please enter a topic"
      return
    end
    
    begin
      generator = QuizGeneratorService.new(topic)
      @quiz = generator.generate_quiz
      
      quiz_attempt = @quiz.quiz_attempts.create!(
        user_answers: {}.to_json,
        final_score: 0.0
      )
      
      redirect_to quiz_attempt_path(quiz_attempt)
    rescue => e
      redirect_to new_quiz_path, alert: "Error creating quiz: #{e.message}"
    end
  end
end
