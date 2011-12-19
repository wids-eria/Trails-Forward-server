class ChangeYearsToDatesInWorlds < ActiveRecord::Migration
  def up
    add_column :worlds, :start_date, :date
    add_column :worlds, :current_date, :date

    World.all.each do |world|
      world.update_attributes(start_date: Date.new(world.year_start, 1, 1),
                              current_date: Date.new(world.year_current, 1, 1))
    end

    remove_column :worlds, :year_start
    remove_column :worlds, :year_current
  end

  def down
    add_column :worlds, :year_current, :integer
    add_column :worlds, :year_start, :integer

    World.all.each do |world|
      world.update_attributes(year_start: world.start_date.year, year_current: world.current_date.year)
    end

    remove_column :worlds, :current_date
    remove_column :worlds, :start_date
  end
end
