class CreateQuizAttempts < ActiveRecord::Migration[8.0]
  def change
    create_table :quiz_attempts do |t|
      t.references :quiz, null: false, foreign_key: true
      t.text :user_answers
      t.float :final_score
      t.datetime :completed_at

      t.timestamps
    end
  end
end
