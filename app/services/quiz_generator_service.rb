class QuizGeneratorService
  def initialize(topic)
    @topic = topic
    @openai_service = OpenaiService.new
  end
  
  def generate_quiz
    quiz = Quiz.create!(topic: @topic)
    
    # Generate first 2 questions with fixed difficulty
    2.times do |index|
      difficulty_level = determine_initial_difficulty(index + 1)
      
      question_data = @openai_service.generate_question(
        @topic, 
        difficulty_level, 
        quiz.questions
      )
      
      quiz.questions.create!(
        content: question_data['question'],
        answer_options: question_data['options'].to_json,
        correct_answer: question_data['correct_answer'],
        difficulty_level: difficulty_level,
        question_number: index + 1
      )
      
      sleep(1)
    end
    
    quiz
  end
  
  def generate_adaptive_question(quiz_attempt, question_number)
    quiz = quiz_attempt.quiz
    answers = quiz_attempt.user_answers_hash
    previous_questions = quiz.questions.where('question_number < ?', question_number)
    
    difficulty_level = determine_adaptive_difficulty(answers, previous_questions, question_number)
    
    question_data = @openai_service.generate_question(
      quiz.topic,
      difficulty_level,
      previous_questions
    )
    
    quiz.questions.create!(
      content: question_data['question'],
      answer_options: question_data['options'].to_json,
      correct_answer: question_data['correct_answer'],
      difficulty_level: difficulty_level,
      question_number: question_number
    )
  end
  
  private
  
  def determine_initial_difficulty(question_number)
    case question_number
    when 1, 2
      2
    when 3
      3
    when 4, 5
      3
    end
  end
  
  def determine_adaptive_difficulty(answers, previous_questions, question_number)
    return 2 if previous_questions.empty?
    
    recent_questions = previous_questions.order(:question_number).last(2)
    recent_correct = 0
    
    recent_questions.each do |question|
      user_answer = answers[question.id.to_s]
      recent_correct += 1 if user_answer == question.correct_answer
    end
    
    last_question = recent_questions.last
    current_difficulty = last_question&.difficulty_level || 2
    
    case recent_correct
    when 2
      [current_difficulty + 1, 5].min
    when 1
      current_difficulty
    when 0
      [current_difficulty - 1, 1].max
    else
      current_difficulty
    end
  end
end