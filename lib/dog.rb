require 'pry'
class Dog
    
    attr_accessor :name, :breed, :id

    def initialize(id:nil,name:,breed:)
        @name = name
        @breed = breed
        @id = id
    end

    def self.create_table
        sql = <<-SQL
            CREATE TABLE if NOT EXISTS dogs (
                id INTEGER PRIMARY KEY,
                name TEXT,
                breed TEXT
            );
            SQL
        DB[:conn].execute(sql)
    end

    def self.drop_table
       DB[:conn].execute("DROP TABLE dogs;")
    end

    def save
        if self.id
            update
        else
            sql = "INSERT INTO dogs (name, breed) VALUES (?,?)"
            DB[:conn].execute(sql,self.name,self.breed)
            @id = DB[:conn].execute("SELECT last_insert_rowid() FROM dogs")[0][0]
        end
        self
    end

    def self.create(name:, breed:)
        dog = self.new(name:name, breed:breed)
        dog.save
        dog
    end

    def self.find_by_id(id)
        dog = DB[:conn].execute("SELECT * FROM dogs WHERE id = ?", id).first
        dog = Dog.new(id:dog[0],name:dog[1],breed:dog[2])
        dog
    end

    def self.find_or_create_by(name:, breed:)
        dog = DB[:conn].execute("SELECT * FROM dogs WHERE name = ? AND breed = ?", name, breed)
        if dog.empty?
            dog = self.create(name:name, breed:breed)
        else
            dog = dog[0]
            dog = Dog.new(id:dog[0], name:dog[1], breed:dog[2])
        end
        dog
    end

    def self.new_from_db(row)
        self.create(name:row[1], breed:row[2])
    end

    def self.find_by_name(name)
        dog = DB[:conn].execute("SELECT * FROM dogs WHERE name = ?", name).first
        self.new(id:dog[0],name:dog[1],breed:dog[2])
    end

    def update
        DB[:conn].execute("UPDATE dogs SET name = ?, breed = ? WHERE id = ?", name,breed,id)
        self
    end
end