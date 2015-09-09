# encoding: utf-8
require 'sinatra'
require 'rubygems'
require "mysql"
require 'sinatra/activerecord'
require 'slim'


con = Mysql.new 'localhost', 'root', '42926238', 'nelisa_spaza_shop'

get '/' do
  slim :index
end

get '/popular_products' do
    @tasks = {}
    pop_prod = con.query("SELECT stock_item, SUM(no_sold) AS no_sold FROM sales_history GROUP BY stock_item ORDER BY no_sold DESC")
    pop_prod.each do |item|
    stock_item, no_sold = item.concat([no_sold])
    @tasks[stock_item] = no_sold                                                              
    end
    slim :popular_products
end
get '/popular_categories' do
     @tasks = {}
    cat = con.query('SELECT cat_name, SUM(no_sold) AS no_sold FROM sales_history INNER JOIN categories ON category_name=categories.cat_name GROUP BY cat_name ORDER BY no_sold DESC')
    cat.each do |item|
    stock_item, no_sold = item.concat([no_sold])
    @tasks[stock_item] = no_sold                                                              
    end
    slim :popular_categories 
end
get '/product_price_cost' do
    @tasks = {}
    prodPriceCost = con.query('SELECT stock_item, sales_price, cost FROM sales_history INNER JOIN purchase_history ON stock_item=purchase_history.item GROUP BY stock_item, sales_price, cost')
    prodPriceCost.each do |item|
    stock_item, sales_price, cost = item.concat([sales_price,cost])
    @tasks[stock_item] = [sales_price, cost]                                                            
    end
    slim :product_price_cost 
end
get '/product_earnings' do
    @tasks = {}
    prodEarnings = con.query('SELECT stock_item, SUM(earnings) AS earnings FROM (SELECT stock_item ,SUM(no_sold) AS no_sold, sales_price, SUM(no_sold)*CAST(SUBSTRING(sales_price, 2) AS DECIMAL(53, 2)) AS earnings  FROM sales_history GROUP BY sales_price, stock_item ORDER BY stock_item) AS sold_price_earn GROUP BY stock_item ORDER BY earnings DESC')
    prodEarnings.each do |item|
    stock_item, earnings = item.concat([earnings])
    @tasks[stock_item] = [earnings]                                                            
    end
    slim :product_earnings 
end
get '/product_profits' do
    @tasks = {}
    prodProfits = con.query('SELECT stock_item, avg_profit*no_sold AS profits FROM (SELECT stock_item, ROUND(SUM(profit)/SUM(1), 2) as avg_profit FROM (SELECT * FROM (SELECT stock_item, CAST(SUBSTRING(sales_price,2) AS DECIMAL(53,2)) AS price,CAST(SUBSTRING(cost, 2) AS DECIMAL(53,2)) AS cost, (CAST(SUBSTRING(sales_price,2) AS DECIMAL(53,2)) - CAST(SUBSTRING(cost, 2) AS DECIMAL(53,2))) AS profit FROM sales_history INNER JOIN purchase_history ON stock_item=item GROUP BY stock_item, price, cost) AS single_profits) AS single_profits GROUP BY stock_item) AS avg_prod_profits INNER JOIN product_sold ON product_name=stock_item ORDER BY profits DESC')
    prodProfits.each do |item|
    stock_item, profits = item.concat([profits])
    @tasks[stock_item] = [profits]                                                            
    end
    slim :product_profits 
end
get '/suppliers_popular_product' do
    @tasks = {}
    supPopProd = con.query('SELECT product_name, shop from product_sold INNER JOIN purchase_history ON item=product_name WHERE no_sold=(SELECT MAX(no_sold) FROM product_sold) GROUP BY product_name')
    supPopProd.each do |item|
    product_name, shop = item.concat([product_name])
    @tasks[shop] = [product_name]                                                            
    end
    slim :suppliers_popular_product 
end
get '/suppliers_profitable_product' do
    @tasks = {}
    supProfProd = con.query('SELECT MAX(profits), shop, stock_item FROM (SELECT shop, stock_item, (CAST(SUBSTRING(sales_price,2) AS DECIMAL(53,2))-CAST(SUBSTRING(cost, 2) AS DECIMAL(53,2)))*product_sold.no_sold AS profits FROM sales_history INNER JOIN purchase_history ON stock_item=item INNER JOIN product_sold ON product_name=item GROUP BY sales_history.stock_item ORDER BY profits DESC) AS prod_profits')
    supProfProd.each do |item|
    stock_item, shop, profits = item.concat([stock_item, profits])
    @tasks[shop] = [profits,stock_item]                                                            
    end
    slim :suppliers_profitable_product 
end
