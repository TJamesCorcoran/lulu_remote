#require 'mechanize'
require 'csv'
require 'selenium-webdriver'
require 'capybara'

puts "UTILITIES"

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
  
  def self.add_book_to_cart(url)
    #    @@agent.get(url)
    #    buy_form               = login_page.form_with(:id=>"add-to-cart")
    #    cart_page           = @@agent.submit(buy_form)

    @@sel.visit(url)
    
  end

  def self.add_coupon(coupon_str)
    # @@agent.get(CART_URL)    
    # coupon_form               = login_page.form_with(:id=>"shoppingCartForm")
    # login_form["code"]    = config.username    
    # cart_page           = @@agent.submit(buy_form)
  end

  def self.start_checkout()

  end    

  def self.login
    verbose = true

    @@sel = Capybara::Session.new(:selenium)    # selenium supports javascript
    @@sel.visit(LOGIN_URL)

    @@sel.fill_in('loginEmail', :with => config.username)
    @@sel.fill_in('loginPassword', :with => config.password)

    sleep(10)
    
    return yield if block_given?
  ensure
    logout if block_given?
  end
  
  # def self.login
  #   verbose = true
  
  #   # See if we're already logged in
  #   # raise 'Already logged into Lulu' if @@agent.cookies.detect { |cookie| cookie.name == LOGIN_COOKIE_NAME }
  #   reset_agent
  
  #   login_page               = @@agent.get(LOGIN_URL)
  #   login_form               = login_page.form_with(:id=>"login")
  #   puts "login_form = #{login_form.inspect}" 
  #   login_form["loginEmail"]    = config.username
  #   login_form["loginPassword"] = config.password
  #   login_form["userid"]    = config.username
  #   login_form["password"] = config.password
  #   puts "login_form = #{login_form.inspect}" # NOTFORCHECKIN
  #   logged_in_page           = @@agent.submit(login_form)

  #   #    puts logged_in_page.body.inspect
  #   unless logged_in_page.body.match("Welcome back")
  #     raise 'Login to Lulu failed'
  #     Misc::response_to_chrome(logged_in_page)
  #   end

  #   puts "* logged in body = #{logged_in_page.body.inspect}"  if verbose
  #   puts "* logged in keys = #{@@agent.cookie_jar.jar.first[1].first[1].keys.inspect}" if verbose
  

  #     Misc::response_to_chrome(logged_in_page)
  #   raise 'post login: missing cookies' unless @@agent.cookies.detect { |cookie| cookie.name == LOGIN_COOKIE_NAME }
  
  #   return yield if block_given?
  # ensure
  #   logout if block_given?
  # end

  # def self.logout
  #   # Log the session out
  #   @@agent.get(LOGOUT_URL)
  #   # Delete the cookies so we realize we're logged out
  #   @@agent.cookie_jar.clear!
  # end

  


  


  
end
