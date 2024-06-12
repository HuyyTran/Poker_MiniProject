class CreatePokerCombinations < ActiveRecord::Migration[7.0]
  def change
    create_table :poker_combinations do |t|
      t.string :card
      t.string :hand
      t.boolean :best

      t.timestamps
    end
  end
end
