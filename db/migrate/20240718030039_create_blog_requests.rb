class CreateBlogRequests < ActiveRecord::Migration[7.1]
  def change
    create_table :blog_requests do |t|
      t.string :webhook_url
      t.integer :category, default: 0

      t.timestamps
    end
  end
end
