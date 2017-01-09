class CreateTotemLodestarApi < ActiveRecord::Migration[5.0]
  def change
    create_table :totem_lodestar_apis do |t|
      t.string  :title
      t.string  :slug
      t.timestamps
    end
  end
end
