class CreateTeis < ActiveRecord::Migration
  def change
    create_table :teis do |t|
      t.string :catalog_key
      t.string :title
      t.string :filename
      t.string :filepath
      t.string :pid
      t.string :description
      t.datetime :date_dl_ingest
      t.timestamps
    end
  end
end
