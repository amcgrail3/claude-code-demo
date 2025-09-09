class QuizAttemptsController < ApplicationController
  before_action :set_quiz_attempt, only: [:show, :update]
  
  def show
    @current_question_number = calculate_current_question_number
    @current_question = @quiz_attempt.quiz.questions.find_by(question_number: @current_question_number)
    
    # Generate adaptive question if it doesn't exist
    if @current_question.nil? && @current_question_number <= 5
      begin
        generator = QuizGeneratorService.new(@quiz_attempt.quiz.topic)
        @current_question = generator.generate_adaptive_question(@quiz_attempt, @current_question_number)
      rescue => e
        redirect_to root_path, alert: "Error generating question: #{e.message}"
        return
      end
    end
    
    if @current_question_number > 5
      complete_quiz
      render :results
    end
  end

  def create
    @quiz = Quiz.find(params[:quiz_id])
    @quiz_attempt = @quiz.quiz_attempts.create!(
      user_answers: {}.to_json,
      final_score: 0.0
    )
    
    redirect_to quiz_attempt_path(@quiz_attempt)
  end

  def update
    user_answer = params[:answer]
    question_id = params[:question_id]
    
    if user_answer.present? && question_id.present?
      answers = @quiz_attempt.user_answers_hash
      answers[question_id] = user_answer
      @quiz_attempt.update!(user_answers: answers.to_json)
    end
    
    redirect_to quiz_attempt_path(@quiz_attempt)
  end
  
  private
  
  def set_quiz_attempt
    @quiz_attempt = QuizAttempt.find(params[:id])
  end
  
  def calculate_current_question_number
    return 1 if @quiz_attempt.user_answers_hash.empty?
    
    answered_count = @quiz_attempt.user_answers_hash.keys.count
    answered_count + 1
  end
  
  def complete_quiz
    return if @quiz_attempt.completed?
    
    openai_service = OpenaiService.new
    questions = @quiz_attempt.quiz.questions_ordered
    answers = @quiz_attempt.user_answers_hash
    
    final_score = openai_service.calculate_proficiency_score(answers, questions)
    
    @quiz_attempt.update!(
      final_score: final_score,
      completed_at: Time.current
    )
    
    @final_score = final_score
    @questions = questions
    @user_answers = answers
  end
end
