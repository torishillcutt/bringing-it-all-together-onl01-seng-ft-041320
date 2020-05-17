class Dog
    attr_accessor :id, :name, :breed
  
    def initialize(attr_hash)
      attr_hash.each do |k,v|
        self.send("#{k}=", v)
      end 
    end
  
    def self.create_table
      sql = <<-SQL
        CREATE TABLE IF NOT EXISTS dogs (
            id INTEGER PRIMARY KEY,
            name TEXT,
            breed TEXT
        )
        SQL
      DB[:conn].execute(sql)
    end
  
    def self.drop_table
      sql = <<-SQL
        DROP TABLE IF EXISTS dogs
        SQL
      DB[:conn].execute(sql)
    end
  
    def save
      sql = <<-SQL
        INSERT INTO dogs (name, breed)
        VALUES (?, ?)
        SQL
      DB[:conn].execute(sql, self.name, self.breed)
      self.id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
      self
    end
  
    def self.create(attr_hash)
      self.new(attr_hash).save
    end
  
    def self.new_from_db(row)
      attr_hash = {:id => row[0], :name => row[1], :breed => row[2]}
      self.new(attr_hash)
    end
  
    def self.find_by_id(id)
      sql = <<-SQL
        SELECT * FROM dogs
        WHERE id = ?
        SQL
      row = DB[:conn].execute(sql, id)[0]
      self.new_from_db(row)
    end
  
    def self.find_or_create_by(attr_hash)
      sql = <<-SQL
        SELECT * FROM dogs
        WHERE name = ? AND breed = ?
        SQL
      dog_attr = DB[:conn].execute(sql, attr_hash[:name], attr_hash[:breed])[0]
      if dog_attr
          self.find_by_id(dog_attr[0])
      else
          self.create(attr_hash)
      end
    end
  
    def self.find_by_name(name)
      sql = <<-SQL
        SELECT * FROM dogs
        WHERE name = ?
        SQL
      DB[:conn].execute(sql, name).map do |row|
          self.new_from_db(row)
      end.first
    end
  
    def update
      sql = <<-SQL
        UPDATE dogs
        SET name = ?, breed = ?
        WHERE id = ?
        SQL
      DB[:conn].execute(sql, self.name, self.breed, self.id)
    end
  end  