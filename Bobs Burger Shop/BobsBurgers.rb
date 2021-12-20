class Item 
  attr_accessor :cost, :name
  def initialize( name, cost )
      @name = name
      @cost = cost
  end

  def pretty_cost()
      return sprintf( "$%.02f" , @cost )
  end

  def print_cost()
      puts "$%.02f" % @cost
  end

  def update_cost(change)
      @cost += change
  end

  def update_name(name)
      @name = name
  end

  def get_name()
    return @name
  end

  def get_cost()
    return @cost
  end

end

class Burger < Item

  attr_accessor :toppings, :name, :numToppings
  def initialize
    super("Burger", 5.00)
    @numToppings = 0
    @toppings = Array.new
    addTopping("mustard")
    addTopping("ketchup")
    addTopping("lettuce")
    addTopping("tomato")
    addTopping("onion")
  end


  def addTopping(top)
    if !@toppings.include? top  
      @toppings[@numToppings] = top
      @numToppings += 1
    end
  end

  def removeTopping(topping)
    @toppings.delete(topping)
    @numToppings -= 1
  end

  def pretty_toppings()
    toppingStr = sprintf("\t* ")
    for topping in @toppings
      toppingStr.concat(topping.capitalize())
      toppingStr.concat(" ")
    end
    toppingStr.concat("\n")
    return toppingStr
  end

  def getToppings()
    return @toppings
  end
end

class BurgerOfTheDay < Burger

  attr_accessor :cost, :name, :toppings

  def initialize
      super
      update_name("Burger of the day")
      update_cost(0.95)

  end

  def getToppings()
    @toppings = super
  end

  def pretty_toppings()
    toppingStr = ""
    if @toppings.include? "cheese"
      toppingStr = sprintf("\t* add Cheese\n")
    end
    return toppingStr
  end

end

class Fries < Item

  def initialize
    super("Fries", 2.00)
  end
end

class Salad < Item

  def initialize
      super("Salad", 2.50)
  end
end

class SoftDrink < Item

  def initialize
      super("Soft Drink", 2.00)
  end
end

class Beer < Item

  def initialize
      super("Beer", 4.00)
  end
end

class Bill 

  attr_accessor :itemArr, :orderNum, :numItems, :total
  def initialize(orderNum)
      @itemArr = Array.new
      @orderNum = orderNum
      @numItems = 0
      @total = 0      
  end

  def add_item(item)
      @itemArr[@numItems] = item 
      @numItems += 1
  end

  def contains(item)
      @itemArr.include? item
  end

  def display_bill()
      puts pretty_bill()
  end

  def get_burger_number(number)
      burgerOBJ = Burger.new()
      if @numItems > 0
        
          for item in @itemArr
              if item.get_name() == "Burger" or item.get_name() == "Burger of the day"
                burgerOBJ = item
              end
          end
      end
      return burgerOBJ
  end 
  def pretty_total()
      return sprintf( "$%.02f" , @total )
  end

  def remove_item(item)
      @itemArr.delete(item)
      @numItems -= 1
  end

  def total()
    for item in @itemArr
      @total += item.get_cost()
    end
    return @total
  end

  def pretty_bill()
      temp1 = sprintf("\t%-35s Order:\t\t%d\n", "Guest Check", @orderNum)
      temp2 = "--------------------------------------------------\n"
      temp3 = sprintf("\t%-42s$%0.2f\n", "Total:", total())
      totalBill = ""
      totalBill.concat(temp1)
      totalBill.concat(temp2)
      for item in @itemArr
        totalBill.concat(sprintf("\t%-42s%s\n", item.get_name(), item.pretty_cost()))
          if item.instance_of? Burger
            totalBill.concat(item.pretty_toppings())
          end

          if item.instance_of? BurgerOfTheDay
            totalBill.concat(item.pretty_toppings())
          end
      end
      totalBill.concat(temp2)
      totalBill.concat(temp3)
      return totalBill
  end

  def update_order_number(number)
      @orderNum = number
  end
end

if ARGV.length != 2
  puts "We need an input file and an output file"
  exit
end

input = ARGV[0]
output = ARGV[1]
out = File.open(output, "w")
bill = Bill.new("") 
burgerCount = 0

File.readlines(input, chomp: true).each do |line|
  words = line.split(' ')
  if words[0].downcase == "order"
      bill.update_order_number(words[1])

  elsif words[0].downcase == "burger"
      if words[1] == "of"
          burgerOD = BurgerOfTheDay.new()
          bill.add_item(burgerOD)
          burgerCount += 1
      else 
          burger = Burger.new()
          bill.add_item(burger) 
          burgerCount += 1
      end  
      
  elsif words[0].downcase == "fries"
      fries = Fries.new()
      bill.add_item(fries)
  elsif words[0].downcase == "salad"
      salad = Salad.new()
      bill.add_item(salad)
  elsif words[0].downcase == "drink"
      softdrink = SoftDrink.new()
      bill.add_item(softdrink)
  elsif words[0].downcase == "beer"
      beer = Beer.new()
      bill.add_item(beer)
  elsif words[0].downcase == "add"   
      if burgerCount >= 1
          lastBurger = bill.get_burger_number(0)
          lastBurger.addTopping(words[1].downcase)
          if(words[1].downcase=="cheese")
            lastBurger.update_cost(0.50)
          end 
      end
  else
      if burgerCount >= 1
          lastBurger = bill.get_burger_number(0)
          lastBurger.removeTopping(words[1].downcase)
      end
  end
end
out.write(bill.pretty_bill())
out.close()