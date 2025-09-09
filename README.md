# AI Quiz Platform

An intelligent quiz application that uses OpenAI to generate adaptive questions based on any topic and assess user proficiency.

## Features

- **Dynamic Topic Selection**: Users can enter any topic they want to be quizzed on
- **Adaptive Difficulty**: Questions get harder if you're doing well, easier if you're struggling
- **AI-Powered Questions**: Uses OpenAI's GPT-3.5-turbo to generate relevant multiple choice questions
- **Proficiency Scoring**: Final score reflects knowledge level based on difficulty-weighted performance
- **Quiz History**: Track your attempts and see improvement over time
- **Resume Capability**: Continue incomplete quizzes where you left off

## Setup Instructions

1. **Install Dependencies**:
   ```bash
   bundle install
   ```

2. **Setup Database**:
   ```bash
   rails db:migrate
   ```

3. **Configure OpenAI API**:
   - Copy the example environment file:
     ```bash
     cp .env.example .env
     ```
   - Add your OpenAI API key to the `.env` file:
     ```
     OPENAI_API_KEY=your_actual_openai_api_key_here
     ```

4. **Start the Server**:
   ```bash
   rails server
   ```

5. **Visit the App**:
   Open your browser to `http://localhost:3000`

## How It Works

1. **Enter a Topic**: Type in any subject you want to be quizzed on (e.g., "JavaScript", "World History", "Biology")
2. **Take the Quiz**: Answer 5 multiple choice questions
3. **Adaptive Difficulty**: 
   - First 2 questions start at beginner/easy level
   - Questions 3-5 adapt based on your performance:
     - Get both recent questions right → difficulty increases
     - Get one right → difficulty stays the same  
     - Get both wrong → difficulty decreases
4. **View Results**: See your proficiency score (0-100%) and detailed question review
5. **Track Progress**: Return to view quiz history and retake quizzes to improve

## Technical Details

### Models
- **Quiz**: Stores topic and has many questions/attempts
- **Question**: Stores question content, options, correct answer, and difficulty level (1-5)
- **QuizAttempt**: Tracks user answers and final score for each quiz session

### Adaptive Algorithm
- Difficulty levels: 1 (very easy) to 5 (very hard/expert)
- Score calculation weights correct answers by difficulty level
- Questions 3-5 dynamically adjust based on recent performance

### Services
- **OpenaiService**: Handles API calls to generate questions and calculate scores
- **QuizGeneratorService**: Manages quiz creation and adaptive question generation

## Requirements

- Ruby on Rails 8.0+
- PostgreSQL database
- OpenAI API key

Some rights reserved — see [LICENSE.txt](LICENSE.txt)
