require 'json'

class Flash
  def initialize(req)
    cookies = req.cookies['_rails_lite_app_flash']
    unless cookies.nil?
      @now_cookie = JSON.parse(cookies)
    else
      @now_cookie = {}
    end
    @cookie = {} 
  end
  
  def [](key)
    @cookie[key.to_s] || @now_cookie[key.to_s] || @cookie[key.to_sym] || @now_cookie[key.to_sym]
  end

  def []=(key, val)
    @cookie[key] = val
  end

  # serialize the hash into json and save in a cookie
  # add to the responses cookies
  def store_flash(res)
    save_cookie = JSON.generate(@cookie)
    res.set_cookie('_rails_lite_app_flash', value: save_cookie, path: "/")
  end
  
  def now
    @now_cookie
  end 
  
end
