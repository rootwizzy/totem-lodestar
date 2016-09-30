class CreateTotemLodestarSections < ActiveRecord::Migration[5.0]
  def change
    create_table :totem_lodestar_sections do |t|
      t.string     :title
      t.string     :slug
      t.integer    :order

      t.references :parent
      t.belongs_to :version
      t.timestamps
    end
  end
end
