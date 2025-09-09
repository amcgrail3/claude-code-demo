class OpenaiService
  include HTTParty
  
  base_uri 'https://api.openai.com/v1'
  
  def initialize
    @api_key = ENV['OPENAI_API_KEY']
    @headers = {
      'Content-Type' => 'application/json',
      'Authorization' => "Bearer #{@api_key}"
    }
  end
  
  def generate_question(topic, difficulty_level, previous_questions = [])
    difficulty_description = {
      1 => "very easy, basic level",
      2 => "easy, beginner level", 
      3 => "medium, intermediate level",
      4 => "hard, advanced level",
      5 => "very hard, expert level"
    }
    
    previous_questions_text = previous_questions.any? ? 
      "Previous questions asked: #{previous_questions.map(&:content).join('; ')}" : ""
    
    prompt = <<~PROMPT
      Generate a #{difficulty_description[difficulty_level]} multiple choice question about #{topic}.
      
      #{previous_questions_text}
      
      Requirements:
      - Don't repeat previous questions
      - Provide exactly 4 answer options (A, B, C, D)
      - Clearly indicate which is the correct answer
      - Make the question appropriate for the difficulty level
      
      Format your response as JSON:
      {
        "question": "Your question here",
        "options": {
          "A": "First option",
          "B": "Second option", 
          "C": "Third option",
          "D": "Fourth option"
        },
        "correct_answer": "A"
      }
    PROMPT
    
    body = {
      model: 'gpt-3.5-turbo',
      messages: [
        {
          role: 'user',
          content: prompt
        }
      ],
      temperature: 0.7,
      max_tokens: 500
    }
    
    response = self.class.post('/chat/completions', 
      body: body.to_json, 
      headers: @headers
    )
    
    if response.success?
      content = response.dig('choices', 0, 'message', 'content')
      JSON.parse(content)
    else
      raise "OpenAI API error: #{response.code} - #{response.message}"
    end
  end
  
  def calculate_proficiency_score(answers, questions)
    return 0 if questions.empty?
    
    correct_count = 0
    total_difficulty_points = 0
    earned_difficulty_points = 0
    
    answers.each_with_index do |(question_id, user_answer), index|
      question = questions.find { |q| q.id.to_s == question_id.to_s }
      next unless question
      
      total_difficulty_points += question.difficulty_level * 20
      
      if user_answer == question.correct_answer
        correct_count += 1
        earned_difficulty_points += question.difficulty_level * 20
      end
    end
    
    return 0 if total_difficulty_points == 0
    (earned_difficulty_points.to_f / total_difficulty_points * 100).round(1)
  end
end