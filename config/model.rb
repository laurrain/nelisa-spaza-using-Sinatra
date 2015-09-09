require 'sinatra/base'
require 'rubygems'
require 'active_record'
require 'mysql'


begin
    con = Mysql.new 'localhost', 'root', '42926238', 'nelisa_spaza_shop'

    rs = con.query("SELECT * FROM sales_history")
    
    rs.each do |row|
        puts row.join("\s")
    end
        
rescue Mysql::Error => e
    puts e.errno
    puts e.error
    
ensure
    con.close if con
end