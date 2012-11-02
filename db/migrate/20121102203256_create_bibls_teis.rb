class CreateBiblsTeis < ActiveRecord::Migration
  def change
    create_table :bibls_teis, :id => false do |t|
      t.integer :bibl_id
      t.integer :tei_id
    end

    add_index :bibls_teis, [:bibl_id, :tei_id]
  end
end
