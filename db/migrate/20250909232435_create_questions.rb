class CreateQuestions < ActiveRecord::Migration[8.0]
  def change
    create_table :questions do |t|
      t.references :quiz, null: false, foreign_key: true
      t.text :content
      t.text :answer_options
      t.string :correct_answer
      t.integer :difficulty_level
      t.integer :question_number

      t.timestamps
    end
  end
end
