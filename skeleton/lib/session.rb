require 'json'

class Session
  # find the cookie for this app
  # deserialize the cookie into a hash
  def initialize(req)
    cookies = req.cookies["_rails_lite_app"]
    unless cookies.nil?
      @cookie = JSON.parse(cookies)
    else
      @cookie = {}
    end
  end

  def [](key)
    @cookie[key]
  end

  def []=(key, val)
    @cookie[key] = val
  end

  # serialize the hash into json and save in a cookie
  # add to the responses cookies
  def store_session(res)
    save_cookie = JSON.generate(@cookie)
    res.set_cookie("_rails_lite_app", save_cookie)
  end
end
