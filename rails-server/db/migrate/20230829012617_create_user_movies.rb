class CreateUserMovies < ActiveRecord::Migration[6.1]
  def change
    create_table :user_movies do |t|
      t.string :action_type
      t.references :user, null: false, foreign_key: true
      t.references :movie, null: false, foreign_key: true

      t.timestamps
    end
  end
end
