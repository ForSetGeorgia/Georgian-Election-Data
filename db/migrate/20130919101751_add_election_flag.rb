class AddElectionFlag < ActiveRecord::Migration
  def up
    add_column :event_types, :is_election, :boolean, :default => false
    add_index :event_types, :is_election 

    # add values
    ids = [1,3,4,5]
    EventType.where(:id => ids).update_all(:is_election => true)
    
  end

  def down
    remove_index :event_types, :is_election
    remove_column :event_types, :is_election
  end
end
