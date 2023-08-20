class AddMovies < ActiveRecord::Migration[6.1]
  def change
    create_table :movies do |t|
      t.string :title
      t.text :description
      t.text :info
      t.text :url_share
      t.text :youtube_id
      t.text :user_email

      t.timestamps
    end
  end
end
