class CreatePanels < ActiveRecord::Migration
  def self.up
    create_table :panels do |t|
      t.string :value, :length => 80
      t.string :ip, :length => 15
      t.string :user

      t.references :status
      t.references :place

      t.timestamps
    end
  end

  def self.down
    drop_table :panels
  end
end
