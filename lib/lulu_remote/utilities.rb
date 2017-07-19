require 'csv'
require 'selenium-webdriver'
require 'capybara'

module LuluRemote

  @@sel = Capybara::Session.new(:selenium)    
  
  # def self.get_agent()    @@agent   end
  # def self.get_cookies()    @@agent.cookie_jar.jar.first[1].first[1].keys   end
  #  @@agent = Mechanize.new
  #  @@agent.user_agent = "Mozilla/5.0 (X11; U; Linux i686; en-US; rv:1.9.2.13) Gecko/20101206 Ubuntu/10.04 (lucid) Firefox/3.6.13"
  #  @@agent.post_connect_hooks << MechanizeCleanupHook.new

  LOGIN_COOKIE_NAME = ".lulu.com"
  LOGIN_URL         = "https://www.lulu.com/account/sign-in"
  LOGOUT_URL        = "https://www.lulu.com/account/logout"
  CART_URL          = "https://www.lulu.com/shop/view-cart.ep"

  VERBOSE = true
  
  def self.add_book_to_cart(url)
    puts "-- add book" if VERBOSE
    @@sel.visit(url)
    @@sel.find("form#addToCartForm button").click
    { :success => true }
  end


  #--------------------
  # checkout process
  #--------------------  

  def self.empty_cart
    puts "-- empty_cart" if VERBOSE
    @@sel.visit(CART_URL)
    while @@sel.first("div.remove-cart-item-link a") do
      puts "delete 1"
      @@sel.first("div.remove-cart-item-link a").click
    end
    { :success => true }
  end
  
  def self.add_coupon(coupon_str)
    puts "-- add_coupon" if VERBOSE
    @@sel.visit(CART_URL)
    @@sel.find("div.couponCode input#code").set(coupon_str)
    @@sel.find("div.couponCode a.luluBtnSmall").click()

    return {:success => false, :error_msg => "coupon not applied", :body => @@sel.body} unless @@sel.first("tr.discount.coupon")
    return {:success => true}
  end

  # checkout step 1a
  #
  def self.start_checkout()
    puts "-- start_checkout" if VERBOSE
    @@sel.visit(CART_URL)
    @@sel.find("#checkoutButton").click
    return {:success => false, :error_msg => "wrong page?" , :body => @@sel.body} unless @@sel.first("li.step-one.current")    
    {:success => true }
  end    

  # checkout step 1b - optional
  #
  def self.add_address(full_name, addr_1, addr_2, city, state_code, zip, phone, country_code)
    puts "-- add_address" if VERBOSE

    return { :success => false, :error_msg => "wrong start page" } unless @@sel.first("li.step-one.current")    
    return { :success => false, :error_msg => "state code bad"   } if state_code.size != 2
    return { :success => false, :error_msg => "country code bad" } if country_code.size != 2
    return { :success => false, :error_msg => "phone bad"        } if phone.nil?

    @@sel.find("div.new-address a").click()

    @@sel.select(state_code, :from => "select#address\\.country") if country_code != "US"
    return { :success => false, :error_msg => "can't find form" , :body => @@sel.body}  unless     @@sel.first("input#address\\.fullName")
    @@sel.find("input#address\\.fullName").set(full_name)
    @@sel.find("input#address\\.street1").set(addr_1)
    @@sel.find("input#address\\.street2").set(addr_2) if addr_2
    @@sel.find("input#address\\.city").set(city)
    @@sel.find("input#address\\.zipOrPostalCode").set(zip)
    @@sel.find("input#address\\.phoneNumber").set(phone)
    return { :success => false, :error_msg => "can't find select" , :body => @@sel.body}  unless     @@sel.first("select#address\\.subCountry")

    # @@sel.select(state_code, :from => "address.subCountry")
    @@sel.find("option[value=\"#{state_code}\"]").click

    @@sel.find("div.save-button button").click()

    return { :success => false, :error_msg => "error in address" , :body => @@sel.body}  if @@sel.first("div.feedback.error", :text => "We couldn't validate")
    return { :success => false, :error_msg => "address not set" , :body => @@sel.body}  if ! @@sel.first("div.name", :text => full_name)
    return { :success => true }
  end

  # checkout step 1c
  #
  def self.choose_shipping_option(option = :mail)
    puts "-- choose_shipping_option" if VERBOSE
    return false unless [:mail, :ground, :expedited, :express].include?(option)
    return false unless @@sel.first("li.step-one.current")
    
    id = {:mail      => 100100,
          :ground    => 100102,
          :expedited => 100103,
          :express   => 100104
         }[option]
    
    @@sel.choose("selectedShippingServiceLevel", option: id.to_s)

    @@sel.find("div.save-button").click

    return { :success => true }
  end

  # checkout step 2
  #
  def self.billing(security_code)
    puts "-- billing" if VERBOSE
    return {:success => false, :error_msg => "starts at wrong step", :body => @@sel.body} unless @@sel.first("li.step-two.current")

    @@sel.fill_in('securityCode', :with => security_code)
    @@sel.find("div.save-button").click

    return {:success => false, :error_msg => "ends at wrong step", :body => @@sel.body} unless @@sel.first("li.step-three.current")
    return {:success => true }
  end

  # checkout step 3
  #
  #
  # returns 
  #   { :success     => <bool>,
  #     :error_msg   => <str>,  [ OPT ]
  #     :order_num   => <num>,  [ OPT ]
  #     :total_price => <num>   [ OPT ]
  #   }
  def self.review
    puts "-- review" if VERBOSE
    return {:success => false, :error_msg => "wrong page before", :body => @@sel.body} unless @@sel.first("li.step-three.current")
    @@sel.first("div.save-button button").click
    sleep(5)
    return {:success => false, :error_msg => "wrong page after", :body => @@sel.body} unless @@sel.first("li.step-four.current")

    raw_text = @@sel.find("div.order-number").text
    match = raw_text.match(/Your order number is ([0-9]+)/)
    return {:success => false, :error_msg => "can't find order number", :body => @@sel.body} unless match
    order_num = $1.to_i

    raw_text = @@sel.find("tr.order-total td.amount span.value").text
    match = raw_text.match(/\$([0-9]+\.[0-9][0-9])/)
    return{:success => false, :error_msg => "can't find total price", :body => @@sel.body} unless match
    total_price = $1.to_f
    
    return{:success => true, :order_num => order_num, :total_price => total_price }
  end

  #--------------------
  # login / logout
  #--------------------  
  def self.logout
    puts "-- logout" if VERBOSE
    @@sel.visit(LOGOUT_URL)
  end


  
  def self.login
    verbose = true

    @@sel = Capybara::Session.new(:selenium)    # selenium supports javascript
    @@sel.visit(LOGIN_URL)

    @@sel.fill_in('loginEmail', :with => config.username)
    @@sel.fill_in('loginPassword', :with => config.password)
    @@sel.find_button('Log In').click
    
    return yield if block_given?
  ensure
    logout if block_given?
  end
  
end
