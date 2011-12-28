width =  1400
height = 800

partition_width = 400
partition_height = 400

create_sql = ''

%w(agents resource_tiles).each do |base_table|
trigger_prefix = "CREATE OR REPLACE FUNCTION #{base_table}_insert_trigger()
RETURNS TRIGGER AS $$
BEGIN
  "
trigger_suffix = "E
    RAISE EXCEPTION '#{base_table.gsub('_', ' ').capitalize} location out of range.  Fix the #{base_table}_insert_trigger() function!';
  END IF;
  RETURN NULL;
END;
$$
LANGUAGE plpgsql;
"
trigger_body = ''

(0..width).step(partition_width) do |x_min|
  x_max = x_min + partition_width
  (0..height).step(partition_height) do |y_min|
    y_max = y_min + partition_height
    table_name = "#{base_table}_x#{x_min}_y#{y_min}"
    create_sql += <<EOS
CREATE TABLE #{table_name} (
  CHECK ( x >= #{x_min} AND x < #{x_max}
    AND y >= #{y_min} AND y < #{y_max} )
) INHERITS (#{base_table});

CREATE INDEX #{table_name}_x_y ON #{table_name} (x,y);

EOS

  trigger_body += "IF ( x >= #{x_min} AND x < #{x_max} AND y >= #{y_min} AND y < #{y_max} ) THEN
    INSERT INTO #{table_name} VALUES (NEW.*);
  ELS"
  end
end

create_sql += trigger_prefix + trigger_body + trigger_suffix
end

puts create_sql
